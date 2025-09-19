clear;
runGLMs = 0;

% chdir('~/Dropbox (Brown)/ShenhavLab/Experiments/TSS/Analysis');

% isOAsubject = 1

%% Load in data files
files = dir('../Results/TSS_1*mat');
fileNames = {files(:).name};

for x = 1:length(fileNames)
    file = ['../Results/', fileNames{x}];
    data.raw(x) = load(file);
end

data.all = [];
data.allIntBased = [];
for x = 1:length(fileNames)
    try
        subID = str2num(data.raw(x).p.subID);
        version = data.raw(x).p.version;
        
        numIntervalsPerBlock = data.raw(x).p.numIntervalsPerBlock;
        numIntervalsTotal = length(data.raw(x).results.TrialsResponded);
        numTrialsPerInt = data.raw(x).results.TrialsResponded;
        numTrialsTotal = sum(data.raw(x).results.TrialsResponded);
        
        curSubID = subID*ones(1,numTrialsTotal);
        curVersion = version*ones(1,numTrialsTotal);
        
        stimCongruency = [data.raw(x).p.stimuli(:).IsCongruent];
        curCongruency = stimCongruency(1:numTrialsTotal);
        correctResp = [data.raw(x).p.stimuli(:).ColorAns];
        curCorrectResp = correctResp(1:numTrialsTotal);
        trialsCompleted = data.raw(x).results.TrialsResponded;
        
        rewLvl = data.raw(x).p.intervalRewLvl;
        gainLvl = data.raw(x).p.intervalIsGain;
        curInitiationTime = data.raw(x).results.initiationTime;
        curResp = data.raw(x).results.resp;
        try
            curRT = data.raw(x).results.newResponseTime;
        catch
            %%%% Reconcile w/ OA:
            curRT = data.raw(x).results.responseTime;
        end
        % % %         curAcc = data.raw(x).results.acc; %%% CDW: is this correct
        curTooFast = data.raw(x).results.tooFast;
        curAcc = curCorrectResp==curResp;
        
        curBlockNum = [];
        curIntNum = [];
        curIntLength = [];
        curTrialsCompleted = [];
        curNumTrialsInIntverval = [];
        curIntLengthSecs = [];
        curRewLvl = [];
        curGainLvl = [];
        curTrialNuminInt = [];
        curCorrectedIntLength = [];
        curBlockType = {};
        
        curIntBasedIntNum = [];
        curIntBasedLengthSecs = [];
        for intNum = 1:numIntervalsTotal
            thisIntLengthSecs = data.raw(x).results.timing.intervalEnd(intNum)-data.raw(x).results.timing.intervalStart(intNum);
            curBlockNum = [curBlockNum, repmat((ceil(intNum/numIntervalsPerBlock)), 1, numTrialsPerInt(intNum))];
            curIntNum = [curIntNum, repmat(intNum, 1, numTrialsPerInt(intNum))];
            curIntLength = [curIntLength, repmat(data.raw(x).p.intervalLength(intNum), 1, numTrialsPerInt(intNum))];
            curTrialNuminInt = [curTrialNuminInt,1:numTrialsPerInt(intNum)];
            curTrialsCompleted = [curTrialsCompleted, repmat(trialsCompleted(intNum), 1, numTrialsPerInt(intNum))];
            curRewLvl = [curRewLvl, repmat(rewLvl(intNum), 1, numTrialsPerInt(intNum))];
            curGainLvl = [curGainLvl, repmat(gainLvl(intNum), 1, numTrialsPerInt(intNum))];
            curIntLengthSecs = [curIntLengthSecs, repmat(thisIntLengthSecs, 1, numTrialsPerInt(intNum))];
            curIntBasedLengthSecs(intNum) = thisIntLengthSecs;
            curIntBasedIntNum(intNum) = intNum;
            
            curCorrectedIntLength = [curCorrectedIntLength, repmat((thisIntLengthSecs - ((trialsCompleted(intNum) - 1) * data.raw(x).p.timing.isi)), 1, numTrialsPerInt(intNum))];
             
            temp = cell(1,(numTrialsPerInt(intNum)));
            try
                temp(:) = {data.raw(x).p.blockOrder{ceil(intNum/numIntervalsPerBlock)}};
                curBlockType = [curBlockType, temp];
            catch
                curBlockType = [curBlockType, temp];
            end
        end
        
        
        curBlockTypeNum = nan(1,length(curBlockType));
        curBlockTypeNum(strcmp(curBlockType,'highRew')) = 20;
        curBlockTypeNum(strcmp(curBlockType,'lowRew')) = 10;
        curBlockTypeNum(strcmp(curBlockType,'gain')) = 2;
        curBlockTypeNum(strcmp(curBlockType,'loss')) = 1;
        curSubBlockTypeRewLvl = (curBlockTypeNum==20) - (curBlockTypeNum==10);
        curSubBlockTypeGainLvl = (curBlockTypeNum==2) - (curBlockTypeNum==1);
        
        
        isComplete = numIntervalsTotal == data.raw(x).p.numIntervals;
        curIsComplete = repmat(isComplete, 1, length(curBlockNum));
        
        curIntSubID = subID*ones(1,numIntervalsTotal);
        
        if subID<5003 || (subID>5003 & subID<6000)
            for trialNum = 1:length(curInitiationTime)
                %%%% Reconcile w/ OA:
                %                  curRT(trialNum) = curRT(trialNum)-curInitiationTime((trialNum));
                if trialNum>1 && (curIntNum(trialNum-1)==curIntNum(trialNum))   % mid-int
                    curInitiationTime(trialNum) = curInitiationTime(trialNum)-data.raw(x).results.responseTime((trialNum-1));
                else % int start
                    curInitiationTime(trialNum) = curInitiationTime(trialNum)-data.raw(x).results.timing.intervalStart(curIntNum(trialNum));
                end
            end
        end
        
        curNumRespondedTrialsInIntverval = [];
        curNumInitiatedTrialsInIntverval = [];
        curNumCorrectTrialsInIntverval = [];
        curCumulTimeInIntverval = [];
        
        curIntBasedRespondedTrials = [];
        curIntBasedInitiatedTrials = [];
        curIntBasedCorrectTrials = [];
        
        for intNum = 1:numIntervalsTotal
            thisIntRespondedTrials = sum(~isnan(curRT(curIntNum==intNum)));
            thisIntInitiatedTrials = sum((curInitiationTime(curIntNum==intNum)>0));
            thisIntCorrectTrials = sum(curAcc(curIntNum==intNum));
            % %             thisIntCumulTime = nansum((curRT(curIntNum==intNum)))+nansum((curInitiationTime(curIntNum==intNum)));
            
            curNumRespondedTrialsInIntverval = [curNumRespondedTrialsInIntverval, repmat(thisIntRespondedTrials, 1, numTrialsPerInt(intNum))];
            curNumInitiatedTrialsInIntverval = [curNumInitiatedTrialsInIntverval, repmat(thisIntInitiatedTrials, 1, numTrialsPerInt(intNum))];
            curNumCorrectTrialsInIntverval = [curNumCorrectTrialsInIntverval, repmat(thisIntCorrectTrials, 1, numTrialsPerInt(intNum))];
            
            % RT test
            % %             curCumulTimeInIntverval = [curCumulTimeInIntverval, repmat(thisIntCumulTime, 1, numTrialsPerInt(intNum))];
            
            curIntBasedRespondedTrials(intNum) = thisIntRespondedTrials;
            curIntBasedInitiatedTrials(intNum) = thisIntInitiatedTrials;
            curIntBasedCorrectTrials(intNum) = thisIntCorrectTrials;
            
        end
        
        curIntRespRateAll = curNumRespondedTrialsInIntverval./curIntLengthSecs;
        curIntInitRateAll = curNumInitiatedTrialsInIntverval./curIntLengthSecs;
        curIntRespRateCorr = curNumCorrectTrialsInIntverval./curIntLengthSecs;
        curCorrectedIntRespRateCorr = curNumCorrectTrialsInIntverval./curCorrectedIntLength;
        
        curIntBasedRespRateAll = curIntBasedRespondedTrials./curIntBasedLengthSecs;
        curIntBasedInitRateAll = curIntBasedInitiatedTrials./curIntBasedLengthSecs;
        curIntBasedRespRateCorr = curIntBasedCorrectTrials./curIntBasedLengthSecs;
        
        % Testing RTs:
        % %         curIntPctInterval = curCumulTimeInIntverval./curIntLengthSecs;
        
        
        curSubData = [curSubID',...
            curVersion',...
            curBlockNum'...
            curBlockTypeNum',...
            curIntNum',...
            curIntLength',...
            curTrialsCompleted',...
            curRewLvl',...
            curGainLvl',...
            curCongruency',...
            curInitiationTime',...
            curRT',...
            curCorrectResp',...
            curResp',...
            curAcc',...
            curIntInitRateAll',...
            curIntRespRateAll',...
            curIntRespRateCorr',...
            curIntLengthSecs',...
            curTrialNuminInt',...
            curIsComplete'...
            curSubBlockTypeRewLvl',...
            curSubBlockTypeGainLvl',...
            curCorrectedIntLength',...
            curCorrectedIntRespRateCorr'...
            ];
        
        
        
        curSubDataInt = [curIntSubID',...
            rewLvl(1:numIntervalsTotal)',...
            gainLvl(1:numIntervalsTotal)'...
            curIntBasedIntNum',...
            curIntBasedInitRateAll',...
            curIntBasedRespRateAll',...
            curIntBasedRespRateCorr',...
            curIntBasedLengthSecs',...
            ];
        
        
        data.all = [data.all; curSubData];
        data.allIntBased = [data.allIntBased; curSubDataInt];
        
    catch me
        sca
        keyboard
    end
