%% audio setup
InitializePsychSound(0);
freq=48000;
%pahandle = PsychPortAudio(‘Open’ [, deviceid][, mode][, reqlatencyclass][, freq][, channels][, buffersize][, suggestedLatency][, selectchannels][, specialFlags=0]);
pahandle = PsychPortAudio('Open', [], 3,1,freq,[2,2]) ;%3 for play and record

%s = PsychPortAudio('GetStatus', pahandle);
%freq = s.SampleRate;
Sub{3,1}=freq;
% Preallocate an internal audio recording  buffer with a capacity of 120 seconds:
PsychPortAudio('GetAudioData', pahandle, 120);


%% read file
[ret, name] = system('hostname');     
if strcmp(strip(name),'Long')  
    audio_folder='D:\data\speech_Southmead\audio\original\15_seconds'; %afile_tmp.folder;
else
    audio_folder='.\audio\square_wave\15_second_wavs'; %afile_tmp.folder;
end
i=1;
filename=strcat(string(i),'.wav');%afile_tmp.name;
afile=strcat(audio_folder,'\', filename);
[y, freq] = psychwavread(afile);
wavedata = y';
wavedata = [wavedata ; wavedata];

%% play audio

PsychPortAudio('FillBuffer', pahandle, wavedata); % wait for previous PsychPortAudio to finish speaking
repetitions=1; 
t1 = PsychPortAudio('Start', pahandle, repetitions, 0, 1); %0:start it immediately;

%% clear up things
PsychPortAudio('Stop', pahandle);
PsychPortAudio('Close', pahandle);
fclose('all');
