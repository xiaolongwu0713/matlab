%% config
config_all;
config_gesture;

%%
sid=17;
key=strcat('sid',num2str(sid));
channel_index_from_python=29; % add 1 to it

%%  load good channels
load(strcat(meta_dir,'good_channels.mat'))
tmp=good_channels;
clear good_channels;

% make sid as the key of the good_channels structure
info=strcat(info_dir,'info.txt');
M = readmatrix(info);
for index = [1:length(M)]
    sid_name=fieldnames(tmp{1,index});
    sid_name=sid_name{1,1};
    good_channels.(sid_name)=tmp{1,index}.(sid_name);
end

%%
electrode_file=strcat(electrode_dir,'P',num2str(sid),'/electrodes_Final_Norm.mat'); % input electrode file folder here
load(electrode_file);
Etala.(key).electrodes=cell2mat(elec_Info_Final_wm.norm_pos');
Etala.(key).ana_names=string(elec_Info_Final_wm.ana_label_name);


%%
selected_goodChn.(key)=good_channels.(key)(channel_index_from_python);
reg=strcat(electrode_dir,'P',num2str(sid),'/SignalChanel_Electrode_Registration.mat');
reg=load(reg);
ele_index_gumbel.(key)=find(reg.CHN==selected_goodChn.(key));

% anatomy name:
Etala.(key).ana_names(ele_index_gumbel.(key))
