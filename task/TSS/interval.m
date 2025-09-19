function [p,practice,results] = interval(p,practice,results)
%% Cue
p.openBanks = 0;

% Load Images
p.cueImage = imread(p.interval.cueImage{p.curIntervalNum});
if p.session.isRewardPenalty || p.session.isLossPenalty
    p.cueImage = imresize(p.cueImage,0.20);
end
p.cueTexture = Screen('MakeTexture',p.wPtr,p.cueImage);

% If there are 2 or 3 feedback images, read each separately
if size(p.interval.feedbackImage{1},2) == 1
    p.feedbackImage = imread(p.interval.feedbackImage{p.curIntervalNum});
    p.feedbackTexture = Screen('MakeTexture',p.wPtr,p.feedbackImage);
elseif size(p.interval.feedbackImage{1},2) == 2
    p.feedbackImage1 = imread(p.interval.feedbackImage{p.curIntervalNum}{1});
    p.feedbackTexture1 = Screen('MakeTexture',p.wPtr,p.feedbackImage1);
    p.feedbackImage2 = imread(p.interval.feedbackImage{p.curIntervalNum}{2});
    p.feedbackTexture2 = Screen('MakeTexture',p.wPtr,p.feedbackImage2);
elseif size(p.interval.feedbackImage{1},2) == 3
    p.feedbackImage1 = imread(p.interval.feedbackImage{p.curIntervalNum}{1});
    p.feedbackTexture1 = Screen('MakeTexture',p.wPtr,p.feedbackImage1);
    p.feedbackImage2 = imread(p.interval.feedbackImage{p.curIntervalNum}{2});
    p.feedbackTexture2 = Screen('MakeTexture',p.wPtr,p.feedbackImage2);
    p.feedbackImage3 = imread(p.interval.feedbackImage{p.curIntervalNum}{3});
    p.feedbackTexture3 = Screen('MakeTexture',p.wPtr,p.feedbackImage3);
else
    sca
    %keyboard
    error('Error. \nThere is an incorrect number of feedback images in your counterbalanceMatrix!')
end

% p.feedbackImage = imread(p.interval.feedbackImage{p.curIntervalNum});
% p.feedbackTexture = Screen('MakeTexture',p.wPtr,p.feedbackImage);

% if p.session.isRewardPenalty == 1
%     p.cueImage = imresize(p.cueImage,0.3);
%     p.cueTexture = Screen('MakeTexture',p.wPtr,p.cueImage);
%     p.penaltyImage = imread([p.interval.feedbackImageFolder,'Loss.png']);
%     p.penaltyTexture = Screen('MakeTexture',p.wPtr,p.penaltyImage);
%     p.penaltyGain1Image = imread([p.interval.feedbackImageFolder,'Gain1.png']);
%     p.penaltyGain1Image = imresize(p.penaltyGain1Image,0.5);
%     p.penaltyGain1Texture = Screen('MakeTexture',p.wPtr,p.penaltyGain1Image);
%     p.penaltyLoss1Image = imread([p.interval.feedbackImageFolder,'Loss1.png']);
%     p.penaltyLoss1Image = imresize(p.penaltyLoss1Image,0.5);
%     p.penaltyLoss1Texture = Screen('MakeTexture',p.wPtr,p.penaltyLoss1Image);
% end

% If GainLoss session, set the Initial Bonus of Gems
if p.session.isGainLoss == 1
    if p.interval.gainValue(p.curIntervalNum)
        intBonusStart = '0';
    else
        intBonusStart = '1500';
    end
    
    Screen('TextSize',p.wPtr, 65);
    DrawFormattedText(p.wPtr,intBonusStart,'center',p.yCenter+250,p.color.white,70);
end

% Present Cue
Screen('DrawTexture',p.wPtr,p.cueTexture);
Screen('TextSize',p.wPtr, 65);
fixedCueStart = Screen(p.wPtr,'Flip');

