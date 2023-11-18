%%
% Esc to terminate the program
% repeat=3: run 6 sessions;
% repeat=4: run 4 sessions;
%%


clear all;clc;
[ret, name] = system('hostname');
if strcmp(strip(name),'LongsMac') 
    win=false;
else
    win=true;
end
%PsychDebugWindowConfiguration(1, 0.5)%transparent screen
%%-------uncomment below if SYNCHRONIZATION FAILURE ----------------
Screen('Preference', 'SkipSyncTests', 1);
%Screen('Preference', 'SkipSyncTests', 0);  %set this for maximum accuracy and reliability.

%%------- -------------------------- ------------------------------------------------------------------%% 
%  Collect subject's information.
%Sub.inf=inputdlg({'Name','Age','Gender','Left-handed or Right-handed','Repeting times(1 or 5)'},'Subject Information',1,{'Name()','Age','Gender','Right or Left','5'});
%Sub.inf=inputdlg({'Test trials'},'Sub ject Information',1,{'0'});
Sub.inf=inputdlg({'Loop times'},'Subject Information',1,{'3'});


repeattimes=str2double(Sub.inf(1));% loop 3 times=3*8 tasks=24 tasks per session

if isempty(Sub.inf)
    error("Quite program")
end


whichScreen = max(Screen('Screens'));
white = WhiteIndex(whichScreen);
black = BlackIndex(whichScreen);
[w,rect]=Screen('OpenWindow',whichScreen, black);
%[w,rect] = Screen('OpenWindow', whichScreen, black, [0,0,500,500]);
slack=Screen('GetFlipInterval',w)/2;
[xc,yc]=RectCenter(rect); 
%HideCursor; % cursor clicking no respones anyway

task1='左手-想';
task2='左手-动';
task3='右手-想';
task4='右手-动';
task5='左脚-想';
task6='左脚-动';
task7='右脚-想';
task8='右脚-动';
Screen('TextFont',w,'Microsoft YaHei');
pattern={task1 task2 task3 task4 task5 task6 task7 task8};
class_number=length(pattern);
rest_prompt='休息';
%word_width=RectWidth(Screen('TextBounds',w, task1)); %not work properly with chinese
word_width=200;
word_height=20;

 % % marker part
 marker_length=0.1;
if win
    ioObj = io64;
    status = io64(ioObj);
    if status == 0
        disp('inpoutx64.dll successfully installed.')
    else
        error('inpoutx64.dll installation failed.')
    end
    address = hex2dec('DEFC');
    
    % two consecutive pulse representing program start
    io64(ioObj,address,0);
    WaitSecs(marker_length);
    io64(ioObj,address,20);
    WaitSecs(marker_length);
    io64(ioObj,address,0);
    WaitSecs(marker_length);
    io64(ioObj,address,20);
    WaitSecs(marker_length);
    io64(ioObj,address,0);
end

%  Remind subject to prepare.
text='Press a Key When You Are Ready!';
Screen('TextSize', w ,60);
width=RectWidth(Screen('TextBounds',w,text));
Screen('Drawtext',w,text,xc-width/2,yc,[255 255 255]);
Screen('Flip',w);
KbWait;


patterncode=1:length(pattern);
patterncode=repmat(patterncode,1,repeattimes);
marker=patterncode(randperm(length(patterncode))); % makers

% --->rest cue for rest_duration-->task_cue for task_duration-->
% cue disappear(black screen) or not for random time-->task_begin_cue for task_duration--
task_cue_disappear=0; % cue disappear(1) or not(0)
delay_random_or_fix=0; % delay random period=1, delay fix period=0;
rest_duration=3;
cue_duration=2; % which task
radmon_delay=[1,2]; % mean delay=2s
fix_delay=1;
task_duration=4;

KbName('UnifyKeyNames');
escapeKey = KbName('ESCAPE');
deviceIndex=[];
spaceKey = KbName('SPACE');
KbQueueCreate(deviceIndex);
KbQueueStart(deviceIndex);
    
Priority(2);
marker_shown=[];
for i=1:length(marker)
    marker_tmp=marker(i);
    marker_shown=[marker_shown marker_tmp];
    
    % rest 
    Screen('Drawtext',w,double(rest_prompt),xc-word_width/2,yc-word_height/2,[255 255 255]);
    Screen('Flip',w);
    WaitSecs(rest_duration); % rest
    
    % task cue
    %Screen('Drawtext',w,unicodetext,xc-cue_width/2,yc,[255 255 255]);
    Screen('Drawtext',w,double(cell2mat(pattern(1,marker(i)))),xc-word_width/2,yc-word_height/2,[255 255 255]);
    Screen('Flip',w);
    WaitSecs(cue_duration);
     
    
    % task start with a green circle, and last for task_duration s
    Screen('FillOval',w,[0 255 0],[xc-100,yc-100,xc+100,yc+100]);
    Screen('Flip',w);
    % task start marker
    if win
        io64(ioObj,address,marker(i));
        WaitSecs(marker_length);
        io64(ioObj,address,0);
    end
    WaitSecs(task_duration);
    
    % task begin: black
    %Screen('DrawLine',w,[255 255 255],xc-300,yc,xc+300,yc,5);
    %Screen('DrawLine',w,[255 255 255],xc,yc-300 ,xc,yc+300,5);
    %show_cross=Screen('Flip',w,cue_onset+cue_duration-slack);
    %WaitSecs(task_duration);
    
    %ending trial
    %cue_onset=Screen('Flip',w);
    %break;
    [pressed, keyCode]=KbQueueCheck(deviceIndex);
    pressedKeys = KbName(keyCode);
    if strcmp(pressedKeys,'ESCAPE') % terminate the whole process
        fprintf('Terminate the program with ESCAPE key');
        break;
    end
            
end
KbQueueStop(deviceIndex);
KbQueueRelease(deviceIndex);

Priority(0);

if not (i<length(marker) && strcmp(pressedKeys,'ESCAPE'))
    foldername=['result/',datestr(now,'yyyymmddHHMM')];
    mkdir(foldername);
    filename=strcat(foldername,'/inf.mat');
    save(filename,'Sub','marker_shown');
end  

Screen('CloseAll');
ShowCursor;

    
    
    
