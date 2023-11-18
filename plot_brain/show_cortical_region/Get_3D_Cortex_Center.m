% generate the cortex color code in M(t).Cortex_Color(n*4 size) as in below:
%   [cortex_index R G B]
%   [cortex_index R G B]
%   [cortex_index R G B]
%   [cortex_index R G B]
% and save this cortex_color code in the same place as other three
% parameter files
function Get_3D_Cortex_Center(WholeCortex_file, rh_annot_file, lh_annot_file)
tmp_dir=fileparts(which(WholeCortex_file)); % WholeCortex_file contains folders
if isempty(tmp_dir) % WholeCortex_file with no folders
    tmp_dir=fileparts(WholeCortex_file);
end
%M=load('WholeCortex.mat');
M=load(WholeCortex_file);
L=M.leftcortex;
LV=length(L.vert);
R=M.rightcortex;
RV=length(R.vert);
M=struct;
for t=1:2
    if t==1
        %[AV,BV,CV]=read_annotation('rh.aparc.annot');
        [AV,BV,CV]=read_annotation(rh_annot_file);
        M(t).vert=R.vert;
        M(t).tri=R.tri; % Right hemisephera put forward
        M(t).numEntries=CV.numEntries;
        M(t).struct_names=CV.struct_names;
        M(t).table=CV.table;
    else
        %[AV,BV,CV]=read_annotation('lh.aparc.annot');
        [AV,BV,CV]=read_annotation(lh_annot_file);
        M(t).vert=L.vert;
        M(t).tri=L.tri;
        M(t).numEntries=CV.numEntries;
        M(t).struct_names=CV.struct_names;
        M(t).table=CV.table;
    end

%%
    index=cell(CV.numEntries,1);
    %Cindexed=zeros(length(M(t).vert),3);
    Cortex_Index=[];
    Color_Index=[];
    M(t).Center=zeros(CV.numEntries,3);
    for  i=1:CV.numEntries
       index{i}=find(BV==CV.table(i,end));
        while isempty(index{i})
            M(t).Center(i,:)=[nan,nan,nan];
            i=i+1;
            index{i}=find(BV==CV.table(i,end)); 
        end
       M(t).Center(i,:)=mean(M(t).vert(index{i},:)); 
       Cindexed=repmat((CV.table(i,1:3)),length(index{i}),1)/255;
       Cortex_Index=[Cortex_Index;index{i}];
       Color_Index=[Color_Index;Cindexed];

    end
    
    % remove 1:20 regions. find the index from CV.struct_names;
    plot_index=[30];
    remove_index=setdiff(1:CV.numEntries,plot_index);
    for  i=remove_index
       index{i}=find(BV==CV.table(i,end));
        while isempty(index{i})
            M(t).Center(i,:)=[nan,nan,nan];
            i=i+1;
            index{i}=find(BV==CV.table(i,end)); 
        end
       M(t).Center(i,:)=mean(M(t).vert(index{i},:)); 
       Cindexed=repmat([0.97,0.97,0.97],length(index{i}),1);
       Cortex_Index=[Cortex_Index;index{i}];
       Color_Index=[Color_Index;Cindexed];

    end
    
    Cortex_Color=[Cortex_Index,Color_Index];
    M(t).Cortex_Color=Cortex_Color;

end
save(strcat(tmp_dir,'/Cortex_Center.mat'),'M');

end