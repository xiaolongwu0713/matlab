type='SEEG'; % ECoG/SEEG
id=2;
datetime='20231201';
folder=strcat('D:\data\speech_Southmead\raw\',type,int2str(id),'_',datetime);
filename=strcat(folder,'\matlab\inf.mat');
aa=load(filename);
prompts=cellstr(aa.prompt_shown);
files=cellstr(aa.read_files);

filename3=strcat(folder,'\matlab\inf.txt');
%filename3='D:\data\speech_Southmead\raw\SEEG1\matlab\inf.txt';
fileID = fopen(filename3,'w');
for i=1:size(prompts,2)
    a_cell=prompts(i);
    a_str=char(a_cell);
    fprintf(fileID,'%s\n',a_str);
end
fclose(fileID);


