%% Versioin 3
% 1, Add datetime to 'Resuming' event in log file;
% 2, Add the program start datetime to logfile;


%%
sca;close all;clear all;delete(instrfindall);
Priority(1);
[ret, name] = system('hostname'); 
prompt_shown=[string(datetime),];
send_trigger=1;
%% experiment type and user info
Sub=inputdlg({'Type','Patient initial'},'Info',1,{'ECoG or SEEG',''});
type_raw=Sub{1,1};
type=upper(type_raw);
sub_initial=Sub{2,1};

if ~strcmpi(type,'ECoG') & ~strcmpi(type,'SEEG')
    error("Type must be either ECoG or SEEG.")
end
    
if isempty(sub_initial)
    error("Please enter patient initial.")
end

if strcmpi(type,'SEEG')
    result_folder=['result/',datestr(now,'yyyymmddHHMM'),'_SEEG/',sub_initial];
elseif strcmpi(type,'ECoG')
    result_folder=['result/',datestr(now,'yyyymmddHHMM'),'_ECoG/',sub_initial];
end

%% audio setup
InitializePsychSound(0);
freq=48000;
%pahandle = PsychPortAudio(‘Open’ [, deviceid][, mode][, reqlatencyclass][, freq][, channels][, buffersize][, suggestedLatency][, selectchannels][, specialFlags=0]);
%pahandle = PsychPortAudio('Open', [], 1,1,freq) ;%3 for 1play and 2record
pahandle = PsychPortAudio('Open', [], 3,1,freq,[2,2]) ;%3 for 1play and 2record
PsychPortAudio('GetAudioData', pahandle, 120);
%s = PsychPortAudio('GetStatus', pahandle);
%freq = s.SampleRate;
Sub{3,1}=freq;

HideCursor;

%% screen setup
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

%% audio file setup

%sentences=[base_dir,'audio\sentences.txt']; 
sentences='.\audio\sentences.txt';
f=fileread(sentences);
prompts = strsplit(f,'\n');

if strcmpi(type,'SEEG')
    audio_folder='.\audio\original\15_second_wavs'; %afile_tmp.folder;
elseif strcmpi(type,'ECoG')
    audio_folder='.\audio\square_wave\15_second_wavs_ONE_SQUARE_WAVE'; %afile_tmp.folder;
end

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
if send_trigger
	if strcmpi(type,'SEEG')
		if isempty(ps_list)
		%send_trigger=0;
			error('No port available, please connect the trigger box!');
		else
			port=ps_list{1,1};
			portNr=str2num(port(end));
			send_trigger=1;
			fprintf('Using port: COM%d.\n',portNr);
			TriggerPort=open_ns_port(portNr);
			TriggerValue=1;
			send_ns_trigger(TriggerValue, TriggerPort);
		end
	elseif strcmpi(type,'ECoG')
        afile1='.\audio\square_wave\one_squarewave.wav'; 
		[y, freq] = psychwavread(afile1);
		wavedata = y';
		wavedata = [wavedata ; wavedata];
		PsychPortAudio('FillBuffer', pahandle, wavedata);
		t1 = PsychPortAudio('Start', pahandle, repetitions, 0, 1); %0:start it immediately;
	end
end
pause(1);

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
%%  experiment begins with three consecutive triggers
if  send_trigger 
    %if strcmpi(type,'ECoG')
    %    fprintf(arduino,'0');
    if strcmpi(type,'SEEG')
        % three consecutive triggers
        for i=1:3
            send_ns_trigger(TriggerValue, TriggerPort);
			pause(0.5);
        end
        % baseline
		for i=1:5
			Screen('Drawtext',w,int2str(i),xc-width/2,yc,[255 255 255]);
			Screen('Flip',w);
            pause(1);
		end
		
    end
	if strcmpi(type,'ECoG')
		% three consecutive squre waves
        afile3='.\audio\square_wave\three_squarewaves.wav'; 
		[y, freq] = psychwavread(afile3);
		wavedata = y';
		wavedata = [wavedata ; wavedata];
		PsychPortAudio('FillBuffer', pahandle, wavedata);
		t1 = PsychPortAudio('Start', pahandle, repetitions, 0, 1); %0:start it immediately;
        pause(4.5); % wait for the square audio finish;
        % baseline
        for i=1:5
			Screen('Drawtext',w,int2str(i),xc,yc,[255 255 255]);
			Screen('Flip',w);
            pause(1);
        end
	end
end
% baseline


