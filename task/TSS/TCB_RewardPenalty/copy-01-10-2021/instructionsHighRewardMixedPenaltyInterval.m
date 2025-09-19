function instructionsHighRewardMixedPenaltyInterval(p,wait)

%% Start second practice
msg = ['You will now do another practice block of the game.\n\n\n\n\n\n\n\n\n\n\n\n',...
    'On each turn in this game, you will try to add gems to your bank.\n'];

    imgFile_Bank = imread([p.interval.cueFolder,'Bank.png']);
    imgFile_Bank = imresize(imgFile_Bank,0.2);
    BankTexture = Screen('MakeTexture',p.wPtr,imgFile_Bank);
    [height_Bank, width_Bank, ~] = size(imgFile_Bank);
    Screen('DrawTexture',p.wPtr,BankTexture,[],[p.xCenter-(width_Bank/2),p.yCenter-100-(height_Bank/2),p.xCenter+(width_Bank/2),p.yCenter-100+(height_Bank/2)]);

    instructions(p,msg,1);

%% Written High Reward Mixed Penalty Instructions
% msg = ['\n\nWhen you play the role of COLLECTOR, you can collect gems to add to your bank. ',...
%     'On each turn, you can collect gems by correctly responding to the colored words.\n\n',...
%     'You can collect ', num2str(p.stimulus.rewardValues(1)), ' or ',num2str(p.stimulus.rewardValues(2)),' gems for each correct response.\n\n',...
%     'However, each incorrect response will cause one or many bombs to appear in your bank, each of which will detonate the equivalent number of gems.\n\n',...
%     'On some turns, you will detonate ', num2str(p.stimulus.penaltyValues(1)), ' bomb for each incorrect response. ',...
%     'On other turns, you will detonate ', num2str(p.stimulus.penaltyValues(2)), ' bombs for each incorrect response. ',...
%     'Importantly, you will not collect any gems AND you will detonate bomb(s) for each incorrect response.\n\n'];
% 
% instructions(p,msg,1,-400);

msg = ['\n\nAt the start of each turn, one of the images will indicate how many gems you can collect for each correct response and how many bombs you will detonate for each incorrect response. ',...
    '\n\nAt the end of each turn, you will see the net number of gems, based on the number of gems you collected minus the number of bombs you detonated!'];


imgFile_Rew2Pen1 = imread([p.interval.cueFolder,'Rew2_Pen1.png']);
imgFile_Rew2Pen2 = imread([p.interval.cueFolder,'Rew2_Pen2.png']);
imgFile_Rew2Pen1 = imresize(imgFile_Rew2Pen1,0.15);
imgFile_Rew2Pen2 = imresize(imgFile_Rew2Pen2,0.15);
[height_Rew2Pen1, width_Rew2Pen1, ~] = size(imgFile_Rew2Pen1);
[height_Rew2Pen2, width_Rew2Pen2, ~] = size(imgFile_Rew2Pen2);
Rew2Pen1Texture = Screen('MakeTexture',p.wPtr,imgFile_Rew2Pen1);
Rew2Pen2Texture = Screen('MakeTexture',p.wPtr,imgFile_Rew2Pen2);

DrawFormattedText(p.wPtr,[' Low Penalty Turn'],(p.xCenter-300-(width_Rew2Pen1/2)),(p.yCenter-50),p.color.white,70);
Screen('DrawTexture',p.wPtr,Rew2Pen1Texture,[],[p.xCenter-225-(width_Rew2Pen1/2),p.yCenter+150-(height_Rew2Pen1/2),p.xCenter-225+(width_Rew2Pen1/2),p.yCenter+150+(height_Rew2Pen1/2)]);
DrawFormattedText(p.wPtr,[' High Penalty Turn'],(p.xCenter+150-(width_Rew2Pen2/2)),(p.yCenter-50),p.color.white,70);
Screen('DrawTexture',p.wPtr,Rew2Pen2Texture,[],[p.xCenter+225-(width_Rew2Pen2/2),p.yCenter+150-(height_Rew2Pen2/2),p.xCenter+225+(width_Rew2Pen2/2),p.yCenter+150+(height_Rew2Pen2/2)]);

instructions(p,msg,1,-0);


%% Interval Schema
imgFile = imread('Images/Instructions/RewardPenaltyIntervalDiagram.png');
[height, width, ~] = size(imgFile);
img = Screen('MakeTexture',p.wPtr,imgFile);

