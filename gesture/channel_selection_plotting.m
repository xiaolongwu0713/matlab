%% extract a certain channel ana: 
% 1: set the channel: selected_channels_gumbel.('sid10')=[146 147]; 
% 2: return the ana: Etala.('sid10_gumbel')
% plot by calling viewBrain from plot_brain folder;

%% config
config_all;
config_gesture;


%fileID = fopen(final_good_sids_file,'r');
fileID = fopen(good_sids_file,'r');
final_good_sids = fscanf(fileID,'%d');
fclose(fileID);
%good_sids=[4 10 13 29 41];
%%  load good channels
load(strcat(meta_dir,'good_channels.mat'))
tmp=good_channels;
clear good_channels;

% make sid as the key of the good_channels structure
info=strcat(info_dir,'info.txt');
M = readmatrix(info);
for index = [1:length(M)]
    sid_name=fieldnames(tmp{1,index});
    sid_name=sid_name{1,1};
    good_channels.(sid_name)=tmp{1,index}.(sid_name);
end 
%% load selected channels
%load(strcat(meta_dir,'selected_channels_gumbel_final.mat'))
load(strcat(meta_dir,'selected_channels_gumbel.mat'))
tmp=selected_channels_gumbel;
clear selected_channels_gumbel;
% for index = 1:length(final_good_sids)
%     sid=final_good_sids(index);
%     key=strcat('sid',num2str(sid));
%     selected_channels_gumbel.(key)=tmp{1,index}.(key);
% end

for index = 1:length(tmp)
    key=fieldnames(tmp{index});
    selected_channels_gumbel.(key{1})=tmp{1,index}.(key{1});
end

%load(strcat(meta_dir,'selected_channels_stg_final.mat'))
load(strcat(meta_dir,'selected_channels_stg.mat'))
tmp=selected_channels_stg;
clear selected_channels_stg;
for index = 1:length(tmp)
    key=fieldnames(tmp{index});
    selected_channels_stg.(key{1})=tmp{1,index}.(key{1});
end

%% check if use_channels == good_channels
% no need for this because: all good_subject use all UseChn as good_channels
keys=fieldnames(good_channels);
for index=1:length(keys)
    key=keys{index,1};
    if length(good_channels.(key))~= max(good_channels.(key))
        key % partially used
    end
end

%% real channel index in the raw data
for index = 1:length(final_good_sids)
    key=strcat('sid',num2str(final_good_sids(index)));
    ele_index_gumbel.(key)=zeros(size(selected_channels_gumbel.(key)));
    ele_index_stg.(key)=zeros(size(selected_channels_stg.(key)));

    selected_goodChn_gumbel.(key)=good_channels.(key)(selected_channels_gumbel.(key));
    selected_goodChn_stg.(key)=good_channels.(key)(selected_channels_stg.(key));
    
    % registration file
    reg=strcat(electrode_dir,'P',num2str(final_good_sids(index)),'/SignalChanel_Electrode_Registration.mat');
    reg=load(reg);
    
    for i=1:length(selected_goodChn_gumbel.(key))
        ele_index_gumbel.(key)(i)=find(reg.CHN==selected_goodChn_gumbel.(key)(i));
    end
    ele_index_gumbel.(key)=sort(ele_index_gumbel.(key));
    for i=1:length(selected_goodChn_stg.(key))
        ele_index_stg.(key)(i)=find(reg.CHN==selected_goodChn_stg.(key)(i));
    end
    ele_index_stg.(key)=sort(ele_index_stg.(key));
end

%% prepare for plotting
clear Etala;
std_brain=strcat(electrode_dir,'Standard Brain/Norm_Brain.mat');
cortex=load(std_brain); cortex=cortex.cortex;

