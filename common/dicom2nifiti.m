% prepare the folder like below
% -subject_dir
%   -DICOM
%       -MRI
%       -CT
%it will create below folder and put the converted img files in the corresponding
%folder
%-subject_dir
%   -NIfTI
%       -MRI
%       -CT
subjectDirectory='/Volumes/second/data_local/iEEGview/subjects/HHFU016';
%MRI_folder_name='MRI';
%CT_folder_name='CT';
mriDICOMpath = strcat(subjectDirectory, '/DICOM/MRI/');
ctDICOMpath = strcat(subjectDirectory, '/DICOM/CT/');

% gets all dicom files from dicom folder
mriDICOMfiles = dir(strcat(mriDICOMpath, '/*.dcm')); 
ctDICOMfiles = dir(strcat(ctDICOMpath, '/*.IMA')); % *.dcm


% puts dicom file names in array
mriDICOMfilenames = {mriDICOMfiles.name}';
ctDICOMfilenames = {ctDICOMfiles.name}';

fprintf('Now converting DICOM to NIfTI\n\n');
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

% prepare the paths for the ct and mri NIfTI files to be moved to
mriPath = strcat(subjectDirectory, '/NIfTI/MRI/');
ctPath = strcat(subjectDirectory, '/NIfTI/CT/');

% make the directories to hold the NIfTI files
if ~exist(mriPath,'dir')
    mkdir(mriPath);
end
if ~exist(ctPath,'dir')
    mkdir(ctPath);
end

% if statements are to prevent error if files are already in the right
% directory
% shouldn't be needed anymore now that checks are performed to ensure that
% the NIfTI folder does not exist prior to conversion
if ~strcmp(mriPath, pwd)
    % move the resulting mri files (.img and .hdr) to the nifti folder
    movefile(strcat(mriNIfTIfiles, '.img'), mriPath);
    movefile(strcat(mriNIfTIfiles, '.hdr'), mriPath);
end

if ~strcmp(ctPath, pwd)
    % move the resulting ct files (.img and .hdr) to the nifti folder
    movefile(strcat(ctNIfTIfiles, '.img'), ctPath);
    movefile(strcat(ctNIfTIfiles, '.hdr'), ctPath);
end