%% init

freesurfer_directory='/Applications/';
subject_name='iEEGview_demo_essential';
subjectDirectory='/Users/long/Documents/BaiduNetdiskWorkspace/BCI/data/iEEGview_demo_essential/';
surfaces_directory=strcat(subjectDirectory,'Segmentation/surf/');
volume_path=strcat(subjectDirectory,'Segmentation/mri/orig.mgz');
electrodesDirectory = strcat(subjectDirectory, 'Electrodes/');


electrodes_path=strcat(electrodesDirectory,'electrode_raw.mat');
%volume_path='/Users/long/Documents/BCI/matlab/iEEGview_demo1/Segmentation/mri/orig.mgz';

handles.CalculationFlag=0;
handles.CalculationFlag_Activation=0;
handles.CalculationFlag_Activation_std=0;
handles.KernelType_lasttime=[1,10,15,0];
handles.specspec=[];
handles.ProcessState=4;
handles.ElectrodeIndex=1;
handles.ElectrodeType=1;
shaftpara.ContactLength=2;
shaftpara.InterContactDistance=3.5;
shaftpara.Diameter=0.8;
handles.ElectrodeLength=shaftpara;

handles.ConfigurationPath.subject_directory=subjectDirectory;
%handles.ConfigurationPath.iEEGview_directory='/Users/long/Documents/BCI/matlab_plugin/iEEGview';
handles.ConfigurationPath.freesurfer_directory=freesurfer_directory;
handles.ConfigurationPath.subject_name=subject_name;
handles.ConfigurationPath.DICOM_directory=strcat(subjectDirectory,'/DICOM');
handles.ConfigurationPath.electrodes_path=electrodes_path;
handles.ConfigurationPath.surfaces_directory=surfaces_directory;
handles.ConfigurationPath.volume_path=volume_path;
handles.ConfigurationPath.root_path='/Users/long/Documents/BaiduNetdiskWorkspace/BCI/code/matlab/iEEGview_essential/';

%% segmentation

%% coregister
% assembles path to dicoms
mriDICOMpath = strcat(subjectDirectory, '/DICOM/MRI/');
ctDICOMpath = strcat(subjectDirectory, '/DICOM/CT/');

% gets all dicom files from dicom folder
mriDICOMfiles = dir(strcat(mriDICOMpath, '/*.dcm'));
ctDICOMfiles = dir(strcat(ctDICOMpath, '/*.dcm'));

mriDICOMfilenames = {mriDICOMfiles.name}';
ctDICOMfilenames = {ctDICOMfiles.name}';

firstMRIdicom = mriDICOMfilenames(1);
firstMRIdicom = firstMRIdicom{1};

mriDICOMheaders = spm_dicom_headers(char(strcat(mriDICOMpath, mriDICOMfilenames)));
mriNIfTI = spm_dicom_convert(mriDICOMheaders,'all','flat','img');
ctDICOMheaders = spm_dicom_headers(char(strcat(ctDICOMpath, ctDICOMfilenames)));
ctNIfTI = spm_dicom_convert(ctDICOMheaders,'all','flat','img');

% make file names of nifti files into char
mriNIfTIfiles = char(mriNIfTI.files);
ctNIfTIfiles = char(ctNIfTI.files);

% remove extension, add each one later
mriNIfTIfiles = mriNIfTIfiles(1:(end - 4));
ctNIfTIfiles = ctNIfTIfiles(1:(end - 4));

mriPath = strcat(subjectDirectory, '/NIfTI/MRI/');
ctPath = strcat(subjectDirectory, '/NIfTI/CT/');
mkdir(mriPath);
mkdir(ctPath);
movefile(strcat(mriNIfTIfiles, '.img'), mriPath);
movefile(strcat(mriNIfTIfiles, '.hdr'), mriPath);
movefile(strcat(ctNIfTIfiles, '.img'), ctPath);
movefile(strcat(ctNIfTIfiles, '.hdr'), ctPath);

