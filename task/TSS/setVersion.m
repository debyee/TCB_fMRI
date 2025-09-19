function p = setVersion(p)
%SETVERSION Defines the task parameters for the study
%   This is a function helper script that defines the parameters for the
%   version of the task we are plan to run. Below are the different
%   cases that correspond to the different iterations or versions.
%   Case 101: TSS Lab version, simple gain and loss avoidance
%   Case 102: TSS Lab version, gamification with mining task (Gem Game)
%   Case 103: TSS Lab version, Gem Game, change reward ratio to 1:100
%   Case 104: TSS Gain vs. Loss, Gem Game, lab version no tracker
%   Case 105: TSS Gain vs. Loss, Gem Game, lab version with tracker
%   Case 106: TSS Gain vs. Penalty, Gem game
%   Case 201: TSS Gain vs. Loss, Gem Game, scanning version
%   Case 202: TSS Gain vs. Penalty, Gem Game, scanning version
%   Case 203: TSS Loss vs. Penalty, Gem Game, scanning version (outside scanner)
%   Case 204: TSS Gain vs. Penalty, Gem Game, scanning version, changed practice to all 4 cells 
%   Case 205: TSS Loss vs. Penalty, Gem Game, scanning version (outside scanner), changed practice to all 4 cells
%   Case 510: TSS FXC OA version, scanning version
%   Case 900: Demo version, abridged for testing code


%% Set version based on input
if ~exist('version','var')
    p.version = input('What is the version number? (e.g., 101): ');
else
    p.version = version;
end


