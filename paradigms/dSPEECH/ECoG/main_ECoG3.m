% Two blocks of `clear; serialport` are required to load the virtual buffer
% and communicate with the dSPEECH trigger box.
%clear
%s = serialport;
%clear
%s = serialport;

%% Version 4: isolated words; tasks: speak + imagine; alignment using patient event trigger;
% One trigger: imagining speech automatically start right after overt speech (no trigger needed for covert speech)
 
% update: add visual cue to promote button pressiong
%%
sca;close all;clear all;delete(instrfindall);
Priority(1);
[ret, name] = system('hostname'); 
tmp=strcat(string(datetime),'start_program');
events=[string(datetime),tmp];
send_trigger=1;
cd ./; %  D:\mydrive\matlab\paradigms\speech_Southmead\ECoG\;
result_folder=['result/',datestr(now,'yyyymmddHHMM'),'_ECoG'];
type='ECoG';

%% connect to arduino
%arduino=serial("/dev/tty.usbmodem141201",'BaudRate',115200);
arduino=serial('COM3','BaudRate',115200);
%arduino=serial('COM5','BaudRate',115200);
fopen(arduino);

%% audio setup
InitializePsychSound(0);
freq=48000;
%pahandle = PsychPortAudio(‘Open’ [, deviceid][, mode][, reqlatencyclass][, freq][, channels][, buffersize][, suggestedLatency][, selectchannels][, specialFlags=0]);
%pahandle = PsychPortAudio('Open', [], 1,1,freq) ;%3 for 1play and 2record
pahandle = PsychPortAudio('Open', [], 2, 1, [], 2);%3 for symontaneously play and record; 2: force lowest latency;

PsychPortAudio('GetAudioData', pahandle, 120);
%s = PsychPortAudio('GetStatus', pahandle);
%freq = s.SampleRate;
Sub{3,1}=freq;         

%HideCursor;

%% screen setup
%%-------uncomment below if SYNCHRONIZATION FAILURE ----------------
Screen('Preference', 'SkipSyncTests', 1);  
whichScreen = max(Screen('Screens')); 
white = WhiteIndex(whichScreen);
black = BlackIndex(whichScreen);
[w, rect] = Screen('OpenWindow', whichScreen, black);% ,[100,100,900,800]);

slack=Screen('GetFlipInterval',w)/2;
[xc,yc] = WindowCenter(w);%xc=960,yc=540
% Get the screen dimensions
screenWidth = rect(3); 
screenHeight = rect(4);

