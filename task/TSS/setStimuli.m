function p = setStimuli(p)

if ~p.restart % only execute if we are not restarting a prior session

%% Set the stimulus text size
p.stimulus.textSize = 65;


%% Set colors
p.color.black = [0,0,0];
p.color.white = [255,255,255];
p.color.darkerGrey = [20,20,20];
p.color.darkGrey = [85,85,85];
p.color.lightGrey = [170,170,170];
p.color.red = [230,0,0];
p.color.yellow = [255,250,0];
p.color.green = [0,220,0];
p.color.blue = [0,70,255];
p.color.purple = [148,0,211];
p.color.orange = [255,140,0];

stimulus.texts = {'RED','YELLOW','GREEN','BLUE'};
stimulus.inkColors = {'red','yellow','green','blue'};
stimulus.inkCodes = {p.color.red, p.color.yellow, p.color.green, p.color.blue};

colorOrderPerms = ...
    [4,3,2,1; 4,3,1,2; 4,2,3,1; 4,2,1,3; 4,1,3,2; 4,1,2,3;...
    3,4,2,1; 3,4,1,2; 3,2,4,1; 3,2,1,4; 3,1,4,2; 3,1,2,4;...
    2,4,3,1; 2,4,1,3; 2,3,4,1; 2,3,1,4; 2,1,4,3; 2,1,3,4;...
    1,4,3,2; 1,4,2,3; 1,3,4,2; 1,3,2,4; 1,2,4,3; 1,2,3,4];
condition = mod(p.subIDNum, length(colorOrderPerms));
if condition == 0
    condition = length(colorOrderPerms);
end
p.colorOrder = colorOrderPerms(condition,:);

for x = 1:4
    p.stimulus.texts{x} = stimulus.texts{p.colorOrder(x)};
    p.stimulus.inkColors{x} = stimulus.inkColors{p.colorOrder(x)};
    p.stimulus.inkCodes{x} = stimulus.inkCodes{p.colorOrder(x)};
end
p.stimulus.texts{5} = 'XXXXX';


stimuli.congruent = [];
stimuli.incongruent = [];
stimuli.neutral = [];

for inkIndex = 1:length(p.stimulus.inkColors)
    for textIndex = 1:length(p.stimulus.texts)
        % Congruent Stimuli
        if textIndex == inkIndex
            thisStimulus = Stimulus(p.stimulus.texts{textIndex},p.stimulus.inkColors{inkIndex},p.stimulus.inkCodes{inkIndex},p.stimulus.textSize);
            thisStimulus.IsCongruent = 1;
            thisStimulus.ColorAns = inkIndex;
            thisStimulus.WordAns = textIndex;
            stimuli.congruent = [stimuli.congruent, thisStimulus];
            
            % Neutral Stimuli
        elseif textIndex == 5
            thisStimulus = Stimulus(p.stimulus.texts{textIndex},p.stimulus.inkColors{inkIndex},p.stimulus.inkCodes{inkIndex},p.stimulus.textSize);
            thisStimulus.IsCongruent = 2;
            thisStimulus.ColorAns = inkIndex;
            thisStimulus.WordAns = nan;
            stimuli.neutral = [stimuli.neutral, thisStimulus];
            
            % Incongruent Stimuli
        else
            thisStimulus = Stimulus(p.stimulus.texts{textIndex},p.stimulus.inkColors{inkIndex},p.stimulus.inkCodes{inkIndex},p.stimulus.textSize);
            thisStimulus.IsCongruent = 0;
            thisStimulus.ColorAns = inkIndex;
            thisStimulus.WordAns = textIndex;
            stimuli.incongruent = [stimuli.incongruent, thisStimulus];
            
        end
    end
end





%% Key Mapping Practice (only neutral)
p.practiceStimuli.keyMapping = [];
numReps = ceil(p.numPracTrials.keyMapping/length(stimuli.neutral));

for repNum = 1:numReps
    while 1
        stimSet = stimuli.neutral(randperm(length(stimuli.neutral)));
        
        if repNum == 1
            p.practiceStimuli.keyMapping = [p.practiceStimuli.keyMapping, stimSet];
            break
        elseif ~(strcmp(stimSet(1).InkColor, p.practiceStimuli.keyMapping(end).InkColor))
            p.practiceStimuli.keyMapping = [p.practiceStimuli.keyMapping, stimSet];
            break
        end
    end
