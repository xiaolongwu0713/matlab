function [elecMatrix,elecInfo] = sortelec(dcm_obj)
% manual select electrodes, this function works on the active MATLAB figure
ElectrodeIndex=1;

set(dcm_obj,'UpdateFcn',@myupdatefcn)
elecNum=0;
switch ElectrodeIndex
    case 1
        done=0;
        while ~done
            pinnum=inputdlg('Type in a pin name (click OK without typing to stop selection):'); %c
            pinnum = pinnum{1}; %c
            for iele=1:4
                pause
                cursor = getCursorInfo(dcm_obj); % store cursor location
                elecNum = elecNum + 1;
                elecMatrix(elecNum, 1) = cursor.Position(1);
                elecMatrix(elecNum, 2) = cursor.Position(2);
                elecMatrix(elecNum, 3) = cursor.Position(3);
                elecInfo.loc{elecNum}=elecMatrix(elecNum,:);
                elecInfo.name{elecNum}=pinnum;
                fprintf('Electrode %d.\n',elecNum)
            end
            forwardflag = questdlg('Add another shaft? Yes to continue, No to exit.','','Yes','No',''); % (question_text,title,option1,option2)
            switch forwardflag
                case 'Yes'
                case 'No'
                    done=1;
            end
        end
    case 2 || 3
        printf('Not implemented ye');
end
