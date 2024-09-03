address = hex2dec('378'); %并口地址
config_io;
global cogent;
if( cogent.io.status ~= 0 )
   error('inp/outp installation failed');
end
outp(address,0);

for i = 1:100
outp(address,i);% mark 值
WaitSecs(0.004);
outp(address,0);
end