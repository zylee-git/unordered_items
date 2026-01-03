function y = mu_law_compress(x, x_max, mu)
%% μ律压缩函数
% 输入：
%   x - 输入信号
%   x_max - 最大幅度
%   mu - μ律参数
% 输出：
%   y - 压缩后信号

y = zeros(size(x));
for i = 1:length(x)
    if x(i) >= 0
        sgn = 1;
    else
        sgn = -1;
    end
    y(i) = x_max * log(1 + mu * abs(x(i)) / x_max) / log(1 + mu) * sgn;
end

% 限制输出范围
y = max(min(y, x_max), -x_max);