end


%% Table: Long-form data
% Assuming congruency is 3-level (incong =0, cong=1, neutral=2):
allSubHdr = {'SubID','Vers','Block', 'BlockType', 'Interval','IntervalLength','TrialsInInterval',...
    'RewLvl', 'GainLvl','Congruency','InitiationRT','RT','CorrectResp','Resp','Acc','InitRateAll',...
    'RespRateAll','RespRateCorr','IntLength','IntTrialNum','IsComplete',...
    'BlockTypeRlvl','BlockTypeGlvl','IntLengthCORRECTED','RespRateCorrCORRECTED'};

% allSubHdr = {'SubID','Vers','Block', 'Interval','Trial','TrialCumRewLvl',...
%     'IntervalRewLvl', 'IntervalCumRew', 'TargetResp','Resp','RT','Acc','Fast','AccRT',...
%     'IsRewarded','IsMiss','runavgRRgen','runavgRRcond','ZRT','AccZRT'};
allSubData = array2table(data.all);
allSubData.Properties.VariableNames = allSubHdr;


allSubHdrIntBased = {'SubID','RewLvl', 'GainLvl','Interval','InitRateAll','RespRateAll','RespRateCorr','IntLength'};
allSubDataIntBased = array2table(data.allIntBased);
allSubDataIntBased.Properties.VariableNames = allSubHdrIntBased;




