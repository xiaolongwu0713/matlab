%%
% Function: Electrode locations projected on the three-dimensional standard Montreal Neurological Institute brain model. 
%           Show brain model and implanted contacts (small red dots) in the sagittal, coronal, and transverse view respectively. 
%
%
clear;clc;
cd 'H:\lsj\preprocessing_data\refMeths_Result';

load 'D:\lsj\EleCTX_Files_2018_10_26\Standard Brain\Norm_Brain' cortex

Inf = [2, 1000; 3, 1000; 4, 1000; 5, 1000; 7, 1000; 8, 1000; 9, 1000; 10, 2000; % 11, 500; 12, 500;
       13, 2000;  16, 2000; 17, 2000; 18, 2000; 19, 2000; 20, 1000; 21, 1000; 22, 2000; 23, 2000; % 14, 2000;
        29, 2000; 30, 2000; 31, 2000; 32, 2000; 34, 2000; 35, 1000; % 28, 2000; 33,    24, 2000; 25, 2000; 26, 2000; 
       36, 2000; 37, 2000; 41,2000;
       ];
goodsubj = [1,2,3,8,9,12,18,26];
Inf = Inf(goodsubj,:);
for t = 1%1:3
%for i = 1 
for i=1:size(Inf, 1)
    pn = Inf(i, 1);
% Localization of Electrodes’ 3D Coordinates.
%     addpath(genpath([cd,'\nicebrain']));
    Electrode_Registration_Folder=strcat('D:\lsj\EleCTX_Files_2018_10_26\P',num2str(pn),'\SignalChanel_Electrode_Registration.mat'); % input electrode file folder here
    load(Electrode_Registration_Folder);

    
    Electrode_Folder=strcat('D:\lsj\EleCTX_Files_2018_10_26\P',num2str(pn),'\electrodes_Final_Anatomy_wm_All.mat'); % input electrode file folder here
    %     Brain_Model_Folder=strcat('D:\lsj\EleCTX_Files_2018_10_26\P',num2str(pn),'\WholeCortex.mat');% input brain cortex file folder here
    load(Electrode_Folder);
    %     load(Brain_Model_Folder);
    
    
    strname = strcat('D:/lsj/preprocessing_data/P',num2str(pn),'/preprocessing3/preprocessingALL_3_0.5_v3_Local_optimal.mat');
    load(strname, 'opti_chn_set');
    strname = strcat('D:/lsj/preprocessing_data/P',num2str(pn),'/preprocessing1/preprocessingALL_1.mat');
    load(strname, 'good_channels');
    Etala.trielectrodes=cell2mat(elec_Info_Final_wm.norm_pos');
    
    opti_chn_set = good_channels(opti_chn_set);
    good_channels = CHN(good_channels);
    opti_chn_set = CHN(opti_chn_set);
    good_channels_setdiff = setdiff(good_channels, opti_chn_set);
    Etala.trielectrodes_good_channels_setdiff = Etala.trielectrodes(good_channels_setdiff,:);
    Etala.trielectrodes_optimal = Etala.trielectrodes(opti_chn_set,:);
    % view_vect = input('What side of the brain do you want to view? ("front"|"top"|"lateral"|"isometric"|"right"|"left"): ');
    switch t
        case 1;view_vect = 'left';
        case 2;view_vect = 'front';
        case 3;view_vect = 'top';
    end
    figure(t);
    if i == 1;transp = 0.3;colix = 32;else;transp = 0.3;colix = 32;end
    viewBrain(cortex, Etala, {'brain','trielectrodes'}, transp, colix, view_vect,i,opti_chn_set);
    axis off;
    colorbar off
    set(0,'defaultfigurecolor','w') 
end
end
%cd 'H:\lsj\Documents\重要文件\小论文\小论文回复\optimal_conta_Plot'