Screen('BlendFunction', w, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
%smImSq = [0 0 250 250];
%[smallIm, xOffsetsigS, yOffsetsigS] = CenterRect(smImSq, rect);
%smallIm=[0 yc-100 250 yc+100];

[img1, ~, alpha] = imread('mouth.png');
img1(:, :, 4) = alpha;
texture_overt = Screen('MakeTexture', w, img1);

% NEW BLOCK
[imageHeight, imageWidth, ~] = size(imread('thinking.png'));
topRightX = screenWidth - imageWidth/2 - 150;
topRightY = 50;
smallIm=[topRightX, topRightY, topRightX + imageWidth/2, topRightY + imageHeight/2];
% END NEW BLOCK

[img2, ~, alpha] = imread('thinking.png');
img2(:, :, 4) = alpha;
texture_covert = Screen('MakeTexture', w, img2);

%Screen('DrawTexture', w, texture1, [], smallIm);
%Screen('Flip', w);
%fprintf('without the alpha channel.')
%pause(5)


%sca;
%return 



%return; %quit(10);
%Screen('CloseAll');
%% audio file setup: no audio play in this paradigm
%{
%sentences=[base_dir,'audio\sentences.txt']; 
%sentences='./audio/sentences.txt';
sentences='./audio/pseudowords/3_vowels_sentencs.txt';
f=fileread(sentences);
prompts = strsplit(f,'\n');

if strcmpi(type,'SEEG')
    audio_folder='./audio/original/15_second_wavs'; %afile_tmp.folder;
elseif strcmpi(type,'ECoG')
    %audio_folder='./audio/square_wave/15_second_wavs_ONE_SQUARE_WAVE'; %afile_tmp.folder;
    audio_folder='./audio/pseudowords'; %afile_tmp.folder;
end
%}

%% read word list
                
word_list='word_list.txt';
f=fileread(word_list);
prompts = strsplit(f,'\n');
lines=size(prompts,2);                

%% keyboard set up
KbName('UnifyKeyNames');
escapeKey = KbName('ESCAPE'); 
deviceIndex=[];
spaceKey = KbName('SPACE');
KbQueueCreate(deviceIndex);
KbQueueStart(deviceIndex);

%% initialize port + one squarewave
ps_list=serialportlist;
% start program trigger
repetitions=1; 

%% press key to start
text='Press a Key When You Are Ready!';
Screen('TextSize', w ,70);
Screen('TextFont',w,'Microsoft YaHei');
width=RectWidth(Screen('TextBounds',w,text));
Screen('Drawtext',w,text,xc-width/2,yc,[255 255 255]);
Screen('Flip',w);
KbWait;
%reset the keyboard cache
KbQueueCreate(deviceIndex);
KbQueueStart(deviceIndex);
%%  experiment begins
tmp=strcat(string(datetime),'start_experiment');
events=[events,tmp];


%% loop trials
% PsychPortAudio doesn't block while playing audio
% playback and record at the same time
t1 = PsychPortAudio('Start', pahandle, repetitions, 0, 1); %0:start it immediately;

read_files=[];
pause('on');
escape=0;
recordedaudio=[]; 
total_sentences=10;
pause_time=1;
for i=1:lines % 100 sentence; size(audio_files)

    progress=convertStringsToChars(strcat(string(i),'/',string(lines)));
     
    % text
    prompts_tmp=prompts(i);
    prompt=prompts_tmp{1,1};
    tmp=strcat(string(datetime),prompt);
    events=[events,tmp];
    tmp=split(prompt,'—');
    first=char(tmp(1,1)); first=first(find(~isspace(first)));
    second=char(tmp(2,1)); second=second(find(~isspace(second)));
    third=char(tmp(3,1)); third=third(find(~isspace(third)));
    
    Screen('DrawTexture', w, texture_overt, [], smallIm);
    Screen('Drawtext',w,first,xc-700,yc,[255 255 255]);
    Screen('Drawtext',w,second,xc-75,yc,[255 255 255]);
    Screen('Drawtext',w,third,xc+525,yc,[255 255 255]);
    Screen('Drawtext',w,progress,xc*2-400,yc*2-100,[255 255 255]);
    Screen('Flip',w);
    
    if  send_trigger 
        if strcmpi(type,'SEEG')
            send_ns_trigger(TriggerValue, TriggerPort);
        end
    end
    
    % NEW BLOCK
    lastPressTime = -Inf;  % Set to -Inf so the first press works
    % END NEW BLOCK
  
    while 1
        [pressed, keyCode]=KbQueueCheck(deviceIndex);
        pressedKeys = KbName(keyCode);
        if strcmp(pressedKeys,'ESCAPE')
            break;
        end
        signal=fscanf(arduino,'%c');
        trigger=str2num(signal);
        %[pressed, keyCode]=KbQueueCheck(deviceIndex);
        %pressedKeys = KbName(keyCode);
        if trigger==1 %strcmp(pressedKeys,'space')

            % NEW BLOCK
            currentTime = GetSecs;
            if (currentTime - lastPressTime) > 8
                lastPressTime = currentTime;
                % END NEW BLOCK
    
                %mark=[1 1 2 2 3 3; 1 1 2 2 3 3];
                %audiodata = PsychPortAudio('GetAudioData', pahandle);
                %audiodata = [audiodata mark];
                %recordedaudio = [recordedaudio audiodata];
                beep;
                pause(pause_time);
                Screen('DrawTexture', w, texture_overt, [], smallIm);
                Screen('Drawtext',w,first,xc-700,yc,[0 255 0]);
                Screen('Drawtext',w,second,xc-75,yc,[255 255 255]);
                Screen('Drawtext',w,third,xc+525,yc,[255 255 255]);
                Screen('Drawtext',w,progress,xc*2-400,yc*2-100,[255 255 255]);
                Screen('Flip',w);
                pause(pause_time);
                Screen('DrawTexture', w, texture_overt, [], smallIm);
                Screen('Drawtext',w,first,xc-700,yc,[255 255 255]);
                Screen('Drawtext',w,second,xc-75,yc,[0 255 0]);
                Screen('Drawtext',w,third,xc+525,yc,[255 255 255]);
                Screen('Drawtext',w,progress,xc*2-400,yc*2-100,[255 255 255]);
                Screen('Flip',w);
                pause(pause_time);
                Screen('DrawTexture', w, texture_overt, [], smallIm);
                Screen('Drawtext',w,first,xc-700,yc,[255 255 255]);
                Screen('Drawtext',w,second,xc-75,yc,[255 255 255]);
                Screen('Drawtext',w,third,xc+525,yc,[0 255 0]);
                Screen('Drawtext',w,progress,xc*2-400,yc*2-100,[255 255 255]);
                Screen('Flip',w);
                pause(pause_time);
                % NEW BLOCK
                Screen('DrawTexture', w, texture_covert, [], smallIm);
                Screen('Drawtext',w,first,xc-700,yc,[255 255 255]);
                Screen('Drawtext',w,second,xc-75,yc,[255 255 255]);
                Screen('Drawtext',w,third,xc+525,yc,[255 255 255]);
                Screen('Drawtext',w,progress,xc*2-400,yc*2-100,[255 255 255]);
                Screen('Flip',w);
                pause(pause_time);
                % END NEW BLOCK
                Screen('DrawTexture', w, texture_covert, [], smallIm);
                Screen('Drawtext',w,first,xc-700,yc,[255 0 0]);
                Screen('Drawtext',w,second,xc-75,yc,[255  255 255]);
                Screen('Drawtext',w,third,xc+525,yc,[255 255 255]);
                Screen('Drawtext',w,progress,xc*2-400,yc*2-100,[255 255 255]);
                Screen('Flip',w);
                pause(pause_time);
                Screen('DrawTexture', w, texture_covert, [], smallIm);
                Screen('Drawtext',w,first,xc-700,yc,[255 255 255]);
                Screen('Drawtext',w,second,xc-75,yc,[255 0 0]);
                Screen('Drawtext',w,third,xc+525,yc,[255 255 255]);
                Screen('Drawtext',w,progress,xc *2-400,yc*2-100,[255 255 255]);
                Screen('Flip',w);
                pause(pause_time);
                Screen('DrawTexture', w, texture_covert, [], smallIm);
                Screen('Drawtext',w,first,xc-700,yc,[255 255 255]);
                Screen('Drawtext',w,second,xc-75,yc,[255 255 255]);
                Screen('Drawtext',w,third,xc+525,yc,[255 0 0]);
                Screen('Drawtext',w,progress,xc*2-400,yc*2-100,[255 255 255]);
                Screen('Flip',w);
                pause(pause_time);
                
                % visual cue the next trial
                %Screen('Drawtext',w,feedback(),xc-125,yc,[50 150 255]);
                %Screen('Flip',w);
                %pause(pause_time);
                % NEW BLOCK
                trigger=0;
                KbQueueFlush(deviceIndex);
                % END NEW BLOCK
                break;
            end
        end
    end

    % read and record sound
    audiodata = PsychPortAudio('GetAudioData', pahandle);
    recordedaudio = [recordedaudio audiodata];
    
    if strcmp(pressedKeys,'ESCAPE')
        break; % break the for loop
    end
    
    %pause(15);
    %fprintf('Finished playing.\n'); % not yet
    
end


%% close port
if  send_trigger 
    %if strcmpi(type,'ECoG')
    %    fclose(arduino);
    if strcmpi(type,'SEEG')
        close_ns_port(TriggerPort);
    end
end

%% clear up things
PsychPortAudio('Stop', pahandle);
% Perform a last fetch operation to get all remaining data from the capture engine:
audiodata = PsychPortAudio('GetAudioData', pahandle);
% Attach it to our full sound vector:
recordedaudio = [recordedaudio audiodata];
PsychPortAudio('Close', pahandle);
Screen('CloseAll');
ShowCursor;
Priority(0);
fclose(arduino);
fclose('all');

%% save everything
answer=questdlg('Would you like to save?','Save','yes','no','yes');% default is yes
if strcmp(answer,'no')
    fprintf('Discard the log file. \n');
elseif strcmp(answer,'yes')
    mkdir(result_folder);
    filename=strcat(result_folder,'/inf.mat');
    save(filename,'Sub','events'); 
    wavfilename=strcat(result_folder,'/recording.wav');
    psychwavwrite(transpose(recordedaudio), freq, 32, wavfilename);
end

