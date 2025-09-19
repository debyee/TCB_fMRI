function instructionsCue(p)
%% Cue Instructions

imgFile_Rew1Pen1 = imread([p.interval.cueFolder,'Rew1_Pen1.png']);
imgFile_Rew1Pen2 = imread([p.interval.cueFolder,'Rew1_Pen2.png']);
imgFile_Rew2Pen1 = imread([p.interval.cueFolder,'Rew2_Pen1.png']);
imgFile_Rew2Pen2 = imread([p.interval.cueFolder,'Rew2_Pen2.png']);

imgFile_Rew1Pen1 = imresize(imgFile_Rew1Pen1,0.1);
imgFile_Rew1Pen2 = imresize(imgFile_Rew1Pen2,0.1);
imgFile_Rew2Pen1 = imresize(imgFile_Rew2Pen1,0.1);
imgFile_Rew2Pen2 = imresize(imgFile_Rew2Pen2,0.1);

[height_Rew1Pen1, width_Rew1Pen1, ~] = size(imgFile_Rew1Pen1);
[height_Rew1Pen2, width_Rew1Pen2, ~] = size(imgFile_Rew1Pen2);
[height_Rew2Pen1, width_Rew2Pen1, ~] = size(imgFile_Rew2Pen1);
[height_Rew2Pen2, width_Rew2Pen2, ~] = size(imgFile_Rew2Pen2);

Rew1Pen1Texture = Screen('MakeTexture',p.wPtr,imgFile_Rew1Pen1);
Rew1Pen2Texture = Screen('MakeTexture',p.wPtr,imgFile_Rew1Pen2);
Rew2Pen1Texture = Screen('MakeTexture',p.wPtr,imgFile_Rew2Pen1);
Rew2Pen2Texture = Screen('MakeTexture',p.wPtr,imgFile_Rew2Pen2);


% header
Screen('TextSize',p.wPtr,40);

msg = ['Once you are in the scanner, you will start the real game.\n\n',...
    'Before each turn, you will always see one of the following images:'];

DrawFormattedText(p.wPtr,msg,'center',(p.yCenter - 350),p.color.white,70);

% cues
%DrawFormattedText(p.wPtr,['LOW GEM (', num2str(p.stimulus.rewardValues(1)), ')'],'center','center',p.color.white,70,[],[],[],[],[(p.xCenter-200),(p.yCenter-225),(p.xCenter),(p.yCenter-200)]);
%DrawFormattedText(p.wPtr,['HIGH GEM (', num2str(p.stimulus.rewardValues(2)), ')'],'center','center',p.color.white,70,[],[],[],[],[(p.xCenter+150),(p.yCenter-225),(p.xCenter+350),(p.yCenter-200)]);
%DrawFormattedText(p.wPtr,['HIGH BOMB (', num2str(p.stimulus.penaltyValues(2)), ')'],'center','center',p.color.white,70,[],[],[],[],[(p.xCenter-550),(p.yCenter-200),(p.xCenter-250),(p.yCenter+50)]);
%DrawFormattedText(p.wPtr,['LOW BOMB (', num2str(p.stimulus.penaltyValues(1)), ')'],'center','center',p.color.white,70,[],[],[],[],[(p.xCenter-550),(p.yCenter+125),(p.xCenter-250),(p.yCenter+375)]);

% DrawFormattedText(p.wPtr,['LOW GEM (', num2str(p.stimulus.rewardValues(1)), ')'],p.xCenter-225,p.yCenter-175,p.color.white,70);
% DrawFormattedText(p.wPtr,['HIGH GEM (', num2str(p.stimulus.rewardValues(2)), ')'],p.xCenter+150,p.yCenter-175,p.color.white,70);
% DrawFormattedText(p.wPtr,['HIGH BOMB (', num2str(p.stimulus.penaltyValues(2)), ')'],p.xCenter-500,p.yCenter,p.color.white,70);
% DrawFormattedText(p.wPtr,['LOW BOMB (', num2str(p.stimulus.penaltyValues(1)), ')'],p.xCenter-500,p.yCenter+250,p.color.white,70);
% 
% Screen('DrawTexture',p.wPtr,Rew1Pen2Texture,[],[p.xCenter-100-(width_Rew1Pen2/2),p.yCenter-25-(height_Rew1Pen2/2),p.xCenter-100+(width_Rew1Pen2/2),p.yCenter-25+(height_Rew1Pen2/2)]);
% Screen('DrawTexture',p.wPtr,Rew2Pen2Texture,[],[p.xCenter+250-(width_Rew2Pen2/2),p.yCenter-25-(height_Rew2Pen2/2),p.xCenter+250+(width_Rew2Pen2/2),p.yCenter-25+(height_Rew2Pen2/2)]);
% Screen('DrawTexture',p.wPtr,Rew1Pen1Texture,[],[p.xCenter-100-(width_Rew1Pen1/2),p.yCenter+250-(height_Rew1Pen1/2),p.xCenter-100+(width_Rew1Pen1/2),p.yCenter+250+(height_Rew1Pen1/2)]);
% Screen('DrawTexture',p.wPtr,Rew2Pen1Texture,[],[p.xCenter+250-(width_Rew2Pen1/2),p.yCenter+250-(height_Rew2Pen1/2),p.xCenter+250+(width_Rew2Pen1/2),p.yCenter+250+(height_Rew2Pen1/2)]);

