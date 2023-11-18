%% plot the brain and electrode using output from img_pipe
% This is the channel selection result using the open dataset called
% "SingleWordProductionDutch" from paper "Dataset of Speech Production in
% intracranial Electroencephalography"
%%
for sub={'01','02','03','04','05','06','07','08','09','10'}
%sub='10';
sub=char(sub);
cortex_L=load(['sub-',sub,'/sub-',sub,'_lh_pial.mat']);
cortex_R=load(['sub-',sub,'/sub-',sub,'_rh_pial.mat']);
%viewBrain(cortex, Etala, {'brain'}, transp, colix, view_vect);
colix=32;
viewBrain(cortex_L.cortex, 0, {'brain'}, 0.2, colix, 'front');
viewBrain(cortex_R.cortex, 0, {'brain'}, 0.2, colix, 'front');

b=readcell(['sub-',sub,'/sub-',sub,'_task-wordProduction_space-ACPC_electrodes.tsv'],'FileType','text');
ele=b(2:end,2:4);
plotBalls(cell2mat(ele), [0 1 0], 0.7); % radius: 0.8

%%
%sids={'1','2','3','4','5','6','7','8','9','10'};
selected_channels={
[56,49,6,91,79,47,84,46,67,26,86,58,55,22,51]
[108,101,116,26,57,84,15,48,81,79,89,119,120,87,27]
[48,47,87,97,63,113,9,111,106,41,70,99,42,53,45]
[30,20,36,16,7,108,112,102,54,100,0,4,84,97,86]
[47,13,24,44,40,37,54,45,31,39,58,11,28,41,38]
[30,43,35,47,52,98,61,22,48,102,50,8,74,51,100]
[8,100,51,31,74,85,50,52,101,25,94,11,0,102,30]
[47,7,31,3,13,26,0,29,22,46,9,18,35,49,12]
[89,26,116,9,90,81,112,108,98,80,109,39,110,114,87]
[33,37,61,55,39,112,0,35,57,38,56,58,97,60,53]
};
%selected_ele=cell2mat(selected_channels(str2num(sub)));
%show_ele=10;
%selected_ele=selected_ele(1:show_ele)+1; % index start from 1;
sizes=[1.2,1.4,1.6,1.8,2.0,2.2,2.4,2.6,2.8,3.0,3.2,3.4,3.6,3.8,4.0];
%sizes=[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1].*4;
selected_files=readcell(['sub-',sub,'/sub-',sub,'_locations.txt'],'FileType','text');
selected_ele=selected_files(:,2:4);
plotBalls(cell2mat(selected_ele), [1 0 0], sizes); % radius: 0.8

axis equal
saveas(gcf,['sub-',sub,'/plot.fig']);
clf

end

openfig('/Users/xiaowu/My Drive/matlab/plot_brain/speech_Dutch/sub-10/plot.fig')
