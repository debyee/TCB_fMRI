function TCB_makeSOTS 
    
    clear all;

    % Set paths 
%     basepath = '/Volumes/TCB'; 
    basepath = '/gpfs/data/ashenhav/mri-data/TCB'; 
    basepathBehav = [basepath,'/data/behavior/raw'];
    basepathFormat = [basepath,'/data/behavior/formatted'];
    basepathMR = [basepath,'/spm-data'];

    %% STUDY INFORMATION:
    STUDYroot = 'TCB';

    %% PLACEHOLDERS:
    exSubs = [2018]; 
    excludeSubRuns(1,:) = [9999,1];
    %numActualBlockTRs = nan; % Excluding initial dummy TRs (DEAL WITH BELOW)

    %% Start group loop
    % Change directories
    chdir(basepath);
    allResultsB = dir([basepathBehav,'/TSS*.mat']);
    allResultsB = {allResultsB(:).name};

    % Read in behavioral interval data
    % Note that these already remove intervals with task bug! ( may have less than <128 intervals)
    data_behav_int = readtable([basepathFormat,'/data_fMRI-TCB_RewardPenalty_Interval.csv']);
    data_behav_trial = readtable([basepathFormat,'/data_fMRI-TCB_RewardPenalty_Trial.csv']);
    
    % read in task bug table tracking intervals removed
    IntRemove = load([basepathFormat,'/allTaskBugIntervalsRemove.mat']);

    for subi=1:length(allResultsB)
        
        % Load the behavioral data for each subject
        load(fullfile(basepathBehav,allResultsB{subi}));
    
        % Get current subject based on matlab filename (this might be redundant, may delete later)
        curSub = allResultsB{subi};
        curSubString = curSub(23:26); % previously curSubMR
        curSubNum = str2num(curSubString);

        % Subset behavioral data for current subject, this already removes
        % the the task bug from the preprocessing script
        % (TCBfMRI_RewardPenalty_DataFormat.m)
        curSubData = data_behav_int(data_behav_int.SubID == curSubNum,:);
        curSubData_trial = data_behav_trial(data_behav_trial.SubID == curSubNum,:);
        
        % Check whether subject should be excluded. 
        tmpSubNum = str2num(p.subID(1:4)); 
        curFinalExclude = ~isempty(find(exSubs==tmpSubNum, 1));
        
        % If subject is not excluded, then created stimulus onsets
        if ~curFinalExclude
            
            % Display text for which subject is currently being processed
            display(['PROCESSING Regressors for Subject ',p.subID]);
            
            % Change to subject folder within MR directory
            % If doesnt exist, then create directory for subject
            chdir(basepathMR);
            if ~exist(['sub-',curSubString],'dir')
                mkdir(['sub-',curSubString]);
            end
            chdir(fullfile(['sub-',curSubString]));

            
            %% Subject Processing: Extract Timing Information for Onsets
            
            % Number of TRs in block, based upon the xnat files (should be 310)
            numTRsInBlock = 310;  
            
            % Calculate blocklength in seconds (should be 372 secs) 
            BlockLengthInSecs = p.TRlength*numTRsInBlock;

            % Calculate time offset to adjust relative timings based on data
            BlockTimeOffset = repelem(0:(p.numBlocks-1),p.numIntervalsPerBlock)*BlockLengthInSecs;
            
            
            %% TASK BUG
            % Identify intervals with the task bug (mismatch between cue
            % and feedback, these were identified previously
            ix_sub = [IntRemove.allTaskBugIntervalsRemove{:,1}] == curSubNum;
            ix_remove = IntRemove.allTaskBugIntervalsRemove{ix_sub,3};
            ix_keep = setdiff(1:length(results.interval.numTrialsResponded),ix_remove);          
            
            
            %% ONSET AND DURATION TIMES
            % EXTRACT Onset and Duration timings for each subject
            % NOTE: TCB2059 ended task block 8 early, accounting for this here:
            if (length(sum(results.timing.interval.intervalEndRelative)) < length(BlockTimeOffset) && curSubNum == 2059) 
                results.timing.interval.intervalStartRelative = [results.timing.interval.intervalStartRelative,nan(p.numBlocks,p.numIntervals - length(results.timing.interval.intervalStartRelative))];
                results.timing.interval.intervalEndRelative = [results.timing.interval.intervalEndRelative,nan(p.numBlocks,p.numIntervals - length(results.timing.interval.intervalEndRelative))];
                results.timing.interval.respWindowOnsetRelative = [results.timing.interval.respWindowOnsetRelative,nan(p.numBlocks,p.numIntervals - length(results.timing.interval.respWindowOnsetRelative))];
                results.timing.interval.respWindowOffsetRelative = [results.timing.interval.respWindowOffsetRelative,nan(p.numBlocks,p.numIntervals - length(results.timing.interval.respWindowOffsetRelative))];
                results.timing.interval.fbOnsetRelative = [results.timing.interval.fbOnsetRelative,nan(p.numBlocks,p.numIntervals - length(results.timing.interval.fbOnsetRelative))];
                results.timing.interval.fbOffsetRelative = [results.timing.interval.fbOffsetRelative,nan(p.numBlocks,p.numIntervals - length(results.timing.interval.fbOffsetRelative))];
            end
            % Interval Onset and Duration (Cue, Response Window, and Feedback)
            tmpAllOnset_intervalstart = plus(sum(results.timing.interval.intervalStartRelative),BlockTimeOffset);
            tmpAllOnset_intervalend = plus(sum(results.timing.interval.intervalEndRelative),BlockTimeOffset);
            tmpAllOnset_intervalduration = tmpAllOnset_intervalend - tmpAllOnset_intervalstart;
            % Cue Onset and Duration
            tmpAllOnset_cuestart = plus(sum(results.timing.interval.intervalStartRelative),BlockTimeOffset);
            tmpAllOnset_cueend = plus(sum(results.timing.interval.intervalEndRelative),BlockTimeOffset);
            tmpAllOnset_cueduration = tmpAllOnset_intervalend - tmpAllOnset_intervalstart;
            % Response Window Onset and Duration 
            tmpAllOnset_responsewindowstart = plus(sum(results.timing.interval.respWindowOnsetRelative),BlockTimeOffset);
            tmpAllOnset_responsewindowend = plus(sum(results.timing.interval.respWindowOffsetRelative),BlockTimeOffset);
            tmpAllOnset_responsewindowduration = tmpAllOnset_responsewindowend - tmpAllOnset_responsewindowstart;
            % Feedback Onset and duration
            tmpAllOnset_feedbackstart = plus(sum(results.timing.interval.fbOnsetRelative),BlockTimeOffset);
            tmpAllOnset_feedbackend = plus(sum(results.timing.interval.fbOffsetRelative),BlockTimeOffset);
            tmpAllOnset_feedbackduration = tmpAllOnset_feedbackend - tmpAllOnset_feedbackstart;
            % Remove intervals with task bug
            tmpAllOnset_cuestart = tmpAllOnset_cuestart(ix_keep);
            tmpAllOnset_responsewindowstart = tmpAllOnset_responsewindowstart(ix_keep);
            tmpAllOnset_responsewindowduration = tmpAllOnset_responsewindowduration(ix_keep);
            tmpAllOnset_feedbackstart = tmpAllOnset_feedbackstart(ix_keep);
            
            %% ERROR TRIALS
            % Identify trials with errors after removing task bug
            ix_trialerror = find(results.trial.acc == 0);               
            ix_trialerrorkeep = ix_trialerror(ismember(results.trial.intervalNum(ix_trialerror),ix_keep)==1);  
            
            % Compute trial onsets, including time offset across blocks 
            Offset_Trial = [0:7].* BlockLengthInSecs;
            BlockTimeOffset_Trial = sum(bsxfun(@times,Offset_Trial',results.timing.trial.stimOnsetRelative ~=0));
            tmpAllTrials_Onset = plus(sum(results.timing.trial.stimOnsetRelative),BlockTimeOffset_Trial);
            tmpAllTrials_RT = results.trial.responseTime;
            
            % Error Trial Onset and Duration
            tmpAllOnset_trialErrorstart = tmpAllTrials_Onset(ix_trialerrorkeep);
            tmpAllOnset_trialErrorduration = tmpAllTrials_RT(ix_trialerrorkeep);
            if isnan(tmpAllOnset_trialErrorduration)
                error('There is a nan in your error trial duration in TCB_makeSOTS.m!')
            end
            
            %% TASK BUG INTERVALS
            tmpAllOnset_intTaskBugstart = tmpAllOnset_intervalstart(ix_remove');
            tmpAllOnset_intTaskBugduration = tmpAllOnset_intervalduration(ix_remove');
            
            
            %% PARMETRIC MODULATOR conditions for regressors
            % High Reward = 1, Low Reward = -1; High Penalty = 1, Low Penalty = -1
            RewCode = curSubData.RewardLevel';
            RewCode(RewCode==0)=-1;
            PenCode = curSubData.PenaltyLevel';
            PenCode(PenCode==0)=-1;
            RewPenCode = RewCode.*PenCode;
            IntervalNum = zscore(curSubData.Interval');
            IntervalLength = zscore(curSubData.IntervalLength_Actual');
             
            % Compute Average RT, ACC, and Congruency for each interval
            tnum = 1; % trial counter
            avgRT = nan(1,length(curSubData.Interval));
            avgACC = nan(1,length(curSubData.Interval));
            avgCONG = nan(1,length(curSubData.Interval));
            % loop over and compute averge RT and ACC for each interval
            for ind = 1:length(curSubData.Interval)
                
                % Subset trials within current interval
                tmpInt = curSubData_trial(curSubData_trial.IntervalNum == curSubData.Interval(ind),:);
                
                % number of trials per interval
                numTrials = unique(tmpInt.TrialsCompletedPerInterval);
                
                % save average accuracy (ACC)
                trials_acc = tmpInt.Accuracy(1:numTrials);
                avgACC(ind) = mean(trials_acc(~isnan(trials_acc)));      
                
                % extract and assign average RT for correct trials only
                trials_RT = tmpInt.RT(1:numTrials);
                if ~isempty(find(trials_acc==0))
                    trials_RT(find(trials_acc==0)) = nan; 
                end
                avgRT(ind) = mean(trials_RT(~isnan(trials_RT))); 
                
                % save average congruency (CONG)
                trials_CONG = tmpInt.Congruency(1:numTrials);
                avgCONG(ind) = mean(trials_CONG);
                
                % increase trial counter
                tnum = tnum + results.interval.numTrialsResponded(ind);                
            end
            
            % Mean center parametric effects avgRT and avgACC
            avgRT_center = avgRT - mean(avgRT(~isnan(avgRT)));
            avgACC_center = avgACC - mean(~isnan(avgACC));
            avgCONG_center = avgCONG - mean(~isnan(avgCONG));
                      
            
%             avgRT = nan(1,length(results.interval.numTrialsResponded));
%             avgACC = nan(1,length(results.interval.numTrialsResponded));
%             avgCONG = nan(1,length(results.interval.numTrialsResponded));
%             % loop over and compute averge RT and ACC for each interval
%             for ind = 1:length(results.interval.numTrialsResponded)
%                 
%                 % number of trials per interval
%                 numTrials = results.interval.numTrialsResponded(ind); 
%                 
%                 % save average accuracy (ACC)
%                 trials_acc = results.trial.acc(tnum:tnum+numTrials-1);
%                 avgACC(ind) = mean(trials_acc(~isnan(trials_acc)));      
%                 
%                 % extract and assign average RT for correct trials only
%                 trials_RT = results.trial.responseTime(tnum:tnum+numTrials-1); 
%                 if ~isempty(find(trials_acc==0))
%                     trials_RT(find(trials_acc==0)) = nan; 
%                 end
%                 avgRT(ind) = mean(trials_RT(~isnan(trials_RT))); 
%                 
%                 % save average congruency (CONG)
%                 
%                 % increase trial counter
%                 tnum = tnum + results.interval.numTrialsResponded(ind);
%                 
%             end      
%             % Remove intervals with task bug
%             avgRT = avgRT(ix_keep);
%             avgACC = avgACC(ix_keep);
            

             
            %% CUE REW-FIXED VS PEN-FIXED INTERVALS
            % Identify Cues as RewFixed or PenFixed
            CueFix = strings(1,height(curSubData));
            % subjects 2011-2020 do not have a block number
            if ~isfield(results.interval,'blockNum')
                results.interval.blockNum = repelem((1:8),16);
            end
            blockNum = results.interval.blockNum(ix_keep);
            curSubData.blockNum = blockNum';           
            for blockid = 1:max(blockNum) % blockid = 1;
                
                % Extract Reward and Penalty Cues for the block
                tmpRewCue = curSubData.RewardLevel(curSubData.blockNum == blockid);
                tmpPenCue = curSubData.PenaltyLevel(curSubData.blockNum == blockid);
                
                % Assign whether Cue is in RewFixed or PenFixed Block
                if (length(unique(tmpRewCue)) == 2) && (length(unique(tmpPenCue)) == 1)
                    CueFix(curSubData.blockNum == blockid) = "PenFixed";
                elseif (length(unique(tmpRewCue)) == 1) && (length(unique(tmpPenCue)) == 2)
                    CueFix(curSubData.blockNum == blockid) = "RewFixed";
                end 
                
            end
            ix_Cue_RewFix = strmatch('RewFixed',CueFix);
            ix_Cue_PenFix = strmatch('PenFixed',CueFix);

            %% Only include intervals with avgRT values (remove intervals with nans!)
            incl_int = find(~isnan(avgRT_center));
            incl_int_Cue_RewFix = intersect(incl_int,ix_Cue_RewFix);
            incl_int_Cue_PenFix = intersect(incl_int,ix_Cue_PenFix);
            
            
            % Remove intervals with mismatch between cue and feedback
            % (Correcting for task code bug)% setdiff(1:length(RewCode),ix_remove)
%             RewCode_acc = RewCode(ix_keep); 
%             PenCode_acc = PenCode(setdiff(1:length(PenCode),ix_remove));
%             tmpAllOnset_cuestart_acc = tmpAllOnset_cuestart(setdiff(1:length(tmpAllOnset_cuestart),ix_remove));
%             tmpAllOnset_responsewindowstart_acc = tmpAllOnset_responsewindowstart(setdiff(1:length(tmpAllOnset_responsewindowstart),ix_remove));
%             tmpAllOnset_responsewindowduration_acc = tmpAllOnset_responsewindowduration(setdiff(1:length(tmpAllOnset_responsewindowduration),ix_remove));
%             tmpAllOnset_feedbackstart_acc = tmpAllOnset_feedbackstart(setdiff(1:length(tmpAllOnset_feedbackstart),ix_remove));
%             tmpAllOnset_intTaskBugstart = tmpAllOnset_intervalstart(ix_remove');
%             tmpAllOnset_intTaskBugduration = tmpAllOnset_intervalduration(ix_remove');
%             avgRT_acc = avgRT(setdiff(1:length(avgRT),ix_remove));
%             avgACC_acc = avgACC(setdiff(1:length(avgACC),ix_remove));
%             IntervalNum_acc = IntervalNum(setdiff(1:length(IntervalNum),ix_remove));
%             IntervalLength_acc = IntervalLength(setdiff(1:length(IntervalLength),ix_remove));
%             CueFix_acc = CueFix(setdiff(1:length(IntervalLength),ix_remove));
%             ix_Cue_RewFix_acc = ix_Cue_RewFix(setdiff(1:length(ix_Cue_RewFix),ix_remove));
%             ix_Cue_PenFix_acc = ix_Cue_PenFix(setdiff(1:length(ix_Cue_PenFix),ix_remove));
            
            %% GLM 1: Cues with 4 Conditions: HighValRew, LowValRew, HighValPen, LowValPen (ignores task performance)
            % Generate Indices for each of the conditions
            index_HRHP = find(curSubData.RewardLevel==1 & curSubData.PenaltyLevel==1);
            index_HRLP = find(curSubData.RewardLevel==1 & curSubData.PenaltyLevel==0);
            index_LRHP = find(curSubData.RewardLevel==0 & curSubData.PenaltyLevel==1);
            index_LRLP = find(curSubData.RewardLevel==0 & curSubData.PenaltyLevel==0);
            
            % Assign conditions to separate regressors
            SOTS_Event_Cue_RewPenHighLow = [];
            SOTS_Event_Cue_RewPenHighLow(1).name = 'CueHighRewHighPen';
            SOTS_Event_Cue_RewPenHighLow(1).ons = tmpAllOnset_intervalstart(index_HRHP);
            SOTS_Event_Cue_RewPenHighLow(1).dur = 0;
            SOTS_Event_Cue_RewPenHighLow(1).P(1).name = 'none';             
            SOTS_Event_Cue_RewPenHighLow(1).orth = 0;
            SOTS_Event_Cue_RewPenHighLow(2).name = 'CueHighRewLowPen';
            SOTS_Event_Cue_RewPenHighLow(2).ons = tmpAllOnset_intervalstart(index_HRLP);
            SOTS_Event_Cue_RewPenHighLow(2).dur = 0;
            SOTS_Event_Cue_RewPenHighLow(2).P(1).name = 'none';    
            SOTS_Event_Cue_RewPenHighLow(2).orth = 0;
            SOTS_Event_Cue_RewPenHighLow(3).name = 'CueLowRewHighPen';
            SOTS_Event_Cue_RewPenHighLow(3).ons = tmpAllOnset_intervalstart(index_LRHP);
            SOTS_Event_Cue_RewPenHighLow(3).dur = 0;
            SOTS_Event_Cue_RewPenHighLow(3).P(1).name = 'none'; 
            SOTS_Event_Cue_RewPenHighLow(3).orth = 0;
            SOTS_Event_Cue_RewPenHighLow(4).name = 'CueLowRewLowPen';
            SOTS_Event_Cue_RewPenHighLow(4).ons = tmpAllOnset_intervalstart(index_LRLP);
            SOTS_Event_Cue_RewPenHighLow(4).dur = 0;
            SOTS_Event_Cue_RewPenHighLow(4).P(1).name = 'none';    
            SOTS_Event_Cue_RewPenHighLow(4).orth = 0;       
            % Task Bug Interval regressor
            if IntRemove.allTaskBugIntervalsRemove{subi,2} ~= 0
                SOTS_Event_Cue_RewPenHighLow(5).name = 'AllTaskBugInts'; 
                SOTS_Event_Cue_RewPenHighLow(5).ons = tmpAllOnset_intTaskBugstart; 
                SOTS_Event_Cue_RewPenHighLow(5).dur = tmpAllOnset_intTaskBugduration;
                SOTS_Event_Cue_RewPenHighLow(5).P(1).name = 'none';
                SOTS_Event_Cue_RewPenHighLow(5).orth = 0;  %% turn off serial orthogonalization            
            end            
            

            %% GLM 2: Cues & Duration Modulated Intervals with 4 Conditions: HighValGain, LowValGain, HighValLoss, LowValLoss
            % Assign conditions to separate regressors
            SOTS_Event_CueInt_RewPenHighLow = [];
            SOTS_Event_CueInt_RewPenHighLow(1).name = 'CueHighRewHighPen';
            SOTS_Event_CueInt_RewPenHighLow(1).ons = tmpAllOnset_cuestart(index_HRHP);
            SOTS_Event_CueInt_RewPenHighLow(1).dur = 0;
            SOTS_Event_CueInt_RewPenHighLow(1).P(1).name = 'none';
            SOTS_Event_CueInt_RewPenHighLow(1).orth = 0; 
            SOTS_Event_CueInt_RewPenHighLow(2).name = 'CueHighRewLowPen';
            SOTS_Event_CueInt_RewPenHighLow(2).ons = tmpAllOnset_cuestart(index_HRLP);
            SOTS_Event_CueInt_RewPenHighLow(2).dur = 0;
            SOTS_Event_CueInt_RewPenHighLow(2).P(1).name = 'none';    
            SOTS_Event_CueInt_RewPenHighLow(2).orth = 0; 
            SOTS_Event_CueInt_RewPenHighLow(3).name = 'CueLowRewHighPen';
            SOTS_Event_CueInt_RewPenHighLow(3).ons = tmpAllOnset_cuestart(index_LRHP);
            SOTS_Event_CueInt_RewPenHighLow(3).dur = 0;
            SOTS_Event_CueInt_RewPenHighLow(3).P(1).name = 'none'; 
            SOTS_Event_CueInt_RewPenHighLow(3).orth = 0; 
            SOTS_Event_CueInt_RewPenHighLow(4).name = 'CueLowRewLowPen';
            SOTS_Event_CueInt_RewPenHighLow(4).ons = tmpAllOnset_cuestart(index_LRLP);
            SOTS_Event_CueInt_RewPenHighLow(4).dur = 0;
            SOTS_Event_CueInt_RewPenHighLow(4).P(1).name = 'none';   
            SOTS_Event_CueInt_RewPenHighLow(4).orth = 0;    
            SOTS_Event_CueInt_RewPenHighLow(5).name = 'IntervalHighRewHighPen';
            SOTS_Event_CueInt_RewPenHighLow(5).ons = tmpAllOnset_responsewindowstart(index_HRHP);
            SOTS_Event_CueInt_RewPenHighLow(5).dur = tmpAllOnset_responsewindowduration(index_HRHP);
            SOTS_Event_CueInt_RewPenHighLow(5).P(1).name = 'none'; 
            SOTS_Event_CueInt_RewPenHighLow(5).orth = 0; 
            SOTS_Event_CueInt_RewPenHighLow(6).name = 'IntervalHighRewLowPen';
            SOTS_Event_CueInt_RewPenHighLow(6).ons = tmpAllOnset_responsewindowstart(index_HRLP);
            SOTS_Event_CueInt_RewPenHighLow(6).dur = tmpAllOnset_responsewindowduration(index_HRLP);
            SOTS_Event_CueInt_RewPenHighLow(6).P(1).name = 'none';    
            SOTS_Event_CueInt_RewPenHighLow(6).orth = 0; 
            SOTS_Event_CueInt_RewPenHighLow(7).name = 'IntervalLowRewHighPen';
            SOTS_Event_CueInt_RewPenHighLow(7).ons = tmpAllOnset_responsewindowstart(index_LRHP);
            SOTS_Event_CueInt_RewPenHighLow(7).dur = tmpAllOnset_responsewindowduration(index_LRHP);
            SOTS_Event_CueInt_RewPenHighLow(7).P(1).name = 'none'; 
            SOTS_Event_CueInt_RewPenHighLow(7).orth = 0; 
            SOTS_Event_CueInt_RewPenHighLow(8).name = 'IntervalLowRewLowPen';
            SOTS_Event_CueInt_RewPenHighLow(8).ons = tmpAllOnset_responsewindowstart(index_LRLP);
            SOTS_Event_CueInt_RewPenHighLow(8).dur = tmpAllOnset_responsewindowduration(index_LRLP);
            SOTS_Event_CueInt_RewPenHighLow(8).P(1).name = 'none';      
            SOTS_Event_CueInt_RewPenHighLow(8).orth = 0;     
            % Task Bug Interval regressor
            if IntRemove.allTaskBugIntervalsRemove{subi,2} ~= 0
                SOTS_Event_CueInt_RewPenHighLow(9).name = 'AllTaskBugInts'; 
                SOTS_Event_CueInt_RewPenHighLow(9).ons = tmpAllOnset_intTaskBugstart; 
                SOTS_Event_CueInt_RewPenHighLow(9).dur = tmpAllOnset_intTaskBugduration;
                SOTS_Event_CueInt_RewPenHighLow(9).P(1).name = 'none';
                SOTS_Event_CueInt_RewPenHighLow(9).orth = 0;  %% turn off serial orthogonalization            
            end               

            %% GLM 3: Cues, Feedback, & Duration Modulated Intervals with 4 Conditions: HighValGain, LowValGain, HighValLoss, LowValLoss
            % Assign conditions to separate regressors
            SOTS_Event_CueIntFb_RewPenHighLow = [];
            SOTS_Event_CueIntFb_RewPenHighLow(1).name = 'CueHighRewHighPen';
            SOTS_Event_CueIntFb_RewPenHighLow(1).ons = tmpAllOnset_cuestart(index_HRHP);
            SOTS_Event_CueIntFb_RewPenHighLow(1).dur = 0;
            SOTS_Event_CueIntFb_RewPenHighLow(1).P(1).name = 'none'; 
            SOTS_Event_CueIntFb_RewPenHighLow(1).orth = 0;
            SOTS_Event_CueIntFb_RewPenHighLow(2).name = 'CueHighRewLowPen';
            SOTS_Event_CueIntFb_RewPenHighLow(2).ons = tmpAllOnset_cuestart(index_HRLP);
            SOTS_Event_CueIntFb_RewPenHighLow(2).dur = 0;
            SOTS_Event_CueIntFb_RewPenHighLow(2).P(1).name = 'none';    
            SOTS_Event_CueIntFb_RewPenHighLow(2).orth = 0;
            SOTS_Event_CueIntFb_RewPenHighLow(3).name = 'CueLowRewHighPen';
            SOTS_Event_CueIntFb_RewPenHighLow(3).ons = tmpAllOnset_cuestart(index_LRHP);
            SOTS_Event_CueIntFb_RewPenHighLow(3).dur = 0;
            SOTS_Event_CueIntFb_RewPenHighLow(3).P(1).name = 'none'; 
            SOTS_Event_CueIntFb_RewPenHighLow(3).orth = 0;
            SOTS_Event_CueIntFb_RewPenHighLow(4).name = 'CueLowRewLowPen';
            SOTS_Event_CueIntFb_RewPenHighLow(4).ons = tmpAllOnset_cuestart(index_LRLP);
            SOTS_Event_CueIntFb_RewPenHighLow(4).dur = 0;
            SOTS_Event_CueIntFb_RewPenHighLow(4).P(1).name = 'none';    
            SOTS_Event_CueIntFb_RewPenHighLow(4).orth = 0;  
            SOTS_Event_CueIntFb_RewPenHighLow(5).name = 'IntervalHighRewHighPen';
            SOTS_Event_CueIntFb_RewPenHighLow(5).ons = tmpAllOnset_responsewindowstart(index_HRHP);
            SOTS_Event_CueIntFb_RewPenHighLow(5).dur = tmpAllOnset_responsewindowduration(index_HRHP);
            SOTS_Event_CueIntFb_RewPenHighLow(5).P(1).name = 'none'; 
            SOTS_Event_CueIntFb_RewPenHighLow(5).orth = 0;
            SOTS_Event_CueIntFb_RewPenHighLow(6).name = 'IntervalHighRewLowPen';
            SOTS_Event_CueIntFb_RewPenHighLow(6).ons = tmpAllOnset_responsewindowstart(index_HRLP);
            SOTS_Event_CueIntFb_RewPenHighLow(6).dur = tmpAllOnset_responsewindowduration(index_HRLP);
            SOTS_Event_CueIntFb_RewPenHighLow(6).P(1).name = 'none';  
            SOTS_Event_CueIntFb_RewPenHighLow(6).orth = 0;  
            SOTS_Event_CueIntFb_RewPenHighLow(7).name = 'IntervalLowRewHighPen';
            SOTS_Event_CueIntFb_RewPenHighLow(7).ons = tmpAllOnset_responsewindowstart(index_LRHP);
            SOTS_Event_CueIntFb_RewPenHighLow(7).dur = tmpAllOnset_responsewindowduration(index_LRHP);
            SOTS_Event_CueIntFb_RewPenHighLow(7).P(1).name = 'none'; 
            SOTS_Event_CueIntFb_RewPenHighLow(7).orth = 0;
            SOTS_Event_CueIntFb_RewPenHighLow(8).name = 'IntervalLowRewLowPen';
            SOTS_Event_CueIntFb_RewPenHighLow(8).ons = tmpAllOnset_responsewindowstart(index_LRLP);
            SOTS_Event_CueIntFb_RewPenHighLow(8).dur = tmpAllOnset_responsewindowduration(index_LRLP);
            SOTS_Event_CueIntFb_RewPenHighLow(8).P(1).name = 'none'; 
            SOTS_Event_CueIntFb_RewPenHighLow(8).orth = 0;
            SOTS_Event_CueIntFb_RewPenHighLow(9).name = 'FbHighRewHighPen';
            SOTS_Event_CueIntFb_RewPenHighLow(9).ons = tmpAllOnset_feedbackstart(index_HRHP);
            SOTS_Event_CueIntFb_RewPenHighLow(9).dur = 0;
            SOTS_Event_CueIntFb_RewPenHighLow(9).P(1).name = 'none'; 
            SOTS_Event_CueIntFb_RewPenHighLow(9).orth = 0;
            SOTS_Event_CueIntFb_RewPenHighLow(10).name = 'FbHighRewLowPen';
            SOTS_Event_CueIntFb_RewPenHighLow(10).ons = tmpAllOnset_feedbackstart(index_HRLP);
            SOTS_Event_CueIntFb_RewPenHighLow(10).dur = 0;
            SOTS_Event_CueIntFb_RewPenHighLow(10).P(1).name = 'none';    
            SOTS_Event_CueIntFb_RewPenHighLow(10).orth = 0;
            SOTS_Event_CueIntFb_RewPenHighLow(11).name = 'FbLowRewHighPen';
            SOTS_Event_CueIntFb_RewPenHighLow(11).ons = tmpAllOnset_feedbackstart(index_LRHP);
            SOTS_Event_CueIntFb_RewPenHighLow(11).dur = 0;
            SOTS_Event_CueIntFb_RewPenHighLow(11).P(1).name = 'none'; 
            SOTS_Event_CueIntFb_RewPenHighLow(11).orth = 0;
            SOTS_Event_CueIntFb_RewPenHighLow(12).name = 'FbLowRewLowPen';
            SOTS_Event_CueIntFb_RewPenHighLow(12).ons = tmpAllOnset_feedbackstart(index_LRLP);
            SOTS_Event_CueIntFb_RewPenHighLow(12).dur = 0;
            SOTS_Event_CueIntFb_RewPenHighLow(12).P(1).name = 'none';  
            SOTS_Event_CueIntFb_RewPenHighLow(12).orth = 0;    
            % Task Bug Interval regressor
            if IntRemove.allTaskBugIntervalsRemove{subi,2} ~= 0
                SOTS_Event_CueIntFb_RewPenHighLow(13).name = 'AllTaskBugInts'; 
                SOTS_Event_CueIntFb_RewPenHighLow(13).ons = tmpAllOnset_intTaskBugstart; 
                SOTS_Event_CueIntFb_RewPenHighLow(13).dur = tmpAllOnset_intTaskBugduration;
                SOTS_Event_CueIntFb_RewPenHighLow(13).P(1).name = 'none';
                SOTS_Event_CueIntFb_RewPenHighLow(13).orth = 0;  %% turn off serial orthogonalization            
            end   
            
            %% GLMs 4-6: Whole Brain with Parametric Regressors (Pmod)
            
            %% GLM 4: BASELINE Pmod with Reward, Penalty
            % Assign conditions to separate regressors (8 regressors + task bug)
            % Cue Regressor 
            SOTS_Pmod_RewPen = [];
            SOTS_Pmod_RewPen(1).name = 'AllCues';
            SOTS_Pmod_RewPen(1).ons = tmpAllOnset_cuestart(incl_int);
            SOTS_Pmod_RewPen(1).dur = 0;
            SOTS_Pmod_RewPen(1).P(1).name = 'isHighRew'; 
            SOTS_Pmod_RewPen(1).P(1).P = RewCode(incl_int); %% vector of -1 and 1
            SOTS_Pmod_RewPen(1).P(1).h = 1;  % polynomial
            SOTS_Pmod_RewPen(1).P(2).name = 'isHighPen'; 
            SOTS_Pmod_RewPen(1).P(2).P = PenCode(incl_int); %% vector of -1 and 1
            SOTS_Pmod_RewPen(1).P(2).h = 1;
            SOTS_Pmod_RewPen(1).orth = 0; %% turn off serial orthogonalization
            % Response Window Regressor
            SOTS_Pmod_RewPen(2).name = 'AllRespInts';
            SOTS_Pmod_RewPen(2).ons = tmpAllOnset_responsewindowstart(incl_int);
            SOTS_Pmod_RewPen(2).dur = tmpAllOnset_responsewindowduration(incl_int);
            SOTS_Pmod_RewPen(2).P(1).name = 'isHighRew'; 
            SOTS_Pmod_RewPen(2).P(1).P = RewCode(incl_int); %% vector of -1 and 1
            SOTS_Pmod_RewPen(2).P(1).h = 1;  % polynomial
            SOTS_Pmod_RewPen(2).P(2).name = 'isHighPen'; 
            SOTS_Pmod_RewPen(2).P(2).P = PenCode(incl_int); %% vector of -1 and 1
            SOTS_Pmod_RewPen(2).P(2).h = 1;         
            SOTS_Pmod_RewPen(2).orth = 0; %% turn off serial orthogonalization
            % Feedback Regressor
            SOTS_Pmod_RewPen(3).name = 'AllFb';
            SOTS_Pmod_RewPen(3).ons = tmpAllOnset_feedbackstart(incl_int);
            SOTS_Pmod_RewPen(3).dur = 0;
            SOTS_Pmod_RewPen(3).P(1).name = 'none';
            SOTS_Pmod_RewPen(3).orth = 0;  %% turn off serial orthogonalization           
            % Error regressor
            SOTS_Pmod_RewPen(4).name = 'AllErrorEvents'; % ideally do not do with avgACC
            SOTS_Pmod_RewPen(4).ons = tmpAllOnset_trialErrorstart; 
            SOTS_Pmod_RewPen(4).dur = tmpAllOnset_trialErrorduration;
            SOTS_Pmod_RewPen(4).P(1).name = 'none';
            SOTS_Pmod_RewPen(4).orth = 0;  %% turn off serial orthogonalization
            % Task Bug Interval regressor
            if IntRemove.allTaskBugIntervalsRemove{subi,2} ~= 0
                SOTS_Pmod_RewPen(5).name = 'AllTaskBugInts'; % ideally do not do with avgACC
                SOTS_Pmod_RewPen(5).ons = tmpAllOnset_intTaskBugstart; 
                SOTS_Pmod_RewPen(5).dur = tmpAllOnset_intTaskBugduration;
                SOTS_Pmod_RewPen(5).P(1).name = 'none';
                SOTS_Pmod_RewPen(5).orth = 0;  %% turn off serial orthogonalization            
            end
            
            
            %% GLM 5: BASELINE Pmod with Reward, Penalty, Interval Num, Interval Length, Mean Congruency
            % Assign conditions to separate regressors (12 regressors)
            % Cue Regressor 
            SOTS_Pmod_RewPenTask = [];
            SOTS_Pmod_RewPenTask(1).name = 'AllCues';
            SOTS_Pmod_RewPenTask(1).ons = tmpAllOnset_cuestart(incl_int);
            SOTS_Pmod_RewPenTask(1).dur = 0;
            SOTS_Pmod_RewPenTask(1).P(1).name = 'isHighRew'; 
            SOTS_Pmod_RewPenTask(1).P(1).P = RewCode(incl_int); % vector of -1 and 1
            SOTS_Pmod_RewPenTask(1).P(1).h = 1;  % polynomial
            SOTS_Pmod_RewPenTask(1).P(2).name = 'isHighPen'; 
            SOTS_Pmod_RewPenTask(1).P(2).P = PenCode(incl_int); % vector of -1 and 1
            SOTS_Pmod_RewPenTask(1).P(2).h = 1;
            SOTS_Pmod_RewPenTask(1).P(3).name = 'IntervalNum'; 
            SOTS_Pmod_RewPenTask(1).P(3).P = IntervalNum(incl_int); % interval number in session (scaled)
            SOTS_Pmod_RewPenTask(1).P(3).h = 1;
            SOTS_Pmod_RewPenTask(1).orth = 0; %% turn off serial orthogonalization
            % Response Window Regressor
            SOTS_Pmod_RewPenTask(2).name = 'AllRespInts';
            SOTS_Pmod_RewPenTask(2).ons = tmpAllOnset_responsewindowstart(incl_int);
            SOTS_Pmod_RewPenTask(2).dur = tmpAllOnset_responsewindowduration(incl_int);
            SOTS_Pmod_RewPenTask(2).P(1).name = 'isHighRew'; 
            SOTS_Pmod_RewPenTask(2).P(1).P = RewCode(incl_int); % vector of -1 and 1
            SOTS_Pmod_RewPenTask(2).P(1).h = 1;             
            SOTS_Pmod_RewPenTask(2).P(2).name = 'isHighPen'; 
            SOTS_Pmod_RewPenTask(2).P(2).P = PenCode(incl_int); % vector of -1 and 1
            SOTS_Pmod_RewPenTask(2).P(2).h = 1;                     
            SOTS_Pmod_RewPenTask(2).P(3).name = 'IntervalNum'; 
            SOTS_Pmod_RewPenTask(2).P(3).P = IntervalNum(incl_int); % interval number in session (scaled)
            SOTS_Pmod_RewPenTask(2).P(3).h = 1;            
            SOTS_Pmod_RewPenTask(2).P(4).name = 'IntervalLength'; 
            SOTS_Pmod_RewPenTask(2).P(4).P = IntervalLength(incl_int); % interval length
            SOTS_Pmod_RewPenTask(2).P(4).h = 1;            
            SOTS_Pmod_RewPenTask(2).P(5).name = 'MeanCongruency'; 
            SOTS_Pmod_RewPenTask(2).P(5).P = avgCONG_center(incl_int); % mean congruency per interval 
            SOTS_Pmod_RewPenTask(2).P(5).h = 1;
            SOTS_Pmod_RewPenTask(2).orth = 0; 
            % Feedback Regressor
            SOTS_Pmod_RewPenTask(3).name = 'AllFb';
            SOTS_Pmod_RewPenTask(3).ons = tmpAllOnset_feedbackstart(incl_int);
            SOTS_Pmod_RewPenTask(3).dur = 0;
            SOTS_Pmod_RewPenTask(3).P(1).name = 'none';
            SOTS_Pmod_RewPenTask(3).orth = 0;            
            % Error regressor
            SOTS_Pmod_RewPenTask(4).name = 'AllErrorEvents'; 
            SOTS_Pmod_RewPenTask(4).ons = tmpAllOnset_trialErrorstart; 
            SOTS_Pmod_RewPenTask(4).dur = tmpAllOnset_trialErrorduration;
            SOTS_Pmod_RewPenTask(4).P(1).name = 'none';
            SOTS_Pmod_RewPenTask(4).orth = 0;    
            % Task Bug Interval regressor
            if IntRemove.allTaskBugIntervalsRemove{subi,2} ~= 0
                SOTS_Pmod_RewPenTask(5).name = 'AllTaskBugInts';
                SOTS_Pmod_RewPenTask(5).ons = tmpAllOnset_intTaskBugstart; 
                SOTS_Pmod_RewPenTask(5).dur = tmpAllOnset_intTaskBugduration;
                SOTS_Pmod_RewPenTask(5).P(1).name = 'none';
                SOTS_Pmod_RewPenTask(5).orth = 0;  
            end
            
            
            %% GLM 6: BASELINE Pmod with Reward, Penalty, Interval Num, Interval Length, Mean Congruency, RT, Accuracy, RT*Rew, RT*Pen
            % Assign conditions to separate regressors (16 regressors)
            % Cue Regressor 
            SOTS_Pmod_RewPenTask_RTACC = [];
            SOTS_Pmod_RewPenTask_RTACC(1).name = 'AllCues';
            SOTS_Pmod_RewPenTask_RTACC(1).ons = tmpAllOnset_cuestart(incl_int);
            SOTS_Pmod_RewPenTask_RTACC(1).dur = 0;
            SOTS_Pmod_RewPenTask_RTACC(1).P(1).name = 'isHighRew'; 
            SOTS_Pmod_RewPenTask_RTACC(1).P(1).P = RewCode(incl_int); % vector of -1 and 1
            SOTS_Pmod_RewPenTask_RTACC(1).P(1).h = 1;  % polynomial
            SOTS_Pmod_RewPenTask_RTACC(1).P(2).name = 'isHighPen'; 
            SOTS_Pmod_RewPenTask_RTACC(1).P(2).P = PenCode(incl_int); % vector of -1 and 1
            SOTS_Pmod_RewPenTask_RTACC(1).P(2).h = 1;
            SOTS_Pmod_RewPenTask_RTACC(1).P(3).name = 'IntervalNum'; 
            SOTS_Pmod_RewPenTask_RTACC(1).P(3).P = IntervalNum(incl_int); % interval number in session (scaled)
            SOTS_Pmod_RewPenTask_RTACC(1).P(3).h = 1;
            SOTS_Pmod_RewPenTask_RTACC(1).orth = 0; %% turn off serial orthogonalization
            % Response Window Regressor
            SOTS_Pmod_RewPenTask_RTACC(2).name = 'AllRespInts';
            SOTS_Pmod_RewPenTask_RTACC(2).ons = tmpAllOnset_responsewindowstart(incl_int);
            SOTS_Pmod_RewPenTask_RTACC(2).dur = tmpAllOnset_responsewindowduration(incl_int);
            SOTS_Pmod_RewPenTask_RTACC(2).P(1).name = 'isHighRew'; 
            SOTS_Pmod_RewPenTask_RTACC(2).P(1).P = RewCode(incl_int); % vector of -1 and 1
            SOTS_Pmod_RewPenTask_RTACC(2).P(1).h = 1;             
            SOTS_Pmod_RewPenTask_RTACC(2).P(2).name = 'isHighPen'; 
            SOTS_Pmod_RewPenTask_RTACC(2).P(2).P = PenCode(incl_int); % vector of -1 and 1
            SOTS_Pmod_RewPenTask_RTACC(2).P(2).h = 1;                     
            SOTS_Pmod_RewPenTask_RTACC(2).P(3).name = 'IntervalNum'; 
            SOTS_Pmod_RewPenTask_RTACC(2).P(3).P = IntervalNum(incl_int); % interval number in session (scaled)
            SOTS_Pmod_RewPenTask_RTACC(2).P(3).h = 1;            
            SOTS_Pmod_RewPenTask_RTACC(2).P(4).name = 'IntervalLength'; 
            SOTS_Pmod_RewPenTask_RTACC(2).P(4).P = IntervalLength(incl_int); % interval length
            SOTS_Pmod_RewPenTask_RTACC(2).P(4).h = 1;            
            SOTS_Pmod_RewPenTask_RTACC(2).P(5).name = 'MeanCongruency';  
            SOTS_Pmod_RewPenTask_RTACC(2).P(5).P = avgCONG_center(incl_int); % mean congruency per interval  
            SOTS_Pmod_RewPenTask_RTACC(2).P(5).h = 1;
            SOTS_Pmod_RewPenTask_RTACC(2).P(6).name = 'avgRT'; 
            SOTS_Pmod_RewPenTask_RTACC(2).P(6).P = avgRT_center(incl_int); %% vector of average RT per interval
            SOTS_Pmod_RewPenTask_RTACC(2).P(6).h = 1;            
            SOTS_Pmod_RewPenTask_RTACC(2).P(7).name = 'avgACC'; 
            SOTS_Pmod_RewPenTask_RTACC(2).P(7).P = avgACC_center(incl_int); %% vector of average accuracy per interval
            SOTS_Pmod_RewPenTask_RTACC(2).P(7).h = 1;
            SOTS_Pmod_RewPenTask_RTACC(2).P(8).name = 'isHighRew*RT';
            SOTS_Pmod_RewPenTask_RTACC(2).P(8).P = RewCode(incl_int).*avgRT_center(incl_int);
            SOTS_Pmod_RewPenTask_RTACC(2).P(8).h = 1; 
            SOTS_Pmod_RewPenTask_RTACC(2).P(9).name = 'isHighPen*RT'; 
            SOTS_Pmod_RewPenTask_RTACC(2).P(9).P = PenCode(incl_int).*avgRT_center(incl_int);
            SOTS_Pmod_RewPenTask_RTACC(2).P(9).h = 1;
            SOTS_Pmod_RewPenTask_RTACC(2).orth = 0; 
            % Feedback Regressor
            SOTS_Pmod_RewPenTask_RTACC(3).name = 'AllFb';
            SOTS_Pmod_RewPenTask_RTACC(3).ons = tmpAllOnset_feedbackstart(incl_int);
            SOTS_Pmod_RewPenTask_RTACC(3).dur = 0;
            SOTS_Pmod_RewPenTask_RTACC(3).P(1).name = 'none';
            SOTS_Pmod_RewPenTask_RTACC(3).orth = 0;            
            % Error regressor
            SOTS_Pmod_RewPenTask_RTACC(4).name = 'AllErrorEvents'; 
            SOTS_Pmod_RewPenTask_RTACC(4).ons = tmpAllOnset_trialErrorstart; 
            SOTS_Pmod_RewPenTask_RTACC(4).dur = tmpAllOnset_trialErrorduration;
            SOTS_Pmod_RewPenTask_RTACC(4).P(1).name = 'none';
            SOTS_Pmod_RewPenTask_RTACC(4).orth = 0;    
            % Task Bug Interval regressor
            if IntRemove.allTaskBugIntervalsRemove{subi,2} ~= 0
                SOTS_Pmod_RewPenTask_RTACC(5).name = 'AllTaskBugInts';
                SOTS_Pmod_RewPenTask_RTACC(5).ons = tmpAllOnset_intTaskBugstart; 
                SOTS_Pmod_RewPenTask_RTACC(5).dur = tmpAllOnset_intTaskBugduration;
                SOTS_Pmod_RewPenTask_RTACC(5).P(1).name = 'none';
                SOTS_Pmod_RewPenTask_RTACC(5).orth = 0;  
            end            
            
            
            %% GLM 7: BASELINE Pmod with Reward, Penalty, Interval Num, Interval Length, Mean Congruency, RT, Accuracy, RT*Rew, RT*Pen
            % Assign conditions to separate regressors (18 regressors)
            % Cue Regressor 
            SOTS_Pmod_RewPenTask_RTACC_interact = [];
            SOTS_Pmod_RewPenTask_RTACC_interact(1).name = 'AllCues';
            SOTS_Pmod_RewPenTask_RTACC_interact(1).ons = tmpAllOnset_cuestart(incl_int);
            SOTS_Pmod_RewPenTask_RTACC_interact(1).dur = 0;
            SOTS_Pmod_RewPenTask_RTACC_interact(1).P(1).name = 'isHighRew'; 
            SOTS_Pmod_RewPenTask_RTACC_interact(1).P(1).P = RewCode(incl_int); %% vector of -1 and 1
            SOTS_Pmod_RewPenTask_RTACC_interact(1).P(1).h = 1;  % polynomial
            SOTS_Pmod_RewPenTask_RTACC_interact(1).P(2).name = 'isHighPen'; 
            SOTS_Pmod_RewPenTask_RTACC_interact(1).P(2).P = PenCode(incl_int); %% vector of -1 and 1
            SOTS_Pmod_RewPenTask_RTACC_interact(1).P(2).h = 1;
            SOTS_Pmod_RewPenTask_RTACC_interact(1).P(3).name = 'IntervalNum'; 
            SOTS_Pmod_RewPenTask_RTACC_interact(1).P(3).P = IntervalNum(incl_int); %% interval number in session (scaled)
            SOTS_Pmod_RewPenTask_RTACC_interact(1).P(3).h = 1;
            SOTS_Pmod_RewPenTask_RTACC_interact(1).P(4).name = 'isHighRew*isHighPen'; 
            SOTS_Pmod_RewPenTask_RTACC_interact(1).P(4).P = RewCode(incl_int).*PenCode(incl_int); 
            SOTS_Pmod_RewPenTask_RTACC_interact(1).P(4).h = 1;
            SOTS_Pmod_RewPenTask_RTACC_interact(1).orth = 0; %% turn off serial orthogonalization
            % Response Window Regressor
            SOTS_Pmod_RewPenTask_RTACC_interact(2).name = 'AllRespInts';
            SOTS_Pmod_RewPenTask_RTACC_interact(2).ons = tmpAllOnset_responsewindowstart(incl_int);
            SOTS_Pmod_RewPenTask_RTACC_interact(2).dur = tmpAllOnset_responsewindowduration(incl_int);
            SOTS_Pmod_RewPenTask_RTACC_interact(2).P(1).name = 'isHighRew'; 
            SOTS_Pmod_RewPenTask_RTACC_interact(2).P(1).P = RewCode(incl_int); %% vector of -1 and 1
            SOTS_Pmod_RewPenTask_RTACC_interact(2).P(1).h = 1;  % polynomial           
            SOTS_Pmod_RewPenTask_RTACC_interact(2).P(2).name = 'isHighPen'; 
            SOTS_Pmod_RewPenTask_RTACC_interact(2).P(2).P = PenCode(incl_int); %% vector of -1 and 1
            SOTS_Pmod_RewPenTask_RTACC_interact(2).P(2).h = 1;                     
            SOTS_Pmod_RewPenTask_RTACC_interact(2).P(3).name = 'IntervalNum'; 
            SOTS_Pmod_RewPenTask_RTACC_interact(2).P(3).P = IntervalNum(incl_int); % interval number in session (scaled)
            SOTS_Pmod_RewPenTask_RTACC_interact(2).P(3).h = 1;            
            SOTS_Pmod_RewPenTask_RTACC_interact(2).P(4).name = 'IntervalLength'; 
            SOTS_Pmod_RewPenTask_RTACC_interact(2).P(4).P = IntervalLength(incl_int); % interval length
            SOTS_Pmod_RewPenTask_RTACC_interact(2).P(4).h = 1;            
            SOTS_Pmod_RewPenTask_RTACC_interact(2).P(5).name = 'MeanCongruency'; 
            SOTS_Pmod_RewPenTask_RTACC_interact(2).P(5).P = avgCONG_center(incl_int); % mean congruency per interval 
            SOTS_Pmod_RewPenTask_RTACC_interact(2).P(5).h = 1;
            SOTS_Pmod_RewPenTask_RTACC_interact(2).P(6).name = 'avgRT'; 
            SOTS_Pmod_RewPenTask_RTACC_interact(2).P(6).P = avgRT_center(incl_int); %% vector of average RT per interval
            SOTS_Pmod_RewPenTask_RTACC_interact(2).P(6).h = 1;            
            SOTS_Pmod_RewPenTask_RTACC_interact(2).P(7).name = 'avgACC'; 
            SOTS_Pmod_RewPenTask_RTACC_interact(2).P(7).P = avgACC_center(incl_int); %% vector of average accuracy per interval
            SOTS_Pmod_RewPenTask_RTACC_interact(2).P(7).h = 1;
            SOTS_Pmod_RewPenTask_RTACC_interact(2).P(8).name = 'isHighRew*RT';
            SOTS_Pmod_RewPenTask_RTACC_interact(2).P(8).P = RewCode(incl_int).*avgRT_center(incl_int);
            SOTS_Pmod_RewPenTask_RTACC_interact(2).P(8).h = 1; 
            SOTS_Pmod_RewPenTask_RTACC_interact(2).P(9).name = 'isHighPen*RT'; 
            SOTS_Pmod_RewPenTask_RTACC_interact(2).P(9).P = PenCode(incl_int).*avgRT_center(incl_int);
            SOTS_Pmod_RewPenTask_RTACC_interact(2).P(9).h = 1;        
            SOTS_Pmod_RewPenTask_RTACC_interact(2).P(10).name = 'isHighRew*isHighPen'; 
            SOTS_Pmod_RewPenTask_RTACC_interact(2).P(10).P = RewCode(incl_int).*PenCode(incl_int); 
            SOTS_Pmod_RewPenTask_RTACC_interact(2).P(10).h = 1;           
            SOTS_Pmod_RewPenTask_RTACC_interact(2).orth = 0; %% turn off serial orthogonalization
            % Feedback Regressor
            SOTS_Pmod_RewPenTask_RTACC_interact(3).name = 'AllFb';
            SOTS_Pmod_RewPenTask_RTACC_interact(3).ons = tmpAllOnset_feedbackstart(incl_int);
            SOTS_Pmod_RewPenTask_RTACC_interact(3).dur = 0;
            SOTS_Pmod_RewPenTask_RTACC_interact(3).P(1).name = 'none';
            SOTS_Pmod_RewPenTask_RTACC_interact(3).orth = 0;  %% turn off serial orthogonalization            
            % Error regressor
            SOTS_Pmod_RewPenTask_RTACC_interact(4).name = 'AllErrorEvents'; % ideally do not do with avgACC
            SOTS_Pmod_RewPenTask_RTACC_interact(4).ons = tmpAllOnset_trialErrorstart; 
            SOTS_Pmod_RewPenTask_RTACC_interact(4).dur = tmpAllOnset_trialErrorduration;
            SOTS_Pmod_RewPenTask_RTACC_interact(4).P(1).name = 'none';
            SOTS_Pmod_RewPenTask_RTACC_interact(4).orth = 0;  %% turn off serial orthogonalization   
            % Task Bug Interval regressor
            if IntRemove.allTaskBugIntervalsRemove{subi,2} ~= 0
                SOTS_Pmod_RewPenTask_RTACC_interact(5).name = 'AllTaskBugInts'; % ideally do not do with avgACC
                SOTS_Pmod_RewPenTask_RTACC_interact(5).ons = tmpAllOnset_intTaskBugstart; 
                SOTS_Pmod_RewPenTask_RTACC_interact(5).dur = tmpAllOnset_intTaskBugduration;
                SOTS_Pmod_RewPenTask_RTACC_interact(5).P(1).name = 'none';
                SOTS_Pmod_RewPenTask_RTACC_interact(5).orth = 0;  %% turn off serial orthogonalization
            end
            
            %% GLM 8: BASELINE Pmod with Reward, Penalty, Interval Num, Interval Length, Mean Congruency, RT, Accuracy, RT*Rew, RT*Pen, Cue Estimates by RewFixed and PenFixed
            % Assign conditions to separate regressors (20 regressors)
            % Cue Regressor 
            SOTS_Pmod_RewPenTask_RTACC_CueFixed = [];   
            SOTS_Pmod_RewPenTask_RTACC_CueFixed(1).name = 'RFixedCues';
            SOTS_Pmod_RewPenTask_RTACC_CueFixed(1).ons = tmpAllOnset_cuestart(incl_int_Cue_RewFix);
            SOTS_Pmod_RewPenTask_RTACC_CueFixed(1).dur = 0;
            SOTS_Pmod_RewPenTask_RTACC_CueFixed(1).P(1).name = 'isHighRew'; 
            SOTS_Pmod_RewPenTask_RTACC_CueFixed(1).P(1).P = RewCode(incl_int_Cue_RewFix); %% vector of -1 and 1
            SOTS_Pmod_RewPenTask_RTACC_CueFixed(1).P(1).h = 1;  % polynomial
            SOTS_Pmod_RewPenTask_RTACC_CueFixed(1).P(2).name = 'isHighPen'; 
            SOTS_Pmod_RewPenTask_RTACC_CueFixed(1).P(2).P = PenCode(incl_int_Cue_RewFix); %% vector of -1 and 1
            SOTS_Pmod_RewPenTask_RTACC_CueFixed(1).P(2).h = 1;
            SOTS_Pmod_RewPenTask_RTACC_CueFixed(1).P(3).name = 'IntervalNum'; 
            SOTS_Pmod_RewPenTask_RTACC_CueFixed(1).P(3).P = IntervalNum(incl_int_Cue_RewFix); %% interval number in session (scaled)
            SOTS_Pmod_RewPenTask_RTACC_CueFixed(1).P(3).h = 1;
            SOTS_Pmod_RewPenTask_RTACC_CueFixed(1).orth = 0; %% turn off serial orthogonalization
            SOTS_Pmod_RewPenTask_RTACC_CueFixed(2).name = 'PFixedCues';
            SOTS_Pmod_RewPenTask_RTACC_CueFixed(2).ons = tmpAllOnset_cuestart(incl_int_Cue_PenFix);
            SOTS_Pmod_RewPenTask_RTACC_CueFixed(2).dur = 0;
            SOTS_Pmod_RewPenTask_RTACC_CueFixed(2).P(1).name = 'isHighRew'; 
            SOTS_Pmod_RewPenTask_RTACC_CueFixed(2).P(1).P = RewCode(incl_int_Cue_PenFix); %% vector of -1 and 1
            SOTS_Pmod_RewPenTask_RTACC_CueFixed(2).P(1).h = 1;  % polynomial
            SOTS_Pmod_RewPenTask_RTACC_CueFixed(2).P(2).name = 'isHighPen'; 
            SOTS_Pmod_RewPenTask_RTACC_CueFixed(2).P(2).P = PenCode(incl_int_Cue_PenFix); %% vector of -1 and 1
            SOTS_Pmod_RewPenTask_RTACC_CueFixed(2).P(2).h = 1;
            SOTS_Pmod_RewPenTask_RTACC_CueFixed(2).P(3).name = 'IntervalNum'; 
            SOTS_Pmod_RewPenTask_RTACC_CueFixed(2).P(3).P = IntervalNum(incl_int_Cue_PenFix); %% interval number in session (scaled)
            SOTS_Pmod_RewPenTask_RTACC_CueFixed(2).P(3).h = 1;
            SOTS_Pmod_RewPenTask_RTACC_CueFixed(2).orth = 0; %% turn off serial orthogonalization
            % Response Window Regressor
            SOTS_Pmod_RewPenTask_RTACC_CueFixed(3).name = 'AllRespInts';
            SOTS_Pmod_RewPenTask_RTACC_CueFixed(3).ons = tmpAllOnset_responsewindowstart(incl_int);
            SOTS_Pmod_RewPenTask_RTACC_CueFixed(3).dur = tmpAllOnset_responsewindowduration(incl_int);
            SOTS_Pmod_RewPenTask_RTACC_CueFixed(3).P(1).name = 'isHighRew'; 
            SOTS_Pmod_RewPenTask_RTACC_CueFixed(3).P(1).P = RewCode(incl_int); %% vector of -1 and 1
            SOTS_Pmod_RewPenTask_RTACC_CueFixed(3).P(1).h = 1;  % polynomial
            SOTS_Pmod_RewPenTask_RTACC_CueFixed(3).P(2).name = 'isHighPen'; 
            SOTS_Pmod_RewPenTask_RTACC_CueFixed(3).P(2).P = PenCode(incl_int); %% vector of -1 and 1
            SOTS_Pmod_RewPenTask_RTACC_CueFixed(3).P(2).h = 1;         
            SOTS_Pmod_RewPenTask_RTACC_CueFixed(3).P(3).name = 'IntervalNum'; 
            SOTS_Pmod_RewPenTask_RTACC_CueFixed(3).P(3).P = IntervalNum(incl_int); % interval number in session (scaled)
            SOTS_Pmod_RewPenTask_RTACC_CueFixed(3).P(3).h = 1;            
            SOTS_Pmod_RewPenTask_RTACC_CueFixed(3).P(4).name = 'IntervalLength'; 
            SOTS_Pmod_RewPenTask_RTACC_CueFixed(3).P(4).P = IntervalLength(incl_int); % interval length
            SOTS_Pmod_RewPenTask_RTACC_CueFixed(3).P(4).h = 1;  
            SOTS_Pmod_RewPenTask_RTACC_CueFixed(3).P(5).name = 'MeanCongruency';  
            SOTS_Pmod_RewPenTask_RTACC_CueFixed(3).P(5).P = avgCONG_center(incl_int); % mean congruency per interval  
            SOTS_Pmod_RewPenTask_RTACC_CueFixed(3).P(5).h = 1;
            SOTS_Pmod_RewPenTask_RTACC_CueFixed(3).P(6).name = 'avgRT'; 
            SOTS_Pmod_RewPenTask_RTACC_CueFixed(3).P(6).P = avgRT_center(incl_int); %% vector of average RT per interval
            SOTS_Pmod_RewPenTask_RTACC_CueFixed(3).P(6).h = 1;            
            SOTS_Pmod_RewPenTask_RTACC_CueFixed(3).P(7).name = 'avgACC'; 
            SOTS_Pmod_RewPenTask_RTACC_CueFixed(3).P(7).P = avgACC_center(incl_int); %% vector of average accuracy per interval
            SOTS_Pmod_RewPenTask_RTACC_CueFixed(3).P(7).h = 1;
            SOTS_Pmod_RewPenTask_RTACC_CueFixed(3).P(8).name = 'isHighRew*RT';
            SOTS_Pmod_RewPenTask_RTACC_CueFixed(3).P(8).P = RewCode(incl_int).*avgRT_center(incl_int);
            SOTS_Pmod_RewPenTask_RTACC_CueFixed(3).P(8).h = 1; 
            SOTS_Pmod_RewPenTask_RTACC_CueFixed(3).P(9).name = 'isHighPen*RT'; 
            SOTS_Pmod_RewPenTask_RTACC_CueFixed(3).P(9).P = PenCode(incl_int).*avgRT_center(incl_int);
            SOTS_Pmod_RewPenTask_RTACC_CueFixed(3).P(9).h = 1;
            SOTS_Pmod_RewPenTask_RTACC_CueFixed(3).orth = 0; 
            % Feedback Regressor
            SOTS_Pmod_RewPenTask_RTACC_CueFixed(4).name = 'AllFb';
            SOTS_Pmod_RewPenTask_RTACC_CueFixed(4).ons = tmpAllOnset_feedbackstart(incl_int);
            SOTS_Pmod_RewPenTask_RTACC_CueFixed(4).dur = 0;
            SOTS_Pmod_RewPenTask_RTACC_CueFixed(4).P(1).name = 'none';
            SOTS_Pmod_RewPenTask_RTACC_CueFixed(4).orth = 0;  %% turn off serial orthogonalization            
            % Error regressor
            SOTS_Pmod_RewPenTask_RTACC_CueFixed(5).name = 'AllErrorEvents'; % ideally do not do with avgACC
            SOTS_Pmod_RewPenTask_RTACC_CueFixed(5).ons = tmpAllOnset_trialErrorstart; 
            SOTS_Pmod_RewPenTask_RTACC_CueFixed(5).dur = tmpAllOnset_trialErrorduration;
            SOTS_Pmod_RewPenTask_RTACC_CueFixed(5).P(1).name = 'none';
            SOTS_Pmod_RewPenTask_RTACC_CueFixed(5).orth = 0;  %% turn off serial orthogonalization   
            % Task Bug regressor
            if IntRemove.allTaskBugIntervalsRemove{subi,2} ~= 0
                SOTS_Pmod_RewPenTask_RTACC_CueFixed(6).name = 'AllTaskBugInts'; % ideally do not do with avgACC
                SOTS_Pmod_RewPenTask_RTACC_CueFixed(6).ons = tmpAllOnset_intTaskBugstart; 
                SOTS_Pmod_RewPenTask_RTACC_CueFixed(6).dur = tmpAllOnset_intTaskBugduration;
                SOTS_Pmod_RewPenTask_RTACC_CueFixed(6).P(1).name = 'none';
                SOTS_Pmod_RewPenTask_RTACC_CueFixed(6).orth = 0;  %% turn off serial orthogonalization
            end
            
            
            %% GLM 9: BASELINE Pmod with Reward, Penalty, RT centered, Accuracy, Interval Num, Interval Length, RT*R, RT*P, Interaction, Cue Estimates by RewFixed and PenFixed
            % Note: same as GLM8, except with rew*pen interactions 
            % Assign conditions to separate regressors (23 regressors)
            % Cue Regressor 
            SOTS_Pmod_RewPenTask_RTACC_CueFixed_interact = [];   
            SOTS_Pmod_RewPenTask_RTACC_CueFixed_interact(1).name = 'RFixedCues';
            SOTS_Pmod_RewPenTask_RTACC_CueFixed_interact(1).ons = tmpAllOnset_cuestart(incl_int_Cue_RewFix);
            SOTS_Pmod_RewPenTask_RTACC_CueFixed_interact(1).dur = 0;
            SOTS_Pmod_RewPenTask_RTACC_CueFixed_interact(1).P(1).name = 'isHighRew'; 
            SOTS_Pmod_RewPenTask_RTACC_CueFixed_interact(1).P(1).P = RewCode(incl_int_Cue_RewFix); %% vector of -1 and 1
            SOTS_Pmod_RewPenTask_RTACC_CueFixed_interact(1).P(1).h = 1;  % polynomial
            SOTS_Pmod_RewPenTask_RTACC_CueFixed_interact(1).P(2).name = 'isHighPen'; 
            SOTS_Pmod_RewPenTask_RTACC_CueFixed_interact(1).P(2).P = PenCode(incl_int_Cue_RewFix); %% vector of -1 and 1
            SOTS_Pmod_RewPenTask_RTACC_CueFixed_interact(1).P(2).h = 1;
            SOTS_Pmod_RewPenTask_RTACC_CueFixed_interact(1).P(3).name = 'IntervalNum'; 
            SOTS_Pmod_RewPenTask_RTACC_CueFixed_interact(1).P(3).P = IntervalNum(incl_int_Cue_RewFix); %% interval number in session (scaled)
            SOTS_Pmod_RewPenTask_RTACC_CueFixed_interact(1).P(3).h = 1;
            SOTS_Pmod_RewPenTask_RTACC_CueFixed_interact(1).P(4).name = 'isHighRew*isHighPen'; 
            SOTS_Pmod_RewPenTask_RTACC_CueFixed_interact(1).P(4).P = RewCode(incl_int_Cue_RewFix).*PenCode(incl_int_Cue_RewFix); %% vector of -1 and 1
            SOTS_Pmod_RewPenTask_RTACC_CueFixed_interact(1).P(4).h = 1;   
            SOTS_Pmod_RewPenTask_RTACC_CueFixed_interact(1).orth = 0; %% turn off serial orthogonalization
            SOTS_Pmod_RewPenTask_RTACC_CueFixed_interact(2).name = 'PFixedCues';
            SOTS_Pmod_RewPenTask_RTACC_CueFixed_interact(2).ons = tmpAllOnset_cuestart(incl_int_Cue_PenFix);
            SOTS_Pmod_RewPenTask_RTACC_CueFixed_interact(2).dur = 0;
            SOTS_Pmod_RewPenTask_RTACC_CueFixed_interact(2).P(1).name = 'isHighRew'; 
            SOTS_Pmod_RewPenTask_RTACC_CueFixed_interact(2).P(1).P = RewCode(incl_int_Cue_PenFix); %% vector of -1 and 1
            SOTS_Pmod_RewPenTask_RTACC_CueFixed_interact(2).P(1).h = 1;  % polynomial
            SOTS_Pmod_RewPenTask_RTACC_CueFixed_interact(2).P(2).name = 'isHighPen'; 
            SOTS_Pmod_RewPenTask_RTACC_CueFixed_interact(2).P(2).P = PenCode(incl_int_Cue_PenFix); %% vector of -1 and 1
            SOTS_Pmod_RewPenTask_RTACC_CueFixed_interact(2).P(2).h = 1;
            SOTS_Pmod_RewPenTask_RTACC_CueFixed_interact(2).P(3).name = 'IntervalNum'; 
            SOTS_Pmod_RewPenTask_RTACC_CueFixed_interact(2).P(3).P = IntervalNum(incl_int_Cue_PenFix); %% interval number in session (scaled)
            SOTS_Pmod_RewPenTask_RTACC_CueFixed_interact(2).P(3).h = 1;
            SOTS_Pmod_RewPenTask_RTACC_CueFixed_interact(2).P(4).name = 'isHighRew*isHighPen'; 
            SOTS_Pmod_RewPenTask_RTACC_CueFixed_interact(2).P(4).P = RewCode(incl_int_Cue_PenFix).*PenCode(incl_int_Cue_PenFix); %% vector of -1 and 1
            SOTS_Pmod_RewPenTask_RTACC_CueFixed_interact(2).P(4).h = 1;   
            SOTS_Pmod_RewPenTask_RTACC_CueFixed_interact(2).orth = 0; %% turn off serial orthogonalization
            % Response Window Regressor
            SOTS_Pmod_RewPenTask_RTACC_CueFixed_interact(3).name = 'AllRespInts';
            SOTS_Pmod_RewPenTask_RTACC_CueFixed_interact(3).ons = tmpAllOnset_responsewindowstart(incl_int);
            SOTS_Pmod_RewPenTask_RTACC_CueFixed_interact(3).dur = tmpAllOnset_responsewindowduration(incl_int);
            SOTS_Pmod_RewPenTask_RTACC_CueFixed_interact(3).P(1).name = 'isHighRew'; 
            SOTS_Pmod_RewPenTask_RTACC_CueFixed_interact(3).P(1).P = RewCode(incl_int); %% vector of -1 and 1
            SOTS_Pmod_RewPenTask_RTACC_CueFixed_interact(3).P(1).h = 1;  % polynomial
            SOTS_Pmod_RewPenTask_RTACC_CueFixed_interact(3).P(2).name = 'isHighPen'; 
            SOTS_Pmod_RewPenTask_RTACC_CueFixed_interact(3).P(2).P = PenCode(incl_int); %% vector of -1 and 1
            SOTS_Pmod_RewPenTask_RTACC_CueFixed_interact(3).P(2).h = 1;         
            SOTS_Pmod_RewPenTask_RTACC_CueFixed_interact(3).P(3).name = 'IntervalNum'; 
            SOTS_Pmod_RewPenTask_RTACC_CueFixed_interact(3).P(3).P = IntervalNum(incl_int); % interval number in session (scaled)
            SOTS_Pmod_RewPenTask_RTACC_CueFixed_interact(3).P(3).h = 1;            
            SOTS_Pmod_RewPenTask_RTACC_CueFixed_interact(3).P(4).name = 'IntervalLength'; 
            SOTS_Pmod_RewPenTask_RTACC_CueFixed_interact(3).P(4).P = IntervalLength(incl_int); % interval length
            SOTS_Pmod_RewPenTask_RTACC_CueFixed_interact(3).P(4).h = 1;  
            SOTS_Pmod_RewPenTask_RTACC_CueFixed_interact(3).P(5).name = 'MeanCongruency';  
            SOTS_Pmod_RewPenTask_RTACC_CueFixed_interact(3).P(5).P = avgCONG_center(incl_int); % mean congruency per interval  
            SOTS_Pmod_RewPenTask_RTACC_CueFixed_interact(3).P(5).h = 1;
            SOTS_Pmod_RewPenTask_RTACC_CueFixed_interact(3).P(6).name = 'avgRT'; 
            SOTS_Pmod_RewPenTask_RTACC_CueFixed_interact(3).P(6).P = avgRT_center(incl_int); %% vector of average RT per interval
            SOTS_Pmod_RewPenTask_RTACC_CueFixed_interact(3).P(6).h = 1;            
            SOTS_Pmod_RewPenTask_RTACC_CueFixed_interact(3).P(7).name = 'avgACC'; 
            SOTS_Pmod_RewPenTask_RTACC_CueFixed_interact(3).P(7).P = avgACC_center(incl_int); %% vector of average accuracy per interval
            SOTS_Pmod_RewPenTask_RTACC_CueFixed_interact(3).P(7).h = 1;
            SOTS_Pmod_RewPenTask_RTACC_CueFixed_interact(3).P(8).name = 'isHighRew*RT';
            SOTS_Pmod_RewPenTask_RTACC_CueFixed_interact(3).P(8).P = RewCode(incl_int).*avgRT_center(incl_int);
            SOTS_Pmod_RewPenTask_RTACC_CueFixed_interact(3).P(8).h = 1; 
            SOTS_Pmod_RewPenTask_RTACC_CueFixed_interact(3).P(9).name = 'isHighPen*RT'; 
            SOTS_Pmod_RewPenTask_RTACC_CueFixed_interact(3).P(9).P = PenCode(incl_int).*avgRT_center(incl_int);
            SOTS_Pmod_RewPenTask_RTACC_CueFixed_interact(3).P(9).h = 1;
            SOTS_Pmod_RewPenTask_RTACC_CueFixed_interact(3).P(10).name = 'isHighRew*isHighPen'; 
            SOTS_Pmod_RewPenTask_RTACC_CueFixed_interact(3).P(10).P = RewCode(incl_int).*PenCode(incl_int); %% vector of -1 and 1
            SOTS_Pmod_RewPenTask_RTACC_CueFixed_interact(3).P(10).h = 1;   
            SOTS_Pmod_RewPenTask_RTACC_CueFixed_interact(3).orth = 0; 
            % Feedback Regressor
            SOTS_Pmod_RewPenTask_RTACC_CueFixed_interact(4).name = 'AllFb';
            SOTS_Pmod_RewPenTask_RTACC_CueFixed_interact(4).ons = tmpAllOnset_feedbackstart(incl_int);
            SOTS_Pmod_RewPenTask_RTACC_CueFixed_interact(4).dur = 0;
            SOTS_Pmod_RewPenTask_RTACC_CueFixed_interact(4).P(1).name = 'none';
            SOTS_Pmod_RewPenTask_RTACC_CueFixed_interact(4).orth = 0;  %% turn off serial orthogonalization            
            % Error regressor
            SOTS_Pmod_RewPenTask_RTACC_CueFixed_interact(5).name = 'AllErrorEvents'; % ideally do not do with avgACC
            SOTS_Pmod_RewPenTask_RTACC_CueFixed_interact(5).ons = tmpAllOnset_trialErrorstart; 
            SOTS_Pmod_RewPenTask_RTACC_CueFixed_interact(5).dur = tmpAllOnset_trialErrorduration;
            SOTS_Pmod_RewPenTask_RTACC_CueFixed_interact(5).P(1).name = 'none';
            SOTS_Pmod_RewPenTask_RTACC_CueFixed_interact(5).orth = 0;  %% turn off serial orthogonalization   
            % Task Bug regressor
            if IntRemove.allTaskBugIntervalsRemove{subi,2} ~= 0
                SOTS_Pmod_RewPenTask_RTACC_CueFixed_interact(6).name = 'AllTaskBugInts'; % ideally do not do with avgACC
                SOTS_Pmod_RewPenTask_RTACC_CueFixed_interact(6).ons = tmpAllOnset_intTaskBugstart; 
                SOTS_Pmod_RewPenTask_RTACC_CueFixed_interact(6).dur = tmpAllOnset_intTaskBugduration;
                SOTS_Pmod_RewPenTask_RTACC_CueFixed_interact(6).P(1).name = 'none';
                SOTS_Pmod_RewPenTask_RTACC_CueFixed_interact(6).orth = 0;  %% turn off serial orthogonalization
            end       
            
            %% GLM 10: Extract Cue, Response, Feedback for All Intervals
            % for single interval extraction:
            SOTS_AllIntervals = [];
            % for intervalind = 1:length(tmpAllOnset_cuestart) % loop over all intervals
            for intervalind = 1:length(incl_int) % loop over all included intervals
                % Interval1_cue, Interval1_response, Interval1_feedback, Interval2_cue, Interval2_response, Interval2_feedback
                SOTS_AllIntervals((intervalind-1)*3+1).name = ['Interval',num2str(ix_keep(intervalind)),'_cue'];
                SOTS_AllIntervals((intervalind-1)*3+2).name = ['Interval',num2str(ix_keep(intervalind)),'_response'];
                SOTS_AllIntervals((intervalind-1)*3+3).name = ['Interval',num2str(ix_keep(intervalind)),'_feedback'];
                SOTS_AllIntervals((intervalind-1)*3+1).ons = tmpAllOnset_cuestart(intervalind);
                SOTS_AllIntervals((intervalind-1)*3+2).ons = tmpAllOnset_responsewindowstart(intervalind);
                SOTS_AllIntervals((intervalind-1)*3+3).ons = tmpAllOnset_feedbackstart(intervalind);
                SOTS_AllIntervals((intervalind-1)*3+1).dur = 0; % stick
                SOTS_AllIntervals((intervalind-1)*3+2).dur = tmpAllOnset_responsewindowduration(intervalind); % duration mod epoch
                SOTS_AllIntervals((intervalind-1)*3+3).dur = 0; % stick
                SOTS_AllIntervals((intervalind-1)*3+1).P(1).name = 'none'; % .P(n) = parametric modulator
                SOTS_AllIntervals((intervalind-1)*3+2).P(1).name = 'none';
                SOTS_AllIntervals((intervalind-1)*3+3).P(1).name = 'none';
                SOTS_AllIntervals((intervalind-1)*3+1).orth = 0; %% turn off serial orthogonalization
                SOTS_AllIntervals((intervalind-1)*3+2).orth = 0;
                SOTS_AllIntervals((intervalind-1)*3+3).orth = 0;
            end 
            % Error regressor %% DY DOUBLECHECK THIS INDEX IS CORRECT!!
            SOTS_AllIntervals((intervalind-1)*3+4).name = 'AllErrorEvents'; % ideally do not do with avgACC
            SOTS_AllIntervals((intervalind-1)*3+4).ons = tmpAllOnset_trialErrorstart; 
            SOTS_AllIntervals((intervalind-1)*3+4).dur = tmpAllOnset_trialErrorduration;
            SOTS_AllIntervals((intervalind-1)*3+4).P(1).name = 'none';
            SOTS_AllIntervals((intervalind-1)*3+4).orth = 0;  %% turn off serial orthogonalization  
            % Task Bug Interval regressor
            if IntRemove.allTaskBugIntervalsRemove{subi,2} ~= 0
                SOTS_AllIntervals((intervalind-1)*3+5).name = 'AllTaskBugInts'; % ideally do not do with avgACC
                SOTS_AllIntervals((intervalind-1)*3+5).ons = tmpAllOnset_intTaskBugstart; 
                SOTS_AllIntervals((intervalind-1)*3+5).dur = tmpAllOnset_intTaskBugduration;
                SOTS_AllIntervals((intervalind-1)*3+5).P(1).name = 'none';
                SOTS_AllIntervals((intervalind-1)*3+5).orth = 0;  %% turn off serial orthogonalization
            end
            
            
            
            %% OLD
            
%             %% GLM 5: BASELINE Pmod with Reward, Penalty, RT centered, Accuracy
%             % Assign conditions to separate regressors
%             % Cue Regressor 
%             allSOTSconds_Event_AllIntervPmod_RewPenRTacc = [];
%             allSOTSconds_Event_AllIntervPmod_RewPenRTacc(1).name = 'AllCues';
%             allSOTSconds_Event_AllIntervPmod_RewPenRTacc(1).ons = tmpAllOnset_cuestart(incl_int);
%             allSOTSconds_Event_AllIntervPmod_RewPenRTacc(1).dur = 0;
%             allSOTSconds_Event_AllIntervPmod_RewPenRTacc(1).P(1).name = 'isHighRew'; 
%             allSOTSconds_Event_AllIntervPmod_RewPenRTacc(1).P(1).P = RewCode(incl_int); %% vector of -1 and 1
%             allSOTSconds_Event_AllIntervPmod_RewPenRTacc(1).P(1).h = 1;  % polynomial
%             allSOTSconds_Event_AllIntervPmod_RewPenRTacc(1).P(2).name = 'isHighPen'; 
%             allSOTSconds_Event_AllIntervPmod_RewPenRTacc(1).P(2).P = PenCode(incl_int); %% vector of -1 and 1
%             allSOTSconds_Event_AllIntervPmod_RewPenRTacc(1).P(2).h = 1;
%             allSOTSconds_Event_AllIntervPmod_RewPenRTacc(1).orth = 0; %% turn off serial orthogonalization
%             % Response Window Regressor
%             allSOTSconds_Event_AllIntervPmod_RewPenRTacc(2).name = 'AllRespInts';
%             allSOTSconds_Event_AllIntervPmod_RewPenRTacc(2).ons = tmpAllOnset_responsewindowstart(incl_int);
%             allSOTSconds_Event_AllIntervPmod_RewPenRTacc(2).dur = tmpAllOnset_responsewindowduration(incl_int);
%             allSOTSconds_Event_AllIntervPmod_RewPenRTacc(2).P(1).name = 'isHighRew'; 
%             allSOTSconds_Event_AllIntervPmod_RewPenRTacc(2).P(1).P = RewCode(incl_int); %% vector of -1 and 1
%             allSOTSconds_Event_AllIntervPmod_RewPenRTacc(2).P(1).h = 1;  % polynomial
%             allSOTSconds_Event_AllIntervPmod_RewPenRTacc(2).P(2).name = 'isHighPen'; 
%             allSOTSconds_Event_AllIntervPmod_RewPenRTacc(2).P(2).P = PenCode(incl_int); %% vector of -1 and 1
%             allSOTSconds_Event_AllIntervPmod_RewPenRTacc(2).P(2).h = 1;         
%             allSOTSconds_Event_AllIntervPmod_RewPenRTacc(2).P(3).name = 'avgRT'; 
%             allSOTSconds_Event_AllIntervPmod_RewPenRTacc(2).P(3).P = avgRT_center(incl_int); %% vector of average RT per interval
%             allSOTSconds_Event_AllIntervPmod_RewPenRTacc(2).P(3).h = 1;
%             allSOTSconds_Event_AllIntervPmod_RewPenRTacc(2).P(4).name = 'avgAcc'; 
%             allSOTSconds_Event_AllIntervPmod_RewPenRTacc(2).P(4).P = avgACC_center(incl_int); %% vector of average accuracy per interval
%             allSOTSconds_Event_AllIntervPmod_RewPenRTacc(2).P(4).h = 1;
%             allSOTSconds_Event_AllIntervPmod_RewPenRTacc(2).orth = 0; %% turn off serial orthogonalization
%             % Feedback Regressor
%             allSOTSconds_Event_AllIntervPmod_RewPenRTacc(3).name = 'AllFb';
%             allSOTSconds_Event_AllIntervPmod_RewPenRTacc(3).ons = tmpAllOnset_feedbackstart(incl_int);
%             allSOTSconds_Event_AllIntervPmod_RewPenRTacc(3).dur = 0;
%             allSOTSconds_Event_AllIntervPmod_RewPenRTacc(3).P(1).name = 'none';
%             allSOTSconds_Event_AllIntervPmod_RewPenRTacc(3).orth = 0;  %% turn off serial orthogonalization     
%             % Error regressor
%             allSOTSconds_Event_AllIntervPmod_RewPenRTacc(4).name = 'AllErrorEvents'; % ideally do not do with avg accurate in pmod?
%             allSOTSconds_Event_AllIntervPmod_RewPenRTacc(4).ons = tmpAllOnset_trialErrorstart; 
%             allSOTSconds_Event_AllIntervPmod_RewPenRTacc(4).dur = tmpAllOnset_trialErrorduration;
%             allSOTSconds_Event_AllIntervPmod_RewPenRTacc(4).P(1).name = 'none';
%             allSOTSconds_Event_AllIntervPmod_RewPenRTacc(4).orth = 0;  %% turn off serial orthogonalization    
%             % Task Bug Interval regressor
%             if IntRemove.allTaskBugIntervalsRemove{subi,2} ~= 0
%                 allSOTSconds_Event_AllIntervPmod_RewPenRTacc(5).name = 'AllTaskBugInts'; % ideally do not do with avgACC
%                 allSOTSconds_Event_AllIntervPmod_RewPenRTacc(5).ons = tmpAllOnset_intTaskBugstart; 
%                 allSOTSconds_Event_AllIntervPmod_RewPenRTacc(5).dur = tmpAllOnset_intTaskBugduration;
%                 allSOTSconds_Event_AllIntervPmod_RewPenRTacc(5).P(1).name = 'none';
%                 allSOTSconds_Event_AllIntervPmod_RewPenRTacc(5).orth = 0;  %% turn off serial orthogonalization
%             end
%             
%             %% GLM 6: BASELINE Pmod with Reward, Penalty, RT centered, Accuracy, RT*R, RT*P
%             % Assign conditions to separate regressors
%             % Cue Regressor 
%             allSOTSconds_Event_AllIntervPmod_RewPenRTacc_interact = [];
%             allSOTSconds_Event_AllIntervPmod_RewPenRTacc_interact(1).name = 'AllCues';
%             allSOTSconds_Event_AllIntervPmod_RewPenRTacc_interact(1).ons = tmpAllOnset_cuestart(incl_int);
%             allSOTSconds_Event_AllIntervPmod_RewPenRTacc_interact(1).dur = 0;
%             allSOTSconds_Event_AllIntervPmod_RewPenRTacc_interact(1).P(1).name = 'isHighRew'; 
%             allSOTSconds_Event_AllIntervPmod_RewPenRTacc_interact(1).P(1).P = RewCode_acc(incl_int); %% vector of -1 and 1
%             allSOTSconds_Event_AllIntervPmod_RewPenRTacc_interact(1).P(1).h = 1;  % polynomial
%             allSOTSconds_Event_AllIntervPmod_RewPenRTacc_interact(1).P(2).name = 'isHighPen'; 
%             allSOTSconds_Event_AllIntervPmod_RewPenRTacc_interact(1).P(2).P = PenCode_acc(incl_int); %% vector of -1 and 1
%             allSOTSconds_Event_AllIntervPmod_RewPenRTacc_interact(1).P(2).h = 1;
%             allSOTSconds_Event_AllIntervPmod_RewPenRTacc_interact(1).orth = 0; %% turn off serial orthogonalization
%             % Response Window Regressor
%             allSOTSconds_Event_AllIntervPmod_RewPenRTacc_interact(2).name = 'AllRespInts';
%             allSOTSconds_Event_AllIntervPmod_RewPenRTacc_interact(2).ons = tmpAllOnset_responsewindowstart_acc(incl_int);
%             allSOTSconds_Event_AllIntervPmod_RewPenRTacc_interact(2).dur = tmpAllOnset_responsewindowduration_acc(incl_int);
%             allSOTSconds_Event_AllIntervPmod_RewPenRTacc_interact(2).P(1).name = 'isHighRew'; 
%             allSOTSconds_Event_AllIntervPmod_RewPenRTacc_interact(2).P(1).P = RewCode_acc(incl_int); %% vector of -1 and 1
%             allSOTSconds_Event_AllIntervPmod_RewPenRTacc_interact(2).P(1).h = 1;  % polynomial
%             allSOTSconds_Event_AllIntervPmod_RewPenRTacc_interact(2).P(2).name = 'isHighPen'; 
%             allSOTSconds_Event_AllIntervPmod_RewPenRTacc_interact(2).P(2).P = PenCode_acc(incl_int); %% vector of -1 and 1
%             allSOTSconds_Event_AllIntervPmod_RewPenRTacc_interact(2).P(2).h = 1;         
%             allSOTSconds_Event_AllIntervPmod_RewPenRTacc_interact(2).P(3).name = 'avgRT'; 
%             allSOTSconds_Event_AllIntervPmod_RewPenRTacc_interact(2).P(3).P = avgRT_acc_center(incl_int); %% vector of average RT per interval
%             allSOTSconds_Event_AllIntervPmod_RewPenRTacc_interact(2).P(3).h = 1;
%             allSOTSconds_Event_AllIntervPmod_RewPenRTacc_interact(2).P(4).name = 'avgAcc'; 
%             allSOTSconds_Event_AllIntervPmod_RewPenRTacc_interact(2).P(4).P = avgACC(incl_int); %% vector of average accuracy per interval
%             allSOTSconds_Event_AllIntervPmod_RewPenRTacc_interact(2).P(4).h = 1;
%             allSOTSconds_Event_AllIntervPmod_RewPenRTacc_interact(2).P(5).name = 'isHighRew*RT';
%             allSOTSconds_Event_AllIntervPmod_RewPenRTacc_interact(2).P(5).P = ...
%                 allSOTSconds_Event_AllIntervPmod_RewPenRTacc_interact(2).P(1).P.*allSOTSconds_Event_AllIntervPmod_RewPenRTacc_interact(2).P(3).P; 
%             allSOTSconds_Event_AllIntervPmod_RewPenRTacc_interact(2).P(5).h = 1;  % polynomial
%             allSOTSconds_Event_AllIntervPmod_RewPenRTacc_interact(2).P(6).name = 'isHighPen*RT'; 
%             allSOTSconds_Event_AllIntervPmod_RewPenRTacc_interact(2).P(6).P = ...
%                 allSOTSconds_Event_AllIntervPmod_RewPenRTacc_interact(2).P(2).P.*allSOTSconds_Event_AllIntervPmod_RewPenRTacc_interact(2).P(3).P; 
%             allSOTSconds_Event_AllIntervPmod_RewPenRTacc_interact(2).P(6).h = 1;
%             allSOTSconds_Event_AllIntervPmod_RewPenRTacc_interact(2).orth = 0; %% turn off serial orthogonalization
%             % Feedback Regressor
%             allSOTSconds_Event_AllIntervPmod_RewPenRTacc_interact(3).name = 'AllFb';
%             allSOTSconds_Event_AllIntervPmod_RewPenRTacc_interact(3).ons = tmpAllOnset_feedbackstart_acc(incl_int);
%             allSOTSconds_Event_AllIntervPmod_RewPenRTacc_interact(3).dur = 0;
%             allSOTSconds_Event_AllIntervPmod_RewPenRTacc_interact(3).P(1).name = 'none';
%             allSOTSconds_Event_AllIntervPmod_RewPenRTacc_interact(3).orth = 0;  %% turn off serial orthogonalization            
%             % Error regressor
%             allSOTSconds_Event_AllIntervPmod_RewPenRTacc_interact(4).name = 'AllErrorEvents'; % ideally do not do with avgACC
%             allSOTSconds_Event_AllIntervPmod_RewPenRTacc_interact(4).ons = tmpAllOnset_trialErrorstart; 
%             allSOTSconds_Event_AllIntervPmod_RewPenRTacc_interact(4).dur = tmpAllOnset_trialErrorduration;
%             allSOTSconds_Event_AllIntervPmod_RewPenRTacc_interact(4).P(1).name = 'none';
%             allSOTSconds_Event_AllIntervPmod_RewPenRTacc_interact(4).orth = 0;  %% turn off serial orthogonalization   
%             % Task Bug regressor
%             if IntRemove.allTaskBugIntervalsRemove{subi,2} ~= 0
%                 allSOTSconds_Event_AllIntervPmod_RewPenRTacc_interact(5).name = 'AllTaskBugInts'; % ideally do not do with avgACC
%                 allSOTSconds_Event_AllIntervPmod_RewPenRTacc_interact(5).ons = tmpAllOnset_intTaskBugstart; 
%                 allSOTSconds_Event_AllIntervPmod_RewPenRTacc_interact(5).dur = tmpAllOnset_intTaskBugduration;
%                 allSOTSconds_Event_AllIntervPmod_RewPenRTacc_interact(5).P(1).name = 'none';
%                 allSOTSconds_Event_AllIntervPmod_RewPenRTacc_interact(5).orth = 0;  %% turn off serial orthogonalization
%             end
%             
            
            

%             %% GLM 11: BASELINE Pmod with Reward, Penalty, R*P, RT centered, Accuracy, Interval num, Interval Length, RT*R, RT*P
%             % Assign conditions to separate regressors
%             % Cue Regressor 
%             allSOTSconds_Event_AllIntervPmod_RewPenRTaccInt_interact = [];
%             allSOTSconds_Event_AllIntervPmod_RewPenRTaccInt_interact(1).name = 'AllCues';
%             allSOTSconds_Event_AllIntervPmod_RewPenRTaccInt_interact(1).ons = tmpAllOnset_cuestart_acc(incl_int);
%             allSOTSconds_Event_AllIntervPmod_RewPenRTaccInt_interact(1).dur = 0;
%             allSOTSconds_Event_AllIntervPmod_RewPenRTaccInt_interact(1).P(1).name = 'isHighRew'; 
%             allSOTSconds_Event_AllIntervPmod_RewPenRTaccInt_interact(1).P(1).P = RewCode_acc(incl_int); %% vector of -1 and 1
%             allSOTSconds_Event_AllIntervPmod_RewPenRTaccInt_interact(1).P(1).h = 1;  % polynomial
%             allSOTSconds_Event_AllIntervPmod_RewPenRTaccInt_interact(1).P(2).name = 'isHighPen'; 
%             allSOTSconds_Event_AllIntervPmod_RewPenRTaccInt_interact(1).P(2).P = PenCode_acc(incl_int); %% vector of -1 and 1
%             allSOTSconds_Event_AllIntervPmod_RewPenRTaccInt_interact(1).P(2).h = 1;
%             allSOTSconds_Event_AllIntervPmod_RewPenRTaccInt_interact(1).P(3).name = 'IntervalNum'; 
%             allSOTSconds_Event_AllIntervPmod_RewPenRTaccInt_interact(1).P(3).P = IntervalNum_acc(incl_int); %% interval number in session (scaled)
%             allSOTSconds_Event_AllIntervPmod_RewPenRTaccInt_interact(1).P(3).h = 1;
%             allSOTSconds_Event_AllIntervPmod_RewPenRTaccInt_interact(1).P(4).name = 'isHighRew*isHighPen'; 
%             allSOTSconds_Event_AllIntervPmod_RewPenRTaccInt_interact(1).P(4).P = RewCode_acc(incl_int)*RewCode_acc(incl_int); 
%             allSOTSconds_Event_AllIntervPmod_RewPenRTaccInt_interact(1).P(4).h = 1;
%             allSOTSconds_Event_AllIntervPmod_RewPenRTaccInt_interact(1).orth = 0; %% turn off serial orthogonalization
%             % Response Window Regressor
%             allSOTSconds_Event_AllIntervPmod_RewPenRTaccInt_interact(2).name = 'AllRespInts';
%             allSOTSconds_Event_AllIntervPmod_RewPenRTaccInt_interact(2).ons = tmpAllOnset_responsewindowstart_acc(incl_int);
%             allSOTSconds_Event_AllIntervPmod_RewPenRTaccInt_interact(2).dur = tmpAllOnset_responsewindowduration_acc(incl_int);
%             allSOTSconds_Event_AllIntervPmod_RewPenRTaccInt_interact(2).P(1).name = 'isHighRew'; 
%             allSOTSconds_Event_AllIntervPmod_RewPenRTaccInt_interact(2).P(1).P = RewCode_acc(incl_int); %% vector of -1 and 1
%             allSOTSconds_Event_AllIntervPmod_RewPenRTaccInt_interact(2).P(1).h = 1;  % polynomial           
%             allSOTSconds_Event_AllIntervPmod_RewPenRTaccInt_interact(2).P(2).name = 'isHighPen'; 
%             allSOTSconds_Event_AllIntervPmod_RewPenRTaccInt_interact(2).P(2).P = PenCode_acc(incl_int); %% vector of -1 and 1
%             allSOTSconds_Event_AllIntervPmod_RewPenRTaccInt_interact(2).P(2).h = 1;                     
%             allSOTSconds_Event_AllIntervPmod_RewPenRTaccInt_interact(2).P(3).name = 'avgRT'; 
%             allSOTSconds_Event_AllIntervPmod_RewPenRTaccInt_interact(2).P(3).P = avgRT_acc_center(incl_int); %% vector of average RT per interval
%             allSOTSconds_Event_AllIntervPmod_RewPenRTaccInt_interact(2).P(3).h = 1;            
%             allSOTSconds_Event_AllIntervPmod_RewPenRTaccInt_interact(2).P(4).name = 'avgAcc'; 
%             allSOTSconds_Event_AllIntervPmod_RewPenRTaccInt_interact(2).P(4).P = avgACC(incl_int); %% vector of average accuracy per interval
%             allSOTSconds_Event_AllIntervPmod_RewPenRTaccInt_interact(2).P(4).h = 1;            
%             allSOTSconds_Event_AllIntervPmod_RewPenRTaccInt_interact(2).P(5).name = 'IntervalNum'; 
%             allSOTSconds_Event_AllIntervPmod_RewPenRTaccInt_interact(2).P(5).P = IntervalNum_acc(incl_int); %% interval number in session (scaled)
%             allSOTSconds_Event_AllIntervPmod_RewPenRTaccInt_interact(2).P(5).h = 1;            
%             allSOTSconds_Event_AllIntervPmod_RewPenRTaccInt_interact(2).P(6).name = 'IntervalLength'; 
%             allSOTSconds_Event_AllIntervPmod_RewPenRTaccInt_interact(2).P(6).P = IntervalLength_acc(incl_int); %% interval length
%             allSOTSconds_Event_AllIntervPmod_RewPenRTaccInt_interact(2).P(6).h = 1;            
%             allSOTSconds_Event_AllIntervPmod_RewPenRTaccInt_interact(2).P(7).name = 'isHighRew*RT';
%             allSOTSconds_Event_AllIntervPmod_RewPenRTaccInt_interact(2).P(7).P = RewCode_acc(incl_int).*avgRT_acc_center(incl_int);
%             allSOTSconds_Event_AllIntervPmod_RewPenRTaccInt_interact(2).P(7).h = 1;  % polynomial
%             allSOTSconds_Event_AllIntervPmod_RewPenRTaccInt_interact(2).P(8).name = 'isHighPen*RT'; 
%             allSOTSconds_Event_AllIntervPmod_RewPenRTaccInt_interact(2).P(8).P = PenCode_acc(incl_int).*avgRT_acc_center(incl_int);
%             allSOTSconds_Event_AllIntervPmod_RewPenRTaccInt_interact(2).P(8).h = 1;
%             allSOTSconds_Event_AllIntervPmod_RewPenRTaccInt_interact(2).P(9).name = 'MeanCongruency';  %DYEDIT
%             allSOTSconds_Event_AllIntervPmod_RewPenRTaccInt_interact(2).P(9).P = IntervalNum_acc(incl_int); %% mean congruency per interval  %DYEDIT
%             allSOTSconds_Event_AllIntervPmod_RewPenRTaccInt_interact(2).P(9).h = 1;
%             allSOTSconds_Event_AllIntervPmod_RewPenRTaccInt_interact(1).P(10).name = 'isHighRew*isHighPen'; 
%             allSOTSconds_Event_AllIntervPmod_RewPenRTaccInt_interact(1).P(10).P = RewCode_acc(incl_int)*RewCode_acc(incl_int); 
%             allSOTSconds_Event_AllIntervPmod_RewPenRTaccInt_interact(1).P(10).h = 1;
%             allSOTSconds_Event_AllIntervPmod_RewPenRTaccInt_interact(2).orth = 0; %% turn off serial orthogonalization
%             % Feedback Regressor
%             allSOTSconds_Event_AllIntervPmod_RewPenRTaccInt_interact(3).name = 'AllFb';
%             allSOTSconds_Event_AllIntervPmod_RewPenRTaccInt_interact(3).ons = tmpAllOnset_feedbackstart_acc(incl_int);
%             allSOTSconds_Event_AllIntervPmod_RewPenRTaccInt_interact(3).dur = 0;
%             allSOTSconds_Event_AllIntervPmod_RewPenRTaccInt_interact(3).P(1).name = 'none';
%             allSOTSconds_Event_AllIntervPmod_RewPenRTaccInt_interact(3).orth = 0;  %% turn off serial orthogonalization            
%             % Error regressor
%             allSOTSconds_Event_AllIntervPmod_RewPenRTaccInt_interact(4).name = 'AllErrorEvents'; % ideally do not do with avgACC
%             allSOTSconds_Event_AllIntervPmod_RewPenRTaccInt_interact(4).ons = tmpAllOnset_trialErrorstart; 
%             allSOTSconds_Event_AllIntervPmod_RewPenRTaccInt_interact(4).dur = tmpAllOnset_trialErrorduration;
%             allSOTSconds_Event_AllIntervPmod_RewPenRTaccInt_interact(4).P(1).name = 'none';
%             allSOTSconds_Event_AllIntervPmod_RewPenRTaccInt_interact(4).orth = 0;  %% turn off serial orthogonalization   
%             % Task Bug regressor
%             if IntRemove.allTaskBugIntervalsRemove{subi,2} ~= 0
%                 allSOTSconds_Event_AllIntervPmod_RewPenRTaccInt_interact(5).name = 'AllTaskBugInts'; % ideally do not do with avgACC
%                 allSOTSconds_Event_AllIntervPmod_RewPenRTaccInt_interact(5).ons = tmpAllOnset_intTaskBugstart; 
%                 allSOTSconds_Event_AllIntervPmod_RewPenRTaccInt_interact(5).dur = tmpAllOnset_intTaskBugduration;
%                 allSOTSconds_Event_AllIntervPmod_RewPenRTaccInt_interact(5).P(1).name = 'none';
%                 allSOTSconds_Event_AllIntervPmod_RewPenRTaccInt_interact(5).orth = 0;  %% turn off serial orthogonalization
%             end

            
            
            
            %% Model without behavior
 
            %% GLM 11: FIR Analyses from cue onset
            
           
                
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %% SAVING THE SOTS FILES - Everything below this can be left as is
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Identify the Stimulus Onsets (SOTS) structs for each of the GLMS created above:
            tmpVars = whos;                                              % gets all variables in workspace
            tmpVars = {tmpVars(:).name};                                 % keeps only their names
            tmpVars = tmpVars(strncmp(tmpVars,'SOTS',4));       % selects the ones with allSOTSconds in the beginning
            % NOTE: important to have a unique common beginning for this to work
            
            % Loop through each of these GLMs
            for tvi = 1:length(tmpVars) 
                curSOTSname = tmpVars{tvi};
                curSOTS = eval(curSOTSname); 
                
                names = {curSOTS(:).name};
                onsets = {curSOTS(:).ons};
                durations = {curSOTS(:).dur}; 
                pmod = struct('name',{''},'param',{},'poly',{});
                orth = {curSOTS(:).orth};
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
                
                % Assign each GLM to corresponding index of the following variables
                subAllSOTSnames{tvi} = curSOTSname;
                subAllNames{tvi,1} = names;
                subAllOnsets{tvi,1} = onsets;
                subAllDurs{tvi,1} = durations;
                subAllPmod{tvi,1} = pmod;
                subAllOrth{tvi,1} = orth;
                
                % clear the variables from workspace
                clear('names','onsets','durations','pmod','orth');
            end
            
            % Saving out all of the stimulus onset (sots) files
            for tviii = 1:size(subAllPmod,1)            
                curSOTSname = subAllSOTSnames{tviii};
                
                modSubAllPmods = subAllPmod(tviii,:);
                
                names = subAllNames{tviii,1};
                onsets = subAllOnsets{tviii,1};
                durations = subAllDurs{tviii,1};
                pmod = modSubAllPmods{1};
                orth = subAllOrth{tviii,1};
                
                % displays warnings if there are errors
                for oi =1:length(onsets)
                    if length(find(onsets{oi}<0))>0
                        display(['CRITICAL!!!!!! BAD ONSET FOR SUBJECT: ',p.subID,', ANALYSIS: ',curSOTSname(5:end)]);
                    end
                    if length((onsets{oi}))==0
                        display(['MISSING EVENTS FOR SUBJECT: ',p.subID,', ANALYSIS: ',curSOTSname(5:end)]);
                    end
                end
                
                for p1 = 1:length(pmod)
                    for p2 = 1:length(pmod(p1).param)
                        if length(unique(pmod(p1).param{p2}))<=1
                            display(['NO VARIATION IN PMOD ',num2str(p2),...
                                ' FOR COND ',num2str(p1),', SUBJECT: ',p.subID,', ANALYSIS: ',curSOTSname(5:end)]);
                        end
                    end
                end
                
                
                % Change to stimulus onsets folder within subject folder
                % If it doesn't exist, then create directory for stimulus onsets (SOTS)
                if ~exist('SOTS','dir')
                    %unix(['rm ',STUDYroot,'*sots*mat']);
                    mkdir('SOTS');
                end
                if tviii==1
                    %unix(['rm -f SOTS/',STUDYroot,'*sots*mat']);
                end
                
                save(['SOTS/',STUDYroot,curSOTSname(5:end),'_sots_allTcat.mat'],'names','onsets','durations','pmod','orth');
                
                % Remove variables from Workspace
                clear('names','onsets','durations','pmod','orth');
                clear modSubAllPmods;
            end
            % After saving all of the GLMS, remove variables from workspace
            clear('subAllNames','subAllOnsets','subAllDurs','subAllPmod');
            display(['COMPLETED Subject ',p.subID]);
        
%             % Save the Task Bug Remove Error Table 
%             save([basepathFormat,'/allTaskBugRemove.mat'],'allTaskBugRemove');
    
            
        
        else
            %% Excluded Subject
            display(['EXCLUDING Subject',p.subID]);
            try
                subID_exclude = [p.subID];
                save(fullfile(basepathMR,curSubString,'EXCLUDE.mat'),'subID_exclude');
            end
        end
        
    end

end
