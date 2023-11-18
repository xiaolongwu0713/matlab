clear all;clc;

iti = 3;
cueTime = 3;
randelay = 0.3;
reactionTime = 3;
feedbackTime = 0.5;



isTriggerCOM = false;
isParallelPort = true;
if isTriggerCOM
    triggerBoxCOM = TriggerBox();
end 
if isParallelPort 
    portPP = hex2dec('0378');  
    config_io;
    global cogent;
    if( cogent.io.status ~= 0 )
       error('inp/outp installation failed');
    end
    outp(portPP, 0);
end


KbName('UnifyKeyNames');
Screen('Preference','SkipSyncTests',1);

%%---------------------------------------------------------------------------------------------------%% 
%  Collect subject's information.
Sub.inf=inputdlg({'Name','Age','Gender','Left-handed or Right-handed Experiments','Paradigm Types'},...
                     'Subject Information',1,{'Name()','Age','Gender','Right or Left','ParadigmTypes'});
Sub.Name=Sub.inf(1);
Sub.StartTime=clock;
%Sub=cell2struct(Sub.inf,{'Name'},1);
%%---------------------------------------------------------------------------------------------------%%

[w,rect]=Screen('OpenWindow',0,[0 0 0]);
[xc,yc]=RectCenter(rect); 
slack=Screen('GetFlipInterval',w)/2;
HideCursor;
Screen('Screens');
%%---------------------------------------------------------------------------------------------------%%
rkey1=KbName('LeftArrow');
rkey2=KbName('UpArrow');
rkey3=KbName('RightArrow');
rkey4=KbName('DownArrow');
rkeyorder=[rkey1 rkey2 rkey3 rkey4];

image1=imread('E:/aud_vis/arrow_left','jpg');
image1 = imresize(image1,[500,500]);
image2=imread('E:/aud_vis/arrow_up','jpg');
image2 = imresize(image2,[500,500]);
image3=imread('E:/aud_vis/arrow_right','jpg');
image3 = imresize(image3,[500,500]);
image4=imread('E:/aud_vis/arrow_down','jpg');
image4 = imresize(image4,[500,500]);
image_text1=Screen('MakeTexture',w,image1);
image_text2=Screen('MakeTexture',w,image2);
image_text3=Screen('MakeTexture',w,image3);
image_text4=Screen('MakeTexture',w,image4);

arroworder=[image_text1 image_text2 image_text3 image_text4];


image5=imread('E:/aud_vis/pressst','png');
image6=imread('E:/aud_vis/notpressst','png');
image7=imread('E:/aud_vis/pressnd','png');
image8=imread('E:/aud_vis/notpressnd','png');
image_text5=Screen('MakeTexture',w,image5);
image_text6=Screen('MakeTexture',w,image6);
image_text7=Screen('MakeTexture',w,image7);
image_text8=Screen('MakeTexture',w,image8);
% text1='Go';
% text2='No Go';
textorder={image_text5,image_text6;image_text7,image_text8};

triggerIdx = [11 12;21 22];
ntrial = 60; % mod10=0
trialn=[ones(1,ntrial*0.7) ones(1,ntrial*0.3)+1];
trialrandom1=trialn(randperm(ntrial));
trialrandom2=trialn(randperm(ntrial));
accuracy=zeros(ntrial,2);
rtime=zeros(ntrial,2);

%  Remind subject to prepare.
text='Press a Key When You Are Ready!';
Screen('TextSize', w ,60);
width=RectWidth(Screen('TextBounds',w,text));
Screen('Drawtext',w,text,xc-width/2,yc,[255 255 255]);
Screen('Flip',w);
KbWait;

%%---------------------------------------------------------------------------------------------------%%(session开始打标)
if isTriggerCOM
    triggerBoxCOM.OutputEventData(100);
end
if isParallelPort
    outp(portPP,100);
    pause(0.004);
    outp(portPP, 0);
end