test_activation=1;
for i = 1:length(final_good_sids)%size(Inf, 1)
    sid=final_good_sids(i);
    key=strcat('sid',num2str(sid));
    electrode_file=strcat(electrode_dir,'P',num2str(sid),'/electrodes_Final_Norm.mat'); % input electrode file folder here
    load(electrode_file);
    Etala.(key).electrodes=cell2mat(elec_Info_Final_wm.norm_pos');
    Etala.(key).ana_names=string(elec_Info_Final_wm.ana_label_name);
    %Etala.(key).ana_index=elec_Info_Final_wm.ana_label_index;
    
    chnNum=size(Etala.(key).electrodes,1);
    all_index=1:chnNum;
    
    all_selected_index=union(ele_index_gumbel.(key), ele_index_stg.(key));
    ele_index_left=setdiff(all_index, all_selected_index);
    ele_index_inter = intersect(ele_index_gumbel.(key),ele_index_stg.(key));
    ele_gumbel_only = setdiff(ele_index_gumbel.(key),ele_index_inter);
    ele_gumbel_left = setdiff(all_index, ele_index_gumbel.(key));
    ele_stg_only = setdiff(ele_index_stg.(key),ele_index_inter);
    ele_gumbel = [ele_gumbel_only ele_index_inter];
    ele_stg = [ele_stg_only ele_index_inter];
    
    % add the electrodes activation to plot
    ahalf=floor(chnNum./2);
    bhalf=chnNum-ahalf;
    Etala.(key).activations=[ones(1,ahalf)*1,ones(1,bhalf)*1]';
    
    % assemble data
    key2=strcat('sid',num2str(sid),'_gumbel_only');
    key3=strcat('sid',num2str(sid),'_stg_only');
    key4=strcat('sid',num2str(sid),'_left');
    key5=strcat('sid',num2str(sid),'_inter');
    key6=strcat('sid',num2str(sid),'_gumbel');
    key9=strcat('sid',num2str(sid),'_gumbel_left');
    key7=strcat('sid',num2str(sid),'_stg');
    key8=strcat('sid',num2str(sid),'_all'); %all_index
    
    
    Etala.(key2).electrodes = Etala.(key).electrodes(ele_gumbel_only,:);
    Etala.(key2).activations=Etala.(key).activations(ele_gumbel_only);
    Etala.(key2).ana_names=Etala.(key).ana_names(ele_gumbel_only);
    %Etala.(key2).ana_index=Etala.(key).ana_index(ele_gumbel_only);
    
    Etala.(key3).electrodes = Etala.(key).electrodes(ele_stg_only,:);
    Etala.(key3).activations=Etala.(key).activations(ele_stg_only);
    Etala.(key3).ana_names=Etala.(key).ana_names(ele_stg_only);
    %Etala.(key3).ana_index=Etala.(key).ana_index(ele_stg_only);
    
    Etala.(key4).electrodes = Etala.(key).electrodes(ele_index_left,:);
    Etala.(key4).activations=Etala.(key).activations(ele_index_left);
    Etala.(key4).ana_names=Etala.(key).ana_names(ele_index_left);
    %Etala.(key4).ana_index=Etala.(key).ana_index(ele_index_left);
    
    Etala.(key5).electrodes = Etala.(key).electrodes(ele_index_inter,:);
    Etala.(key5).activations=Etala.(key).activations(ele_index_inter);
    Etala.(key5).ana_names=Etala.(key).ana_names(ele_index_inter);
    %Etala.(key5).ana_index=Etala.(key).ana_index(ele_index_inter);
    
    Etala.(key6).electrodes = Etala.(key).electrodes(ele_gumbel,:);
    Etala.(key6).activations=Etala.(key).activations(ele_gumbel);
    Etala.(key6).ana_names=Etala.(key).ana_names(ele_gumbel);
    
    Etala.(key9).electrodes = Etala.(key).electrodes(ele_gumbel_left,:);
    Etala.(key9).activations=Etala.(key).activations(ele_gumbel_left);
    Etala.(key9).ana_names=Etala.(key).ana_names(ele_gumbel_left);
    
    Etala.(key7).electrodes = Etala.(key).electrodes(ele_stg,:);
    Etala.(key7).activations=Etala.(key).activations(ele_stg);
    Etala.(key7).ana_names=Etala.(key).ana_names(ele_stg);
    
    Etala.(key8).electrodes = Etala.(key).electrodes(all_index,:);
    Etala.(key8).activations=Etala.(key).activations(all_index);
    Etala.(key8).ana_names=Etala.(key).ana_names(all_index);
end

%% plot electrodes in std brain model for the individual subject
view_vect={'left','front','top'};
view_vecti=view_vect(3);

figure;
transp_brain = 0.2; % brighter with smaller transp
transp_ele = 0.8;
file_dir=strcat(result_dir,'selection/');

% plot on one example subject
example_sid=10;

% plot the brain with an example colorful ROI
%viewBrain(cortex, Etala, {'brain','cortexcolor'}, transp_brain, [0.9 0.9 0.9], view_vecti,[1,2,3,4]);
% plot the std brain without RIO
viewBrain(cortex, Etala, {'brain'}, transp_brain, [0 1 0], view_vecti,[1,2,3,4]);
% all electrodes
if 1==1
    key=strcat('sid',num2str(example_sid),'_all');
    iEtala=Etala.(key);
    viewBrain(cortex, iEtala, {'electrodes'}, transp_ele, [1,1,0], view_vecti); % yellow
end
% gumbel
if 1==1
    key=strcat('sid',num2str(example_sid),'_gumbel');
    iEtala=Etala.(key);
    viewBrain(cortex, iEtala, {'electrodes'}, transp_ele, [1 0 0], view_vecti); % red
end
% stg
if 1==0
    key=strcat('sid',num2str(example_sid),'_stg');
    iEtala=Etala.(key);
    viewBrain(cortex, iEtala, {'electrodes'}, transp_ele, [1 0 0], view_vecti); % blue
end
% left
if 1==0
    key=strcat('sid',num2str(example_sid),'_left');
    iEtala=Etala.(key);
    viewBrain(cortex, iEtala, {'electrodes'}, transp_ele, [10,1,1]/255, view_vecti); % black
end
% intersection
if 1==0
    key=strcat('sid',num2str(example_sid),'_inter');
    iEtala=Etala.(key);
    viewBrain(cortex, iEtala, {'electrodes'}, transp_ele, [255,255,0]/255, view_vecti); % yellow
end


axis off;
colorbar off
set(0,'defaultfigurecolor','w');
filename=strcat(file_dir,strcat('sid',num2str(sid),'.png'));
%exportgraphics(gca,filename,'Resolution',600);
%clf(gcf);

%%  ######   plot all electrodes on the colorful brain ######
%%%% 1) plot all electrodes in std brain
view_vect={'left','front','top'}; 
view_vecti=view_vect(2);
light('Position', [0,120,0], 'Style', 'infinite'); % light position (top:[0,0,120])
lighting('gouraud');
transp_ele = 0.1;
for i = 1:3%length(final_good_sids)
    sid=final_good_sids(i);
    % gumbel
    if 1==1 % all=gumbel+gumbel_left
        key=strcat('sid',num2str(sid),'_gumbel');
        iEtala=Etala.(key);
        viewBrain(cortex, iEtala, {'electrodes'}, transp_ele, [0,1,0], view_vecti); % green
        
        key=strcat('sid',num2str(sid),'_gumbel_left');
        iEtala=Etala.(key);
        viewBrain(cortex, iEtala, {'electrodes'}, transp_ele, [0.5,0.5,0.5], view_vecti); % black
        
    end
    % stg
    if 1==0
        key=strcat('sid',num2str(sid),'_stg');
        iEtala=Etala.(key);
        viewBrain(cortex, iEtala, {'electrodes'}, transp_ele, [9,39,236]/255, view_vecti); % blue
    end
    % left
    if 1==0
        key=strcat('sid',num2str(sid),'_left');
        iEtala=Etala.(key);
        viewBrain(cortex, iEtala, {'electrodes'}, transp_ele, [10,1,1]/255, view_vecti); % black
    end
    % intersection
    if 1==0
        key=strcat('sid',num2str(sid),'_inter');
        iEtala=Etala.(key);
        viewBrain(cortex, iEtala, {'electrodes'}, transp_ele, [255,255,0]/255, view_vecti); % yellow
    end
    hold on;
