
whichScreen = max(Screen('Screens'));
white = WhiteIndex(whichScreen);
black = BlackIndex(whichScreen);
[w, rect] = PsychImaging('OpenWindow', whichScreen, black) ;
slack=Screen('GetFlipInterval',w)/2;
[xc,yc] = WindowCenter(w);%xc=960,yc=540
% Get the screen dimensions
screenWidth = rect(3); 
screenHeight = rect(4);


KbName('UnifyKeyNames');
escapeKey = KbName('ESCAPE');
deviceIndex=[];
spaceKey = KbName('SPACE');
KbQueueCreate(deviceIndex);
KbQueueStart(deviceIndex);

Priority(1);
HideCursor;
pausing=0;
while 1
[pressed, keyCode]=KbQueueCheck(deviceIndex);
pressedKeys = KbName(keyCode);
if strcmp(pressedKeys,'space') % pause  the whole process
    if pausing==0
        fprintf('pause');
        pausing=1;      
    elseif pausing==1
        fprintf('Resume');
        pausing=0;
    end
elseif strcmp(pressedKeys,'ESCAPE') % terminate the whole process
        fprintf('Terminate the program with ESCAPE key');
        break;    
    
end
        
end

Priority(0);
ShowCursor;
