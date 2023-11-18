function [ ] = viewBrain( M, subjstructs, what2view, transp, colix, viewvect,roi)
% roi=[1,2,3,4....]
%VIEWBRAIN  Display a brain model and/or electrode grid locations using activateBrain.
%
%   CALLING SEQUENCE:
%       viewBrain( M )
%       viewBrain( M, subjstructs )
%       viewBrain( M, subjstructs, what2view, transp )
%       viewBrain( M, subjstructs, what2view, transp, colix )
%
%   INPUT:
%       M:              struct('vert', Vx3matrix, 'tri', Tx3matrix) - brain model (eventually the one altered by projectElectrodes, see <help projectElectrodes>)
%       subjstructs:    field of structures, for each subject: struct('activations', NsubjxLsubjMatrix, 'trielectrodes', Nsubjx1Matrix) - structure of 'electrodes' only or enhanced subjstructs (output of projectElectrodes), where 'trielectrodes' is a matrix of coordinates of the projected electrodes
%       what2view:      a column cell of strings specifying what shall be visualized:
%           possible values: 'brain' - shows the grey brain
%                            'activations' - shows the activations
%                            'electrodes' - shows the original electrode locations
%                            'trielectrodes' - shows the projected electrode locations
%                                 (e.g. {'brain', 'electrodes'} )
%       transp:         brain surface transparency value (<0, 1> : 0 - invisible, 1 - opaque) - this is mainly used for plotting more than one brain on the same figure using <hold on> - see Example below
%       colix:          a colour index into a 64-value greyscale colormap used (0 - black, 64 - white) - this is mainly used for plotting more than one brain on the same figure using <hold on> - see Example below
%       viewvect:       vector used by the view command (e.g. [-90, 0])
%
%   Example:    
%       load pial_talairach;
%       load DEMOsubj;
%       M = cortex;
%       viewBrain( M, subj, {'brain', 'electrodes'}, 0.5, 24 );
%       hold on;
%       M = hullModel(M);
%       viewBrain( M, subj, {'brain', 'electrodes'}, 0.5, 42 );
%
%       Please see also demo and activateBrain for further information
%
%   See also DEMO, PROJECTELECTRODES, ELECTRODESCONTRIBUTIONS, ACTIVATEBRAIN, RECORDBRAIN, COARSERMODEL, SMOOTHMODEL, HULLMODEL.

%   Author: Jan Kubanek
%   Institution: Czech Technical University in Prague
%   Date: August 2005
%   This procedure is a part of the activeBrain Matlab package which was
%   designed for internal purposes of the BCI group at the Wadsworth Institute,
%   Albany, NY.

config_all;
%config_gesture;
grey = 32;    
if exist('colix', 'var'),
    grey = colix;
end
if size(colix,2)
    color=colix;
end

if ~exist('what2view', 'var'),
    if exist('subjstructs', 'var'),
        what2view = {'brain', 'electrodes'};
    else
        what2view = {'brain'};
    end
end
if ~exist('viewvect', 'var'),
    viewvect = [90, 0];
end
if ~exist('transp', 'var'),
    transp = 1;
end

viewstruct.what2view = what2view;
viewstruct.material = 'dull';
viewstruct.enablelight = 1;
viewstruct.enablecolorbar = 0;
viewstruct.enableaxis = 1;
viewstruct.lightingtype = 'gouraud';
if strcmp(viewvect,'front')
%%%%%front view%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   viewstruct.lightpos=[0,180,0];
    viewstruct.viewvect=[180,0];
elseif strcmp(viewvect,'top')
%%%%%top view%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 viewstruct.lightpos=[0,0,80]; %[0,0,80];
    viewstruct.viewvect=[0,90];
elseif strcmp(viewvect,'lateral')
%%%%%lateral view%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  viewstruct.lightpos=[85,0,0];
   viewstruct.viewvect=[90,0];
elseif strcmp(viewvect,'isometric')
%%%%%isometric view%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 viewstruct.lightpos=[-100,80,45];
   viewstruct.viewvect=[-108,30];
   
elseif strcmp(viewvect,'right')
     viewstruct.viewvect     = [110, 10];
     viewstruct.lightpos     = [150, 0, 0];
elseif strcmp(viewvect,'left')
     viewstruct.viewvect     = [270, 5];
%      viewstruct.viewvect     = [-82, 5];
     viewstruct.lightpos     = [-150,0, 10];   
else
    error('wrong input, check your spelling');
end
%Prepare for plotting
hold on;

markers = '+o*.xsd^v><ph'; %electrode marker type for each subject
colours = {'r', 'g', 'b', 'y'};
if exist('subjstructs', 'var'), Ss = length(subjstructs); else Ss = 0; end % Ss is subjects number
colormap('Bone');

