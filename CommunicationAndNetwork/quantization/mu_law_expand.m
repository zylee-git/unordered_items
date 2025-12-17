function x = mu_law_expand(y, x_max, mu)
%% μ律扩张函数
% 输入：
%   y - 压缩后信号
%   x_max - 最大幅度
%   mu - μ律参数
% 输出：
%   x - 扩张后信号

x = zeros(size(y));
for i = 1:length(y)
    if y(i) >= 0
        sgn = 1;
    else
        sgn = -1;
    end
    x(i) = x_max / mu * ((1 + mu)^(abs(y(i)) / x_max) - 1) * sgn;
end