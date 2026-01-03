clear;
clc;
close all;

% 码长
n = 7;

% 信息位长
k = 4;

% 传输比特块数
M = 1000000;

% 生成矩阵
Q = [1 1 1; 1 1 0; 1 0 1; 0 1 1];
G = [eye(k) Q];

% 监督矩阵
H = [Q' eye(n-k)];

% 随机生成M个需要传输的比特块
x_data = randi([0 1], M, k);

% 将每个比特块编码成（7，4）汉明码
x_code = mod(x_data*G , 2); %进行编码


% 经过误符号率为p的BSC信道
p = logspace(log10(1e-3),log10(2e-1),20);

% 初始化误码率
BlockErrorRate_uncode=zeros(1,20);
BitErrorRate_uncode=zeros(1,20);
BlockErrorRate_code=zeros(1,20);
BitErrorRate_code=zeros(1,20);

for ind=1:20
    noise = rand(M, n) < p(ind);
    y = mod(x_code + noise, 2);
     
    % 利用监督矩阵计算校正子
    syndrome = mod(y*H',2);
     
    % 比较校正子和监督矩阵，找出错误位置
    error_positions = zeros(M,1);
    for i = 1:M
        if ismember(H',syndrome(i,:),'rows') == zeros(n,1)
            error_positions(i,1) = 0; 
        else
            error_positions(i,1) = find(ismember(H',syndrome(i,:),'rows'));
        end
    end
    
    % 进行纠错
    y_decode = y;
    for i = 1:M
        if error_positions(i,1) ~= 0
            y_decode(i, error_positions(i,1)) = ~y_decode(i, error_positions(i,1)); 
        end
    end
    % 去掉监督位
    y_decode = y_decode(:,1:k);
    
    % 计算无信道编码时的误块率和误比特率
    result_uncode = mod(x_data+y(:,1:k),2);
    BlockErrorRate_uncode(ind) = sum(~ismember(result_uncode,zeros(1,k),'rows'))/M;
    BitErrorRate_uncode(ind) = sum(result_uncode,'all')/(M*k);
    
    % 计算有信道编码时的误块率和误比特率
    result_code = mod(x_data+y_decode,2);
    BlockErrorRate_code(ind) = sum(~ismember(result_code,zeros(1,k),"rows"))/M;
    BitErrorRate_code(ind) = sum(result_code,"all")/(M*k);
end

figure;
loglog(p,BitErrorRate_uncode,'r-o',p,BlockErrorRate_uncode,'r-+',p,BitErrorRate_code,'b-o',p,BlockErrorRate_code,'b-+');
title('误码率随信道误符号率的变化');
xlabel('信道误符号率p');
ylabel('误码率');
legend('误比特率——无编码','误块率——无编码','误比特率——有编码','误块率——有编码');