%%%% Done loading data %%%%


%% Add Perfromance Variables
allSubData.Acc(isnan(allSubData.Resp)) = nan;
allSubData.AccRT = allSubData.Acc .* allSubData.RT;
allSubData.AccRT(allSubData.Acc==0) = nan;
allSubData.logRT = log(allSubData.RT);
allSubData.logAccRT = log(allSubData.AccRT);
allSubData.RespRateAll(isnan(allSubData.RT)) = nan;

allSubData.BlockTypeRlvl = categorical(allSubData.BlockTypeRlvl,'Ordinal',true);
allSubData.BlockTypeGlvl = categorical(allSubData.BlockTypeGlvl,'Ordinal',true);

check1 = grpstats(allSubData(allSubData.IsComplete == 1,:),{'IntervalLength','GainLvl'},{'mean'},'DataVars',{'RT','Acc','AccRT','RespRateAll','RespRateCorr'});
check2 = grpstats(allSubData(allSubData.IsComplete == 1,:),{'IntervalLength','RewLvl'},{'mean'},'DataVars',{'RT','Acc','AccRT','RespRateAll','RespRateCorr'});
check3 = grpstats(allSubData(allSubData.IsComplete == 1,:),{'IntervalLength','RewLvl','GainLvl'},{'mean'},'DataVars',{'RT','Acc','AccRT','RespRateAll','RespRateCorr'});




