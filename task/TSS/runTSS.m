function runTSS
clear all

p = [];                             % Initializes the p variable, which will contain all of the parameters to be saved
p = setVersion(p);                  % Runs setVersion.m to define task parameters
[p,practice,results] = setSubID(p); % Runs setSubID.m to define subject id, initializes practice and results as empty cells or loads prior data
p = setSession(p);                  % Runs setSession.m to randomise seed generator and get session & device info
p = setParams(p);                   % Runs setParams.m to calibrate keys and set up reward matrix
p = setScannerParams(p);            % Runs setScannerParams.m to set the scanner parameters
p = setScreen(p);                   % Runs setScreen.m to calibrate the Screen
p = setStimuli(p);                  % Runs setStimuli.m to define the Stroop stimuli

% Adds path for game at start of script. Need to rmpath at end of runTSS.
addpath(p.session.versionPath);

if p.restart == 0
    p.rollingRewardWindow = [];
    %practice = [];
    %results = [];
end

% Uncomment these to test specific instructions or skip the pracice blocks for debugging
% p.skipPractice = 1;
% instructionsGainInterval(p,1)
% instructionsLossInterval(p,1)
% p.curBlockNum = 1; instructionsBlock(p);

% TCB_RewardPenalty:
%p.skipPractice = 0;
%instructionsLowRewardMixedPenaltyInterval(p,1)
%instructionsHighRewardMixedPenaltyInterval(p,1)
%instructionsCue(p)
%instructionsCueInTask(p)
%p.curBlockNum = 1;
%instructionsBlock(p)
%instructionsLowLossMixedPenaltyInterval(p,1)
%instructionsHighLossMixedPenaltyInterval(p,1)
%instructionsCueInTask(p)

%instructionsMixedRewardLowPenaltyInterval(p,1)
%instructionsMixedRewardHighPenaltyInterval(p,1)
%instructionsLowRewardMixedPenaltyInterval(p,1)
%instructionsMixedRewardHighPenaltyInterval(p,1)

% TCB_LossPenalty:
%instructionsMixedLossLowPenaltyInterval(p,1)
%instructionsMixedLossHighPenaltyInterval(p,1)
%instructionsLowLossMixedPenaltyInterval(p,1)
%instructionsHighLossMixedPenaltyInterval(p,1)
%instructionsCueInTask(p);
% p.curBlockNum = 1;
% instructionsBlock(p)
% 
% clc;
% sca;

