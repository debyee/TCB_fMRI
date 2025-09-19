function [p] = setParams(p)

if ~p.restart % only set up params if not restarting (b/c if restarting want to keep old params)

%% Define Response Keys
if p.responseBox
    p.keyArrayStrVec = '1234';
else
    p.keyArrayStrVec = 'dfjk';
end


p.device.num.resp = -1;
p.initiateKey = 'space';
p.exptrKey = 'p';



%% Set Up Condition Variables
p.timing.intervalDurationOptions = linspace(p.timing.iti.intervalDurationMin, p.timing.iti.intervalDurationMax, p.timing.iti.intervalDurationBins);


%% Set Up Condition Matrix
%%% Note each matrix defines interval values according to the following structure:
%%% ROW 1: [reward level;
%%% ROW 2:  gain/loss;
%%% ROW 3:  efficacy level;
%%% ROW 4:  penalty level;
%%% ROW 5:  interval length (in seconds)]
%%% ROW 6:  cue image file (png)
%%% ROW 7:  feedback image file (png) - NOTE: can be 1 or 2 cells inside

timeDurationsMatrix = repmat(p.timing.intervalDurationOptions,1,ceil(p.numIntervalsPerBlock/p.timing.iti.intervalDurationBins));
timeDurationsMatrix = timeDurationsMatrix(1:(p.numIntervalsPerBlock));

% Define Low Reward Block -
lowRewMatrix = [zeros(1,(p.numIntervalsPerBlock));...
    zeros(1,(p.numIntervalsPerBlock/2)), ones(1,(p.numIntervalsPerBlock/2));...
    repmat([zeros(1,(p.numIntervalsPerBlock/4)), ones(1,(p.numIntervalsPerBlock/4))],1,2);...
    repmat([zeros(1,(p.numIntervalsPerBlock/8)), ones(1,(p.numIntervalsPerBlock/8))],1,4);...
    repmat(p.timing.intervalDurationOptions,1,p.numIntervalsPerBlock/p.timing.iti.intervalDurationBins);...
    ];
lowRewMatrix = num2cell(lowRewMatrix);
if p.session.isGainLoss 
    lowRewMatrix = [lowRewMatrix; repmat({[p.interval.cueFolder,'Loss1.png']},1,(p.numIntervalsPerBlock/2)),repmat({[p.interval.cueFolder,'Gain1.png']},1,(p.numIntervalsPerBlock/2))];
    lowRewMatrix = [lowRewMatrix; repmat({[p.interval.feedbackImageFolder,'Loss.png']},1,(p.numIntervalsPerBlock/2)),repmat({[p.interval.feedbackImageFolder,'Gain.png']},1,(p.numIntervalsPerBlock/2))];
elseif p.session.isEfficacy
    lowRewMatrix = [lowRewMatrix; repmat({[p.interval.cueFolder,'Rew1_Eff10.jpg']},1,(p.numIntervalsPerBlock/2)),repmat({[p.interval.cueFolder,'Rew1_Eff90.jpg']},1,(p.numIntervalsPerBlock/2))];
    lowRewMatrix = [lowRewMatrix; repmat({[p.interval.feedbackImageFolder,'Rew1_Eff0.jpg']},1,(p.numIntervalsPerBlock/2)),repmat({[p.interval.feedbackImageFolder,'Rew1_Eff0.jpg']},1,(p.numIntervalsPerBlock/2))]; 
elseif p.session.isRewardPenalty 
    if p.numIntervalsPerBlock == 8
        lowRewMatrix = [lowRewMatrix; repmat({[p.interval.cueFolder,'Rew1_Pen1.png'],[p.interval.cueFolder,'Rew1_Pen2.png']},1,(p.numIntervalsPerBlock/2))];
    elseif p.numIntervalsPerBlock == 16
        lowRewMatrix = [lowRewMatrix; repmat({[p.interval.cueFolder,'Rew1_Pen1.png'],[p.interval.cueFolder,'Rew1_Pen1.png'],...
        [p.interval.cueFolder,'Rew1_Pen2.png'],[p.interval.cueFolder,'Rew1_Pen2.png']},1,(p.numIntervalsPerBlock/4))];
    else
        error('Num Intervals Per Block Not 8 or 16! Check setParams.m');
    end
    lowRewMatrix = [lowRewMatrix; repmat({{[p.interval.feedbackImageFolder,'Gain.png'],[p.interval.feedbackImageFolder,'Penalty.png']}},1,(p.numIntervalsPerBlock))];
    %lowRewMatrix = [lowRewMatrix; repmat({[p.interval.feedbackImageFolder,'Gain.png'],1,p.numIntervalsPerBlock})]
elseif p.session.isLossPenalty
    if p.numIntervalsPerBlock == 8
        lowRewMatrix = [lowRewMatrix; repmat({[p.interval.cueFolder,'Loss1_Pen1.png'],[p.interval.cueFolder,'Loss1_Pen2.png']},1,(p.numIntervalsPerBlock/2))];
    elseif p.numIntervalsPerBlock == 16
        lowRewMatrix = [lowRewMatrix; repmat({[p.interval.cueFolder,'Loss1_Pen1.png'],[p.interval.cueFolder,'Loss1_Pen1.png'],...
            [p.interval.cueFolder,'Loss1_Pen2.png'],[p.interval.cueFolder,'Loss1_Pen2.png']},1,(p.numIntervalsPerBlock/4))];
    else
        error('Num Intervals Per Block Not 8 or 16! Check setParams.m');
    end
%     lowRewMatrix = [lowRewMatrix; repmat({[p.interval.cueFolder,'Loss1_Pen1.png'],[p.interval.cueFolder,'Loss1_Pen1.png'],...
%         [p.interval.cueFolder,'Loss1_Pen2.png'],[p.interval.cueFolder,'Loss1_Pen2.png']},1,(p.numIntervalsPerBlock/4))];
    lowRewMatrix = [lowRewMatrix; repmat({{[p.interval.feedbackImageFolder,'Gain.png'],[p.interval.feedbackImageFolder,'LossAvoid.png'],[p.interval.feedbackImageFolder,'Penalty.png']}},1,(p.numIntervalsPerBlock))];    
