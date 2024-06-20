%%
config_all;
config_gesture;
%% process all together
%  process pipline.

all_Info = [2, 1000; 3, 1000; 4, 1000; 5, 1000; 7, 1000; 8, 1000; 9, 1000; 10, 2000;  11, 500; 12, 500;%1,xxx;6,;
       13, 2000; 14, 2000; 16, 2000; 17, 2000; 18, 2000; 19, 2000; 20, 1000; 21, 1000; 22, 2000; %15,
	   23, 2000; 24, 2000; 25, 2000; 26, 2000; 29, 2000; 30, 2000; 31, 2000; 32, 2000; 34, 2000;%27,28,33,
       35, 1000; % 36,37,38,39,40    
	   41,2000;
       ];
allSubj=all_Info(:,1);
goodSubj = [2,3,4,10,13,17,18,29,32,41];  %P4, P10, P13,P17,P29,P32,P34,P41
good_index=ismember(all_Info(:,1),goodSubj);
badSubj=setdiff(allSubj,goodSubj);
bad_index=ismember(all_Info(:,1),badSubj);


Info = all_Info(good_index,:);
%Inf = all_Info(bad_index,:);

%% check all subject info existance
for i = 1 : size(all_Info, 1)
    pn = all_Info(i, 1);
    Fs = all_Info(i, 2);
    subInfo = get_sub_info(pn);
end
%mat2np(all_Info, strcat(info_dir,'info.npy'), 'int16')
%writematrix(Inf,strcat(info_dir,'info.txt'))
%%
plotty=1;
for i = 1 : size(Info, 1) 
    i=1;
    pn = Info(i, 1);
    Fs = Info(i, 2);
    
    % 合并 trigger 向量.
    % EMG 信号的预处理.
    % 剔除噪声通道.
     subInfo = get_sub_info(pn);
%     
    preprocessing1(pn, Fs, subInfo, plotty);
    
    % SEEG 信号预处理， 滤波, 重参考, 
    % 获得EMG 对应的trigger 对齐为切片做准备.
    
    preprocessing2(pn, 1000);
    
    % preprocess for DeepConvNet.
%     preprocessing3(pn, 1000);
    
%     pre_3_psd_v2(pn, 1000)
    
    %pre_3_psd_v3(pn)
    break;
end



%% process individually

%pn=5;
%Fs=1000;
%subInfo = config(pn);
%preprocessing1(pn, 1000, subInfo)
%preprocessing2(pn, 1000)