%% Set version params
while 1
    switch p.version
        case 101
            p.interval.cueFolder = 'Images/Cues/GainLoss/Classic/';
            p.interval.feedbackImageFolder = 'Images/Feedback/GainLoss/Classic/';
            p.session.versionPath = 'TCB';
            
            % task version
            p.isTestVersion = 0;
            p.skipPractice = 0;
            p.isScanningVersion = 0;
            
            % define number of practice trials and intervals
            p.numPracTrials.keyMapping = 80;
            p.numPracTrials.stroop = 100;
            p.numPracIntervals = 10;
            
            % define number of task trials and intervals
            p.numTrials = 2500;
            p.numIntervals = 128;
            p.numBlocks = 8;
            p.numIntervalsPerBlock = p.numIntervals/p.numBlocks;
            
            % define efficacy task conditions
            p.stimulus.efficacyValues = [1,1];
            p.noEfficacyLevel = .8;
            
            % define reward task conditions
            p.stimulus.rewardValues = [1,100];
            p.stimulus.rewardText = {'+1','+100'};
            
            % define timing parameters
            p.timing.pracRtDeadline = 1;
            p.timing.pracFbDuration = .75;
            p.timing.cueDuration = 2;
            p.timing.fbAnimationDuration = 1;
            p.timing.fbDuration = 2;
            p.timing.iti.intervalDurationMin = 6;
            p.timing.iti.intervalDurationMax = 9;
            p.timing.iti.intervalDurationBins = 4;
            p.timing.isi = .25;
            p.timing.iti.preCue = 1;
            p.timing.iti.postCue = 1;
            p.response.tooFastWait = .25;
            
            % define response device information
            p.device.num.resp = -1;
            p.responseBox = 0; % 0 = no button box, 1 = button box
            
            p.rollingAccWindowSize = 10;

            % define task session details 
            p.session.isPhysicalEffort = 0;
            p.session.isStroopTask = 1;
            p.removeNeutral = 1;
            p.session.isEfficacy = 0;
            p.session.isGamified = 0;
            p.includeRiskyChoice = 0;
            p.intervalInitialLoss = 1.5;  
            p.initialEndowment = 15;
            p.conversionFactor = 2000; 
            
            
            
            break
            
            
        case 102
            p.interval.cueFolder = 'Images/Cues/GainLoss/Classic/';
            p.interval.feedbackImageFolder = 'Images/Feedback/GainLoss/Classic/';     
            p.session.versionPath = 'TCB';
            
            % task version
            p.isTestVersion = 0;
            p.skipPractice = 0;
            p.isScanningVersion = 0;
            
            % define number of practice trials
            p.numPracTrials.keyMapping = 80;
            p.numPracTrials.stroop = 100;
            p.numPracIntervals = 10;
            
            % define number of task trials
            p.numTrials = 2500;
            p.numIntervals = 128;
            p.numBlocks = 8;
            p.numIntervalsPerBlock = p.numIntervals/p.numBlocks;
            
            % define efficacy task conditions
            p.stimulus.efficacyValues = [1,1];
            p.noEfficacyLevel = .8;
            
            % define reward task conditions
            p.stimulus.rewardValues = [1,10];
            p.stimulus.rewardText = {'+1','+10'};
            
            % define timing parameters 
            p.timing.pracRtDeadline = 1;
            p.timing.pracFbDuration = .75;
            p.timing.cueDuration = 2;
            p.timing.fbAnimationDuration = 1;
            p.timing.fbDuration = 2;
            p.timing.iti.intervalDurationMin = 6;
            p.timing.iti.intervalDurationMax = 9;
            p.timing.iti.intervalDurationBins = 4;
            p.timing.isi = .25;
            p.timing.iti.preCue = 3;
            p.timing.iti.postCue = 1;
            p.response.tooFastWait = .25;
            p.session.isPhysicalEffort = 0;
            p.session.isStroopTask = 1;
            p.removeNeutral = 1;
            
            % define response device information
            p.device.num.resp = -1;
            p.responseBox = 0;
            
            p.rollingAccWindowSize = 10;
             
            % define task session details 
            p.session.isEfficacy = 0;
            p.session.isGamified = 1;
            p.includeRiskyChoice = 0;
            p.intervalInitialLoss = 1.5;
            p.initialEndowment = 15;
            p.conversionFactor = .01;
            p.initialGemEndowment = p.initialEndowment/p.conversionFactor;
            p.numIntSampledPerBlock = 4;
            
            break
            
            
        case 103
            p.interval.cueFolder = 'Images/Cues/GainLoss/Game/';
            p.interval.feedbackImageFolder = 'Images/Feedback/GainLoss/Game/';
            p.session.versionPath = 'TCB';
            
            % task version
            p.isTestVersion = 0;
            p.skipPractice = 0;
            p.isScanningVersion = 0;
            
            % define number of practice trials and intervals
            p.numPracTrials.keyMapping = 80;
            p.numPracTrials.stroop = 100;
            p.numPracIntervals = 8;
            
            % define number of task trials and intervals
            p.numTrials = 2500;
            p.numIntervals = 128;
            p.numBlocks = 8;
            p.numIntervalsPerBlock = p.numIntervals/p.numBlocks;
            
            % define efficacy task conditions
            p.stimulus.efficacyValues = [1,1];
            p.noEfficacyLevel = .8;
            
            % define reward task conditions
            p.stimulus.rewardValues = [1,100];
            p.stimulus.rewardText = {'+1','+100'};
            
            % define timing parameters
            p.timing.pracRtDeadline = 1;
            p.timing.pracFbDuration = .75;
            p.timing.cueDuration = 2;
            p.timing.fbAnimationDuration = 1;
            p.timing.fbDuration = 2;
            p.timing.iti.intervalDurationMin = 6;
            p.timing.iti.intervalDurationMax = 9;
            p.timing.iti.intervalDurationBins = 4;
            p.timing.isi = .25;
            p.timing.iti.preCue = 3;
            p.timing.iti.postCue = 1;
            p.response.tooFastWait = .25;

            % define response device information
            p.device.num.resp = -1;
            p.responseBox = 0;
            
            p.rollingAccWindowSize = 10;
            
            % define task session details 
            p.session.isPhysicalEffort = 0;
            p.session.isStroopTask = 1;
            p.removeNeutral = 1;
            p.session.isEfficacy = 0;
            p.session.isGamified = 1;
            p.includeRiskyChoice = 0;
            p.intervalInitialLoss = 1.5;
            p.initialEndowment = 20;
            p.conversionFactor = .001;
            p.initialGemEndowment = p.initialEndowment/p.conversionFactor;
            p.numIntSampledPerBlock = 4;
            
            break
            
            
        case 104
            p.session.versionPath = 'TCB';
            p.interval.cueFolder = 'Images/Cues/GainLoss/Game/';
            p.interval.feedbackImageFolder = 'Images/Feedback/GainLoss/Game/';
            
            % task version
            p.isTestVersion = 0;
            p.skipPractice = 0;
            p.isScanningVersion = 0;
            
            p.session.isPhysicalEffort = 0;
            p.session.isStroopTask = 1;
            p.session.isGamified = 1;
            p.session.isTracker = 0;
            

            
