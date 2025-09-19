function drawTracker(p)

Screen('DrawTexture',p.wPtr,p.feedbackTexture,[],[p.xCenter-150, p.yCenter+400, p.xCenter-100, p.yCenter+450]);
Screen('DrawTexture',p.wPtr,p.feedbackTexture,[],[p.xCenter+100, p.yCenter+400, p.xCenter+150, p.yCenter+450]);

if p.interval.rewardLevel(p.curIntervalNum) == 1
    p.curIntervalReward = p.numCorrectResp * p.stimulus.rewardValues(2);
else
    p.curIntervalReward = p.numCorrectResp * p.stimulus.rewardValues(1);
end

Screen('TextSize',p.wPtr, 65);
if p.interval.gainValue(p.curIntervalNum)
    DrawFormattedText(p.wPtr,num2str(p.curIntervalReward),'center',p.yCenter+450,p.color.white,70);
else
    p.curIntervalFb = p.intervalInitialLoss/p.conversionFactor - p.curIntervalReward;
    DrawFormattedText(p.wPtr,num2str(p.curIntervalFb),'center',p.yCenter+450,p.color.white,70);
    p.curIntervalReward = -(p.intervalInitialLoss/p.conversionFactor) + p.curIntervalReward;
end

end

