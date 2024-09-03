portPP = hex2dec('0378');  % DEFC  
config_io;     
global cogent;
if( cogent.io.status ~= 0 )
   error('inp/outp installation failed');
end
outp(portPP, 0);

% test marker
marker_length=0.1;
marker_interval=1;
marker=[1,2,3,4,5,6,7,8];
%for m = marker
while 1
    m
    outp(portPP,m);
    pause(marker_length);
    outp(portPP, 0);
    WaitSecs(marker_interval);
end