end

% Define High Reward Block
highRewMatrix = [ones(1,(p.numIntervalsPerBlock));...
    zeros(1,(p.numIntervalsPerBlock/2)), ones(1,(p.numIntervalsPerBlock/2));...
    repmat([zeros(1,(p.numIntervalsPerBlock/4)), ones(1,(p.numIntervalsPerBlock/4))],1,2);...
    repmat([zeros(1,(p.numIntervalsPerBlock/8)), ones(1,(p.numIntervalsPerBlock/8))],1,4);...
    repmat(p.timing.intervalDurationOptions,1,p.numIntervalsPerBlock/p.timing.iti.intervalDurationBins);...
    ];
highRewMatrix = num2cell(highRewMatrix);
if p.session.isGainLoss 
    highRewMatrix = [highRewMatrix; repmat({[p.interval.cueFolder,'Loss2.png']},1,(p.numIntervalsPerBlock/2)),repmat({[p.interval.cueFolder,'Gain2.png']},1,(p.numIntervalsPerBlock/2))];
    highRewMatrix = [highRewMatrix; repmat({[p.interval.feedbackImageFolder,'Loss.png']},1,(p.numIntervalsPerBlock/2)),repmat({[p.interval.feedbackImageFolder,'Gain.png']},1,(p.numIntervalsPerBlock/2))];
elseif p.session.isEfficacy 
    highRewMatrix = [highRewMatrix; repmat({[p.interval.cueFolder,'Rew2_Eff10.jpg']},1,(p.numIntervalsPerBlock/2)),repmat({[p.interval.cueFolder,'Rew2_Eff90.jpg']},1,(p.numIntervalsPerBlock/2))];
    highRewMatrix = [highRewMatrix; repmat({[p.interval.feedbackImageFolder,'Rew1_Eff0.jpg']},1,(p.numIntervalsPerBlock/2)),repmat({[p.interval.feedbackImageFolder,'Rew1_Eff0.jpg']},1,(p.numIntervalsPerBlock/2))];
elseif p.session.isRewardPenalty
    if p.numIntervalsPerBlock == 8
        highRewMatrix = [highRewMatrix; repmat({[p.interval.cueFolder,'Rew2_Pen1.png'],[p.interval.cueFolder,'Rew2_Pen2.png']},1,(p.numIntervalsPerBlock/2))];
    elseif p.numIntervalsPerBlock == 16
        highRewMatrix = [highRewMatrix; repmat({[p.interval.cueFolder,'Rew2_Pen1.png'],[p.interval.cueFolder,'Rew2_Pen1.png'], ...
        [p.interval.cueFolder,'Rew2_Pen2.png'],[p.interval.cueFolder,'Rew2_Pen2.png']},1,(p.numIntervalsPerBlock/4))];
    else
        error('Num Intervals Per Block Not 8 or 16! Check setParams.m');
    end
    highRewMatrix = [highRewMatrix; repmat({{[p.interval.feedbackImageFolder,'Gain.png'],[p.interval.feedbackImageFolder,'Penalty.png']}},1,(p.numIntervalsPerBlock))];
    %highRewMatrix = [highRewMatrix; repmat({[p.interval.feedbackImageFolder,'Gain.png']},1,(p.numIntervalsPerBlock/2)),repmat({[p.interval.feedbackImageFolder,'Gain.png']},1,(p.numIntervalsPerBlock/2))]; 
elseif p.session.isLossPenalty
    if p.numIntervalsPerBlock == 8
        highRewMatrix = [highRewMatrix; repmat({[p.interval.cueFolder,'Loss2_Pen1.png'],[p.interval.cueFolder,'Loss2_Pen2.png']},1,(p.numIntervalsPerBlock/2))];
    elseif p.numIntervalsPerBlock == 16
        highRewMatrix = [highRewMatrix; repmat({[p.interval.cueFolder,'Loss2_Pen1.png'],[p.interval.cueFolder,'Loss2_Pen1.png'], ...
        [p.interval.cueFolder,'Loss2_Pen2.png'],[p.interval.cueFolder,'Loss2_Pen2.png']},1,(p.numIntervalsPerBlock/4))];
    else
        error('Num Intervals Per Block Not 8 or 16! Check setParams.m');
    end
    highRewMatrix = [highRewMatrix; repmat({{[p.interval.feedbackImageFolder,'Gain.png'],[p.interval.feedbackImageFolder,'LossAvoid.png'],[p.interval.feedbackImageFolder,'Penalty.png']}},1,(p.numIntervalsPerBlock))];
end


% Define Loss Block
lossMatrix = [zeros(1,(p.numIntervalsPerBlock/2)), ones(1,(p.numIntervalsPerBlock/2));...
    zeros(1,(p.numIntervalsPerBlock));...
    repmat([zeros(1,(p.numIntervalsPerBlock/4)), ones(1,(p.numIntervalsPerBlock/4))],1,2);...
    repmat([zeros(1,(p.numIntervalsPerBlock/8)), ones(1,(p.numIntervalsPerBlock/8))],1,4);...
    repmat(p.timing.intervalDurationOptions,1,p.numIntervalsPerBlock/p.timing.iti.intervalDurationBins);...
    ];
lossMatrix = num2cell(lossMatrix);
lossMatrix = [lossMatrix; repmat({[p.interval.cueFolder,'Loss1.png']},1,(p.numIntervalsPerBlock/2)),repmat({[p.interval.cueFolder,'Loss2.png']},1,(p.numIntervalsPerBlock/2))];
lossMatrix = [lossMatrix; repmat({[p.interval.feedbackImageFolder,'Loss.png']},1,(p.numIntervalsPerBlock))];


