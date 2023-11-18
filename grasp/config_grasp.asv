% config file

global raw_dir processing_dir meta_dir root_dir electrode_dir;
[ret, name] = system('hostname');
if strcmp(strip(name),'LongsMac')
    raw_dir=strcat(raw_dir,'gesture/Raw_Data_All/');
    processing_dir=strcat(processing_dir,'gesture/preprocessing/');
    meta_dir=strcat(meta_dir,'gesture/');
    project_dir =strcat(root_dir, 'gesture/');  % this is project root on google drive
    electrode_dir=strcat(meta_dir, 'EleCTX_Files/');
    info_dir = strcat(meta_dir,'info/');  % sub info
    result_dir=strcat(project_dir,'result/');
elseif strcmp(strip(name),'workstation')
    raw_dir=strcat(raw_dir,'gesture/Raw_Data_All/');
    processing_dir=strcat(processing_dir,'gesture/preprocessing/');
    meta_dir=strcat(meta_dir,'gesture/');
    project_dir = strcat(root_dir,'gesture/');  % this is project root on google drive
    electrode_dir=strcat(meta_dir, 'EleCTX_Files/');
    info_dir = strcat(meta_dir,'info/');  % sub info
    result_dir=strcat(project_dir,'result/');
elseif strcmp(strip(name),'DESKTOP-NP9A9VI')
    raw_dir=strcat(raw_dir,'grasp/');
    processing_dir=strcat(processing_dir,'grasp/preprocessing/');
    meta_dir=strcat(meta_dir,'grasp/');
    project_dir = strcat(root_dir,'grasp/');  % this is project root on google drive
    electrode_dir=strcat(meta_dir, 'EleCTX_Files/');
    info_dir = strcat(meta_dir,'info/');  % sub info
    result_dir=strcat(project_dir,'result/');
end