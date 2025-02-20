%%
[a,computer]=system('hostname');

if strcmp(strip(computer),'longsMac')
    data_dir='/Volumes/Samsung_T5/data/ruijin/gonogo/';
    eeglab_path='/Users/long/Documents/BCI/matlab_plugin/eeglab2021.1';
    addpath(eeglab_path);
elseif strcmp(strip(computer),'workstation')
    data_dir='H:/Long/data/ruijin/gonogo/';
    eeglab_path=['C:/Users/wuxiaolong/Desktop/BCI/eeglab2021.1'];
    addpath(eeglab_path);
end

pn = 5;
file=strcat(data_dir,'preprocessing/P',num2str(pn),'/preprocessing/preprocessingv2.mat');

load(file);

data1=DATA{1,1};
data2=DATA{1,2};
trigger1=Trigger{1,1};
trigger2=Trigger{1,2};
trigger2(:,1)=trigger2(:,1)+size(data1,1);

data=cat(1,data1,data2);
trigger=cat(1,trigger1,trigger2); % latency, type, description_code(reaction time)

eeglab;
EEG = pop_importdata('dataformat','matlab','nbchan',0,'data',data','srate',Fs,'pnts',0,'xmin',0);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'setname','raw','gui','off');
EEG = pop_importevent( EEG, 'event',trigger,'fields',{'latency','type','duration'},'timeunit',NaN);
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
EEG = eeg_checkset( EEG );
%eeglab redraw;

% dataset 2: epoch11
EEG = pop_epoch( ALLEEG(1), {  '11'  }, [0  3], 'newname', 'epoch11', 'epochinfo', 'yes');
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'gui','off');
% dataset 3
EEG = pop_epoch( ALLEEG(1), {  '12'  }, [0  3], 'newname', 'epoch12', 'epochinfo', 'yes');
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'gui','off');
% dataset 4
%EEG = pop_epoch( ALLEEG(1), {  '21'  }, [-1  4], 'newname', 'epoch21', 'epochinfo', 'yes');
%[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'gui','off');
% dataset 5
%EEG = pop_epoch( ALLEEG(1), {  '22'  }, [-1  4], 'newname', 'epoch22', 'epochinfo', 'yes');
%[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'gui','off');
eeglab redraw;

%%
% call pac analysis program on event 11
%[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 3,'retrieve',2,'study',0); % working on epoch11
%eeglab redraw;
pac_eegbook1;
%%
% call pac analysis program on event 12
%[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2,'retrieve',3,'study',0); % working on epoch11
%eeglab redraw;
pac_eegbook1;

%%
% low frequency: 4-15, high frequency: 80-150;
%EEG = pop_pac(EEG,'Channels',[4 15],[80 150],[1,1,1,1,1],[1,2,3,4,5],'method','mvlmi','nboot',200,'alpha',[],'nfreqs1',4,'nfreqs2',20,'freqscale','log','bonfcorr',0);


%63**63 is waaaaaaaay too huge data
% for chni = [1:63]
%     chns=[1:63];
%     tmp = pop_pac(EEG,'Channels',[4 15],[80 150],repmat(chni,1,63),[1:63],'method','mvlmi','nboot',200,'alpha',[],'nfreqs1',4,'nfreqs2',20,'freqscale','log','bonfcorr',0);
%     param=tmp.etc.eegpac(1).params;
%     %A{chni}={EEG.etc.eegpac.mvlmi};
%     for ci =[1:63] 
%         field=strcat('c',num2str(chni),'_',num2str(ci));
%         result.(field)=tmp.etc.eegpac(ci).mvlmi.pacval;
%     end
%     if chni == 'ahaha'
%         fprintf('\n Pausing...  Press any key to resume.');
%         pause
%         fprintf('\n Resume running...');
%     end
%     
% end
%save('pac_result','result','param');
%a=EEG.etc.eegpac.mvlmi{1}.pacval;
%[a,b,c,d,e]=EEG.etc.eegpac.mvlmi;

ax=axes;
for i =1:length(fieldnames(result))
    chn=i
    chnn=strcat('c',num2str(chn),'_',num2str(chn),'_','10');
    image(ax,result.(chnn));
    %imagesc(ax,result.(chnn));%选取一个phase的frequency画图。
    ax.YDir = 'normal';
    pause(1)
end
chn=47
chnn=strcat('c',num2str(chn),'_',num2str(chn),'_','10');
image(result.(chnn));
caxis([10,20])
ax=gca()
load('/Users/long/Documents/BCI/matlab_scripts/common/MyColormaps.mat','mycmap')
colormap(ax,jet)
caxis([0,4]);
colorbar;
xlabel('Time/s');ylabel('FrequEncy/Hz');
