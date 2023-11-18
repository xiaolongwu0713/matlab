clear all;clc;
%PsychDebugWindowConfiguration(1, 0.5)%transparent screen
%%-------uncomment below if SYNCHRONIZATION FAILURE ----------------
Screen('Preference', 'SkipSyncTests', 1);

%%------- -------------------------- ------------------------------------------------------------------%% 
%  Collect subject's information.
%Sub.inf=inputdlg({'Name','Age','Gender','Left-handed or Right-handed','Repeting times(1 or 5)'},'Subject Information',1,{'Name()','Age','Gender','Right or Left','5'});
Sub.inf=inputdlg({'Repeting times(1 or 5)'},'Subject Information',1,{'5'});
% parallel com
portPP = hex2dec('0378');  
config_io;     
global cogent;
if( cogent.io.status ~= 0 )
   error('inp/outp installation failed');
end
outp(portPP, 0);


whichScreen = max(Screen('Screens'));
white = WhiteIndex(whichScreen);
black = BlackIndex(whichScreen);
[w,rect]=Screen('OpenWindow',whichScreen, black);
%[w,rect] = Screen('OpenWindow', whichScreen, black, [0,0,500,500]);
slack=Screen('GetFlipInterval',w)/2;
[xc,yc]=RectCenter(rect);
%HideCursor; % cursor clicking no respones anyway


%task1=[33292 22836 45 24819]; %"舌头-想";
%task2=[33292 22836 45 21160]; %"舌头-动";
%task3=[24038 25163 45 24819]; %"左手-想";
%task4=[24038 25163 45 21160]; %"左手-动";
%task5=[21491 25163 45 24819]; %"右手-想";
%task6=[21491 25163 45 21160]; %"右手-动";
%task7=[24038 33050 45 24819]; %"左脚-想";
%task8=[24038 33050 45 21160]; %"左脚-动";
%task9=[21491 33050 45 24819]; %"右脚-想";
%task10=[21491 33050 45 21160]; %"右脚-动";

%task1='舌头-想';
%task2='舌头-动';
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
rest_prompt='休息';
%word_width=RectWidth(Screen('TextBounds',w, task1)); %not work properly with chinese
word_width=400;
word_height=20;


%  Remind subject to prepare.
text='Press a Key When You Are Ready!';
Screen('TextSize', w ,60);
width=RectWidth(Screen('TextBounds',w,text));
Screen('Drawtext',w,text,xc-width/2,yc,[255 255 255]);
Screen('Flip',w);
KbWait;

class_number=length(pattern);
repeattimes=str2double(Sub.inf(end)); % repete 5 *(10task*10second)=500s=8min
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

% ---------------begin session marker-----------------
outp(portPP,100);
pause(0.004);
outp(portPP, 0);

Priority(2);
for i=1:length(marker)
    
    outp(portPP,50);
    pause(0.004);
    outp(portPP, 0);

    outp(portPP,marker(i));
    pause(0.004);
    outp(portPP, 0);
    
    
    % rest 
    Screen('Drawtext',w,double(rest_prompt),xc-word_width/2,yc-word_height/2,[255 255 255]);
    rest_cue=Screen('Flip',w);
    WaitSecs(rest_duration); % rest
    
    
    % task cue
    %Screen('Drawtext',w,unicodetext,xc-cue_width/2,yc,[255 255 255]);
    Screen('Drawtext',w,double(cell2mat(pattern(1,marker(i)))),xc-word_width/2,yc-word_height/2,[255 255 255]);
    task_cue=Screen('Flip',w,rest_cue+rest_duration-slack);
    
    % task cue disappear
    if task_cue_disappear
        Screen('FillRect',w,[0 0 0]);
        cue_disappear=Screen('Flip',w,task_cue+cue_duration-slack);
    else
        cue_disappear=task_cue;
        WaitSecs(cue_duration);
    end
    
    % delay: random or not
    if delay_random_or_fix
        delay = (radmon_delay(2)-radmon_delay(1)).*rand() + radmon_delay(1);
    else
        delay=fix_delay;
    end
    WaitSecs(delay);
    
    % task start with a green circle, and last for task_duration s
    Screen('FillOval',w,[0 255 0],[xc-100,yc-100,xc+100,yc+100]);
    task_onset=Screen('Flip',w, cue_disappear+delay-slack);
    WaitSecs(task_duration);
    
    % task begin: black
    %Screen('DrawLine',w,[255 255 255],xc-300,yc,xc+300,yc,5);
    %Screen('DrawLine',w,[255 255 255],xc,yc-300 ,xc,yc+300,5);
    %show_cross=Screen('Flip',w,cue_onset+cue_duration-slack);
    %WaitSecs(task_duration);
    
    %ending trial
    %cue_onset=Screen('Flip',w);
    %break;

end
Priority(0);

foldername=['result/',datestr(now,'yyyymmddHHMM')];
mkdir(foldername);
filename=strcat(foldername,'/inf.mat');
save(filename,'Sub','marker');

Screen('CloseAll');
ShowCursor;

%questdlg('Experiment Finished!');

    
    
    
