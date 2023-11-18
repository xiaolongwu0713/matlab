clear all;clc;
%PsychDebugWindowConfiguration(1, 0.5)%transparent screen
%%-------uncomment below if SYNCHRONIZATION FAILURE ----------------
Screen('Preference', 'SkipSyncTests', 1);

%%------- -------------------------- ------------------------------------------------------------------%% 
%  Collect subject's information.
%Sub.inf=inputdlg({'Name','Age','Gender','Left-handed or Right-handed','Repeting times(1 or 5)'},'Subject Information',1,{'Name()','Age','Gender','Right or Left','5'});
%Sub.inf=inputdlg({'Test trials'},'Subject Information',1,{'0'});
Sub.inf=inputdlg({'Tyep: 0-test,1-actural run','Test trials','Loop times'},'Subject Information',1,{'0','0','5'});

%Tyep: 0-test,1-actural run
type=str2double(Sub.inf(1));
test_trials=str2double(Sub.inf(2));
%loop cycles in actual run
repeattimes=str2double(Sub.inf(3));% loop 5 times=5*8 tasks=40 tasks

if isempty(Sub.inf)
    error("Quite program")
else 
    if type==0
        if test_trials == 0
            error("Input test trial number please.");
        else
            tobreak=1;
        end
    elseif type==1
        tobreak=0;
    end
end



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
class_number=length(pattern);
rest_prompt='休息';
%word_width=RectWidth(Screen('TextBounds',w, task1)); %not work properly with chinese
word_width=200;
word_height=20;


%  Remind subject to prepare.
text='Press a Key When You Are Ready!';
Screen('TextSize', w ,60);
width=RectWidth(Screen('TextBounds',w,text));
Screen('Drawtext',w,text,xc-width/2,yc,[255 255 255]);
Screen('Flip',w);
KbWait;