%% Table: Subject means for each condition
condMeansByInt = grpstats(allSubData,{'Vers','SubID','Interval'},{'mean'},'DataVars',{'SubID','GainLvl','RewLvl','Congruency','TrialsInInterval','InitiationRT','RT','Acc','AccRT','logRT','logAccRT','InitRateAll','RespRateAll','RespRateCorr'});

%% Table: Group means for each reward level
condMeansR = grpstats(allSubData,{'Vers','RewLvl'},{'nanmean'},'DataVars',{'TrialsInInterval','InitiationRT','RT','Acc','AccRT','logRT','logAccRT','InitRateAll','RespRateAll','RespRateCorr','RespRateCorrCORRECTED'});
condMeansRbySub = grpstats(allSubData,{'Vers','SubID','RewLvl'},{'nanmean'},'DataVars',{'TrialsInInterval','InitiationRT','RT','Acc','AccRT','logRT','logAccRT','InitRateAll','RespRateAll','RespRateCorr','RespRateCorrCORRECTED'});
condMeansRbySubGrp = grpstats(condMeansRbySub,{'Vers','RewLvl'},{'nanmean','sem'},'DataVars',{'nanmean_TrialsInInterval','nanmean_InitiationRT','nanmean_RT','nanmean_Acc','nanmean_AccRT','nanmean_logRT','nanmean_logAccRT','nanmean_RespRateAll','nanmean_RespRateCorr'});

condMeansRbyBlock = grpstats(allSubData,{'Vers','Block','RewLvl'},{'nanmean'},'DataVars',{'TrialsInInterval','InitiationRT','RT','Acc','AccRT','logRT','logAccRT','InitRateAll','RespRateAll','RespRateCorr','RespRateCorrCORRECTED'});
condMeansRbySubbyBlock = grpstats(allSubData,{'Vers','SubID','Block','RewLvl'},{'nanmean'},'DataVars',{'TrialsInInterval','InitiationRT','RT','Acc','AccRT','logRT','logAccRT','InitRateAll','RespRateAll','RespRateCorr','RespRateCorrCORRECTED'});

%% Table: Group means for each gain level
condMeansG = grpstats(allSubData,{'Vers','GainLvl'},{'nanmean'},'DataVars',{'TrialsInInterval','InitiationRT','RT','Acc','AccRT','logRT','logAccRT','InitRateAll','RespRateAll','RespRateCorr','RespRateCorrCORRECTED'});
condMeansGbySub = grpstats(allSubData,{'Vers','SubID','GainLvl'},{'nanmean'},'DataVars',{'TrialsInInterval','InitiationRT','RT','Acc','AccRT','logRT','logAccRT','InitRateAll','RespRateAll','RespRateCorr','RespRateCorrCORRECTED'});
condMeansGbySubGrp = grpstats(condMeansGbySub,{'Vers','GainLvl'},{'nanmean','sem'},'DataVars',{'nanmean_TrialsInInterval','nanmean_InitiationRT','nanmean_RT','nanmean_Acc','nanmean_AccRT','nanmean_logRT','nanmean_logAccRT','nanmean_RespRateAll','nanmean_RespRateCorr'});

%% Table: Group means for each reward and gain level

