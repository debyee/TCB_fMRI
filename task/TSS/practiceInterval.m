function [p,practice,results] = practiceInterval(p,practice,results)
p.openBanks = 0;

%% Cue
% Load Cue
if p.practice.isCued == 1
    
    % Load Images
    p.cueImage = imread(p.practice.interval.cueImage{p.curIntervalNum});
    if p.session.isRewardPenalty || p.session.isLossPenalty
        p.cueImage = imresize(p.cueImage,0.20);
    end
    p.cueTexture = Screen('MakeTexture',p.wPtr,p.cueImage);
    
    % If there are 2 or 3 feedback images, read each separately
    if size(p.practice.interval.feedbackImage{1},2) == 1
        p.feedbackImage = imread(p.practice.interval.feedbackImage{p.curIntervalNum});
        p.feedbackTexture = Screen('MakeTexture',p.wPtr,p.feedbackImage);
    elseif size(p.practice.interval.feedbackImage{1},2) == 2
        p.feedbackImage1 = imread(p.practice.interval.feedbackImage{p.curIntervalNum}{1});
        p.feedbackTexture1 = Screen('MakeTexture',p.wPtr,p.feedbackImage1);
        p.feedbackImage2 = imread(p.practice.interval.feedbackImage{p.curIntervalNum}{2});
        p.feedbackTexture2 = Screen('MakeTexture',p.wPtr,p.feedbackImage2);
    elseif size(p.practice.interval.feedbackImage{1},2) == 3
        p.feedbackImage1 = imread(p.practice.interval.feedbackImage{p.curIntervalNum}{1});
        p.feedbackTexture1 = Screen('MakeTexture',p.wPtr,p.feedbackImage1);
        p.feedbackImage2 = imread(p.practice.interval.feedbackImage{p.curIntervalNum}{2});
        p.feedbackTexture2 = Screen('MakeTexture',p.wPtr,p.feedbackImage2);
        p.feedbackImage3 = imread(p.practice.interval.feedbackImage{p.curIntervalNum}{3});
        p.feedbackTexture3 = Screen('MakeTexture',p.wPtr,p.feedbackImage3); 
    else 
        sca;
        keyboard
        error('Error. \nThere is an incorrect number of feedback images in your counterbalancePracticeMatrix!')
    end
        
%     if p.session.isRewardPenalty == 1
%         p.cueImage = imresize(p.cueImage,0.3);
%         p.cueTexture = Screen('MakeTexture',p.wPtr,p.cueImage);
%         p.penaltyImage = imread([p.interval.feedbackImageFolder,'Loss.png']);
%         p.penaltyTexture = Screen('MakeTexture',p.wPtr,p.penaltyImage);
%         p.penaltyGain1Image = imread([p.interval.feedbackImageFolder,'Gain1.png']);
%         p.penaltyGain1Image = imresize(p.penaltyGain1Image,0.5);
%         p.penaltyGain1Texture = Screen('MakeTexture',p.wPtr,p.penaltyGain1Image);
%         p.penaltyLoss1Image = imread([p.interval.feedbackImageFolder,'Loss1.png']);
%         p.penaltyLoss1Image = imresize(p.penaltyLoss1Image,0.5);
%         p.penaltyLoss1Texture = Screen('MakeTexture',p.wPtr,p.penaltyLoss1Image);
%     end
    
    % If GainLoss session, set the Initial Bonus of Gems
    if p.session.isGainLoss == 1
        if p.practice.interval.gainValue(p.curIntervalNum)
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
    
    Screen(p.wPtr,'Flip');
    fixedCueStart = GetSecs;
    WaitSecs(p.timing.cueDuration - (GetSecs - fixedCueStart));
    
end


%% ISI
fixation(p,p.color.darkGrey);
WaitSecs(p.timing.iti.postCue);


%% Trials
p.curIntervalReward = 0;
p.curIntervalPenalty = 0;
p.curIntervalTrialNum = 1;
p.curIntervalStart = GetSecs;

practice.timing.intervalStart(p.curIntervalNum) = p.curIntervalStart;
p.curIntervalEnd = p.curIntervalStart + p.practice.interval.length(p.curIntervalNum);

p.numCorrectResp = 0;
p.numIncorrectResp = 0;

