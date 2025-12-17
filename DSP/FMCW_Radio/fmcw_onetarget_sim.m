clear; clc; close all

c = physconst('LightSpeed');    % 光速

%% FMCW雷达工作参数
Fc = 77e9;                      % 起始频率
lambda = c / Fc;                % 波长

BW = 500e6;                     % Hz，扫频带宽    
T_chirp = 10e-6;                % s，chirp时长
T_idle = 90e-6;                 % s，idle时长
Tc = T_chirp + T_idle;          % s，扫频周期

F_slope = BW / T_chirp;         % Hz/s，扫频斜率

numChirps = 100;                % 一帧中包含chirp的个数

Fs = 20e6;                          % Hz，ADC采样频率
numInTchirp = int32(Fs * T_chirp);  % 每个chirp内的采样点数
numInTc = int32(Fs * Tc);           % 每个扫频周期内的采样点数

%% 目标状态信息，每个目标用长度为3的行向量保存信息
%      col_1               col_2              col_3
% 相对雷达的起始距离    相对雷达的径向速度    目标回波强度
targets_info = [10 3 1];
numTargets = size(targets_info, 1);

%% 以下代码用于生成包含所有目标回波的中频信号

% 一个扫频周期时间内的采样时刻
t = 0 : 1/Fs : Tc * numChirps - 1/Fs;

% 调用calc_Phase_tx函数 计算雷达信号在不同时刻的载波相位
tx_phase = calc_Phase_tx(t, Fc, T_chirp, T_idle, F_slope);

% 对每个目标，计算对应不同采样时刻回波信号的双向延迟和载波相位，进而生成相应的中频信号
targets_dly = zeros(numTargets,length(t));      % 回波信号的双向延迟
targets_phase = zeros(numTargets,length(t));    % 回波信号的载波相位   
targets_if = zeros(numTargets,length(t));       % 回波信号与发射信号混频滤波后得到的中频信号

for i = 1 : numTargets
    r0 = targets_info(i, 1);
    v = targets_info(i, 2);
    target_dist = r0 + v * t; 
    targets_dly(i,:) = 2 * target_dist / c;
    targets_phase(i,:) = calc_Phase_tx(t - targets_dly(i,:), Fc, T_chirp, T_idle, F_slope);
    targets_if(i,:) = targets_info(i,3) * exp(1j*(tx_phase - targets_phase(i,:)));
end

% 生成包含所有目标回波的接收中频信号
rx_if = zeros(1,length(t));
for i = 1 : numTargets
    rx_if = rx_if + targets_if(i,:);
end

%% 绘制中频信号的时域波形图
figure('Name', '中频回波信号')
subplot(211);
plot(t(1:numInTchirp*2), real(targets_if(1, 1:numInTchirp*2)));
ylabel('信号波形');
xlabel('采样时间（s）');
title('目标1回波对应的中频信号');
subplot(212);
plot(t(1:numInTchirp*2), real(rx_if(1:numInTchirp*2)));
ylabel('信号波形');
xlabel('采样时间（s）');
title('总接收回波对应的中频信号');

%% 实现FMCW雷达测距和测速信号处理算法

% 测距：range-DFT，计算每个扫频周期内T_chirp时段内采样中频信号的DFT，DFT峰值对应着目标
numRangeFFT = 256;                          % range-DFT的变换点数
range_win = window(@rectwin,numInTchirp);   % DFT计算前可根据需要对采样数据进行加窗

range_fft = zeros(numChirps, numRangeFFT);  % 该数组用于记录每个扫频周期的DFT结果

for n = 1 : numChirps
    range_fft(n,:) = fft(rx_if(numInTc*(n-1)+1:numInTc*(n-1)+numInTchirp).*range_win',numRangeFFT);
end

% 换算为距离轴坐标 
axis_range = (0:numRangeFFT - 1) * physconst('LightSpeed') / 2 / (BW * numRangeFFT * (1 / Fs) / T_chirp); 

figure('Name','第一个扫频周期的测距结果');
plot(axis_range,abs(range_fft(1,:)))
xlabel('距离（m）');
ylabel('回波幅度');
title('第一个扫频周期的测距结果')
grid on;

% 测速：doppler-DFT，取一帧雷达信号每个chirp的range-DFT输出中同一序号的计算结果
% 形成numRangeFFT个由numChirps点组成的新序列，再对这些序列计算DFT。
numDopplerFFT = 256;                        % doppler-DFT的变换点数
doppler_win = window(@blackman,numChirps);  % DFT计算前可根据需要对采样数据进行加窗

doppler_fft = zeros(numRangeFFT,numDopplerFFT); % 该数组用于记录numRangeFFT个序列的DFT结果
for m = 1 : numRangeFFT
    doppler_fft(m,:) = fftshift(fft(range_fft(:,m).*doppler_win,numDopplerFFT));
end

% 换算为速度轴坐标 
axis_velocity = -1 .* (floor(numDopplerFFT / 2):-1: - floor(numDopplerFFT / 2) + 1) / (numDopplerFFT - 1) * (numChirps - 1) * physconst('LightSpeed') / (2 * Fc * Tc * numChirps);

figure('Name','距离多普勒二维DFT计算结果');
imagesc(axis_range, axis_velocity,abs(doppler_fft)')
xlabel('距离（m）');
ylabel('速度（m/s）');
title('距离多普勒二维DFT计算结果')

figure('Name','三维展示的距离多普勒二维DFT计算结果');
mesh( axis_velocity,axis_range,abs(doppler_fft))
ylabel('距离（m）');
xlabel('速度（m/s）');
zlabel('幅度');
title('距离多普勒二维DFT计算结果')


%% 请在本段添加代码，给出给定工作参数下FMCW雷达探测的理论性能
% 最大探测距离和测距分辨率
max_range = physconst('LightSpeed') * Fs / (2 * F_slope) / 2;
res_range = physconst('LightSpeed') / (2 * BW);

% 最大测速范围和测距分辨率
max_velocity = physconst('LightSpeed') / (4 * Fc * Tc);
res_velocity = physconst('LightSpeed') / (2 * Fc * Tc * numChirps);

fprintf('最大测距距离: %.2f m\n', max_range);
fprintf('测距分辨率: %.4f m\n', res_range);
fprintf('最大测速范围: ±%.2f m/s\n', max_velocity);
fprintf('测速分辨率: %.4f m/s\n', res_velocity);

%% 计算相位函数
function signal = calc_Phase_tx(t, fc, T_chirp, T_idle, slope)
    t = mod(t, T_chirp + T_idle);
    signal = zeros(size(t));
    signal(t < T_chirp) = 2 * pi * (t(t < T_chirp) .* (fc + 0.5 * slope * t(t < T_chirp)));
    signal(t >= T_chirp) = 2 * pi * fc .* t(t >= T_chirp);
end