% Define Gain Block
gainMatrix = [zeros(1,(p.numIntervalsPerBlock/2)), ones(1,(p.numIntervalsPerBlock/2));...
    ones(1,(p.numIntervalsPerBlock));...
    repmat([zeros(1,(p.numIntervalsPerBlock/4)), ones(1,(p.numIntervalsPerBlock/4))],1,2);...
    repmat([zeros(1,(p.numIntervalsPerBlock/8)), ones(1,(p.numIntervalsPerBlock/8))],1,4);...
    repmat(p.timing.intervalDurationOptions,1,p.numIntervalsPerBlock/p.timing.iti.intervalDurationBins);...
    ];
gainMatrix = num2cell(gainMatrix);
gainMatrix = [gainMatrix; repmat({[p.interval.cueFolder,'Gain1.png']},1,(p.numIntervalsPerBlock/2)),repmat({[p.interval.cueFolder,'Gain2.png']},1,(p.numIntervalsPerBlock/2))];
gainMatrix = [gainMatrix; repmat({[p.interval.feedbackImageFolder,'Gain.png']},1,p.numIntervalsPerBlock)];


% Define Low Efficacy Block
lowEffMatrix = [zeros(1,(p.numIntervalsPerBlock/2)), ones(1,(p.numIntervalsPerBlock/2));...
    repmat([zeros(1,(p.numIntervalsPerBlock/4)), ones(1,(p.numIntervalsPerBlock/4))],1,2);...
    zeros(1,(p.numIntervalsPerBlock));...
    repmat([zeros(1,(p.numIntervalsPerBlock/8)), ones(1,(p.numIntervalsPerBlock/8))],1,4);...
    repmat(p.timing.intervalDurationOptions,1,p.numIntervalsPerBlock/p.timing.iti.intervalDurationBins);...
    ];
lowEffMatrix = num2cell(lowEffMatrix);
lowEffMatrix = [lowEffMatrix; repmat({[p.interval.cueFolder,'Rew1_Eff10.jpg']},1,(p.numIntervalsPerBlock/2)),repmat({[p.interval.cueFolder,'Rew2_Eff10.jpg']},1,(p.numIntervalsPerBlock/2))];
lowEffMatrix = [lowEffMatrix; repmat({[p.interval.feedbackImageFolder,'Rew1_Eff0.jpg']},1,(p.numIntervalsPerBlock))];


% Define High Efficacy Block
highEffMatrix = [zeros(1,(p.numIntervalsPerBlock/2)), ones(1,(p.numIntervalsPerBlock/2));...
    repmat([zeros(1,(p.numIntervalsPerBlock/4)), ones(1,(p.numIntervalsPerBlock/4))],1,2);...
    ones(1,(p.numIntervalsPerBlock));...
    repmat([zeros(1,(p.numIntervalsPerBlock/8)), ones(1,(p.numIntervalsPerBlock/8))],1,4);...
    repmat(p.timing.intervalDurationOptions,1,p.numIntervalsPerBlock/p.timing.iti.intervalDurationBins);...
    ];
highEffMatrix = num2cell(highEffMatrix);
highEffMatrix = [highEffMatrix; repmat({[p.interval.cueFolder,'Rew1_Eff90.jpg']},1,(p.numIntervalsPerBlock/2)),repmat({[p.interval.cueFolder,'Rew2_Eff90.jpg']},1,(p.numIntervalsPerBlock/2))];
highEffMatrix = [highEffMatrix; repmat({[p.interval.feedbackImageFolder,'Rew1_Eff0.jpg']},1,(p.numIntervalsPerBlock))];


% Define Low Penalty Block
lowPenMatrix = [zeros(1,(p.numIntervalsPerBlock/2)), ones(1,(p.numIntervalsPerBlock/2));...
    repmat([zeros(1,(p.numIntervalsPerBlock/4)), ones(1,(p.numIntervalsPerBlock/4))],1,2);...
    repmat([zeros(1,(p.numIntervalsPerBlock/8)), ones(1,(p.numIntervalsPerBlock/8))],1,4);...
    zeros(1,(p.numIntervalsPerBlock));...
    repmat(p.timing.intervalDurationOptions,1,p.numIntervalsPerBlock/p.timing.iti.intervalDurationBins);... 
    %timeDurationsMatrix(randperm(length(timeDurationsMatrix)));...
    ];
lowPenMatrix = num2cell(lowPenMatrix);
if p.session.isRewardPenalty
    lowPenMatrix = [lowPenMatrix; repmat({[p.interval.cueFolder,'Rew1_Pen1.png']},1,(p.numIntervalsPerBlock/2)),repmat({[p.interval.cueFolder,'Rew2_Pen1.png']},1,(p.numIntervalsPerBlock/2))];
    lowPenMatrix = [lowPenMatrix; repmat({{[p.interval.feedbackImageFolder,'Gain.png'],[p.interval.feedbackImageFolder,'Penalty.png']}},1,(p.numIntervalsPerBlock))];
    %lowPenMatrix = [lowPenMatrix; repmat({[p.interval.feedbackImageFolder,'Gain.png']},1,(p.numIntervalsPerBlock))];
elseif p.session.isLossPenalty
    lowPenMatrix = [lowPenMatrix; repmat({[p.interval.cueFolder,'Loss1_Pen1.png']},1,(p.numIntervalsPerBlock/2)),repmat({[p.interval.cueFolder,'Loss2_Pen1.png']},1,(p.numIntervalsPerBlock/2))];
    lowPenMatrix = [lowPenMatrix; repmat({{[p.interval.feedbackImageFolder,'Gain.png'],[p.interval.feedbackImageFolder,'LossAvoid.png'],[p.interval.feedbackImageFolder,'Penalty.png']}},1,(p.numIntervalsPerBlock))];
end