%% PART 1: Practice
if p.isScanningVersion == 0 || (p.isScanningVersion == 1 && p.curSession == 1)
    if p.skipPractice == 0
       
        % Determining whethe is practice or task
        p.isPracticeSession = 1 ; 
        
        instructionsStart(p)
        
        % Key mapping practice (without & with deadline)
        instructionsKeyMapping(p,1);
        [p,practice,results] = practiceKeyMapping(p,practice,results);
        instructions(p,'You have finished this practice.',1);
        
        % Stroop Practice
        instructionsStroop(p,1)
        [p,practice,results] = practiceStroop(p,practice,results);
        instructions(p,'You have finished this practice.',1);
        
        % Basic Interval Practice
        instructionsBasicInterval(p,1);
        
        p.curOverallTrialNum = 1;
        p.practice.isCued = 0;
        
        for intervalNum = 1:p.numPracIntervals
            p.curIntervalNum = intervalNum;
            [p,practice,results] = practiceInterval(p,practice,results);
        end
        instructions(p,'You have finished this practice.',1);
        
        %% Conditions Interval Practice (2 Practice Blocks Total)
        %  Order of Instructions for Intervals
        %  Efficacy: 1) High Efficacy (100%), 2) Low Efficacy (0%), 3) Mixed Efficacy
        %  GainLoss: 1) Gain, 2) Loss
        %  RewardPenalty: 1) Mixed Reward-Low Penalty, 2) Mixed Reward-High Penalty, 3) Low Reward-Mixed Penalty, 4) High Reward-Mixed Penalty
        
        %% Cued Interval Practice Block 1
        if p.session.isEfficacy
            % One Hundred Efficacy Interval Practice (Button Interval Practice)
            instructionsHighEffInterval(p,1)
            p.curOverallTrialNum = 1;
            p.practice.isCued = 1;
        elseif p.session.isGainLoss
            % Gain Interval Practice
            instructionsGainInterval(p,1)
            p.curOverallTrialNum = 1;
            p.practice.isCued = 1;
        elseif p.session.isRewardPenalty
            % Mixed Reward Low Penalty Interval Practice 
            %instructionsLowRewardMixedPenaltyInterval(p,1)
            instructionsMixedRewardLowPenaltyInterval(p,1)
            p.curOverallTrialNum = 1;
            p.practice.isCued = 1;
        end
        
        for intervalNum = 1:p.numPracIntervals
            p.curIntervalNum = intervalNum;
            [p,practice,results] = practiceInterval(p,practice,results);
        end
        instructions(p,'You have finished this practice.',1);

        %% Cued Interval Practice Block 2
        if p.session.isEfficacy
            % Zero Efficacy Interval Practice (Dice Interval Practice)
            instructionsLowEffInterval(p,1)
            p.practice.isCued = 1;
        elseif p.session.isGainLoss
            % Loss Interval Practice
            instructionsLossInterval(p,1)
            p.practice.isCued = 1;
        elseif p.session.isRewardPenalty
            % Mixed Reward High Penalty Interval Practice 
            %instructionsHighRewardMixedPenaltyInterval(p,1)
            instructionsMixedRewardHighPenaltyInterval(p,1)
            p.practice.isCued = 1; 
        end
        
        for intervalNum = p.numPracIntervals+1:p.numPracIntervals*2
            p.curIntervalNum = intervalNum;
            [p,practice,results] = practiceInterval(p,practice,results);
        end
        instructions(p,'You have finished this practice.',1);
        
        
        %% Cued Interval Practice Block 3 - Efficacy Only
        %% Main Task Efficacy Levels Interval Practice (Mixed Efficacy Interval Practice)
        if p.session.isEfficacy % NOTE: should check that this code works, DY edited 1/9/21
            instructionsMixedEffInterval(p,1)
            p.curOverallTrialNum = 1;
            p.practice.isCued = 1;
            
            for intervalNum = 1:p.numPracIntervals
                p.curIntervalNum = intervalNum;
                [p,practice,results] = practiceInterval(p,practice,results);
            end
            instructions(p,'You have finished this practice.',1);
        end
       %% Cued Interval Practice Block 3 & 4 - Reward and Penalty Only
       if p.session.isRewardPenalty
            % Low Reward Mixed Penalty Interval Practice 
            instructionsLowRewardMixedPenaltyInterval(p,1)
            p.practice.isCued = 1; 
            for intervalNum = p.numPracIntervals*2+1:p.numPracIntervals*3
                p.curIntervalNum = intervalNum;
                [p,practice,results] = practiceInterval(p,practice,results);
            end
            instructions(p,'You have finished this practice.',1);
            
            % High Reward Mixed Penalty Interval Practice
            instructionsHighRewardMixedPenaltyInterval(p,1)
            p.practice.isCued = 1;
            for intervalNum = p.numPracIntervals*3+1:p.numPracIntervals*4
                p.curIntervalNum = intervalNum;
                [p,practice,results] = practiceInterval(p,practice,results);
            end
            instructions(p,'You have finished this practice.',1);
        end
        
        
        if p.isScanningVersion == 1
            instructionsCue(p); % This file lives in the project sub-folder
            instructions(p,'You have completed the practice. Please get the experimeter.',1);
        end    

        rmpath(p.session.versionPath);
        clc;
        sca;
    end
end

%% PART 2: Main Task
if (p.isScanningVersion == 0 || (p.isScanningVersion == 1 && p.curSession == 2) || (p.curSession == 3))
    
    % Determining whethe is practice or task
    p.isPracticeSession = 0 ; 
    
    if ~isfield(p,'curBlockNum')
        p.curBlockNum = 0;
    end
    
    % Practice the button pressing in the scanner
    if p.isScanningVersion == 1 && p.curBlockNum == 0
        [p] = practiceScanButtons(p);
        p.curBlockNum = p.curBlockNum + 1;
    end
    
    
