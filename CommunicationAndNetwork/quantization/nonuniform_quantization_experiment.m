function nonuniform_quantization_experiment()
%% 2. 基于µ律压扩的非均匀量化

fprintf('\n=== 2. 拉普拉斯分布下的非均匀量化实验 ===\n');

N = 1000000;  % 采样点数
sigma_x = 1;  % 拉普拉斯分布参数
R = 9;  % 量化比特数
x_max = 10;  % 量化范围
mu = 255;  % μ律压扩参数

% (1)验证函数实现的正确性
figure;
for i = 1 : 9
    sigma_test = 0.5 * i;
    x_test = randlap(N, sigma_test);
    sgtitle('验证函数实现的正确性', 'FontSize', 14, 'FontWeight', 'bold');
    subplot(3, 3, i);
    histogram(x_test, 100, 'Normalization', 'pdf');
    hold on;
    x_test_theory = linspace(-10, 10, 2000);
    pdf_test_theory = 1/(sqrt(2)*sigma_test) * exp(-sqrt(2)*abs(x_test_theory)/sigma_test);
    plot(x_test_theory, pdf_test_theory, 'r-', 'LineWidth', 2);
    xlabel('x');
    ylabel('p_X(x)');
    title(sprintf('σ_x=%.1f', sigma_test));
    legend('实验分布', '理论分布');
    grid on;
end

% 生成拉普拉斯分布随机采样数据
x = randlap(N, sigma_x);
figure;
sgtitle('拉普拉斯分布下的非均匀量化实验', 'FontSize', 14, 'FontWeight', 'bold');
subplot(3, 2, 1);
histogram(x, 100, 'Normalization', 'pdf');
hold on;
x_theory = linspace(-10, 10, 2000);
pdf_theory = 1/(sqrt(2)*sigma_x) * exp(-sqrt(2)*abs(x_theory)/sigma_x);
plot(x_theory, pdf_theory, 'r-', 'LineWidth', 2);
xlabel('x');
ylabel('p_X(x)');
title('拉普拉斯分布幅度分布');
legend('实验分布', '理论分布');
grid on;

% (2)在[-10, 10]区间进行9-bit均匀量化
[xq_uniform, error_uniform] = uniform_quantize(x, -x_max, x_max, R);

% 计算均匀量化性能
signal_power = mean(x.^2);
noise_power_uniform = mean(error_uniform.^2);
SNR_uniform = 10 * log10(signal_power / noise_power_uniform);

subplot(3, 2, 2);
histogram(error_uniform, 100, 'Normalization', 'pdf');
xlabel('e(x)');
ylabel('概率密度');
title('均匀量化误差分布');
grid on;

fprintf('\n(1)均匀量化下的功率和信噪比\n');
fprintf('E[x²_exp](dB)\tσ²_exp(dB)\tSNR_exp(dB)\n');
fprintf('%.4f\t\t%.4f\t%.4f\n', 10 * log10(signal_power), 10 * log10(noise_power_uniform), SNR_uniform);

% (3)μ律压扩
y = mu_law_compress(x, x_max, mu);
subplot(3, 2, 3);
histogram(y, 100, 'Normalization', 'pdf');
xlabel('幅度');
ylabel('概率密度');
title('压缩后信号分布');
grid on;

% (4)对压缩信号进行均匀量化
[yq, error_BC] = uniform_quantize(y, -x_max, x_max, R);
subplot(3, 2, 4);
histogram(error_BC, 100, 'Normalization', 'pdf');
xlabel('e_{BC}(x)');
ylabel('概率密度');
title('压缩域量化误差分布');
grid on;

% 计算压缩域性能
signal_power_B = mean(y.^2);
noise_power_BC = mean(error_BC.^2);
SNR_BC = 10 * log10(signal_power_B / noise_power_BC);

fprintf('\n(2)μ律压缩后均匀量化下的功率和信噪比\n');
fprintf('E[x²_B,exp](dB)\tσ²_BC,exp(dB)\tSNR_BC,exp(dB)\n');
fprintf('%.4f\t\t%.4f\t%.4f\n', 10 * log10(signal_power_B), 10 * log10(noise_power_BC), SNR_BC);

% (5)扩张
x_recon = mu_law_expand(yq, x_max, mu);
error_AD = x - x_recon;

subplot(3, 2, 5);
histogram(error_AD, 100, 'Normalization', 'pdf');
xlabel('e_{AD}(x)');
ylabel('概率密度');
title('重建信号量化误差分布');
grid on;

% 计算重建信号性能
noise_power_AD = mean(error_AD.^2);
SNR_AD = 10 * log10(signal_power / noise_power_AD);
L = 2^R;
SNR_theory = 10 * log10(3 * L^2 / (log(1 + mu))^2);

fprintf('\n(3)扩张重建后的功率和信噪比\n');
fprintf('E[x²_exp](dB)\tσ²_AD,exp(dB)\tSNR_AD,exp(dB)\tSNR_q,AD,exp(dB)\n');
fprintf('%.4f\t\t%.4f\t%.4f\t\t%.4f\n', 10 * log10(signal_power), 10 * log10(noise_power_AD), SNR_AD, SNR_theory);