%             p.interval.cueFolder = 'Images/Cues/RewardPenalty/';
%             p.interval.feedbackImageFolder = 'Images/Feedback/RewardPenalty/';
%             p.session.versionPath = 'RewardPenalty';
            
            % define number of practice trials and intervals
            p.numPracTrials.keyMapping = 80;
            p.numPracTrials.stroop = 100;
            p.numPracIntervals = 8;
            
            % define number of task trials and intervals
            p.numTrials = 2500;
            p.numIntervals = 128;
            p.numBlocks = 8;
            p.numIntervalsPerBlock = p.numIntervals/p.numBlocks;

            % define reward task conditions
            p.stimulus.rewardValues = [1,100];
            p.stimulus.rewardText = {'+1','+100'};

            % define efficacy task conditions
            p.session.isEfficacy = 0;
            p.stimulus.efficacyValues = [1,1];
            
            % define gain/loss task conditions
            p.session.isGainLoss = 1;
            p.stimulus.gainValues = [0,1];
            
            % define penalty task conditions
            p.session.isRewardPenalty = 0;
            p.stimulus.penaltyValues = [0,0];
            
            % define timing parameters
            p.timing.pracRtDeadline = 1;
            p.timing.pracFbDuration = .75;
            p.timing.cueDuration = 2.4;
            p.timing.fbAnimationDuration = 0;
            p.timing.fbDuration = 2.4;
            p.timing.iti.intervalDurationMin = 6;
            p.timing.iti.intervalDurationMax = 8.4;
            p.timing.iti.intervalDurationBins = 4;
            p.timing.isi = .25;
            p.timing.iti.preCueMin = 2.4;
            p.timing.iti.preCueMax = 7.2;
            p.timing.iti.preCueBins = 5;
            p.timing.iti.postCue = 2.4;
            p.response.tooFastWait = .25;

            % define response device information
            p.responseBox = 0;
                        
            % define task session details
            p.removeNeutral = 1;
            p.intervalInitialLoss = 1.5;
            p.initialEndowment = 20;
            p.conversionFactor = .001;
            p.initialGemEndowment = p.initialEndowment/p.conversionFactor;
            p.numIntSampledPerBlock = 4;
            
            break            
        
            
        case 105
            % task version
            p.isTestVersion = 0;
            p.skipPractice = 0;
            p.isScanningVersion = 0;
            
            p.session.isPhysicalEffort = 0;
            p.session.isStroopTask = 1;
            p.session.isGamified = 1;
            p.session.isTracker = 1;
            
            p.session.versionPath = 'TCB';
            p.interval.cueFolder = 'Images/Cues/GainLoss/Game/';
            p.interval.feedbackImageFolder = 'Images/Feedback/GainLoss/Game/';
            
            % define number of practice trials and intervals
            p.numPracTrials.keyMapping = 80;
            p.numPracTrials.stroop = 100;
            p.numPracIntervals = 8;
            
            % define number of task trials and intervals
            p.numTrials = 2500;
            p.numIntervals = 128;
            p.numBlocks = 8;
            p.numIntervalsPerBlock = p.numIntervals/p.numBlocks;

            % define reward task conditions
            p.stimulus.rewardValues = [1,100];
            p.stimulus.rewardText = {'+1','+100'};

            % define efficacy task conditions
            p.session.isEfficacy = 0;
            p.stimulus.efficacyValues = [1,1];
            
            % define gain/loss task conditions
            p.session.isGainLoss = 1;
            p.stimulus.gainValues = [0,1];
            
            % define penalty task conditions
            p.session.isRewardPenalty = 0;
            p.stimulus.penaltyValues = [0,0];
            
            % define timing parameters
            p.timing.pracRtDeadline = 1;
            p.timing.pracFbDuration = .75;
            p.timing.cueDuration = 2.4;
            p.timing.fbAnimationDuration = 0;
            p.timing.fbDuration = 2.4;
            p.timing.iti.intervalDurationMin = 6;
            p.timing.iti.intervalDurationMax = 8.4;
            p.timing.iti.intervalDurationBins = 4;
            p.timing.isi = .25;
            p.timing.iti.preCueMin = 2.4;
            p.timing.iti.preCueMax = 7.2;
            p.timing.iti.preCueBins = 5;
            p.timing.iti.postCue = 2.4;
            p.response.tooFastWait = .25;

            % define response device information
            p.responseBox = 0;
                        
            % define task session details
            p.removeNeutral = 1;
            p.intervalInitialLoss = 1.5;
            p.initialEndowment = 20;
            p.conversionFactor = .001;
            p.initialGemEndowment = p.initialEndowment/p.conversionFactor;
            p.numIntSampledPerBlock = 4;
            
            break            

        case 106
            % task version
            p.isTestVersion = 0;
            p.skipPractice = 1;
            p.isScanningVersion = 0;
            
            p.session.isPhysicalEffort = 0;
            p.session.isStroopTask = 1;
            p.session.isGamified = 1;
            p.session.isTracker = 0;
            
            p.session.versionPath = 'RewardPenalty';
            p.interval.cueFolder = 'Images/Cues/RewardPenalty/Game/';
            p.interval.feedbackImageFolder = 'Images/Feedback/RewardPenalty/Game/';
            
            % define number of practice trials and intervals
            p.numPracTrials.keyMapping = 80;
            p.numPracTrials.stroop = 100;
            p.numPracIntervals = 8;
            
            % define number of task trials and intervals
            p.numTrials = 2500;
            p.numIntervals = 64;
            p.numBlocks = 4;
            p.numIntervalsPerBlock = p.numIntervals/p.numBlocks;

            % define reward task conditions
            p.stimulus.rewardValues = [1,100];
            p.stimulus.rewardText = {'+1','+100'};

            % define efficacy task conditions
            p.session.isEfficacy = 0;
            p.stimulus.efficacyValues = [1,1];
            
            % define gain/loss task conditions
            p.session.isGainLoss = 0;
            p.stimulus.gainValues = [1,1];
            
            % define penalty task conditions
            p.session.isRewardPenalty = 1;
            p.stimulus.penaltyValues = [1,100];
            
            % define timing parameters
            p.timing.pracRtDeadline = 1;
            p.timing.pracFbDuration = .75;
            p.timing.cueDuration = 2.4;
            p.timing.fbAnimationDuration = 0;
            p.timing.fbDuration = 2.4;
            p.timing.iti.intervalDurationMin = 6;
            p.timing.iti.intervalDurationMax = 8.4;
            p.timing.iti.intervalDurationBins = 4;
            p.timing.isi = .25;
            p.timing.iti.preCueMin = 2.4;
            p.timing.iti.preCueMax = 7.2;
            p.timing.iti.preCueBins = 5;
            p.timing.iti.postCue = 2.4;
            p.response.tooFastWait = .25;

            % define response device information
            p.responseBox = 0;
                        
            % define task session details
            p.removeNeutral = 1;
            p.intervalInitialLoss = 1.5;
            p.initialEndowment = 0;
            p.conversionFactor = .001;
            p.initialGemEndowment = p.initialEndowment/p.conversionFactor;
            p.numIntSampledPerBlock = 4;
            
            break                        
            
        case 201
            % task version
            p.isTestVersion = 0;
            p.skipPractice = 0;
            p.isScanningVersion = 1;
            
            p.session.isPhysicalEffort = 0;
            p.session.isStroopTask = 1;
            p.session.isGamified = 1;
            p.session.isTracker = 0;
            
            p.session.versionPath = 'TCB';
            p.interval.cueFolder = 'Images/Cues/GainLoss/Game/';
            p.interval.feedbackImageFolder = 'Images/Feedback/GainLoss/Game/';
            
            % define number of practice trials and intervals
            p.numPracTrials.keyMapping = 80;
            p.numPracTrials.stroop = 100;
            p.numPracIntervals = 8;
            
            % define number of task trials and intervals
            p.numTrials = 2500;
            p.numIntervals = 128;
            p.numBlocks = 8;
            p.numIntervalsPerBlock = p.numIntervals/p.numBlocks;
            
            % define reward task conditions
            p.stimulus.rewardValues = [1,100];
            p.stimulus.rewardText = {'+1','+100'};
            
            % define efficacy task conditions
            p.session.isEfficacy = 0;
            p.stimulus.efficacyValues = [1,1];
            
            % define gain/loss task conditions
            p.session.isGainLoss = 1;
            p.stimulus.gainValues = [0,1];
            
            % define penalty task conditions
            p.session.isRewardPenalty = 0;
            p.stimulus.penaltyValues = [0,0];
            
            % define timing parameters
            p.timing.pracRtDeadline = 1;
            p.timing.pracFbDuration = .75;
            p.timing.cueDuration = 2.4;
            p.timing.fbAnimationDuration = 0;
            p.timing.fbDuration = 2.4;
            p.timing.iti.intervalDurationMin = 6;
            p.timing.iti.intervalDurationMax = 8.4;
            p.timing.iti.intervalDurationBins = 4;
            p.timing.isi = .25;
            p.timing.iti.preCueMin = 2.4;
            p.timing.iti.preCueMax = 7.2;
            p.timing.iti.preCueBins = 5;
            p.timing.iti.postCue = 2.4;
            p.response.tooFastWait = .25;

            % define response device information
            p.responseBox = 0;
            
            % define task session details 
            
            p.removeNeutral = 1;
            p.intervalInitialLoss = 1.5;
            p.initialEndowment = 20;
            p.conversionFactor = .001;
            p.initialGemEndowment = p.initialEndowment/p.conversionFactor;
            p.numIntSampledPerBlock = 4;
                    
            break            
        
        case 202
            % task version
            p.isTestVersion = 0;
            p.skipPractice = 0;
            p.isScanningVersion = 1;
            
            p.session.isPhysicalEffort = 0;
            p.session.isStroopTask = 1;
            p.session.isGamified = 1;
            p.session.isTracker = 0;
            
            p.session.versionPath = 'TCB_RewardPenalty';
            p.interval.cueFolder = 'Images/Cues/RewardPenalty/Game/';
            p.interval.feedbackImageFolder = 'Images/Feedback/RewardPenalty/Game/';
            
            % define number of practice trials and intervals
            p.numPracTrials.keyMapping = 80;
            p.numPracTrials.stroop = 100;
            p.numPracIntervals = 8;
            
            % define number of task trials and intervals
            p.numTrials = 2500;
            p.numIntervals = 128;
            p.numBlocks = 8;
            p.numIntervalsPerBlock = p.numIntervals/p.numBlocks;
            
            % define number of practiceScanButton trials
            p.numPracticeScanButtons = 24;
            
            %%% VARS FOR TESTING
            p.debug = 0; % 1 = debugging on computer, 0 = actual task
            if p.debug == 1
                debugTask = input('CAUTION: This is debug mode. Continue? (Yes = 1, No = 0): ');
                    while 1
                        switch debugTask
                            case 1 
                                break
                            case 0
                                error('runTSS is stopped to avoid running debug mode.')
                            otherwise
                                debugTask = (input('Invalid debug mode response, please enter again (Yes = 1, No = 0): '));
                        end
                    end
                
                p.numPracTrials.keyMapping = 8;
                p.numPracTrials.stroop = 8;
                p.numPracIntervals = 4;
                
                p.numTrials = 1000;
                p.numIntervals = 32;
                p.numBlocks = 4;
                p.numIntervalsPerBlock = p.numIntervals/p.numBlocks;
                
                p.numPracticeScanButtons = 2;
            end
            
            % define reward task conditions
            p.stimulus.rewardValues = [1,100];
            p.stimulus.rewardText = {'+1','+100'};
            
            % define efficacy task conditions
            p.session.isEfficacy = 0;
            p.stimulus.efficacyValues = [1,1];
            
            % define gain/loss task conditions
            % Gain = 1, Loss = 0;
            p.session.isGainLoss = 0;
            p.stimulus.gainValues = [1,1]; 
            
            % define penalty task conditions (for reward-penalty task)
            p.session.isRewardPenalty = 1;
            p.stimulus.penaltyValues = [1,100];
            
            % define timing parameters
            p.timing.pracRtDeadline = 1;
            p.timing.pracFbDuration = .75;
            p.timing.cueDuration = 2.4;
            p.timing.fbAnimationDuration = 0;
            p.timing.fbDuration = 2.4;
            p.timing.iti.intervalDurationMin = 6;
            p.timing.iti.intervalDurationMax = 8.4;
            p.timing.iti.intervalDurationBins = 4;
            p.timing.isi = .25;
            p.timing.iti.preCueMin = 2.4;
            p.timing.iti.preCueMax = 7.2;
            p.timing.iti.preCueBins = 5;
            p.timing.iti.postCue = 2.4;
            p.response.tooFastWait = .25;

            % define response device information
            p.responseBox = 0;
            
            % define task session details 
            p.removeNeutral = 1;
            p.intervalInitialLoss = 1.5;
            p.initialEndowment = 0;
            p.conversionFactor = .001;
            p.initialGemEndowment = p.initialEndowment/p.conversionFactor;
            p.numIntSampledPerBlock = 4;
                    
            break         

            