% Define High Penalty Block
highPenMatrix = [zeros(1,(p.numIntervalsPerBlock/2)), ones(1,(p.numIntervalsPerBlock/2));...
    repmat([zeros(1,(p.numIntervalsPerBlock/4)), ones(1,(p.numIntervalsPerBlock/4))],1,2);...
    repmat([zeros(1,(p.numIntervalsPerBlock/8)), ones(1,(p.numIntervalsPerBlock/8))],1,4);...
    ones(1,(p.numIntervalsPerBlock));...
    repmat(p.timing.intervalDurationOptions,1,p.numIntervalsPerBlock/p.timing.iti.intervalDurationBins);... 
    %timeDurationsMatrix(randperm(length(timeDurationsMatrix)));...
    ];
highPenMatrix = num2cell(highPenMatrix);
if p.session.isRewardPenalty
    highPenMatrix = [highPenMatrix; repmat({[p.interval.cueFolder,'Rew1_Pen2.png']},1,(p.numIntervalsPerBlock/2)),repmat({[p.interval.cueFolder,'Rew2_Pen2.png']},1,(p.numIntervalsPerBlock/2))];
    highPenMatrix = [highPenMatrix; repmat({{[p.interval.feedbackImageFolder,'Gain.png'],[p.interval.feedbackImageFolder,'Penalty.png']}},1,(p.numIntervalsPerBlock))];
    %highPenMatrix = [highPenMatrix; repmat({[p.interval.feedbackImageFolder,'Gain.png']},1,(p.numIntervalsPerBlock))];
elseif p.session.isLossPenalty
    highPenMatrix = [highPenMatrix; repmat({[p.interval.cueFolder,'Loss1_Pen2.png']},1,(p.numIntervalsPerBlock/2)),repmat({[p.interval.cueFolder,'Loss2_Pen2.png']},1,(p.numIntervalsPerBlock/2))];
    highPenMatrix = [highPenMatrix; repmat({{[p.interval.feedbackImageFolder,'Gain.png'],[p.interval.feedbackImageFolder,'LossAvoid.png'],[p.interval.feedbackImageFolder,'Penalty.png']}},1,(p.numIntervalsPerBlock))];
end


%% Create Session Matrix (Based on Values in setVersion.m)
counterbalanceMatrix = [];
p.blockOrder = {};

if p.session.isGainLoss == 1
    % Session Matrix
    for i = 1:(p.numBlocks/4)
        
        % Randomize blocks
        lowRewMatrix = lowRewMatrix(:,randperm(size(lowRewMatrix,2)));
        highRewMatrix = highRewMatrix(:,randperm(size(highRewMatrix,2)));
        lossMatrix = lossMatrix(:,randperm(size(lossMatrix,2)));
        gainMatrix = gainMatrix(:,randperm(size(gainMatrix,2)));
        
        
        switch mod(p.subIDNum,4)
            case 0
                counterbalanceMatrix = [counterbalanceMatrix, lowRewMatrix, highRewMatrix, lossMatrix, gainMatrix];
                p.blockOrder{end+1} = 'lowRew';
                p.blockOrder{end+1} = 'highRew';
                p.blockOrder{end+1} = 'loss';
                p.blockOrder{end+1} = 'gain';
            case 1
                counterbalanceMatrix = [counterbalanceMatrix, lossMatrix, gainMatrix, lowRewMatrix, highRewMatrix];
                p.blockOrder{end+1} = 'loss';
                p.blockOrder{end+1} = 'gain';
                p.blockOrder{end+1} = 'lowRew';
                p.blockOrder{end+1} = 'highRew';
            case 2
                counterbalanceMatrix = [counterbalanceMatrix, highRewMatrix, lowRewMatrix, gainMatrix, lossMatrix];
                p.blockOrder{end+1} = 'highRew';
                p.blockOrder{end+1} = 'lowRew';
                p.blockOrder{end+1} = 'gain';
                p.blockOrder{end+1} = 'loss';
            case 3
                counterbalanceMatrix = [counterbalanceMatrix, gainMatrix, lossMatrix, highRewMatrix, lowRewMatrix];
                p.blockOrder{end+1} = 'gain';
                p.blockOrder{end+1} = 'loss';
                p.blockOrder{end+1} = 'highRew';
                p.blockOrder{end+1} = 'lowRew';
        end
    end

elseif p.session.isEfficacy == 1
    for i = 1:(p.numBlocks/4)
        
        % Randomize blocks
        lowRewMatrix = lowRewMatrix(:,randperm(size(lowRewMatrix,2)));
        highRewMatrix = highRewMatrix(:,randperm(size(highRewMatrix,2)));
        lowEffMatrix = lowEffMatrix(:,randperm(size(lowEffMatrix,2)));
        highEffMatrix = highEffMatrix(:,randperm(size(highEffMatrix,2)));
        
        
        switch mod(p.subIDNum,4)
            case 0
                counterbalanceMatrix = [counterbalanceMatrix, lowRewMatrix, highRewMatrix, lowEffMatrix, highEffMatrix];
                p.blockOrder{end+1} = 'lowRew';
                p.blockOrder{end+1} = 'highRew';
                p.blockOrder{end+1} = 'lowEff';
                p.blockOrder{end+1} = 'highEff';
            case 1
                counterbalanceMatrix = [counterbalanceMatrix, lowEffMatrix, highEffMatrix, lowRewMatrix, highRewMatrix];
                p.blockOrder{end+1} = 'lowEff';
                p.blockOrder{end+1} = 'highEff';
                p.blockOrder{end+1} = 'lowRew';
                p.blockOrder{end+1} = 'highRew';
            case 2
                counterbalanceMatrix = [counterbalanceMatrix, highRewMatrix, lowRewMatrix, highEffMatrix, lowEffMatrix];
                p.blockOrder{end+1} = 'highRew';
                p.blockOrder{end+1} = 'lowRew';
                p.blockOrder{end+1} = 'highEff';
                p.blockOrder{end+1} = 'lowEff';
            case 3
                counterbalanceMatrix = [counterbalanceMatrix, highEffMatrix, lowEffMatrix, highRewMatrix, lowRewMatrix];
                p.blockOrder{end+1} = 'highEff';
                p.blockOrder{end+1} = 'lowEff';
                p.blockOrder{end+1} = 'highRew';
                p.blockOrder{end+1} = 'lowRew';
        end
    end