[~, mrifilename] = fileparts(mriNIfTIfiles);
[~, ctfilename] = fileparts(ctNIfTIfiles);
mriIMG = strcat(subjectDirectory, '/NIfTI/MRI/', mrifilename, '.img');
ctIMG = strcat(subjectDirectory, '/NIfTI/CT/', ctfilename, '.img');

% generate handles for mri and ct nifti images
mrihandle = spm_vol(mriIMG);
cthandle = spm_vol(ctIMG);
job.ref = mrihandle;
job.source = cthandle;
job.eoptions.cost_fun = 'nmi'; % 'nmi' - Normalised Mutual Information
job.eoptions.sep = [4 2];
job.eoptions.fwhm = [7 7];
job.eoptions.tol = [0.02, 0.02, 0.02, 0.001, 0.001, 0.001, 0.01, 0.01, 0.01, 0.001, 0.001, 0.001];
job.roptions.mask = 0;
job.roptions.interp = 1;
job.roptions.wrap = 1;
job.roptions.prefix = 'r';
job.other = {};

x = spm_coreg(job.ref, job.source, job.eoptions); % 1min. co-register the CT .img and MRI .img file.

M = spm_matrix(x);
PO = job.source;
MM = zeros(4,4,numel(PO));
MM(:,:,1) = spm_get_space(PO.fname);
spm_get_space(PO.fname, M\MM(:,:,1));

P  = {job.ref.fname; job.source.fname};

spm_reslice(P); % create [rs/means]xxxxx[.hdr/.img] under both MRI and CT folders. Only CT/rsxxx.[hdr/img] will be used next.

