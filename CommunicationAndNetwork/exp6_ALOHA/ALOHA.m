%% 纯ALOHA仿真
clc
clear
% 设置系统参数
N = 100;% 用户数
lambdas = 100/N:100/N:5000/N;% 单个用户的帧到达率集合
b = 100;
R = 1e5;
T_fr = b/R;
T = 1e2;% 总仿真随机接入时长，可以根据仿真情况适当修改

lambdalength = length(lambdas);
rho_simu1 = zeros(size(lambdas));% 根据纯指数分布生成所有用户的帧到达情况下的总归一化吞吐速率
rho_simu2 = zeros(size(lambdas));% 设置某一用户在发送帧的过程中不会有新的帧到达该用户时计算的总归一化吞吐速率
tic
for lambdaCounter = 1:lambdalength

    lambda = lambdas(lambdaCounter);
    MAX_number_of_arrived_frames_in_T_for_each_user=ceil(T*lambda + 5*sqrt(T*lambda));

    % 生成所有用户的帧到达情况-到达时刻与所属用户
    TotalFrameArrivalConditions1 = [];% 根据纯指数分布生成所有用户的帧到达情况
    TotalFrameArrivalConditions2 = [];% 在指数分布的情况下，设置某一用户在发送帧的过程中不会有新的帧到达该用户
    for n = 1:N

        % 生成TotalFrameArrivalConditions1---

        FrameArrivalTimes=zeros(1,MAX_number_of_arrived_frames_in_T_for_each_user); % 预开一个数组用来存储当前用户的T时间内的所有帧到达时刻, 同学们要注意避免溢出
        
        % 采用逐个累加的方式生成T时间内的所有帧到达时刻
        number_of_arrived_frames = 0;
        FrameArrivalTime = exprnd(1/lambda);% 第一帧的到达时刻

        while FrameArrivalTime<T
            % 按照指数分布生成帧到达时刻
            number_of_arrived_frames = number_of_arrived_frames+1;
            FrameArrivalTimes(number_of_arrived_frames) = FrameArrivalTime;
            FrameArrivalTime =  FrameArrivalTime + exprnd(1/lambda);% 当前最新一帧的到达时刻
        end
        CurrentUserFrameArrivals = [FrameArrivalTimes(1:number_of_arrived_frames);ones(1,number_of_arrived_frames)*n];
        TotalFrameArrivalConditions1 = [TotalFrameArrivalConditions1,CurrentUserFrameArrivals];
        
        % 生成TotalFrameArrivalConditions2---
        FrameArrivalTimes=zeros(1,MAX_number_of_arrived_frames_in_T_for_each_user);
        number_of_arrived_frames = 0;
        FrameArrivalTime = exprnd(1/lambda);
        while FrameArrivalTime<T
            number_of_arrived_frames = number_of_arrived_frames+1;
            FrameArrivalTimes(number_of_arrived_frames) = FrameArrivalTime;
            FrameArrivalTime = FrameArrivalTime + T_fr + exprnd(1/lambda);
        end
        CurrentUserFrameArrivals = [FrameArrivalTimes(1:number_of_arrived_frames);ones(1,number_of_arrived_frames)*n];
        TotalFrameArrivalConditions2 = [TotalFrameArrivalConditions2,CurrentUserFrameArrivals];
    end

    % 统计仿真时长T内总的成功发送的帧的数量并计算归一化吞吐速率
        % 先所有用户的帧到达时刻按从先到后排序
    [~,SortedIdxs1] = sort(TotalFrameArrivalConditions1(1,:));
    TotalFrameArrivalConditions1 = TotalFrameArrivalConditions1(:,SortedIdxs1);
    [~,SortedIdxs2] = sort(TotalFrameArrivalConditions2(1,:));
    TotalFrameArrivalConditions2 = TotalFrameArrivalConditions2(:,SortedIdxs2);

        % 送入函数SuccessFrameNumCalcu统计成功传输帧的数量并计算归一化吞吐速率 (这里计算的是所有用户总的归一化吞吐速率，同学们也可观察每一个用户的情况)
    rho_simu1(lambdaCounter) = sum(SuccessFrameNumCalcu(TotalFrameArrivalConditions1,T_fr,N))/T*T_fr;
    rho_simu2(lambdaCounter) = sum(SuccessFrameNumCalcu(TotalFrameArrivalConditions2,T_fr,N))/T*T_fr;
end
toc

figure
G_s = 0:0.01:N*lambdas(end)*T_fr;
plot(G_s,G_s.*exp(-2*G_s),'DisplayName','纯Aloha理论值')
hold on
plot(N*lambdas*T_fr,rho_simu1,'+','DisplayName','纯Aloha仿真值')
hold on
plot(N*lambdas*T_fr,rho_simu2,'*','DisplayName','纯Aloha仿真值-用户自己帧碰撞避免(到达率校正前)')
hold on
plot(N*(lambdas./(1+lambdas*T_fr))*T_fr,rho_simu2,'hexagram','DisplayName','纯Aloha仿真值-用户自己帧碰撞避免(到达率校正后)')
legend
grid on
title(['N = ', num2str(N)])
xlabel('G')
ylabel('\rho')

function SuccessFrameNum_Users = SuccessFrameNumCalcu(TotalFrameArrivalConditions,T_fr,N)
    % 输入：TotalFrameArrivalConditions: 矩阵, 两行, 第一行-所有用户的帧到达时刻(按照从先到后顺序),
    % 第二行-帧所属用户编号; T_fr: 标量, 无碰撞时一帧的发送耗时; N: 标量, 用户总数
    % 输出：SuccessFrameNum_Users: 矢量, 每个用户成功传输(不与别的帧碰撞)的帧的数量
    % 函数功能：在帧到达即发送的情况下，统计每个用户能成功传输的帧的数量

    TotalFrameArrivalTimes = TotalFrameArrivalConditions(1,:);
    TotalFrameArrivalNum = length(TotalFrameArrivalTimes);
    TransmissionConditions = zeros(1,TotalFrameArrivalNum);%标记某一帧能否传输成功
    if TotalFrameArrivalTimes(2) > TotalFrameArrivalTimes(1)+T_fr
        TransmissionConditions(1) = 1;
    end
    for i = 2 : TotalFrameArrivalNum-1
        if (TotalFrameArrivalTimes(i)>TotalFrameArrivalTimes(i-1)+T_fr) && ...
                (TotalFrameArrivalTimes(i)<TotalFrameArrivalTimes(i+1)-T_fr)
            TransmissionConditions(i) = 1;
        end
    end
    if TotalFrameArrivalTimes(TotalFrameArrivalNum) > TotalFrameArrivalTimes(TotalFrameArrivalNum-1)+T_fr
        TransmissionConditions(TotalFrameArrivalNum) = 1;
    end
    
    TotalFrameOwners = TotalFrameArrivalConditions(2,:);
    SuccessFrameNum_Users = zeros(1,N);
    for n = 1:N
        SuccessFrameNum_Users(n) = nnz(TotalFrameOwners(logical(TransmissionConditions))==n);
    end

end