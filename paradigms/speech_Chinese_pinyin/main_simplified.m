%% This is a simple version of main2.m. It is designed to validate the integerety of the recorded data.
% To that end, it only have four vowel: a e i u. And, the baseline is long
% enough to perform frequency analysis.

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
trigger_duration=0.1;
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
    pause(trigger_duration);
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
% participant start task marker
if send_trigger
    io64(ioObj,address,8);
    pause(trigger_duration);
    io64(ioObj,address,0);
end
KbQueueCreate(deviceIndex);
KbQueueStart(deviceIndex);
prompt_shown{end+1}=strcat(char(datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss:SSS')),'@Button_pressed_to_start');
%% Start audio capture immediately and wait for the capture to start.
% We set the number of 'repetitions' to zero, i.e. record until recording is manually stopped.
PsychPortAudio('Start', pahandle, 0, 0, 1);
% start recording marker
if send_trigger
    io64(ioObj,address,10);
    pause(trigger_duration);
    io64(ioObj,address,0);
end
prompt_shown{end+1}=strcat(char(datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss:SSS')),'@audio_started');

%% 
prompt_shown{end+1}=strcat(char(datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss:SSS')),'@begin_loop');
interval=0.7;
terminate=0;
recordedaudio=[];
audio_marker=[1 0 1 0 1 0];
diff1=[];
diff2=[];
diff3=[];
ready_prompt='准备';
PsychPortAudio('GetAudioData', pahandle); % clear cache and get ready
for i = 1:length(rdm_prompts)
    progress=strcat(int2str(i),'/',int2str(length(rdm_prompts)));
    tmp=char(rdm_prompts(i));
    prompt=tmp(1:end-1);
    prompt_shown{end+1}=strcat(char(datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss:SSS')),'@',prompt);
    %width=RectWidth(Screen('TextBounds',w,prompt(3))); 
    if send_trigger
        % screen index
        io64(ioObj,address,5);
        pause(trigger_duration);
        io64(ioObj,address,0);
    end
    recordedaudio = [recordedaudio audio_marker];
    Screen('Drawtext',w,double(ready_prompt),xc,yc,[0 255 0],[],1);
    Screen('Drawtext',w,progress,width-200,height-100,[255 255 255],[],1);
    Screen('Flip',w); 
    pause(3);
    
    
    Screen('Drawtext',w,prompt,xc,yc,[0 255 0],[],1);
    Screen('Drawtext',w,progress,width-200,height-100,[255 255 255],[],1);
    Screen('Flip',w); 
    pause(2);
    
    %% pause or escape
    [pressed, keyCode]=KbQueueCheck(deviceIndex);
    pressedKeys = KbName(keyCode);
    if strcmp(pressedKeys,'ESCAPE')
        io64(ioObj,address,2);
        pause(trigger_duration);
        io64(ioObj,address,0);
        fprintf('Terminate the program with ESCAPE key');
        prompt_shown{end+1}=strcat(char(datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss:SSS')),'@Escape');
        terminate=1;
    
    elseif strcmp(pressedKeys,'space')
        PsychPortAudio('Stop', pahandle);
        io64(ioObj,address,2);
        pause(trigger_duration);
        io64(ioObj,address,0);
        fprintf('Pause');
        prompt_shown{end+1}=strcat(char(datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss:SSS')),'@Pause');
        while 1
            [pressed, keyCode]=KbQueueCheck(deviceIndex);
            pressedKeys = KbName(keyCode);
            
            if strcmp(pressedKeys,'ESCAPE')
                io64(ioObj,address,2);
                pause(trigger_duration);
                io64(ioObj,address,0);
                fprintf('Terminate the program with ESCAPE key');
                prompt_shown{end+1}=strcat(char(datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss:SSS')),'@Escape');
                terminate=1;
                break;  
            elseif strcmp(pressedKeys,'space')
                PsychPortAudio('Start', pahandle, 0, 0, 1);
                io64(ioObj,address,2);
                pause(trigger_duration);
                io64(ioObj,address,0);
                fprintf('Resume');
                prompt_shown{end+1}=strcat(char(datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss:SSS')),'@Resume');
                break;
            end
            
            pause(1);
            
        end
    end
    
    
    %% get audio data
    audiodata = PsychPortAudio('GetAudioData', pahandle);
    recordedaudio = [recordedaudio audiodata]; %#ok<AGROW>
    
    
    
    if terminate==1
        break;
    end
    
end

% Stop recording:
PsychPortAudio('Stop', pahandle);
prompt_shown{end+1}=strcat(char(datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss:SSS')),'@stop_audio');
if send_trigger
    io64(ioObj,address,10);
    pause(trigger_duration);
    io64(ioObj,address,0);
end
% Close the audio device:
prompt_shown{end+1}=strcat(char(datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss:SSS')),'@close_audio');
PsychPortAudio('Close', pahandle);



%save sound
if terminate==1
    foldername=['result/',patient,'_',datestr(now,'yyyymmddHHMM'),'_escape'];
else
    foldername=['result/',patient,'_',datestr(now,'yyyymmddHHMM')];
end
mkdir(foldername);
wavfilename=strcat(foldername,'/recording.wav');
% what is 32 stands for? Warning below if set to 16:
%Warning: Data clipped when writing file. 
psychwavwrite(transpose(recordedaudio), freq, 32, wavfilename);

filename=strcat(foldername,'/prompt_shown.mat');
save(filename,'prompt_shown');

Screen('CloseAll');   
