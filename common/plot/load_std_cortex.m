function cortex=load_std_cortex(std_brain_model) %
if strcmp(std_brain_model,'fsaverage')
    filename=strcat(std_brain_model_dir,'FSAVERAGE/MATLAB/WholeCortex.mat');
elseif strcmp(std_brain_model,'mni')
    filename=strcat(std_brain_model_dir,'MNI/MATLAB/WholeCortex.mat');
end

tmp=load(filename);
cortex=tmp.cortex;