case 203
            % task version
            p.isTestVersion = 0;
            p.skipPractice = 1;
            p.isScanningVersion = 0;
            p.isPostScanningVersion = 1;
            
            p.session.isPhysicalEffort = 0;
            p.session.isStroopTask = 1;
            p.session.isGamified = 1;
            p.session.isTracker = 0;
            
            p.session.versionPath = 'TCB_LossPenalty';
            p.interval.cueFolder = 'Images/Cues/LossPenalty/Game/';
            p.interval.feedbackImageFolder = 'Images/Feedback/LossPenalty/Game/';
            
            % define number of practice trials and intervals
            p.numPracTrials.keyMapping = 80;
            p.numPracTrials.stroop = 100;
            p.numPracIntervals = 8; 
            
            % define number of task trials and intervals
            p.numTrials = 2500;
            p.numIntervals = 64;
            p.numBlocks = 4;
            p.numIntervalsPerBlock = p.numIntervals/p.numBlocks;
            
            % define number of practiceScanButton trials
            p.numPracticeScanButtons = 24;
            
            %%% VARS FOR TESTING
            p.debug = 1; % 1 = debugging on computer, 0 = actual task
            if p.debug == 1
                debugTask = input('CAUTION: This is debug mode. Continue? (Yes = 1, No = 0): ');
                    while 1
                        switch debugTask
                            case 1 
                                break
                            case 0
                                error('runTSS is stopped to avoid running debug mode.')
                            otherwise
                                debugTask = (input('Invalid debug mode response, please enter again (Yes = 1, No = 0): '));
                        end
                    end               
                
                p.numPracTrials.keyMapping = 8;
                p.numPracTrials.stroop = 8;
                p.numPracIntervals = 4;
                
                p.numTrials = 1000;
                p.numIntervals = 32;
                p.numBlocks = 4;
                p.numIntervalsPerBlock = p.numIntervals/p.numBlocks;
                
                p.numPracticeScanButtons = 2;
            end
            
            % define reward task conditions (for correct responses)
            % note: relevant for loss avoidance as well.
            p.stimulus.rewardValues = [1,100];
            p.stimulus.rewardText = {'+1','+100'};
            
            % define efficacy task conditions
            p.session.isEfficacy = 0;
            p.stimulus.efficacyValues = [1,1];
            
            % define gain/loss task conditions
            % Gain = 1, Loss Avoidance = 0;
            p.session.isGainLoss = 0;
            p.stimulus.gainValues = [0,0];          
            
            % define penalty task conditions (for reward-penalty or loss-penalty task)
            p.session.isRewardPenalty = 0;
            p.session.isLossPenalty = 1;
            p.stimulus.penaltyValues = [1,100];
            
            % define timing parameters
            p.timing.pracRtDeadline = 1;
            p.timing.pracFbDuration = .75;
            p.timing.cueDuration = 2.4;
            p.timing.fbAnimationDuration = 0;
            p.timing.fbDuration = 2.4;
            p.timing.iti.intervalDurationMin = 6;
            p.timing.iti.intervalDurationMax = 8.4;
            p.timing.iti.intervalDurationBins = 4;
            p.timing.isi = .25;
            p.timing.iti.preCueMin = 2.4;
            p.timing.iti.preCueMax = 7.2;
            p.timing.iti.preCueBins = 5;
            p.timing.iti.postCue = 2.4;
            p.response.tooFastWait = .25;

            % define response device information
            p.responseBox = 0;
            
            % define task session details 
            p.removeNeutral = 1;
            p.intervalInitialLoss = 1.5;
            p.initialEndowment = 20;
            p.conversionFactor = .001;
            p.initialGemEndowment = p.initialEndowment/p.conversionFactor;
            p.initialBombsPerTurn = p.intervalInitialLoss/p.conversionFactor;
            p.numIntSampledPerBlock = 4;
                    
            break         

