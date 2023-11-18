function [vcontribs,vcontribs_norm]=cal_contrib_norm(cortex,tala,kernelpara)
% Kernelpara=[1,10,15,25];
%Computing the electrode contributions
%Compute the contributions of the given electrodes:
if kernelpara(1)==1
    kernel = 'gaussian';
else
    kernel = 'linear';    
end
parameter = 10;
cutoff = kernelpara(2);
Dis_surf=kernelpara(3);
%See also |electrodesContributions| for a more thorough information on its arguments)
[ vcontribs ] = electrodesContributions( cortex, tala, kernel, parameter, cutoff, Dis_surf);
% normalizing vcontribs by number of electrodes 
vcontribs_norm = vcontribs;
 
for idx=1:length(vcontribs)
    
    v_norm = sum(vcontribs(idx).contribs(:,3));
    
    if size(vcontribs(idx).contribs,1) > 1
        
        vcontribs_norm(idx).contribs(:,3) = vcontribs(idx).contribs(:,3) ./ v_norm;
        
    end
end

end