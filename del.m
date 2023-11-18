light('Position', [0,180,0], 'Style', 'infinite');
lighting('gouraud');
transp_ele = 0.1;
i=1;
    sid=final_good_sids(i);
    % gumbel
    if 1==1 % all=gumbel+gumbel_left
        key=strcat('sid',num2str(sid),'_gumbel');
        iEtala=Etala.(key);
        viewBrain(cortex, iEtala, {'electrodes'}, transp_ele, [0,1,0], view_vecti); % green
        
        key=strcat('sid',num2str(sid),'_gumbel_left');
        iEtala=Etala.(key);
        viewBrain(cortex, iEtala, {'electrodes'}, transp_ele, [0,0,0], view_vecti); % black
        
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