case 204
            % task version
            p.isTestVersion = 0;
            p.skipPractice = 0;
            p.isScanningVersion = 1;
            
            p.session.isPhysicalEffort = 0;
            p.session.isStroopTask = 1;
            p.session.isGamified = 1;
            p.session.isTracker = 0;
            
            p.session.versionPath = 'TCB_RewardPenalty';
            p.interval.cueFolder = 'Images/Cues/RewardPenalty/Game/';
            p.interval.feedbackImageFolder = 'Images/Feedback/RewardPenalty/Game/';
            
            % define number of practice trials and intervals
            p.numPracTrials.keyMapping = 80;
            p.numPracTrials.stroop = 100;
            p.numPracIntervals = 4;
            
            % define number of task trials and intervals
            p.numTrials = 2500;
            p.numIntervals = 128;
            p.numBlocks = 8;
            p.numIntervalsPerBlock = p.numIntervals/p.numBlocks;
            
            % define number of practiceScanButton trials
            p.numPracticeScanButtons = 24;
            
            %%% VARS FOR TESTING
            p.debug = 0; % 1 = debugging on computer, 0 = actual task
            if p.debug == 1
                debugTask = input('CAUTION: This is debug mode. Continue? (Yes = 1, No = 0): ');
                    while 1
                        switch debugTask
                            case 1 
                                break
                            case 0
                                error('runTSS is stopped to avoid running debug mode.')
                            otherwise
                                debugTask = (input('Invalid debug mode response, please enter again (Yes = 1, No = 0): '));
                        end
                    end
                
                p.numPracTrials.keyMapping = 4;
                p.numPracTrials.stroop = 4;
                p.numPracIntervals = 4;
                
                p.numTrials = 1000;
                p.numIntervals = 32;
                p.numBlocks = 4;
                p.numIntervalsPerBlock = p.numIntervals/p.numBlocks;
                
                p.numPracticeScanButtons = 2;
            end
            
            % define reward task conditions
            p.stimulus.rewardValues = [1,100];
            p.stimulus.rewardText = {'+1','+100'};
            
            % define efficacy task conditions
            p.session.isEfficacy = 0;
            p.stimulus.efficacyValues = [1,1];
            
            % define gain/loss task conditions
            % Gain = 1, Loss = 0;
            p.session.isGainLoss = 0;
            p.stimulus.gainValues = [1,1]; 
            
            % define penalty task conditions (for reward-penalty task)
            p.session.isRewardPenalty = 1;
            p.session.isLossPenalty = 0;
            p.stimulus.penaltyValues = [1,100];
            
            % define timing parameters
            p.timing.pracRtDeadline = 1;
            p.timing.pracFbDuration = .75;
            p.timing.cueDuration = 2.4;
            p.timing.fbAnimationDuration = 0;
            p.timing.fbDuration = 2.4;
            p.timing.iti.intervalDurationMin = 6;
            p.timing.iti.intervalDurationMax = 8.4;
            p.timing.iti.intervalDurationBins = 4;
            p.timing.isi = .25;
            p.timing.iti.preCueMin = 2.4;
            p.timing.iti.preCueMax = 7.2;
            p.timing.iti.preCueBins = 5;
            p.timing.iti.postCue = 2.4;
            p.response.tooFastWait = .25;

            % define response device information
            p.responseBox = 0;
            
            % define task session details 
            p.removeNeutral = 1;
            p.intervalInitialLoss = 1.5;
            p.initialEndowment = 0;
            p.conversionFactor = .001;
            p.initialGemEndowment = p.initialEndowment/p.conversionFactor;
            p.numIntSampledPerBlock = 4;
                    
            break         

            