end

axis off;
colorbar off
set(0,'defaultfigurecolor','w');


%%%% 2) add a stdbrain brain background and highlight some ROI
view_vect={'left','front','top'};
view_vecti=view_vect{3}; % 3: top
%viewBrain(cortex, Etala, {'brain'}, transp_brain, [0.9 0.9 0.9], view_vecti);

stdmodel = load(strcat(std_brain_model_dir,'MNI/MATLAB/WholeCortex.mat'));
M = stdmodel.cortex;
Color_Mat=load(strcat(std_brain_model_dir,'MNI/MATLAB/Cortex_Center_aparc.mat'));


% Color_Mat=load('Cortex_Center.mat');
%     Color_Cindex=repmat((cmapstruct.basecol+[0.1,0.1,0.1]),Mm,1);
Mm = length(M.vert);
Color_Cindex=repmat([0.9,0.9,0.9],Mm,1);
%Color_Cindex=repmat([0,0,0],Mm,1);
Color_Cindex(Color_Mat.M(2).Cortex_Color(:,1),:)=Color_Mat.M(2).Cortex_Color(:,2:4);
Color_Cindex(Color_Mat.M(1).Cortex_Color(:,1)+size(Color_Mat.M(2).vert,1),:)=Color_Mat.M(1).Cortex_Color(:,2:4); 
handles.spec_std=[23,25]; % pre and post-central regions
spec_std = handles.spec_std;
light('Position', [0,0,100], 'Style', 'infinite');
if ~isempty(handles.spec_std)
    nospec_roi=setdiff([1:Color_Mat.M(1).numEntries],spec_std);
    if ~isempty(nospec_roi)