% If Scanning Version, wait for the start of the trigger
if p.isScanningVersion
    results.timing.interval.intervalStartAbsolute(p.curBlockNum, p.curIntervalNum) = fixedCueStart;
    results.timing.interval.intervalStartRelative(p.curBlockNum, p.curIntervalNum) = ...
        results.timing.interval.intervalStartAbsolute(p.curBlockNum, p.curIntervalNum) - results.timing.scanBlockStartTTLglobal(p.curBlockNum);
    
    results.timing.interval.cueOnsetAbsolute(p.curBlockNum, p.curIntervalNum) = fixedCueStart;
    results.timing.interval.cueOnsetRelative(p.curBlockNum, p.curIntervalNum) = ...
        results.timing.interval.cueOnsetAbsolute(p.curBlockNum, p.curIntervalNum) - results.timing.scanBlockStartTTLglobal(p.curBlockNum);
end
WaitSecs(p.timing.cueDuration - (GetSecs - fixedCueStart));


%% Post Cue ISI
fixedCueItiStart = fixation(p,p.color.darkGrey);
if p.isScanningVersion
    results.timing.interval.cueOffsetAbsolute(p.curBlockNum, p.curIntervalNum) = fixedCueItiStart;
    results.timing.interval.cueOffsetRelative(p.curBlockNum, p.curIntervalNum) = ...
        results.timing.interval.cueOffsetAbsolute(p.curBlockNum, p.curIntervalNum) - results.timing.scanBlockStartTTLglobal(p.curBlockNum);
    
    results.timing.interval.cueIsiOnsetAbsolute(p.curBlockNum, p.curIntervalNum) = fixedCueItiStart;
    results.timing.interval.cueIsiOnsetRelative(p.curBlockNum, p.curIntervalNum) = ...
        results.timing.interval.cueIsiOnsetAbsolute(p.curBlockNum, p.curIntervalNum) - results.timing.scanBlockStartTTLglobal(p.curBlockNum);
end
WaitSecs(p.timing.iti.postCue - (GetSecs - fixedCueItiStart));


%% Trials
p.curIntervalReward = 0;
p.curIntervalPenalty = 0;
p.curIntervalTrialNum = 1;
p.curIntervalStart = GetSecs;

results.timing.intervalStart(p.curIntervalNum) = p.curIntervalStart;
p.curIntervalEnd = p.curIntervalStart + p.interval.length(p.curIntervalNum);

p.numCorrectResp = 0;
p.numIncorrectResp = 0;

if p.isScanningVersion
    results.timing.interval.cueIsiOffsetAbsolute(p.curBlockNum, p.curIntervalNum) = p.curIntervalStart;
    results.timing.interval.cueIsiOffsetRelative(p.curBlockNum, p.curIntervalNum) = ...
        results.timing.interval.cueOffsetAbsolute(p.curBlockNum, p.curIntervalNum) - results.timing.scanBlockStartTTLglobal(p.curBlockNum);
    
    results.timing.interval.respWindowOnsetAbsolute(p.curBlockNum, p.curIntervalNum) = p.curIntervalStart;
    results.timing.interval.respWindowOnsetRelative(p.curBlockNum, p.curIntervalNum) = ...
        results.timing.interval.respWindowOnsetAbsolute(p.curBlockNum, p.curIntervalNum) - results.timing.scanBlockStartTTLglobal(p.curBlockNum);
end

while GetSecs < p.curIntervalEnd
    
    [p,practice,results] = trial(p,practice,results);
    
    p.curOverallTrialNum = p.curOverallTrialNum + 1;
    p.curIntervalTrialNum = p.curIntervalTrialNum + 1;
    
    if p.session.isEfficacy == 1
        % efficacy banks
        drawBanks(p,1)
        [p] = drawReward(p,p.yCenter+200);
    end
    
    if p.session.isTracker == 1
        drawTracker(p);
    end

    % frame orientation
    Screen('TextSize',p.wPtr,65);
    Screen('FrameRect',p.wPtr,p.color.lightGrey,[p.xCenter-200,p.yCenter-85,p.xCenter+200,p.yCenter+85],2);
    if p.curDevice == 1
        DrawFormattedText(p.wPtr,'+','center',p.yCenter+25,p.color.white);
    elseif p.curDevice == 2
        % DrawFormattedText(p.wPtr,'+','center',p.yCenter,p.color.white);
        DrawFormattedText(p.wPtr,'+','center','center',p.color.white); % MT edited to use 'center' for y location
    elseif p.curDevice == 3
        DrawFormattedText(p.wPtr,'+','center','center',p.color.white);
        %DrawFormattedText(p.wPtr,'+','center','center',p.color.white);
    end
    
    Screen(p.wPtr,'Flip');
    
    if GetSecs + p.timing.isi >= p.curIntervalEnd
        WaitSecs(p.curIntervalEnd - GetSecs);
    elseif GetSecs < p.curIntervalEnd
        WaitSecs(p.timing.isi);
    end
    
