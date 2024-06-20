[ret, name] = system('hostname');     
if strcmp(strip(name),'Long')  
    audioDir='D:\data\speech_Southmead\audio\original\15_seconds'; %afile_tmp.folder;
else
    audioDir='.\audio\original\15_second_wavs'; %afile_tmp.folder;
end
audioFiles = dir(fullfile(audioDir,'*.wav'));
for i = 1:numel(audioFiles)
    selectedAudioFile = fullfile(audioDir, audioFiles(i).name);
    [y, Fs] = audioread(selectedAudioFile);
    player = audioplayer(y, Fs);
    play(player);
    pause(player.TotalSamples / player.SampleRate);
    stop(player);
end