% 通信与网络 实验2 基带传输
% 电平传输 实电平信道
clearvars;
close all;
clc;
% rng(2025);  %固定种子

% 参数
% 信噪比范围 E_s/\sigma^2
SNR_dB = -5:1:20;
SNR = 10.^(SNR_dB/10);

% 符号数
M = [2;4];

% 比特序列长度，可修改
N = 5e5;
if mod(N,2)~=0
    error('Invalid bit sequence length');
end

% 初始化向量，存储误符号率和误比特率
BER = zeros(length(M), length(SNR));
SER = zeros(length(M), length(SNR));

for cnt1 = 1:length(M)
    M_cur = M(cnt1);
    % 随机生成比特序列（data_bit）
    data_bit = randi([0 1], 1, N);

    % 符号映射，转化为调制后的电平序列（data_mod）
    data_mod = Gray_mapping_real(data_bit, M_cur);

    % 发送端平均电平能量
    Es = mean(data_mod.^2);
    % 理论平均电平能量
    Es_theory = (M_cur^2-1)/3;

    for cnt2 = 1:length(SNR)
        % 加性噪声
        noise_power = Es_theory / SNR(cnt2);
        noise = sqrt(noise_power) * randn(1, length(data_mod));

        % 加性高斯噪声信道，获得接收信号（data_rx）
        data_rx = data_mod + noise;

        % 解调，根据电平序列获得比特序列（data_bit_demod）
        data_bit_demod = Inverse_Gray_mapping(data_rx, M_cur);

        % 差错比特
        bit_err = xor(data_bit, data_bit_demod);
        % 计算差错比特数
        BER(cnt1,cnt2) = sum(bit_err);
        % 计算差错符号数
        if M_cur == 2
            SER(cnt1,cnt2) = BER(cnt1,cnt2);
        elseif M_cur == 4
            bit_err = reshape(bit_err,2,[]);
            SER(cnt1,cnt2) = sum(bit_err(1,:) | bit_err(2,:));
        end
    end
end
% 误码率和误比特率归一化
BER = BER./N;
SER = SER./(N./log2(M));

% 理论值
SER_theory = (2-2./M).*qfunc(sqrt(3./(M.^2-1).*SNR));
BER_theory = SER_theory./log2(M);

% 绘图
figure;
semilogy(SNR_dB, BER(1,:),'bo', ...
    SNR_dB, BER_theory(1,:),'b', ...
    SNR_dB, BER(2,:),'rx', ...
    SNR_dB, BER_theory(2,:),'r');
xlabel('信噪比E_s/\sigma^2 (dB)');
ylabel('误比特率');
set(gca, 'ylim', [1e-4,1e0]);
legend('M=2, simulation', 'M=2, theory', ...
    'M=4, simulation', 'M=4, theory', ...
    'Location', 'southwest');
title('实电平信道 BER-SNR');
box on;
grid on;

figure;
semilogy(SNR_dB, SER(1,:),'bo', ...
    SNR_dB, SER_theory(1,:),'b', ...
    SNR_dB, SER(2,:),'rx', ...
    SNR_dB, SER_theory(2,:),'r');
xlabel('信噪比E_s/\sigma^2 (dB)');
ylabel('误符号率');
set(gca, 'ylim', [1e-4,1e0]);
legend('M=2, simulation', 'M=2, theory', ...
    'M=4, simulation', 'M=4, theory', ...
    'Location', 'southwest');
title('实电平信道 SER-SNR');
box on;
grid on;


% 实电平信道，由比特序列映射到电平序列
function data_mod = Gray_mapping_real(data_bit, M)
% 对应的符号序列长度
N = length(data_bit)/log2(M);
data_mod = zeros(1, N);
if M==2
    % 逐个符号判断映射关系
    for n = 1:N
        current_bits = data_bit(n);
        if current_bits == 0
            data_mod(n) = -1;
        elseif current_bits == 1
            data_mod(n) = 1;
        end
    end
elseif M==4
    % 逐个符号判断映射关系
    for n = 1:N
        current_bits = data_bit(2*n-1 : 2*n);
        if current_bits(1)==0 && current_bits(2)==0
            data_mod(n) = -3;
        elseif current_bits(1)==0 && current_bits(2)==1
            data_mod(n) = -1;
        elseif current_bits(1)==1 && current_bits(2)==1
            data_mod(n) = 1;
        elseif current_bits(1)==1 && current_bits(2)==0
            data_mod(n) = 3;
        end
    end
else
    error('Invalid modulation order');
end
end

% 实电平信道，由电平序列映射到比特序列
function data_bit_demod = Inverse_Gray_mapping(data_rx, M)
% 初始化比特序列
N = length(data_rx)*log2(M);
data_bit_demod = zeros(1, N);
if M==2
    % 逐个符号判决
    for n = 1:N
        current_level = data_rx(n);
        if current_level < 0
            data_bit_demod(n) = 0;
        else
            data_bit_demod(n) = 1;
        end
    end
elseif M==4
    % 逐个符号判决
    for n = 1:(N/2)
        current_level = data_rx(n);
        if current_level < -2
            data_bit_demod(2*n-1:2*n) = [0,0];
        elseif current_level < 0
            data_bit_demod(2*n-1:2*n) = [0,1];
        elseif current_level < 2
            data_bit_demod(2*n-1:2*n) = [1,1];
        else
            data_bit_demod(2*n-1:2*n) = [1,0];
        end
    end
end
end