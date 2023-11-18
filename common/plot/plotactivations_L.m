function plotactivations_L( M, vcontribs, subjstructs, range, cmapstruct, viewstruct)
config_all;
% inherit from activeBrain.m
%M: [vert, tri]: cortex martix


%Data for the visualization of the electrodes
markers = 'o+*.xsd^v><ph'; %electrode marker type for each subject
colours = {'r', 'g', 'b', 'y'};

Ss = length(subjstructs);
Mm = length(M.vert);

La = length(vcontribs);
actvert = zeros(La, 1);

for a = 1 : La,
    actvert(a) = vcontribs(a).vertNo;
end

C = zeros(La, 1); %zero vector of activation colours
Cindexed = nan(Mm, 1); %NaN vector of activation colours, numbers inserted where appropriate

%The loop is subject to Matlab6.5 JIT acceleration (although trisurf is not a built-in function):
fprintf('Computing....');

cix = 0;
for r = range, %for specified activation samples
    for a = 1 : La, %for all activated vertices
        contribs = vcontribs(a).contribs; %reallocate for speed
        subjcontr = zeros(Ss, 1); %maximum number of subjects that are able to contribute to the averaging process at a vertex
        sci = 0; %index into subjcontr
        while ~isempty(contribs),
            sci = sci + 1;
            subjNo = contribs(1, 1);
            subjcontrIx = find(contribs(:, 1) == subjNo);
            elNos = contribs(subjcontrIx, 2);
            multips = contribs(subjcontrIx, 3);
            activs = subjstructs(subjNo).activations(elNos, r);
            subjcontr(sci) = activs' * multips;
            contribs(subjcontrIx, :) = [];
        end
        
        cix = cix + 1;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        C(cix) = sum(subjcontr) / sci; %the mean value
        %%% averaged activation value for each related vertex. by GY Li
    end
    fprintf('done\n');
    
    fprintf('Displaying....');
    
%Adjust the color values and the colormap
    cmap = cmapstruct.cmap;
    grey = cmapstruct.basecol;        
    ixg2 = cmapstruct.ixg2;
    ixg1 = cmapstruct.ixg1;
    cmin = cmapstruct.cmin;
    cmax = cmapstruct.cmax;
    
    cmapL = length(cmap);
    
    if cmapstruct.enablecolormap,
        if cmapstruct.fading,
            ixL = ixg2 - ixg1 + 1;
            ixLm = floor(ixL/2);
            highmult = zeros(ixL, 1);
            lowmult = zeros(ixL, 1);
            highmult(1 : ixLm) = (ixLm - 1: -1 : 0) / ixLm;
            lowmult(ixLm + 1 : ixL) = (0 : 1 : (ixL - ixLm) - 1) / (ixL - ixLm);
            centermult = 1 - highmult - lowmult;
            li = 1; hi = ixL;
            
            ixbrainc = (ixg2 + ixg1) / 2; %the basecol            
            if ixbrainc < 1, ixbrainc = 1; end
            if ixbrainc > cmapL, ixbrainc = cmapL; end
            
            if ixg1 < 1, hi = hi + ixg1 - 1; ixg1 = 1; end
            if ixg2 > cmapL, li = ixg2 - cmapL + 1; ixg2 = cmapL; end
            cpart = cmap(ixg2: -1 : ixg1, :);
            greyM = ones(hi - li + 1, 1) * grey;
            lowmultM = lowmult(li : hi) * ones(1, 3);
            highmultM = highmult(li : hi) * ones(1, 3);
            centermultM = centermult(li : hi) * ones(1, 3);    
            cpart2 = cpart .* highmultM + cpart .* lowmultM + greyM .* centermultM;
            cmap(ixg2 : -1 : ixg1, :) = cpart2;
            CindexedNIx = ((C - cmin) / (cmax - cmin) * cmapL) + 1;
            %adjust the index range so that it matches colorbar
            nic = find(CindexedNIx < 1);
            CindexedNIx(nic) = 1;
            nic = find(CindexedNIx > cmapL);
            CindexedNIx(nic) = cmapL;
            Cindexed(actvert) = CindexedNIx; %the values were computed for activated vertices only
        else
            cmap(1, :) = grey;
            %the 2 in the following overcomes the grey at 1:
            CindexedNIx = ((C - cmin) / (cmax - cmin) * cmapL) + 2;
            %adjust the index range so that it matches colorbar
            nic = find(CindexedNIx < 2);
            CindexedNIx(nic) = 2;
            nic = find(CindexedNIx > cmapL);
            CindexedNIx(nic) = cmapL;
            
            Cindexed(actvert) = CindexedNIx; %the values were computed for activated vertices only
            ixbrainc = 1; %the basecol
        end
            
        colormap(cmap);
        %handles.cmap = cmap;
        if cmapstruct.enablecolorbar,
            caxis([cmin, cmax]);
            cBar=colorbar('location','West');
            set(cBar,'YAxisLocation','left');
            set(cBar,'FontSize',6);
%              cBarPos=get(cBar,'Position');
%              set(cBar,'Position',cBarPos+[0.04 -0.01 -0.005 +0.02]);
        else
            cBar=[];
        end
    end

