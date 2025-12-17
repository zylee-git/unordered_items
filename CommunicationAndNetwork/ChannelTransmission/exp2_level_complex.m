% 通信与网络 实验2 基带传输
% 电平传输 复电平信道
clearvars;
close all;
clc;
% rng(2025);  %固定种子

% 参数
% 信噪比范围 E_s/\sigma^2
SNR_dB = 0:1:25;
SNR = 10.^(SNR_dB/10);

% 符号数
M = [4;16];

% 重复实验次数，可修改
N = 5e5;
if mod(N,4)~=0
    error('Invalid bit sequence length');
end

% 记录BER和SER
BER = zeros(length(M),length(SNR));
SER = zeros(length(M),length(SNR));

% 记录两个信噪比下的接收信号
SNR_dB_rec = [15,20];

for cnt1 = 1:length(M)
    M_cur = M(cnt1);
    % 随机生成比特序列（data_bit）
    data_bit = randi([0 1], 1, N);

    % 符号映射，转化为调制后的电平序列（data_mod）
    data_mod = Gray_mapping_complex(data_bit, M_cur);

    % 发送端平均电平能量
    Es = mean(abs(data_mod).^2);
    % 理论平均电平能量
    if M(cnt1)==4
        Es_theory = 2;
    elseif M(cnt1)==16
        Es_theory = 10;
    end

    for cnt2 = 1:length(SNR)
        % 加性噪声
        noise_power = Es_theory / SNR(cnt2);
        noise = sqrt(noise_power) * (randn(1, length(data_mod)) + 1j*randn(1, length(data_mod)));

        % 加性高斯噪声信道，获得接收信号（data_rx）
        data_rx = data_mod + noise;
        if M_cur==16 && ismember(SNR_dB(cnt2),SNR_dB_rec)
            figure;
            scatter(real(data_rx), imag(data_rx), 10, 'filled');
            box on; grid on;
            title(['SNR=',num2str(SNR_dB(cnt2)),'dB']);
        end

        % 解调，根据电平序列获得比特序列（data_bit_demod）
        data_bit_demod = Inverse_Gray_mapping_complex(data_rx, M_cur);

        % 差错比特
        bit_err = xor(data_bit, data_bit_demod);
        % 计算差错比特数
        BER(cnt1,cnt2) = sum(bit_err);
        % 计算差错符号数
        bit_err = reshape(bit_err, log2(M_cur), []);
        SER(cnt1,cnt2) = sum(any(bit_err,1));
    end
end
% 误码率和误比特率归一化
BER = BER./N;
SER = SER./(N./log2(M));

% 理论值
ser_theory = 4*(1-1./sqrt(M)) .* qfunc(sqrt(3*SNR./(2*(M-1)))) ...
            - 4*(1-1./sqrt(M)).^2 .* qfunc(sqrt(3*SNR./(2*(M-1)))).^2;
ber_theory = ser_theory./log2(M);

% 绘图
figure;
semilogy(SNR_dB, BER(1,:),'bo', ...
    SNR_dB, ber_theory(1,:),'b', ...
    SNR_dB, BER(2,:),'rx', ...
    SNR_dB, ber_theory(2,:),'r');
xlabel('信噪比E_s/\sigma^2 (dB)');
ylabel('误比特率');
set(gca, 'ylim', [1e-4,1e0]);
legend('M=4, simulation', 'M=4, theory', ...
    'M=16, simulation', 'M=16, theory', ...
    'Location', 'southwest');
title('复电平信道 BER-SNR');
box on;
grid on;

figure;
semilogy(SNR_dB, SER(1,:),'bo', ...
    SNR_dB, ser_theory(1,:),'b', ...
    SNR_dB, SER(2,:),'rx', ...
    SNR_dB, ser_theory(2,:),'r');
xlabel('信噪比E_s/\sigma^2 (dB)');
ylabel('误符号率');
set(gca, 'ylim', [1e-4,1e0]);
legend('M=4, simulation', 'M=4, theory', ...
    'M=16, simulation', 'M=16, theory', ...
    'Location', 'southwest');
title('复电平信道 SER-SNR');
box on;
grid on;


% 复电平信道，由比特序列映射到电平序列
function data_mod = Gray_mapping_complex(data_bit, M)
% 对应的符号序列长度
N = length(data_bit)/log2(M);
data_mod = zeros(1,N);
if M==4
    % 逐个符号判断映射关系
    for n = 1:N
        current_bits = data_bit(2*n-1 : 2*n);
        if current_bits(1)==0 && current_bits(2)==0
            data_mod(n) = 1+1j;
        elseif current_bits(1)==0 && current_bits(2)==1
            data_mod(n) = -1+1j;
        elseif current_bits(1)==1 && current_bits(2)==1
            data_mod(n) = -1-1j;
        elseif current_bits(1)==1 && current_bits(2)==0
            data_mod(n) = 1-1j;
        end
    end
