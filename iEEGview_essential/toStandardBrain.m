
if handles.MultiSubFlag==1
    fprintf('Standard model translating... \n');

    ConfigurationPath = handles.ConfigurationPath;
    [trans_matrix]=Read_Transform_Matrix(ConfigurationPath.subject_directory); % talairach.xfm:3x4 matrix of double
    std_brain_path=['/Users/long/Documents/BCI/matlab_plugin/iEEGview_essential/StdbrainModel']; % include: FSAVERAGE and MNI
    
    xfm_path=[ConfigurationPath.subject_directory,'/MATLAB/xfrm_matrices.mat']; % xfrm_matrices=[M.vox2ras;M.tkrvox2ras]; 
    load(xfm_path);% xfrm_matrices: 8x4 double matrix
    
    Norig = xfrm_matrices(1:4, :);
    Torig = xfrm_matrices(5:8, :);
    subpath{1} = [ConfigurationPath.subject_directory '/Electrodes/electrodes_Final_Anatomy_wm.mat'];
    Electrode_mni = {};
    Electrode_fsave= {};
    Electrode_AnaName = {};
    hem={};
    for sub = 1
        try
            tmpdata = load(subpath{sub}); % load: electrodes_Final_Anatomy_wm.mat
        catch
            errordlg('No anatomy file is found. Please finish the anatomy localiazation first!');
        end
        fssurfpath=fullfile(std_brain_path,'FSAVERAGE','MATLAB','WholeCortex.mat');
        if ~exist(fssurfpath,'file')
            errordlg('No standard brain file is found. Please check and finish the brain reconstruction first!');
        else
            fsctxfile=load(fssurfpath); % load: iEEGview/iEEGview/StdbrainModel/FSAVERAGE/MATLAB/WholeCortex.mat
        end
        subsurfpath=fullfile(ConfigurationPath.subject_directory,'MATLAB','WholeCortex.mat');
        if ~exist(subsurfpath,'file')
            errordlg('No brain file is found. Please check and finish the brain reconstruction first!');
        else
            subctxfile=load(subsurfpath); % load: iEEGview_demo/MATLAB/WholeCortex.mat
        end
        subsurfpath=fullfile(ConfigurationPath.subject_directory,'Segmentation','surf');
        subvolpath=fullfile(ConfigurationPath.subject_directory,'Segmentation','mri','T1.mgz');
        elec_inds=cell2mat(tmpdata.elec_Info_Final_wm.pos'); % tmpdata: electrodes_Final_Anatomy_wm.mat
        elec_inds=Norig*inv(Torig)*[elec_inds,ones(size(elec_inds,1),1)]'; % to scanner RAS coordinate     
        elec_inds=elec_inds(1:3,:)'; % transform elec_inds
        
        [~,elec_norm_vol]=vol_normalization(subvolpath,elec_inds); % to MNI template in MNI152 space
        for j=1:length(tmpdata.elec_Info_Final_wm.pos)
            pos_norm=[tmpdata.elec_Info_Final_wm.pos{j},1]';
            if ~isempty(strmatch(tmpdata.elec_Info_Final_wm.eletype{j},'Depth','exact'))
                pos_norm=trans_matrix*Norig*inv(Torig)*[tmpdata.elec_Info_Final_wm.pos{j},1]'; %%% MNI305
                tmpdata.elec_Info_Final_wm.norm_pos_mni{j}=elec_norm_vol(j,:);
                tmpdata.elec_Info_Final_wm.norm_pos_fsave{j}=pos_norm(1:3)';
            elseif ~isempty(strmatch(tmpdata.elec_Info_Final_wm.eletype{j},'Grid','exact'))
                tmpdata.elec_Info_Final_wm.norm_pos_mni{j}=elec_norm_vol(j,:);
                tmpdata.elec_Info_Final_wm.norm_pos_fsave{j}=sub2stdbrain(tmpdata.elec_Info_Final_wm.pos{j},tmpdata.elec_Info_Final_wm.hem(j),subctxfile,fsctxfile);
            else
                errordlg('Wrong electrode type found, please check the electrode file!');
            end
            
        end
        
    end
    %%%%%%%%
    
    handles.normdist = 25;
    stdtala = tmpdata.elec_Info_Final_wm;
    stdtala.electrodes_mni=cell2mat(tmpdata.elec_Info_Final_wm.norm_pos_mni');
    stdtala.electrodes_fsave=cell2mat(tmpdata.elec_Info_Final_wm.norm_pos_fsave');
    for mdind=1:2 % MNI+fsaverage
        switch mdind
            case 1
                stdtala.electrodes=stdtala.electrodes_mni;
                [ stdtala ] = projectElectrodesDepthGridStd(std_brain_path,stdtala,handles,'mni');
                tmpdata.elec_Info_Final_wm.norm_electrodesdur_mni=(mat2cell(stdtala.electrodesdur,ones(1,size(stdtala.electrodesdur,1)),3))';
                tmpdata.elec_Info_Final_wm.norm_trielectrodes_mni=(mat2cell(stdtala.trielectrodes,ones(1,size(stdtala.trielectrodes,1)),3))';
            case 2
                stdtala.electrodes=stdtala.electrodes_fsave;
                [ stdtala ] = projectElectrodesDepthGridStd(std_brain_path,stdtala,handles,'fsave');
                tmpdata.elec_Info_Final_wm.norm_electrodesdur_fsave=(mat2cell(stdtala.electrodesdur,ones(1,size(stdtala.electrodesdur,1)),3))';
                tmpdata.elec_Info_Final_wm.norm_trielectrodes_fsave=(mat2cell(stdtala.trielectrodes,ones(1,size(stdtala.trielectrodes,1)),3))';
        end
    end
    %%%%%%%%
    Electrode_mni{1} = tmpdata.elec_Info_Final_wm.norm_pos_mni;
    Electrode_fsave{1} = tmpdata.elec_Info_Final_wm.norm_pos_fsave;
    Electrode_AnaName{1} = tmpdata.elec_Info_Final_wm.ana_label_name;
    elec_Info_Final_wm = tmpdata.elec_Info_Final_wm;
    handles.Electrodedur_mni{1} = tmpdata.elec_Info_Final_wm.norm_electrodesdur_mni;
    handles.TriElectrode_mni{1} = tmpdata.elec_Info_Final_wm.norm_trielectrodes_mni;
    handles.Electrodedur_fsave{1} = tmpdata.elec_Info_Final_wm.norm_electrodesdur_fsave;
    handles.TriElectrode_fsave{1} = tmpdata.elec_Info_Final_wm.norm_trielectrodes_fsave;
    handles.Electrode_mni = Electrode_mni;
    handles.Electrode_fsave = Electrode_fsave;
    handles.Electrode_AnaName = Electrode_AnaName;
    handles.cpm=tmpdata.elec_Info_Final_wm.cpm;
    handles.sEEGnum(1) = tmpdata.elec_Info_Final_wm.seeg_pos;
    handles.heminfo=cell(1,1);
    handles.heminfo{1}=tmpdata.elec_Info_Final_wm.hem;
    
    save([ConfigurationPath.subject_directory,'/Electrodes/electrodes_Final_Norm.mat'],'elec_Info_Final_wm');

elseif handles.MultiSubFlag==2
    try
        [subpath,standardpath] = StandardIntergration_GUI(handles);
    catch
        return;
    end
    for sub = 1:length(subpath)
        tmpdata = load(subpath{sub});
        Electrode_mni{sub} = tmpdata.elec_Info_Final_wm.norm_pos_mni;
        Electrode_fsave{sub} = tmpdata.elec_Info_Final_wm.norm_pos_fsave;
        TriElectrode_mni{sub} = tmpdata.elec_Info_Final_wm.norm_trielectrodes_mni;
        Electrode_AnaName{sub} = tmpdata.elec_Info_Final_wm.ana_label_name;
        Electrodedur_mni{sub} = tmpdata.elec_Info_Final_wm.norm_electrodesdur_mni;
        TriElectrode_fsave{sub} = tmpdata.elec_Info_Final_wm.norm_trielectrodes_fsave;
        Electrodedur_fsave{sub} = tmpdata.elec_Info_Final_wm.norm_electrodesdur_fsave;
        hem{sub}=tmpdata.elec_Info_Final_wm.hem;
        try
            sEEGnum(sub) = tmpdata.elec_Info_Final_wm.seeg_pos;
        catch
            sEEGnum(sub) = 0;
        end
    end
    handles.Electrodedur_mni = Electrodedur_mni;
    handles.TriElectrode_mni = TriElectrode_mni;
    handles.Electrode_mni = Electrode_mni;
    handles.Electrodedur_fsave = Electrodedur_fsave;
    handles.TriElectrode_fsave = TriElectrode_fsave;
    handles.Electrode_fsave = Electrode_fsave;
    handles.Electrode_AnaName = Electrode_AnaName;
    handles.sEEGnum = sEEGnum;
    handles.cpm=tmpdata.elec_Info_Final_wm.cpm;
    handles.heminfo=hem;
   
end