if p.yRes/height < p.xRes/width
    scaleFactor = p.yRes/height;
else
    scaleFactor = p.xRes/width;
end

scaleFactor = scaleFactor*.9;
scaledWidth = width*scaleFactor;
scaledHeight = height*scaleFactor;
Screen('DrawTexture',p.wPtr,img,[],[p.xCenter-scaledWidth/2, p.yCenter-scaledHeight/2, p.xCenter+scaledWidth/2, p.yCenter+scaledHeight/2]);

Screen(p.wPtr,'Flip');
WaitSecs(wait);
keyWaitTTL(-1,p.exptrKey);


%% Interval Example
smallValue = p.stimulus.rewardValues(2) * 10 - p.stimulus.penaltyValues(1) * 2;
largeValue = p.stimulus.rewardValues(2) * 10 - p.stimulus.penaltyValues(2) * 2;

% msg = ['\n\n\nThis top image means that you will collect ', num2str(p.stimulus.rewardValues(2)), ' gems for each correct response. ',...
%     'For example, if you answer 10 trials correctly and 2 trials incorrectly you will collect ', num2str(smallValue), ' gems.\n\n\n\n\n\n',...
%     'This bottom image means that you will collect ', num2str(p.stimulus.rewardValues(2)), ' gems for each correct response. ',...
%     'For example, if you answer 10 trials correctly and 2 trials incorrectly you will collect ', num2str(largeValue), ' gems.\n\n\n\n',...
%     'Now you will practice being the COLLECTOR. \n\n'];

% msg = ['\n\n\nThis top image means that you will collect ', num2str(p.stimulus.rewardValues(2)), ' gems for each correct response ',...
%     'and detonate ',num2str(p.stimulus.penaltyValues(1)),' bomb for each incorrect response.\n\n',...
%     'For example, if you answer 10 trials correctly and 2 trials incorrectly you will have a net gain of ', num2str(smallValue), ' gems.\n\n\n\n\n\n',...
%     'This bottom image means that you will collect ', num2str(p.stimulus.rewardValues(2)), ' gems for each correct response ',...
%     'and detonate ',num2str(p.stimulus.penaltyValues(2)),' bombs for each incorrect response.\n\n',...
%     'For example, if you answer 10 trials correctly and 2 trials incorrectly you will have a net gain of ', num2str(largeValue), ' gems.\n\n\n',...
%     'Now you will practice being the COLLECTOR. \n\n'];


msg = ['\n\n\nThis top image means that you will collect ', num2str(p.stimulus.rewardValues(2)), ' gems for each correct response ',...
    'and detonate ',num2str(p.stimulus.penaltyValues(1)),' bomb for each incorrect response.\n\n',...
    'For example, if you answer 10 trials correctly and 2 trials incorrectly you will have a net gain of ', num2str(smallValue), ' gems.\n\n\n\n\n\n',...
    'This bottom image means that you will collect ', num2str(p.stimulus.rewardValues(2)), ' gems for each correct response ',...
    'and detonate ',num2str(p.stimulus.penaltyValues(2)),' bombs for each incorrect response.\n\n',...
    'For example, if you answer 10 trials correctly and 2 trials incorrectly you will have a net gain of ', num2str(largeValue), ' gems.\n\n\n',...
    'Now you will practice the game. \n\n'];

Screen('DrawTexture',p.wPtr,Rew2Pen1Texture,[],[p.xCenter-500-(width_Rew2Pen1/2),p.yCenter-200-(height_Rew2Pen1/2),p.xCenter-500+(width_Rew2Pen1/2),p.yCenter-200+(height_Rew2Pen1/2)]);
Screen('DrawTexture',p.wPtr,Rew2Pen2Texture,[],[p.xCenter-500-(width_Rew2Pen2/2),p.yCenter+200-(height_Rew2Pen2/2),p.xCenter-500+(width_Rew2Pen2/2),p.yCenter+200+(height_Rew2Pen2/2)]);

%instructions(p,msg,1);
% Note: had to modify the instructions display slightly to accomodate cues
Screen('TextSize',p.wPtr, 36);
DrawFormattedText(p.wPtr,msg,p.xCenter-400,'center',p.color.white,60);
Screen(p.wPtr,'Flip');
WaitSecs(wait);

keyWaitTTL(p.device.num.exptr,p.exptrKey)


%% Key mapping reminder
keyMappingReminder(p);
end