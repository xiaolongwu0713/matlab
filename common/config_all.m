global raw_dir processing_dir meta_dir root_dir std_brain_model_dir;

[ret, name] = system('hostname');
if strcmp(strip(name),'LongsMac')
    raw_dir='/Volumes/Samsung_T5/data/';
    processing_dir='/Volumes/Samsung_T5/data/';
    meta_dir='/Users/long/mydrive/meta/';
    root_dir = '/Users/long/mydrive/matlab/';  % this is project root on google drive
    
elseif strcmp(strip(name),'workstation')
    raw_dir='H:/Long/data/';
    processing_dir='H:/Long/data/';
    meta_dir='C:/Users/wuxiaolong/mydrive/meta/';
    root_dir = 'C:/Users/wuxiaolong/mydrive/matlab/';
elseif strcmp(strip(name),'DESKTOP-NP9A9VI')
    raw_dir='H:/Long/data/';
    processing_dir='H:/Long/data/';
    meta_dir='C:/Users/xiaol/mydrive/meta/';
    root_dir = 'C:/Users/xiaol/mydrive/matlab/';  % this is project root on google drive
end
std_brain_model_dir=strcat(root_dir,'common/StdbrainModel/');