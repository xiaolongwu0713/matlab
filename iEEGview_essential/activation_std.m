function activation_std(handles, elec_Final_Norm)
config_all;
switch handles.popupmenu_Sub
    case 1 % activations for single subject
        %subpath{1}= [handles.ConfigurationPath.subject_directory '/Electrodes/electrodes_Final_Norm.mat'];

        %for sub = 1:length(subpath) %1:length(ele_Final_Norm) %1:length(subpath)
        %tmpdata = load(subpath{sub}); %tmpdata=ele_Final_Norm{sub};%
        sub=1; % only one subject
        tmpdata=elec_Final_Norm;
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
        %end
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
        handles.CalculationFlag_Activation_std = 1;

        try
            if isempty(handles.Electrode_mni) % this is not a good judgement
                errordlg('Please load the electrode informations of all subjects!')
                return;
            end
        catch
            errordlg('Please load the electrode informations of all subjects!')
            return;
        end
        ConfigurationPath = handles.ConfigurationPath;
        %modeltype = get(handles.popupmenu_StandardModelType,'value');
        modeltype = handles.modeltype;
        if modeltype==1
            StdbrainModel_path=[std_brain_model_dir,'/MNI/MATLAB/WholeCortex.mat'];
            stdmodel = load(StdbrainModel_path);
            cortex = stdmodel.cortex;
            clear stdmodel
        elseif modeltype==2
            StdbrainModel_path=[std_brain_model_dir,'/FSAVERAGE/MATLAB/WholeCortex.mat'];
            stdmodel = load(StdbrainModel_path);
            cortex = stdmodel.cortex;
            clear stdmodel
        end
        % determine whether to re-calculation
        try
            if modeltype~= 1 % handles.oldModelType_std
                handles.CalculationFlag_Activation_std = 0;
            end
        catch 
        end
        handles.oldModelType_std = modeltype;            

        % the projecting parameters
        %KernelType(1) = get(handles.popupmenu_DP_KernelType,'value');
        %KernelType(2) = str2num(get(handles.edit_DP_CutoffDistance_Cortical,'string'));
        %KernelType(3) = str2num(get(handles.edit_DP_CutoffDistance_CP,'string'));
        %KernelType(4) = str2num(get(handles.edit_DP_MaximumDistance,'string'));
        KernelType=[1,10,15,25];
        handles.KernelType_lasttime=KernelType;
        if ~all(KernelType==handles.KernelType_lasttime)
            handles.KernelType_lasttime = KernelType;
            handles.CalculationFlag_Activation_std = 0;
        end
        % view side
        %viewall = get(handles.popupmenu_DP_ViewSide,'string');
        %viewnum = get(handles.popupmenu_DP_ViewSide,'value');
        viewall={'front','top','right','left','isometric'};
        viewnum=1;
        viewside = viewall{viewnum};
        handles.Side = viewside;
        % activations(:,1)=rand(121,1);
        %         load([ConfigurationPath.subject_directory,'/MATLAB/',ConfigurationPath.subject_name,'.mat']);
        tala = [];
        tala.electrodes = [];
        tmpele.sEEGelectrodes = [];
        tmpele.ECoGelectrodes = [];
        tmpele.hemseeg=[];
        tmpele.hemecog=[];
        switch modeltype
            case 1
                for sub = 1:length(handles.Electrode_mni)
                    if handles.sEEGnum(sub)~=0 % contain SEEG
                        for ele = 1:handles.sEEGnum(sub)
                            tmpele.sEEGelectrodes(end+1,:) = handles.Electrode_mni{sub}{ele};
                            tmpele.hemseeg(end+1,1)=handles.heminfo{sub}(ele);
                        end
                    end
                    if length(handles.Electrode_mni{sub})>handles.sEEGnum(sub) % contain ECoG
                        for ele = handles.sEEGnum(sub)+1:length(handles.Electrode_mni{sub})
                            tmpele.ECoGelectrodes(end+1,:) = handles.Electrode_mni{sub}{ele};
                            tmpele.hemecog(end+1,1)=handles.heminfo{sub}(ele);
                        end
                    end
                end
            case 2
                for sub = 1:length(handles.Electrode_fsave)
                    if handles.sEEGnum(sub)~=0
                        for ele = 1:handles.sEEGnum(sub)
                            tmpele.sEEGelectrodes(end+1,:) = handles.Electrode_fsave{sub}{ele};
                            tmpele.hemseeg(end+1,1)=handles.heminfo{sub}(ele);
                        end
                    end
                    if length(handles.Electrode_fsave{sub})>handles.sEEGnum(sub)
                        for ele = handles.sEEGnum(sub)+1:length(handles.Electrode_fsave{sub})
                            tmpele.ECoGelectrodes(end+1,:) = handles.Electrode_mni{sub}{ele};
                            tmpele.hemecog(end+1,1)=handles.heminfo{sub}(ele);
                        end
                    end
                end

        end
        tala.electrodes = [tmpele.sEEGelectrodes;tmpele.ECoGelectrodes];
        tala.hem=[tmpele.hemseeg;tmpele.hemecog];
        tala.seeg_pos = sum(handles.sEEGnum);
        handles.modeltype=modeltype;% function handles = plotactivations_std(M,eleS,activations,kernelpara,sub_info,pathToSubjectDir,handles)
        handles = plotactivations_std(cortex, tala, handles.ActivationData, KernelType,ConfigurationPath.subject_name, ConfigurationPath.subject_directory, handles);
    case 2 % activations for multiple subjects
        try
            if isempty(handles.Electrode_mni) % this is not a good judgement
                errordlg('Please load the electrode informations of all subjects!')
                return;
            end
        catch
            errordlg('Please load the electrode informations of all subjects!')
            return;
        end
        
        ConfigurationPath = handles.ConfigurationPath;

        modeltype = get(handles.popupmenu_StandardModelType,'value');
    %         modeltype = 2;
        if modeltype==1
            StdbrainModel_path=[ConfigurationPath.iEEGview_directory,'/iEEGview/StdbrainModel/MNI/MATLAB/WholeCortex.mat'];
            stdmodel = load(StdbrainModel_path);
            cortex = stdmodel.cortex;
            clear stdmodel
        elseif modeltype==2
            StdbrainModel_path=[ConfigurationPath.iEEGview_directory,'/iEEGview/StdbrainModel/FSAVERAGE/MATLAB/WholeCortex.mat'];
            stdmodel = load(StdbrainModel_path);
            cortex = stdmodel.cortex;
            clear stdmodel
        end
        % determine whether to re-calculation
        handles.oldModelType_std=1;
        try
            if modeltype~=handles.oldModelType_std
                handles.CalculationFlag_Activation_std = 0;
            end
        catch 
        end
        handles.oldModelType_std = modeltype;

        tmp = get(handles.checkbox_ReCalculation,'value');
        if tmp                    
            handles.CalculationFlag_Activation_std = 0;                    
        end    

        KernelType(1) = get(handles.popupmenu_DP_KernelType,'value');
        KernelType(2) = str2num(get(handles.edit_DP_CutoffDistance_Cortical,'string'));
        KernelType(3) = str2num(get(handles.edit_DP_CutoffDistance_CP,'string'));
        KernelType(4) = str2num(get(handles.edit_DP_MaximumDistance,'string'));

        if ~all(KernelType==handles.KernelType_lasttime)
            handles.KernelType_lasttime = KernelType;
            handles.CalculationFlag_Activation_std = 0;
        end
        % view side
        %viewall = get(handles.popupmenu_DP_ViewSide,'string');
        %viewnum = get(handles.popupmenu_DP_ViewSide,'value');
        viewall={'front','top','right','left','isometric'};
        viewnum=1;
        viewside = viewall{viewnum};
        handles.Side = viewside;

        tala = [];
        tala.electrodes = [];
        tmpele.sEEGelectrodes = [];
        tmpele.ECoGelectrodes = [];
        tmpele.hemseeg=[];
        tmpele.hemecog=[];
        switch modeltype
            case 1
                for sub = 1:length(handles.Electrode_mni)
                    if handles.sEEGnum(sub)~=0
                        for ele = 1:handles.sEEGnum(sub)
                            tmpele.sEEGelectrodes(end+1,:) = handles.Electrode_mni{sub}{ele};
                            tmpele.hemseeg(end+1,1)=handles.heminfo{sub}(ele);
                        end
                    end
                    if length(handles.Electrode_mni{sub})>handles.sEEGnum(sub)
                        for ele = handles.sEEGnum(sub)+1:length(handles.Electrode_mni{sub})
                            tmpele.ECoGelectrodes(end+1,:) = handles.Electrode_mni{sub}{ele};
                            tmpele.hemecog(end+1,1)=handles.heminfo{sub}(ele);
                        end
                    end
                end
            case 2
                for sub = 1:length(handles.Electrode_fsave)
                    if handles.sEEGnum(sub)~=0
                        for ele = 1:handles.sEEGnum(sub)
                            tmpele.sEEGelectrodes(end+1,:) = handles.Electrode_fsave{sub}{ele};
                            tmpele.hemseeg(end+1,1)=handles.heminfo{sub}(ele);
                        end
                    end
                    if length(handles.Electrode_fsave{sub})>handles.sEEGnum(sub)
                        for ele = handles.sEEGnum(sub)+1:length(handles.Electrode_fsave{sub})
                            tmpele.ECoGelectrodes(end+1,:) = handles.Electrode_mni{sub}{ele};
                            tmpele.hemecog(end+1,1)=handles.heminfo{sub}(ele);
                        end
                    end
                end

        end
        tala.electrodes = [tmpele.sEEGelectrodes;tmpele.ECoGelectrodes];
        tala.hem=[tmpele.hemseeg;tmpele.hemecog];
        tala.seeg_pos = sum(handles.sEEGnum);
        handles.modeltype=modeltype;
        handles = plotactivations_std(cortex, tala, handles.ActivationData, KernelType,ConfigurationPath.subject_name, ConfigurationPath.subject_directory, handles);
end

end