elseif p.session.isRewardPenalty == 1 || p.session.isLossPenalty
    for i = 1:(p.numBlocks/4)
        
        % Randomize blocks
        lowRewMatrix = lowRewMatrix(:,randperm(size(lowRewMatrix,2)));
        highRewMatrix = highRewMatrix(:,randperm(size(highRewMatrix,2)));
        lowPenMatrix = lowPenMatrix(:,randperm(size(lowPenMatrix,2)));
        highPenMatrix = highPenMatrix(:,randperm(size(highPenMatrix,2)));
        
   
        switch mod(p.subIDNum,4)
            case 0
                counterbalanceMatrix = [counterbalanceMatrix, lowRewMatrix, highRewMatrix, lowPenMatrix, highPenMatrix];
                p.blockOrder{end+1} = 'lowRew';
                p.blockOrder{end+1} = 'highRew';
                p.blockOrder{end+1} = 'lowPen';
                p.blockOrder{end+1} = 'highPen';
            case 1
                counterbalanceMatrix = [counterbalanceMatrix, lowPenMatrix, highPenMatrix, lowRewMatrix, highRewMatrix];
                p.blockOrder{end+1} = 'lowPen';
                p.blockOrder{end+1} = 'highPen';
                p.blockOrder{end+1} = 'lowRew';
                p.blockOrder{end+1} = 'highRew';
            case 2
                counterbalanceMatrix = [counterbalanceMatrix, highRewMatrix, lowRewMatrix, highPenMatrix, lowPenMatrix];
                p.blockOrder{end+1} = 'highRew';
                p.blockOrder{end+1} = 'lowRew';
                p.blockOrder{end+1} = 'highPen';
                p.blockOrder{end+1} = 'lowPen';
            case 3
                counterbalanceMatrix = [counterbalanceMatrix, highPenMatrix, lowPenMatrix, highRewMatrix, lowRewMatrix];
                p.blockOrder{end+1} = 'highPen';
                p.blockOrder{end+1} = 'lowPen';
                p.blockOrder{end+1} = 'highRew';
                p.blockOrder{end+1} = 'lowRew';
        end
    end
    
end

% Interval reward level (0 = low, 1 = high -- these are relative levels, exact values determined in setVersion.m)
p.interval.rewardLevel = cell2mat(counterbalanceMatrix(1,:));
p.interval.rewardValue = nan(1, p.numIntervals);
p.interval.rewardValue(p.interval.rewardLevel == 0) = p.stimulus.rewardValues(1);
p.interval.rewardValue(p.interval.rewardLevel == 1) = p.stimulus.rewardValues(2);
if p.stimulus.rewardValues(1) == p.stimulus.rewardValues(2)
    p.interval.rewardLevel = nan(1, p.numIntervals);
end

% Interval gain/loss level (0 = loss, 1 = gain)
p.interval.gainLevel = cell2mat(counterbalanceMatrix(2,:));
p.interval.gainValue = nan(1, p.numIntervals);
p.interval.gainValue(p.interval.gainLevel == 0) = p.stimulus.gainValues(1);
p.interval.gainValue(p.interval.gainLevel == 1) = p.stimulus.gainValues(2);
if p.stimulus.gainValues(1) == p.stimulus.gainValues(2)
    p.interval.gainLevel = nan(1, p.numIntervals);
end

% Interval efficacy level (0 = low, 1 = high -- these are relative levels, exact values determined in setVersion.m)
p.interval.efficacyLevel = cell2mat(counterbalanceMatrix(3,:));
p.interval.efficacyValue = nan(1, p.numIntervals);
p.interval.efficacyValue(p.interval.efficacyLevel == 0) = p.stimulus.efficacyValues(1);
p.interval.efficacyValue(p.interval.efficacyLevel == 1) = p.stimulus.efficacyValues(2);
if p.stimulus.efficacyValues(1) == p.stimulus.efficacyValues(2)
    p.interval.efficacyLevel = nan(1, p.numIntervals);
end

% Interval penalty level (0 = low, 1 = high -- these are relative levels, exact values determined in setVersion.m)
p.interval.penaltyLevel = cell2mat(counterbalanceMatrix(4,:));
p.interval.penaltyValue = nan(1, p.numIntervals);
p.interval.penaltyValue(p.interval.penaltyLevel == 0) = p.stimulus.penaltyValues(1);
p.interval.penaltyValue(p.interval.penaltyLevel == 1) = p.stimulus.penaltyValues(2);
if p.stimulus.penaltyValues(1) == p.stimulus.penaltyValues(2)
    p.interval.penaltyLevel = nan(1, p.numIntervals);
end

% Interval length in seconds
p.interval.length = cell2mat(counterbalanceMatrix(5,:));

% Interval cue file
p.interval.cueImage = counterbalanceMatrix(6,:);

% Interval feedback image file
p.interval.feedbackImage = counterbalanceMatrix(7,:);


%% Set Up PRACTICE Condition Matrix
% Define Gain Practice Block
gainPracticeMatrix = [zeros(1,(p.numPracIntervals/2)), ones(1,(p.numPracIntervals/2));...
    ones(1,p.numPracIntervals);...
    zeros(1,p.numPracIntervals);...
    zeros(1,p.numPracIntervals);...
    repmat(p.timing.intervalDurationOptions,1,p.numPracIntervals/p.timing.iti.intervalDurationBins);...
    ];
gainPracticeMatrix = num2cell(gainPracticeMatrix);
gainPracticeMatrix = [gainPracticeMatrix; repmat({[p.interval.cueFolder,'Gain1.png']},1,(p.numPracIntervals/2)), repmat({[p.interval.cueFolder,'Gain2.png']},1,(p.numPracIntervals/2))];
gainPracticeMatrix = [gainPracticeMatrix; repmat({[p.interval.feedbackImageFolder,'Gain.png']},1,p.numPracIntervals)];


