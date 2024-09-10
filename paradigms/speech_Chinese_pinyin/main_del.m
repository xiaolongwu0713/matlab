% marker=10: start the recording ---> marker=8: user press any key to start
% the task ---> marker=1,2...10,11,..25: the i-th line ---->
% marker=10: stop the recording;

% operation: run the experiment-->SPACE bar to pause--->'ESC' to terminate
% and save result; or run the experiment--->directly 'ESC' to terminate the
% experiment.

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
f=fileread('chinese_syllables_pinyin.txt');
prompts = strsplit(f,'\n');
repeting=2;
prompts=repmat(prompts,1,repeting);
rdm_prompts=prompts(randperm(length(prompts)));

%% marker initilization 
if send_trigger
    ioObj = io64;     
    status = io64(ioObj);     
    if status == 0  
        disp('inpoutx64.dll successfully installed.')
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
[w, rect] = PsychImaging('OpenWindow', whichScreen, black); % ,[10,10,1000,1000]
slack=Screen('GetFlipInterval',w)/2;
[xc,yc] = WindowCenter(w);%xc=960,yc=540
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
    io64(ioObj,address,0);
end
prompt_shown{end+1}=strcat(char(datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss:SSS')),'@audio_started');

%% play a beep and record with PTB: Then, the recordings should start with the beep.
% ToDO
prompt_shown{end+1}=strcat(char(datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss:SSS')),'@begin_loop');
interval=0.7;
terminate=0;
recordedaudio=[];
audio_marker=[1 0 1 0 1 0];
PsychPortAudio('GetAudioData', pahandle); % clear cache and get ready
diff1=[];
diff2=[];
diff3=[];
for i = 1:length(rdm_prompts)
    if i==5
        break;
    end
    t = datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss:SSS');
    progress=strcat(int2str(i),'/',int2str(length(rdm_prompts)));
    tmp=char(rdm_prompts(i));
    prompt=tmp(1:end-1);
    prompt_shown{end+1}=strcat(char(datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss:SSS')),'@',prompt);
    t1 = datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss:SSS');
    aa=seconds(t1-t);
    diff1=[diff1 aa]; % doesn't change
    %width=RectWidth(Screen('TextBounds',w,prompt(3))); 
    if send_trigger
        % screen index
        io64(ioObj,address,5);
        io64(ioObj,address,0);
    end
    recordedaudio = [recordedaudio audio_marker];
    %% counting
    if i==1
        counting_down(i,w,prompt,1,progress); % all grey
        pause(interval);
        counting_down(i,w,prompt,2,progress); % first dot green
        pause(interval);
        counting_down(i,w,prompt,3,progress); % second dot green
        pause(interval);
    else
        counting_down(i,w,prompt,1,progress); % all grey
        pause(interval);
    end  
    
    counting_down(i,w,prompt,4,progress); % initial green
    pause(interval);
    counting_down(i,w,prompt,5,progress); % final green
    pause(interval);
    counting_down(i,w,prompt,6,progress); % cyllable green
    pause(interval);
    counting_down(i,w,prompt,7,progress); % cyllable green
    pause(interval);
    counting_down(i,w,prompt,8,progress); % cyllable green
    pause(interval);
    counting_down(i,w,prompt,9,progress); % cyllable green
    pause(interval);
    counting_down(i,w,prompt,10,progress); % cyllable green
    pause(interval);
    
    t2 = datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss:SSS');
    aa=seconds(t2-t1);
    diff2=[diff2 aa]; % it will get larger as experiment goes
    % read and record sound
    audiodata = PsychPortAudio('GetAudioData', pahandle);
    % And attach it to our full sound vector:
    recordedaudio = [recordedaudio audiodata]; %#ok<AGROW>
    t3 = datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss:SSS');
    aa=seconds(t3-t2);
    diff3=[diff3 aa]; % get larger as well
    [pressed, keyCode]=KbQueueCheck(deviceIndex);
    pressedKeys = KbName(keyCode);
    if strcmp(pressedKeys,'ESCAPE')
        io64(ioObj,address,2);
        io64(ioObj,address,0);
        fprintf('Terminate the program with ESCAPE key');
        prompt_shown{end+1}=strcat(char(datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss:SSS')),'@Escape');
        terminate=1;
    
    elseif strcmp(pressedKeys,'space')
        PsychPortAudio('Stop', pahandle);
        io64(ioObj,address,2);
        io64(ioObj,address,0);
        fprintf('Pause');
        prompt_shown{end+1}=strcat(char(datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss:SSS')),'@Pause');
        while 1
            [pressed, keyCode]=KbQueueCheck(deviceIndex);
            pressedKeys = KbName(keyCode);
            
            if strcmp(pressedKeys,'ESCAPE')
                io64(ioObj,address,2);
                io64(ioObj,address,0);
                fprintf('Terminate the program with ESCAPE key');
                prompt_shown{end+1}=strcat(char(datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss:SSS')),'@Escape');
                terminate=1;
                break;  
            elseif strcmp(pressedKeys,'space')
                PsychPortAudio('Start', pahandle, 0, 0, 1);
                io64(ioObj,address,2);
                io64(ioObj,address,0);
                fprintf('Resume');
                prompt_shown{end+1}=strcat(char(datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss:SSS')),'@Resume');
                break;
            end
            
            pause(1);
            
        end
    end
    
    if terminate==1
        break;
    end
    
end

% Stop recording:
PsychPortAudio('Stop', pahandle);
prompt_shown{end+1}=strcat(char(datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss:SSS')),'@stop_audio');
if send_trigger
    io64(ioObj,address,10);
    io64(ioObj,address,0);
end
% Perform a last fetch operation to get all remaining data from the capture engine:
audiodata = PsychPortAudio('GetAudioData', pahandle);
% Attach it to our full sound vector:
recordedaudio = [recordedaudio audiodata];
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