%spec = handles.specspec;
%Please specify viewstruct.what2view (see above in comments) to display the brain surface and/or the activations

%grey brain:
    I = strmatch('brain', viewstruct.what2view,'exact');
    if ~isempty(I),
        if ~exist('ixbrainc', 'var')
            disp('You are trying to display the brain but did not provide colormap (enablecolomap == false) information, setting to grey...');
            
            colormap('Bone');
            %handles.cmap = 'Bone';
            ixbrainc = 32;
        end
         II = strmatch('activations', viewstruct.what2view,'exact');
          if ~isempty(II),
              hold on;
               ha=trisurf(M.tri, M.vert(:, 1), M.vert(:, 2), M.vert(:, 3), 'FaceVertexCData', ixbrainc, 'CDataMapping', 'direct', 'linestyle', 'none','FaceAlpha',1);
               set(ha,'FaceLighting','phong','AmbientStrength',0.5);
             
          else
              if viewstruct.enablecortexcolor
                  
                  switch  viewstruct.cpm  %%% Cortical Parcellation methods,need to add handle here in GUI
                      case 1
                          Color_Mat=load([std_brain_model_dir,'MNI/MATLAB/Cortex_Center_aparc.mat']);
                      case 2
                          Color_Mat=load([std_brain_model_dir,'MNI/MATLAB/Cortex_Center_aparc2009.mat']);
                      case 3
                          Color_Mat=load([std_brain_model_dir,'MNI/MATLAB/Cortex_Center_DKT40.mat']);
                  end
%                   Color_Mat=load('Cortex_Center.mat');
                  Color_Cindex=repmat((cmapstruct.basecol+[0.1,0.1,0.1]),Mm,1);
                  spec='';
                  if ~isempty(spec)
                      Color_Cindex(Color_Mat.M(2).Cortex_Color_spec(:,1),:)=Color_Mat.M(2).Cortex_Color_spec(:,2:4); 
                      Color_Cindex(Color_Mat.M(1).Cortex_Color_spec(:,1)+size(Color_Mat.M(2).vert,1),:)=Color_Mat.M(1).Cortex_Color_spec(:,2:4);
                  else
                      Color_Cindex(Color_Mat.M(2).Cortex_Color(:,1),:)=Color_Mat.M(2).Cortex_Color(:,2:4);
                      Color_Cindex(Color_Mat.M(1).Cortex_Color(:,1)+size(Color_Mat.M(2).vert,1),:)=Color_Mat.M(1).Cortex_Color(:,2:4);
				  end
%                   if subjstructs(1).electrodes(1)<0
%                   Color_Cindex(Color_Mat.M(2).Cortex_Color(:,1),:)=Color_Mat.M(2).Cortex_Color(:,2:4);
%                   else
%                   Color_Cindex(Color_Mat.M(1).Cortex_Color(:,1)+size(Color_Mat.M(2).vert,1),:)=Color_Mat.M(1).Cortex_Color(:,2:4);
%                   end
                  hh=trisurf(M.tri, M.vert(:, 1), M.vert(:, 2), M.vert(:, 3),  'FaceVertexCData',  Color_Cindex, 'FaceColor', 'interp', 'CDataMapping', 'direct', 'linestyle', 'none','FaceAlpha',0.2);%0.1
                  set(hh,'FaceLighting','phong','AmbientStrength',0.5);
              else
                  if viewstruct.enablewhitematter
                      hold on;
                      load('Whitematter.mat');%% white matter surface
                      hw=trisurf(white.tri, white.vert(:, 1), white.vert(:, 2), white.vert(:, 3), 'FaceVertexCData', ixbrainc, 'CDataMapping', 'direct', 'linestyle', 'none','FaceAlpha',0.2);
                      set(hw,'FaceLighting','phong','AmbientStrength',0.5);
                  else
                      
                      hc=trisurf(M.tri, M.vert(:, 1), M.vert(:, 2), M.vert(:, 3), 'FaceVertexCData', ixbrainc, 'CDataMapping', 'direct', 'linestyle', 'none','FaceAlpha',0.1);%0.1
                      set(hc,'FaceLighting','phong','AmbientStrength',0.5);
                  end
              end             
          end          
    end
    
%activations on it:
    I = strmatch('activations', viewstruct.what2view,'exact');
    if ~isempty(I),
        hold on;
        ha=trisurf(M.tri, M.vert(:, 1), M.vert(:, 2), M.vert(:, 3), 'FaceVertexCData', Cindexed, 'FaceColor', 'interp', 'CDataMapping', 'direct', 'linestyle', 'none','FaceAlpha',1);
        set(ha,'FaceLighting','phong','AmbientStrength',0.5);
    end

    if viewstruct.enableaxis,
        axis equal;        
    else
        axis equal off;
    end
    view(viewstruct.viewvect);
    material(viewstruct.material);
    if viewstruct.enablelight,
        light('Position', viewstruct.lightpos, 'Style', 'infinite');
    end
%      ll=light;
%     lighting(viewstruct.lightingtype);
    
%Please specify viewstruct.what2view (see above in comments) if you want to display the electrodes

    set(gcf,'color','w');
    hold off;
end