%     % If this is the penalty version after TCB (version 104), then we will
%     % run the interval instructions and practice for Penalty without Stroop practice
%     if (p.session.isRewardPenalty == 1 && p.version == 106)
%         instructionsPenaltyInterval(p,1)
%         p.curOverallTrialNum = 1;
%         p.practice.isCued = 1;
%         for intervalNum = 1:p.numPracIntervals
%             p.curIntervalNum = intervalNum;
%             [p,practice,results] = practiceInterval(p,practice,results);
%         end       
%     end
    
    % Post Scanner Task 
    if p.curSession == 3
        if p.curBlockNum == 0 % only run practice at start of post scanner task
            if p.session.isLossPenalty
                
                % Mixed Loss Avoidance Low Penalty Interval Practice
                instructionsMixedLossLowPenaltyInterval(p,1)
                p.curOverallTrialNum = 1;
                p.practice.isCued = 1;
                for intervalNum = 1:p.numPracIntervals
                    p.curIntervalNum = intervalNum;
                    [p,practice,results] = practiceInterval(p,practice,results);
                end
                instructions(p,'You have finished this practice.',1);
                
                % Mixed Loss Avoidance High Penalty Interval Practice
                instructionsMixedLossHighPenaltyInterval(p,1)
                p.practice.isCued = 1;
                for intervalNum = p.numPracIntervals+1:p.numPracIntervals*2
                    p.curIntervalNum = intervalNum;
                    [p,practice,results] = practiceInterval(p,practice,results);
                end
                instructions(p,'You have finished this practice.',1);
                
                % Low Loss Avoidance Mixed Penalty Interval Practice
                instructionsLowLossMixedPenaltyInterval(p,1)
                p.practice.isCued = 1;
                for intervalNum = p.numPracIntervals*2+1:p.numPracIntervals*3
                    p.curIntervalNum = intervalNum;
                    [p,practice,results] = practiceInterval(p,practice,results);
                end
                instructions(p,'You have finished this practice.',1);
                
                % High Loss Avoidance Mixed Penalty Interval Practice
                instructionsHighLossMixedPenaltyInterval(p,1)
                p.practice.isCued = 1;
                
                for intervalNum = p.numPracIntervals*3+1:p.numPracIntervals*4
                    p.curIntervalNum = intervalNum;
                    [p,practice,results] = practiceInterval(p,practice,results);
                end
                instructions(p,'You have finished this practice.',1);
            end
            % After practice blocks, increase to start block (= 1)
            p.curBlockNum = p.curBlockNum + 1;
        end
    end
    
    % Displays the instructions for the main task
    instructionsCueInTask(p);
    
    % if starting task for first time, initialize trial number and total points 
    if p.restart == 0
        p.curOverallTrialNum = 1;                 % Initializes the trial number
        results.interval.totalPoints = 0;         % Initializes the total point count
    elseif p.restart == 1
        % If restarting task, initialize trial number as first trial of restarted block
        p.curOverallTrialNum = find(results.trial.blockNum==p.curBlockNum,1,'first');
    end
    
    if ~isfield(p,'curBlockNum')
        p.curBlockNum = 1;
    end
    
    % Iterates over the number of task blocks
    for blockNum = p.curBlockNum:p.numBlocks
        
        % Sets current block number
        p.curBlockNum = blockNum;
        
        % Displays instructions for the current block
        instructionsBlock(p);
        
        % Runs the block
        [p,practice,results] = block(p,practice,results);
        
        % Text displayed on the screen at the end of the block
        if blockNum == p.numBlocks
            if p.isScanningVersion == 1
                instructions(p,'You have finished the game. Please stay still while the scan finishes.',1);
            else
                instructions(p,'You have finished the study. Please get the experimenter.',1);
            end
            
        else
            if p.isScanningVersion == 1
                instructions(p,'You have finished this block. Please stay still while the scan finishes.',1);
            else
                instructions(p,'You have finished this block. Please get the experimenter.',1);
            end
        end
    end
    
    %% Field Map Fixation
    if p.isScanningVersion == 1
        instructions(p,'You have one more scan that will last about two minutes. You do not need to do anything other than stay still.',1);
        fixation(p,p.color.white);
        WaitSecs(5);
        keyWaitTTL(-1,p.exptrKey)
    end
    
    KbWait(-1);
    rmpath(p.session.versionPath);
    clc;
    sca;
end