end

results.timing.intervalEnd(p.curIntervalNum) = GetSecs;


%% Pre Feedback ISI
fixedFbItiStart = fixation(p,p.color.white);
if p.isScanningVersion
    results.timing.interval.respWindowOffsetAbsolute(p.curBlockNum, p.curIntervalNum) = fixedFbItiStart;
    results.timing.interval.respWindowOffsetRelative(p.curBlockNum, p.curIntervalNum) = ...
        results.timing.interval.respWindowOffsetAbsolute(p.curBlockNum, p.curIntervalNum) - results.timing.scanBlockStartTTLglobal(p.curBlockNum);
    
    results.timing.interval.fbIsiOnsetAbsolute(p.curBlockNum, p.curIntervalNum) = fixedFbItiStart;
    results.timing.interval.fbIsiOnsetRelative(p.curBlockNum, p.curIntervalNum) = ...
        results.timing.interval.fbIsiOnsetAbsolute(p.curBlockNum, p.curIntervalNum) - results.timing.scanBlockStartTTLglobal(p.curBlockNum);
end
WaitSecs(p.timing.iti.postCue - (GetSecs - fixedFbItiStart));



%% Feedback
p.openBanks = 1;
% Performance (Accuracy, Errors)
accResponses = p.numCorrectResp;
errorResponses = p.numIncorrectResp;

% Reward calculations (Reward, Penalty)
earnedReward = p.numCorrectResp;
p.curIntervalReward = earnedReward;
if p.session.isRewardPenalty || p.session.isLossPenalty
    penalizedResponses = p.numIncorrectResp;
else
    penalizedResponses = 0;
    p.curIntervalPenalty = 0;
    p.curIntervalNetReward = p.curIntervalReward;
end

% GainLoss Feedback
if p.session.isGainLoss == 1
    if p.session.isGamified == 1
        % calculate reward during interval
        if p.interval.rewardLevel(p.curIntervalNum) == 1
            p.curIntervalReward = p.numCorrectResp * p.stimulus.rewardValues(2);
        elseif p.interval.rewardLevel(p.curIntervalNum) == 0
            p.curIntervalReward = p.numCorrectResp * p.stimulus.rewardValues(1);
        end
        p.curIntervalNetReward = p.curIntervalReward;
        % draw feedback images
        Screen('DrawTexture',p.wPtr,p.feedbackTexture);
        Screen('TextSize',p.wPtr, 65);
        if p.interval.gainValue(p.curIntervalNum) == 1
            DrawFormattedText(p.wPtr,num2str(p.curIntervalNetReward),'center',p.yCenter+250,p.color.white,70);
        else
            p.curIntervalFb = p.intervalInitialLoss/p.conversionFactor - p.curIntervalNetReward;
            DrawFormattedText(p.wPtr,num2str(p.curIntervalFb),'center',p.yCenter+250,p.color.white,70);
            p.curIntervalReward = -(p.intervalInitialLoss/p.conversionFactor) + p.curIntervalNetReward;
        end
        fixedFbStart = Screen(p.wPtr,'Flip');
        
    elseif p.session.isGamified == 0
        Screen('DrawTexture',p.wPtr,p.cueTexture,[],[p.xCenter-133, p.yCenter-200, p.xCenter+133, p.yCenter+200]);
        Screen('TextSize',p.wPtr, 65);
        DrawFormattedText(p.wPtr,intBonusStart,'center',p.yCenter+300,p.color.white,70);
        Screen(p.wPtr,'Flip');
        
        WaitSecs(p.timing.fbAnimationDuration);
        
        if p.interval.rewardLevel(p.curIntervalNum) == 1
            p.curIntervalReward = p.numCorrectResp * p.stimulus.rewardValues(2);
        else
            p.curIntervalReward = p.numCorrectResp * p.stimulus.rewardValues(1);
        end
        
        [p] = drawReward(p);

        Screen('DrawTexture',p.wPtr,p.feedbackTexture,[],[p.xCenter-133, p.yCenter-200, p.xCenter+133, p.yCenter+200]);
        Screen('TextSize',p.wPtr, 65);
        if p.interval.gainValue(p.curIntervalNum)
            DrawFormattedText(p.wPtr,['+$',sprintf('%0.2f',p.curIntervalReward)],'center',p.yCenter+300,p.color.white,70);
        else
            p.curIntervalReward = -p.intervalInitialLoss + p.curIntervalReward;
            DrawFormattedText(p.wPtr,['-$',sprintf('%0.2f',p.curIntervalReward)],'center',p.yCenter+300,p.color.white,70);
        end
        fixedFbStart = Screen(p.wPtr,'Flip');
    end
    
    % Feedback for Reward-Penalty Version, No Loss avoidance
