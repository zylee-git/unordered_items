%% 调试交织函数 interleaver 和解交织函数 deinterleaver
clear;
clc;
close all;

% 产生一个 [1,2,3,...,35] 的整数序列，使用 5 行 7 列的交织块
row=5;
column=7;
nums1=1:row*column;
interleaved1=interleaver(row,column,nums1);
deinterleaved1=deinterleaver(row,column,interleaved1);
fprintf("交织前序列: ")
show(nums1)
fprintf("交织后序列: ")
show(interleaved1)
fprintf("解交织后序列: ")
show(deinterleaved1)

% 序列换成长度为 35 的全零序列，并使交织后的序列经过一个信道传输
nums_e=zeros(1,35);
interleaved_e=interleaver(row,column,nums_e);
interleaved_e1=burst_error(interleaved_e,row);
deinterleaved_e1=deinterleaver(row,column,interleaved_e1);
fprintf("解交织后序列: ")
show(deinterleaved_e1)

% 令 L 为交织块行数的 2 倍
interleaved_e2=burst_error(interleaved_e,2*row);
deinterleaved_e2=deinterleaver(row,column,interleaved_e2);
fprintf("解交织后序列: ")
show(deinterleaved_e2)