case 205
            % task version
            p.isTestVersion = 0;
            p.skipPractice = 1;
            p.isScanningVersion = 0;
            p.isPostScanningVersion = 1;
            
            p.session.isPhysicalEffort = 0;
            p.session.isStroopTask = 1;
            p.session.isGamified = 1;
            p.session.isTracker = 0;
            
            p.session.versionPath = 'TCB_LossPenalty';
            p.interval.cueFolder = 'Images/Cues/LossPenalty/Game/';
            p.interval.feedbackImageFolder = 'Images/Feedback/LossPenalty/Game/';
            
            % define number of practice trials and intervals
            p.numPracTrials.keyMapping = 80;
            p.numPracTrials.stroop = 100;
            p.numPracIntervals = 4; 
            
            % define number of task trials and intervals
            p.numTrials = 2500;
            p.numIntervals = 64;
            p.numBlocks = 4;
            p.numIntervalsPerBlock = p.numIntervals/p.numBlocks;
            
            % define number of practiceScanButton trials
            p.numPracticeScanButtons = 24;
            
            %%% VARS FOR TESTING
            p.debug = 0; % 1 = debugging on computer, 0 = actual task
            if p.debug == 1
                debugTask = input('CAUTION: This is debug mode. Continue? (Yes = 1, No = 0): ');
                    while 1
                        switch debugTask
                            case 1 
                                break
                            case 0
                                error('runTSS is stopped to avoid running debug mode.')
                            otherwise
                                debugTask = (input('Invalid debug mode response, please enter again (Yes = 1, No = 0): '));
                        end
                    end               
                
                p.numPracTrials.keyMapping = 8;
                p.numPracTrials.stroop = 8;
                p.numPracIntervals = 4;
                
                p.numTrials = 1000;
                p.numIntervals = 32;
                p.numBlocks = 4;
                p.numIntervalsPerBlock = p.numIntervals/p.numBlocks;
                
                p.numPracticeScanButtons = 2;
            end
            
            % define reward task conditions (for correct responses)
            % note: relevant for loss avoidance as well.
            p.stimulus.rewardValues = [1,100];
            p.stimulus.rewardText = {'+1','+100'};
            
            % define efficacy task conditions
            p.session.isEfficacy = 0;
            p.stimulus.efficacyValues = [1,1];
            
            % define gain/loss task conditions
            % Gain = 1, Loss Avoidance = 0;
            p.session.isGainLoss = 0;
            p.stimulus.gainValues = [0,0];          
            
            % define penalty task conditions (for reward-penalty or loss-penalty task)
            p.session.isRewardPenalty = 0;
            p.session.isLossPenalty = 1;
            p.stimulus.penaltyValues = [1,100];
            
            % define timing parameters
            p.timing.pracRtDeadline = 1;
            p.timing.pracFbDuration = .75;
            p.timing.cueDuration = 2.4;
            p.timing.fbAnimationDuration = 0;
            p.timing.fbDuration = 2.4;
            p.timing.iti.intervalDurationMin = 6;
            p.timing.iti.intervalDurationMax = 8.4;
            p.timing.iti.intervalDurationBins = 4;
            p.timing.isi = .25;
            p.timing.iti.preCueMin = 2.4;
            p.timing.iti.preCueMax = 7.2;
            p.timing.iti.preCueBins = 5;
            p.timing.iti.postCue = 2.4;
            p.response.tooFastWait = .25;

            % define response device information
            p.responseBox = 0;
            
            % define task session details 
            p.removeNeutral = 1;
            p.intervalInitialLoss = 1.5;
            p.initialEndowment = 24;
            p.conversionFactor = .001;
            p.initialGemEndowment = p.initialEndowment/p.conversionFactor;
            p.initialBombsPerTurn = p.intervalInitialLoss/p.conversionFactor;
            p.numIntSampledPerBlock = 4;
                    
            break                     
            
            
        case 501
            % task version
            p.isTestVersion = 0;
            p.skipPractice = 0;
            p.isScanningVersion = 1;
            
            % define number of practice trials and intervals
            p.numPracTrials.keyMapping = 80;
            p.numPracTrials.stroop = 100;
            p.numPracIntervals = 8;
            
            % define number of task trials and intervals
            p.numTrials = 2500;
            p.numIntervals = 128;
            p.numBlocks = 8;
            p.numIntervalsPerBlock = p.numIntervals/p.numBlocks;
            
            % define number of practiceScanButton trials
            p.numPracticeScanButtons = 24;
            
            %%% VARS FOR TESTING
            p.debug = 0; % 1 = debugging on computer, 0 = actual task
            if p.debug == 1
                p.numPracTrials.keyMapping = 2;
                p.numPracTrials.stroop = 2;
                p.numPracIntervals = 4;
                
                p.numTrials = 1000;
                p.numIntervals = 128;
                p.numBlocks = 8;
                p.numRiskyChoiceTrials = 5;
                
                p.numPracticeScanButtons = 2;
            end

            % define efficacy task conditions
            p.session.isEfficacy = 1;
            p.stimulus.efficacyValues = [0.1,0.9];              % represents percent based on performance
            p.stimulus.practiceEfficacyValues = [0.0,1.0];      % represents percent based on performance