% Define Loss Practice Block
lossPracticeMatrix = [zeros(1,(p.numPracIntervals/2)), ones(1,(p.numPracIntervals/2));...
    zeros(1,p.numPracIntervals);...
    zeros(1,p.numPracIntervals);...
    zeros(1,p.numPracIntervals);...
    repmat(p.timing.intervalDurationOptions,1,p.numPracIntervals/p.timing.iti.intervalDurationBins);...
    ];
lossPracticeMatrix = num2cell(lossPracticeMatrix);
lossPracticeMatrix = [lossPracticeMatrix; repmat({[p.interval.cueFolder,'Loss1.png']},1,(p.numPracIntervals/2)), repmat({[p.interval.cueFolder,'Loss2.png']},1,(p.numPracIntervals/2))];
lossPracticeMatrix = [lossPracticeMatrix; repmat({[p.interval.feedbackImageFolder,'Loss.png']},1,p.numPracIntervals)];


% Define Low Efficacy Practice Block
lowEffPracticeMatrix = [zeros(1,p.numPracIntervals);...
    zeros(1,p.numPracIntervals);...
    ones(1,p.numPracIntervals).*2;...
    zeros(1,p.numPracIntervals);...
    repmat(p.timing.intervalDurationOptions,1,p.numPracIntervals/p.timing.iti.intervalDurationBins);...
    ];
lowEffPracticeMatrix = num2cell(lowEffPracticeMatrix);
lowEffPracticeMatrix = [lowEffPracticeMatrix; repmat({[p.interval.cueFolder,'Loss1.png']},1,(p.numPracIntervals/2)), repmat({[p.interval.cueFolder,'Loss2.png']},1,(p.numPracIntervals/2))];
lowEffPracticeMatrix = [lowEffPracticeMatrix; repmat({[p.interval.feedbackImageFolder,'Loss.png']},1,p.numPracIntervals)];


% Define High Efficacy Practice Block
highEffPracticeMatrix = [zeros(1,p.numPracIntervals);...
    zeros(1,p.numPracIntervals);...
    ones(1,p.numPracIntervals).*3;...
    zeros(1,p.numPracIntervals);...
    repmat(p.timing.intervalDurationOptions,1,p.numPracIntervals/p.timing.iti.intervalDurationBins);...
    ];
highEffPracticeMatrix = num2cell(highEffPracticeMatrix);
highEffPracticeMatrix = [highEffPracticeMatrix; repmat({[p.interval.cueFolder,'Gain1.png']},1,(p.numPracIntervals/2)), repmat({[p.interval.cueFolder,'Gain2.png']},1,(p.numPracIntervals/2))];
highEffPracticeMatrix = [highEffPracticeMatrix; repmat({[p.interval.feedbackImageFolder,'Gain.png']},1,p.numPracIntervals)];


% Define Mixed Efficacy Practice Block
mixedEffPracticeMatrix = [zeros(1,p.numPracIntervals);...
    zeros(1,p.numPracIntervals);...
    ones(1,(p.numPracIntervals/2)), zeros(1,(p.numPracIntervals/2));...
    zeros(1,p.numPracIntervals);...
    repmat(p.timing.intervalDurationOptions,1,p.numPracIntervals/p.timing.iti.intervalDurationBins);...
    ];
mixedEffPracticeMatrix = num2cell(mixedEffPracticeMatrix);
mixedEffPracticeMatrix = [mixedEffPracticeMatrix; repmat({[p.interval.cueFolder,'Gain1.png']},1,p.numPracIntervals)];
mixedEffPracticeMatrix = [mixedEffPracticeMatrix; repmat({[p.interval.feedbackImageFolder,'Gain.png']},1,p.numPracIntervals)];

 
% Define Low Penalty Block
lowPenPracticeMatrix = [zeros(1,(p.numPracIntervals/2)), ones(1,(p.numPracIntervals/2));...
    zeros(1,p.numPracIntervals);...
    zeros(1,p.numPracIntervals);...
    zeros(1,p.numPracIntervals);...
    repmat(p.timing.intervalDurationOptions,1,p.numPracIntervals/p.timing.iti.intervalDurationBins);...
    ];
lowPenPracticeMatrix = num2cell(lowPenPracticeMatrix);
if p.session.isRewardPenalty
    lowPenPracticeMatrix = [lowPenPracticeMatrix; repmat({[p.interval.cueFolder,'Rew1_Pen1.png']},1,(p.numPracIntervals/2)), repmat({[p.interval.cueFolder,'Rew2_Pen1.png']},1,(p.numPracIntervals/2))];
    lowPenPracticeMatrix = [lowPenPracticeMatrix; repmat({{[p.interval.feedbackImageFolder,'Gain.png'],[p.interval.feedbackImageFolder,'Penalty.png']}},1,p.numPracIntervals)];
    %lowPenPracticeMatrix = [lowPenPracticeMatrix; repmat({[p.interval.feedbackImageFolder,'Gain.png']},1,p.numPracIntervals)];
elseif p.session.isLossPenalty
    lowPenPracticeMatrix = [lowPenPracticeMatrix; repmat({[p.interval.cueFolder,'Loss1_Pen1.png']},1,(p.numPracIntervals/2)), repmat({[p.interval.cueFolder,'Loss2_Pen1.png']},1,(p.numPracIntervals/2))];
    lowPenPracticeMatrix = [lowPenPracticeMatrix; repmat({{[p.interval.feedbackImageFolder,'Gain.png'],[p.interval.feedbackImageFolder,'LossAvoid.png'],[p.interval.feedbackImageFolder,'Penalty.png']}},1,p.numPracIntervals)];
end

% Define High Penalty Block
highPenPracticeMatrix = [zeros(1,(p.numPracIntervals/2)), ones(1,(p.numPracIntervals/2));...
    zeros(1,p.numPracIntervals);...
    zeros(1,p.numPracIntervals);...
    ones(1,p.numPracIntervals);...
    repmat(p.timing.intervalDurationOptions,1,p.numPracIntervals/p.timing.iti.intervalDurationBins);...
    ];