end




%% Stroop Practice
% Congruency
if p.removeNeutral
    
    numITrials = ceil(p.numPracTrials.stroop * 0.60);
    numCTrials = ceil(p.numPracTrials.stroop * 0.40);
    numNTrials = 0;
    
else
    if mod(p.numPracTrials.stroop,3) == 0
        numITrials = p.numPracTrials.stroop/3;
        numCTrials = p.numPracTrials.stroop/3;
        numNTrials = p.numPracTrials.stroop/3;
    elseif mod(p.numPracTrials.stroop,3) == 1
        numITrials = ceil(p.numPracTrials.stroop/3);
        numCTrials = floor(p.numPracTrials.stroop/3);
        numNTrials = floor(p.numPracTrials.stroop/3);
    else
        numITrials = ceil(p.numPracTrials.stroop/3);
        numCTrials = ceil(p.numPracTrials.stroop/3);
        numNTrials = floor(p.numPracTrials.stroop/3);
    end
end

trialCong = [zeros(1,numITrials), ones(1,numCTrials), 2.*ones(1,numNTrials)];
trialCong = trialCong(randperm(length(trialCong)));

for trialNum = 1:p.numPracTrials.stroop
    while 1
        if trialCong(trialNum) == 2       	% Neutral trial
            stim = stimuli.neutral(randi([1 length(stimuli.neutral)],1));
        elseif trialCong(trialNum) == 1   	% Congruent trial
            stim = stimuli.congruent(randi([1 length(stimuli.congruent)],1));
        else                                % Incongruent trial
            stim = stimuli.incongruent(randi([1 length(stimuli.incongruent)],1));
        end
        
        if trialNum == 1
            p.practiceStimuli.stroop(trialNum) = stim;
            break
        elseif ~(strcmp(stim.Text, p.practiceStimuli.stroop(trialNum-1).Text) || strcmp(stim.InkColor, p.practiceStimuli.stroop(trialNum-1).InkColor))
            p.practiceStimuli.stroop(trialNum) = stim;
            break
        elseif trialCong(trialNum) == 2 && trialCong(trialNum-1) == 2
            trialCong(trialNum) = randi(2);
        end
    end
end



%% Main Task Trials
%Congruency
if p.removeNeutral
    
    numITrials = ceil(p.numTrials * 0.6);
    numCTrials = ceil(p.numTrials * 0.4);
    numNTrials = 0;
    
else
    if mod(p.numTrials,3) == 0
        numITrials = p.numTrials/3;
        numCTrials = p.numTrials/3;
        numNTrials = p.numTrials/3;
    elseif mod(p.numTrials,3) == 1
        numITrials = ceil(p.numTrials/3);
        numCTrials = floor(p.numTrials/3);
        numNTrials = floor(p.numTrials/3);
    else
        numITrials = ceil(p.numTrials/3);
        numCTrials = ceil(p.numTrials/3);
        numNTrials = floor(p.numTrials/3);
    end
end



trialCong = [zeros(1,numITrials), ones(1,numCTrials), 2.*ones(1,numNTrials)];
trialCong = trialCong(randperm(length(trialCong)));


for trialNum = 1:p.numTrials
    while 1
        if trialCong(trialNum) == 2       	% Neutral trial
            stim = stimuli.neutral(randi([1 length(stimuli.neutral)],1));
        elseif trialCong(trialNum) == 1   	% Congruent trial
            stim = stimuli.congruent(randi([1 length(stimuli.congruent)],1));
        else                                % Incongruent trial
            stim = stimuli.incongruent(randi([1 length(stimuli.incongruent)],1));
        end
        
        if trialNum == 1
            p.stimuli(trialNum) = stim;
            break
        elseif ~(strcmp(stim.Text, p.stimuli(trialNum-1).Text) || strcmp(stim.InkColor, p.stimuli(trialNum-1).InkColor))
            p.stimuli(trialNum) = stim;
            break
        elseif trialCong(trialNum) == 2 && trialCong(trialNum-1) == 2
            trialCong(trialNum) = randi(2);
        end
    end
end

end % if ~p.restart

end
