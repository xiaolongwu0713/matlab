clear all;clc;
%%--------------------------------- ------------------------------------------------------------------%% 
%  Collect subject's information.
Sub.inf=inputdlg({'Name','Age','Gender','Left-handed or Right-handed Experiments','Paradigm Types','Start Time'},...
                     'Subject Information',1,{'Name()','Age','Gender','Right or Left','ParadigmTypes','HH:MM:SS'});
Sub.Name=Sub.inf(1);
Sub.StartTime=Sub.inf(6);
%Sub=cell2struct(Sub.inf,{'Name'},1);

whichScreen = max(Screen('Screens'));
white = WhiteIndex(whichScreen);
black = BlackIndex(whichScreen);
%[w,rect]=Screen('OpenWindow',whichScreen);
[w,rect] = Screen('OpenWindow', whichScreen, black, [0,0,500,500]);
slack=Screen('GetFlipInterval',w)/2;
[xc,yc]=RectCenter(rect);
%HideCursor;


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
task1='舌头-想';
task2='舌头-动';
task3='左手-想';
task4='左手-动';
task5='右手-想';
task6='右手-动';
task7='左脚-想';
task8='左脚-动';
task9='右脚-想';
task10='右脚-动';
Screen('TextFont',w,'Microsoft YaHei');
pattern2={task1 task2 task3 task4 task5 task6 task7 task8 task9 task10};
cue_width=RectWidth(Screen('TextBounds',w,'xxxxx'));


%  Remind subject to prepare.
text='Press a Key When You Are Ready!';
Screen('TextSize', w ,60);
width=RectWidth(Screen('TextBounds',w,text));
Screen('Drawtext',w,text,xc-width/2,yc,[255 255 255]);
Screen('Flip',w);
KbWait;


repeattimes=40;
patternlist=1:length(pattern2);
patternlist=repmat(patternlist,1,repeattimes);
randomlist=Shuffle(patternlist);

% --->rest-->cue-->cross(task)--
rest_duration=4;
cue_duration=1;
task_duration=5;

Priority(2);
for i=1:length(randomlist) 

    WaitSecs(rest_duration); % rest
    
    % words cue
    %Screen('Drawtext',w,unicodetext,xc-cue_width/2,yc,[255 255 255]);
    Screen('Drawtext',w,double(cell2mat(pattern2(1,randomlist(i)))),xc-cue_width/2,yc,[255 255 255]);
    cue_onset=Screen('Flip',w);
    
    % task begin: black
    Screen('DrawLine',w,[255 255 255],xc-300,yc,xc+300,yc,5);
    Screen('DrawLine',w,[255 255 255],xc,yc-300 ,xc,yc+300,5);
    show_cross=Screen('Flip',w,cue_onset+cue_duration-slack);
    WaitSecs(task_duration);
    
    %ending trial
    cue_onset=Screen('Flip',w);
    

end
Priority(0);

%  Record the end time of trial.
Sub.EndTime=datestr(now,13);
InfFileName=strcat('./result/',Sub.Name,'_visual');
InfFileName=InfFileName{1};

%Save information.
mkdir(InfFileName);
strname=strcat(InfFileName,'/inf.mat');
save(strname,'Sub');

Screen('CloseAll');
ShowCursor;

questdlg('Experiment Finished!');

    
    
    