elseif p.session.isRewardPenalty == 1
    if p.session.isGamified == 1
        % calculate reward during interval
        if p.interval.rewardLevel(p.curIntervalNum) == 1
            p.curIntervalReward = p.numCorrectResp * p.stimulus.rewardValues(2);
        else
            p.curIntervalReward = p.numCorrectResp * p.stimulus.rewardValues(1);
        end
        % calculate penalty during interval
        if p.interval.penaltyLevel(p.curIntervalNum) == 1
            p.curIntervalPenalty = p.numIncorrectResp * p.stimulus.penaltyValues(2);
        else
            p.curIntervalPenalty = p.numIncorrectResp * p.stimulus.penaltyValues(1);
        end
        % calculate Net Reward per Interval
        p.curIntervalNetReward = p.curIntervalReward - p.curIntervalPenalty;
        
        % draw feedback images
        %Screen('DrawTexture',p.wPtr,p.feedbackTexture1);
        if p.curDevice == 1 % DY laptop
            Screen('DrawTexture',p.wPtr,p.feedbackTexture1,[],[p.xCenter-120,p.yCenter-150,p.xCenter+80,p.yCenter+50]);
        else
            Screen('DrawTexture',p.wPtr,p.feedbackTexture1,[],[p.xCenter-80,p.yCenter-150,p.xCenter+80,p.yCenter+50]);
        end
        Screen('TextSize',p.wPtr, 65);
        if p.curIntervalNetReward >= 0
            if p.curDevice == 1 % DY laptop
                DrawFormattedText(p.wPtr,num2str(p.curIntervalNetReward),'center',p.yCenter+100,p.color.white,70);
            elseif p.curDevice == 2 % AS laptop - MT added 01/11/21
                DrawFormattedText(p.wPtr,num2str(p.curIntervalNetReward),'center',p.yCenter+100,p.color.white,70);
            elseif p.curDevice == 3 % MRF 
                DrawFormattedText(p.wPtr,num2str(p.curIntervalNetReward),'center',p.yCenter+100,p.color.white,70);
                %DrawFormattedText(p.wPtr,num2str(p.curIntervalNetReward),p.xCenter-25,p.yCenter+100,p.color.white,70);
            end
        elseif p.curIntervalNetReward < 0
            if p.curDevice == 1 % DY laptop
                DrawFormattedText(p.wPtr,['-',num2str(abs(p.curIntervalNetReward))],'center',p.yCenter+100,p.color.white,70);
            elseif p.curDevice == 2 % AS laptop - MT added 01/11/21
                DrawFormattedText(p.wPtr,['-',num2str(abs(p.curIntervalNetReward))],'center',p.yCenter+100,p.color.white,70);
            elseif p.curDevice == 3 % MRF
                %DrawFormattedText(p.wPtr,['-',num2str(abs(p.curIntervalNetReward))],p.xCenter-35,p.yCenter+100,p.color.white,70);
                DrawFormattedText(p.wPtr,['-',num2str(abs(p.curIntervalNetReward))],'center',p.yCenter+100,p.color.white,70);
                
            end    
        end
        % draw little gem on the left
        %Screen('DrawTexture',p.wPtr,p.feedbackTexture1,[],[p.xCenter-375,p.yCenter+300,p.xCenter-275,p.yCenter+400]);
        %DrawFormattedText(p.wPtr,num2str(p.curIntervalReward),p.xCenter-250,p.yCenter+390,p.color.white,70);
        Screen('DrawTexture',p.wPtr,p.feedbackTexture1,[],[p.xCenter-375,p.yCenter+200,p.xCenter-275,p.yCenter+300]);
        if p.curDevice == 1 % DY Laptop
            DrawFormattedText(p.wPtr,num2str(p.curIntervalReward),p.xCenter-250,p.yCenter+275,p.color.white,70);
        elseif p.curDevice == 2 % AS laptop - MT added 01/11/21
            DrawFormattedText(p.wPtr,num2str(p.curIntervalReward),p.xCenter-250,p.yCenter+275,p.color.white,70);
        elseif p.curDevice == 3 % MRF computer
            %DrawFormattedText(p.wPtr,num2str(p.curIntervalReward),p.xCenter-350,p.yCenter+325,p.color.white,70);
            DrawFormattedText(p.wPtr,num2str(p.curIntervalReward),p.xCenter-250,p.yCenter+225,p.color.white,70);
        end
        
        % draw little bomb on the right
        %Screen('DrawTexture',p.wPtr,p.feedbackTexture2,[],[p.xCenter+150,p.yCenter+300,p.xCenter+275,p.yCenter+400]);
        %DrawFormattedText(p.wPtr,num2str(p.curIntervalPenalty),p.xCenter+300,p.yCenter+390,p.color.white,70);
        Screen('DrawTexture',p.wPtr,p.feedbackTexture2,[],[p.xCenter+150,p.yCenter+200,p.xCenter+275,p.yCenter+300]);
        if p.curDevice == 1 % DY Laptop
            DrawFormattedText(p.wPtr,num2str(p.curIntervalPenalty),p.xCenter+280,p.yCenter+275,p.color.white,70);
        elseif p.curDevice == 2 % AS laptop - MT added 01/11/21
            DrawFormattedText(p.wPtr,num2str(p.curIntervalPenalty),p.xCenter+280,p.yCenter+275,p.color.white,70);
        elseif p.curDevice == 3 % MRF computer
            %DrawFormattedText(p.wPtr,num2str(p.curIntervalPenalty),p.xCenter+200,p.yCenter+325,p.color.white,70);
            DrawFormattedText(p.wPtr,num2str(p.curIntervalPenalty),p.xCenter+280,p.yCenter+225,p.color.white,70);
        end
        
        fixedFbStart = Screen(p.wPtr,'Flip');
        
    end
    
    % Feedback for Loss-Penalty Version, No Reward 
    % p.curIntervalReward is the same as p.curIntervalLossAvoidance, so using same vars)
