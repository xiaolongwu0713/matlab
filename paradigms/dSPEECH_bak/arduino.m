clear all
clc
delete(instrfindall);

arduino=serial('COM4','BaudRate',9600,'DataBits',8);
InputBufferSize=8;
Timeout=0.1;
set(arduino, 'InputBufferSize',InputBufferSize);
set(arduino, 'Timeout',Timeout);
set(arduino, 'Terminator','CR');

fopen(arduino);

while 1
fprintf(arduino,'0');
pause(5);
end

%y=fscanf(arduino,'%f')
fclose(arduino);
