function [featureMatrix,cspMatrix] = fbCspTrainOVO(miData,filterBands, nFilter, extendChannels)
% DESCRIPTION OF FUNCTION
%
% Uses the FBCSP algorithm on the training data to calculate 
% a set of csp filters and their corresponding features on the training data
%
% INPUT
% miData:           Structure that contains MI snippets and corresponding
%                   information.
%
% filterbands:      Filter bank of band pass filters specified in main
%
% nFilter:          describes how many sets csp filters to take from the
%                   matrix from each side
%
% extendChannels:   Boolean value that determines whether we want
%                   downsampling to extra channels
%
% OUTPUT:
% featureMatrix:    cell matrix containing all calculated features of 
%                   band / classifier combination. 
%                   size is [nBands x nClassifiers]
%
% cspMatrix         cell matrix containing all calculated csp filters of 
%                   band / classifier combination. 
%                   size is [nBands x nClassifiers]  
%
% AUTHORS OF FUNCTION:
% Soeren Moeller Christensen, s153571@student.dtu.dk
% Nicklas Stubkjaer Holm, s154411@student.dtu.dk


%constants
nClasses = miData.nClasses;
nBands = filterBands.nBands;

%Variables


%data
nClassifiers = nClasses*(nClasses-1)/2;

%a filter combination of OVO vs band
cspMatrix = cell(nBands,nClassifiers);
featureMatrix = cell(nBands,nClassifiers);
miDataUse = miData.miData;

for band = 1:nBands
    
    %band pass filter data  -  using current band
    filterUse = filterBands.filterVector{band};
    filteredSignal = filtfilt(filterUse.b,filterUse.a,transpose(miDataUse{1,band}));
    
    
    if (extendChannels)
        %downsample and add the thrown away data as channels
        miData = newChannels(miData,filteredSignal);
    else
        %put filtered signal in struct
        miData.miData = transpose(filteredSignal);
    end
    
    
    %calculate CSP filters for each classifier in this band (is a cell vector)
    [cspFilters] = getCSPOVO(miData,nFilter);
    
    %calculate features for each classifier in this band (is a cell vector)
    features = cspFeatures(miData,cspFilters);
    
    
    cspMatrix(band,:) = cspFilters;
    featureMatrix(band,:) = features;
    
end

end