highPenPracticeMatrix = num2cell(highPenPracticeMatrix);
if p.session.isRewardPenalty
    highPenPracticeMatrix = [highPenPracticeMatrix; repmat({[p.interval.cueFolder,'Rew1_Pen2.png']},1,(p.numPracIntervals/2)), repmat({[p.interval.cueFolder,'Rew2_Pen2.png']},1,(p.numPracIntervals/2))];
    highPenPracticeMatrix = [highPenPracticeMatrix; repmat({{[p.interval.feedbackImageFolder,'Gain.png'],[p.interval.feedbackImageFolder,'Penalty.png']}},1,p.numPracIntervals)];
    %highPenPracticeMatrix = [highPenPracticeMatrix; repmat({[p.interval.feedbackImageFolder,'Gain.png']},1,p.numPracIntervals)];
elseif p.session.isLossPenalty
    highPenPracticeMatrix = [highPenPracticeMatrix; repmat({[p.interval.cueFolder,'Loss1_Pen2.png']},1,(p.numPracIntervals/2)), repmat({[p.interval.cueFolder,'Loss2_Pen2.png']},1,(p.numPracIntervals/2))];
    highPenPracticeMatrix = [highPenPracticeMatrix; repmat({{[p.interval.feedbackImageFolder,'Gain.png'],[p.interval.feedbackImageFolder,'LossAvoid.png'],[p.interval.feedbackImageFolder,'Penalty.png']}},1,p.numPracIntervals)];
end


% Define Low Reward Mixed Penalty 
lowRewPracticeMatrix = [zeros(1,(p.numPracIntervals));...
    zeros(1,p.numPracIntervals);...
    zeros(1,p.numPracIntervals);...
    zeros(1,(p.numPracIntervals/2)), ones(1,(p.numPracIntervals/2));...
    repmat(p.timing.intervalDurationOptions,1,p.numPracIntervals/p.timing.iti.intervalDurationBins);...
    ];
lowRewPracticeMatrix = num2cell(lowRewPracticeMatrix);
if p.session.isRewardPenalty 
    lowRewPracticeMatrix = [lowRewPracticeMatrix; repmat({[p.interval.cueFolder,'Rew1_Pen1.png']},1,(p.numPracIntervals/2)), repmat({[p.interval.cueFolder,'Rew1_Pen2.png']},1,(p.numPracIntervals/2))];
    lowRewPracticeMatrix = [lowRewPracticeMatrix; repmat({{[p.interval.feedbackImageFolder,'Gain.png'],[p.interval.feedbackImageFolder,'Penalty.png']}},1,p.numPracIntervals)];
    %lowRewMixedPenPracticeMatrix = [lowRewMixedPenPracticeMatrix; repmat({[p.interval.feedbackImageFolder,'Gain.png']},1,p.numPracIntervals)];
elseif p.session.isLossPenalty
    lowRewPracticeMatrix = [lowRewPracticeMatrix; repmat({[p.interval.cueFolder,'Loss1_Pen1.png']},1,(p.numPracIntervals/2)), repmat({[p.interval.cueFolder,'Loss1_Pen2.png']},1,(p.numPracIntervals/2))];
    lowRewPracticeMatrix = [lowRewPracticeMatrix; repmat({{[p.interval.feedbackImageFolder,'Gain.png'],[p.interval.feedbackImageFolder,'LossAvoid.png'],[p.interval.feedbackImageFolder,'Penalty.png']}},1,p.numPracIntervals)];
end

% Define High Reward Mixed Penalty Block
highRewPracticeMatrix = [ones(1,(p.numPracIntervals));...
    zeros(1,p.numPracIntervals);...
    zeros(1,p.numPracIntervals);...
    zeros(1,(p.numPracIntervals/2)), ones(1,(p.numPracIntervals/2));...
    repmat(p.timing.intervalDurationOptions,1,p.numPracIntervals/p.timing.iti.intervalDurationBins);...
    ];
highRewPracticeMatrix = num2cell(highRewPracticeMatrix);
if p.session.isRewardPenalty
    highRewPracticeMatrix = [highRewPracticeMatrix; repmat({[p.interval.cueFolder,'Rew2_Pen1.png']},1,(p.numPracIntervals/2)), repmat({[p.interval.cueFolder,'Rew2_Pen2.png']},1,(p.numPracIntervals/2))];
    highRewPracticeMatrix = [highRewPracticeMatrix; repmat({{[p.interval.feedbackImageFolder,'Gain.png'],[p.interval.feedbackImageFolder,'Penalty.png']}},1,p.numPracIntervals)];
    %lowRewMixedPenPracticeMatrix = [lowRewMixedPenPracticeMatrix; repmat({[p.interval.feedbackImageFolder,'Gain.png']},1,p.numPracIntervals)];
elseif p.session.isLossPenalty
    highRewPracticeMatrix = [highRewPracticeMatrix; repmat({[p.interval.cueFolder,'Loss2_Pen1.png']},1,(p.numPracIntervals/2)), repmat({[p.interval.cueFolder,'Loss2_Pen2.png']},1,(p.numPracIntervals/2))];
    highRewPracticeMatrix = [highRewPracticeMatrix; repmat({{[p.interval.feedbackImageFolder,'Gain.png'],[p.interval.feedbackImageFolder,'LossAvoid.png'],[p.interval.feedbackImageFolder,'Penalty.png']}},1,p.numPracIntervals)];
end