%Please specify viewstruct.what2view (see above in comments) if you want to display the brain and/or the activations
%grey brain:
I = strmatch('brain', viewstruct.what2view,'exact');
I2 = strmatch('cortexcolor', viewstruct.what2view,'exact');
if ~isempty(I) && isempty(I2),
    trisurf(M.tri, M.vert(:, 1), M.vert(:, 2), M.vert(:, 3), 'FaceVertexCData', [0.9 0.9 0.9], 'CDataMapping', 'direct', 'linestyle', 'none', 'FaceAlpha', transp);
end
%activations on it:
I = strmatch('activations', viewstruct.what2view,'exact');
if ~isempty(I),
    trisurf(M.tri, M.vert(:, 1), M.vert(:, 2), M.vert(:, 3), 'FaceVertexCData', Cindexed, 'FaceColor', 'interp', 'CDataMapping', 'direct', 'linestyle', 'none');
end

%I2 = strmatch('cortexcolor', viewstruct.what2view,'exact');

cpm=1;
if ~isempty(I2)
     switch  cpm  %%% Cortical Parcellation methods,need to add handle here in GUI
        case 1
            Color_Mat=load([std_brain_model_dir,'MNI/MATLAB/Cortex_Center_aparc.mat']);
        case 2
            Color_Mat=load([std_brain_model_dir,'MNI/MATLAB/Cortex_Center_aparc2009.mat']);
        case 3
            Color_Mat=load([std_brain_model_dir,'MNI/MATLAB/Cortex_Center_DKT40.mat']);
    end
    % Color_Mat=load('Cortex_Center.mat');
%     Color_Cindex=repmat((cmapstruct.basecol+[0.1,0.1,0.1]),Mm,1);
    Mm = length(M.vert);
    Color_Cindex=repmat([0.9,0.9,0.9],Mm,1);
    Color_Cindex(Color_Mat.M(2).Cortex_Color(:,1),:)=Color_Mat.M(2).Cortex_Color(:,2:4);
    Color_Cindex(Color_Mat.M(1).Cortex_Color(:,1)+size(Color_Mat.M(2).vert,1),:)=Color_Mat.M(1).Cortex_Color(:,2:4); 
    
    if exist('roi','var')
        spec_std = roi;
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
                    Color_Cindex(Cortex_Index,:)=repmat([220,220,220],length(Cortex_Index),1)/255;
                else
                    Color_Cindex(Cortex_Index+size(Color_Mat.M(2).vert,1),:)=repmat([220,220,220],length(Cortex_Index),1)/255;
                end
            end
        else
            %                        Color_Cindex(Color_Mat.M(2).Cortex_Color(:,1),:)=Color_Mat.M(2).Cortex_Color(:,2:4);
%                        Color_Cindex(Color_Mat.M(1).Cortex_Color(:,1)+size(Color_Mat.M(2).vert,1),:)=Color_Mat.M(1).Cortex_Color(:,2:4); 
        end
    end
    hh=trisurf(M.tri, M.vert(:, 1), M.vert(:, 2), M.vert(:, 3),  'FaceVertexCData',  Color_Cindex, 'FaceColor', 'interp', 'CDataMapping', 'direct', 'linestyle', 'none','FaceAlpha',transp);%0.1
    set(hh,'FaceLighting','phong','AmbientStrength',0.5);


end
if viewstruct.enableaxis
    axis equal;        
else
    axis equal off;
end
view(viewstruct.viewvect);
material(viewstruct.material);
if viewstruct.enablelight
    %light('Position', viewstruct.lightpos, 'Style', 'infinite');
end
%lighting(viewstruct.lightingtype);

%Please specify viewstruct.what2view (see above in comments) if you want to display the electrodes
for k = 1 : Ss
    %original electrode locations:       
    I = strmatch('electrodes', viewstruct.what2view,'exact');
    if ~isempty(I)
        if strcmp(fieldnames(subjstructs(k)),'activations') % activation exises
            plotBalls(subjstructs(k).electrodes, color, subjstructs(k).activations); % plotBalls(electrodes, color, radius)
%         patch(subjstructs(k).electrodes(:, 1), subjstructs(k).electrodes(:, 2), subjstructs(k).electrodes(:, 3), colours{k}, 'FaceColor', 'none', 'LineStyle', 'none', 'Marker', markers(k + Ss), 'MarkerEdgeColor', colours{k}, 'MarkerFaceColor', 'none');
        else
            plotBalls(subjstructs(k).electrodes, color, 0.7); % radius: 0.8
        end
     end

    %transformed electrode locations
    I = strmatch('trielectrodes', viewstruct.what2view,'exact');
    if ~isempty(I)
         plotBalls(subjstructs(k).trielectrodes, 'red', 1.5);
%         patch(subjstructs(k).trielectrodes(:, 1), subjstructs(k).trielectrodes(:, 2), subjstructs(k).trielectrodes(:, 3), colours{k}, 'FaceColor', 'none', 'LineStyle', 'none', 'Marker', markers(k), 'MarkerEdgeColor', colours{k}, 'MarkerFaceColor', 'none');
    end

    fprintf('done\n');
end

xlabel('x');
ylabel('y');
zlabel('z');

hold off;