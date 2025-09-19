function [p,practice,results] = trial(p,practice,results)

Screen('TextSize',p.wPtr,65);

initiationTime = nan;
responded = 0;
responseTime = nan;
resp = nan;
acc = nan;
tooFast = nan;

% Pulls out Stroop Stimulus from p.stimuli
stim = p.stimuli(p.curOverallTrialNum);

if p.session.isEfficacy == 1
    drawBanks(p,1);
    p.rewardsToDraw = p.numCorrectResp;
    [pw] = drawReward(p,p.yCenter+200);
end

if p.session.isTracker == 1
    drawTracker(p);
end


% frame orientation
Screen('FrameRect',p.wPtr,p.color.lightGrey,[p.xCenter-200,p.yCenter-85,p.xCenter+200,p.yCenter+85],2);

% Screen('TextSize',p.wPtr,stim.PrintSize);
Screen('TextSize',p.wPtr,65);
DrawFormattedText(p.wPtr,stim.Text,'center','center',stim.InkCode);

% Set the timing of the trial onset and offset
fixedStimStart = Screen(p.wPtr,'Flip');
if p.isScanningVersion
    results.timing.trial.fixationOffsetAbsolute(p.curBlockNum, p.curOverallTrialNum) = fixedStimStart;
    results.timing.trial.fixationOffsetRelative(p.curBlockNum, p.curOverallTrialNum) = ...
        results.timing.trial.fixationOffsetAbsolute(p.curBlockNum, p.curOverallTrialNum) - results.timing.scanBlockStartTTLglobal(p.curBlockNum);
    
    results.timing.trial.stimOnsetAbsolute(p.curBlockNum, p.curOverallTrialNum) = fixedStimStart;
    results.timing.trial.stimOnsetRelative(p.curBlockNum, p.curOverallTrialNum) = ...
        results.timing.trial.stimOnsetAbsolute(p.curBlockNum, p.curOverallTrialNum) - results.timing.scanBlockStartTTLglobal(p.curBlockNum);
end


if p.isScanningVersion == 1  
    WaitSecs(p.response.tooFastWait - (GetSecs - fixedStimStart));
else
    WaitSecs(p.response.tooFastWait - (GetSecs - fixedStimStart));
end


% Waits for button response from participant
while GetSecs < p.curIntervalEnd && responded == 0
    
    % look for response
    [press, pressTime, keyCode] = KbCheck(p.device.num.resp);
    whichKey = KbName(keyCode);
    if length(whichKey)>1
        whichKey = whichKey(1);
    end
    
    % check valid response
    try
        if press == 1 && length(whichKey)==1 && ~isempty(find(p.keyArrayStrVec == whichKey))
            responseTime = pressTime - fixedStimStart;
            resp = find(p.keyArrayStrVec == whichKey(1));
            responded = 1;
        end
    catch
        if press == 1 && length(whichKey)==1 && ~isempty(strfind(p.keyArrayStrVec,whichKey))
            try
            responseTime = pressTime - fixedStimStart;
            resp = find(p.keyArrayStrVec == whichKey(1));
            responded = 1;
            end
        end
    end
end

% Define the accuracy of the trial
if responded == 1
    if resp == stim.ColorAns
        acc = 1;
        tooFast = 0;
        p.flashCorrect = 1;
    else
        acc = 0;
        tooFast = 0;
    end

    if acc == 1
        p.numCorrectResp = p.numCorrectResp + 1;
    elseif acc == 0
        p.numIncorrectResp = p.numIncorrectResp + 1;
    end  
end

%% Save results
try
    results.trial.rewardLevel(p.curOverallTrialNum) = p.interval.rewardLevel(p.curIntervalNum);
    results.trial.penaltyLevel(p.curOverallTrialNum) = p.interval.penaltyLevel(p.curIntervalNum);
%     results.trial.effLevel(p.curOverallTrialNum) = p.interval.efficacyLevel(p.curIntervalNum);
    results.trial.isGain(p.curOverallTrialNum) = p.interval.gainValue(p.curIntervalNum);
    results.trial.intervalNum(p.curOverallTrialNum) = p.curIntervalNum;
    results.trial.blockNum(p.curOverallTrialNum) = p.curBlockNum;
    results.trial.overallTrialNum(p.curOverallTrialNum) = p.curOverallTrialNum;
    results.trial.intervalTrialNum(p.curOverallTrialNum) = p.curIntervalTrialNum;
    results.trial.initiationTime(p.curOverallTrialNum) = initiationTime;
    results.trial.resp(p.curOverallTrialNum) = resp;
    results.trial.responseTime(p.curOverallTrialNum) = responseTime;
    results.trial.acc(p.curOverallTrialNum) = acc;
    results.trial.tooFast(p.curOverallTrialNum) = tooFast;
end


end
