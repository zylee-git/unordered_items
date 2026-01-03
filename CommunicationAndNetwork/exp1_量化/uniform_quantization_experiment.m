function uniform_quantization_experiment()
%% 1. 均匀分布下的均匀量化实验

fprintf('\n=== 1. 均匀分布下的均匀量化实验 ===\n');

N = 1000000;  % 采样点数
a = -1; b = 1;  % 均匀分布区间
bits = [1, 2, 3];  % 均匀量化的比特数

% (1)随机生成采样点列
x = a + (b-a)*rand(N, 1);

% 绘制采样点列的幅度分布
figure;
sgtitle('均匀分布下的均匀量化实验', 'FontSize', 14, 'FontWeight', 'bold');
subplot(2, 2, 1);
histogram(x, 100, 'Normalization', 'pdf');
hold on;
x_theory = linspace(a, b, 1000);
pdf_theory = 0.5 * ones(size(x_theory)); % 理论PDF = 0.5
plot(x_theory, pdf_theory, 'r-', 'LineWidth', 2);
xlabel('x');
ylabel('p_X(x)');
title('均匀分布幅度分布');
legend('实验分布', '理论分布');
grid on;

% 初始化结果存储
results = struct();

for i = 1:length(bits)
    R = bits(i);
    L = 2^R;
    delta = (b - a) / L;
    
    % (2)均匀量化
    [xq, q_error] = uniform_quantize(x, a, b, R);
    
    % 绘制量化误差分布
    subplot(2, 2, i+1);
    histogram(q_error, 100, 'Normalization', 'pdf');
    xlabel('e(x)');
    ylabel('概率密度');
    title(sprintf('%d-bit 量化误差分布', R));
    grid on;
    
    % (3)计算实验值
    signal_power_exp = mean(x.^2);  % 信号功率实验值
    q_noise_power_exp = mean(q_error.^2);  % 量化噪声功率实验值
    SNRq_exp = 10 * log10(signal_power_exp / q_noise_power_exp);  % 信噪比实验值(dB)
    
    % (4)计算理论值
    signal_power_th = (b^3 - a^3) / (3*(b-a));  % 信号功率理论值
    q_noise_power_th = delta^2 / 12;  % 量化噪声功率理论值
    SNRq_th = 10 * log10(signal_power_th / q_noise_power_th);  % 信噪比理论值(dB)
    
    % 存储结果
    results(i).bits = R;
    results(i).signal_power_exp = 10 * log10(signal_power_exp);
    results(i).signal_power_th = 10 * log10(signal_power_th);
    results(i).q_noise_power_exp = 10 * log10(q_noise_power_exp);
    results(i).q_noise_power_th = 10 * log10(q_noise_power_th);
    results(i).SNRq_exp = SNRq_exp;
    results(i).SNRq_th = SNRq_th;
end

% 显示表格结果
fprintf('\n量化bit数\tσ²_q,exp(dB)\tσ²_q,th(dB)\tσ²_s,exp(dB)\tσ²_s,th(dB)\tSNRq,exp(dB)\tSNRq,th(dB)\n');
for i = 1:length(results)
    fprintf('%d\t\t%.4f\t%.4f\t%.4f\t\t%.4f\t\t%.4f\t\t%.4f\n', ...
        results(i).bits, ...
        results(i).q_noise_power_exp, ...
        results(i).q_noise_power_th, ...
        results(i).signal_power_exp, ...
        results(i).signal_power_th, ...
        results(i).SNRq_exp, ...
        results(i).SNRq_th);
end