clear all
clc
delete(instrfindall);

%% test the relay 
arduino=serial('COM7','BaudRate',9600,'DataBits',8);
InputBufferSize=8;
Timeout=0.1;
set(arduino, 'InputBufferSize',InputBufferSize);
set(arduino, 'Timeout',Timeout);
set(arduino, 'Terminator','CR');

fopen(arduino);

while 1
fprintf(arduino,'0');
pause(3);
end

%y=fscanf(arduino,'%f')
fclose(arduino);

%% test the opto isolator

arduino=serial('COM8','BaudRate',9600,'DataBits',8);
InputBufferSize=8;
Timeout=0.1;
set(arduino, 'InputBufferSize',InputBufferSize);
set(arduino, 'Timeout',Timeout);
set(arduino, 'Terminator','CR');

fopen(arduino);

while 1
fprintf(arduino,'0');
pause(1);
fprintf("sending trigger \n");
end
fclose(arduino);
