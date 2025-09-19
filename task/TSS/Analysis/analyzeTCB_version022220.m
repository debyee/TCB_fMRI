clear;
runGLMs = 0;

% chdir('~/Dropbox (Brown)/ShenhavLab/Experiments/TSS/Analysis');
% isOAsubject = 1

%% LOAD IN ALL OF THE DATA FILES
files = dir('../TCB/Results/TSS_TCB_2*mat');
fileNames = {files(:).name};

for x = 1:length(fileNames)
    file = ['../TCB/Results/', fileNames{x}];
    data.raw(x) = load(file);
end

%% CONCATENATE ALL OF THE SUBJECT DATA INTO TWO TABLES

% Initialize empty cells to store subject data into tables 
subDataAll_Trial = {};      % Trial-level
subDataAll_Interval = {};   % Interval-level

% Loop over the subject data to extract out the relevant variables and
% concatenate into two tables. One table will be at the trial level,
% whereas the other talbe will be at the interval level.
for x = 1:length(fileNames)
    try

        % Calculate number of intervals and trials
        numIntervalsPerBlock = data.raw(x).p.numIntervalsPerBlock;
        numIntervalsTotal = length(data.raw(x).results.TrialsResponded);
        numTrialsPerInterval = data.raw(x).results.TrialsResponded;
        numTrialsTotal = sum(data.raw(x).results.TrialsResponded);
        
        % Interval level properties
        rewLvl = data.raw(x).p.intervalRewLvl;
        gainLvl = data.raw(x).p.intervalIsGain;
        
        % Subject ID and version
        subID = str2num(data.raw(x).p.subID);
        curSubID = subID*ones(1,numTrialsTotal);
        version = data.raw(x).p.version;
        curVersion = version*ones(1,numTrialsTotal);
        
        % Stimulus properties
        StimWord = {data.raw(x).p.stimuli.Text};
        curStimWord = StimWord(1:numTrialsTotal);
        StimInkColor = {data.raw(x).p.stimuli.InkColor};
        curStimInkColor = StimInkColor(1:numTrialsTotal);
        stimCongruency = [data.raw(x).p.stimuli(:).IsCongruent];
        curStimCongruency = stimCongruency(1:numTrialsTotal);
        
        % Extract correct responses
        correctResp = [data.raw(x).p.stimuli(:).ColorAns];
        curCorrectResp = correctResp(1:numTrialsTotal);
        trialsCompletedPerInterval = data.raw(x).results.TrialsResponded;

        % Extract participant responses
        curInitiationTime = data.raw(x).results.initiationTime;  %OA_param
        curResp = data.raw(x).results.resp;
        try 
            curRT = data.raw(x).results.newResponseTime;
        catch
            %%%% Reconcile w/ OA:
            curRT = data.raw(x).results.responseTime;
        end
        %%%  curAcc = data.raw(x).results.acc; %%% CDW: is this correct
        curTooFast = data.raw(x).results.tooFast;
        curAcc = curCorrectResp==curResp;
        
        %% CREATE ARRAYS FOR ALL TRIAL-BASED VARIABLES
        
        % Initialize arrays to fill based on total number of trials
        curBlockNum = ones(1,numTrialsTotal)*(-10);
        curIntNum = ones(1,numTrialsTotal)*(-10);
        curIntLength = ones(1,numTrialsTotal)*(-10);
        curTrialNuminInt = ones(1,numTrialsTotal)*(-10);
        curTrialsCompleted = ones(1,numTrialsTotal)*(-10);
        curRewLvl = ones(1,numTrialsTotal)*(-10);
        curGainLvl = ones(1,numTrialsTotal)*(-10);
        curIntLengthSecs = ones(1,numTrialsTotal)*(-10);
        curIntLengthSecsNoISI = ones(1,numTrialsTotal)*(-10);
        curBlockType = cell(1,numTrialsTotal);
        curBlockType = cell(1,numTrialsTotal);

        % Initialize arrays to fill based on total number of intervals
        curIntBasedIntNum = ones(1,numIntervalsTotal)*(-10);
        curIntBasedLengthSecs = ones(1,numIntervalsTotal)*(-10);
        curIntBasedLengthSecsNoISI = ones(1,numIntervalsTotal)*(-10);
        
        % Iterate over intervals to fill out arrays based on number of trials per interval
        for intNum = 1:numIntervalsTotal 
            
            % Set indices in array to input values
            ix_start = find(curBlockNum<0,1);
            ix_end = ix_start + numTrialsPerInterval(intNum) - 1;
            
            % Fill in trialwise variables based on current interval
            curBlockNum(ix_start:ix_end) = ceil(intNum/numIntervalsPerBlock);
            curIntNum(ix_start:ix_end) = intNum;
            curIntLength(ix_start:ix_end) = data.raw(x).p.intervalLength(intNum);
            curTrialNuminInt(ix_start:ix_end) = 1:numTrialsPerInterval(intNum);
            curTrialsCompleted(ix_start:ix_end) = trialsCompletedPerInterval(intNum);
            curRewLvl(ix_start:ix_end) = rewLvl(intNum);
            curGainLvl(ix_start:ix_end) = gainLvl(intNum);
            thisIntLengthSecs = data.raw(x).results.timing.intervalEnd(intNum)-data.raw(x).results.timing.intervalStart(intNum);
            curIntLengthSecs(ix_start:ix_end) = thisIntLengthSecs;
            curIntLengthSecsNoISI(ix_start:ix_end) = thisIntLengthSecs - ((trialsCompletedPerInterval(intNum) - 1) * data.raw(x).p.timing.isi);
            curBlockType(ix_start:ix_end) = repmat({data.raw(x).p.blockOrder{ceil(intNum/numIntervalsPerBlock)}},1,numTrialsPerInterval(intNum));   
            
            % Fill in interval info
            curIntBasedLengthSecs(intNum) = thisIntLengthSecs;
            curIntBasedLengthSecsNoISI(intNum) = thisIntLengthSecs - ((trialsCompletedPerInterval(intNum) - 1) * data.raw(x).p.timing.isi);
            curIntBasedIntNum(intNum) = intNum;
        end
        
        % Create variable that is held constant based on block type 
        % high reward = 20,  100 bombs vs. 100 gems
        % low reward = 10,   1 bomb vs. 1 gem
        % gain = 2,          100 gems vs. 1 gem
        % loss = 1           100 bombs vs. 1 bomb
        % Dont think this variable has been used for any analyses.
        curBlockTypeNum = nan(1,length(curBlockType));
        curBlockTypeNum(strcmp(curBlockType,'highRew')) = 20;
        curBlockTypeNum(strcmp(curBlockType,'lowRew')) = 10;
        curBlockTypeNum(strcmp(curBlockType,'gain')) = 2;
        curBlockTypeNum(strcmp(curBlockType,'loss')) = 1;
        
        % Dummy code the variables based on trial types perr interval
        % Reward level: High value (high reward) = 1, Partial Value (Gain or Loss) = 0, Low Value (low reward) = -1
        % Gain Level: Full Gain (both cues are 100) = 1, Partial Gain (cues are 100 and 1) = 0, No Gain (both cues are 1) = -1
        curSubBlockTypeRewLvl = (curBlockTypeNum==20) - (curBlockTypeNum==10);
        curSubBlockTypeGainLvl = (curBlockTypeNum==2) - (curBlockTypeNum==1);
        
        % Check if the data (number of intervals) is complete
        isComplete = numIntervalsTotal == data.raw(x).p.numIntervals;
        curIsComplete = repmat(isComplete, 1, length(curBlockNum));
        
        % Create interval vector
        curIntSubID = subID*ones(1,numIntervalsTotal);

        %% CREATE ARRAYS FOR ALL INTERVAL-BASED VARIABLES 
        
        % Initialize arrays to fill based on total number of trials
        curNumRespondedTrialsInInterval = ones(1,numTrialsTotal)*(-10);
        curNumCorrectTrialsInInterval = ones(1,numTrialsTotal)*(-10);
        
        % Initialize arrays to fill based on total number of intervals
        curIntBasedRespondedTrials = ones(1,numIntervalsTotal)*(-10);
        curIntBasedCorrectTrials = ones(1,numIntervalsTotal)*(-10);
        
        % Iterate over intervals to fill out arrays based on number of trials per interval
        for intNum = 1:numIntervalsTotal
            
            % Calculate number of trials responded and correct per interval 
            thisIntRespondedTrials = sum(~isnan(curRT(curIntNum==intNum)));
            thisIntCorrectTrials = sum(curAcc(curIntNum==intNum));
            
            % Set indices in array to input values
            ix_start = find(curNumRespondedTrialsInInterval<0,1);
            ix_end = ix_start + numTrialsPerInterval(intNum) - 1;
            
            % Fill in trialwise variables based on current interval
            curNumRespondedTrialsInInterval(ix_start:ix_end) = thisIntRespondedTrials;
            curNumCorrectTrialsInInterval(ix_start:ix_end) = thisIntCorrectTrials; 
            
            % Fill in interval info
            curIntBasedRespondedTrials(intNum) = thisIntRespondedTrials;
            curIntBasedCorrectTrials(intNum) = thisIntCorrectTrials;
            
        end
        
        % Normalizes the number of trials by the interval length
        curIntRespRateAll = curNumRespondedTrialsInInterval./curIntLengthSecs;
        %curIntInitRateAll = curNumInitiatedTrialsInInterval./curIntLengthSecs;
        curIntRespRateCorr = curNumCorrectTrialsInInterval./curIntLengthSecs;
        curIntRespRateCorrNoISI = curNumCorrectTrialsInInterval./curIntLengthSecsNoISI;
        
        curIntBasedRespRateAll = curIntBasedRespondedTrials./curIntBasedLengthSecs;
        %curIntBasedInitRateAll = curIntBasedInitiatedTrials./curIntBasedLengthSecs;
        curIntBasedRespRateCorr = curIntBasedCorrectTrials./curIntBasedLengthSecs;
        
        % Testing RTs:
        % %         curIntPctInterval = curCumulTimeInIntverval./curIntLengthSecs;
        
        
        %% COMPILE THE TRIAL AND INTERVAL VARIABLES INTO TWO TABLES 

        % Create a table of trial data that can be output for analyses (in R)
        % Can also use this table for analyses within matlab
        curSubData = table(curSubID',curVersion',curStimWord',curStimInkColor',curBlockType',curBlockNum',...
            curIntNum',curIntLength',curTrialsCompleted',curTrialNuminInt',curRewLvl', curGainLvl',curStimCongruency',...
            curSubBlockTypeRewLvl',curSubBlockTypeGainLvl',curCorrectResp',curResp',curIsComplete',...
        curRT',curAcc',curIntRespRateAll',curIntRespRateCorr',curIntRespRateCorrNoISI',curIntLengthSecs',curIntLengthSecsNoISI');
        curSubData_header = {'SubID','Vers','StimWord','StimColor','BlockType','BlockNum',...
            'IntervalNum','IntervalLength','TrialsInInterval','IntervalTrialNum','RewLvl','GainLvl','Congruency',...
            'RewLvlBlockcode','GainLvlBlockcode','CorrectResp','Resp','IsComplete',...
            'RT','Acc','RespRateAll','RespRateCorr','RespRateCorrNoISI','IntervalLengthSecs','IntervalLengthSecsNoISI'};
        curSubData.Properties.VariableNames = curSubData_header;
        
        % Create a table of the interval data that can be output for analyses (in R)
        % Can also use this table for analyses within matlab
        curSubDataInt = table(curIntSubID',rewLvl',gainLvl',curIntBasedIntNum',curIntBasedRespRateAll',curIntBasedRespRateCorr',curIntBasedLengthSecs');
        curSubDataInt_header = {'SubID','RewLvl','GainLvl','Interval','RespRateAll','RespRateCorr','IntervalLengthSecs'};
        curSubDataInt.Properties.VariableNames = curSubDataInt_header;

        % Vertically concatenate 
        subDataAll_Trial = vertcat(subDataAll_Trial,curSubData);
        subDataAll_Interval = vertcat(subDataAll_Interval,curSubDataInt);
        
    catch me
        sca
        keyboard
    end
end


%% Add Performance Variables
subDataAll_Trial.Acc(isnan(subDataAll_Trial.Resp)) = nan;
subDataAll_Trial.AccRT = subDataAll_Trial.Acc.*subDataAll_Trial.RT;
subDataAll_Trial.AccRT(subDataAll_Trial.Acc==0) = nan;
subDataAll_Trial.logRT = log(subDataAll_Trial.RT);
subDataAll_Trial.logAccRT = log(subDataAll_Trial.AccRT);
subDataAll_Trial.RespRateAll(isnan(subDataAll_Trial.RT)) = nan;

subDataAll_Trial.RewLvlBlockcode = categorical(subDataAll_Trial.RewLvlBlockcode,'Ordinal',true);
subDataAll_Trial.GainLvlBlockcode = categorical(subDataAll_Trial.GainLvlBlockcode,'Ordinal',true);

%% Run checks to make sure that data is complete
check1 = grpstats(subDataAll_Trial(subDataAll_Trial.IsComplete == 1,:),{'IntervalLength','GainLvl'},{'mean'},'DataVars',{'RT','Acc','AccRT','RespRateAll','RespRateCorr'});
check2 = grpstats(subDataAll_Trial(subDataAll_Trial.IsComplete == 1,:),{'IntervalLength','RewLvl'},{'mean'},'DataVars',{'RT','Acc','AccRT','RespRateAll','RespRateCorr'});
check3 = grpstats(subDataAll_Trial(subDataAll_Trial.IsComplete == 1,:),{'IntervalLength','RewLvl','GainLvl'},{'mean'},'DataVars',{'RT','Acc','AccRT','RespRateAll','RespRateCorr'});


%% SAVE DATA: Trial table exported as csv in "DataFormatted" subfolder
pathToSave = strcat(pwd,'/DataFormatted/data_TSS-TCB-LabVersion.csv');
writetable(subDataAll_Trial,pathToSave);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%% Done loading data %%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% ANALYSIS: Group Variables 
% NOTE: DY edid this, mostly renamed some variables and removed the initiation time related variables. 
% Kept the previous code for historical purposes, may opt to delete if redundnant.

%% Table: Subject means for each condition
%condMeansByInt = grpstats(subDataAll_Trial,{'Vers','SubID','IntervalNum'},{'mean'},'DataVars',{'SubID','GainLvl','RewLvl','Congruency','TrialsInInterval','InitiationRT','RT','Acc','AccRT','logRT','logAccRT','InitRateAll','RespRateAll','RespRateCorr'});
condMeansByInt = grpstats(subDataAll_Trial,{'Vers','SubID','IntervalNum'},{'mean'},'DataVars',{'SubID','GainLvl','RewLvl','Congruency','TrialsInInterval','RT','Acc','AccRT','logRT','logAccRT','RespRateAll','RespRateCorr'});

%% Table: Group means for each reward level
% condMeansR = grpstats(subDataAll_Trial,{'Vers','RewLvl'},{'nanmean'},'DataVars',{'TrialsInInterval','InitiationRT','RT','Acc','AccRT','logRT','logAccRT','InitRateAll','RespRateAll','RespRateCorr','RespRateCorrCORRECTED'});
% condMeansRbySub = grpstats(subDataAll_Trial,{'Vers','SubID','RewLvl'},{'nanmean'},'DataVars',{'TrialsInInterval','InitiationRT','RT','Acc','AccRT','logRT','logAccRT','InitRateAll','RespRateAll','RespRateCorr','RespRateCorrCORRECTED'});
% condMeansRbySubGrp = grpstats(condMeansRbySub,{'Vers','RewLvl'},{'nanmean','sem'},'DataVars',{'nanmean_TrialsInInterval','nanmean_InitiationRT','nanmean_RT','nanmean_Acc','nanmean_AccRT','nanmean_logRT','nanmean_logAccRT','nanmean_RespRateAll','nanmean_RespRateCorr'});
condMeansR = grpstats(subDataAll_Trial,{'Vers','RewLvl'},{'nanmean'},'DataVars',{'TrialsInInterval','RT','Acc','AccRT','logRT','logAccRT','RespRateAll','RespRateCorr','RespRateCorrNoISI'});
condMeansRbySub = grpstats(subDataAll_Trial,{'Vers','SubID','RewLvl'},{'nanmean'},'DataVars',{'TrialsInInterval','RT','Acc','AccRT','logRT','logAccRT','RespRateAll','RespRateCorr','RespRateCorrNoISI'});
condMeansRbySubGrp = grpstats(condMeansRbySub,{'Vers','RewLvl'},{'nanmean','sem'},'DataVars',{'nanmean_TrialsInInterval','nanmean_RT','nanmean_Acc','nanmean_AccRT','nanmean_logRT','nanmean_logAccRT','nanmean_RespRateAll','nanmean_RespRateCorr'});

% condMeansRbyBlock = grpstats(subDataAll_Trial,{'Vers','Block','RewLvl'},{'nanmean'},'DataVars',{'TrialsInInterval','InitiationRT','RT','Acc','AccRT','logRT','logAccRT','InitRateAll','RespRateAll','RespRateCorr','RespRateCorrNoISI'});
% condMeansRbySubbyBlock = grpstats(subDataAll_Trial,{'Vers','SubID','Block','RewLvl'},{'nanmean'},'DataVars',{'TrialsInInterval','InitiationRT','RT','Acc','AccRT','logRT','logAccRT','InitRateAll','RespRateAll','RespRateCorr','RespRateCorrNoISI'});
condMeansRbyBlock = grpstats(subDataAll_Trial,{'Vers','BlockNum','RewLvl'},{'nanmean'},'DataVars',{'TrialsInInterval','RT','Acc','AccRT','logRT','logAccRT','RespRateAll','RespRateCorr','RespRateCorrNoISI'});
condMeansRbySubbyBlock = grpstats(subDataAll_Trial,{'Vers','SubID','BlockNum','RewLvl'},{'nanmean'},'DataVars',{'TrialsInInterval','RT','Acc','AccRT','logRT','logAccRT','RespRateAll','RespRateCorr','RespRateCorrNoISI'});

%% Table: Group means for each gain level
% condMeansG = grpstats(subDataAll_Trial,{'Vers','GainLvl'},{'nanmean'},'DataVars',{'TrialsInInterval','InitiationRT','RT','Acc','AccRT','logRT','logAccRT','InitRateAll','RespRateAll','RespRateCorr','RespRateCorrNoISI'});
% condMeansGbySub = grpstats(subDataAll_Trial,{'Vers','SubID','GainLvl'},{'nanmean'},'DataVars',{'TrialsInInterval','InitiationRT','RT','Acc','AccRT','logRT','logAccRT','InitRateAll','RespRateAll','RespRateCorr','RespRateCorrNoISI'});
% condMeansGbySubGrp = grpstats(condMeansGbySub,{'Vers','GainLvl'},{'nanmean','sem'},'DataVars',{'nanmean_TrialsInInterval','nanmean_InitiationRT','nanmean_RT','nanmean_Acc','nanmean_AccRT','nanmean_logRT','nanmean_logAccRT','nanmean_RespRateAll','nanmean_RespRateCorr'});
condMeansG = grpstats(subDataAll_Trial,{'Vers','GainLvl'},{'nanmean'},'DataVars',{'TrialsInInterval','RT','Acc','AccRT','logRT','logAccRT','RespRateAll','RespRateCorr','RespRateCorrNoISI'});
condMeansGbySub = grpstats(subDataAll_Trial,{'Vers','SubID','GainLvl'},{'nanmean'},'DataVars',{'TrialsInInterval','RT','Acc','AccRT','logRT','logAccRT','RespRateAll','RespRateCorr','RespRateCorrNoISI'});
condMeansGbySubGrp = grpstats(condMeansGbySub,{'Vers','GainLvl'},{'nanmean','sem'},'DataVars',{'nanmean_TrialsInInterval','nanmean_RT','nanmean_Acc','nanmean_AccRT','nanmean_logRT','nanmean_logAccRT','nanmean_RespRateAll','nanmean_RespRateCorr'});

%% Table: Group means for each reward and gain level
% condMeansRxG = grpstats(subDataAll_Trial,{'Vers','GainLvl','RewLvl'},{'nanmean'},'DataVars',{'TrialsInInterval','InitiationRT','RT','Acc','AccRT','logRT','logAccRT','InitRateAll','RespRateAll','RespRateCorr','RespRateCorrNoISI'});
% condMeansRxGbySub = grpstats(subDataAll_Trial,{'Vers','SubID','GainLvl','RewLvl'},{'nanmean'},'DataVars',{'TrialsInInterval','InitiationRT','RT','Acc','AccRT','logRT','logAccRT','InitRateAll','RespRateAll','RespRateCorr','RespRateCorrNoISI'});
% condMeansRxGbySubGrp = grpstats(condMeansRxGbySub,{'Vers','GainLvl','RewLvl'},{'nanmean','sem'},'DataVars',{'nanmean_TrialsInInterval','nanmean_InitiationRT','nanmean_RT','nanmean_Acc','nanmean_AccRT','nanmean_logRT','nanmean_logAccRT','nanmean_RespRateAll','nanmean_RespRateCorr'});
condMeansRxG = grpstats(subDataAll_Trial,{'Vers','GainLvl','RewLvl'},{'nanmean'},'DataVars',{'TrialsInInterval','RT','Acc','AccRT','logRT','logAccRT','RespRateAll','RespRateCorr','RespRateCorrNoISI'});
condMeansRxGbySub = grpstats(subDataAll_Trial,{'Vers','SubID','GainLvl','RewLvl'},{'nanmean'},'DataVars',{'TrialsInInterval','RT','Acc','AccRT','logRT','logAccRT','RespRateAll','RespRateCorr','RespRateCorrNoISI'});
condMeansRxGbySubGrp = grpstats(condMeansRxGbySub,{'Vers','GainLvl','RewLvl'},{'nanmean','sem'},'DataVars',{'nanmean_TrialsInInterval','nanmean_RT','nanmean_Acc','nanmean_AccRT','nanmean_logRT','nanmean_logAccRT','nanmean_RespRateAll','nanmean_RespRateCorr'});

%% Table: Group means for each reward level block
% condMeansRB = grpstats(subDataAll_Trial,{'Vers','BlockTypeRlvl'},{'nanmean'},'DataVars',{'TrialsInInterval','InitiationRT','RT','Acc','AccRT','logRT','logAccRT','InitRateAll','RespRateAll','RespRateCorr','RespRateCorrNoISI'});
% condMeansRBbySub = grpstats(subDataAll_Trial,{'Vers','SubID','BlockTypeRlvl'},{'nanmean'},'DataVars',{'TrialsInInterval','InitiationRT','RT','Acc','AccRT','logRT','logAccRT','InitRateAll','RespRateAll','RespRateCorr','RespRateCorrNoISI'});
% condMeansRBbySubGrp = grpstats(condMeansRBbySub,{'Vers','BlockTypeRlvl'},{'nanmean','sem'},'DataVars',{'nanmean_TrialsInInterval','nanmean_InitiationRT','nanmean_RT','nanmean_Acc','nanmean_AccRT','nanmean_logRT','nanmean_logAccRT','nanmean_RespRateAll','nanmean_RespRateCorr'});
condMeansRB = grpstats(subDataAll_Trial,{'Vers','RewLvlBlockcode'},{'nanmean'},'DataVars',{'TrialsInInterval','RT','Acc','AccRT','logRT','logAccRT','RespRateAll','RespRateCorr','RespRateCorrNoISI'});
condMeansRBbySub = grpstats(subDataAll_Trial,{'Vers','SubID','RewLvlBlockcode'},{'nanmean'},'DataVars',{'TrialsInInterval','RT','Acc','AccRT','logRT','logAccRT','RespRateAll','RespRateCorr','RespRateCorrNoISI'});
condMeansRBbySubGrp = grpstats(condMeansRBbySub,{'Vers','RewLvlBlockcode'},{'nanmean','sem'},'DataVars',{'nanmean_TrialsInInterval','nanmean_RT','nanmean_Acc','nanmean_AccRT','nanmean_logRT','nanmean_logAccRT','nanmean_RespRateAll','nanmean_RespRateCorr'});

%% Table: Group means for each efficacy level block
% condMeansGB = grpstats(allSubData,{'Vers','BlockTypeGlvl'},{'nanmean'},'DataVars',{'TrialsInInterval','InitiationRT','RT','Acc','AccRT','logRT','logAccRT','InitRateAll','RespRateAll','RespRateCorr','RespRateCorrCORRECTED'});
% condMeansGBbySub = grpstats(allSubData,{'Vers','SubID','BlockTypeGlvl'},{'nanmean'},'DataVars',{'TrialsInInterval','InitiationRT','RT','Acc','AccRT','logRT','logAccRT','InitRateAll','RespRateAll','RespRateCorr','RespRateCorrCORRECTED'});
% condMeansGBbySubGrp = grpstats(condMeansGBbySub,{'Vers','BlockTypeGlvl'},{'nanmean','sem'},'DataVars',{'nanmean_TrialsInInterval','nanmean_InitiationRT','nanmean_RT','nanmean_Acc','nanmean_AccRT','nanmean_logRT','nanmean_logAccRT','nanmean_RespRateAll','nanmean_RespRateCorr'});
condMeansGB = grpstats(subDataAll_Trial,{'Vers','GainLvlBlockcode'},{'nanmean'},'DataVars',{'TrialsInInterval','RT','Acc','AccRT','logRT','logAccRT','RespRateAll','RespRateCorr','RespRateCorrNoISI'});
condMeansGBbySub = grpstats(subDataAll_Trial,{'Vers','SubID','GainLvlBlockcode'},{'nanmean'},'DataVars',{'TrialsInInterval','RT','Acc','AccRT','logRT','logAccRT','RespRateAll','RespRateCorr','RespRateCorrNoISI'});
condMeansGBbySubGrp = grpstats(condMeansGBbySub,{'Vers','GainLvlBlockcode'},{'nanmean','sem'},'DataVars',{'nanmean_TrialsInInterval','nanmean_RT','nanmean_Acc','nanmean_AccRT','nanmean_logRT','nanmean_logAccRT','nanmean_RespRateAll','nanmean_RespRateCorr'});

%% Table: Avg Performance by Subject
subMeansPerf = grpstats(subDataAll_Trial,{'SubID'},{'mean'},'DataVars',{'Vers','RT','Acc','AccRT','RespRateAll','RespRateCorr','RespRateCorrNoISI','Congruency'});
subMeansPerfVers = grpstats(subMeansPerf,{'mean_Vers'},{'mean'},'DataVars',{'mean_RT','mean_Acc','mean_AccRT','mean_RespRateAll','mean_RespRateCorr','mean_Congruency'});

means = grpstats(subDataAll_Trial,{'Vers','SubID','Congruency'},{'mean'},'DataVars',{'Vers','RT','Acc','AccRT','RespRateAll','RespRateCorr'});


%% Add Avg Performance data to long-form table

[subIDs,uniqueRows] = unique(subDataAll_Trial.SubID);
[scoreSubIDs,scoreUniqueRows] = unique(subMeansPerf.SubID);

allAvgPerf = [];
for sub = 1:length(subIDs)
    startRow = uniqueRows(sub);
    if sub == length(subIDs)
        endRow = height(subDataAll_Trial);
    else
        endRow = uniqueRows(sub + 1) - 1;
    end
    numReps = endRow - startRow + 1;
    
    [isMem,scoreSub] = ismember(subIDs(sub),scoreSubIDs);               % Check if subject did SRMs
    if isMem
        subAvgPerf = repmat(subMeansPerf{scoreSub,(3:end)},numReps,1);
    else
        subAvgPerf = NaN(numReps,3);                             % If subject didn't do SRMs, fill with NaNs
    end
    allAvgPerf = [allAvgPerf; subAvgPerf];
end

% Convert to table and change column names
allAvgPerf = array2table(allAvgPerf);
headers = subMeansPerf.Properties.VariableNames(3:end);
allAvgPerf.Properties.VariableNames = headers;

% Concatenate two tables
subDataAll_Trial = [subDataAll_Trial, allAvgPerf];


%% Mixed effects stats

% This is important for specifying that these should be treated as
% categorical not continuous vars (can be set up above with table creation):
% allSubData.RewLvlNum = (allSubData.RewLvl)-2.5;   % mean-centered

subDataAll_Trial.RewLvl = categorical(subDataAll_Trial.RewLvl);
subDataAll_Trial.GainLvl = categorical(subDataAll_Trial.GainLvl);

%allSubData.SubIDnum = (allSubData.SubID);
subDataAll_Trial.SubID = categorical(subDataAll_Trial.SubID);
subDataAll_Trial.Vers = categorical(subDataAll_Trial.Vers);

subDataAll_Trial.Congruency = categorical(subDataAll_Trial.Congruency);

condMeansByInt.RewLvl = categorical(condMeansByInt.mean_RewLvl);
condMeansByInt.GainLvl = categorical(condMeansByInt.mean_GainLvl);
condMeansByInt.SubID = categorical(condMeansByInt.mean_SubID);

subDataAll_Interval.RewLvl = categorical(subDataAll_Interval.RewLvl);
subDataAll_Interval.GainLvl = categorical(subDataAll_Interval.GainLvl);
subDataAll_Interval.SubID = categorical(subDataAll_Interval.SubID);


%% NOTE: DY did not edit below this section. Last Edited 02/11/20.

%% FIX THIS

% % % We want these vars to be categorical bc only a few levels, but we want
% % % to maintain their ordinal relationship in analyses:
% % % % allSubData.Block = categorical(allSubData.Block,[1,2,3,4],'Ordinal',true);
% % allSubData.IvsCcong = allSubData.Congruency;
% % allSubData.IvsCcong(allSubData.IvsCcong==2) = nan;
% % allSubData.IvsCcong = categorical(allSubData.IvsCcong);
% % allSubData.Congruency = categorical(allSubData.Congruency,[0,2,1],'Ordinal',true);



%% GLMs
if runGLMs
        curInclSubs = allSubData(allSubData.Vers=='104',:);
        %%% Check by interval length
        %%% 1/24: Block-level effect of G/L, trial-level effect of R
    
    
    % Vanilla RT linear mixed effects model:
    lmeStats_RT = fitlme(curInclSubs,...
        'RespRateCorrNoISI ~ 1+ RewLvl*GainLvl+Interval+IntervalLength+ (1 + RewLvl*GainLvl+Interval+IntervalLength|SubID) + (1+IntervalLength|Interval)',...
        'FitMethod','REML');
    % This extracts the (properly corrected) effect estimates from the regression above:
    [~,~,stats_RT] = fixedEffects(lmeStats_RT,'DFmethod','satterthwaite')
    

    lmeStats_RT = fitlme(curInclSubs,...
        'RespRateCorrNoISI ~ 1+ RewLvl+GainLvl+ (1 + RewLvl+GainLvl|SubID) + (1|Interval)',...
        'FitMethod','REML');
    % This extracts the (properly corrected) effect estimates from the regression above:
    [~,~,stats_RT] = fixedEffects(lmeStats_RT,'DFmethod','satterthwaite')
    
    % Vanilla RT linear mixed effects model:
    lmeStats_RT = fitlme(curInclSubs,...
        'logAccRT ~ 1+ RewLvl*GainLvl*Congruency+IntTrialNum+Interval+ (1 + RewLvl*GainLvl*Congruency+IntTrialNum+Interval|SubID)+ (1|Interval)',...
        'FitMethod','REML');
    % This extracts the (properly corrected) effect estimates from the regression above:
    [~,~,stats_RT] = fixedEffects(lmeStats_RT,'DFmethod','satterthwaite')

    
    
        % Vanilla accuracy LOGISTIC mixed effects model (EXCLUDING missed trials):
    % Note that we're now using FITGLME rather than FITLME
    lmeStats_acc_excMsd = fitglme(curInclSubs,...
        'Acc ~ 1 + RewLvl + GainLvl + Congruency + (1 + RewLvl + GainLvl+Congruency|SubID)',...
        'Distribution','Binomial',...
        'FitMethod','Laplace');
    % This extracts the (NOT properly corrected) effect estimates from the regression above (be wary of this p-value!):
    [~,~,stats_acc_excMsd] = fixedEffects(lmeStats_acc_excMsd,'DFmethod','residual')
    anova(lmeStats_acc_excMsd,'DFmethod','residual')

    
    
            lmeStats_RT = fitlme(curInclSubs,...
        'RespRateCorrNoISI ~ 1+ RewLvlBlockcode+GainLvl+Interval+IntervalLength+ (1 + RewLvlBlockcode+GainLvl+Interval+IntervalLength|SubID) + (1+IntervalLength|Interval)',...
        'FitMethod','REML');
    [~,~,stats_RT] = fixedEffects(lmeStats_RT,'DFmethod','satterthwaite')
    anova(lmeStats_RT,'DFmethod','satterthwaite')

        lmeStats_RT = fitlme(curInclSubs,...
        'RespRateCorrNoISI ~ 1+ GainLvlBlockcode+RewLvl+Interval+IntervalLength+ (1 + GainLvlBlockcode+RewLvl+Interval+IntervalLength|SubID) + (1+IntervalLength|Interval)',...
        'FitMethod','REML');
    [~,~,stats_RT] = fixedEffects(lmeStats_RT,'DFmethod','satterthwaite')
    anova(lmeStats_RT,'DFmethod','satterthwaite')
     

            lmeStats_RT = fitlme(curInclSubs,...
        'logAccRT ~ 1+ GainLvlBlockcode+RewLvl+Interval+Congruency+IntTrialNum+ (1 + GainLvlBlockcode+RewLvl+Interval+Congruency+IntTrialNum|SubID) + (1+IntTrialNum|Interval)',...
        'FitMethod','REML');
    [~,~,stats_RT] = fixedEffects(lmeStats_RT,'DFmethod','satterthwaite')
    anova(lmeStats_RT,'DFmethod','satterthwaite')

    
    
        % Vanilla RT linear mixed effects model:
    lmeStats_RT = fitlme(curInclSubs,...
        'RespRateCorr ~ 1+ RewLvl+GainLvl+Interval+ (1 + RewLvl+GainLvl+Interval|SubID) + (1|Interval)',...
        'FitMethod','REML');
    % This extracts the (properly corrected) effect estimates from the regression above:
    [~,~,stats_RT] = fixedEffects(lmeStats_RT,'DFmethod','satterthwaite')

    
    
    
    
    
    % Vanilla RT linear mixed effects model:
    lmeStats_RT = fitlme(allSubData,...
        'logAccRT ~ 1+ RewLvl+GainLvl +Interval+ (1 + RewLvl+GainLvl+Interval|SubID)',...
        'FitMethod','REML');
    % This extracts the (properly corrected) effect estimates from the regression above:
    [~,~,stats_RT] = fixedEffects(lmeStats_RT,'DFmethod','satterthwaite')
    
    % Vanilla RT linear mixed effects model:
    lmeStats_RT = fitlme(allSubData,...
        'InitRateAll ~ 1+ RewLvl*GainLvl+ (1 + RewLvl*GainLvl|SubID) + (1|Interval)',...
        'FitMethod','REML');
    % This extracts the (properly corrected) effect estimates from the regression above:
    [~,~,stats_RT] = fixedEffects(lmeStats_RT,'DFmethod','satterthwaite')
    
    % Vanilla RT linear mixed effects model:
    lmeStats_RT = fitlme(allSubData,...
        'RespRateCorr ~ 1+ RewLvl+GainLvl+ (1 + RewLvl+GainLvl|SubID) + (1|Interval)',...
        'FitMethod','REML');
    % This extracts the (properly corrected) effect estimates from the regression above:
    [~,~,stats_RT] = fixedEffects(lmeStats_RT,'DFmethod','satterthwaite')
    
    
    % Vanilla RT linear mixed effects model:
    lmeStats_RT = fitlme(allSubData,...
        'InitRateAll ~ 1+ RewLvl*GainLvl+IntLength+Interval+ (1 + RewLvl*GainLvl+IntLength+Interval|SubID) + (1|Interval)',...
        'FitMethod','REML');
    % This extracts the (properly corrected) effect estimates from the regression above:
    [~,~,stats_RT] = fixedEffects(lmeStats_RT,'DFmethod','satterthwaite')
    
    
    
    % Vanilla accuracy LOGISTIC mixed effects model (EXCLUDING missed trials):
    % Note that we're now using FITGLME rather than FITLME
    lmeStats_acc_excMsd = fitglme(allSubData,...
        'Acc ~ 1 + RewLvl + GainLvl + Congruency + (1 + RewLvl + GainLvl+Congruency|SubID)',...
        'Distribution','Binomial',...
        'FitMethod','Laplace');
    % This extracts the (NOT properly corrected) effect estimates from the regression above (be wary of this p-value!):
    [~,~,stats_acc_excMsd] = fixedEffects(lmeStats_acc_excMsd,'DFmethod','residual')
    anova(lmeStats_acc_excMsd,'DFmethod','residual')
    
    
    
    
    % Vanilla RT linear mixed effects model:
    lmeStats_RT = fitlme(condMeansByInt,...
        'mean_InitRateAll ~ 1+ RewLvl*GainLvl+Interval+ (1 + RewLvl*GainLvl+Interval|SubID)',...
        'FitMethod','REML');
    % This extracts the (properly corrected) effect estimates from the regression above:
    [~,~,stats_RT] = fixedEffects(lmeStats_RT,'DFmethod','satterthwaite')
    
    
    
    
    
    % Vanilla RT linear mixed effects model:
    lmeStats_RT = fitlme(subDataAll_Interval,...
        'InitRateAll ~ 1+ RewLvl+GainLvl+Interval+ (1 + RewLvl+GainLvl+Interval|SubID)+(1|Interval)',...
        'FitMethod','REML');
    % This extracts the (properly corrected) effect estimates from the regression above:
    [~,~,stats_RT] = fixedEffects(lmeStats_RT,'DFmethod','satterthwaite')
    
    
    %%
    % Vanilla RT linear mixed effects model (EXCLUDING missed trials):
    lmeStats_RT_excMsd = fitlme(allSubData,...
        'RT ~ 1+ RewLvl + GainLvl + (1 + RewLvl + GainLvl|SubID)',...
        'Exclude',find(allSubData.IsMiss=='1'),...
        'FitMethod','REML');
    % This extracts the (properly corrected) effect estimates from the regression above:
    [~,~,stats_RT_excMsdT] = fixedEffects(lmeStats_RT_excMsd,'DFmethod','satterthwaite')
    
    
    curExcl = allSubData.IsMiss=='0' & allSubData.mean_IsRewarded>0.5;
    
    % Vanilla accRT linear mixed effects model (EXCLUDING missed trials):
    lmeStats_CorrRT_excMsd = fitlme(allSubData(curExcl,:),...
        'AccRT ~ 1+ RewLvl*GainLvl + (1 + RewLvl*GainLvl|SubID)',...
        'FitMethod','REML');
    % This extracts the (properly corrected) effect estimates from the regression above:
    [~,~,stats_CorrRT_excMsd] = fixedEffects(lmeStats_CorrRT_excMsd,'DFmethod','satterthwaite')
    
    
    % Vanilla accuracy LOGISTIC mixed effects model (EXCLUDING missed trials):
    % Note that we're now using FITGLME rather than FITLME
    lmeStats_acc_excMsd = fitglme(allSubData,...
        'Acc ~ 1 + RewLvl + GainLvl + Congruency + (1 + RewLvl + GainLvl+Congruency|SubID)',...
        'Exclude',find(allSubData.IsMiss=='1'),...
        'Distribution','Binomial',...
        'FitMethod','Laplace');
    % This extracts the (NOT properly corrected) effect estimates from the regression above (be wary of this p-value!):
    [~,~,stats_acc_excMsd] = fixedEffects(lmeStats_acc_excMsd,'DFmethod','residual')
    anova(lmeStats_acc_excMsd,'DFmethod','residual')
    
    
    
    curExcl =  allSubData.IsMiss=='0' & allSubData.mean_IsRewarded>0.6 & allSubData.mean_Acc>0.6;
    
    % Vanilla accRT linear mixed effects model (EXCLUDING missed trials) + SRM:
    % DASS corr w/ RewLvl; GSE corr w/ GainLvl; DASS/GSE faster overall for all trials
    lmeStats_CorrRT_excMsd = fitlme(allSubData(curExcl,:),...
        'AccRT ~ 1+ RewLvl*zDASS_Score + GainLvl*zGSE_Score + Congruency+(1 + RewLvl + GainLvl+Congruency|SubID)',...
        'FitMethod','REML');
    % This extracts the (properly corrected) effect estimates from the regression above:
    [~,~,stats_CorrRT_excMsd] = fixedEffects(lmeStats_CorrRT_excMsd,'DFmethod','satterthwaite')
    
    
end



%% MISC CODE

%         % Remnant from OA script 
%         if subID<5003 || (subID>5003 && subID<6000)
%             for trialNum = 1:length(curInitiationTime)
%                 %%%% Reconcile w/ OA:
%                 %                  curRT(trialNum) = curRT(trialNum)-curInitiationTime((trialNum));
%                 if trialNum>1 && (curIntNum(trialNum-1)==curIntNum(trialNum))   % mid-int
%                     curInitiationTime(trialNum) = curInitiationTime(trialNum)-data.raw(x).results.responseTime((trialNum-1));
%                 else % int start
%                     curInitiationTime(trialNum) = curInitiationTime(trialNum)-data.raw(x).results.timing.intervalStart(curIntNum(trialNum));
%                 end
%             end
%         end
        
%         % Iterate over intervals
%         curBlockNum = [];
%         curIntNum = [];
%         curIntLength = [];
%         curTrialsCompleted = [];
%         curNumTrialsInIntverval = [];
%         curIntLengthSecs = [];
%         curRewLvl = [];
%         curGainLvl = [];
%         curTrialNuminInt = [];
%         curIntLengthSecNoISI = [];
%         curBlockType = {};
%         
%         curIntBasedIntNum = [];
%         curIntBasedLengthSecs = [];
%         for intNum = 1:numIntervalsTotal
%             thisIntLengthSec = data.raw(x).results.timing.intervalEnd(intNum)-data.raw(x).results.timing.intervalStart(intNum); 
%             curBlockNum = [curBlockNum, repmat((ceil(intNum/numIntervalsPerBlock)), 1, numTrialsPerInterval(intNum))];
%             curIntNum = [curIntNum, repmat(intNum, 1, numTrialsPerInterval(intNum))];
%             curIntLength = [curIntLength, repmat(data.raw(x).p.intervalLength(intNum), 1, numTrialsPerInterval(intNum))];
%             curTrialNuminInt = [clurTriaNuminInt,1:numTrialsPerInterval(intNum)];
%             curTrialsCompleted = [curTrialsCompleted, repmat(trialsCompletedPerInterval(intNum), 1, numTrialsPerInterval(intNum))];
%             curRewLvl = [curRewLvl, repmat(rewLvl(intNum), 1, numTrialsPerInterval(intNum))];
%             curGainLvl = [curGainLvl, repmat(gainLvl(intNum), 1, numTrialsPerInterval(intNum))];
%             
%             curIntLengthSecs = [curIntLengthSecs, repmat(thisIntLengthSec, 1, numTrialsPerInterval(intNum))];
%             curIntBasedLengthSecs(intNum) = thisIntLengthSec;
%             curIntBasedIntNum(intNum) = intNum;
%             curIntLengthSecNoISI = [curIntLengthSecNoISI, repmat((thisIntLengthSec - ((trialsCompletedPerInterval(intNum) - 1) * data.raw(x).p.timing.isi)), 1, numTrialsPerInterval(intNum))];
%              
%             temp = cell(1,(numTrialsPerInterval(intNum)));
%             try
%                 temp(:) = {data.raw(x).p.blockOrder{ceil(intNum/numIntervalsPerBlock)}};
%                 curBlockType = [curBlockType, temp];
%             catch
%                 curBlockType = [curBlockType, temp];
%             end
%         end


%         % Creating an interval array
%         curNumRespondedTrialsInInterval = [];
%         %curNumInitiatedTrialsInInterval = []; this variable not used
%         curNumCorrectTrialsInInterval = [];
%         %curCumulTimeInInterval = []; % this variable not used
%         
%         curIntBasedRespondedTrials = [];
%         curIntBasedInitiatedTrials = [];
%         curIntBasedCorrectTrials = [];
%         
%         for intNum = 1:numIntervalsTotal
%             thisIntRespondedTrials = sum(~isnan(curRT(curIntNum==intNum)));
%             %thisIntInitiatedTrials = sum((curInitiationTime(curIntNum==intNum)>0));
%             thisIntCorrectTrials = sum(curAcc(curIntNum==intNum));
%             % %  thisIntCumulTime = nansum((curRT(curIntNum==intNum)))+nansum((curInitiationTime(curIntNum==intNum)));
%             
%             curNumRespondedTrialsInInterval = [curNumRespondedTrialsInInterval, repmat(thisIntRespondedTrials, 1, numTrialsPerInterval(intNum))];
%             curNumInitiatedTrialsInInterval = [curNumInitiatedTrialsInInterval, repmat(thisIntInitiatedTrials, 1, numTrialsPerInterval(intNum))];
%             curNumCorrectTrialsInInterval = [curNumCorrectTrialsInInterval, repmat(thisIntCorrectTrials, 1, numTrialsPerInterval(intNum))];
%             
%             % RT test
%             % %  curCumulTimeInIntverval = [curCumulTimeInIntverval, repmat(thisIntCumulTime, 1, numTrialsPerInt(intNum))];
%             
%             curIntBasedRespondedTrials(intNum) = thisIntRespondedTrials;
%             curIntBasedInitiatedTrials(intNum) = thisIntInitiatedTrials;
%             curIntBasedCorrectTrials(intNum) = thisIntCorrectTrials;
%             
%         end


%         
%         curSubData = [curSubID',...
%             curVersion',...
%             curBlockNum'...
%             curBlockTypeNum',...
%             curIntNum',...
%             curIntLength',...
%             curTrialsCompleted',...
%             curRewLvl',...
%             curGainLvl',...
%             curStimCongruency',...
%             curInitiationTime',...
%             curRT',...
%             curCorrectResp',...
%             curResp',...
%             curAcc',...
%             curIntRespRateAll',...
%             curIntRespRateCorr',...
%             curIntLengthSecs',...
%             curTrialNuminInt',...
%             curIsComplete'...
%             curSubBlockTypeRewLvl',...
%             curSubBlockTypeGainLvl',...
%             curIntLengthSecsNoISI',...
%             curIntRespRateCorrNoISI'...
%             ];
%             %curIntInitRateAll',...
 

%         curSubDataInt = [curIntSubID',...
%             rewLvl(1:numIntervalsTotal)',...
%             gainLvl(1:numIntervalsTotal)'...
%             curIntBasedIntNum',...
%             curIntBasedInitRateAll',...
%             curIntBasedRespRateAll',...
%             curIntBasedRespRateCorr',...
%             curIntBasedLengthSecs',...
%             ];




%% Add Performance Variables
% allSubData.Acc(isnan(allSubData.Resp)) = nan;
% allSubData.AccRT = allSubData.Acc .* allSubData.RT;
% allSubData.AccRT(allSubData.Acc==0) = nan;
% allSubData.logRT = log(allSubData.RT);
% allSubData.logAccRT = log(allSubData.AccRT);
% allSubData.RespRateAll(isnan(allSubData.RT)) = nan;

% allSubData.BlockTypeRlvl = categorical(allSubData.BlockTypeRlvl,'Ordinal',true);
% allSubData.BlockTypeGlvl = categorical(allSubData.BlockTypeGlvl,'Ordinal',true);

% check1 = grpstats(allSubData(allSubData.IsComplete == 1,:),{'IntervalLength','GainLvl'},{'mean'},'DataVars',{'RT','Acc','AccRT','RespRateAll','RespRateCorr'});
% check2 = grpstats(allSubData(allSubData.IsComplete == 1,:),{'IntervalLength','RewLvl'},{'mean'},'DataVars',{'RT','Acc','AccRT','RespRateAll','RespRateCorr'});
% check3 = grpstats(allSubData(allSubData.IsComplete == 1,:),{'IntervalLength','RewLvl','GainLvl'},{'mean'},'DataVars',{'RT','Acc','AccRT','RespRateAll','RespRateCorr'});


%% Table: Long-form data
% % Assuming congruency is 3-level (incong =0, cong=1, neutral=2):
% allSubHdr = {'SubID','Vers','BlockNum', 'BlockType', 'IntervalNum','IntervalLength','TrialsInInterval',...
%     'RewLvl', 'GainLvl','Congruency','InitiationRT','RT','CorrectResp','Resp','Acc',...
%     'RespRateAll','RespRateCorr','IntLength','IntTrialNum','IsComplete',...
%     'BlockTypeRlvl','BlockTypeGlvl','IntLengthCORRECTED','RespRateCorrCORRECTED'};
% allSubHdr = {'SubID','Vers','BlockNum', 'BlockType', 'IntervalNum','IntervalLength','TrialsInInterval',...
%     'RewLvl', 'GainLvl','Congruency','InitiationRT','RT','CorrectResp','Resp','Acc','InitRateAll',...
%     'RespRateAll','RespRateCorr','IntLength','IntTrialNum','IsComplete',...
%     'BlockTypeRlvl','BlockTypeGlvl','IntLengthCORRECTED','RespRateCorrCORRECTED'};

% allSubHdr = {'SubID','Vers','Block', 'Interval','Trial','TrialCumRewLvl',...
%     'IntervalRewLvl', 'IntervalCumRew', 'TargetResp','Resp','RT','Acc','Fast','AccRT',...
%     'IsRewarded','IsMiss','runavgRRgen','runavgRRcond','ZRT','AccZRT'};
% allSubData = array2table(data.all);
% allSubData.Properties.VariableNames = allSubHdr;
% 
% allSubHdrIntBased = {'SubID','RewLvl', 'GainLvl','Interval','RespRateAll','RespRateCorr','IntLength'};
% allSubDataIntBased = array2table(data.allIntBased);
% allSubDataIntBased.Properties.VariableNames = allSubHdrIntBased;

%data.all = [];
%data.allIntBased = [];
%data.all = [data.all; curSubData];
%data.allIntBased = [data.allIntBased; curSubDataInt];