while GetSecs < p.curIntervalEnd
    
    [p,practice,results] = practiceTrial(p,practice,results);
    
    p.curOverallTrialNum = p.curOverallTrialNum + 1;
    p.curIntervalTrialNum = p.curIntervalTrialNum + 1;
    
    if p.session.isEfficacy == 1
        % efficacy banks
        drawBanks(p,1)
        drawReward(p,p.yCenter+200);
    end
    
    if p.practice.isCued == 1 && p.session.isTracker == 1
        drawTracker(p);
    end
    
    % frame orientation
    Screen('FrameRect',p.wPtr,p.color.lightGrey,[p.xCenter-200,p.yCenter-85,p.xCenter+200,p.yCenter+85],2);
    %fixation(p,p.color.white);
    if p.curDevice == 1
        DrawFormattedText(p.wPtr,'+','center',p.yCenter+25,p.color.white);
    elseif p.curDevice == 2
        % DrawFormattedText(p.wPtr,'+','center',p.yCenter,p.color.white);
        DrawFormattedText(p.wPtr,'+','center','center',p.color.white); % MT edited to use 'center' as y location
    elseif p.curDevice == 3
        DrawFormattedText(p.wPtr,'+','center',p.yCenter,p.color.white);
        %DrawFormattedText(p.wPtr,'+','center','center',p.color.white);
    end
    
    %DrawFormattedText(p.wPtr,'+','center',p.yCenter+25,p.color.white);
    %DrawFormattedText(p.wPtr,'+','center','center',p.color.white);
    %DrawFormattedText(p.wPtr,'+','center','center',p.color.white,[p.xCenter-200,p.yCenter-85,p.xCenter+200,p.yCenter+85]);
    
    Screen(p.wPtr,'Flip');
    WaitSecs(p.timing.isi);
    
end

practice.timing.intervalEnd(p.curIntervalNum) = GetSecs;


%% Feedback
p.openBanks = 1;
earnedReward = p.numCorrectResp;

p.curIntervalReward = earnedReward;
p.rewardsToDraw = earnedReward;