out.cfiles = PO;
out.M      = M;
out.rfiles = cell(size(out.cfiles));
[pth,nam,ext,num] = spm_fileparts(out.cfiles.fname);
out.rfiles{1} = fullfile(pth,[job.roptions.prefix, nam, ext, num]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% end spm code %%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% extract isosurface 
% creates directory for electrodes

if ~exist(electrodesDirectory, 'dir') % if ~exist('electrodesDirectory', 'dir')
    mkdir(electrodesDirectory);
end

shellcommand='/Users/long/Documents/BCI/matlab_plugin/iEEGview/iEEGview/viewMRIandCT.sh /Applications /Users/long/Documents/BCI/matlab_scripts/iEEGview_demo_essential&';
system(shellcommand)

%% manual pick electrode
electrodesvtk = dir(strcat(electrodesDirectory, '/*.vtk'));
electrodesSurf = importisosurface(strcat(electrodesDirectory, '/', electrodesvtk.name));
trisurf(electrodesSurf.triangles, electrodesSurf.vertices(:,1), electrodesSurf.vertices(:,2), electrodesSurf.vertices(:,3));
fig = gcf;
datacursormode on;
dcm_obj = datacursormode(fig);
[elecMatrix,elecInfo] = sortelec(dcm_obj);
save(strcat(electrodesDirectory, '/', 'electrode_raw.mat'), 'elecInfo','elecMatrix');
close(fig)
%% electrode recon
clear all
load(strcat(electrodesDirectory, '/', 'electrode_raw.mat'));
ElectrodeIndex=1; % seeg|ecog|seeg+ecog
tmpmsg = ['Please input the electrode number of each pin (eg,16,10,10..., the numbers should be in the same order with the sequence of pin names). ','The sequence of pins is ( ' elec_Info.name{:} ' )'];
switch ElectrodeIndex
    case 1 
        elec_Info.name=unique(elecInfo.name,'stable');
        tmpanswer = inputdlg(tmpmsg,'Electrode number');
        eval(['elec_Info.number = {' tmpanswer{1} '};']);
        [ElectrodeType,ElectrodeLength] = SelectElectrodeType_GUI(elec_Info.name);
        save([subjectDirectory,'/Electrodes/electrode_raw.mat'],'elecMatrix','elecInfo','elec_Info');
        save([subjectDirectory,'/Electrodes/electrodeType.mat'],'ElectrodeType','ElectrodeLength');
    case 2
        ElectrodeType = 0;
        ElectrodeLength = 0;
        save([subjectDirectory,'/Electrodes/electrode_raw.mat'],'elecMatrix','elecInfo');
        save([subjectDirectory,'/Electrodes/electrodeType.mat'],'ElectrodeType','ElectrodeLength');
        
    case 3
        elec_Info.name=unique(elecInfo.name(1:elecInfo.seeg_points),'stable');
        tmpanswer = inputdlg(tmpmsg,'Electrode number');
        eval(['elec_Info.number = {' tmpanswer{1} '};']);
        [ElectrodeType,ElectrodeLength] = SelectElectrodeType_GUI(elec_Info.name);
        save([subjectDirectory,'/Electrodes/electrode_raw.mat'],'elecMatrix','elecInfo','elec_Info');
        save([subjectDirectory,'/Electrodes/electrodeType.mat'],'ElectrodeType','ElectrodeLength');
end


handles = plotusingmatlab(subjectDirectory, subject_name,surfaces_directory, freesurfer_directory,volume_path,[], electrodes_path,handles,1);

%% anatomy localization
clear all
load([handles.ConfigurationPath.subject_directory '/Electrodes/electrodes_Final.mat']);
[cpm,ok] = listdlg('ListString',{'desikan_killiany.gcs','destrieux.simple.2009-07-28.gcs','DKTatas40.gcs'},...
    'Name','Select a cortical parcellation method',...
    'OKString','OK','CancelString','Cancel',...
    'SelectionMode','single','ListSize',[180,80]);

handles.cpm = cpm;
save([handles.ConfigurationPath.subject_directory '/Electrodes/AnatomyMethod.mat'],'cpm','-v7.3');
switch cpm
    case 1
        handles.spec = 1:36;
    case 2
        handles.spec = 1:72;
    case 3
        handles.spec = 1:36;
end
fprintf('Anatomy model calculating...');
Get_3D_Cortex_Center_v3(handles.ConfigurationPath.subject_directory);
Plot_In_RAS_WM_v2(handles.ConfigurationPath,cpm,handles.ElectrodeIndex,handles);
fprintf('AnatomyModel completed!');

%% 
ShowingIn3D_GUI(handles);

%% to std brain
handles.MultiSubFlag=1; %1:single, 2:multiple
toStandardBrain;

%% plot activation in standard brain
tmp = load('~/BCI/matlab_scripts/iEEGview_demo_essential/activationData.mat');
handles.ActivationData = tmp.activations;
handles.checkbox_DP_Activation=1;
tmpdata = load([handles.ConfigurationPath.subject_directory,'/Electrodes/electrodeType.mat']);
handles.ElectrodeType = tmpdata.ElectrodeType;
handles.ElectrodeLength = tmpdata.ElectrodeLength;
DisplayOptiomString='Electrode localization';
handles.popupmenu_Sub=1; %1:single subject, 2: multiple subject
activation_std;

%% plot electrode in standard brain
DisplayOptiomString='Standard';
switch DisplayOptiomString
    case 'Standard'
        [cpm,ok] = listdlg('ListString',{'desikan_killiany.gcs','destrieux.simple.2009-07-28.gcs','DKTatas40.gcs'},...
            'Name','Select a cortical parcellation method',...
            'OKString','OK','CancelString','Cancel',...
            'SelectionMode','single','ListSize',[180,80]);
        if ~ok
            cpm = 1; % default is desikan_killiany
        end
        switch cpm
            case 1
                handles.spec = 1:36;
                %set(handles.edit_ColorfulCortexSpec,'string','1:36');
            case 2
                handles.spec = 1:72;
                %set(handles.edit_ColorfulCortexSpec,'string','1:76');
            case 3
                handles.spec = 1:36;
                %set(handles.edit_ColorfulCortexSpec,'string','1:36');
        end
        handles.cpmstd = cpm;
    otherwise
end
handles.spec=1:3; % ROI with color
tmpdata = load([handles.ConfigurationPath.subject_directory,'/Electrodes/electrodeType.mat']);
handles.ElectrodeType = tmpdata.ElectrodeType;
handles.ElectrodeLength = tmpdata.ElectrodeLength;
plot_electrode_std;






