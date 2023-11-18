ConfigurationPath = handles.ConfigurationPath;
%modeltype = get(handles.popupmenu_StandardModelType,'value');
modeltype = 1;
if modeltype==1
    StdbrainModel_path=[ConfigurationPath.root_path,'StdbrainModel/MNI/MATLAB/WholeCortex.mat'];
    stdmodel = load(StdbrainModel_path);
    Cortex = stdmodel.cortex;
    clear stdmodel
elseif modeltype==2
    StdbrainModel_path=[ConfigurationPath.root_path,'StdbrainModel/FSAVERAGE/MATLAB/WholeCortex.mat'];
    stdmodel = load(StdbrainModel_path);
    Cortex = stdmodel.cortex;
    clear stdmodel
end
%valueflag=get(handles.popupmenu_Sub,'value'); 
valueflag=1; % 1:single subject, 2:multiple
if valueflag==1 && exist(fullfile(ConfigurationPath.subject_directory,'Electrodes','electrodes_Final_Norm.mat'),'file')
    tempfile=load(fullfile(ConfigurationPath.subject_directory,'Electrodes','electrodes_Final_Norm.mat'));
    handles.Electrode_mni{1}=tempfile.elec_Info_Final_wm.norm_pos_mni;
    handles.Electrode_fsave{1}=tempfile.elec_Info_Final_wm.norm_pos_fsave;
    handles.Electrode_AnaName{1}=tempfile.elec_Info_Final_wm.ana_label_name;
    handles.sEEGnum(1)=tempfile.elec_Info_Final_wm.seeg_pos;
    handles.TriElectrode_mni{1}=tempfile.elec_Info_Final_wm.norm_trielectrodes_mni;
    handles.Electrodedur_mni{1}=tempfile.elec_Info_Final_wm.norm_electrodesdur_mni;
    handles.TriElectrode_fsave{1}=tempfile.elec_Info_Final_wm.norm_trielectrodes_fsave;
    handles.Electrodedur_fsave{1}=tempfile.elec_Info_Final_wm.norm_electrodesdur_fsave;
    handles.cpm=tempfile.elec_Info_Final_wm.cpm;
    handles.heminfo=cell(1,1);
    handles.heminfo{1}=tempfile.elec_Info_Final_wm.hem;
    Electrode_mni = handles.Electrode_mni;
    Electrode_AnaName = handles.Electrode_AnaName;

    Etala.electrodes=cell2mat(Electrode_mni{1}');
elseif valueflag==2
    Electrode = handles.Electrode_mni;
    Etala.electrodes=[];
    for j=1:length(Electrode)
        Etala.electrodes=[Etala.electrodes;cell2mat(Electrode{j}')];
    end
    Electrode_AnaName = handles.Electrode_AnaName;
end

viewall={'front','top','right','left','isometric'};
viewnum=1;
ViewVector = viewall{viewnum};

%tmp = str2double(get(handles.edit_Alpha,'string'));
alpha=0.1;
handles.modeltype=modeltype;
handles = viewBrain(Cortex, Etala, {'brain'}, alpha, 50, ViewVector, handles);
hold on
axis off
cut=0;
%ballRadius = str2double(get(handles.edit_BallRadius,'string'));
%ballColor = str2num(get(handles.edit_BallColor,'string'));
ballRadius=1.5;
ballColor=[1 0 0];


tala = [];
tala.electrodes = [];
tala.trielectrodes = [];
tmpele.sEEGelectrodes = [];
tmpele.sEEGtrielectrodes = [];
tmpele.sEEGelectrodes_name=[];
tmpele.sEEGelectrodesdur=[];
tmpele.ECoGelectrodes = [];
tmpele.ECoGtrielectrodes = [];
tmpele.ECoGelectrodes_name=[];
tmpele.ECoGelectrodesdur=[];
switch modeltype
    case 1
        for sub = 1:length(handles.Electrode_mni)
            if handles.sEEGnum(sub)~=0
                for ele = 1:handles.sEEGnum(sub)
                    tmpele.sEEGelectrodes(end+1,:) = handles.Electrode_mni{sub}{ele};
                    tmpele.sEEGtrielectrodes(end+1,:) = handles.TriElectrode_mni{sub}{ele};
                    tmpele.sEEGelectrodesdur(end+1,:) = handles.Electrodedur_mni{sub}{ele};
                    tmpele.sEEGelectrodes_name{end+1}=handles.Electrode_AnaName{sub}{ele};
                end
            end
            if length(handles.Electrode_mni{sub})>handles.sEEGnum(sub)
                for ele = handles.sEEGnum(sub)+1:length(handles.Electrode_mni{sub})
                    tmpele.ECoGelectrodes(end+1,:) = handles.Electrode_mni{sub}{ele};
                    tmpele.ECoGtrielectrodes(end+1,:) = handles.TriElectrode_mni{sub}{ele};
                    tmpele.ECoGelectrodesdur(end+1,:) = handles.Electrodedur_mni{sub}{ele};
                    tmpele.ECoGelectrodes_name{end+1}=handles.Electrode_AnaName{sub}{ele};
                end
            end
        end
    case 2

        for sub = 1:length(handles.Electrode_fsave)
            if handles.sEEGnum(sub)~=0
                for ele = 1:handles.sEEGnum(sub)
                    tmpele.sEEGelectrodes(end+1,:) = handles.Electrode_fsave{sub}{ele};
                    tmpele.sEEGtrielectrodes(end+1,:) = handles.TriElectrode_fsave{sub}{ele};
                    tmpele.sEEGelectrodesdur(end+1,:) = handles.Electrodedur_fsave{sub}{ele};
                    tmpele.sEEGelectrodes_name{end+1}=handles.Electrode_AnaName{sub}{ele};
                end
            end
            if length(handles.Electrode_fsave{sub})>handles.sEEGnum(sub)
                for ele = handles.sEEGnum(sub)+1:length(handles.Electrode_fsave{sub})
                    tmpele.ECoGelectrodes(end+1,:) = handles.Electrode_fsave{sub}{ele};
                    tmpele.ECoGtrielectrodes(end+1,:) = handles.TriElectrode_fsave{sub}{ele};
                    tmpele.ECoGelectrodesdur(end+1,:) = handles.Electrodedur_fsave{sub}{ele};
                    tmpele.ECoGelectrodes_name{end+1}=handles.Electrode_AnaName{sub}{ele};
                end
            end
        end
end
tala.electrodes = [tmpele.sEEGelectrodes;tmpele.ECoGelectrodes];
tala.trielectrodes = [tmpele.sEEGtrielectrodes;tmpele.ECoGtrielectrodes];
tala.electrodesdur = [tmpele.sEEGelectrodesdur;tmpele.ECoGelectrodesdur];
tala.electrodes_name = [tmpele.sEEGelectrodes_name';tmpele.ECoGelectrodes_name'];
tala.seeg_pos = sum(handles.sEEGnum);

plotBalloptions(tala,handles);