try
    if p.practice.isCued == 1
        if p.session.isGainLoss == 1
            if p.session.isGamified == 1
                % calculate reward during interval
                if p.practice.interval.rewardLevel(p.curIntervalNum) == 1
                    p.curIntervalReward = p.numCorrectResp * p.stimulus.rewardValues(2);
                else
                    p.curIntervalReward = p.numCorrectResp * p.stimulus.rewardValues(1);
                end
                
                % draw feedback images
                Screen('DrawTexture',p.wPtr,p.feedbackTexture);
                Screen('TextSize',p.wPtr, 65);
                if p.practice.interval.gainLevel(p.curIntervalNum)
                    DrawFormattedText(p.wPtr,num2str(p.curIntervalReward),'center',p.yCenter+250,p.color.white,70);
                else
                    p.curIntervalReward = p.intervalInitialLoss/p.conversionFactor - p.curIntervalReward;
                    DrawFormattedText(p.wPtr,num2str(p.curIntervalReward),'center',p.yCenter+250,p.color.white,70);
                end
            else
                Screen('TextSize',p.wPtr, 50);
                DrawFormattedText(p.wPtr,[num2str(p.curIntervalReward), ' Rewards Earned'],'center','center',p.color.white,70);
            end
            
        elseif p.session.isRewardPenalty == 1
            if p.session.isGamified == 1
                % calculate reward during interval
                if p.practice.interval.rewardLevel(p.curIntervalNum) == 1
                    p.curIntervalReward = p.numCorrectResp * p.stimulus.rewardValues(2);
                else
                    p.curIntervalReward = p.numCorrectResp * p.stimulus.rewardValues(1);
                end
                % calculate penalty during interval
                if p.practice.interval.penaltyLevel(p.curIntervalNum) == 1
                    p.curIntervalPenalty = p.numIncorrectResp * p.stimulus.penaltyValues(2);
                else
                    p.curIntervalPenalty = p.numIncorrectResp * p.stimulus.penaltyValues(1);
                end
                % calculate Net Reward Per Interval
                p.curIntervalNetReward = p.curIntervalReward - p.curIntervalPenalty;
                
                % draw feedback images
                Screen('DrawTexture',p.wPtr,p.feedbackTexture1,[],[p.xCenter-120,p.yCenter-150,p.xCenter+80,p.yCenter+50]);
                Screen('TextSize',p.wPtr, 65);
                if p.curIntervalNetReward >= 0
                    %DrawFormattedText(p.wPtr,num2str(p.curIntervalNetReward),p.xCenter-25,p.yCenter+150,p.color.white,70);
                    DrawFormattedText(p.wPtr,num2str(p.curIntervalNetReward),'center',p.yCenter+100,p.color.white,70);
                elseif p.curIntervalNetReward < 0
                    %DrawFormattedText(p.wPtr,['-',num2str(abs(p.curIntervalNetReward))],p.xCenter-35,p.yCenter+150,p.color.white,70);
                    DrawFormattedText(p.wPtr,['-',num2str(abs(p.curIntervalNetReward))],'center',p.yCenter+150,p.color.white,70);
                end
                % draw little gem on the left
                Screen('DrawTexture',p.wPtr,p.feedbackTexture1,[],[p.xCenter-375,p.yCenter+200,p.xCenter-275,p.yCenter+300]);
                %DrawFormattedText(p.wPtr,num2str(p.curIntervalReward),p.xCenter-250,p.yCenter+300,p.color.white,70);
                DrawFormattedText(p.wPtr,num2str(p.curIntervalReward),p.xCenter-250,p.yCenter+275,p.color.white,70);
                % draw little bomb on the right
                Screen('DrawTexture',p.wPtr,p.feedbackTexture2,[],[p.xCenter+150,p.yCenter+200,p.xCenter+275,p.yCenter+300]);
                %DrawFormattedText(p.wPtr,num2str(p.curIntervalPenalty),p.xCenter+300,p.yCenter+300,p.color.white,70);
                DrawFormattedText(p.wPtr,num2str(p.curIntervalPenalty),p.xCenter+280,p.yCenter+275,p.color.white,70);
                
            else
                Screen('TextSize',p.wPtr, 50);
                DrawFormattedText(p.wPtr,[num2str(p.curIntervalReward), ' Rewards Earned'],'center','center',p.color.white,70);
            end
        % LOSS PENALTY    
        elseif p.session.isLossPenalty == 1
            if p.session.isGamified == 1
                % calculate reward during interval
                if p.practice.interval.rewardLevel(p.curIntervalNum) == 1
                    p.curIntervalReward = p.numCorrectResp * p.stimulus.rewardValues(2);
                else
                    p.curIntervalReward = p.numCorrectResp * p.stimulus.rewardValues(1);
                end
                % calculate penalty during interval
                if p.practice.interval.penaltyLevel(p.curIntervalNum) == 1
                    p.curIntervalPenalty = p.numIncorrectResp * p.stimulus.penaltyValues(2);
                else
                    p.curIntervalPenalty = p.numIncorrectResp * p.stimulus.penaltyValues(1);
                end
                % calculate Net Reward Per Interval (net bombs removed)
                %p.curIntervalNetReward = p.curIntervalReward - p.curIntervalPenalty - p.initialBombsPerTurn;
                p.curIntervalNetReward = p.curIntervalReward - p.curIntervalPenalty;
                
                % draw feedback images
                Screen('DrawTexture',p.wPtr,p.feedbackTexture2,[],[p.xCenter-80,p.yCenter-150,p.xCenter+80,p.yCenter+50]);
                Screen('TextSize',p.wPtr, 65);
                if p.curIntervalNetReward >= 0
                    %DrawFormattedText(p.wPtr,num2str(p.curIntervalNetReward),p.xCenter-25,p.yCenter+150,p.color.white,70);
                    DrawFormattedText(p.wPtr,num2str(p.curIntervalNetReward),'center',p.yCenter+100,p.color.white,70);
                elseif p.curIntervalNetReward < 0
                    %DrawFormattedText(p.wPtr,['-',num2str(abs(p.curIntervalNetReward))],p.xCenter-35,p.yCenter+150,p.color.white,70);
                    DrawFormattedText(p.wPtr,['-',num2str(abs(p.curIntervalNetReward))],'center',p.yCenter+150,p.color.white,70);
                end
                % draw little gray bomb on the left
                Screen('DrawTexture',p.wPtr,p.feedbackTexture2,[],[p.xCenter-350,p.yCenter+200,p.xCenter-275,p.yCenter+300]);
                %DrawFormattedText(p.wPtr,num2str(p.curIntervalReward),p.xCenter-250,p.yCenter+300,p.color.white,70);
                DrawFormattedText(p.wPtr,num2str(p.curIntervalReward),p.xCenter-250,p.yCenter+275,p.color.white,70);
                % draw little orange bomb on the right
                Screen('DrawTexture',p.wPtr,p.feedbackTexture3,[],[p.xCenter+150,p.yCenter+200,p.xCenter+275,p.yCenter+300]);
                %DrawFormattedText(p.wPtr,num2str(p.curIntervalPenalty),p.xCenter+300,p.yCenter+300,p.color.white,70);
                DrawFormattedText(p.wPtr,num2str(p.curIntervalPenalty),p.xCenter+280,p.yCenter+275,p.color.white,70);
                
            else
                Screen('TextSize',p.wPtr, 50);
                DrawFormattedText(p.wPtr,[num2str(p.curIntervalReward), ' Rewards Earned'],'center','center',p.color.white,70);
            end
            
        elseif p.session.isEfficacy == 1
            
            if p.practice.interval.efficacyValue(p.curIntervalNum) == 100
                
                earnedReward = p.numCorrectResp;
                
                p.curIntervalReward = earnedReward;
                p.rewardsToDraw = earnedReward;
                
                drawBanks(p,1)
                drawReward(p,p.yCenter+200);
                
                rewardRate = p.numCorrectResp / p.practice.interval.length(p.curIntervalNum);
                
                if length(p.rollingRewardWindow) < 10
                    p.rollingRewardWindow = [p.rollingRewardWindow, rewardRate];
                else
                    p.rollingRewardWindow = [p.rollingRewardWindow(2:10), rewardRate];
                end
                
            elseif p.practice.interval.efficacyValue(p.curIntervalNum) == 0
                
                if rand < .5
                    intervalBonus = ceil(p.numCorrectResp * 1.5);
                else
                    intervalBonus = floor(p.numCorrectResp * .5);
                end
                
                drawBanks(p,0)
                
                fbFile = imread('Images/Feedback/Rew1_Eff100_grey.jpg');
                p.feedbackTexture = Screen('MakeTexture',p.wPtr,fbFile);
                
                [p] = drawReward(p,p.yCenter+200);
                
                fbFile = imread('Images/Feedback/Rew1_Eff0.jpg');
                p.feedbackTexture = Screen('MakeTexture',p.wPtr,fbFile);
                
                randomReward = round(intervalBonus);
                
                p.curIntervalReward = randomReward;
                p.rewardsToDraw = randomReward;
                [p] = drawReward(p,p.yCenter-350);
                
            else
                earnedReward = p.numCorrectResp;
                
                try
                    randomReward = round(datasample(p.rollingRewardWindow, 1) * p.practice.interval.length(p.curIntervalNum));
                    randomReward = round(randomReward);
                catch
                    randomReward = p.numCorrectResp;
                end
                
                if rand < p.practice.interval.efficacyLevel(p.curIntervalNum)
                    
                    p.curIntervalReward = earnedReward;
                    
                    buttonImgFile = imread('Images/Feedback/Rew1_Eff100.jpg');
                    diceImgFile = imread('Images/Feedback/Rew1_Eff0_grey.jpg');
                    
                else
                    p.curIntervalReward = randomReward;
                    
                    buttonImgFile = imread('Images/Feedback/Rew1_Eff100_grey.jpg');
                    diceImgFile = imread('Images/Feedback/Rew1_Eff0.jpg');
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
                
            end
            Screen('TextSize',p.wPtr, 65);
            DrawFormattedText(p.wPtr,['+ ', num2str(p.curIntervalReward)],'center','center',p.color.white,70);
            
        end
    else
        Screen('TextSize',p.wPtr, 50);
        DrawFormattedText(p.wPtr,[num2str(p.curIntervalReward), ' Correct Responses'],'center','center',p.color.white,70);
    end
catch me
    sca
    keyboard
end

Screen(p.wPtr,'Flip');
WaitSecs(p.timing.fbDuration);


try
    practice.interval.IntervalCumRew(p.curIntervalNum) = p.curIntervalReward;
    practice.interval.TrialPerInterval(p.curIntervalNum) = p.curIntervalTrialNum;
    practice.interval.IntervalRew(p.curIntervalNum) = p.practice.interval.rewardLevel(p.curIntervalNum);
end

try
    saveResults(p,practice,results)
catch
    %save(fullfile([p.session.versionPath,'/Results'],['TSS_',p.subID,'_',p.date,'.mat']),'p','results','practice');
    save(fullfile([p.session.versionPath,'/Results'],['TSS_',p.session.versionPath,'_practice_',p.subID,'_',p.date,'.mat']),'p','practice','results');
end

%% ISI
fixation(p,p.color.white);
WaitSecs(p.timing.iti.preCue(p.curIntervalNum));


end

