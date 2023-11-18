%% use the std brain
load_path='/Users/long/mydrive/matlab/iEEGview_essential/StdbrainModel/MNI/MATLAB/';
wholecortex_file=strcat(load_path,'WholeCortex.mat');
rh_anno_file=strcat(load_path,'rh.aparc.a2009s.annot');
lh_anno_file=strcat(load_path,'lh.aparc.a2009s.annot');
Get_3D_Cortex_Center(wholecortex_file,rh_anno_file,lh_anno_file);
%Color_Mat=load(strcat(load_path,'Cortex_Center_aparc.mat'));
Color_Mat=load(strcat(load_path,'Cortex_Center.mat'));
load(strcat(load_path,'WholeCortex.mat'));

%% or use the individual brain
% generate the cortex color code as file Cortex_Center.mat with function Get_3D_Cortex_Center by parsing
% l/rh.aparc.annot file
Get_3D_Cortex_Center('WholeCortex.mat','rh.aparc.annot','lh.aparc.annot'); % only need to run it once
Color_Mat=load('Cortex_Center.mat');
load('WholeCortex.mat');

%% plot all cortex regions
Color_Mat.M(1).struct_names;
Color_Cindex=repmat([0.7,0.7,0.7],length(cortex.vert),1);
Color_Cindex(Color_Mat.M(2).Cortex_Color(:,1),:)=Color_Mat.M(2).Cortex_Color(:,2:4);
Color_Cindex(Color_Mat.M(1).Cortex_Color(:,1)+size(Color_Mat.M(2).vert,1),:)=Color_Mat.M(1).Cortex_Color(:,2:4); % Color_Cindex
hh=trisurf(cortex.tri, cortex.vert(:, 1), cortex.vert(:, 2), cortex.vert(:, 3),  'FaceVertexCData', Color_Cindex , 'FaceColor', 'interp', 'CDataMapping', 'direct', 'linestyle', 'none','FaceAlpha',0.5);%0.1
%hh=trisurf(cortex.tri, cortex.vert(:, 1), cortex.vert(:, 2), cortex.vert(:, 3), 'CDataMapping', 'direct', 'linestyle', 'none','FaceAlpha',0.5);%0.1
set(hh,'FaceLighting','phong','AmbientStrength',0.5);
material('dull');
viewstruct.viewvect     = [110, 10];
viewstruct.lightpos     = [150, 0, 0];
view(viewstruct.viewvect);
light('Position', viewstruct.lightpos, 'Style', 'infinite');
axis equal off;