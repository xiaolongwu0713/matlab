global raw_dir processing_dir meta_dir root_dir electrode_dir;
config_all;
[ret, name] = system('hostname');
if strcmp(strip(name),'LongsMac')
    raw_dir=strcat(raw_dir,'HS_MI/Raw_Data_All/');
    processing_dir=strcat(processing_dir,'HS_MI/preprocessing/');
    meta_dir=strcat(meta_dir,'HS_MI/');
    root_dir =strcat(root_dir, 'HS_MI/');  % this is project root on google drive
    electrode_dir=strcat(meta_dir, 'EleCTX_Files/');
    info_dir = strcat(meta_dir,'info/');  % sub info
elseif strcmp(strip(name),'workstation')
    raw_dir=strcat(raw_dir,'HS_MI/Raw_Data_All/');
    processing_dir=strcat(processing_dir,'HS_MI/preprocessing/');
    meta_dir=strcat(meta_dir,'HS_MI/');
    root_dir = strcat(root_dir,'HS_MI/');  % this is project root on google drive
    electrode_dir=strcat(meta_dir, 'EleCTX_Files/');
    info_dir = strcat(meta_dir,'info/');  % sub info
elseif strcmp(strip(name),'DESKTOP-NP9A9VI')
    raw_dir=strcat(raw_dir,'HS_MI/Raw_Data_All/');
    processing_dir=strcat(processing_dir,'HS_MI/preprocessing/');
    meta_dir=strcat(meta_dir,'HS_MI/');
    root_dir = strcat(root_dir,'HS_MI/');  % this is project root on google drive
    electrode_dir=strcat(meta_dir, 'EleCTX_Files/');
    info_dir = strcat(meta_dir,'info/');  % sub info
end