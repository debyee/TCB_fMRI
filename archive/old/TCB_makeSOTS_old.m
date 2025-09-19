clear all;

%basepath = '~/Dropbox (Brown)/ShenhavLab/experiments/FXC/';
%basepathMR = '/Volumes/Research/CLPS_Shenhav_Lab/ScanningData/FXC/Data';
%basepathBehav = '~/Dropbox (Brown)/ShenhavLab/experiments/FXC/Results/';
% addpath('/Volumes/Research/CLPS_Shenhav_Lab/ScanningData/BASB/Scripts'); 
% to access e.g. AS_nanzscore and later potentially other useful functions

Debbie_debug = 0;
if Debbie_debug == 1
    addpath('/Users/debbieyee/Documents/MATLAB/spm12/')
end
%basepath = '/Volumes/dyee7/data/mri-data/TCB';
%basepathBehav = '/Volumes/dyee7/data/mri-data/TCB/behavior/raw';
%basepathMR = '/Volumes/dyee7/data/mri-data/TCB/spm-data';

%numBlockStartTRs = 3;
%numBlockEndTRs = 3;

%% STUDY INFORMATION:
STUDYroot = 'TCB';

%% PLACEHOLDERS:
exSubs = [2001]; % 
excludeSubRuns(1,:) = [9999,1];
numActualBlockTRs = nan; % Excluding initial dummy TRs (DEAL WITH BELOW)

%% Start group loop
% Change directories
chdir(basepath);
allResultsB = dir('behavior/raw/TSS_TCB*mat'); 
allResultsB = {allResultsB(:).name};

