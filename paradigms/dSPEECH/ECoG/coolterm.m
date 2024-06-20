filename='..\CoolTerm6.txt';
fileID = fopen(filename,'r');
formatSpec = '%f';
A = fscanf(fileID,formatSpec);
plot(A)