elseif M==16
    % 逐个符号判断映射关系
    for n = 1:N
        current_bits = data_bit(4*n-3 : 4*n);
        if all(current_bits==[0,0,0,0])
            data_mod(n) = 3+3j;
        elseif all(current_bits==[0,0,0,1])
            data_mod(n) = 1+3j;
        elseif all(current_bits==[0,0,1,1])
            data_mod(n) = -1+3j;
        elseif all(current_bits==[0,0,1,0])
            data_mod(n) = -3+3j;
        elseif all(current_bits==[0,1,0,0])
            data_mod(n) = 3+1j;
        elseif all(current_bits==[0,1,0,1])
            data_mod(n) = 1+1j;
        elseif all(current_bits==[0,1,1,1])
            data_mod(n) = -1+1j;
        elseif all(current_bits==[0,1,1,0])
            data_mod(n) = -3+1j;
        elseif all(current_bits==[1,1,0,0])
            data_mod(n) = 3-1j;
        elseif all(current_bits==[1,1,0,1])
            data_mod(n) = 1-1j;
        elseif all(current_bits==[1,1,1,1])
            data_mod(n) = -1-1j;
        elseif all(current_bits==[1,1,1,0])
            data_mod(n) = -3-1j;
        elseif all(current_bits==[1,0,0,0])
            data_mod(n) = 3-3j;
        elseif all(current_bits==[1,0,0,1])
            data_mod(n) = 1-3j;
        elseif all(current_bits==[1,0,1,1])
            data_mod(n) = -1-3j;
        elseif all(current_bits==[1,0,1,0])
            data_mod(n) = -3-3j;
        end
    end
end
end

% 复数电平信道，由电平序列映射到比特序列
function data_bit_demod = Inverse_Gray_mapping_complex(data_rx, M)
% 符号序列长度
N = length(data_rx)*log2(M);
data_bit_demod = zeros(1, N);
if M==4
    % 逐个符号判决
    for n = 1:(N/2)
        current_level=data_rx(n);
        if (real(current_level) >= 0)&&(imag(current_level) > 0)
            data_bit_demod(2*n-1:2*n) = [0,0];
        elseif (real(current_level) < 0)&&(imag(current_level) >= 0)
            data_bit_demod(2*n-1:2*n) = [0,1];
        elseif (real(current_level) <= 0)&&(imag(current_level) < 0)
            data_bit_demod(2*n-1:2*n) = [1,1];
        else
            data_bit_demod(2*n-1:2*n) = [1,0];
        end
    end
elseif M==16
    % 逐个符号判决
    for n = 1:(N/4)
        current_level=data_rx(n);
        if real(current_level) >= 2
            if imag(current_level) >= 2
                data_bit_demod(4*n-3:4*n) = [0,0,0,0];
            elseif imag(current_level) >= 0
                data_bit_demod(4*n-3:4*n) = [0,1,0,0];
            elseif imag(current_level) >= -2
                data_bit_demod(4*n-3:4*n) = [1,1,0,0];
            else
                data_bit_demod(4*n-3:4*n) = [1,0,0,0];
            end
        elseif real(current_level) >= 0
            if imag(current_level) >= 2
                data_bit_demod(4*n-3:4*n) = [0,0,0,1];
            elseif imag(current_level) >= 0
                data_bit_demod(4*n-3:4*n) = [0,1,0,1];
            elseif imag(current_level) >= -2
                data_bit_demod(4*n-3:4*n) = [1,1,0,1];
            else
                data_bit_demod(4*n-3:4*n) = [1,0,0,1];
            end
        elseif real(current_level) >= -2
            if imag(current_level) >= 2
                data_bit_demod(4*n-3:4*n) = [0,0,1,1];
            elseif imag(current_level) >= 0
                data_bit_demod(4*n-3:4*n) = [0,1,1,1];
            elseif imag(current_level) >= -2
                data_bit_demod(4*n-3:4*n) = [1,1,1,1];
            else
                data_bit_demod(4*n-3:4*n) = [1,0,1,1];
            end
        else
            if imag(current_level) >= 2
                data_bit_demod(4*n-3:4*n) = [0,0,1,0];
            elseif imag(current_level) >= 0
                data_bit_demod(4*n-3:4*n) = [0,1,1,0];
            elseif imag(current_level) >= -2
                data_bit_demod(4*n-3:4*n) = [1,1,1,0];
            else
                data_bit_demod(4*n-3:4*n) = [1,0,1,0];
            end
        end
    end
end
end