% Create Practice Matrix
if p.session.isGainLoss == 1
    % Create Practice Matrix - order always gain then loss (but randomized within each set
    gainPracticeMatrix = gainPracticeMatrix(:,randperm(size(gainPracticeMatrix,2)));
    lossPracticeMatrix = lossPracticeMatrix(:,randperm(size(lossPracticeMatrix,2)));
    counterbalancePracticeMatrix = [gainPracticeMatrix, lossPracticeMatrix];
elseif p.session.isEfficacy == 1
    % Create Practice Matrix - order always gain then loss
    counterbalancePracticeMatrix = [highEffPracticeMatrix, lowEffPracticeMatrix, mixedEffPracticeMatrix];
elseif p.session.isRewardPenalty == 1 || p.session.isLossPenalty == 1 
    % Create Practice Matrix - order always low then high penalty
    lowRewPracticeMatrix = lowRewPracticeMatrix(:,randperm(size(lowRewPracticeMatrix,2)));
    highRewPracticeMatrix = highRewPracticeMatrix(:,randperm(size(lowRewPracticeMatrix,2)));
    lowPenPracticeMatrix = lowPenPracticeMatrix(:,randperm(size(lowPenPracticeMatrix,2)));
    highPenPracticeMatrix = highPenPracticeMatrix(:,randperm(size(highPenPracticeMatrix,2)));
    %counterbalancePracticeMatrix = [lowRewPracticeMatrix, highRewPracticeMatrix, lowPenPracticeMatrix, highPenPracticeMatrix];
    counterbalancePracticeMatrix = [lowPenPracticeMatrix, highPenPracticeMatrix, lowRewPracticeMatrix, highRewPracticeMatrix];
    %counterbalancePracticeMatrix = lowRewMixedPenPracticeMatrix(:,randperm(size(lowRewMixedPenPracticeMatrix,2)));
% elseif p.session.isLossPenalty == 1
%     % Create Practice Matrix - order always low then high 
%     lowRewPracticeMatrix = lowRewPracticeMatrix(:,randperm(size(lowRewPracticeMatrix,2)));
%     highRewPracticeMatrix = highRewPracticeMatrix(:,randperm(size(lowRewPracticeMatrix,2)));
%     lowPenPracticeMatrix = lowPenPracticeMatrix(:,randperm(size(lowPenPracticeMatrix,2)));
%     highPenPracticeMatrix = highPenPracticeMatrix(:,randperm(size(highPenPracticeMatrix,2)));
%     counterbalancePracticeMatrix = [lowRewPracticeMatrix, highRewPracticeMatrix, lowPenPracticeMatrix, highPenPracticeMatrix];
end


% Practice interval reward level (0 = low, 1 = high -- these are relative levels, exact values determined in setVersion.m)
p.practice.interval.rewardLevel = cell2mat(counterbalancePracticeMatrix(1,:));
p.practice.interval.rewardValue = nan(1, p.numPracIntervals);
p.practice.interval.rewardValue(p.practice.interval.rewardLevel == 0) = p.stimulus.rewardValues(1);
p.practice.interval.rewardValue(p.practice.interval.rewardLevel == 1) = p.stimulus.rewardValues(2);
if p.stimulus.rewardValues(1) == p.stimulus.rewardValues(2)
    p.practice.interval.rewardLevel = nan(1, p.numIntervals);
end

% Practice interval gain/loss level (0 = loss, 1 = gain)
p.practice.interval.gainLevel = cell2mat(counterbalancePracticeMatrix(2,:));
p.practice.interval.gainValue = nan(1, p.numPracIntervals);
p.practice.interval.gainValue(p.practice.interval.gainLevel == 0) = p.stimulus.gainValues(1);
p.practice.interval.gainValue(p.practice.interval.gainLevel == 1) = p.stimulus.gainValues(2);
if p.stimulus.gainValues(1) == p.stimulus.gainValues(2)
    p.practice.interval.gainLevel = nan(1, p.numIntervals);
end

% Practice interval efficacy level (0 = low, 1 = high; for practice 2 = none, 3 = full)
p.practice.interval.efficacyLevel = cell2mat(counterbalancePracticeMatrix(3,:));
p.practice.interval.efficacyValue = nan(1, p.numPracIntervals);
p.practice.interval.efficacyValue(p.practice.interval.efficacyLevel == 0) = p.stimulus.efficacyValues(1);
p.practice.interval.efficacyValue(p.practice.interval.efficacyLevel == 1) = p.stimulus.efficacyValues(2);
if p.session.isEfficacy
    p.practice.interval.efficacyValue(p.practice.interval.efficacyLevel == 2) = p.stimulus.practiceEfficacyValues(1);
    p.practice.interval.efficacyValue(p.practice.interval.efficacyLevel == 3) = p.stimulus.practiceEfficacyValues(2);
end
if p.stimulus.efficacyValues(1) == p.stimulus.efficacyValues(2)
    p.practice.interval.efficacyLevel = nan(1, p.numIntervals);
end

% Practice interval penalty level (0 = low, 1 = high -- these are relative levels, exact values determined in setVersion.m)
p.practice.interval.penaltyLevel = cell2mat(counterbalancePracticeMatrix(4,:));
p.practice.interval.penaltyValue = nan(1, p.numPracIntervals);
p.practice.interval.penaltyValue(p.practice.interval.penaltyLevel == 0) = p.stimulus.penaltyValues(1);
p.practice.interval.penaltyValue(p.practice.interval.penaltyLevel == 1) = p.stimulus.penaltyValues(2);
if p.stimulus.penaltyValues(1) == p.stimulus.penaltyValues(2)
    p.practice.interval.penaltyLevel = nan(1, p.numIntervals);
end

% Practice interval length in seconds
p.practice.interval.length = cell2mat(counterbalancePracticeMatrix(5,:));

% Practice interval cue file
p.practice.interval.cueImage = counterbalancePracticeMatrix(6,:);

% Practice interval feedback image file
p.practice.interval.feedbackImage = counterbalancePracticeMatrix(7,:);

%% Timing Jitter

% Psuedorandomize ITIs
numReps = ceil(p.numIntervals / p.timing.iti.preCueBins);
iti = repmat(linspace(p.timing.iti.preCueMin, p.timing.iti.preCueMax, p.timing.iti.preCueBins), 1, numReps);
p.timing.iti.preCue = iti(randperm(length(iti)));

end % if ~p.restart

end

