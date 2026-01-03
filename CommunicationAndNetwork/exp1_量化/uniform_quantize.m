function [xq, error] = uniform_quantize(x, x_min, x_max, R)
%% 均匀量化函数
% 输入：
%   x : 输入信号
%   x_min, x_max : 量化范围
%   R : 量化比特数
% 输出：
%   xq : 量化后信号
%   error : 量化误差

L = 2^R;  % 量化级数
delta = (x_max - x_min) / L;  % 量化间隔

overload_lower = (x < x_min);
overload_upper = (x > x_max);
overload_mask = overload_lower | overload_upper;
normal_mask = ~overload_mask;

% 量化
xq = zeros(size(x));
if any(normal_mask)
    x_normal = x(normal_mask);
    quant_levels = floor((x_normal - x_min) / delta);
    xq_normal = x_min + quant_levels * delta + delta/2;
    xq(normal_mask) = xq_normal;
end
if any(overload_lower)
    xq(overload_lower) = x_min;  % 直接量化为最小值
end
if any(overload_upper)
    xq(overload_upper) = x_max;  % 直接量化为最大值
end

% 量化误差
error = x - xq;