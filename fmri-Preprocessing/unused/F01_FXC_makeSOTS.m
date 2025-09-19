
%% Goal:
% Generate design matrices for first level analyses of individual subjects

% Does: loops through subjects and generates an SOT folder with the
% design matrices to be used in the first level analyses

%%
clear;


basepath = '/gpfs/data/ashenhav/mri-data/FXCI/';
basepathMR = '/gpfs/data/ashenhav/mri-data/FXCI/spm-data';
basepathBehav = '/gpfs/data/ashenhav/mri-data/FXCI/behavior/'; 


%basepathBehav = '~/Dropbox (Brown)/CLPS-Shenhavlab/experiments/FXC_Interval/FXC_Interval/Results/'; %for testing purposes
addpath('/gpfs/data/ashenhav/mri-data/FXCI/scripts'); % to access e.g. AS_nanzscore and later potentially other useful functions
% note: copy any functions that are needed to scripts folder on Oscar - may
% also need to copy Stimulus.m 

tic()
%% PLACEHOLDERS:
exSubs = [5000]; %
excludeSubRuns(1,:) = [9999,1];

%% Start group loop

chdir(basepath);

allResultsB = dir([basepathBehav, 'FXC_Interval_50*mat']);
allResultsB = {allResultsB(:).name};

for subi=1:length(allResultsB)
    
    % gets current subject file
    curSub = allResultsB{subi};
    curSubStr = curSub(14:17);
    % subject ID
    curSubNum = str2num(curSubStr);
    
    % do we want that guy?
    curFinalExclude = ~isempty(find(exSubs==curSubNum));
    
    % if we do: 
    if ~curFinalExclude
        
        % move to MR data folder
        chdir(basepathMR);
        
        % get this subject's folder name:
        % files are named differently when they come out of BIDS, so we need to
        % add a prefix to the subID for the subject folder names
        curSubMR = ['sub-' curSubStr];
        
        % make them a directory if it doesn't exist
        if ~exist(curSubMR,'dir')
            mkdir(curSubMR);
        end
        chdir([basepathMR, '/',curSubMR])
        
        %%%%  ------------ get some variables we need ----------
        
        % load their behavioral data
        load(fullfile(basepathBehav,allResultsB{subi}));
        
        % get the timing-relevant variables
        numBlocks = p.numBlocks;
        TRlength = p.TRlength;
        numBlockStartTRs = p.numStartDummyScans; % we will subtract this from the true block TR number to determine timing relative to the first scan 

        % neither are currently used.
        cueDur = p.timing.cueDuration;
        fbDur = p.timing.fbDuration;
        

        %% ------------------------------- get Timing -----------------------------------

            % In the analyses later on, we will concatenate the images
            % across runs, but only those during the actual block, not the
            % Dummie scans before block start
            % TRs and not whatever happened after the block ended. 
            % All timings therefore need to be relative to the
            % beginning of the beginning of the first block. 
            % Here's how we do it: 


        % for each block, get the end time (relative to beginning of
        % that block), convert to TRs and subtract the number of the first x-many dummie TRs which we will skip
        % in the 1st level script later.

        tmpnumActualBlockTRs = round(ceil(results.timing.scanBlockEndRelative/TRlength)- (numBlockStartTRs)); % how many real block TRs are in each block?        
        if curSubNum == 5030
            tmpnumActualBlockTRs(8) = 255;
        elseif curSubNum== 5048
            tmpnumActualBlockTRs(3) = 251;
            tmpnumActualBlockTRs(4) = 251;
        end
        % from this info, we get how many TRs have passed by each block
        % end since beginning of experiment by computing the cumulative sum
        tmpcumBlockTRs = cumsum(tmpnumActualBlockTRs); 
        % from that, we get the number of TRs at beginning of each block, 
        %(0 on the first and then the passed TRs on each previous block), multiply by TR to return to time space
        tmpcumOnsetTRins = [0, tmpcumBlockTRs(1:end-1)]*TRlength; 
        
        % we will want to add this to all timings in the relevant block, so
        % we make a variable that allows us to do that.

        tmpAllOnsetAdder = sort(repmat(tmpcumOnsetTRins, [1, p.numIntervalsPerBlock])); % use that only for the interval level stuff. 
        
        % adding this to have the proper variable with block start TRs for
        % trial-level variables
        tmpAllTrialOnsetAdder = repelem(tmpcumOnsetTRins, sum(results.timing.trial.stimOnsetRelative>0,2)'); % 

        % we will now add the tmpAllOnsetAdder/tmpAllTrialOnsetAdder to our event onsets below
                
        
        %% get event onsets 
        % The relative Onsets are to the block onset. Each block has x-many
        % empty TRs though before things begin, that's why we subtract that
        % (these TRs are removed in the next script as mentioned above, so
        % we need to do this for the timing to match up.)

        % all cues
        tmpAllOns_cue = tmpAllOnsetAdder + sum(results.timing.interval.cueOnsetRelative) - (TRlength*numBlockStartTRs); 
        % all intervals
        tmpAllOns_interval = tmpAllOnsetAdder + sum(results.timing.interval.respWindowOnsetRelative) - (TRlength*numBlockStartTRs);
        % all feedback
        tmpAllOns_fb = tmpAllOnsetAdder + sum(results.timing.interval.fbOnsetRelative) - (TRlength*numBlockStartTRs); 

        % adding info for responses so that we can model errors as separate
        % events by subsetting this - we need to know when the response was
        % given
        tmpAllOns_tresp = tmpAllTrialOnsetAdder + sum(results.timing.trial.stimOnsetRelative,1) + results.trial.responseTime - (TRlength*numBlockStartTRs);
        tmpAllOns_terr = tmpAllOns_tresp(results.trial.acc==0);
        
        % durations
        tmpAllIntervalDur = results.timing.intervalEnd - results.timing.intervalStart; %because p.interval.length is the intended, but not the factual duration

        %% get event info
              
        % trial
        % incentive condition
        tmpAllTrialRewLevels = 2*( results.trial.rewardLevel-0.5); % highvlowReward
        tmpAllTrialEffLevels = 2*(results.trial.effLevel-0.5); % highvlowEfficacy
        
        % congruency
        tmpAllstimCongruency = [p.stimuli(:).IsCongruent];
        tmpAllTrialCongruency = tmpAllstimCongruency(1:length(tmpAllTrialEffLevels));

        % performance
        tmpAllTrialRT = results.trial.responseTime;
        tmpAllTrialAccuracy = results.trial.acc;
        tmpMissedTrials = isnan(tmpAllTrialAccuracy);
        
        tmpSubResp = results.trial.resp;
        tmpSubZRt = AS_nanzscore(tmpAllTrialRT); % z-score


        % interval
        % incentive condition
        tmpIntervalRewLevels = 2*(results.interval.rewLevel- 0.5); % highvlowReward
        tmpIntervalEffLevels = 2*(results.interval.effLevel-0.5); % highvlowEfficacy

        % there is a variable called results.trial.intervalNum that will
        % help us compute interval level congruency and behavior.

        tmpMeanIntervalCongruency = nan(size(tmpIntervalRewLevels));
        tmpMeanIntervalAccuracy   = nan(size(tmpIntervalRewLevels));
        tmpMeanIntervalRT   = nan(size(tmpIntervalRewLevels));
        for ii = 1:max(results.trial.intervalNum)
            tmpMeanIntervalCongruency(ii) = nanmean(tmpAllTrialCongruency(results.trial.intervalNum==ii));
            tmpMeanIntervalAccuracy(ii) = nanmean(tmpAllTrialAccuracy(results.trial.intervalNum==ii));
            tmpMeanIntervalRT(ii) = nanmean(tmpAllTrialRT(results.trial.intervalNum==ii));
        end
        
       
        % center covariates
        tmpcMeanIntervalCongruency = tmpMeanIntervalCongruency - nanmean(tmpMeanIntervalCongruency);
        tmpcMeanIntervalAccuracy = tmpMeanIntervalAccuracy - nanmean(tmpMeanIntervalAccuracy);
        tmpcMeanIntervalRT = tmpMeanIntervalRT- nanmean(tmpMeanIntervalRT);
        %%% add in IntervalLength + IntervalNum %%%
        tmpcIntervalDur = tmpAllIntervalDur - mean(tmpAllIntervalDur);
        tmpcIntervalNum = unique(results.trial.intervalNum)- mean(unique(results.trial.intervalNum));


        % feedback 
        tmpAllRew_fb = results.interval.reward; % what reward they got
        
        % additional feedback information (not saved out for subjects with
        % IDs < 5008)
        try
        
            tmpIntervalIsPerformanceFB = results.interval.isPerformanceBased;
            tmpRandomReward = results.interval.randomReward;
            tmpPerformanceReward = results.interval.earnedReward;

        end


        %% ------------------------------------- Define GLMS --------------------------------------------------
        %% GLM 1-3: Defining different conditions as different events
        
        % GLM 1) Basic version modeling all trials as single condition, only
        % cues
        allSOTSconds_Cues = []; % setting up this basic model
       
        % event 1 - 4 valid trials, cue conditions
        allSOTSconds_Cues(1).name = 'HEHR'; 
        allSOTSconds_Cues(1).ons = tmpAllOns_cue(tmpIntervalEffLevels==1 & tmpIntervalRewLevels==1 & ~isnan(tmpMeanIntervalRT)); 
        allSOTSconds_Cues(1).dur = 0; 
        allSOTSconds_Cues(1).orth = 0;
        allSOTSconds_Cues(1).P(1).name = 'none'; 
        allSOTSconds_Cues(2).name = 'HELR';
        allSOTSconds_Cues(2).ons = tmpAllOns_cue(tmpIntervalEffLevels==1 & tmpIntervalRewLevels== -1 & ~isnan(tmpMeanIntervalRT)); 
        allSOTSconds_Cues(2).dur = 0; 
        allSOTSconds_Cues(2).orth = 0;
        allSOTSconds_Cues(2).P(1).name = 'none'; 
        allSOTSconds_Cues(3).name = 'LEHR'; 
        allSOTSconds_Cues(3).ons = tmpAllOns_cue(tmpIntervalEffLevels==-1 & tmpIntervalRewLevels==1 & ~isnan(tmpMeanIntervalRT)); 
        allSOTSconds_Cues(3).dur = 0; 
        allSOTSconds_Cues(3).orth = 0;
        allSOTSconds_Cues(3).P(1).name = 'none'; 
        allSOTSconds_Cues(4).name = 'LELR'; 
        allSOTSconds_Cues(4).ons = tmpAllOns_cue(tmpIntervalEffLevels==-1 & tmpIntervalRewLevels==-1 & ~isnan(tmpMeanIntervalRT)); 
        allSOTSconds_Cues(4).dur = 0; 
        allSOTSconds_Cues(4).orth = 0;
        allSOTSconds_Cues(4).P(1).name = 'none'; 
        if any(results.trial.acc==0) 
            % (4) Errors
            allSOTSconds_Cues(5).name = 'Error';
            allSOTSconds_Cues(5).ons = tmpAllOns_terr;
            allSOTSconds_Cues(5).dur = 0;
            allSOTSconds_Cues(5).orth = 0; 
            allSOTSconds_Cues(5).P(1).name = 'none';
        end
        if any(isnan(tmpMeanIntervalRT))
            allSOTSconds_Cues(end+1).name = 'Missing';
            allSOTSconds_Cues(end).ons = tmpAllOns_cue(isnan(tmpMeanIntervalRT));
            allSOTSconds_Cues(end).dur = 0;
            allSOTSconds_Cues(end).orth = 0; 
            allSOTSconds_Cues(end).P(1).name = 'none';
        end


        
        % GLM 2) cue and interval (add interval)
        % event 1-4 valid cues (definitions from previous model)
        allSOTSconds_Cue_Interval = allSOTSconds_Cues(1:4); 
        % 5-8 intervals
        allSOTSconds_Cue_Interval(5).name = 'HEHRInt'; 
        allSOTSconds_Cue_Interval(5).ons = tmpAllOns_interval(tmpIntervalEffLevels==1 & tmpIntervalRewLevels==1 & ~isnan(tmpMeanIntervalRT)); 
        allSOTSconds_Cue_Interval(5).dur = tmpAllIntervalDur(tmpIntervalEffLevels==1 & tmpIntervalRewLevels==1 & ~isnan(tmpMeanIntervalRT)); 
        allSOTSconds_Cue_Interval(5).orth = 0; 
        allSOTSconds_Cue_Interval(5).P(1).name = 'none'; 
        allSOTSconds_Cue_Interval(6).name = 'HELRInt';
        allSOTSconds_Cue_Interval(6).ons = tmpAllOns_interval(tmpIntervalEffLevels==1 & tmpIntervalRewLevels== -1 & ~isnan(tmpMeanIntervalRT)); 
        allSOTSconds_Cue_Interval(6).dur = tmpAllIntervalDur(tmpIntervalEffLevels==1 & tmpIntervalRewLevels== -1 & ~isnan(tmpMeanIntervalRT)); 
        allSOTSconds_Cue_Interval(6).orth = 0; 
        allSOTSconds_Cue_Interval(6).P(1).name = 'none'; 
        allSOTSconds_Cue_Interval(7).name = 'LEHRInt'; 
        allSOTSconds_Cue_Interval(7).ons = tmpAllOns_interval(tmpIntervalEffLevels==-1 & tmpIntervalRewLevels==1 & ~isnan(tmpMeanIntervalRT)); 
        allSOTSconds_Cue_Interval(7).dur = tmpAllIntervalDur(tmpIntervalEffLevels==-1 & tmpIntervalRewLevels==1 & ~isnan(tmpMeanIntervalRT)); 
        allSOTSconds_Cue_Interval(7).orth = 0; 
        allSOTSconds_Cue_Interval(7).P(1).name = 'none'; 
        allSOTSconds_Cue_Interval(8).name = 'LELRInt'; 
        allSOTSconds_Cue_Interval(8).ons = tmpAllOns_interval(tmpIntervalEffLevels==-1 & tmpIntervalRewLevels==-1 & ~isnan(tmpMeanIntervalRT)); 
        allSOTSconds_Cue_Interval(8).dur = tmpAllIntervalDur(tmpIntervalEffLevels==-1 & tmpIntervalRewLevels==-1 & ~isnan(tmpMeanIntervalRT)); 
        allSOTSconds_Cue_Interval(8).orth = 0; 
        allSOTSconds_Cue_Interval(8).P(1).name = 'none'; 
        
        if any(results.trial.acc==0) 
            % (9) Errors
            allSOTSconds_Cue_Interval(9).name = 'Error';
            allSOTSconds_Cue_Interval(9).ons = tmpAllOns_terr;
            allSOTSconds_Cue_Interval(9).dur = 0;
            allSOTSconds_Cue_Interval(9).orth = 0; 
            allSOTSconds_Cue_Interval(9).P(1).name = 'none';
        end
        if any(isnan(tmpMeanIntervalRT))
            allSOTSconds_Cue_Interval(end+1).name = 'Missing';
            allSOTSconds_Cue_Interval(end).ons = tmpAllOns_cue(isnan(tmpMeanIntervalRT));
            allSOTSconds_Cue_Interval(end).dur = 0;
            allSOTSconds_Cue_Interval(end).orth = 0; 
            allSOTSconds_Cue_Interval(end).P(1).name = 'none';
            allSOTSconds_Cue_Interval(end+1).name = 'MissingInt';
            allSOTSconds_Cue_Interval(end).ons = tmpAllOns_interval(isnan(tmpMeanIntervalRT));
            allSOTSconds_Cue_Interval(end).dur = tmpAllIntervalDur(isnan(tmpMeanIntervalRT));
            allSOTSconds_Cue_Interval(end).orth = 0; 
            allSOTSconds_Cue_Interval(end).P(1).name = 'none';
        end
        
        % GLM 3) Three timepoint version (cue,interval, feedback)
        % event 1-4 valid cues, 5-8 intervals (previous model)
        allSOTSconds_Cue_Interval_FB = allSOTSconds_Cue_Interval(1:8); % setting up this basic model
        
        % event 9:12 feedback
        allSOTSconds_Cue_Interval_FB(9).name = 'HEHRFB'; 
        allSOTSconds_Cue_Interval_FB(9).ons = tmpAllOns_fb(tmpIntervalEffLevels==1 & tmpIntervalRewLevels==1 & ~isnan(tmpMeanIntervalRT)); 
        allSOTSconds_Cue_Interval_FB(9).dur = 0; 
        allSOTSconds_Cue_Interval_FB(9).orth = 0; 
        allSOTSconds_Cue_Interval_FB(9).P(1).name = 'none'; 
        allSOTSconds_Cue_Interval_FB(10).name = 'HELRFB';
        allSOTSconds_Cue_Interval_FB(10).ons = tmpAllOns_fb(tmpIntervalEffLevels==1 & tmpIntervalRewLevels== -1 & ~isnan(tmpMeanIntervalRT)); 
        allSOTSconds_Cue_Interval_FB(10).dur = 0; 
        allSOTSconds_Cue_Interval_FB(10).orth = 0; 
        allSOTSconds_Cue_Interval_FB(10).P(1).name = 'none'; 
        allSOTSconds_Cue_Interval_FB(11).name = 'LEHRFB'; 
        allSOTSconds_Cue_Interval_FB(11).ons = tmpAllOns_fb(tmpIntervalEffLevels==-1 & tmpIntervalRewLevels==1 & ~isnan(tmpMeanIntervalRT)); 
        allSOTSconds_Cue_Interval_FB(11).dur = 0; 
        allSOTSconds_Cue_Interval_FB(11).orth = 0; 
        allSOTSconds_Cue_Interval_FB(11).P(1).name = 'none'; 
        allSOTSconds_Cue_Interval_FB(12).name = 'LELRFB'; 
        allSOTSconds_Cue_Interval_FB(12).ons = tmpAllOns_fb(tmpIntervalEffLevels==-1 & tmpIntervalRewLevels==-1 & ~isnan(tmpMeanIntervalRT)); 
        allSOTSconds_Cue_Interval_FB(12).dur = 0;
        allSOTSconds_Cue_Interval_FB(12).orth = 0;
        allSOTSconds_Cue_Interval_FB(12).P(1).name = 'none';

        if any(results.trial.acc==0)
            % (13) Errors
            allSOTSconds_Cue_Interval_FB(13).name = 'Error';
            allSOTSconds_Cue_Interval_FB(13).ons = tmpAllOns_terr;
            allSOTSconds_Cue_Interval_FB(13).dur = 0;
            allSOTSconds_Cue_Interval_FB(13).orth = 0;
            allSOTSconds_Cue_Interval_FB(13).P(1).name = 'none';
        end

        if any(isnan(tmpMeanIntervalRT))
            allSOTSconds_Cue_Interval_FB(end+1).name = 'Missing';
            allSOTSconds_Cue_Interval_FB(end).ons = tmpAllOns_cue(isnan(tmpMeanIntervalRT));
            allSOTSconds_Cue_Interval_FB(end).dur = 0;
            allSOTSconds_Cue_Interval_FB(end).orth = 0;
            allSOTSconds_Cue_Interval_FB(end).P(1).name = 'none';
            allSOTSconds_Cue_Interval_FB(end+1).name = 'MissingInt';
            allSOTSconds_Cue_Interval_FB(end).ons = tmpAllOns_interval(isnan(tmpMeanIntervalRT));
            allSOTSconds_Cue_Interval_FB(end).dur = tmpAllIntervalDur(isnan(tmpMeanIntervalRT));
            allSOTSconds_Cue_Interval_FB(end).orth = 0;
            allSOTSconds_Cue_Interval_FB(end).P(1).name = 'none';
            allSOTSconds_Cue_Interval_FB(end+1).name = 'MissingFB';
            allSOTSconds_Cue_Interval_FB(end).ons = tmpAllOns_fb(isnan(tmpMeanIntervalRT));
            allSOTSconds_Cue_Interval_FB(end).dur = 0;
            allSOTSconds_Cue_Interval_FB(end).orth = 0;
            allSOTSconds_Cue_Interval_FB(end).P(1).name = 'none';
        end
        %% -----------------------  Parametric modulator models  ----------------------------------
        %% templates
        % these will be modified below by adding parametric modulators for
        % the different events and just define the basic events that happen (just cue, cue and interval, cue, interval & FB).

        % 1) Basic version modeling all trials as single condition, only
        % cues
        template = []; % setting up this basic model
        % has 1 event type of interest (cue) and additionally models errors
        % event 1 - interval cues
        template(1).name = 'AllTrials'; % name
        template(1).ons = tmpAllOns_cue(~isnan(tmpMeanIntervalRT)); % when? assign all cue onsets for all blocks
        template(1).dur = 0; % duration (0 = stick)
        template(1).orth = 0;
        template(1).P(1).name = 'none'; % we don't have regressors here yet
        % event 2 - add errors
        if any(results.trial.acc==0)
            template(2).name = 'Errors'; % name
            template(2).ons = tmpAllOns_terr; % when? assign all error onsets for all blocks
            template(2).dur = 0; % duration (0 = stick)
            template(2).orth = 0;
            template(2).P(1).name = 'none'; % we don't have regressors here yet
        end
        if any(isnan(tmpMeanIntervalRT))
            template(end+1).name = 'Missing';
            template(end).ons = tmpAllOns_cue(isnan(tmpMeanIntervalRT));
            template(end).dur = 0;
            template(end).orth = 0;
            template(end).P(1).name = 'none';

        end

        % 2) Two time-point version (cue and interval)
        template_2tp = []; % setting up this basic model
        % (1) cues
        template_2tp(1).name = 'AllTrials_cue';
        template_2tp(1).ons = tmpAllOns_cue(~isnan(tmpMeanIntervalRT));
        template_2tp(1).dur = 0;
        template_2tp(1).orth = 0;
        template_2tp(1).P(1).name = 'none';
        % (2) intervals
        template_2tp(2).name = 'AllTrials_int';
        template_2tp(2).ons = tmpAllOns_interval(~isnan(tmpMeanIntervalRT));
        template_2tp(2).dur = tmpAllIntervalDur(~isnan(tmpMeanIntervalRT)); % the full duration of interval
        template_2tp(2).orth = 0;
        template_2tp(2).P(1).name = 'none';
        if any(results.trial.acc==0)
            % (3) errors
            template_2tp(3).name = 'Errors';
            template_2tp(3).ons = tmpAllOns_terr;
            template_2tp(3).dur = 0;
            template_2tp(3).orth = 0;
            template_2tp(3).P(1).name = 'none';
        end

        if any(isnan(tmpMeanIntervalRT))
            template_2tp(end+1).name = 'Missing';
            template_2tp(end).ons = tmpAllOns_cue(isnan(tmpMeanIntervalRT));
            template_2tp(end).dur = 0;
            template_2tp(end).orth = 0;
            template_2tp(end).P(1).name = 'none';
            template_2tp(end+1).name = 'MissingInt';
            template_2tp(end).ons = tmpAllOns_interval(isnan(tmpMeanIntervalRT));
            template_2tp(end).dur = tmpAllIntervalDur(isnan(tmpMeanIntervalRT));
            template_2tp(end).orth = 0;
            template_2tp(end).P(1).name = 'none';
        end

        % 3) Three timepoint version (cue, interval, feedback)
        template_3tp = []; % setting up this basic model
        % (1) cues
        template_3tp(1).name = 'AllTrials_cue';
        template_3tp(1).ons = tmpAllOns_cue(~isnan(tmpMeanIntervalRT));
        template_3tp(1).dur = 0;
        template_3tp(1).orth = 0;
        template_3tp(1).P(1).name = 'none';
        % (2) intervals
        template_3tp(2).name = 'AllTrials_int';
        template_3tp(2).ons = tmpAllOns_interval(~isnan(tmpMeanIntervalRT)); % It includes all onsets
        template_3tp(2).dur = tmpAllIntervalDur(~isnan(tmpMeanIntervalRT)); % the full duration of the interval
        template_3tp(2).orth = 0;
        template_3tp(2).P(1).name = 'none';
        % (3) feedback
        template_3tp(3).name = 'AllTrials_fb';
        template_3tp(3).ons = tmpAllOns_fb(~isnan(tmpMeanIntervalRT));
        template_3tp(3).dur = 0;
        template_3tp(3).orth = 0;
        template_3tp(3).P(1).name = 'none';
        if any(results.trial.acc==0)
            % (4) missed trial cues
            template_3tp(4).name = 'Error';
            template_3tp(4).ons = tmpAllOns_terr;
            template_3tp(4).dur = 0;
            template_3tp(4).orth = 0;
            template_3tp(4).P(1).name = 'none';
        end

        if any(isnan(tmpMeanIntervalRT))
            template_3tp(end+1).name = 'Missing';
            template_3tp(end).ons = tmpAllOns_cue(isnan(tmpMeanIntervalRT));
            template_3tp(end).dur = 0;
            template_3tp(end).orth = 0;
            template_3tp(end).P(1).name = 'none';
            template_3tp(end+1).name = 'MissingInt';
            template_3tp(end).ons = tmpAllOns_interval(isnan(tmpMeanIntervalRT));
            template_3tp(end).dur = tmpAllIntervalDur(isnan(tmpMeanIntervalRT));
            template_3tp(end).orth = 0;
            template_3tp(end).P(1).name = 'none';
            template_3tp(end+1).name = 'MissingFB';
            template_3tp(end).ons = tmpAllOns_fb(isnan(tmpMeanIntervalRT));
            template_3tp(end).dur = 0;
            template_3tp(end).orth = 0;
            template_3tp(end).P(1).name = 'none';
        end
        
        %% 
        % GLM 1 
        % 
        % event for each cue with 
        % 
        % PMOD efficacy, reward, and their interaction
        % 
        % event for interval start (1st target/cue offset, interval duration)
        % 
        % with PMOD efficacy, reward and interaction, 
        % 
        % PMOD for interval congruency
        % 
        % event for feedback
        % 
        % event for each error response
        
        % pREC --> parametric Reward, Efficacy, Congruency 
        allSOTSconds_cif_pREC = template_3tp; % we copy the 3 time-point template and add the modulators
        allSOTSconds_cif_pREC(1).P(1).name = 'isHighRew'; 
        allSOTSconds_cif_pREC(1).P(1).P = tmpIntervalRewLevels(~isnan(tmpMeanIntervalRT)); % 1 when reward is high, -1 otherwise
        allSOTSconds_cif_pREC(1).P(1).h = 1; % polynomial, here linear - increase for quadratic, cubic... 
        allSOTSconds_cif_pREC(1).P(2).name = 'isHighEff'; 
        allSOTSconds_cif_pREC(1).P(2).P = tmpIntervalEffLevels(~isnan(tmpMeanIntervalRT)); % 1 when efficacy is high, -1 otherwise
        allSOTSconds_cif_pREC(1).P(2).h = 1; 
        allSOTSconds_cif_pREC(1).P(3).name = 'isHighEffxisHighRew';  
        allSOTSconds_cif_pREC(1).P(3).P = 2*(((tmpIntervalEffLevels(~isnan(tmpMeanIntervalRT))==1).*(tmpIntervalRewLevels(~isnan(tmpMeanIntervalRT))==1))-0.5); % 1 when both reward and efficacy are high, -1 otherwise
        allSOTSconds_cif_pREC(1).P(3).h = 1;
        allSOTSconds_cif_pREC(1).P(4).name = 'IntervalNum';  
        allSOTSconds_cif_pREC(1).P(4).P = tmpcIntervalNum(~isnan(tmpMeanIntervalRT)); % 1 when both reward and efficacy are high, -1 otherwise
        allSOTSconds_cif_pREC(1).P(4).h = 1;

       % interval modulators
        allSOTSconds_cif_pREC(2).P(1).name = 'isHighRew_Int';  
        allSOTSconds_cif_pREC(2).P(1).P = tmpIntervalRewLevels(~isnan(tmpMeanIntervalRT));
        allSOTSconds_cif_pREC(2).P(1).h = 1; 
        allSOTSconds_cif_pREC(2).P(2).name = 'isHighEff_Int';  
        allSOTSconds_cif_pREC(2).P(2).P = tmpIntervalEffLevels(~isnan(tmpMeanIntervalRT));
        allSOTSconds_cif_pREC(2).P(2).h = 1; 
        allSOTSconds_cif_pREC(2).P(3).name = 'isHighEffxisHighRew_Int';  
        allSOTSconds_cif_pREC(2).P(3).P = 2*(((tmpIntervalEffLevels(~isnan(tmpMeanIntervalRT))==1).*(tmpIntervalRewLevels(~isnan(tmpMeanIntervalRT))==1))-0.5); 
        allSOTSconds_cif_pREC(2).P(3).h = 1;
        allSOTSconds_cif_pREC(2).P(4).name = 'meanCongruency';  
        allSOTSconds_cif_pREC(2).P(4).P = tmpcMeanIntervalCongruency(~isnan(tmpMeanIntervalRT));
        allSOTSconds_cif_pREC(2).P(4).h = 1;
        allSOTSconds_cif_pREC(2).P(5).name = 'IntervalNum';  
        allSOTSconds_cif_pREC(2).P(5).P = tmpcIntervalNum(~isnan(tmpMeanIntervalRT));
        allSOTSconds_cif_pREC(2).P(5).h = 1;
        allSOTSconds_cif_pREC(2).P(6).name = 'IntervalDur';  
        allSOTSconds_cif_pREC(2).P(6).P = tmpcIntervalDur(~isnan(tmpMeanIntervalRT));
        allSOTSconds_cif_pREC(2).P(6).h = 1;


        % GLM 2

        % event for each cue with 
        % 
        % PMOD efficacy, reward, and their interaction
        % 
        % event for interval start (1st target/cue offset, interval duration)
        % 
        % with PMOD efficacy, reward and interaction, 
        % 
        % PMOD for interval congruency
        % 
        % PMOD average RT
        % 
        % PMOD average accuracy (?)
        % 
        % event for feedback
        % 
        % event for each error response
        % pRECRT --> parametric Reward, Efficacy, Congruency, RT 
         allSOTSconds_cif_pRECRT = allSOTSconds_cif_pREC; % copy first model
         allSOTSconds_cif_pRECRT(2).P(end+1).name = 'meanRT';  % add additional pMOD to Interval event
         allSOTSconds_cif_pRECRT(2).P(end).P = tmpcMeanIntervalRT(~isnan(tmpMeanIntervalRT));
         allSOTSconds_cif_pRECRT(2).P(end).h = 1;
         
         % GLM 3 with mean accuracy, too
         allSOTSconds_cif_pRECRTACC = allSOTSconds_cif_pRECRT; % copy first model
         allSOTSconds_cif_pRECRTACC(2).P(end+1).name = 'meanAcc';  % add additional pMOD to Interval event
         allSOTSconds_cif_pRECRTACC(2).P(end).P = tmpcMeanIntervalAccuracy(~isnan(tmpMeanIntervalRT));
         allSOTSconds_cif_pRECRTACC(2).P(end).h = 1;

         %% add GLM4 with interactions of incentives and performance (on interval?)
         allSOTSconds_cif_pRECRTIA = allSOTSconds_cif_pRECRTACC; % copy first model
         allSOTSconds_cif_pRECRTIA(2).P(end+1).name = 'isHighRewxRT';  % add additional pMOD to Interval event
         allSOTSconds_cif_pRECRTIA(2).P(end).P = tmpIntervalRewLevels(~isnan(tmpMeanIntervalRT)).*tmpMeanIntervalRT(~isnan(tmpMeanIntervalRT));
         allSOTSconds_cif_pRECRTIA(2).P(end).h = 1;
         allSOTSconds_cif_pRECRTIA(2).P(end+1).name = 'isHighEffxRT';  % add additional pMOD to Interval event
         allSOTSconds_cif_pRECRTIA(2).P(end).P = tmpIntervalEffLevels(~isnan(tmpMeanIntervalRT)).*tmpMeanIntervalRT(~isnan(tmpMeanIntervalRT));
         allSOTSconds_cif_pRECRTIA(2).P(end).h = 1;
         allSOTSconds_cif_pRECRTIA(2).P(end+1).name = 'isHighEffxisHighRewxRT';  % add additional pMOD to Interval event
         allSOTSconds_cif_pRECRTIA(2).P(end).P = 2*(((tmpIntervalEffLevels(~isnan(tmpMeanIntervalRT))==1).*(tmpIntervalRewLevels(~isnan(tmpMeanIntervalRT))==1))-0.5).*tmpMeanIntervalRT(~isnan(tmpMeanIntervalRT));
         allSOTSconds_cif_pRECRTIA(2).P(end).h = 1;

        %% for single trial extraction:
        allSOTSconds_AllIntervals_cue = [];
        allSOTSconds_AllIntervals_interval = [];
        allSOTSconds_AllIntervals_fb = [];
        allSOTSconds_AllIntervals_allEv = [];
        % put everything in one model instead and then grab the relevant
        % betas all from that one model
        for trialind = 1:length(tmpAllOns_cue)
            allSOTSconds_AllIntervals_cue(trialind).name = ['Trial',num2str(trialind)];
            allSOTSconds_AllIntervals_cue(trialind).ons = tmpAllOns_cue(trialind);
            allSOTSconds_AllIntervals_cue(trialind).dur = 0;
            allSOTSconds_AllIntervals_cue(trialind).orth = 0;
            allSOTSconds_AllIntervals_cue(trialind).P(1).name = 'none';
            
            allSOTSconds_AllIntervals_interval(trialind).name = ['Trial',num2str(trialind)];
            allSOTSconds_AllIntervals_interval(trialind).ons = tmpAllOns_interval(trialind);
            allSOTSconds_AllIntervals_interval(trialind).dur = tmpAllIntervalDur(trialind);
            allSOTSconds_AllIntervals_interval(trialind).orth = 0;
            allSOTSconds_AllIntervals_interval(trialind).P(1).name = 'none';
            
            allSOTSconds_AllIntervals_fb(trialind).name = ['Trial',num2str(trialind)];
            allSOTSconds_AllIntervals_fb(trialind).ons = tmpAllOns_fb(trialind);
            allSOTSconds_AllIntervals_fb(trialind).dur = 0;
            allSOTSconds_AllIntervals_fb(trialind).orth = 0;
            allSOTSconds_AllIntervals_fb(trialind).P(1).name = 'none';

            % add another model that has everything in there at once
            
            allSOTSconds_AllIntervals_allEv(trialind).name = ['Cue',num2str(trialind)];
            allSOTSconds_AllIntervals_allEv(trialind).ons = tmpAllOns_cue(trialind);
            allSOTSconds_AllIntervals_allEv(trialind).dur = 0;
            allSOTSconds_AllIntervals_allEv(trialind).orth = 0;
            allSOTSconds_AllIntervals_allEv(trialind).P(1).name = 'none';

            allSOTSconds_AllIntervals_allEv(trialind + length(tmpAllOns_cue)).name = ['Interval',num2str(trialind)];
            allSOTSconds_AllIntervals_allEv(trialind + length(tmpAllOns_cue)).ons = tmpAllOns_cue(trialind);
            allSOTSconds_AllIntervals_allEv(trialind + length(tmpAllOns_cue)).dur = 0;
            allSOTSconds_AllIntervals_allEv(trialind + length(tmpAllOns_cue)).orth = 0;
            allSOTSconds_AllIntervals_allEv(trialind + length(tmpAllOns_cue)).P(1).name = 'none';

            allSOTSconds_AllIntervals_allEv(trialind + 2*length(tmpAllOns_cue)).name = ['FB',num2str(trialind)];
            allSOTSconds_AllIntervals_allEv(trialind + 2*length(tmpAllOns_cue)).ons = tmpAllOns_cue(trialind);
            allSOTSconds_AllIntervals_allEv(trialind + 2*length(tmpAllOns_cue)).dur = 0;
            allSOTSconds_AllIntervals_allEv(trialind + 2*length(tmpAllOns_cue)).orth = 0;
            allSOTSconds_AllIntervals_allEv(trialind + 2*length(tmpAllOns_cue)).P(1).name = 'none';
            
        end

        % add other variables
        %Interval and Feedback to cue
        allSOTSconds_AllIntervals_cue(end+1).name = 'IntervalOns';
        allSOTSconds_AllIntervals_cue(end).ons = tmpAllOns_interval(~isnan(tmpMeanIntervalRT));
        allSOTSconds_AllIntervals_cue(end).dur =tmpAllIntervalDur(~isnan(tmpMeanIntervalRT));
        allSOTSconds_AllIntervals_cue(end).orth = 0;
        allSOTSconds_AllIntervals_cue(end).P(1).name = 'none';

        allSOTSconds_AllIntervals_cue(end+1).name = 'AllTrials_fb';
        allSOTSconds_AllIntervals_cue(end).ons = tmpAllOns_fb(~isnan(tmpMeanIntervalRT));
        allSOTSconds_AllIntervals_cue(end).dur = 0;
        allSOTSconds_AllIntervals_cue(end).orth = 0;
        allSOTSconds_AllIntervals_cue(end).P(1).name = 'none';
        
        %Cue and Feedback to Interval
        allSOTSconds_AllIntervals_interval(end+1).name = 'AllTrials_cue';
        allSOTSconds_AllIntervals_interval(end).ons = tmpAllOns_cue(~isnan(tmpMeanIntervalRT));
        allSOTSconds_AllIntervals_interval(end).dur = 0;
        allSOTSconds_AllIntervals_interval(end).orth = 0;
        allSOTSconds_AllIntervals_interval(end).P(1).name = 'none';

        allSOTSconds_AllIntervals_interval(end+1).name = 'AllTrials_fb';
        allSOTSconds_AllIntervals_interval(end).ons = tmpAllOns_fb(~isnan(tmpMeanIntervalRT));
        allSOTSconds_AllIntervals_interval(end).dur = 0;
        allSOTSconds_AllIntervals_interval(end).orth = 0;
        allSOTSconds_AllIntervals_interval(end).P(1).name = 'none';

        % Cue and Interval to Feedback
        allSOTSconds_AllIntervals_fb(end+1).name = 'AllTrials_cue';
        allSOTSconds_AllIntervals_fb(end).ons = tmpAllOns_cue(~isnan(tmpMeanIntervalRT));
        allSOTSconds_AllIntervals_fb(end).dur = 0;
        allSOTSconds_AllIntervals_fb(end).orth = 0;
        allSOTSconds_AllIntervals_fb(end).P(1).name = 'none';

        allSOTSconds_AllIntervals_fb(end+1).name = 'IntervalOns';
        allSOTSconds_AllIntervals_fb(end).ons = tmpAllOns_interval(~isnan(tmpMeanIntervalRT));
        allSOTSconds_AllIntervals_fb(end).dur = tmpAllIntervalDur(~isnan(tmpMeanIntervalRT));
        allSOTSconds_AllIntervals_fb(end).orth = 0;
        allSOTSconds_AllIntervals_fb(end).P(1).name = 'none';

        if any(results.trial.acc==0)
            % (4) errors trials
            allSOTSconds_AllIntervals_cue(end+1).name = 'Error';
            allSOTSconds_AllIntervals_cue(end).ons = tmpAllOns_terr;
            allSOTSconds_AllIntervals_cue(end).dur =0;
            allSOTSconds_AllIntervals_cue(end).orth = 0;
            allSOTSconds_AllIntervals_cue(end).P(1).name = 'none';

            allSOTSconds_AllIntervals_interval(end+1).name = 'Error';
            allSOTSconds_AllIntervals_interval(end).ons = tmpAllOns_terr;
            allSOTSconds_AllIntervals_interval(end).dur = 0;
            allSOTSconds_AllIntervals_interval(end).orth = 0;
            allSOTSconds_AllIntervals_interval(end).P(1).name = 'none';

            allSOTSconds_AllIntervals_fb(end+1).name = 'Error';
            allSOTSconds_AllIntervals_fb(end).ons = tmpAllOns_terr;
            allSOTSconds_AllIntervals_fb(end).dur = 0;
            allSOTSconds_AllIntervals_fb(end).orth = 0;
            allSOTSconds_AllIntervals_fb(end).P(1).name = 'none';

            allSOTSconds_AllIntervals_allEv(end+1).name = 'Error';
            allSOTSconds_AllIntervals_allEv(end).ons = tmpAllOns_terr;
            allSOTSconds_AllIntervals_allEv(end).dur = 0;
            allSOTSconds_AllIntervals_allEv(end).orth = 0;
            allSOTSconds_AllIntervals_allEv(end).P(1).name = 'none';

        end

        if any(isnan(tmpMeanIntervalRT))
            % Interval and Feedback to Cue
            allSOTSconds_AllIntervals_cue(end+1).name = 'MissingInt';
            allSOTSconds_AllIntervals_cue(end).ons = tmpAllOns_interval(isnan(tmpMeanIntervalRT));
            allSOTSconds_AllIntervals_cue(end).dur =tmpAllIntervalDur(isnan(tmpMeanIntervalRT));
            allSOTSconds_AllIntervals_cue(end).orth = 0;
            allSOTSconds_AllIntervals_cue(end).P(1).name = 'none';

            allSOTSconds_AllIntervals_cue(end+1).name = 'MissingFB';
            allSOTSconds_AllIntervals_cue(end).ons = tmpAllOns_fb(isnan(tmpMeanIntervalRT));
            allSOTSconds_AllIntervals_cue(end).dur = 0;
            allSOTSconds_AllIntervals_cue(end).orth = 0;
            allSOTSconds_AllIntervals_cue(end).P(1).name = 'none';

            % Cue and Feedback to Interval
            allSOTSconds_AllIntervals_interval(end+1).name = 'MissingCue';
            allSOTSconds_AllIntervals_interval(end).ons = tmpAllOns_cue(isnan(tmpMeanIntervalRT));
            allSOTSconds_AllIntervals_interval(end).dur = 0;
            allSOTSconds_AllIntervals_interval(end).orth = 0;
            allSOTSconds_AllIntervals_interval(end).P(1).name = 'none';

            allSOTSconds_AllIntervals_interval(end+1).name = 'MissingFB';
            allSOTSconds_AllIntervals_interval(end).ons = tmpAllOns_fb(isnan(tmpMeanIntervalRT));
            allSOTSconds_AllIntervals_interval(end).dur = 0;
            allSOTSconds_AllIntervals_interval(end).orth = 0;
            allSOTSconds_AllIntervals_interval(end).P(1).name = 'none';

            % Cue and Interval to Feedback
            allSOTSconds_AllIntervals_fb(end+1).name = 'MissingCue';
            allSOTSconds_AllIntervals_fb(end).ons = tmpAllOns_cue(isnan(tmpMeanIntervalRT));
            allSOTSconds_AllIntervals_fb(end).dur = 0;
            allSOTSconds_AllIntervals_fb(end).orth = 0;
            allSOTSconds_AllIntervals_fb(end).P(1).name = 'none';

            allSOTSconds_AllIntervals_fb(end+1).name = 'MissingInt';
            allSOTSconds_AllIntervals_fb(end).ons = tmpAllOns_interval(isnan(tmpMeanIntervalRT));
            allSOTSconds_AllIntervals_fb(end).dur = tmpAllIntervalDur(isnan(tmpMeanIntervalRT));
            allSOTSconds_AllIntervals_fb(end).orth = 0;
            allSOTSconds_AllIntervals_fb(end).P(1).name = 'none';

        end


        
        %% These are the SOTS structs I've created above:
        tmpVars=whos; % gets all variables in workspace
        tmpVars = {tmpVars(:).name}; % keeps only their names
        tmpVars = tmpVars(find(strncmp(tmpVars,'allSOTSconds',12))); % selects the ones with allSOTSconds in the beginning
        % MEMO: important to have a unique common beginning for this to
        % work
        
        for tvi=1:length(tmpVars) % ok, so now we loop through these
            curSOTSname = tmpVars{tvi};
            curSOTS = eval(curSOTSname); % gotta love evil eval
            
            names = {curSOTS(:).name};
            onsets = {curSOTS(:).ons};
            durations = {curSOTS(:).dur};
            orth = {curSOTS(:).orth};
            pmod = struct('name',{''},'param',{},'poly',{});
            for pmii = 1:length(curSOTS)
                if isfield(curSOTS(pmii).P,'P')
                    pmod(pmii).name = {curSOTS(pmii).P(:).name};
                    for pmsubi = 1:length(curSOTS(pmii).P)
                        curSOTS(pmii).P(pmsubi).P = (curSOTS(pmii).P(pmsubi).P);
                    end
                    pmod(pmii).param = {curSOTS(pmii).P(:).P};
                    pmod(pmii).poly = {curSOTS(pmii).P(:).h};
                end
            end
            
            subAllSOTSnames{tvi} = curSOTSname;
            
            subAllNames{tvi,1} = names;
            subAllOnsets{tvi,1} = onsets;
            subAllDurs{tvi,1} = durations;
            subAllPmod{tvi,1} = pmod;
            subAllOrth{tvi,1} = orth;
            
            
            clear('names','onsets','durations','pmod', 'orth');
        end
        
        %% Saving out all of the sots files
        
        for tviii = 1:size(subAllPmod,1)
            curSOTSname = subAllSOTSnames{tviii};
            
            modSubAllPmods = subAllPmod(tviii,:);
            
            names = subAllNames{tviii,1};
            onsets = subAllOnsets{tviii,1};
            durations = subAllDurs{tviii,1};
            pmod = modSubAllPmods{1};
            orth = subAllOrth{tviii,1};

            for oi =1:length(onsets)
                if length(find(onsets{oi}<0))>0
                    display(['CRITICAL!!!!!! BAD ONSET FOR SUBJECT: ',p.subID,', ANALYSIS: ',curSOTSname(13:end)]);
                end
                if length((onsets{oi}))==0
                    display(['MISSING EVENTS FOR SUBJECT: ',p.subID,', ANALYSIS: ',curSOTSname(13:end)]);
                end
            end
            
            for p1 = 1:length(pmod)
                for p2 = 1:length(pmod(p1).param)
                    if length(unique(pmod(p1).param{p2}))<=1
                        display(['NO VARIATION IN PMOD ',num2str(p2),...
                            ' FOR COND ',num2str(p1),', SUBJECT: ',p.subID,', ANALYSIS: ',curSOTSname(13:end)]);
                    end
                end
            end
            
            if ~exist('SOTS','dir')
                mkdir('SOTS');
            end

            save(['SOTS/FXCI',curSOTSname(13:end),'_sots_allTcat.mat'],'names','onsets','durations','pmod');
            
            
            clear('names','onsets','durations','pmod');
            
            clear modSubAllPmods;
        end
        clear('subAllNames','subAllOnsets','subAllDurs','subAllPmod');
        
        
    else
        %% Excluded subject
        display(['EXCLUDING ',curSubStr]);
        try
            blah = [];
            save(fullfile(basepathMR,curSubMR,'EXCLUDE.mat'),'blah');
        end
    end
    
    %% Precautionary cleanup:
    clear tmp*; clear allSOTScond*;
    clear p; clear results;
end
toc()