DrawFormattedText(p.wPtr,['LOW COLLECT (', num2str(p.stimulus.rewardValues(1)), ')'],p.xCenter-250,p.yCenter-225,p.color.white,70);
DrawFormattedText(p.wPtr,['HIGH COLLECT (', num2str(p.stimulus.rewardValues(2)), ')'],p.xCenter+150,p.yCenter-225,p.color.white,70);
DrawFormattedText(p.wPtr,['HIGH PENALTY (', num2str(p.stimulus.penaltyValues(2)), ')'],p.xCenter-575,p.yCenter,p.color.white,70);
DrawFormattedText(p.wPtr,['LOW PENALTY (', num2str(p.stimulus.penaltyValues(1)), ')'],p.xCenter-575,p.yCenter+250,p.color.white,70);


Screen('DrawTexture',p.wPtr,Rew1Pen2Texture,[],[p.xCenter-100-(width_Rew1Pen2/2),p.yCenter-25-(height_Rew1Pen2/2),p.xCenter-100+(width_Rew1Pen2/2),p.yCenter-25+(height_Rew1Pen2/2)]);
Screen('DrawTexture',p.wPtr,Rew2Pen2Texture,[],[p.xCenter+250-(width_Rew2Pen2/2),p.yCenter-25-(height_Rew2Pen2/2),p.xCenter+250+(width_Rew2Pen2/2),p.yCenter-25+(height_Rew2Pen2/2)]);
Screen('DrawTexture',p.wPtr,Rew1Pen1Texture,[],[p.xCenter-100-(width_Rew1Pen1/2),p.yCenter+250-(height_Rew1Pen1/2),p.xCenter-100+(width_Rew1Pen1/2),p.yCenter+250+(height_Rew1Pen1/2)]);
Screen('DrawTexture',p.wPtr,Rew2Pen1Texture,[],[p.xCenter+250-(width_Rew2Pen1/2),p.yCenter+250-(height_Rew2Pen1/2),p.xCenter+250+(width_Rew2Pen1/2),p.yCenter+250+(height_Rew2Pen1/2)]);


Screen('Flip', p.wPtr, []);
WaitSecs(1);
keyWaitTTL(-1,p.exptrKey)


if p.isScanningVersion == 0 || (p.isScanningVersion == 1 && p.curSession == 1)
    %% Quiz
    Screen('DrawTexture',p.wPtr,Rew1Pen2Texture,[],[p.xCenter-100-(width_Rew1Pen2/2),p.yCenter-25-(height_Rew1Pen2/2),p.xCenter-100+(width_Rew1Pen2/2),p.yCenter-25+(height_Rew1Pen2/2)]);
    Screen('DrawTexture',p.wPtr,Rew2Pen2Texture,[],[p.xCenter+250-(width_Rew2Pen2/2),p.yCenter-25-(height_Rew2Pen2/2),p.xCenter+250+(width_Rew2Pen2/2),p.yCenter-25+(height_Rew2Pen2/2)]);
    Screen('DrawTexture',p.wPtr,Rew1Pen1Texture,[],[p.xCenter-100-(width_Rew1Pen1/2),p.yCenter+250-(height_Rew1Pen1/2),p.xCenter-100+(width_Rew1Pen1/2),p.yCenter+250+(height_Rew1Pen1/2)]);
    Screen('DrawTexture',p.wPtr,Rew2Pen1Texture,[],[p.xCenter+250-(width_Rew2Pen1/2),p.yCenter+250-(height_Rew2Pen1/2),p.xCenter+250+(width_Rew2Pen1/2),p.yCenter+250+(height_Rew2Pen1/2)]);
    
    Screen('Flip', p.wPtr, [], 1);
    WaitSecs(1);
    keyWaitTTL(-1,p.exptrKey)
    Screen(p.wPtr,'Flip');
    
    
    %% Game Start Instructions
    msg = ['At the start of the real game, you will have ',num2str(p.initialGemEndowment),' gems in your bank account.\n\n\n\n\n\n\n',...
        'There will be ',num2str(p.numBlocks),' rounds of the game.\n\n',...
        'At the end of each round we will choose ',num2str(p.numIntSampledPerBlock),' of the turns. ',...
        'We will add the gems and remaining bombs from those turns to your bank account. ',...
        'Each bomb added to your account will detonate and destroy one gem.\n\n',...
        'Your final bonus will be determined by how many gems are left in your bank account.\n\n',...
        'The remaining gems in your bank account will be converted to real money at the end of the game.'];
    
        imgFile_Bank = imread([p.interval.cueFolder,'Bank.png']);
        imgFile_Bank = imresize(imgFile_Bank,0.2);
        BankTexture = Screen('MakeTexture',p.wPtr,imgFile_Bank);
        [height_Bank, width_Bank, ~] = size(imgFile_Bank);
        Screen('DrawTexture',p.wPtr,BankTexture,[],[p.xCenter-(width_Bank/2),p.yCenter-225-(height_Bank/2),p.xCenter+(width_Bank/2),p.yCenter-225+(height_Bank/2)]);

    
    instructions(p,msg,1);
    
end
end

