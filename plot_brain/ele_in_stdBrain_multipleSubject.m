%%
% Function: Electrode locations projected on the three-dimensional standard Montreal Neurological Institute brain model. 
%           Show brain model and implanted contacts (small red dots) in the sagittal, coronal, and transverse view respectively. 
%
%

config_all;
config_gesture;
std_brain=strcat(meta_dir,'EleCTX_Files/Standard Brain/Norm_Brain.mat');
%load 'C:\Users\Public\BaiduNetdiskWorkspace\BCI\data\gesture\EleCTX_Files_2018_10_26\Standard Brain\Norm_Brain.mat' cortex;
cortex=load(std_brain); cortex=cortex.cortex;

Inf = [2, 1000; 3, 1000; 4, 1000; 5, 1000; 7, 1000; 8, 1000; 9, 1000; 10, 2000; % 11, 500; 12, 500;
       13, 2000;  16, 2000; 17, 2000; 18, 2000; 19, 2000; 20, 1000; 21, 1000; 22, 2000; 23, 2000; % 14, 2000;
        29, 2000; 30, 2000; 31, 2000; 32, 2000; 34, 2000; 35, 1000; % 28, 2000; 33,    24, 2000; 25, 2000; 26, 2000; 
       36, 2000; 37, 2000; 41,2000;];
%goodsubj = [1,2,3,8,9,12,18,26];
%Inf = Inf(goodsubj,:);
ele_path=strcat(meta_dir,'EleCTX_Files/');
Etala=struct([]);
for i = 1:4%size(Inf, 1)
    pn = Inf(i, 1);
    Electrode_Folder=strcat(ele_path,'P',num2str(pn),'/electrodes_Final_Norm.mat'); % input electrode file folder here
    load(Electrode_Folder);
    Etala(i).electrodes=cell2mat(elec_Info_Final_wm.norm_pos');
end
for t = 2%1:3
    switch t
        case 1;view_vect = 'left';
        case 2;view_vect = 'front';
        case 3;view_vect = 'top';
    end

    %strname = strcat('D:/lsj/preprocessing_data/P',num2str(pn),'/preprocessing3/preprocessingALL_3_0.5_v3_Local_optimal.mat');
    %load(strname, 'opti_chn_set');
    %strname = strcat('D:/lsj/preprocessing_data/P',num2str(pn),'/preprocessing1/preprocessingALL_1.mat');
    %load(strname, 'good_channels');
    %opti_chn_set = good_channels(opti_chn_set);
    %good_channels = CHN(good_channels);
    %opti_chn_set = CHN(opti_chn_set);
    %good_channels_setdiff = setdiff(good_channels, opti_chn_set);
    %Etala.trielectrodes_good_channels_setdiff = Etala.trielectrodes(good_channels_setdiff,:);
    %Etala.trielectrodes_optimal = Etala.trielectrodes(opti_chn_set,:);
    % view_vect = input('What side of the brain do you want to view? ("front"|"top"|"lateral"|"isometric"|"right"|"left"): ');

    figure(t);
    transp = 0.1;colix = 32; % brighter with smaller transp 
    viewBrain(cortex, Etala, {'brain','electrodes'}, transp, colix, view_vect);
    

    axis off;
    colorbar off
    set(0,'defaultfigurecolor','w')
    hold on;
    
end