Priority(2);
for i=1:ntrial
 %检查所有按键都已经被释放   
    KeyIsDown=1;
    while KeyIsDown
         [KeyIsDown,~,~]=KbCheck;
         WaitSecs(0.001);
    end
 % 在屏幕上出现随机↑ →       
    Screen('FillOval',w,[0 255 0],[xc-50,yc-50,xc+50,yc+50]);
    arrowsel=randperm(4,2);
    Screen('DrawTexture',w,arroworder(arrowsel(1)));
%%---------------------------------------------------------------------------------------------------%%(目标呈现打标)
    subjst_onset=Screen('Flip',w); 
    Screen('DrawTexture',w,arroworder(arrowsel(2)));
%%---------------------------------------------------------------------------------------------------%%(目标呈现打标)
if isTriggerCOM
    triggerBoxCOM.OutputEventData(1);
end
if isParallelPort
    outp(portPP,1);
    pause(0.004);
    outp(portPP, 0);
end
subjnd_onset=Screen('Flip',w,subjst_onset+iti-slack);  %此处的3是第一个方向的显示时间

 
    Screen('FillRect',w,[0 0 0]);
if isTriggerCOM
    triggerBoxCOM.OutputEventData(2);
end
if isParallelPort
    outp(portPP,2);
    pause(0.004);
    outp(portPP, 0);
end  
    Screen('Flip',w,subjnd_onset+iti-slack);  %此处的3是第二个方向的显示时间
    WaitSecs(rand*0.3);  %0~300ms随机延时
    
    Screen('TextSize', w ,100);
%     width=RectWidth(Screen('TextBounds',w,textorder{trialrandom1(i)}));
    Screen('DrawTexture',w,textorder{1,trialrandom1(i)});
    
%%---------------------------------------------------------------------------------------------------%%(提示打标)
if isTriggerCOM
    triggerBoxCOM.OutputEventData(triggerIdx(1,trialrandom1(i)));
end
if isParallelPort
    outp(portPP,triggerIdx(1,trialrandom1(i)));
    pause(0.004);
    outp(portPP, 0);
end


    tipst_onset=Screen('Flip',w);
    WaitSecs(cueTime);  %此处的0.5是第一个提示的持续时间***0.5→3
    
    Screen('FillRect',w,[0 0 0]);
%%---------------------------------------------------------------------------------------------------%%(选择打标)
    Screen('Flip',w);

    keyisdown1=0;
    real_time=GetSecs;
    while ~keyisdown1  && (real_time- tipst_onset)<cueTime+reactionTime   %用 (real_time- tipst_onset)<2 来控制反应时限*** 2→3
        [keyisdown1,seconds1,keycode1]=KbCheck;
        real_time=GetSecs;
    end 
     if keyisdown1==1
        if isTriggerCOM
            triggerBoxCOM.OutputEventData(3);
        end
        if isParallelPort
            outp(portPP,3);
            pause(0.004);
            outp(portPP, 0);
        end 
        if keycode1(rkeyorder(arrowsel(1))) && trialrandom1(i)==1       
            rtime(i,1)=seconds1-tipst_onset-cueTime;
            accuracy(i,1)=1;
            feedback1='True';
        else
            rtime(i,1)=seconds1-tipst_onset-cueTime;
            feedback1='False';
        end
     else
        if isTriggerCOM
            triggerBoxCOM.OutputEventData(4);
        end
        if isParallelPort
            outp(portPP,4);
            pause(0.004);
            outp(portPP, 0);
        end
        if trialrandom1(i)==2
            rtime(i,1)= reactionTime;
            accuracy(i,1)=1;
            feedback1='True';
        else
            rtime(i,1)= reactionTime;
            feedback1='False';
        end
    end
    WaitSecs(0.3+0.01*rand); 
%     Screen('TextSize', w ,100);
%     Screen('FillRect',w,[0 0 0]);
%     Screen('Flip',w);
%     width=RectWidth(Screen('TextBounds',w,textorder{trialrandom2(i)}));
    Screen('DrawTexture',w,textorder{2,trialrandom2(i)});
