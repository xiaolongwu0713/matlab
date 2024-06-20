function mara_localiser
% mara_localiser
%
% participant's task is to press the DOWN ARROW key whenever an image repeats.
%
% includes 4 runs - one first thing to do in the evening of Session 1, one last thing to do in the morning of Session 1
% one first thing to do in the evening of Session 2, one last thing to do in the morning of Session 2
% each run contains 6 categogies (car, corridor, house, instrument, number, word').
% each category contains 30 exmplars per run
% each run lasts ~ 8 minutes and there is a 20 seconds break at half-time
%
% to continue, usually press <space>
% to abort, press ESC

%                               bernhard.staresina@psy.ox.ac.uk

%% input box
prompt = {...
    'SubjectID:',...
    'RunNr:',...
    'Send Trigger [0 = no | 1 = yes]:',...
    'Number of Port for Neurospec Trigger Box (e.g., if port COM3, enter "3"):',...
    'Language [1 = GER | 2 = ENG]:',...

    };

name      = '';
numlines  = 1;
default   = {'p000', '', '1','',''};

% check if one ID already exists
outfiles_found = dir('output_mara_localiser_*.txt');
if numel(outfiles_found)==1
    existingID = outfiles_found.name(numel('output_mara_localiser_')+1:end-4);
    default{1} = existingID;

    T = readtable(outfiles_found.name);

    default{2} = num2str(max(T.RunNumber)+1);

end

% find out system language
this_language = java.lang.System.getProperty('user.language');
if strcmp(this_language,'de')
    default{5} = '1';
elseif strcmp(this_language,'en')
    default{5} = '2';
end

answer    = inputdlg(prompt,name,numlines,default);

SubjectID       = answer{1};
Run             = str2double(answer{2});
SendTrigger     = str2double(answer{3});
portNr          = str2double(answer{4});
Language        = str2double(answer{5});


%if no port number is given - return error
if SendTrigger && isnan(portNr)
    Screen('CloseAll');
    ShowCursor;
    Priority(0);
    fclose('all'); 
    psychrethrow('Error: NO PORT NUMBER for the Neurospec trigger box was given. Check windows device manager to find port number info');
end

%% insert double-check in case 1st session pm is mistakenly called again

cancel = 0;

if Run == 1 && exist(['stimfile_mara_localiser_ ' SubjectID '.mat'],'file') == 2

    answer = questdlg(sprintf('overwrite existing %s?',SubjectID), ...
        'WARNING', ...
        'No','Yes','No');

    switch answer
        case 'No'
            cancel = 1;
        case 'Yes'
            cancel = 0;
    end

end

if cancel == 1
    return
end

%% Trigger settings

if SendTrigger
    addpath('functions');

    TriggerValue         = 1;
    TriggerPort          = open_ns_port(portNr);     % open the COM port for Neurospec trigger box (check COM port number in Windows Device Manager!)

    %--- number of triggers to mark different parts of the experiment
    nTriggers                 = [];
    nTriggers.Start           = 6;
    MultiTriggerInterval      = .050;

end

%% experimental settings

basedirectory       = pwd;
windsize            = [];% [0 0 1000 800] % to customize the window size (for deugging), otherwise leave empty
StimDim             = [0 0 400 400]; % size of stimulus display
PicPresMin          = 1;   % minimum duration of the picture display
PicPresMax          = 1;   % maximum duration of the picture display

Refractory          = .050;   % time to wait before response is taken (could be a late response from previous trial)
FixationTime        = 1.250;  % prestim fixation
FixationJitter      = -.250 : 0.05 : 0.250;  % jitter times around the average Fixation time

nCategories         = 6;  % number of categories in stimulus set
nStimPerCategory    = 30; % images per category
perc_repeats        = 10; % percent of repeats

nRuns               = 4; % number of separate runs in the experiment
nCycles             = 1; % number of times the stimulus list is repeated within a run

RestPeriod          = 20; % time (sec) to rest after each cycle


% fixation
FixationCross       = '+';
% key asaignments
KbName('UnifyKeyNames');
CancelExpKey        = 'escape';
DownKey             = 'DownArrow';
ContinueSpace       = 'space';

% text settings
TextFont            = 'Verdana';
TextSize            = 20;
FixationFont        = 'Verdana';
FixationSize        = 20;


%--- spin the rand # generator
rng('shuffle');

%% set up output file (not for practice)

GiveFeeback         = 0; % color the fixation cross based in the previous trial's accuracy
CategoryNames       = {'car' 'corridor' 'house' 'instrument' 'number' 'word'};
stimpath            = 'stimuli';
StudyOutputFileName = sprintf('output_mara_localiser_%s.txt',SubjectID);
fid                 = fopen(StudyOutputFileName,'at'); % open as writeable text
if Run == 1
    fprintf(fid,...
        'SubjectID\tRunNumber\tCycleNumber\tTrialNumber\tCategory\tImage\tRepeat\tResponse\tRT\tAccuracy\tBaselineDur\tTriggerTime\tExperimentTime\n');
end

%% build stimulus list for participant when starting the experiment, otherwise load it

if Run == 1

    stimstruct = struct;

    for irun = 1:nRuns

        run_stimlist        = [];
        run_stimlist_categ  = [];
        run_repeatvec       = [];
        run_cyclevec        = [];

        for icycle = 1:nCycles

            cycle_stimlist        = [];
            cycle_stimlist_categ  = [];
            cycle_preslist        = [];

            for iCategory = 1:nCategories

                these_exemplars       = Shuffle(dir(fullfile(basedirectory,stimpath,CategoryNames{iCategory},'*.jpg')));
                these_exemplars       = {these_exemplars.name};

                if irun > 1
                    taken = {};
                    for ii=1:irun-1
                        taken = [taken stimstruct(ii).stimlist];
                    end
                    these_exemplars(ismember(these_exemplars,taken)) = [];
                end
                these_exemplars = these_exemplars(1:nStimPerCategory);

                % designate n% of exemplars as repeats
                preslist = zeros(1,numel(these_exemplars));
                preslist(randi(numel(these_exemplars),1,ceil(nStimPerCategory*(perc_repeats/100)))) = 1;


                cycle_stimlist        = [cycle_stimlist these_exemplars];
                cycle_stimlist_categ  = [cycle_stimlist_categ repmat(CategoryNames(iCategory),1,numel(these_exemplars))];
                cycle_preslist        = [cycle_preslist preslist];
            end

            shuffler              = randperm(numel(cycle_stimlist));
            cycle_stimlist        = cycle_stimlist(shuffler);
            cycle_stimlist_categ  = cycle_stimlist_categ(shuffler);
            cycle_preslist        = cycle_preslist(shuffler);

            cycle_stimlist_rep           = cell(1,numel(cycle_preslist)+sum(cycle_preslist));
            cycle_stimlist_categ_rep     = cell(1,numel(cycle_preslist)+sum(cycle_preslist));
            repeatvec                    = zeros(1,numel(cycle_preslist)+sum(cycle_preslist));

            cnt_orig = 0;
            cnt_rep  = 0;

            for ipres = 1:numel(cycle_stimlist)

                cnt_orig = cnt_orig + 1;
                cnt_rep  = cnt_rep  + 1;

                cycle_stimlist_rep(cnt_rep)        = cycle_stimlist(cnt_orig);
                cycle_stimlist_categ_rep(cnt_rep)  = cycle_stimlist_categ(cnt_orig);

                if cycle_preslist(ipres) == 1

                    cycle_stimlist_rep(cnt_rep+1)        = cycle_stimlist(cnt_orig);
                    cycle_stimlist_categ_rep(cnt_rep+1)  = cycle_stimlist_categ(cnt_orig);
                    repeatvec(cnt_rep+1)                 = 1;
                    cnt_rep = cnt_rep+1;
                end
            end

            run_stimlist        = [run_stimlist cycle_stimlist_rep];
            run_stimlist_categ  = [run_stimlist_categ cycle_stimlist_categ_rep];
            run_repeatvec       = [run_repeatvec repeatvec];
            run_cyclevec        = [run_cyclevec icycle*ones(1,numel(cycle_stimlist_rep))];

        end

        stimstruct(irun).stimlist           = run_stimlist;
        stimstruct(irun).stimlist_categ     = run_stimlist_categ;
        stimstruct(irun).repeatvec          = run_repeatvec;
        stimstruct(irun).cyclevec           = run_cyclevec;

    end

    save(sprintf('stimfile_mara_localiser_%s',SubjectID),'stimstruct')
else
    load(sprintf('stimfile_mara_localiser_%s',SubjectID))
end

%% set up screen
try
    Screen('Preference', 'SkipSyncTests', 1);

    available_screens = Screen('Screens');

    if numel(available_screens)>1
        target_screen = 1;
    else
        target_screen = 0;
    end
    windsize           = [];% [0 0 1000 800] % to customize the window size (for debugging), otherwise leave empty

    [window, windrect] = Screen('OpenWindow',target_screen,[],windsize);

    FlipDuration       = Screen('GetFlipInterval', window);

    AssertOpenGL;
    Screen('Preference', 'Enable3DGraphics', 1);
    Screen('BlendFunction', window, GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
    priorityLevel = MaxPriority(window);
    Priority(priorityLevel);

    HideCursor;
    %% basic settings after screen initialization

    %--- colors
    black       = BlackIndex(window);
    white       = WhiteIndex(window);
    background  = white/2;

    StimFrame       = CenterRect(StimDim,windrect);
    FrameColor      = background;
    FixationFrame   = background;


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% create stimuli and lists %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % put up note while stimuli are loading
    Screen('FillRect', window, background);
    Screen('TextSize', window, TextSize);
    Screen('TextFont', window, TextFont);

    switch Language
        case 1 % german
            WaitNote        = 'Ladevorgang ...';
        case 2 % english
            WaitNote        = 'loading ...';
    end

    WaitNoteRect    = Screen('TextBounds',window,WaitNote);
    DrawFormattedText(window,WaitNote,'center','center',black);
    Screen('Flip', window);

    %--- Progress Bar
    ProgBarWidth    = WaitNoteRect(3);
    ProgBarHeight   = 10;
    ProgBarRect     = CenterRect([0 0 ProgBarWidth ProgBarHeight],windrect);
    ProgBarRect     = [ProgBarRect(1) ProgBarRect(2)+200 ProgBarRect(3) ProgBarRect(4)+200];
    ProgInc         = ProgBarWidth/(length(stimstruct(Run).stimlist));

    ImagePres       = cell(1,length(stimstruct(Run).stimlist));
    ImagePatch      = cell(1,length(stimstruct(Run).stimlist));

    %--- convert stimuli into PTB textures

    for iTrial = 1:length(stimstruct(Run).stimlist)

        ThisImage   = imread(fullfile(basedirectory,stimpath,stimstruct(Run).stimlist_categ{iTrial},stimstruct(Run).stimlist{iTrial}));

        [ImageWidth, ImageHeight] = RectSize(RectOfMatrix(ThisImage));
        if ImageWidth > ImageHeight
            ScaleFactor = StimDim(3)/ImageWidth;
        else
            ScaleFactor = StimDim(3)/ImageHeight;
        end
        ImageTargetPatchWidth    = ImageWidth*ScaleFactor;
        ImageTargetPatchHeight   = ImageHeight*ScaleFactor;

        ImagePres{iTrial}  = Screen('MakeTexture', window, ThisImage);
        ImagePatch{iTrial} = CenterRect([0 0 ImageTargetPatchWidth ImageTargetPatchHeight],windrect);

        clear Image

        % show the loading progress
        DrawFormattedText(window,WaitNote,'center','center',black);
        Screen('FillRect', window, black, [ProgBarRect(1) ProgBarRect(2) ProgBarRect(1)+iTrial*ProgInc ProgBarRect(4)]);
        Screen('FrameRect', window, black, ProgBarRect);
        Screen('Flip', window);

    end

    %%  create fixation cross offscreen and paste later (faster)
    FixationDisplay = Screen('OpenOffscreenWindow',window);
    Screen('FillRect', FixationDisplay, background);

    Screen('TextFont',FixationDisplay,FixationFont);
    Screen('TextSize',FixationDisplay,FixationSize);
    FixationRect = Screen('TextBounds',FixationDisplay,FixationCross);
    FixationLoc  = CenterRect(FixationRect,windrect);

    Screen('DrawText',FixationDisplay,FixationCross,FixationLoc(1)-1,FixationLoc(2)-1,FixationFrame);
    Screen('DrawText',FixationDisplay,FixationCross,FixationLoc(1)-1,FixationLoc(2)+1,FixationFrame);
    Screen('DrawText',FixationDisplay,FixationCross,FixationLoc(1)+1,FixationLoc(2)-1,FixationFrame);
    Screen('DrawText',FixationDisplay,FixationCross,FixationLoc(1)+1,FixationLoc(2)+1,FixationFrame);
    Screen('DrawText',FixationDisplay,FixationCross,FixationLoc(1),FixationLoc(2),black);

    % positive feedback
    FixationDisplayCorrect = Screen('OpenOffscreenWindow',window);
    Screen('FillRect', FixationDisplayCorrect, background);
    Screen('TextFont',FixationDisplayCorrect,FixationFont);
    Screen('TextSize',FixationDisplayCorrect,FixationSize);
    Screen('DrawText',FixationDisplayCorrect,FixationCross,FixationLoc(1),FixationLoc(2),[0 255 0]);

    % negative feedback
    FixationDisplayIncorrect = Screen('OpenOffscreenWindow',window);
    Screen('FillRect', FixationDisplayIncorrect, background);
    Screen('TextFont',FixationDisplayIncorrect,FixationFont);
    Screen('TextSize',FixationDisplayIncorrect,FixationSize);
    Screen('DrawText',FixationDisplayIncorrect,FixationCross,FixationLoc(1),FixationLoc(2),[255 0 0]);

    %% INSTRUCTIONS before practice

    switch Language
        case 1 % german
            InstructionImage     = imread(fullfile(basedirectory,'instructions','mara_localiser_instructions_german.png'));
        case 2 % english
            InstructionImage     = imread(fullfile(basedirectory,'instructions','mara_localiser_instructions_english.png'));
    end

    [ImageWidth, ImageHeight] = RectSize(RectOfMatrix(InstructionImage));

    InstructionImagePres  = Screen('MakeTexture', window, InstructionImage);
    InstructionImagePatch = CenterRect([0 0 ImageWidth ImageHeight],windrect);

    Screen('DrawTexture',window,InstructionImagePres,[],InstructionImagePatch);

    Screen('FrameRect', window ,black,InstructionImagePatch,3);

    Screen('Flip', window);


    while 1
        [keyIsDown,TimeStamp,keyCode] = KbCheck;
        if keyIsDown && keyCode(KbName(ContinueSpace))
            Screen('FillRect', window, background);
            Screen('Flip', window);
            clear keyIsDown
            break
        end
    end

    tic;while toc < .3;end


    %% HIT SPACE TO START

    Screen('FillRect', window, background);
    Screen('TextSize', window, TextSize);
    Screen('TextFont', window, TextFont);

    switch Language
        case 1 % german
            IntroText   = sprintf('<Leertaste> zum Starten');
        case 2 % english
            IntroText   = sprintf('<space> to start');
    end
    DrawFormattedText(window,IntroText,'center','center',black);
    Screen('Flip', window);

    while 1
        [keyIsDown,TimeStamp,keyCode] = KbCheck;
        if keyIsDown && keyCode(KbName(ContinueSpace))
            Screen('FillRect', window, background);
            Screen('Flip', window);
            clear keyIsDown
            break
        end
    end

    tic;while toc < .3;end

    %% START
    WaitSecs(.1);
    clear keyIsDown

    AbortExp    = 0;

    BreakPoints = round(length(stimstruct(Run).stimlist)/2);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Enter the Trial Loop %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if SendTrigger
        %--- show fixation and send run start trigger
        Screen('CopyWindow',FixationDisplay,window)
        FixationStart = Screen('Flip', window);

        for ii = 1 : nTriggers.Start
            send_ns_trigger(TriggerValue, TriggerPort);
            WaitSecs(MultiTriggerInterval);
        end
    end

    RunStart = GetSecs;

    for iTrial = 1:length(stimstruct(Run).stimlist)

        %--- show fixation
        Screen('CopyWindow',FixationDisplay,window)

        if GiveFeeback && iTrial > 1
            if Accuracy == 1
                Screen('CopyWindow',FixationDisplayCorrect,window)
            elseif Accuracy == 0
                Screen('CopyWindow',FixationDisplayIncorrect,window)
            end
        end

        FixationStart = Screen('Flip', window);

        Jitter = FixationJitter(randi(numel(FixationJitter)));

        while GetSecs <= FixationStart + FixationTime + Jitter
            [keyIsDown,TimeStamp,keyCode] = KbCheck;
            if keyIsDown && keyCode(KbName(CancelExpKey))
                clear keyIsDown
                AbortExp = 1;
                break
            end
        end
        if AbortExp; break; end

        %---  Show Image

        ResponseGiven   = 0;
        RT              = -1;

        Screen('DrawTexture',window,ImagePres{iTrial}, [],ImagePatch{iTrial});
        Screen('FrameRect', window ,FrameColor,StimFrame,3);


        TrialStart = Screen('Flip',window,[],1);
        if SendTrigger
            send_ns_trigger(TriggerValue, TriggerPort);
            TriggerOnTime  = GetSecs-RunStart;
        else
            TriggerOnTime = -1;
        end

        while GetSecs <= TrialStart + PicPresMax

            if not(ResponseGiven) && (GetSecs - TrialStart) >= Refractory
                [keyIsDown,TimeStamp,keyCode] = KbCheck;
                if keyIsDown && keyCode(KbName(DownKey))
                    clear keyIsDown
                    ResponseGiven = 1;
                    ResponseTime  = TimeStamp;
                elseif keyIsDown && keyCode(KbName(CancelExpKey))
                    clear keyIsDown
                    AbortExp = 1;
                    ResponseGiven = 1;
                    break
                else
                    ResponseTime = inf;
                    keyCode = zeros(128,1);
                    keyCode(KbName('.')) = 1;
                end
            end
            if ResponseGiven && GetSecs > TrialStart + PicPresMin
                break
            end

        end

        if AbortExp; break; end

        RT   = ResponseTime - TrialStart;
        code = find(keyCode);
        if code(1)      == KbName(DownKey)
            Answer      = 'down';
            if stimstruct(Run).repeatvec(iTrial) == 1
                Accuracy = 1;
            else
                Accuracy = 0;
            end
        else
            Answer      = 'none';
            if stimstruct(Run).repeatvec(iTrial) == 1
                Accuracy = 0;
            else
                Accuracy = 1;
            end
        end

        %--- write out trial info

        fprintf(fid,'%s\t %02d\t %02d\t %03d\t %s\t %s\t %d\t %s\t %3.4f\t %01d\t %2.2f\t %5.4f\t %s\n',...
            SubjectID,...
            Run,...
            stimstruct(Run).cyclevec(iTrial),...
            iTrial,...
            stimstruct(Run).stimlist_categ{iTrial},...
            stimstruct(Run).stimlist{iTrial},...
            stimstruct(Run).repeatvec(iTrial),...
            Answer,...
            RT,...
            Accuracy,...
            FixationTime + Jitter,...
            TriggerOnTime,...
            datestr(now,'dd/mmm/yyyy-HH:MM:SS:FFF'));


        % insert break at BreakPoints, but not after last trial

        if not(rem(iTrial,BreakPoints)) && not(iTrial == length(stimstruct(Run).stimlist))
            BreakStart  = GetSecs;
            switch Language
                case 1 % german
                    RestText    = sprintf('20 Sekunden Pause - gleich geht''s weiter');
                case 2 % english
                    RestText    = sprintf('20 seconds break - we''ll continue shortly');
            end

            while GetSecs < BreakStart + RestPeriod
                TimeLeft = RestPeriod - (GetSecs - BreakStart);
                DrawFormattedText(window, RestText, 'center', 'center', [0 0 0 (255/RestPeriod)*TimeLeft]);
                Screen(window, 'Flip');
                [keyIsDown,TimeStamp,keyCode] = KbCheck;
                if keyIsDown && keyCode(KbName(CancelExpKey))
                    clear keyIsDown
                    AbortExp = 1;
                    break
                end
            end
            % insert an additional 1 s fixation
            Screen('CopyWindow',FixationDisplay,window)
            FixationStart = Screen('Flip', window);
            WaitSecs(1)
        end

    end % of for iTrial

    %--- show another fixation at end of trial list
    FixationStart  = GetSecs;
    FixationShown  = 0;
    while GetSecs <= FixationStart + FixationTime
        %--- show fixation
        if not(FixationShown)
            Screen('CopyWindow',FixationDisplay,window)
            Screen('Flip', window);
            FixationShown = 1;
        end
        [keyIsDown,TimeStamp,keyCode] = KbCheck;
        if keyIsDown && keyCode(KbName(CancelExpKey))
            clear keyIsDown
            AbortExp = 1;
            break
        end
    end

    RunEnd = GetSecs;
    fprintf('runduration = %4.3f sec\n', RunEnd-RunStart);
    %% Show Outro
    Screen('FillRect', window, background);
    Screen('TextSize', window, TextSize);
    Screen('TextFont', window, TextFont);


    switch Language
        case 1 % german
            OutroText   = 'fertig mit diesem Durchgang !\n';
        case 2 % english
            OutroText   = 'you are done with this run !\n';
    end

    DrawFormattedText(window,OutroText,'center','center',black);

    Screen('Flip', window);

    while 1
        [keyIsDown,TimeStamp,keyCode] = KbCheck;
        if keyIsDown && keyCode(KbName(ContinueSpace))
            Screen('FillRect', window, background);
            Screen('Flip', window);
            clear keyIsDown
            break
        end
    end
    WaitSecs(.1);

    %%  %%%%%%%%%%%%%%%%%%%%%%%% cleanup at end of experiment  %%%%%%%%%%%%%%%%%%%%%
    Screen('CloseAll');
    if SendTrigger
        close_ns_port(TriggerPort)
    end
    ShowCursor;
    Priority(0);
    fclose('all');

    fprintf('finished RUN %d for participant %s (%d runs total)\n',Run,SubjectID,nRuns)

    clear

catch % catch error
    Screen('CloseAll');
    ShowCursor;
    Priority(0);
    fclose('all');
    psychrethrow(psychlasterror);
    if SendTrigger
        close_ns_port(TriggerPort)
    end
end % try ... catch