for subi=1:length(allResultsB)
    
    % Load the behvioral data for each subject
    load(fullfile(basepathBehav,allResultsB{subi}));
   
    % Get current subject based on matlab filename (this might be redundant, may delete later)
    curSub = allResultsB{subi};
    curSubString = curSub(9:12); % previously curSubMR
    curSubNum = str2num(curSubString);
    
    % Check whether subject should be excluded. 
    tmpSubNum = str2num(p.subID(1:4)); 
    curFinalExclude = ~isempty(find(exSubs==tmpSubNum, 1));
    
    % If subject is not excluded, then created stimulus onsets
    if ~curFinalExclude
        
        % Display text for which subject is currently being processed
        display(['RUNNING subject ',p.subID]);
        
        % Change to subject folder within MR directory
        % If doesnt exist, then create directory for subject
        chdir(basepathMR);
        if ~exist(['sub-',curSubString],'dir')
            mkdir(['sub-',curSubString]);
        end
        chdir(fullfile(['sub-',curSubString]));

        
        %% Subject Processing: Extract Timing Information for Onsets
        
        % Number of TRs in block, based upon the xnat files
        numTRsInBlock = 310;  
        
        % Calculate blocklength in seconds (should be 372 secs) 
        BlockLengthInSecs = p.TRlength*numTRsInBlock;

        % Calculate time offset to adjust relative timings based on data
        BlockTimeOffset = repelem(0:(p.numBlocks-1),p.numIntervalsPerBlock)*BlockLengthInSecs;
        
        % Extract timings per subject
        tmpAllOnset_intervalstart = plus(sum(results.timing.interval.intervalStartRelative),BlockTimeOffset);
        tmpAllOnset_intervalend = plus(sum(results.timing.interval.intervalEndRelative),BlockTimeOffset);
        tmpAllOnset_intervalduration = tmpAllOnset_intervalend - tmpAllOnset_intervalstart;
        
        tmpAllOnset_responsewindowstart = plus(sum(results.timing.interval.respWidnowOnsetRelative),BlockTimeOffset);
        tmpAllOnset_responsewindowend = plus(sum(results.timing.interval.respWidnowOffsetRelative),BlockTimeOffset);
        tmpAllOnset_responsewindowduration = tmpAllOnset_responsewindowend - tmpAllOnset_responsewindowstart;
        
        %% GLM 1: Cues with 4 Conditions: HighValGain, LowValGain, HighValLoss, LowValLoss
        % Generate Indices for each of the conditions
        index_HighValGain = find(results.interval.isGain==1 & results.interval.rewLvL==1);
        index_LowValGain = find(results.interval.isGain==1 & results.interval.rewLvL==0);
        index_HighValLoss = find(results.interval.isGain==0 & results.interval.rewLvL==1);
        index_LowValLoss = find(results.interval.isGain==0 & results.interval.rewLvL==0);
        % Assign conditions to separate regressors
        allSOTSconds_Event_Cue_GainLossHighLow = [];
        allSOTSconds_Event_Cue_GainLossHighLow(1).name = 'CueHighValGain';
        allSOTSconds_Event_Cue_GainLossHighLow(1).ons = tmpAllOnset_intervalstart(index_HighValGain);
        allSOTSconds_Event_Cue_GainLossHighLow(1).dur = 0;
        allSOTSconds_Event_Cue_GainLossHighLow(1).P(1).name = 'none'; 
        allSOTSconds_Event_Cue_GainLossHighLow(2).name = 'CueLowValGain';
        allSOTSconds_Event_Cue_GainLossHighLow(2).ons = tmpAllOnset_intervalstart(index_LowValGain);
        allSOTSconds_Event_Cue_GainLossHighLow(2).dur = 0;
        allSOTSconds_Event_Cue_GainLossHighLow(2).P(1).name = 'none';    
        allSOTSconds_Event_Cue_GainLossHighLow(3).name = 'CueHighValLoss';
        allSOTSconds_Event_Cue_GainLossHighLow(3).ons = tmpAllOnset_intervalstart(index_HighValLoss);
        allSOTSconds_Event_Cue_GainLossHighLow(3).dur = 0;
        allSOTSconds_Event_Cue_GainLossHighLow(3).P(1).name = 'none'; 
        allSOTSconds_Event_Cue_GainLossHighLow(4).name = 'CueLowValLoss';
        allSOTSconds_Event_Cue_GainLossHighLow(4).ons = tmpAllOnset_intervalstart(index_LowValLoss);
        allSOTSconds_Event_Cue_GainLossHighLow(4).dur = 0;
        allSOTSconds_Event_Cue_GainLossHighLow(4).P(1).name = 'none';           
        

        %% GLM 2: Cues & Duration Modulated Intervals with 4 Conditions: HighValGain, LowValGain, HighValLoss, LowValLoss
        % Assign conditions to separate regressors
        allSOTSconds_Event_CueInterval_GainLossHighLow = [];
        allSOTSconds_Event_CueInterval_GainLossHighLow(1).name = 'CueHighValGain';
        allSOTSconds_Event_CueInterval_GainLossHighLow(1).ons = tmpAllOnset_intervalstart(index_HighValGain);
        allSOTSconds_Event_CueInterval_GainLossHighLow(1).dur = 0;
        allSOTSconds_Event_CueInterval_GainLossHighLow(1).P(1).name = 'none'; 
        allSOTSconds_Event_CueInterval_GainLossHighLow(2).name = 'CueLowValGain';
        allSOTSconds_Event_CueInterval_GainLossHighLow(2).ons = tmpAllOnset_intervalstart(index_LowValGain);
        allSOTSconds_Event_CueInterval_GainLossHighLow(2).dur = 0;
        allSOTSconds_Event_CueInterval_GainLossHighLow(2).P(1).name = 'none';    
        allSOTSconds_Event_CueInterval_GainLossHighLow(3).name = 'CueHighValLoss';
        allSOTSconds_Event_CueInterval_GainLossHighLow(3).ons = tmpAllOnset_intervalstart(index_HighValLoss);
        allSOTSconds_Event_CueInterval_GainLossHighLow(3).dur = 0;
        allSOTSconds_Event_CueInterval_GainLossHighLow(3).P(1).name = 'none'; 
        allSOTSconds_Event_CueInterval_GainLossHighLow(4).name = 'CueLowValLoss';
        allSOTSconds_Event_CueInterval_GainLossHighLow(4).ons = tmpAllOnset_intervalstart(index_LowValLoss);
        allSOTSconds_Event_CueInterval_GainLossHighLow(4).dur = 0;
        allSOTSconds_Event_CueInterval_GainLossHighLow(4).P(1).name = 'none';      
        allSOTSconds_Event_CueInterval_GainLossHighLow(5).name = 'IntervalHighValGain';
        allSOTSconds_Event_CueInterval_GainLossHighLow(5).ons = tmpAllOnset_responsewindowstart(index_HighValGain);
        allSOTSconds_Event_CueInterval_GainLossHighLow(5).dur = tmpAllOnset_responsewindowduration(index_HighValGain);
        allSOTSconds_Event_CueInterval_GainLossHighLow(5).P(1).name = 'none'; 
        allSOTSconds_Event_CueInterval_GainLossHighLow(6).name = 'IntervalLowValGain';
        allSOTSconds_Event_CueInterval_GainLossHighLow(6).ons = tmpAllOnset_responsewindowstart(index_LowValGain);
        allSOTSconds_Event_CueInterval_GainLossHighLow(6).dur = tmpAllOnset_responsewindowduration(index_LowValGain);
        allSOTSconds_Event_CueInterval_GainLossHighLow(6).P(1).name = 'none';    
        allSOTSconds_Event_CueInterval_GainLossHighLow(7).name = 'IntervalHighValLoss';
        allSOTSconds_Event_CueInterval_GainLossHighLow(7).ons = tmpAllOnset_responsewindowstart(index_HighValLoss);
        allSOTSconds_Event_CueInterval_GainLossHighLow(7).dur = tmpAllOnset_responsewindowduration(index_HighValLoss);
        allSOTSconds_Event_CueInterval_GainLossHighLow(7).P(1).name = 'none'; 
        allSOTSconds_Event_CueInterval_GainLossHighLow(8).name = 'IntervalLowValLoss';
        allSOTSconds_Event_CueInterval_GainLossHighLow(8).ons = tmpAllOnset_responsewindowstart(index_LowValLoss);
        allSOTSconds_Event_CueInterval_GainLossHighLow(8).dur = tmpAllOnsebt_responsewindowduration(index_LowValLoss);
        allSOTSconds_Event_CueInterval_GainLossHighLow(8).P(1).name = 'none';          
        
        
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
                unix(['rm ',STUDYroot,'*sots*mat']);
                mkdir('SOTS');
            end
            if tviii==1
                unix(['rm -f SOTS/',STUDYroot,'*sots*mat']);
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