condMeansRxG = grpstats(allSubData,{'Vers','GainLvl','RewLvl'},{'nanmean'},'DataVars',{'TrialsInInterval','InitiationRT','RT','Acc','AccRT','logRT','logAccRT','InitRateAll','RespRateAll','RespRateCorr','RespRateCorrCORRECTED'});
condMeansRxGbySub = grpstats(allSubData,{'Vers','SubID','GainLvl','RewLvl'},{'nanmean'},'DataVars',{'TrialsInInterval','InitiationRT','RT','Acc','AccRT','logRT','logAccRT','InitRateAll','RespRateAll','RespRateCorr','RespRateCorrCORRECTED'});
condMeansRxGbySubGrp = grpstats(condMeansRxGbySub,{'Vers','GainLvl','RewLvl'},{'nanmean','sem'},'DataVars',{'nanmean_TrialsInInterval','nanmean_InitiationRT','nanmean_RT','nanmean_Acc','nanmean_AccRT','nanmean_logRT','nanmean_logAccRT','nanmean_RespRateAll','nanmean_RespRateCorr'});

%% Table: Group means for each reward level block
condMeansRB = grpstats(allSubData,{'Vers','BlockTypeRlvl'},{'nanmean'},'DataVars',{'TrialsInInterval','InitiationRT','RT','Acc','AccRT','logRT','logAccRT','InitRateAll','RespRateAll','RespRateCorr','RespRateCorrCORRECTED'});
condMeansRBbySub = grpstats(allSubData,{'Vers','SubID','BlockTypeRlvl'},{'nanmean'},'DataVars',{'TrialsInInterval','InitiationRT','RT','Acc','AccRT','logRT','logAccRT','InitRateAll','RespRateAll','RespRateCorr','RespRateCorrCORRECTED'});
condMeansRBbySubGrp = grpstats(condMeansRBbySub,{'Vers','BlockTypeRlvl'},{'nanmean','sem'},'DataVars',{'nanmean_TrialsInInterval','nanmean_InitiationRT','nanmean_RT','nanmean_Acc','nanmean_AccRT','nanmean_logRT','nanmean_logAccRT','nanmean_RespRateAll','nanmean_RespRateCorr'});

%% Table: Group means for each efficacy level block
condMeansGB = grpstats(allSubData,{'Vers','BlockTypeGlvl'},{'nanmean'},'DataVars',{'TrialsInInterval','InitiationRT','RT','Acc','AccRT','logRT','logAccRT','InitRateAll','RespRateAll','RespRateCorr','RespRateCorrCORRECTED'});
condMeansGBbySub = grpstats(allSubData,{'Vers','SubID','BlockTypeGlvl'},{'nanmean'},'DataVars',{'TrialsInInterval','InitiationRT','RT','Acc','AccRT','logRT','logAccRT','InitRateAll','RespRateAll','RespRateCorr','RespRateCorrCORRECTED'});
condMeansGBbySubGrp = grpstats(condMeansGBbySub,{'Vers','BlockTypeGlvl'},{'nanmean','sem'},'DataVars',{'nanmean_TrialsInInterval','nanmean_InitiationRT','nanmean_RT','nanmean_Acc','nanmean_AccRT','nanmean_logRT','nanmean_logAccRT','nanmean_RespRateAll','nanmean_RespRateCorr'});







%% Table: Avg performance by subject
subMeansPerf = grpstats(allSubData,{'SubID'},{'mean'},'DataVars',{'Vers','RT','Acc','AccRT','RespRateAll','RespRateCorr','RespRateCorrCORRECTED','Congruency'});
subMeansPerfVers = grpstats(subMeansPerf,{'mean_Vers'},{'mean'},'DataVars',{'mean_RT','mean_Acc','mean_AccRT','mean_RespRateAll','mean_RespRateCorr','mean_Congruency'});


means = grpstats(allSubData,{'Vers','SubID','Congruency'},{'mean'},'DataVars',{'Vers','RT','Acc','AccRT','RespRateAll','RespRateCorr'});


%% Add Avg Perfromance data to long-form table

[subIDs,uniqueRows] = unique(allSubData.SubID);
[scoreSubIDs,scoreUniqueRows] = unique(subMeansPerf.SubID);

allAvgPerf = [];
for sub = 1:length(subIDs)
    startRow = uniqueRows(sub);
    if sub == length(subIDs)
        endRow = height(allSubData);
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
allSubData = [allSubData, allAvgPerf];



%% Mixed effects stats

% This is important for specifying that these should be treated as
% categorical not continuous vars (can be set up above with table creation):
% allSubData.RewLvlNum = (allSubData.RewLvl)-2.5;   % mean-centered

