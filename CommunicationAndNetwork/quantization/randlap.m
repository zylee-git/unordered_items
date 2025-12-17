function x = randlap(size, sigma_x)
%% 拉普拉斯分布采样的函数
% 输入：
%   size : 生成采样点的个数
%   sigma_x : 拉普拉斯分布参数
% 输出：
%   x : 拉普拉斯分布采样序列

x = (log(rand(size,1)) .* (2*floor(rand(size,1)*2)-1)) * sigma_x / sqrt(2);