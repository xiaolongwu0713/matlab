%% This experiment test the recorded signals using a hand gesture task.
% Result: the pause(5) will not stop the recording capturing.

%% config computer
sca;    
close all;clear all;
[ret, device] = system('hostname');     
if strcmp(strip(device),'DESKTOP-FBDP919') | strcmp(strip(device),'Long')
    send_trigger=true;
else
    send_trigger=false;
end
prompt_shown={};
prompt_shown{end+1}=strcat(char(datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss:SSS')),'@program start');

%%  Collect subject's information.
Sub=inputdlg({'Patient'},'Info',1,{'name'});
patient=Sub{1,1};

%% pinyin syllables
f=fileread('pinyin_simplified.txt');
prompts = strsplit(f,'\n');
repeting=2;
prompts=repmat(prompts,1,repeting);
rdm_prompts=prompts(randperm(length(prompts)));

%% marker initilization 
if send_trigger
    ioObj = io64;     
    status = io64(ioObj);     
    if status == 0  
        disp('inpoutx64.dlgl successfully installed.')
    else
        error('inpoutx64.dll installation failed.')  
    end   
    address = hex2dec('378'); %0378   DEFC 
    io64(ioObj,address,0);
    io64(ioObj,address,1);
    io64(ioObj,address,0);
end

prompt_shown{end+1}=strcat(char(datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss:SSS')),'@marker_initialization_done');

%% config PTB
%PsychDebugWindowConfiguration(1, 0.5)%transparent screen 
%%-------comment below if SYNCHRONIZATION FAILURE ----------------
%Priority(2);
Screen('Preference', 'SkipSyncTests', 1); 
whichScreen = max(Screen('Screens'));
white = WhiteIndex(whichScreen);
black = BlackIndex(whichScreen);
[w, rect] = PsychImaging('OpenWindow', whichScreen, black,[10,10,1000,1000]); % ,[10,10,1000,1000]
slack=Screen('GetFlipInterval',w)/2;
[xc,yc] = WindowCenter(w);%xc=960,yc=540
[width, height]=Screen('WindowSize', w);
% Get the screen dimensions
screenWidth = rect(3); 
screenHeight = rect(4);
prompt_shown{end+1}=strcat(char(datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss:SSS')),'@PTB_config_done');
%% PTB sound
InitializePsychSound(1);
%freq = 3000; % Sample rate in Hz
% pahandle = PsychPortAudio(‘Open’ [, deviceid][, mode][, reqlatencyclass][, freq][, channels][, buffersize][, suggestedLatency][, selectchannels][, specialFlags=0]);
pahandle = PsychPortAudio('Open', [], 2, 1, [], 1);%use only one channels: left or right, both should be OK;
% Get what freq'uency we are actually using:
s = PsychPortAudio('GetStatus', pahandle);
freq = s.SampleRate;
% Preallocate an internal audio recording  buffer with a capacity of 120 seconds:
PsychPortAudio('GetAudioData', pahandle, 120);
prompt_shown{end+1}=strcat(char(datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss:SSS')),'@PTB_sound_initilizationi_done');
recordedaudio=[];
%% keyboard set up
KbName('UnifyKeyNames');
escapeKey = KbName('ESCAPE');
deviceIndex=[];
spaceKey = KbName('SPACE');

%%  Remind subject to prepare.
text='Press a Key When You Are Ready!';
Screen('TextSize', w ,60);
Screen('TextFont',w,'Microsoft YaHei');
width=RectWidth(Screen('TextBounds',w,text));
Screen('Drawtext',w,text,xc-width/2,yc,[255 255 255]);
Screen('Flip',w);
KbWait;

KbQueueCreate(deviceIndex);
KbQueueStart(deviceIndex);
%% Start audio capture immediately and wait for the capture to start.
% We set the number of 'repetitions' to zero, i.e. record until recording is manually stopped.
Screen('Drawtext',w,'recording while pause for 5 second.',xc-width/2,yc,[255 255 255]);
Screen('Flip',w);
PsychPortAudio('Start', pahandle, 0, 0, 1);

%% test pause
pause(5);
audiodata = PsychPortAudio('GetAudioData', pahandle);
recordedaudio = [recordedaudio audiodata]; 
Screen('Drawtext',w,'Stop recording.',xc-width/2,yc,[255 255 255]);
pause(0.5);
Screen('Flip',w);
PsychPortAudio('Stop', pahandle);
PsychPortAudio('Close', pahandle);

Screen('CloseAll');   
