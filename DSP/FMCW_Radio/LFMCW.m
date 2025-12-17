%% 线性调频连续波信号产生与分析
clear; clc; close all;

%% 1. 参数设置
fc = 0;                % 起始频率 (Hz)
B = 150e6;             % 带宽 (Hz)
Tc = 2e-6;             % chirp持续时间 (s)
S = B / Tc;            % 扫频斜率 (Hz/s)

% 采样率选择 fs = 400MHz
fs = 400e6;            % 采样率 (Hz)

%% 2. 生成线性调频连续波信号
% 时间轴
t = 0:1/fs:Tc-1/fs;    % 从0到Tc-1/fs，避免包含Tc时刻
N = length(t);         % 采样点数

% 线性调频信号
x = cos(2*pi*fc*t + pi*S*t.^2);

%% 3. 绘制时域波形
figure('Name', '线性调频连续波信号时域波形', 'Position', [100, 100, 800, 400]);

% 完整时域波形
subplot(2, 1, 1);
plot(t*1e6, x, 'b-', 'LineWidth', 1.2);
xlabel('时间 (\mu s)');
ylabel('幅度');
title('线性调频连续波信号时域波形');
grid on;
xlim([0, Tc*1e6]);

% 局部放大（前0.2μs）
subplot(2, 1, 2);
plot(t(t<0.2e-6)*1e6, x(t<0.2e-6), 'r-', 'LineWidth', 1.5);
xlabel('时间 (\mu s)');
ylabel('幅度');
title('时域波形局部放大（前0.2μs）');
grid on;
xlim([0, 0.2]);

%% 4. DFT频域分析
figure('Name', 'DFT频域分析', 'Position', [100, 100, 900, 600]);

% 计算DFT
N_fft = 2^nextpow2(N);  % FFT点数，取2的整数次幂
X = fft(x, N_fft);
f = (-N_fft/2:N_fft/2-1) * (fs/N_fft);  % 频率轴（模拟频率）

% 移动零频到中心
X_shift = fftshift(X);

% 绘制幅度谱
subplot(1, 2, 1);
plot(f/1e6, abs(X_shift), 'b-', 'LineWidth', 1.2);
xlabel('频率 (MHz)');
ylabel('幅度');
title('幅度谱');
grid on;
xlim([-200, 200]);

% 绘制相位谱
subplot(1, 2, 2);
plot(f/1e6, angle(X_shift), 'r-', 'LineWidth', 1.2);
xlabel('频率 (MHz)');
ylabel('相位 (rad)');
title('相位谱');
grid on;
xlim([-200, 200]);

%% 5. STFT时频分析
figure('Name', 'STFT时频分析（不同配置）', 'Position', [100, 100, 1200, 800]);

% 配置1
subplot(2, 2, 1);
window1 = 256;         % 窗口长度
noverlap1 = 200;       % 重叠点数
nfft1 = 512;           % FFT点数
spectrogram(x, hamming(window1), noverlap1, nfft1, fs, 'yaxis');
title('配置1：Hamming窗，窗口256点，重叠200点');
colorbar;
caxis([-100, 0]);

% 配置2
subplot(2, 2, 2);
window2 = 512;         % 窗口长度
noverlap2 = 400;       % 重叠点数
nfft2 = 1024;          % FFT点数
spectrogram(x, hann(window2), noverlap2, nfft2, fs, 'yaxis');
title('配置2：Hann窗，窗口512点，重叠400点');
colorbar;
caxis([-100, 0]);

% 配置3
subplot(2, 2, 3);
window3 = 128;         % 窗口长度
noverlap3 = 100;       % 重叠点数
nfft3 = 256;           % FFT点数
spectrogram(x, rectwin(window3), noverlap3, nfft3, fs, 'yaxis');
title('配置3：矩形窗，窗口128点，重叠100点');
colorbar;
caxis([-100, 0]);

% 配置4
subplot(2, 2, 4);
window4 = 384;         % 窗口长度
noverlap4 = 300;       % 重叠点数
nfft4 = 768;           % FFT点数
spectrogram(x, blackman(window4), noverlap4, nfft4, fs, 'yaxis');
title('配置4：Blackman窗，窗口384点，重叠300点');
colorbar;
caxis([-100, 0]);
