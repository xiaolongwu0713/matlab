% marker=10: start the recording ---> marker=8: user press any key to start
% the task ---> marker=1,2...10,11,..25: the i-th page showed up ---->
% marker=10: stop the recording;
 
sca;    
close all;clear all;
[ret, name] = system('hostname');     
if strcmp(strip(name),'LongsMac')  
    win=false;
else
    win=true;
end
%PsychDebugWindowConfiguration(1, 0.5)%transparent screen 
%%-------uncomment below if SYNCHRONIZATION FAILURE ----------------
Screen('Preference', 'SkipSyncTests', 1); 
  
%%------- ------------- ------------- ------------------------------------- -----------------------------%% 
%  Collect subject's information.
%Sub.inf=inputdlg({'Name','Age','Gender','Left-handed or Right-handed','Repeting times(1 or 5)'},'Subject Information',1,{'Name()','Age','Gender','Right or Left','5'});
%Sub.inf=inputdlg({'Test trials'},'Subject Information',1,{'0'});
  Sub.inf=inputdlg({'Tyep: 0-test,1-actural run','Date','Name','Age','Gender'},'Subject Information',1,{'0','Date','Name','Age','Gender'});
 
%Tyep: 0-test,1-actural run
type=str2double(Sub.inf(1))  ;   

% % marker initilization 
if win
    ioObj = io64;     
    status = io64(ioObj);     
    if status == 0  
        disp('inpoutx64.dll successfully installed.')
    else
        error('inpoutx64.dll installation failed.')  
    end   
    address = hex2dec('378'); %0378   DEFC 
    io64(ioObj,address,0);
end

% Set up Psychtoolbox audio
InitializePsychSound;
%freq = 3000; % Sample rate in Hz
% pahandle = PsychPortAudio(‘Open’ [, deviceid][, mode][, reqlatencyclass][, freq][, channels][, buffersize][, suggestedLatency][, selectchannels][, specialFlags=0]);
pahandle = PsychPortAudio('Open', [], 2, 1, [], 1);%use only one channels: left or right, both should be OK;
% Get what freq'uency we are actually using:
s = PsychPortAudio('GetStatus', pahandle);
freq = s.SampleRate;
Sub.freq=freq;
% Preallocate an internal audio recording  buffer with a capacity of 120 seconds:
PsychPortAudio('GetAudioData', pahandle, 120);

% Start audio capture immediately and wait for the capture to start.
% We set the number of 'repetitions' to zero, i.e. record until recording is manually stopped.
PsychPortAudio('Start', pahandle, 0, 0, 1);
% start recording marker
if win
    io64(ioObj,address,10);
    io64(ioObj,address,0);
end

whichScreen = max(Screen('Screens'));
white = WhiteIndex(whichScreen);
black = BlackIndex(whichScreen);
[w, rect] = PsychImaging('OpenWindow', whichScreen, black) ;
slack=Screen('GetFlipInterval',w)/2;
[xc,yc] = WindowCenter(w);%xc=960,yc=540
% Get the screen dimensions
screenWidth = rect(3); 
screenHeight = rect(4);


f=fileread('corpus.txt');
prompts = strsplit(f);
repeting=2;
prompts=repmat(prompts,1,repeting);
rdm_prompts=prompts(randperm(length(prompts)));


%  Remind subject to prepare.
text='Press a Key When You Are Ready!';
Screen('TextSize', w ,60);
Screen('TextFont',w,'Microsoft YaHei');
width=RectWidth(Screen('TextBounds',w,text));
Screen('Drawtext',w,text,xc-width/2,yc,[255 255 255]);
Screen('Flip',w);
KbWait;

% participant start task marker
if win
    io64(ioObj,address,8);
    io64(ioObj,address,0);
end

%lines per page=10
lines=10;
% Calculate the vertical spacing for the sentences
numSentences = lines;
spacing = floor(screenHeight / (numSentences + 1));
b = floor(length(rdm_prompts)/lines);
r = mod(length(rdm_prompts),lines);
prompt_shown=[];
recordedaudio=[];
for i = 1:b+1
    if i==b+1
        prompt_tmp=rdm_prompts(i*10-9:end);
    else
        prompt_tmp=rdm_prompts(i*10-9:i*10);
    end
    prompt_shown=[prompt_shown prompt_tmp];
    for j =1:length(prompt_tmp)
        yc=j*spacing;  
        Screen('Drawtext',w,double(char(prompt_tmp(j))),700,yc,[255 255 255]);
    end   
    Screen('Flip',w); 
    
    if win
        % screen index
        io64(ioObj,address,i);
        io64(ioObj,address,0);
    end
    
    % read and record sound
    audiodata = PsychPortAudio('GetAudioData', pahandle);
    % And attach it to our full sound vector:
    recordedaudio = [recordedaudio audiodata]; %#ok<AGROW>
    
    WaitSecs(3); % prevent a consecutive keyboard press
    KbWait;  
        
    if type==0
        break;
    end 
    
end

% Stop recording:
PsychPortAudio('Stop', pahandle);
% Perform a last fetch operation to get all remaining data from the capture engine:
audiodata = PsychPortAudio('GetAudioData', pahandle);
% Attach it to our full sound vector:
recordedaudio = [recordedaudio audiodata];
% Close the audio device:
PsychPortAudio('Close', pahandle);
if win
    % EEG stop marker after close
    io64(ioObj,address,10);
    io64(ioObj,address,0);
end

%save sound
if type==0
    foldername=['result/',datestr(now,'yyyymmddHHMM'),'_test'];
else
    foldername=['result/',datestr(now,'yyyymmddHHMM')];
end 
mkdir(foldername);
wavfilename=strcat(foldername,'/recording.wav');
% what is 32 stands for? Warning below if set to 16:
%Warning: Data clipped when writing file. 
psychwavwrite(transpose(recordedaudio), freq, 32, wavfilename);

%save meta info 
filename=strcat(foldername,'/inf.mat');
save(filename,'Sub');
filename=strcat(foldername,'/prompt_shown.mat');
save(filename,'prompt_shown');

Screen('CloseAll');   
