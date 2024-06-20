% 03计算功能连接矩阵网络参数
% Author: ZhGf
% Time: 2024.05.10


clear;
clc;
basicSamplePath = 'E:\WorkSpace\MatlabWorkSpace\02ExerciseFatigueDataset\02EEG Project\01Male Exercise Fatigue EEG Dataset\Experimental Group Result\';
prePrefix = 'OpenEyes\Prefatigue\EveryTrial\';      % 存放疲劳前FC矩阵的文件夹
postPrefix = 'OpenEyes\Postfatigue\EveryTrial\';
sex = 'Male-C25';
type = '-PLV-';
bandPrefix = {'Delta', 'Theta', 'Alpha', 'Beta', 'Gamma', 'All'};   


%% 加载被试EEG文件
[preFCPath, subjectNum] = get_subject_fc_path(strcat(basicSamplePath, prePrefix));
[postFCPath, subjectNum] = get_subject_fc_path(strcat(basicSamplePath, postPrefix));

preNP = zeros(subjectNum, 4);  % 平均脑网络参数
postNP = zeros(subjectNum, 4);  % 平均脑网络参数

for band = bandPrefix
    band = cell2mat(band)
    excelName = strcat(sex, type, band, '-Every Trial Network Property Results.xls');
    for sub = 1:subjectNum 
        sub
        [preTrialNum, preTrialFC] = get_every_class_num(preFCPath{sub}, band);
        [postTrialNum, postTrialFC] = get_every_class_num(postFCPath{sub}, band);
        
        [preCC, preGE, preLE, preCPL] = get_network_properties(preTrialNum, preFCPath{sub}, preTrialFC, band);
        [postCC, postGE, postLE, postCPL] = get_network_properties(postTrialNum, postFCPath{sub}, postTrialFC, band);
        
        trialNum = min(preTrialNum, postTrialNum);
    
        % 向Excel写入数据
        write2excel(preCC, excelName, 'preCC'); 
        write2excel(preGE, excelName, 'preGE'); 
        write2excel(preLE, excelName, 'preLE'); 
        write2excel(preCPL, excelName, 'preCPL'); 
    
        write2excel(postCC, excelName, 'postCC'); 
        write2excel(postGE, excelName, 'postGE'); 
        write2excel(postLE, excelName, 'postLE'); 
        write2excel(postCPL, excelName, 'postCPL'); 
        
        CC1 = preCC(1, 1:trialNum);
        CC2 = postCC(1, 1:trialNum);
        GE1 = preGE(1, 1:trialNum);
        GE2 = postGE(1, 1:trialNum);
        LE1 = preLE(1, 1:trialNum);
        LE2 = postLE(1, 1:trialNum);
        CPL1 = preCPL(1, 1:trialNum);
        CPL2 = postCPL(1, 1:trialNum);
    
        preNP(sub, 1) = mean(CC1);
        preNP(sub, 2) = mean(GE1);
        preNP(sub, 3) = mean(LE1);
        preNP(sub, 4) = mean(CPL1);
    
        postNP(sub, 1) = mean(CC2);
        postNP(sub, 2) = mean(GE2);
        postNP(sub, 3) = mean(LE2);
        postNP(sub, 4) = mean(CPL2);
    end
    aveExcelName = strcat(sex, type, band, '-Mean Network Property Results.xls');
    write2excel(preNP, aveExcelName, 'preNP'); 
    write2excel(postNP, aveExcelName, 'postNP'); 
end % for band


% 计算网络属性函数
function [CC, GE, LE, CPL] = get_network_properties(trialNum, FCPath, TrialFC, band)
    CC = zeros(1, trialNum);  % 聚类系数
    GE = zeros(1, trialNum);  % 全局效率
    LE = zeros(1, trialNum);  % 局部效率
    CPL = zeros(1, trialNum); % 特征路径长度
    % 获取被试脑电文件
    for i=1:trialNum
        FCName = cell2mat(strcat(FCPath, TrialFC{i}));
        W = load(FCName);  % 加载FC矩阵
        switch(band)
            case 'Delta'
                [CC(i), GE(i), LE(i), CPL(i)] = network_property(W.Delta);
            case 'Theta'
                [CC(i), GE(i), LE(i), CPL(i)] = network_property(W.Theta);
            case 'Alpha'
                [CC(i), GE(i), LE(i), CPL(i)] = network_property(W.Alpha);
            case 'Beta'
                [CC(i), GE(i), LE(i), CPL(i)] = network_property(W.Beta);
            case 'Gamma'
                [CC(i), GE(i), LE(i), CPL(i)] = network_property(W.Gamma);
            case 'All'
                [CC(i), GE(i), LE(i), CPL(i)] = network_property(W.ALL);
        end
    end
end


% 获取每名被试的FC文件路径
function [eegFCPath, subjectNum] = get_subject_fc_path(sampleResPath)
    folders = dir(fullfile(sampleResPath, '*'));  % 查找文件夹，不包含文件
    foldersOnly = folders([folders.isdir])
    folderNum = size(foldersOnly, 1);
    subFolders = zeros(folderNum-2, 1);
    for i=3:folderNum
        fileFolder = foldersOnly(i, 1).name;  % 获取被试文件夹名字
        subFolders(i-2) = str2num(fileFolder);  % 序号字符转数字
    end
    
    subFolders = sort(subFolders);  % 将文件夹按照序号排序
    % 组成被试脑电保存文件的路径
    subjectNum = size(subFolders, 1); % 被试的人数
    eegFCPath = {};
    eegIndex = {};
    for i=1:subjectNum
        eegFCPath{end+1} = strcat(sampleResPath, num2str(subFolders(i)), '\'); % 组成被试文件夹路径
        eegIndex{end+1} = subFolders(i);
    end 
end


% 返回trial的个数和trial按照序号排序的名称
function [trialNum, trialFC] = get_every_class_num(FCPath, band)
    trialFC = {};  % 存储trial_fc_name
    bandName = strcat('*', band, '.mat');  % 组成频带的名字
    dirOutput = dir(fullfile(FCPath, bandName));  % 查找文件夹，不包含文件
    for subname = {dirOutput.name}
        subnameStr = split(subname, '_');  % 将FC文件名按照下划线切分
        seq = subnameStr{2};  % 获取trial的顺序
        trialFC{str2num(seq)} = subname;  % 按照trial的顺序存储
    end  
    trialNum = size(trialFC, 2);
end


function [CC, GE, LE, CPL] = network_property(W)
% Input: 连接矩阵
% Output: CC-聚类系数，GE-全局效率，
%         LE-局部效率，CPL-特征路径长度
    [row, col] = size(W);
    CC = clustering_coef_wu(W);  % 聚类系数
    CC = mean(CC);                  % 求平均
    
    GE = efficiency_wei(W);      % 全局效率，global efficiency (scalar)
    LE = efficiency_wei(W, 2);   % 局部效率，local efficiency (vector)
    LE = mean(LE);                  % 求平均
    
    inv_data = 1./W;    % 连接矩阵的倒数
    inv_data(1:row+1:end)=0;
    [D, B] = distance_wei(inv_data);
    [CPL,efficiency,ecc,radius,diameter] = charpath(D);   % 特征路径长度
end


function write2excel(data, excelName, sheet)
    writematrix(data, excelName, 'Sheet', sheet, 'WriteMode', 'append');    % 存储平均PSD
end