%             p.noEfficacyLevel = .8;                           % Probably from old FXC version?
            p.rollingAccWindowSize = 10;
            p.isGoalVersion = 0;
            p.onlineFeedback = 0;
            
            % define reward task conditions
            p.stimulus.rewardValues = [1,100];
            p.stimulus.rewardText = {'+1','+100'};
            
            % define gain/loss task conditions
            p.session.isGainLoss = 0;
            p.stimulus.gainValues = [1,1];
            
            % define penalty task conditions
            p.session.isRewardPenalty = 0;
            p.stimulus.penaltyValues = [0,0];
                  
            
            % define timing parameters
            p.timing.pracRtDeadline = 1;
            p.timing.pracFbDuration = .75;
            p.timing.cueDuration = 2.4;
            p.timing.fbAnimationDuration = 0;
            p.timing.fbDuration = 2.4;
            p.timing.iti.intervalDurationMin = 6;
            p.timing.iti.intervalDurationMax = 8.4;
            p.timing.iti.intervalDurationBins = 4;
            p.timing.isi = .25;
            p.timing.iti.preCueMin = 2.4;
            p.timing.iti.preCueMax = 7.2;
            p.timing.iti.preCueBins = 5;
            p.timing.iti.postCue = 2.4;
            p.response.tooFastWait = .25;

            % define response device information
            p.device.num.resp = -1;
            p.responseBox = 0;
            
            % define task session details 
            p.session.isPhysicalEffort = 0;
            p.session.isStroopTask = 1;
            p.removeNeutral = 1;
            p.session.isGamified = 1;
            p.includeRiskyChoice = 0;
            p.intervalInitialLoss = 1.5;
            p.initialEndowment = 20;
            p.conversionFactor = .001;
            p.initialGemEndowment = p.initialEndowment/p.conversionFactor;
            p.numIntSampledPerBlock = 4;
            
            p.interval.cueFolder = 'Images/Cues/Efficacy/';
            p.interval.feedbackImageFolder = 'Images/Feedback/Efficacy/';
            p.session.versionPath = 'FXC_OA';
            
            break 
        
        case 900
            
            p.session.isPhysicalEffort = 0;
            p.session.isStroopTask = 1;
            p.session.isGamified = 1;
            p.session.isTracker = 1;
            
            p.session.versionPath = 'TCB';
            p.interval.cueFolder = 'Images/Cues/GainLoss/Game/';
            p.interval.feedbackImageFolder = 'Images/Feedback/GainLoss/Game/';
            
            % task version
            p.isTestVersion = 1;
            p.skipPractice = 0;
            p.isScanningVersion = 0;
           
            % define number of practice trials and intervals
            p.numPracTrials.keyMapping = 2;
            p.numPracTrials.stroop = 2;
            p.numPracIntervals = 2;
            
            % define number of task trials and intervals
            p.numTrials = 1000;
            p.numIntervals = 128;
            p.numBlocks = 8;
            p.numIntervalsPerBlock = p.numIntervals/p.numBlocks;
            
            % define efficacy task conditions
            p.stimulus.efficacyLevels = [1];
            p.stimulus.efficacyValues = [1];
            p.noEfficacyLevel = .8;
            
            % define reward task conditions
            p.stimulus.rewardValues = [1,100];
            p.stimulus.rewardText = {'+1','+100'};
            
            % define timing parameters
            p.timing.pracRtDeadline = 1;
            p.timing.pracFbDuration = .75;
            p.timing.cueDuration = 2;
            p.timing.fbAnimationDuration = 1;
            p.timing.fbDuration = 2;
            p.timing.intervalDurationOptions = [6:9];
            p.timing.isi = .25;
            p.timing.iti.preCue = 3;
            p.timing.iti.postCue = 1;
            p.response.tooFastWait = .25;

            % define response device information
            p.device.num.resp = -1;
            p.responseBox = 0;
            
            p.rollingAccWindowSize = 10;
            
            % define task session details 
            p.session.isPhysicalEffort = 0;
            p.session.isStroopTask = 1;
            p.removeNeutral = 1;
            p.session.isEfficacy = 0;
            p.session.isGamified = 1;
            p.includeRiskyChoice = 0;
            p.intervalInitialLoss = 1.5;
            p.initialEndowment = 20;
            p.conversionFactor = .001;
            p.initialGemEndowment = p.initialEndowment/p.conversionFactor;
            p.numIntSampledPerBlock = 4;
            
            break
            
            
        otherwise
            p.version = (input('Invalid version number, please enter again: '));
    end
end

end

