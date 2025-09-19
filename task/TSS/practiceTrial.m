function [p,practice,results] = practiceTrial(p,practice,results)
%TRIAL Summary of this function goes here
%   Detailed explanation goes here

Screen('TextSize',p.wPtr,65);

initiationTime = nan;
responded = 0;
responseTime = nan;
resp = nan;
acc = nan;
tooFast = nan;


% Stimulus
stim = p.stimuli(p.curOverallTrialNum);

% frame orientation
Screen('FrameRect',p.wPtr,p.color.lightGrey,[p.xCenter-200,p.yCenter-85,p.xCenter+200,p.yCenter+85],2);

% Screen('TextSize',p.wPtr,stim.PrintSize);
Screen('TextSize',p.wPtr,65);
DrawFormattedText(p.wPtr,stim.Text,'center','center',stim.InkCode);

fixedStimStart = Screen(p.wPtr,'Flip');

WaitSecs(p.response.tooFastWait);

while GetSecs < p.curIntervalEnd && responded == 0
    
    % get key
    [press, pressTime, keyCode] = KbCheck(-1);
    whichKey = KbName(keyCode);
    if length(whichKey)>1
        whichKey = whichKey(1);
    end
    
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


if responded == 1
    % Feedback
    if resp == stim.ColorAns
        acc = 1;
        tooFast = 0;
    else
        acc = 0;
        tooFast = 0;
    end
    
    
    if acc == 1
        p.numCorrectResp = p.numCorrectResp + 1;
    else
        p.numIncorrectResp = p.numIncorrectResp + 1;
    end
    
end

%% Save practice
practice.rewLevel(p.curOverallTrialNum) = p.practice.interval.rewardLevel(p.curIntervalNum);
practice.initiationTime{p.curOverallTrialNum} = initiationTime;
practice.resp{p.curOverallTrialNum} = resp;
practice.responseTime{p.curOverallTrialNum} = responseTime;
practice.acc(p.curOverallTrialNum) = acc;
practice.tooFast(p.curOverallTrialNum) = tooFast;

end