%%---------------------------------------------------------------------------------------------------%%(提示打标)
if isTriggerCOM
    triggerBoxCOM.OutputEventData(triggerIdx(2,trialrandom2(i)));
end
if isParallelPort
    outp(portPP,triggerIdx(2,trialrandom2(i)));
    pause(0.004);
    outp(portPP, 0);
end

    tipnd_onset=Screen('Flip',w,tipst_onset+cueTime+ rtime(i,1)+0.5+rand*0.3-slack);    %两个移动指令之间的随机延时
    WaitSecs(cueTime);   %此处的0.5是第二个提示的持续时间*** 0.5→3
    
    Screen('FillRect',w,[0 0 0]);
%%---------------------------------------------------------------------------------------------------%%(选择打标)

    Screen('Flip',w);
    
    keyisdown2=0;
    real_time=GetSecs;
    while ~keyisdown2  && (real_time- tipnd_onset)<cueTime+reactionTime   %用 (real_time- tipst_onset)<2 来控制反应时限*** 2→3
        [keyisdown2,seconds2,keycode2]=KbCheck;
        real_time=GetSecs;
    end
    
    if keyisdown2==1
        if isTriggerCOM
            triggerBoxCOM.OutputEventData(5);
        end
        if isParallelPort
            outp(portPP,5);
            pause(0.004);
            outp(portPP, 0);
        end
        if keycode2(rkeyorder(arrowsel(2)))&& trialrandom2(i)==1
            
            rtime(i,2)=seconds2-tipnd_onset-cueTime;
            accuracy(i,2)=1;
            feedback2='True';
        else
            rtime(i,2)=seconds2-tipnd_onset-cueTime;
            feedback2='False';
        end
    else
        if isTriggerCOM
            triggerBoxCOM.OutputEventData(6);
        end
        if isParallelPort
            outp(portPP,6);
            pause(0.004);
            outp(portPP, 0);
        end
        if trialrandom2(i)==2
            rtime(i,2)= reactionTime;
            accuracy(i,2)=1;
            feedback2='True';
        else
            rtime(i,2)= reactionTime;
            feedback2='False';
        end
    end
    
%     Screen('FillRect',w,[0 0 0]);
%     Screen('Flip',w);
    text=strcat(feedback1,'\',feedback2);
    width=RectWidth(Screen('TextBounds',w,text));
    Screen('Drawtext',w,text,xc-width/2,yc,[255 255 255]);
%%---------------------------------------------------------------------------------------------------%%(结果呈现打标)
    Screen('Flip',w,tipnd_onset+cueTime+rtime(i,2)+0.5-slack);
    WaitSecs(feedbackTime);    %最后结果显示的持续时间
    
end
Priority(0);
%%---------------------------------------------------------------------------------------------------%%(session结束打标)
if isTriggerCOM
    triggerBoxCOM.OutputEventData(255);
end
if isParallelPort
    outp(portPP,255);
    pause(0.004);
    outp(portPP, 0);
end

Sub.EndTime=clock;
%%---------------------------------------------------------------------------------------------------%%
%  Record the end time of trial.
Sub.EndTime=datestr(now,13);
InfFileName=strcat('E:\Result\',Sub.Name,'_gonogo');
InfFileName=InfFileName{1};

%  Prevent overwriting generated files by forgetting to change information
%  at the beginning of the trial.
if exist(InfFileName,'dir')
    dig=isstrprop(InfFileName,'digit');
    if isempty(InfFileName(dig))
        InfFileName=strcat('E:\Result\',Sub.Name,'(',num2str(1),')','_gonogo');
        InfFileName=InfFileName{1};
    else
        InfFileName=strcat('E:\Result\',Sub.Name,'(',num2str(str2double(InfFileName(dig))+1),')','_gonogo');
        InfFileName=InfFileName{1};
    end
end

%Save information.
mkdir(InfFileName);
strname=strcat(InfFileName,'\inf.mat');
save(strname,'Sub','accuracy','rtime');
%%---------------------------------------------------------------------------------------------------%%


Screen('CloseAll');
ShowCursor;

questdlg('Experiment Finished!');

