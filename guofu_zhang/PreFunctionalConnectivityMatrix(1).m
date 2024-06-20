% 02计算功能连接矩阵
% 从后往前计算
% Author: ZhGf
% Time: 2024.05.03

clear;
clc;
samplePath = 'E:\WorkSpace\MatlabWorkSpace\02ExerciseFatigueDataset\02EEG Project\01Male Exercise Fatigue EEG Dataset\01Experimental Group\';
resultSavePath = 'E:\WorkSpace\MatlabWorkSpace\02ExerciseFatigueDataset\02EEG Project\01Male Exercise Fatigue EEG Dataset\Experimental Group Result\OpenEyes\';
eegSuffix = 'Male preFatigue OpenEyes Resting State.set';  % EEG文件后缀名
state = 'OpenEyes';
prefix = 'Prefatigue';  % 前缀
kind = 'pre';  
channels = 28;   % 电极通道数


%% 加载被试数据文件名
[eegPath, subjectNum, eegSetName] = get_subject_set_path(samplePath, state, eegSuffix);


%% 计算脑网络参数
type_fcmetric = {'PLI', 'PLV', 'correlation', 'iCOH'};
% for type = {'iCOH'}
% for type = {'COH'}
for type = {'PLV'}
% for type = {'correlation'}
% for type = {'PLI'}
    switch(cell2mat(type))
        case'COH'
            metric = 7;
        case 'MSC'
            metric = 6;
        case 'PLI'
            metric = 5;
        case 'PLV'
            metric = 4;
        case 'correlation'
            metric = 3;
        case 'iCOH'
            metric = 2;
        case 'mutualinf'
            metric = 1;
    end

    Delta_Ave = zeros(channels, channels);
    Theta_Ave = zeros(channels, channels);
    Alpha_Ave = zeros(channels, channels);
    Beta_Ave = zeros(channels, channels);
    Gamma_Ave = zeros(channels, channels);
    ALL_Ave = zeros(channels, channels);
    
    bands = {'Delta','Theta', 'Alpha', 'Beta', 'Gamma', 'ALL'};
    fre_band = struct('metric', metric, 'auto_cmpl',0, ...
                      'frb1',{'[1 4]'},'frb1_name',{'Delta'}, 'frb2',{'[4 8]'},'frb2_name',{'Theta'},...
                      'frb3',{'[8 13]'},'frb3_name',{'Alpha'},  'frb4',{'[13 30]'},'frb4_name',{'Beta'}, ...
                      'frb5',{'[30 45]'},'frb5_name',{'Gamma'}, 'frb6',{'[1 45]'},'frb6_name',{'All Spectrum'}, ...
                      'frb7',{''},'frb7_name',{''}, 'frb8',{''},'frb8_name',{''}, 'frb9',{''},'frb9_name',{''});
    
    maxTRange = zeros(subjectNum, 1);
    for sub = 1:subjectNum % 遍历被试
        EEG = pop_loadset('filename', eegSetName{sub}, 'filepath', eegPath{sub});  % 加载数据
        EEG.event = [];  % 清除原始的标签
       
        saveEachSubFolder = strcat(resultSavePath, prefix, '\EveryTrial\'+ string(sub), '\' );
        if ~exist(saveEachSubFolder, 'dir')  % 如果文件夹不存在，则创建文件夹
            mkdir(saveEachSubFolder); 
        end

        if channels == 28
            % 选择通道, 28通道
            EEG = pop_select( EEG, 'channel',{'C3','C4','CP1','CP2','CP5','CP6','F3','F4','F7','F8','Fz', ...
                'FC1','FC2','FC5','FC6','Fp1','Fp2','O1','O2','Oz','P3','P4','P7','P8','Pz','T7','T8','Cz'});
        elseif channels == 25
            % 选择通道, 25通道
            EEG = pop_select( EEG, 'channel',{'C3','C4','CP1','CP2','CP5','CP6','F3','F4','F7','F8','Fz', ...
                'FC1','FC2','FC5','FC6','Fp1','Fp2','P3','P4','P7','P8','Pz','T7','T8','Cz'});
        elseif channels == 20
            EEG = pop_select( EEG, 'channel',{'C3','C4','F3','F4','F7','F8','Fz','Fp1','Fp2', ...
                'O1','O2','Oz','P3','P4','P7','P8','Pz','T7','T8','Cz'});
        end
   
        xmax = floor(EEG.xmax);
        xmin = EEG.xmin;
        EEG = pop_select( EEG, 'time', [xmin, xmax]); 

        % Convert a continuous dataset into consecutive epochs of a specified regular length
        EEG = eeg_regepochs(EEG, 'recurrence',  4, 'limits', [0, 4], 'rmbase', NaN); 

        EEG2 = EEG;
        eeg_data = EEG2.data;
        % 获取每位被试的平均FC
        for i=1:EEG.trials   % 每个trial计算一个连接矩阵
            EEG2.data = eeg_data(:,:,i);
            [EEG2, com] = pop_fclab_myself(EEG2, fre_band);
            switch(cell2mat(type))
                case 'PLI'
                    fc = EEG2.FC.PLI;
                case 'PLV'
                    fc = EEG2.FC.PLV;
                case 'correlation'
                    fc = EEG2.FC.correlation;   
                case 'iCOH'
                    fc = EEG2.FC.iCOH;
                case 'COH'
                    fc = EEG2.FC.COH;
            end
    
            Delta = fc.Delta.adj_matrix;
            Theta = fc.Theta.adj_matrix;
            Alpha = fc.Alpha.adj_matrix;
            Beta = fc.Beta.adj_matrix;
            Gamma = fc.Gamma.adj_matrix;
            ALL = fc.All_Spectrum.adj_matrix;
        
            for band = bands
                for r = 1:channels
                    switch(cell2mat(band))
                        case 'Delta'  
                            Delta(r, r)=0;
                        case 'Theta'  
                            Theta(r, r)=0;
                        case 'Alpha'  
                            Alpha(r, r)=0;
                        case 'Beta'  
                            Beta(r, r)=0;
                        case 'Gamma'  
                            Gamma(r, r)=0;
                        case 'ALL'  
                            ALL(r, r)=0;
                     end
                end
            end
            
            % 保存每个trial的FC
            save(cell2mat(strcat(saveEachSubFolder,string(sub),'_',int2str(i),'_',kind,'_',type,'_Delta.mat')), 'Delta');
            save(cell2mat(strcat(saveEachSubFolder,string(sub),'_',int2str(i),'_',kind,'_',type,'_Theta.mat')), 'Theta');
            save(cell2mat(strcat(saveEachSubFolder,string(sub),'_',int2str(i),'_',kind,'_',type,'_Alpha.mat')), 'Alpha');
            save(cell2mat(strcat(saveEachSubFolder,string(sub),'_',int2str(i),'_',kind,'_',type,'_Beta.mat')), 'Beta');
            save(cell2mat(strcat(saveEachSubFolder,string(sub),'_',int2str(i),'_',kind,'_',type,'_Gamma.mat')), 'Gamma');
            save(cell2mat(strcat(saveEachSubFolder,string(sub),'_',int2str(i),'_',kind,'_',type,'_ALL.mat')), 'ALL');
        end  % for i=1:trials

    end % for sub=1:subejctNum
end
%}


% 加载被试数据文件名和路径
function [eegPath, subjectNum, eegSetName] = get_subject_set_path(samplePath, state, eegSuffix)
    % 获取每名被试的文件夹编号
    folders = dir(fullfile(samplePath, '*'));  % 查找文件夹，不包含文件
    foldersOnly = folders([folders.isdir])
    folderNum = size(foldersOnly);
    subjectFolders = {};
    for i=3:folderNum(1)
        fileFolder = foldersOnly(i, 1).name;  % 获取被试文件夹名字
        subjectFolders{end+1} = fileFolder;
    end
    
    % 组成被试脑电保存文件的路径
    subjectNum = size(subjectFolders); % 被试的人数
    subjectNum = subjectNum(2);
    eegPath = {};
    eegIndex = {};
    for i=1:subjectNum
        eegPath{end+1} = strcat(samplePath, subjectFolders{i}, '\', state, '\'); % 组成被试文件夹路径
        eegIndex{end+1} = subjectFolders{i};
    end 
    
    % 获取被试脑电文件
    eegSetName = {};  % 存放EEG文件绝对路径
    for i=1:subjectNum
        setData = dir(fullfile(eegPath{i}, "*"+eegSuffix));
        eegSetName{end+1} = setData.name;
    end
end


