clear all;clc;
%%--------------------------------- ------------------------------------------------------------------%% 
%  Collect subject's information.
Sub.inf=inputdlg({'Name','Age','Gender','Left-handed or Right-handed Experiments','Paradigm Types','Start Time'},...
                     'Subject Information',1,{'Name()','Age','Gender','Right or Left','ParadigmTypes','HH:MM:SS'});
Sub.Name=Sub.inf(1);
Sub.StartTime=Sub.inf(6);
%Sub=cell2struct(Sub.inf,{'Name'},1);

%%---------------------------------------------------------------------------------------------------%%
whichScreen = max(Screen('Screens'));
white = WhiteIndex(whichScreen);
black = BlackIndex(whichScreen);
%[w,rect]=Screen('OpenWindow',whichScreen);
[w,rect] = Screen('OpenWindow', whichScreen, black, [100,100,1000,1000]);
slack=Screen('GetFlipInterval',w)/2;
[xc,yc]=RectCenter(rect);
HideCursor;
%Screen('Screens');
%%---------------------------------------------------------------------------------------------------%%
% Preloading functions and variables through a pseudo-trial.
% Screen('DrawLine',w,[255 255 255],xc-300,yc,xc+300,yc,10);
% Screen('FillRect',w,[0 0 0]);
% Screen('FillOval',w,[0 255 0],[xc-100,yc-100,xc+100,yc+100]);
% % N1_parametersSetting;   %??
% WaitSecs;
% Screen('FillRect',w,[0 0 0]);
% Screen('Flip',w);
%%---------------------------------------------------------------------------------------------------%%
% imageplus=imread('D:/plus.jpg');
% imageplus_text=Screen('MakeTexture',w,imageplus);

image1=imread('./MI1','png');
image2=imread('./MI2','png');
image3=imread('./MI3','png');
image4=imread('./MI4','png');

image_text1=Screen('MakeTexture',w,image1);
image_text2=Screen('MakeTexture',w,image2);
image_text3=Screen('MakeTexture',w,image3);
image_text4=Screen('MakeTexture',w,image4);

pattern=[image_text1 image_text2 image_text3 image_text4];

%  Remind subject to prepare.
text='Press a Key When You Are Ready!';
Screen('TextSize', w ,60);
width=RectWidth(Screen('TextBounds',w,text));
Screen('Drawtext',w,text,xc-width/2,yc,[255 255 255]);
Screen('Flip',w);
KbWait;


repeattimes=1;
patternlist=1:length(pattern);
patternlist=repmat(patternlist,1,repeattimes);
randomlist=Shuffle(patternlist);

% --->cross-->cue-->black(image task)--
cross_duration=1;
cue_duration=1;
task_duration=1;

Priority(2);
for i=1:length(randomlist) 

%     Screen('DrawTexture',w,imageplus_text);

%  Resting state, showing cross.
    Screen('DrawLine',w,[255 255 255],xc-300,yc,xc+300,yc,5);
    Screen('DrawLine',w,[255 255 255],xc,yc-300 ,xc,yc+300,5);
%     tic;
    show_cross=Screen('Flip',w);
%     WaitSecs(2.5);
    
%  Visual cues appear randomly, in which moti   on execution is framed, and motion imagination is not framed.  
    Screen('DrawTexture',w,pattern(randomlist(i)));

% add a squre frame
%     if randomlist(i)==4||randomlist(i)==5||randomlist(i)==6
%         Screen('DrawLine',w,[255 255 255],xc-350,yc+350,xc+350,yc+350,6);
%         Screen('DrawLine',w,[255 255 255],xc-350,yc-350 ,xc+350,yc-350,6);
%         Screen('DrawLine',w,[255 255 255],xc-350,yc+350,xc-350,yc-350,6);
%         Screen('DrawLine',w,[255 255 255],xc+350,yc+350 ,xc+350,yc-350,6);
%     end
    
%%---------------------------------------------------------------------------------------------------%%   
%     obj = serial('COM?');       % 
%     fopen(obj);                 %
%     
%     if randomlist(i)==1
%         fwrite(obj,'xxx'); 
%     elseif randomlist(i)==2
%         fwrite(obj,'xxx'); 
%     elseif randomlist(i)==3
%         fwrite(obj,'xxx'); 
%     elseif randomlist(i)==4
%         fwrite(obj,'xxx'); 
%     elseif randomlist(i)==5
%         fwrite(obj,'xxx'); 
%     elseif randomlist(i)==6
%         fwrite(obj,'xxx');
%     end
%%---------------------------------------------------------------------------------------------------%%   
    show_cue=Screen('Flip',w,show_cross+cross_duration-slack);
%     WaitSecs(0.4);

%  500ms~1500ms random delay.
    %r=0.5+rand;
    %Screen('FillRect',w,[0 0 0]);
    %cue_disappear=Screen('Flip',w,show_cue+cue_duration-slack);
%     WaitSecs(r);
    
%  Green Point Tip: Start MI/ME.
%     Screen('FillOval',w,[0 255 0],[xc-100,yc-100,xc+100,yc+100]);
%     tstart_onset=Screen('Flip',w, twait_onset+r-slack);
    
    % begin MI one cue disappear
    Screen('FillRect',w,[0 0 0]);
    start_to_image=Screen('Flip',w,show_cue+cue_duration-slack);
    WaitSecs(task_duration);
%     disp(['toc计算第',num2str(i),'次循环运行时间：',num2str(toc-r)]);
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

    
    
    
