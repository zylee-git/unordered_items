%% FMCW雷达多目标探测和测距测速功能仿真
clear; clc; close all;

c = physconst('LightSpeed');    % 光速

%% FMCW雷达工作参数（与单目标仿真一致）
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

%% 多目标状态信息 - 3个目标
%      col_1               col_2              col_3
% 相对雷达的起始距离    相对雷达的径向速度    目标回波强度
targets_info = [
    4.75,  0,  1.0;      % 目标1：距离4.75m，速度0m/s，强度1
    5.25,  4,  1.0;      % 目标2：距离5.25m，速度4m/s，强度1
    7.20, -5,  0.05      % 目标3：距离7.20m，速度-5m/s，强度0.05
];
numTargets = size(targets_info, 1);

%% 生成包含所有目标回波的中频信号
t = 0 : 1/Fs : Tc * numChirps - 1/Fs;  % 时间轴
tx_phase = calc_Phase_tx(t, Fc, T_chirp, T_idle, F_slope);  % 发射信号相位

targets_dly = zeros(numTargets, length(t));      % 回波信号的双向延迟
targets_phase = zeros(numTargets, length(t));    % 回波信号的载波相位   
targets_if = zeros(numTargets, length(t));       % 各目标单独的中频信号

for i = 1 : numTargets
    r0 = targets_info(i, 1);
    v = targets_info(i, 2);
    target_dist = r0 + v * t; 
    targets_dly(i,:) = 2 * target_dist / c;
    targets_phase(i,:) = calc_Phase_tx(t - targets_dly(i,:), Fc, T_chirp, T_idle, F_slope);
    targets_if(i,:) = targets_info(i,3) * exp(1j*(tx_phase - targets_phase(i,:)));
end

% 总接收回波信号
rx_if = sum(targets_if, 1);

%% 1) 绘制中频信号时域波形
figure('Name', '多目标中频回波信号');
subplot(4, 1, 1);
plot(t(1:numInTchirp*2), real(rx_if(1:numInTchirp*2)));
ylabel('信号波形');
xlabel('采样时间（s）');
title('总接收回波对应的中频信号');
grid on;

% 绘制每个目标的中频信号
for i = 1:3
    subplot(4, 1, i+1);
    plot(t(1:numInTchirp*2), real(targets_if(i, 1:numInTchirp*2)));
    ylabel('信号波形');
    xlabel('采样时间（s）');
    title(sprintf('目标%d单独回波中频信号 (距离=%.2fm, 速度=%.1fm/s)', ...
          i, targets_info(i,1), targets_info(i,2)));
    grid on;
end

%% 2) Range-DFT处理（测距）
numRangeFFT = 256;
range_win = window(@rectwin, numInTchirp);  % 矩形窗

% 对每个chirp进行Range-DFT
range_fft = zeros(numChirps, numRangeFFT);
for n = 1 : numChirps
    start_idx = numInTc*(n-1) + 1;
    end_idx = numInTc*(n-1) + numInTchirp;
    chirp_signal = rx_if(start_idx:end_idx);
    range_fft(n,:) = fft(chirp_signal .* range_win', numRangeFFT);
end

% 换算为距离轴坐标
axis_range = (0:numRangeFFT-1) * c / (2 * BW * numRangeFFT * (1/Fs) / T_chirp);

% 绘制第一个chirp的Range-DFT结果
figure('Name', '第一个Chirp的Range-DFT测距结果');
plot(axis_range, abs(range_fft(1,:)));
xlabel('距离（m）');
ylabel('回波幅度');
title('第一个Chirp的Range-DFT测距结果');
grid on;
xlim([0, 15]);

%% 3) Doppler-FFT处理（测速）
numDopplerFFT = 256;
doppler_win = window(@blackman, numChirps);

% 对每个距离单元进行Doppler-FFT
doppler_fft = zeros(numRangeFFT, numDopplerFFT);
for m = 1 : numRangeFFT
    doppler_signal = range_fft(:, m);
    doppler_fft(m,:) = fftshift(fft(doppler_signal .* doppler_win, numDopplerFFT));
end

% 换算为速度轴坐标
axis_velocity = -1 .* (floor(numDopplerFFT/2):-1:-floor(numDopplerFFT/2)+1) / ...
                (numDopplerFFT-1) * (numChirps-1) * c / (2 * Fc * Tc * numChirps);

% 绘制距离-多普勒二维图
figure('Name', '距离多普勒二维DFT计算结果');
imagesc(axis_range, axis_velocity, abs(doppler_fft)');
xlabel('距离（m）');
ylabel('速度（m/s）');
title('距离-多普勒二维DFT计算结果');
colorbar;
grid on;

% 三维视图
figure('Name', '三维距离多普勒图');
mesh(axis_velocity, axis_range, abs(doppler_fft));
ylabel('距离（m）');
xlabel('速度（m/s）');
zlabel('幅度');
title('三维距离多普勒图');
view(45, 30);
grid on;

%% 4) 检测结果分析
% 寻找二维峰值
abs_matrix = abs(doppler_fft);
threshold = max(abs_matrix(:)) * 0.3;  % 30%阈值
[row_idx, col_idx] = find(abs_matrix > threshold);

detected_targets = [];
for i = 1:length(row_idx)
    range_val = axis_range(row_idx(i));
    vel_val = axis_velocity(col_idx(i));
    
    % 去除重复检测
    is_new = true;
    for j = 1:size(detected_targets, 1)
        if abs(range_val - detected_targets(j,1)) < 0.5 && abs(vel_val - detected_targets(j,2)) < 1
            is_new = false;
            break;
        end
    end
    
    if is_new
        detected_targets = [detected_targets; range_val, vel_val];
    end
end

fprintf('\n=== 距离-多普勒联合检测结果 ===\n');
if isempty(detected_targets)
    fprintf('未检测到任何目标\n');
else
    fprintf('检测到的目标:\n');
    for i = 1:size(detected_targets, 1)
        fprintf('  目标%d: 距离=%.2fm, 速度=%.1fm/s\n', ...
                i, detected_targets(i,1), detected_targets(i,2));
    end
    
    % 检查是否能检测到全部3个目标
    if size(detected_targets, 1) < 3
        fprintf('✗ 不能检测到全部3个目标\n');
        fprintf('原因：目标3回波强度太低（0.05），在距离-多普勒图中被淹没\n');
        fprintf('解决方案：\n');
        fprintf('  1. 增加信号处理增益\n');
        fprintf('  2. 使用更长的观测时间\n');
        fprintf('  3. 提高发射功率\n');
    else
        fprintf('✓ 能检测到全部3个目标\n');
    end
end

%% 计算相位函数（与单目标程序相同）
function signal = calc_Phase_tx(t, fc, T_chirp, T_idle, slope)
    t = mod(t, T_chirp + T_idle);
    signal = zeros(size(t));
    signal(t < T_chirp) = 2 * pi * (t(t < T_chirp) .* (fc + 0.5 * slope * t(t < T_chirp)));
    signal(t >= T_chirp) = 2 * pi * fc .* t(t >= T_chirp);
end