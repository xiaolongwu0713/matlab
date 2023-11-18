% Author:           Xingchen Ran (ran.xingchen@qq.com)
% Date:             2023/05/15
% Copyright:        NeuroXess
% Workfile:         mex2mat.m
% Purpose:          Read MindExplorer recorded mex data file and convert it
%                   to matlab data file.

% This script reading data with mex format from the specified path, and 
% convert it to matlab format.


function [head, data] = mex_reader(varargin)

if isempty(varargin)
    [file, path] = uigetfile("*.mex", "Select an Mex Data File", ...
        "MultiSelect", "off");
else
    filedir = varargin{1};
    assert(exist(filedir, "file") ~= 0, "Selected file " + filedir + " is not exist!");

    [path, file_name, file_ext]= fileparts(filedir);
    path = [char(path) '/'];
    file = [char(file_name) char(file_ext)];
end

filename = [path, file];
fid = fopen(filename, "rb");

head = struct;
data = struct;

% Check 'magic number' at begining of the file to make sure this is an 
% Cerecub MindExplorer recording file.
head.magic_number = fread(fid, 1, "uint64");
if (head.magic_number ~=hex2dec('91F66D2229A56C35'))
    error("Unknown file type!")
end

head.check_sum = fread(fid, 1, "uint32");        % Not used for now.

% Meta info
head.meta = struct;
head.meta.size = fread(fid, 1, "uint16");
head.meta.offset = fread(fid, 1, "uint64");
head.meta.length = fread(fid, 1, "uint64");
head.meta.type = fread(fid, 4, "*char")';
head.meta.record_id = fread(fid, 36, "*char")';

% Data info
head.data = struct;
head.data.size = fread(fid, 1, "uint16");
head.data.offset = fread(fid, 1, "uint64");
head.data.length = fread(fid, 1, "uint64");
head.data.version = fread(fid, 1, "uint32");
head.data.data_stream = fread(fid, 1, "uint16");
head.data.sample_rate = fread(fid, 1, "uint32");
head.data.layout_length = fread(fid, 1, "uint16");
head.data.frame.type = fread(fid, 4, "*char")';
head.data.frame.size = fread(fid, 1, "uint16");
head.data.ttl.type = fread(fid, 4, "*char")';
head.data.ttl.size = fread(fid, 1, "uint16");

% Check the length of the data for safety.
fseek(fid, 0, "eof");
header_limit = 4096;
filesize = ftell(fid);
datasize = (filesize - head.data.offset - header_limit);
if (datasize ~= head.data.length)
    warning("Length of the data do not equal with the header.")
end

% Read data
fseek(fid, head.data.offset + header_limit, "bof");

nbytes = 2;         % int16
ncols = (head.data.frame.size + head.data.ttl.size) / nbytes;  % int16
nsamples = datasize / (head.data.frame.size + head.data.ttl.size);
buffer = fread(fid, [ncols, nsamples], "int16");
data.frame = buffer(1:end - 1, :)';
data.ttl = buffer(end, :)';

fclose(fid);

end
