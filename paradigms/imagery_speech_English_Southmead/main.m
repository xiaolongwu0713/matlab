sca;    
close all;clear all;clc;
[ret, name] = system('hostname');     
if strcmp(strip(name),'LongsMac')
    win=false;
else
    win=true;
end
Sub=inputdlg({'Patient initial'},'Info',1,{''});
sub_initial=Sub{1,1};
if isempty(sub_initial)
    error("Quite program")
end
result_folder=['result/',datestr(now,'yyyymmddHHMM'),'/',sub_initial];

%%-------uncomment below if SYNCHRONIZATION FAILURE ----------------
Screen('Preference', 'SkipSyncTests', 1);  
whichScreen = max(Screen('Screens'));
white = WhiteIndex(whichScreen);
black = BlackIndex(whichScreen);
[w, rect] = Screen('OpenWindow', whichScreen, black) ;
slack=Screen('GetFlipInterval',w)/2;
[xc,yc] = WindowCenter(w);%xc=960,yc=540
% Get the screen dimensions
screenWidth = rect(3); 
screenHeight = rect(4);
Priority(1);
HideCursor;

send_trigger=1;
type='ECoG'; %ECoG/SEEG'
InitializePsychSound(1);
freq=48000;
pahandle = PsychPortAudio('Open', [], [], 2, freq, []);

%% ECoG trigger (send '0' to arduino)
arduino=serial('COM4','BaudRate',9600,'DataBits',8);
InputBufferSize=8;
Timeout=0.1;
set(arduino, 'InputBufferSize',InputBufferSize);
set(arduino, 'Timeout',Timeout);
set(arduino, 'Terminator','CR');
fopen(arduino);

%%

%base_dir='C:\Users\xiaowu\mydrive\matlab\paradigms\imagery_speech_English_Southmead\';
%audio_dir=[base_dir,'audio\clips_samples\*.wav'];
audio_dir='.\audio\clips\*.wav';
audio_files=dir(audio_dir);
[~,ind]=sort({audio_files.name});
a=audio_files(ind);

%sentences=[base_dir,'audio\sentences.txt']; 
sentences='.\audio\sentences.txt';
f=fileread(sentences);
prompts = strsplit(f,'\n');

if send_trigger
    if type=='SEEG'
        portNr=5;
        TriggerPort=open_ns_port(portNr);
        TriggerValue=1;
    end
end

%  Remind subject to prepare.
text='Press a Key When You Are Ready!';
Screen('TextSize', w ,70);
Screen('TextFont',w,'Microsoft YaHei');
width=RectWidth(Screen('TextBounds',w,text));
Screen('Drawtext',w,text,xc-width/2,yc,[255 255 255]);
Screen('Flip',w);
KbWait;

KbName('UnifyKeyNames');
escapeKey = KbName('ESCAPE');
deviceIndex=[];
spaceKey = KbName('SPACE');
KbQueueCreate(deviceIndex);
KbQueueStart(deviceIndex);

read_files=[];
prompt_shown=[];
pause('on');
escape=0;
for i=1:100 % 100 sentence; size(audio_files)

    %afile_tmp=audio_files(i);
    folder='.\audio\clips'; %afile_tmp.folder;
    filename=strcat(string(i),'.wav');%afile_tmp.name;
    afile=strcat(folder,'\', filename);
    fprintf('Read file: %s. \n',filename);
    read_files=[read_files, filename];
    
    % text
    sentence_tmp=prompts(i);
    sentence=sentence_tmp{1,1};
    prompt_shown=[prompt_shown,string(datetime),sentence];
    
    % audio
    [y, freq] = psychwavread(afile);
    wavedata = y';
    wavedata = [wavedata ; wavedata];
    %fprintf('before\n');
    %datetime
    PsychPortAudio('FillBuffer', pahandle, wavedata); % wait for previous PsychPortAudio to finish speaking
    %fprintf('after\n');
    %datetime
    
    repetitions=1;
    Screen('Drawtext',w,sentence,xc-width/2,yc,[255 255 255]);
    Screen('Flip',w);
    % PsychPortAudio doesn't wait to finish speaking
    t1 = PsychPortAudio('Start', pahandle, repetitions, 0, 1); %0:start it immediately; 
    if send_trigger
        if type=='SEEG'
            send_ns_trigger(TriggerValue, TriggerPort);
            fprintf('Trigger %d.\n',TriggerValue);
            datetime(now,'ConvertFrom','datenum')
        else
            fprintf(arduino,'0');
        end
        
    end
    
    pausing=0;
    trial_start=datevec(datenum(datetime));
    a_now=datevec(datenum(datetime));
    while etime(a_now, trial_start)<15
        
        %pause(1);
        [pressed, keyCode]=KbQueueCheck(deviceIndex);
        pressedKeys = KbName(keyCode);
        if strcmp(pressedKeys,'space')
            if pausing
                fprintf('Resuming');
                prompt_shown=[prompt_shown,'Resuming', string(datetime), sentence];
                Screen('Drawtext',w,'Resuming',xc-width/2,yc,[255 255 255]);
                Screen('Flip',w);
                Screen('Drawtext',w,sentence,xc-width/2,yc,[255 255 255]);
                Screen('Flip',w);
                t1 = PsychPortAudio('Start', pahandle, repetitions, 0, 1);
                if send_trigger
                    if type=='SEEG'
                        send_ns_trigger(TriggerValue, TriggerPort);
                        fprintf('Trigger %d.\n',TriggerValue);
                        datetime(now,'ConvertFrom','datenum')
                    else
                        fprintf(arduino,'0');
                    end
                    %send_ns_trigger(TriggerValue, TriggerPort);
                end
                pausing=0;
            else
                fprintf('Pausing.\n');
                prompt_shown=[prompt_shown,string(datetime),'Pausing'];
                Screen('Drawtext',w,'Pausing',xc-width/2,yc,[255 255 255]);
                Screen('Flip',w);
                PsychPortAudio('Stop', pahandle);
                pausing=1;
                trial_start=datevec(datenum(datetime)); % reset the 15s delay
                pause(0.1);
            end
            
        elseif strcmp(pressedKeys,'ESCAPE')
            escape=1;
            fprintf('Terminate the program with ESCAPE key');
            prompt_shown=[prompt_shown,string(datetime),'Escape'];
            break;
        end
        
        if pausing
            trial_start=datevec(datenum(datetime));
        end
        pause(0.1);
        a_now=datevec(datenum(datetime));
    end
   
    
    if escape==1
        break;
    end
    
    %pause(15);
    %fprintf('Finished playing.\n'); % not yet
    
end
if not(escape)
    pause(5) % in case there are still remianing audio
end

if send_trigger
    if type=='SEEG'
        close_ns_port(TriggerPort);
    else
        fclose(arduino);
    end
    %close_ns_port(TriggerPort);
end

% clear up things
PsychPortAudio('Stop', pahandle);
PsychPortAudio('Close', pahandle);
Screen('CloseAll');
ShowCursor;
Priority(0);
fclose('all');

answer=questdlg('Would you like to save?','Save','yes','no','yes');% default is yes
if strcmp(answer,'no')
    fprintf('Discard the log file. \n');
elseif strcmp(answer,'yes')
    mkdir(result_folder);
    filename=strcat(result_folder,'/inf.mat');
    save(filename,'Sub','read_files','prompt_shown'); 
end

