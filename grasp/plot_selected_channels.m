%% config
config_all;
config_grasp;

%%  load stg selected channels
sid=1;
load(strcat(meta_dir,'selected_channels_stg_',num2str(sid),'prob0.6.mat'));
key=strcat('sid',num2str(sid));
selected_channels_stg.(key)=selected_channels_stg;


%% anatomy label analysis
ele_info=load(strcat(raw_dir,'PF',num2str(sid),'/BrainElectrodes/','electrodes_Final_Norm.mat'));
name_arrays=ele_info.elec_Info_Final_wm.ana_label_name;
name_arrays=name_arrays';
