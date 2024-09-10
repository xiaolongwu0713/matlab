% % marker part
ioObj = io64;
status = io64(ioObj);
if status == 0
    disp('inpoutx64.dll successfully installed.')
else
    error('inpoutx64.dll installation failed.')
end
address = hex2dec('378'); %0378   DEFC
io64(ioObj,address,0);

% test marker
marker_length=0.1;
marker_interval=1;
marker=[101, 1,4,5,8,300,9,3,2,200,];

  
for m=marker
    m;
    io64(ioObj,address,m);
    WaitSecs(marker_length);
    io64(ioObj,address,0);
    WaitSecs(marker_interval);

end 
