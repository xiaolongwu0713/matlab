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
    raw_dir=strcat(raw_dir,'gesture/Raw_Data_All/');
    processing_dir=strcat(processing_dir,'gesture/preprocessing/');
    meta_dir=strcat(meta_dir,'gesture/');
    project_dir = strcat(root_dir,'gesture/');  % this is project root on google drive
    electrode_dir=strcat(meta_dir, 'EleCTX_Files/');
    info_dir = strcat(meta_dir,'info/');  % sub info
    result_dir=strcat(project_dir,'result/');
end
%good_subjects=[4 10 13 29 41];
good_sids=[2 3 4 10 13 17 18 29 32 41];
good_sids_file=strcat(meta_dir,'good_sids.txt');
final_good_sids_file=strcat(meta_dir,'final_good_sids.txt');