%             index=cell(length(nospec_roi),1);
        for cmh=1:2
            index=cell(length(nospec_roi),1);
            Cortex_Index=[];
            for cmi=1:length(nospec_roi)
                index{cmi}=find(Color_Mat.M(cmh).BV==Color_Mat.M(cmh).table(nospec_roi(cmi),end));
                while isempty(index{cmi})
                    cmi=cmi+1;
                    index{cmi}=find(Color_Mat.M(cmh).BV==Color_Mat.M(cmh).table(nospec_roi(cmi),end));
                end
                Cortex_Index=[Cortex_Index;index{cmi}];
            end
            if cmh==2
                Color_Cindex(Cortex_Index,:)=repmat([0.9,0.9,0.9],length(Cortex_Index),1);
                %Color_Cindex(Cortex_Index,:)=0; % black
            else
                Color_Cindex(Cortex_Index+size(Color_Mat.M(2).vert,1),:)=repmat([0.9,0.9,0.9],length(Cortex_Index),1);
                %Color_Cindex(Cortex_Index+size(Color_Mat.M(2).vert,1),:)=0;
            end
        end
    else
        %                        Color_Cindex(Color_Mat.M(2).Cortex_Color(:,1),:)=Color_Mat.M(2).Cortex_Color(:,2:4);
%                        Color_Cindex(Color_Mat.M(1).Cortex_Color(:,1)+size(Color_Mat.M(2).vert,1),:)=Color_Mat.M(1).Cortex_Color(:,2:4); 
    end
end % 'FaceAlpha',transparance; 'EdgeAlpha',0.01: seems no effect at all;
hh=trisurf(M.tri, M.vert(:, 1), M.vert(:, 2), M.vert(:, 3),  'FaceVertexCData',  Color_Cindex, 'FaceColor', 'interp', 'CDataMapping', 'direct', 'linestyle', 'none','FaceAlpha',0.1);%0.1