%% loop trials
read_files=[];
pause('on');
escape=0;
recordedaudio=[]; 
total_sentences=125;
for j=1:total_sentences % 100 sentence; size(audio_files)
    if j<100 || j==100
        i=j;
    else
        i=j-100;
    end
    progress=convertStringsToChars(strcat(string(j),'/',string(total_sentences)));
    %afile_tmp=audio_files(i);
    %folder='.\audio\clips'; %afile_tmp.folder; 
    
    filename=strcat(string(i),'.wav');%afile_tmp.name;
    afile=strcat(audio_folder,'\', filename);
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
    Screen('FillOval',w,[0 255 0],[xc-width/2-400,yc-300,xc-width/2,yc+100]);
    Screen('Flip',w);
    Screen('Drawtext',w,sentence,xc-width/2,yc,[255 255 255]);
    Screen('Drawtext',w,progress,xc*2-400,yc*2-100,[255 255 255]);
    Screen('Flip',w);
    
    if  send_trigger 
        if strcmpi(type,'SEEG')
            send_ns_trigger(TriggerValue, TriggerPort);
        end
    end
    % PsychPortAudio doesn't wait to finish speaking
    % playback and record at the same time
    t1 = PsychPortAudio('Start', pahandle, repetitions, 0, 1); %0:start it immediately;
    
    pausing=0;
    trial_begin=datevec(datenum(datetime));
    a_now=datevec(datenum(datetime));
    flash1=0;
    flash2=0;
    while etime(a_now, trial_begin)<15
        
        % need to go near realtime when the green dot is about to apear
        if (etime(a_now, trial_begin)<4.5) || ((etime(a_now, trial_begin)>10.3) && (etime(a_now, trial_begin)<14.5))
            pause(0.3)
        end
        if (5.3<etime(a_now, trial_begin)) && (etime(a_now, trial_begin)<9.5)
            pause(0.3)
        end
        
        if seconds(diff(datetime([trial_begin;a_now])))>5 && flash1==0
            Screen('Drawtext',w,sentence,xc-width/2,yc,[255 255 255]);
            Screen('FillOval',w,[0 255 0],[xc-width/2-400,yc-300,xc-width/2,yc+100]);
            Screen('Flip',w);
            Screen('Drawtext',w,sentence,xc-width/2,yc,[255 255 255]);
            Screen('Drawtext',w,progress,xc*2-400,yc*2-100,[255 255 255]);
            Screen('Flip',w);
            flash1=1;
        elseif seconds(diff(datetime([trial_begin;a_now])))>10 && flash2==0
            Screen('Drawtext',w,sentence,xc-width/2,yc,[255 255 255]);
            Screen('FillOval',w,[0 255 0],[xc-width/2-400,yc-300,xc-width/2,yc+100]);
            Screen('Flip',w);
            Screen('Drawtext',w,sentence,xc-width/2,yc,[255 255 255]);
            Screen('Drawtext',w,progress,xc*2-400,yc*2-100,[255 255 255]);
            Screen('Flip',w);
            flash2=1;
        end
        
        %pause(1);
        [pressed, keyCode]=KbQueueCheck(deviceIndex);
        pressedKeys = KbName(keyCode);
        if strcmp(pressedKeys,'space')
            if pausing
                fprintf('Resuming');
                % missing a timestamp from v2
                prompt_shown=[prompt_shown,string(datetime),'Resuming', string(datetime), sentence];
                Screen('Drawtext',w,'Resuming',xc-width/2,yc,[255 255 255]);
                Screen('Flip',w);
                Screen('Drawtext',w,sentence,xc-width/2,yc,[255 255 255]);
                Screen('Flip',w);
                if  send_trigger 
                    if strcmpi(type,'SEEG')
                        send_ns_trigger(TriggerValue, TriggerPort);
                    end
                    % if strcmpi(type,'SEEG')% ECoG has trigger in audio file
                end
                t1 = PsychPortAudio('Start', pahandle, repetitions, 0, 1);
                pausing=0;
            else
                fprintf('Pausing.\n');
                prompt_shown=[prompt_shown,string(datetime),'Pausing'];
                Screen('Drawtext',w,'Pausing',xc-width/2,yc,[255 255 255]);
                Screen('Flip',w);
                PsychPortAudio('Stop', pahandle);
                pausing=1;
                trial_begin=datevec(datenum(datetime)); % reset the 15s delay
                pause(0.3);
            end
            
        elseif strcmp(pressedKeys,'ESCAPE')
            escape=1;
            fprintf('Terminate the program with ESCAPE key');
            prompt_shown=[prompt_shown,string(datetime),'Escape'];
            break;
        end
        
        % keep pausing for a long time
        if pausing
            pause(0.3);
            trial_begin=datevec(datenum(datetime));
        end
        %pause(0.1);
        a_now=datevec(datenum(datetime));
    end
    
    % read and record sound
    audiodata = PsychPortAudio('GetAudioData', pahandle);
    % And attach it to our full sound vector:
    recordedaudio = [recordedaudio audiodata]; %#ok<AGROW> 
    
    if escape==1
        break;
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
fclose('all');

%% save everything
answer=questdlg('Would you like to save?','Save','yes','no','yes');% default is yes
if strcmp(answer,'no')
    fprintf('Discard the log file. \n');
elseif strcmp(answer,'yes')
    mkdir(result_folder);
    filename=strcat(result_folder,'/inf.mat');
    save(filename,'Sub','read_files','prompt_shown'); 
    wavfilename=strcat(result_folder,'/recording.wav');
    psychwavwrite(transpose(recordedaudio), freq, 32, wavfilename);
end

