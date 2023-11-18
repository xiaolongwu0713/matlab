%------------ FreeSurfer -----------------------------%
% why add FS to matlab???
fshome = getenv('FREESURFER_HOME');
fsmatlab = sprintf('%s/matlab',fshome);
if (exist(fsmatlab) == 7)
    %addpath(genpath(fsmatlab));
end
clear fshome fsmatlab;
%-----------------------------------------------------%

%------------ FreeSurfer FAST ------------------------%
fsfasthome = getenv('FSFAST_HOME');
fsfasttoolbox = sprintf('%s/toolbox',fsfasthome);
if (exist(fsfasttoolbox) == 7)
    path(path,fsfasttoolbox);
end
clear fsfasthome fsfasttoolbox;

%% path for plotting, not the original iEEGview functions
matlab_common='./common';
if (exist(matlab_common) == 7)
    addpath(genpath(matlab_common));
    savepath;
end
clear matlab_common;

nicebrain_path='./plot_brain/nicebrain';
if (exist(nicebrain_path) == 7)
    addpath(genpath(nicebrain_path));
    savepath;
end
clear nicebrain_path;


%% field_trip path setup

% https://www.fieldtriptoolbox.org/faq/should_i_add_fieldtrip_with_all_subdirectories_to_my_matlab_path/
[ret, name] = system('hostname');
if strcmp(strip(name),'DESKTOP-NP9A9VI')
    plugin_dir='C:/Users/xiaol/matlab/';
    fieldtrip_dir=strcat(plugin_dir,'fieldtrip');
    if (exist(fieldtrip_dir) == 7)
        addpath(fieldtrip_dir);
        ft_defaults;
    end
    
    cd C:/Psychtoolbox/;
    SetupPsychtoolbox; % open it when you need psychtoolbox
    cd C:/Users/xiaol/mydrive/matlab;
end

%% psychtoolbox
% addpath('C:\Psychtoolbox'); % not working
PsychStartup %this works; This script should be called automatically everytime Matlab start;
