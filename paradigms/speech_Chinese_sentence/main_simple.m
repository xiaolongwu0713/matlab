 
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
  Sub.inf=inputdlg({'Tyep: 0-test,1-actural run'},'Subject Information',1,{'0'});
 
%Tyep: 0-test,1-actural run
type=str2double(Sub.inf(1));   

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
    WaitSecs(0.1);
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
    WaitSecs(0.1);
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


f=fileread('corpus_simple.txt');
prompts = strsplit(f);
repeting=2  ; % 2*53words*2.5s/word=4.4min
prompts=repmat(prompts,1,repeting);
rdm_prompts=prompts(randperm(length(prompts)));


%  Remind subject to prepare.
text='Press a Key When You Are Ready!';
Screen('TextSize', w ,70);
Screen('TextFont',w,'Microsoft YaHei');
width=RectWidth(Screen('TextBounds',w,text));
Screen('Drawtext',w,text,xc-width/2,yc,[255 255 255]);
Screen('Flip',w);
KbWait;

% participant start task marker
if win
    io64(ioObj,address,8);
    WaitSecs(0.1);
    io64(ioObj,address,0);
end

prompt_shown=[];
recordedaudio=[];
for i=1:size(rdm_prompts,2)
    prompt_tmp=rdm_prompts(i);

    prompt_shown=[prompt_shown prompt_tmp];
    Screen('Drawtext',w,double(char(prompt_tmp)),900,yc,[255 255 255]);
    Screen('Flip',w); 
      
    if win
        % screen index
        io64(ioObj,address,20);
        WaitSecs(0.1);
        io64(ioObj,address,0); 
    end
    
    % read and record sound
    audiodata = PsychPortAudio('GetAudioData', pahandle);
    % And attach it to our full sound vector:
    recordedaudio = [recordedaudio audiodata]; %#ok<AGROW>
    
    WaitSecs(2.5);
        
    if type==0 && i==5
        break;
    end 
    
end

io64(ioObj,address,0);
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
    WaitSecs(0.1);
    io64(ioObj,address,0);
end

%save sound
if type==0
    foldername=['result/simple/',datestr(now,'yyyymmddHHMM'),'_test'];
else
    foldername=['result/simple/ ',datestr(now,'yyyymmddHHMM')];
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
