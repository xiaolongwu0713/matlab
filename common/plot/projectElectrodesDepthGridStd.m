function [ tala ] = projectElectrodesDepthGridStd(pathToSubjectDir,tala,normdist,modelstring)
% The projection of seeg is disabled below, so just return the function
% without doing anything if all electrodes are seeg.

tala.trielectrodes=tala.electrodes;
tala.electrodesdur=tala.electrodes;
if tala.seeg_pos==size(tala.electrodes,1)
    return
end

stdtala=struct;
if strcmp(modelstring,'mni')
    model=1;
elseif strcmp(modelstring,'fsave')
    model=2;
else
    error('wrong model name, please input the corrected model name: ''fsave''/''mni''\n');
end
switch model
    case 1
        fprintf('Projecting electrodes in MNI brain:\n');
        load(strcat(pathToSubjectDir,'MNI//MATLAB/WholeCortex.mat'));
        clear cortex
        clear cortexout
        clear cortexreg
    case 2
        fprintf('Projecting electrodes in fsaverage brain:\n');
        load(strcat(pathToSubjectDir,'FSAVERAGE/MATLAB/WholeCortex.mat'));
        clear cortex
        clear cortexreg
end
for i=1:2 % hem loop
    ind=find(tala.hem==i); % left
    if i==1 && ~isempty(ind)
        hem='left';
    elseif i==2 && ~isempty(ind)
        hem='right';
    else
        hem=[];
%         error('No hemisphere information is found! Please check electrode information~');
    end
    if ~isempty(hem)
        if tala.seeg_pos==size(tala.electrodes,1) % All electrodes are seeg, findTripointsDepth comment out.
            cortexhem=eval([hem,'cortex']);
            switch model
                case 1
                    stdtala.electrodes=tala.electrodes(ind,:);
%                   stdtala.trielectrodes=findTripointsDepth(cortexhem,stdtala.electrodes,normdist);
                    tala.trielectrodes(ind,:)=stdtala.electrodes;
                    tala.electrodesdur(ind,:)=stdtala.electrodes;
                case 2
                    stdtala.electrodes=tala.electrodes(ind,:);
%                   stdtala.trielectrodes=findTripointsDepth(cortexhem,stdtala.electrodes,normdist);
                    tala.trielectrodes(ind,:)=stdtala.electrodes;
                    tala.electrodesdur(ind,:)=stdtala.electrodes;
            end
            clear cortexhem
        elseif tala.seeg_pos==0 % all electrodes are ecog
            
            switch model
                case 1
                    cortexouthem=eval([hem,'cortexout']);
                    cortexoutcoaser=coarserModel(cortexouthem,0.1);
                    stdtala.electrodes=tala.electrodes(ind,:);
                    [ stdtala ] = projectElectrodes(cortexoutcoaser, stdtala, normdist);
                    tala.electrodesdur(ind,:)=stdtala.trielectrodes;
                    tala.trielectrodes(ind,:)=stdtala.trielectrodes;
                    clear cortexouthem
                case 2
                    tala.electrodesdur(ind,:)=tala.electrodes(ind,:);
                    tala.trielectrodes(ind,:)=tala.electrodes(ind,:);
            end
        elseif tala.seeg_pos>0 && tala.seeg_pos<size(tala.electrodes,1) % contains both seeg and ecog
            cortexhem=eval([hem,'cortex']);          
            seegind=[1:tala.seeg_pos];
            ecogind=[(tala.seeg_pos+1):size(tala.electrodes,1)];
            seeghem=intersect(seegind,ind);
            ecoghem=intersect(ecogind,ind);
            switch model
                
                case 1
                    if ~isempty(seeghem)
                        selectrodes=tala.electrodes(seeghem,:);
%                       selectrodestri=findTripointsDepth(cortexhem,selectrodes,normdist);
                        tala.trielectrodes(seeghem,:)=selectrodes;
                        tala.electrodesdur(seeghem,:)=tala.electrodes(seeghem,:);
                    end
                    if ~isempty(ecoghem)
                        cortexouthem=eval([hem,'cortexout']);
                        talae.electrodes=tala.electrodes(ecoghem,:);
                        cortexoutcoaser=coarserModel(cortexouthem,0.1);
                        [ talae  ] = projectElectrodes(cortexoutcoaser,talae,normdist);
                        tala.electrodesdur(ecoghem,:)=talae.trielectrodes;
                        tala.trielectrodes(ecoghem,:)=talae.trielectrodes;
                        clear cortexouthem
                    end
                    
                case 2
                    
                    if ~isempty(seeghem)
                        selectrodes=tala.electrodes(seeghem,:);
%                       selectrodestri=findTripointsDepth(cortexhem,selectrodes,normdist);
                        tala.trielectrodes(seeghem,:)=selectrodes;
                        tala.electrodesdur(seeghem,:)=tala.electrodes(seeghem,:);
                    end
                    if ~isempty(ecoghem)
                        tala.electrodesdur(ecoghem,:)=tala.electrodes(ecoghem,:);
                        tala.trielectrodes(ecoghem,:)=tala.electrodes(ecoghem,:);
                    end
            end
            clear cortexhem
            
        else
            error('Wrong electrode type inputs,please check the electrodes index!');
        end
        
    end
end
end


