% % marker part
ioObj = io64;
status = io64(ioObj);
if status == 0
    disp('inpoutx64.dll successfully installed.')
else
    error('inpoutx64.dll installation failed.')
end
address = hex2dec('DEFC'); %0378-037B   DEFC
io64(ioObj,address,0);

% test marker
marker_length=0.1;
marker_interval=1;
marker=[1,2,3,4,5,6,7,8];
m=marker(1);
m=500;
while 1
    io64(ioObj,address,m);
    WaitSecs(marker_length);
    io64(ioObj,address,0);
    WaitSecs(marker_interval);
end