elseif p.session.isLossPenalty == 1
    if p.session.isGamified == 1
        % calculate reward during interval
        if p.interval.rewardLevel(p.curIntervalNum) == 1
            p.curIntervalReward = p.numCorrectResp * p.stimulus.rewardValues(2);
        else
            p.curIntervalReward = p.numCorrectResp * p.stimulus.rewardValues(1);
        end
        % calculate penalty during interval
        if p.interval.penaltyLevel(p.curIntervalNum) == 1
            p.curIntervalPenalty = p.numIncorrectResp * p.stimulus.penaltyValues(2);
        else
            p.curIntervalPenalty = p.numIncorrectResp * p.stimulus.penaltyValues(1);
        end
        % calculate Net Reward Per Interval (Net Bombs Removed)
        %p.curIntervalNetReward = p.curIntervalReward - p.curIntervalPenalty - p.initialBombsPerTurn;
        p.curIntervalNetReward = p.curIntervalReward - p.curIntervalPenalty;
        
        % draw feedback images
        %Screen('DrawTexture',p.wPtr,p.feedbackTexture1);
        Screen('DrawTexture',p.wPtr,p.feedbackTexture2,[],[p.xCenter-80,p.yCenter-150,p.xCenter+80,p.yCenter+50]); % MT updated first coordinate to p.xcenter-80 from p.xCenter-120 (to unstretch the image)
        Screen('TextSize',p.wPtr, 65);
        if p.curIntervalNetReward >= 0
            if p.curDevice == 1 % DY laptop
                DrawFormattedText(p.wPtr,num2str(p.curIntervalNetReward),'center',p.yCenter+100,p.color.white,70);
            elseif p.curDevice == 2 % AS laptop - MT added 01/11/21
                DrawFormattedText(p.wPtr,num2str(p.curIntervalNetReward),'center',p.yCenter+100,p.color.white,70);
            elseif p.curDevice == 3 % MRF 
                DrawFormattedText(p.wPtr,num2str(p.curIntervalNetReward),'center',p.yCenter+100,p.color.white,70);
                %DrawFormattedText(p.wPtr,num2str(p.curIntervalNetReward),p.xCenter-25,p.yCenter+100,p.color.white,70);
            end
        elseif p.curIntervalNetReward < 0
            if p.curDevice == 1 % DY laptop
               DrawFormattedText(p.wPtr,['-',num2str(abs(p.curIntervalNetReward))],'center',p.yCenter+100,p.color.white,70);
            elseif p.curDevice == 2 % AS laptop - MT added 01/11/21
               DrawFormattedText(p.wPtr,['-',num2str(abs(p.curIntervalNetReward))],'center',p.yCenter+100,p.color.white,70);
            elseif p.curDevice == 3 % MRF
                %DrawFormattedText(p.wPtr,['-',num2str(abs(p.curIntervalNetReward))],p.xCenter-35,p.yCenter+100,p.color.white,70);
                DrawFormattedText(p.wPtr,['-',num2str(abs(p.curIntervalNetReward))],'center',p.yCenter+100,p.color.white,70);
                
            end    
        end
        % draw little gray bomb on the left
        %Screen('DrawTexture',p.wPtr,p.feedbackTexture1,[],[p.xCenter-375,p.yCenter+300,p.xCenter-275,p.yCenter+400]);
        %DrawFormattedText(p.wPtr,num2str(p.curIntervalReward),p.xCenter-250,p.yCenter+390,p.color.white,70);
        Screen('DrawTexture',p.wPtr,p.feedbackTexture2,[],[p.xCenter-350,p.yCenter+200,p.xCenter-275,p.yCenter+300]);
        if p.curDevice == 1 % DY Laptop
            DrawFormattedText(p.wPtr,num2str(p.curIntervalReward),p.xCenter-250,p.yCenter+275,p.color.white,70);
        elseif p.curDevice == 2 % AS laptop - MT added 01/11/21
            DrawFormattedText(p.wPtr,num2str(p.curIntervalReward),p.xCenter-250,p.yCenter+275,p.color.white,70);
        elseif p.curDevice == 3 % MRF computer
            %DrawFormattedText(p.wPtr,num2str(p.curIntervalReward),p.xCenter-350,p.yCenter+325,p.color.white,70);
            DrawFormattedText(p.wPtr,num2str(p.curIntervalReward),p.xCenter-250,p.yCenter+225,p.color.white,70);
        end
        
        % draw little orange bomb on the right
        %Screen('DrawTexture',p.wPtr,p.feedbackTexture2,[],[p.xCenter+150,p.yCenter+300,p.xCenter+275,p.yCenter+400]);
        %DrawFormattedText(p.wPtr,num2str(p.curIntervalPenalty),p.xCenter+300,p.yCenter+390,p.color.white,70);
        Screen('DrawTexture',p.wPtr,p.feedbackTexture3,[],[p.xCenter+150,p.yCenter+200,p.xCenter+275,p.yCenter+300]);
        if p.curDevice == 1 % DY Laptop
            DrawFormattedText(p.wPtr,num2str(p.curIntervalPenalty),p.xCenter+280,p.yCenter+275,p.color.white,70);
        elseif p.curDevice == 2 % AS laptop - MT added 01/11/21
            DrawFormattedText(p.wPtr,num2str(p.curIntervalPenalty),p.xCenter+280,p.yCenter+275,p.color.white,70);
        elseif p.curDevice == 3 % MRF computer
            %DrawFormattedText(p.wPtr,num2str(p.curIntervalPenalty),p.xCenter+200,p.yCenter+325,p.color.white,70);
            DrawFormattedText(p.wPtr,num2str(p.curIntervalPenalty),p.xCenter+280,p.yCenter+225,p.color.white,70);
        end
        
        fixedFbStart = Screen(p.wPtr,'Flip');
        
    end    
    % Efficacy Feedback
