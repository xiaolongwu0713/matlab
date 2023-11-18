function [viewstruct,cmapstruct]=view_setup(viewstruct)

% param.electrodes_pos = input('What side of the brain do you want to view? ("front"|"top"|"lateral"|"isometric"|"right"|"left"): ');
% global View
% param.electrodes_pos = handles.Side;
viewstruct.viewpos
if strcmp(viewstruct.viewpos,'front')
%%%%%front view%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   viewstruct.lightpos=[0,180,0];
    viewstruct.viewvect=[180,0];
elseif strcmp(viewstruct.viewpos,'top')
%%%%%top view%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 viewstruct.lightpos=[0,0,80];
    viewstruct.viewvect=[0,90];
elseif strcmp(viewstruct.viewpos,'isometric')
%%%%%isometric view%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 viewstruct.lightpos=[-100,80,45];
   viewstruct.viewvect=[-108,30];
   
elseif strcmp(viewstruct.viewpos,'right')
    viewstruct.viewvect     = [90, 0];
     viewstruct.lightpos     = [150, 0, 0];
elseif strcmp(viewstruct.viewpos,'left')
     viewstruct.viewvect     = [270, 0];
     viewstruct.lightpos     = [-150,0, 0];
else
    error('wrong input, check your spelling');
end

viewstruct.material     = 'dull';
viewstruct.enablelight  = 1;
viewstruct.enableaxis   = 0;
viewstruct.lightingtype = 'gouraud';
viewstruct.enablecortexcolor=1;
viewstruct.enablewhitematter=0;

II = strmatch('activations', viewstruct.what2view,'exact');
if ~isempty(II)
    cmapstruct.basecol          = [0.97, 0.92, 0.92];
else
    cmapstruct.basecol          = [0.7, 0.7, 0.7];
end
cmapstruct.fading           = true;
cmapstruct.enablecolormap   = true;
cmapstruct.enablecolorbar   = true;
cmapstruct.color_bar_ticks  = 4;
ix = 1;
figure; % c
cmapstruct.cmap = colormap('Jet'); close(gcf); %because colormap creates a figure
cmapstruct.ixg2 = floor(length(cmapstruct.cmap) * 0.15);
cmapstruct.ixg1 = -cmapstruct.ixg2;

%cmapstruct.cmin = -log(0.05/mean(tala.elenum_per_subject));
cmapstruct.cmin = 0; %str2double(get(handles.edit_Cmin,'string'));
cmapstruct.cmax = 10; %str2double(get(handles.edit_Cmax,'string'));
% cmapstruct.cmax = max(tala.activations(:,ix));

end