allSubData.RewLvl = categorical(allSubData.RewLvl);
allSubData.GainLvl = categorical(allSubData.GainLvl);

allSubData.SubIDnum = (allSubData.SubID);
allSubData.SubID = categorical(allSubData.SubID);
allSubData.Vers = categorical(allSubData.Vers);


allSubData.Congruency = categorical(allSubData.Congruency);

condMeansByInt.RewLvl = categorical(condMeansByInt.mean_RewLvl);
condMeansByInt.GainLvl = categorical(condMeansByInt.mean_GainLvl);
condMeansByInt.SubID = categorical(condMeansByInt.mean_SubID);

allSubDataIntBased.RewLvl = categorical(allSubDataIntBased.RewLvl);
allSubDataIntBased.GainLvl = categorical(allSubDataIntBased.GainLvl);
allSubDataIntBased.SubID = categorical(allSubDataIntBased.SubID);





%% FIX THIS

% % % We want these vars to be categorical bc only a few levels, but we want
% % % to maintain their ordinal relationship in analyses:
% % % % allSubData.Block = categorical(allSubData.Block,[1,2,3,4],'Ordinal',true);
% % allSubData.IvsCcong = allSubData.Congruency;
% % allSubData.IvsCcong(allSubData.IvsCcong==2) = nan;
% % allSubData.IvsCcong = categorical(allSubData.IvsCcong);
% % allSubData.Congruency = categorical(allSubData.Congruency,[0,2,1],'Ordinal',true);
% %


%% GLMs
if runGLMs
        curInclSubs = allSubData(allSubData.Vers=='103',:);
        %%% Check by interval length
        %%% 1/24: Block-level effect of G/L, trial-level effect of R
    
    
    % Vanilla RT linear mixed effects model:
    lmeStats_RT = fitlme(curInclSubs,...
        'RespRateCorrCORRECTED ~ 1+ RewLvl+GainLvl+Interval+IntervalLength+ (1 + RewLvl+GainLvl+Interval+IntervalLength|SubID) + (1+IntervalLength|Interval)',...
        'FitMethod','REML');
    % This extracts the (properly corrected) effect estimates from the regression above:
    [~,~,stats_RT] = fixedEffects(lmeStats_RT,'DFmethod','satterthwaite')
    
    
    % Vanilla RT linear mixed effects model:
    lmeStats_RT = fitlme(curInclSubs,...
        'logAccRT ~ 1+ RewLvl+GainLvl+IntTrialNum+Interval+Congruency+ (1 + RewLvl+GainLvl+IntTrialNum+Interval+Congruency|SubID)+ (1|Interval)',...
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
        'RespRateCorrCORRECTED ~ 1+ BlockTypeRlvl+GainLvl+Interval+IntervalLength+ (1 + BlockTypeRlvl+GainLvl+Interval+IntervalLength|SubID) + (1+IntervalLength|Interval)',...
        'FitMethod','REML');
    [~,~,stats_RT] = fixedEffects(lmeStats_RT,'DFmethod','satterthwaite')
    anova(lmeStats_RT,'DFmethod','satterthwaite')

        lmeStats_RT = fitlme(curInclSubs,...
        'RespRateCorrCORRECTED ~ 1+ BlockTypeGlvl+RewLvl+Interval+IntervalLength+ (1 + BlockTypeGlvl+RewLvl+Interval+IntervalLength|SubID) + (1+IntervalLength|Interval)',...
        'FitMethod','REML');
    [~,~,stats_RT] = fixedEffects(lmeStats_RT,'DFmethod','satterthwaite')
    anova(lmeStats_RT,'DFmethod','satterthwaite')
     

            lmeStats_RT = fitlme(curInclSubs,...
        'logAccRT ~ 1+ BlockTypeGlvl+RewLvl+Interval+Congruency+IntTrialNum+ (1 + BlockTypeGlvl+RewLvl+Interval+Congruency+IntTrialNum|SubID) + (1+IntTrialNum|Interval)',...
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
    lmeStats_RT = fitlme(allSubDataIntBased,...
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