elseif p.session.isEfficacy == 1
    
    try
        randomReward = round(datasample(p.rollingRewardWindow, 1) * p.intervalLength(p.curIntervalNum));
        randomReward = round(randomReward);
    catch
        randomReward = p.numCorrectResp;
    end
    
    
    if rand < p.interval.efficacyValue(p.curIntervalNum)                   % rand is performance-based reward probability
        % Perfromance-Based reward
        p.curIntervalReward = earnedReward;
        
        if p.interval.rewardLevel(p.curIntervalNum) == 0
            buttonImgFile = imread('Images/Feedback/Efficacy/Rew1_Eff100.jpg');
        else
            buttonImgFile = imread('Images/Feedback/Efficacy/Rew2_Eff100.jpg');
        end
        
        if p.interval.rewardLevel(p.curIntervalNum) == 0
            diceImgFile = imread('Images/Feedback/Efficacy/Rew1_Eff0_grey.jpg');
        else
            diceImgFile = imread('Images/Feedback/Efficacy/Rew2_Eff0_grey.jpg');
        end
        
    else
        % Random reward
        p.curIntervalReward = randomReward;
        
        if p.interval.rewardLevel(p.curIntervalNum) == 0
            buttonImgFile = imread('Images/Feedback/Efficacy/Rew1_Eff100_grey.jpg');
        else
            buttonImgFile = imread('Images/Feedback/Efficacy/Rew2_Eff100_grey.jpg');
        end
        
        if p.interval.rewardLevel(p.curIntervalNum) == 0
            diceImgFile = imread('Images/Feedback/Efficacy/Rew1_Eff0.jpg');
        else
            diceImgFile = imread('Images/Feedback/Efficacy/Rew2_Eff0.jpg');
        end
        
    end
    
    p.buttonTexture = Screen('MakeTexture',p.wPtr,buttonImgFile);
    p.diceTexture = Screen('MakeTexture',p.wPtr,diceImgFile);
    drawBanks(p,0)
    
    p.rewardsToDraw = earnedReward;
    p.feedbackTexture = p.buttonTexture;
    [p] = drawReward(p,p.yCenter+200);
    
    p.rewardsToDraw = randomReward;
    p.feedbackTexture = p.diceTexture;
    [p] = drawReward(p,p.yCenter-350);
    
    
    
    if p.interval.rewardLevel(p.curIntervalNum) == 1
        p.curIntervalReward = p.curIntervalReward * p.stimulus.rewardValues(2);
    end
    
    
    %% Update Sliding Reward Window
    if p.interval.efficacyLevel(p.curIntervalNum) == 2                        % yolking to high efficacy, not necessarily 100% efficacy 
        rewardRate = earnedReward / p.intervalLength(p.curIntervalNum);
        
        if length(p.rollingRewardWindow) < 10
            p.rollingRewardWindow = [p.rollingRewardWindow, rewardRate];
        else
            p.rollingRewardWindow = [p.rollingRewardWindow(2:10), rewardRate];
        end
        
    end
    
    Screen('TextSize',p.wPtr, 65);
    DrawFormattedText(p.wPtr,['+ ', num2str(p.curIntervalReward)],'center','center',p.color.white,70);
    fixedFbStart = Screen(p.wPtr,'Flip');
    
    