%% plot activation in MNI std brain
% get electrodes from all subjects
all_pos={};
multiple_sids=1; % plot for all sid
sid=4; % test a single sid
if multiple_sids
    for i=1:length(final_good_sids)
        sid = final_good_sids(i);
        ele_file=strcat(electrode_dir,'P',num2str(sid),'/electrodes_Final_Norm.mat');
        elec_Final_Norm=load(ele_file);
        all_pos=[all_pos,elec_Final_Norm.elec_Info_Final_wm.pos];
    end
    all_pos=cell2mat(all_pos');
else
    elec_Final_Norm_file=strcat(electrode_dir,'P',num2str(sid),'/electrodes_Final_Norm.mat');
    elec_Final_Norm=load(elec_Final_Norm_file);
    all_pos=elec_Final_Norm.elec_Info_Final_wm.pos';
    all_pos=cell2mat(all_pos);
end

StdbrainModel_path=[std_brain_model_dir,'MNI/MATLAB/WholeCortex.mat'];
stdmodel = load(StdbrainModel_path);
cortex = stdmodel.cortex;
clear stdmodel

talaa=struct;
talaa.electrodes=all_pos;
talaa.trielectrodes=talaa.electrodes;
talaa.electrodesdur=talaa.electrodes;
ele_num=length(all_pos);
talaa.seeg_pos=ele_num;
talaa.activations=randi([1,6],ele_num,1);

kernelpara=[1,10,15,25];
normdist=kernelpara(4);
modeltype=1;
% projectElectrodesDepthGridStd do nothing for SEEG electrode.
if modeltype==1 % tala.electrodes
  talaa=projectElectrodesDepthGridStd(std_brain_model_dir,talaa,normdist,'mni');  
else
  talaa=projectElectrodesDepthGridStd(std_brain_model_dir,talaa,normdist,'fsave');  
end
[vcontribs,vcontribs_norm]=cal_contrib_norm(cortex,talaa,kernelpara);


viewstruct.enablecortexcolor=0; % Will plot colorful cortex region if what2view = {'brain'} only.
viewstruct.what2view = {'brain','activations'}; %{'brain','activations'};
viewstruct.cpm=1; % 1: aparc, 2:aparc2009, 3:DKT40;
viewstruct.viewpos='top';
[viewstruct,cmapstruct]=view_setup(viewstruct);


handles.viewstruct=viewstruct;
handles.Side='top'; % viewer position
% call plotactivations_std directly without go through activation_std.m
model_type=1; %MNI
ix=1; % no idea
plotactivations_L(cortex, vcontribs_norm, talaa, ix, cmapstruct, viewstruct);
% plotactivations_std(cortex, talaa, talaa.activations, Kernelpara,model_type, 'tst', handles,viewstruct);


%% anatomy analysis of selected electrodes aggregated from all subjects
ana_names1=strings;
for i = 1:length(final_good_sids)%size(Inf, 1)
    sid=final_good_sids(i);
    key=strcat('sid',num2str(sid),'_gumbel');
    %key=strcat('sid',num2str(sid),'_inter');
    name_arrays=Etala.(key).ana_names;
    tmp_name_arrays=strings;
     
    % trailing the anatomy name
    for j =1:length(name_arrays)
        if endsWith(name_arrays{1,j},'White-Matter')
            tmp_name_arrays{1,j}='White-Matter';
        elseif endsWith(name_arrays{1,j},'Inf-Lat-Vent')
            tmp_name_arrays{1,j}='Inf-Lat-Vent';
        else
            m_index1=strfind(name_arrays{1,j},'_');
            m_index2=strfind(name_arrays{1,j},'-');
            if length(m_index2)==0
                m_index2=0;
            end
            if length(m_index1)==0
                m_index1=0;
            end
            afterThis=max(max(m_index1),max(m_index2));
            name_arrays{1,j}
            name_arrays{1,j}(afterThis+1:end)
            tmp_name_arrays{1,j}=name_arrays{1,j}(afterThis+1:end);
        end
    end
    %extractAfter(extractAfter(Etala.(key).ana_names,'-'),'-')
    ana_names1=[ana_names1,tmp_name_arrays];

end
ana_names1=ana_names1';
unique(ana_names1)

%% all anatomy names
ana_names2=strings;
for i = 1:length(final_good_sids)%size(Inf, 1)
    sid=final_good_sids(i);
    key2=strcat('sid',num2str(sid),'_all');
    %key=strcat('sid',num2str(sid),'_inter');
    name_arrays=Etala.(key2).ana_names;
    tmp_name_arrays=strings;
     
    % trailing the anatomy name
    for j =1:length(name_arrays)
        if endsWith(name_arrays{1,j},'White-Matter')
            tmp_name_arrays{1,j}='White-Matter';
        elseif endsWith(name_arrays{1,j},'Inf-Lat-Vent')
            tmp_name_arrays{1,j}='Inf-Lat-Vent';
        else
            m_index1=strfind(name_arrays{1,j},'_');
            m_index2=strfind(name_arrays{1,j},'-');
            if length(m_index2)==0
                m_index2=0;
            end
            if length(m_index1)==0
                m_index1=0;
            end
            afterThis=max(max(m_index1),max(m_index2));
            name_arrays{1,j}
            name_arrays{1,j}(afterThis+1:end)
            tmp_name_arrays{1,j}=name_arrays{1,j}(afterThis+1:end);
        end
    end
    %extractAfter(extractAfter(Etala.(key).ana_names,'-'),'-')
    ana_names2=[ana_names2,tmp_name_arrays];

end
ana_names2=ana_names2';
unique(ana_names2)

%% percentage of selected electrodes: (selected ele in region r)/(total ele in region r)
u_ana_names=unique(ana_names1); % unique of selected electrodes

clear ana_names_dict1;
% selected electrodes number in each region
for i=1:length(u_ana_names)
    key=u_ana_names(i,1);
    key = strrep(key,'-','_');
    
    if key=="" 
        1==1;
    else
        occurance=0;
        for j=1:length(ana_names1)
            if strrep(ana_names1(j,1),'-','_')==key
                occurance=occurance+1;
            end
        end
        ana_names_dict1.(key)=occurance;
     end
    
end


% electrodes number in the selected region
clear ana_names_dict2;
for i=1:length(u_ana_names)
    key=u_ana_names(i,1);
    key = strrep(key,'-','_');
    
    if key=="" 
        1==1;
    else
        occurance=0;
        for j=1:length(ana_names2)
            if strrep(ana_names2(j,1),'-','_')==key
                occurance=occurance+1;
            end
        end
        ana_names_dict2.(key)=occurance;
    end
end

clear ana_perct;
clear ana_perct_detail;
rois=[];
for i=1:length(u_ana_names)
    key=u_ana_names(i,1);
    key = strrep(key,'-','_');
    
    if key=="" 
        1==1;
    else
        rois=[rois,key];
        perct=ana_names_dict1.(key)/ana_names_dict2.(key);
        ana_perct.(key)=perct;
        ana_perct_detail.(key)=[ana_names_dict1.(key),ana_names_dict2.(key)];
    end
end
rois=convertStringsToChars(rois);

%% save Etala and common_ana_names
filename=strcat(result_dir, 'selection/ana_perct_detail.mat');
save(filename, 'rois','ana_perct_detail');
