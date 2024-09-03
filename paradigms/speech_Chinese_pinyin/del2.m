% Clear the workspace and close any existing screens
sca;
close all;

% Set up Psychtoolbox audio
InitializePsychSound(1);
freq = 44100; % Sample rate in Hz
numChannels = 1; % Mono
recordingDuration = 5; % Recording duration in seconds

% Open an audio device for recording
recordingDevice = PsychPortAudio('Open', [], 2, 0, freq, numChannels);

% Start recording
PsychPortAudio('Start', recordingDevice);

% Record audio for the specified duration
recording = PsychPortAudio('GetAudioData', recordingDevice, recordingDuration);

% Stop recording
PsychPortAudio('Stop', recordingDevice);

% Close the recording device
PsychPortAudio('Close', recordingDevice);

% Save the recording to a .wav file
filename = 'recorded_audio.wav';
audiowrite(filename, recording, freq);

% Display a confirmation message
disp(['Recording saved as: ' filename]);

% Clear the audio buffer
PsychPortAudio('DeleteBuffer');

% Exit the script
sca;