end


if p.isScanningVersion
    results.timing.interval.fbIsiOffsetAbsolute(p.curBlockNum, p.curIntervalNum) = fixedFbStart;
    results.timing.interval.fbIsiOffsetRelative(p.curBlockNum, p.curIntervalNum) = ...
        results.timing.interval.fbIsiOffsetAbsolute(p.curBlockNum, p.curIntervalNum) - results.timing.scanBlockStartTTLglobal(p.curBlockNum);
    
    results.timing.interval.fbOnsetAbsolute(p.curBlockNum, p.curIntervalNum) = fixedFbStart;
    results.timing.interval.fbOnsetRelative(p.curBlockNum, p.curIntervalNum) = ...
        results.timing.interval.fbOnsetAbsolute(p.curBlockNum, p.curIntervalNum) - results.timing.scanBlockStartTTLglobal(p.curBlockNum);
end


%% Save Results
results.interval.rewLevel(p.curIntervalNum) = p.interval.rewardLevel(p.curIntervalNum);
% results.interval.effLevel(p.curIntervalNum) = p.interval.efficacyLevel(p.curIntervalNum);
results.interval.isGain(p.curIntervalNum) = p.interval.gainValue(p.curIntervalNum);
results.interval.penaltyLevel(p.curIntervalNum) = p.interval.penaltyLevel(p.curIntervalNum);
results.interval.numTrialsSeen(p.curIntervalNum) = p.curIntervalTrialNum;
% BUG in variable below due to pre-emptively ending while-loop
% results.interval.numTrialsResponded(p.curIntervalNum) = p.curIntervalTrialNum - 1;
results.interval.numAccTrials(p.curIntervalNum) = accResponses;
results.interval.numErrorTrials(p.curIntervalNum) = errorResponses;
results.interval.numPenalizedTrials(p.curIntervalNum) = penalizedResponses;
results.interval.reward(p.curIntervalNum) = p.curIntervalReward;
results.interval.penalty(p.curIntervalNum) = p.curIntervalPenalty;
results.interval.netreward(p.curIntervalNum) = p.curIntervalNetReward;
results.interval.totalPoints = results.interval.totalPoints + p.curIntervalReward;
results.interval.blockNum(p.curIntervalNum) = p.curBlockNum;


