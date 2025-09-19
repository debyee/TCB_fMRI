function TCB_makeSOTS 
    
    clear all;

    % Set paths 
    basepath = '/gpfs/data/ashenhav/mri-data/TCB';
    basepathBehav = [basepath,'/behavior/raw'];
    basepathMR = [basepath,'/spm-data'];

    %% STUDY INFORMATION:
    STUDYroot = 'TCB';

    %% PLACEHOLDERS:
    exSubs = [2018]; % 
    excludeSubRuns(1,:) = [9999,1];
    %numActualBlockTRs = nan; % Excluding initial dummy TRs (DEAL WITH BELOW)

    %% Start group loop
    % Change directories
    chdir(basepath);
    allResultsB = dir([basepathBehav,'/TSS*.mat']);
    allResultsB = {allResultsB(:).name};

    for subi=1:length(allResultsB)
        
        % Load the behavioral data for each subject
        load(fullfile(basepathBehav,allResultsB{subi}));
    
        % Get current subject based on matlab filename (this might be redundant, may delete later)
        curSub = allResultsB{subi};
        curSubString = curSub(23:26); % previously curSubMR
        curSubNum = str2num(curSubString);
        
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
            
            % Extract timings per subject
            % Cue Onset
            tmpAllOnset_intervalstart = plus(sum(results.timing.interval.intervalStartRelative),BlockTimeOffset);
            tmpAllOnset_intervalend = plus(sum(results.timing.interval.intervalEndRelative),BlockTimeOffset);
            tmpAllOnset_intervalduration = tmpAllOnset_intervalend - tmpAllOnset_intervalstart;
            % Interval Duration (Response Window)
            tmpAllOnset_responsewindowstart = plus(sum(results.timing.interval.respWindowOnsetRelative),BlockTimeOffset);
            tmpAllOnset_responsewindowend = plus(sum(results.timing.interval.respWindowOffsetRelative),BlockTimeOffset);
            tmpAllOnset_responsewindowduration = tmpAllOnset_responsewindowend - tmpAllOnset_responsewindowstart;
            % Feedback Onset
            tmpAllOnset_feedbackstart = plus(sum(results.timing.interval.fbOnsetRelative),BlockTimeOffset);
            tmpAllOnset_feedbackend = plus(sum(results.timing.interval.fbOffsetRelative),BlockTimeOffset);
            tmpAllOnset_feedbackduration = tmpAllOnset_feedbackend - tmpAllOnset_feedbackstart;
        
            
            %% GLM 1: Cues with 4 Conditions: HighValRew, LowValRew, HighValPen, LowValPen
            % Generate Indices for each of the conditions
            index_HRHP = find(results.interval.rewLevel==1 & results.interval.penaltyLevel==1);
            index_HRLP = find(results.interval.rewLevel==1 & results.interval.penaltyLevel==0);
            index_LRHP = find(results.interval.rewLevel==0 & results.interval.penaltyLevel==1);
            index_LRLP = find(results.interval.rewLevel==0 & results.interval.penaltyLevel==0);
            % Assign conditions to separate regressors
            allSOTSconds_Event_Cue_RewPenHighLow = [];
            allSOTSconds_Event_Cue_RewPenHighLow(1).name = 'CueHighRewHighPen';
            allSOTSconds_Event_Cue_RewPenHighLow(1).ons = tmpAllOnset_intervalstart(index_HRHP);
            allSOTSconds_Event_Cue_RewPenHighLow(1).dur = 0;
            allSOTSconds_Event_Cue_RewPenHighLow(1).P(1).name = 'none'; 
            allSOTSconds_Event_Cue_RewPenHighLow(2).name = 'CueHighRewLowPen';
            allSOTSconds_Event_Cue_RewPenHighLow(2).ons = tmpAllOnset_intervalstart(index_HRLP);
            allSOTSconds_Event_Cue_RewPenHighLow(2).dur = 0;
            allSOTSconds_Event_Cue_RewPenHighLow(2).P(1).name = 'none';    
            allSOTSconds_Event_Cue_RewPenHighLow(3).name = 'CueLowRewHighPen';
            allSOTSconds_Event_Cue_RewPenHighLow(3).ons = tmpAllOnset_intervalstart(index_LRHP);
            allSOTSconds_Event_Cue_RewPenHighLow(3).dur = 0;
            allSOTSconds_Event_Cue_RewPenHighLow(3).P(1).name = 'none'; 
            allSOTSconds_Event_Cue_RewPenHighLow(4).name = 'CueLowRewLowPen';
            allSOTSconds_Event_Cue_RewPenHighLow(4).ons = tmpAllOnset_intervalstart(index_LRLP);
            allSOTSconds_Event_Cue_RewPenHighLow(4).dur = 0;
            allSOTSconds_Event_Cue_RewPenHighLow(4).P(1).name = 'none';           
            

            %% GLM 2: Cues & Duration Modulated Intervals with 4 Conditions: HighValGain, LowValGain, HighValLoss, LowValLoss
            % Assign conditions to separate regressors
            allSOTSconds_Event_CueInterval_RewPenHighLow = [];
            allSOTSconds_Event_CueInterval_RewPenHighLow(1).name = 'CueHighRewHighPen';
            allSOTSconds_Event_CueInterval_RewPenHighLow(1).ons = tmpAllOnset_intervalstart(index_HRHP);
            allSOTSconds_Event_CueInterval_RewPenHighLow(1).dur = 0;
            allSOTSconds_Event_CueInterval_RewPenHighLow(1).P(1).name = 'none'; 
            allSOTSconds_Event_CueInterval_RewPenHighLow(2).name = 'CueHighRewLowPen';
            allSOTSconds_Event_CueInterval_RewPenHighLow(2).ons = tmpAllOnset_intervalstart(index_HRLP);
            allSOTSconds_Event_CueInterval_RewPenHighLow(2).dur = 0;
            allSOTSconds_Event_CueInterval_RewPenHighLow(2).P(1).name = 'none';    
            allSOTSconds_Event_CueInterval_RewPenHighLow(3).name = 'CueLowRewHighPen';
            allSOTSconds_Event_CueInterval_RewPenHighLow(3).ons = tmpAllOnset_intervalstart(index_LRHP);
            allSOTSconds_Event_CueInterval_RewPenHighLow(3).dur = 0;
            allSOTSconds_Event_CueInterval_RewPenHighLow(3).P(1).name = 'none'; 
            allSOTSconds_Event_CueInterval_RewPenHighLow(4).name = 'CueLowRewLowPen';
            allSOTSconds_Event_CueInterval_RewPenHighLow(4).ons = tmpAllOnset_intervalstart(index_LRLP);
            allSOTSconds_Event_CueInterval_RewPenHighLow(4).dur = 0;
            allSOTSconds_Event_CueInterval_RewPenHighLow(4).P(1).name = 'none';      
            allSOTSconds_Event_CueInterval_RewPenHighLow(5).name = 'IntervalHighRewHighPen';
            allSOTSconds_Event_CueInterval_RewPenHighLow(5).ons = tmpAllOnset_responsewindowstart(index_HRHP);
            allSOTSconds_Event_CueInterval_RewPenHighLow(5).dur = tmpAllOnset_responsewindowduration(index_HRHP);
            allSOTSconds_Event_CueInterval_RewPenHighLow(5).P(1).name = 'none'; 
            allSOTSconds_Event_CueInterval_RewPenHighLow(6).name = 'IntervalHighRewLowPen';
            allSOTSconds_Event_CueInterval_RewPenHighLow(6).ons = tmpAllOnset_responsewindowstart(index_HRLP);
            allSOTSconds_Event_CueInterval_RewPenHighLow(6).dur = tmpAllOnset_responsewindowduration(index_HRLP);
            allSOTSconds_Event_CueInterval_RewPenHighLow(6).P(1).name = 'none';    
            allSOTSconds_Event_CueInterval_RewPenHighLow(7).name = 'IntervalLowRewHighPen';
            allSOTSconds_Event_CueInterval_RewPenHighLow(7).ons = tmpAllOnset_responsewindowstart(index_LRHP);
            allSOTSconds_Event_CueInterval_RewPenHighLow(7).dur = tmpAllOnset_responsewindowduration(index_LRHP);
            allSOTSconds_Event_CueInterval_RewPenHighLow(7).P(1).name = 'none'; 
            allSOTSconds_Event_CueInterval_RewPenHighLow(8).name = 'IntervalLowRewLowPen';
            allSOTSconds_Event_CueInterval_RewPenHighLow(8).ons = tmpAllOnset_responsewindowstart(index_LRLP);
            allSOTSconds_Event_CueInterval_RewPenHighLow(8).dur = tmpAllOnset_responsewindowduration(index_LRLP);
            allSOTSconds_Event_CueInterval_RewPenHighLow(8).P(1).name = 'none';          
            

            %% GLM 3: Cues, Feedback, &Duration Modulated Intervals with 4 Conditions: HighValGain, LowValGain, HighValLoss, LowValLoss
            % Assign conditions to separate regressors
            allSOTSconds_Event_CueIntervalFb_RewPenHighLow = [];
            allSOTSconds_Event_CueIntervalFb_RewPenHighLow(1).name = 'CueHighRewHighPen';
            allSOTSconds_Event_CueIntervalFb_RewPenHighLow(1).ons = tmpAllOnset_intervalstart(index_HRHP);
            allSOTSconds_Event_CueIntervalFb_RewPenHighLow(1).dur = 0;
            allSOTSconds_Event_CueIntervalFb_RewPenHighLow(1).P(1).name = 'none'; 
            allSOTSconds_Event_CueIntervalFb_RewPenHighLow(2).name = 'CueHighRewLowPen';
            allSOTSconds_Event_CueIntervalFb_RewPenHighLow(2).ons = tmpAllOnset_intervalstart(index_HRLP);
            allSOTSconds_Event_CueIntervalFb_RewPenHighLow(2).dur = 0;
            allSOTSconds_Event_CueIntervalFb_RewPenHighLow(2).P(1).name = 'none';    
            allSOTSconds_Event_CueIntervalFb_RewPenHighLow(3).name = 'CueLowRewHighPen';
            allSOTSconds_Event_CueIntervalFb_RewPenHighLow(3).ons = tmpAllOnset_intervalstart(index_LRHP);
            allSOTSconds_Event_CueIntervalFb_RewPenHighLow(3).dur = 0;
            allSOTSconds_Event_CueIntervalFb_RewPenHighLow(3).P(1).name = 'none'; 
            allSOTSconds_Event_CueIntervalFb_RewPenHighLow(4).name = 'CueLowRewLowPen';
            allSOTSconds_Event_CueIntervalFb_RewPenHighLow(4).ons = tmpAllOnset_intervalstart(index_LRLP);
            allSOTSconds_Event_CueIntervalFb_RewPenHighLow(4).dur = 0;
            allSOTSconds_Event_CueIntervalFb_RewPenHighLow(4).P(1).name = 'none';      
            allSOTSconds_Event_CueIntervalFb_RewPenHighLow(5).name = 'IntervalHighRewHighPen';
            allSOTSconds_Event_CueIntervalFb_RewPenHighLow(5).ons = tmpAllOnset_responsewindowstart(index_HRHP);
            allSOTSconds_Event_CueIntervalFb_RewPenHighLow(5).dur = tmpAllOnset_responsewindowduration(index_HRHP);
            allSOTSconds_Event_CueIntervalFb_RewPenHighLow(5).P(1).name = 'none'; 
            allSOTSconds_Event_CueIntervalFb_RewPenHighLow(6).name = 'IntervalHighRewLowPen';
            allSOTSconds_Event_CueIntervalFb_RewPenHighLow(6).ons = tmpAllOnset_responsewindowstart(index_HRLP);
            allSOTSconds_Event_CueIntervalFb_RewPenHighLow(6).dur = tmpAllOnset_responsewindowduration(index_HRLP);
            allSOTSconds_Event_CueIntervalFb_RewPenHighLow(6).P(1).name = 'none';    
            allSOTSconds_Event_CueIntervalFb_RewPenHighLow(7).name = 'IntervalLowRewHighPen';
            allSOTSconds_Event_CueIntervalFb_RewPenHighLow(7).ons = tmpAllOnset_responsewindowstart(index_LRHP);
            allSOTSconds_Event_CueIntervalFb_RewPenHighLow(7).dur = tmpAllOnset_responsewindowduration(index_LRHP);
            allSOTSconds_Event_CueIntervalFb_RewPenHighLow(7).P(1).name = 'none'; 
            allSOTSconds_Event_CueIntervalFb_RewPenHighLow(8).name = 'IntervalLowRewLowPen';
            allSOTSconds_Event_CueIntervalFb_RewPenHighLow(8).ons = tmpAllOnset_responsewindowstart(index_LRLP);
            allSOTSconds_Event_CueIntervalFb_RewPenHighLow(8).dur = tmpAllOnset_responsewindowduration(index_LRLP);
            allSOTSconds_Event_CueIntervalFb_RewPenHighLow(8).P(1).name = 'none'; 
            allSOTSconds_Event_CueIntervalFb_RewPenHighLow(9).name = 'FbHighRewHighPen';
            allSOTSconds_Event_CueIntervalFb_RewPenHighLow(9).ons = tmpAllOnset_feedbackstart(index_HRHP);
            allSOTSconds_Event_CueIntervalFb_RewPenHighLow(9).dur = 0;
            allSOTSconds_Event_CueIntervalFb_RewPenHighLow(9).P(1).name = 'none'; 
            allSOTSconds_Event_CueIntervalFb_RewPenHighLow(10).name = 'FbHighRewLowPen';
            allSOTSconds_Event_CueIntervalFb_RewPenHighLow(10).ons = tmpAllOnset_feedbackstart(index_HRLP);
            allSOTSconds_Event_CueIntervalFb_RewPenHighLow(10).dur = 0;
            allSOTSconds_Event_CueIntervalFb_RewPenHighLow(10).P(1).name = 'none';    
            allSOTSconds_Event_CueIntervalFb_RewPenHighLow(11).name = 'FbLowRewHighPen';
            allSOTSconds_Event_CueIntervalFb_RewPenHighLow(11).ons = tmpAllOnset_feedbackstart(index_LRHP);
            allSOTSconds_Event_CueIntervalFb_RewPenHighLow(11).dur = 0;
            allSOTSconds_Event_CueIntervalFb_RewPenHighLow(11).P(1).name = 'none'; 
            allSOTSconds_Event_CueIntervalFb_RewPenHighLow(12).name = 'FbLowRewLowPen';
            allSOTSconds_Event_CueIntervalFb_RewPenHighLow(12).ons = tmpAllOnset_feedbackstart(index_LRLP);
            allSOTSconds_Event_CueIntervalFb_RewPenHighLow(12).dur = 0;
            allSOTSconds_Event_CueIntervalFb_RewPenHighLow(12).P(1).name = 'none';      

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %% SAVING THE SOTS FILES - Everything below this can be left as is
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Identify the Stimulus Onsets (SOTS) structs for each of the GLMS created above:
            tmpVars = whos;                                              % gets all variables in workspace
            tmpVars = {tmpVars(:).name};                                 % keeps only their names
            tmpVars = tmpVars(strncmp(tmpVars,'allSOTSconds',12));       % selects the ones with allSOTSconds in the beginning
            % NOTE: important to have a unique common beginning for this to work
            
            % Loop through each of these GLMs
            for tvi = 1:length(tmpVars) 
                curSOTSname = tmpVars{tvi};
                curSOTS = eval(curSOTSname); 
                
                names = {curSOTS(:).name};
                onsets = {curSOTS(:).ons};
                durations = {curSOTS(:).dur}; 
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
                
                % Assign each GLM to corresponding index of the following variables
                subAllSOTSnames{tvi} = curSOTSname;
                subAllNames{tvi,1} = names;
                subAllOnsets{tvi,1} = onsets;
                subAllDurs{tvi,1} = durations;
                subAllPmod{tvi,1} = pmod;
                
                % clear the variables from workspace
                clear('names','onsets','durations','pmod');
            end
            
            % Saving out all of the stimulus onset (sots) files
            for tviii = 1:size(subAllPmod,1)            
                curSOTSname = subAllSOTSnames{tviii};
                
                modSubAllPmods = subAllPmod(tviii,:);
                
                names = subAllNames{tviii,1};
                onsets = subAllOnsets{tviii,1};
                durations = subAllDurs{tviii,1};
                pmod = modSubAllPmods{1};
                
                % displays warnings there are errors
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
                
                
                % Change to stimulus onsets folder within subject folder
                % If it doesn't exist, then create directory for stimulus onsets (SOTS)
                if ~exist('SOTS','dir')
                    %unix(['rm ',STUDYroot,'*sots*mat']);
                    mkdir('SOTS');
                end
                if tviii==1
                    %unix(['rm -f SOTS/',STUDYroot,'*sots*mat']);
                end
                
                save(['SOTS/',STUDYroot,curSOTSname(13:end),'_sots_allTcat.mat'],'names','onsets','durations','pmod');
                
                % Remove variables from Workspace
                clear('names','onsets','durations','pmod');
                clear modSubAllPmods;
            end
            % After saving all of the GLMS, remove variables from workspace
            clear('subAllNames','subAllOnsets','subAllDurs','subAllPmod');
        
            
        
        else
            %% Excluded Subject
            display(['EXCLUDING subject',p.subID]);
            try
                subID_exclude = [p.subID];
                save(fullfile(basepathMR,curSubString,'EXCLUDE.mat'),'subID_exclude');
            end
        end
        
    end

end