try
    saveResults(p,practice,results)
catch
    save(fullfile([p.session.versionPath,'/Results'],['TSS_',p.subID,'_',p.date,'.mat']),'p','results');
end

WaitSecs(p.timing.fbDuration - (GetSecs - fixedFbStart));


%% ITI
fixedItiStart = fixation(p,p.color.white);

if p.isScanningVersion
    results.timing.interval.fbOffsetAbsolute(p.curBlockNum, p.curIntervalNum) = fixedItiStart;
    results.timing.interval.fbOffsetRelative(p.curBlockNum, p.curIntervalNum) = ...
        results.timing.interval.fbOffsetAbsolute(p.curBlockNum, p.curIntervalNum) - results.timing.scanBlockStartTTLglobal(p.curBlockNum);
    
    results.timing.interval.intervalEndAbsolute(p.curBlockNum, p.curIntervalNum) = fixedItiStart;
    results.timing.interval.intervalEndRelative(p.curBlockNum, p.curIntervalNum) = ...
        results.timing.interval.intervalEndAbsolute(p.curBlockNum, p.curIntervalNum) - results.timing.scanBlockStartTTLglobal(p.curBlockNum);
end


try
    WaitSecs(p.timing.iti.preCue(p.curIntervalNum) - (GetSecs - fixedItiStart));
catch
    WaitSecs(4.8 - (GetSecs - fixedItiStart));
end


end

