function instructionsBasicInterval(p,wait)

%% Written Instructions
intLengthMean = num2str(round(mean([p.timing.iti.intervalDurationMin, p.timing.iti.intervalDurationMax])));

if p.session.isGamified
    instructions(p,['The game will be broken up into turns, and each turn will be about ',intLengthMean,' seconds long.\n\n ',...
        'Each turn will start with one of the colored words you saw earlier. ',...
        'Once you respond to that word, a new word will appear. ',...
        'This will keep happening until the time for that turn runs out.\n\n ',...
        'We will now show you a diagram to explain how these turns work.',...
        ],1);
else
    instructions(p,['Now, you will continue doing the same task as before, except now you will have a fixed amount of time (about ',intLengthMean,...
        'seconds) to respond to as many words as you can.\n\n ',...
        'You will no longer see the words correct or incorrect after each response. ',...
        'Instead, at the end of the interval you will see your total number of correct responses.\n\n ',...
        'We will now show you a diagram to explain the task in more detail.',...
        ],1);
end


%% Interval Schema
imgFile = imread('Images/Instructions/IntervalDiagram.png');
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


%% Written Instructions
instructions(p,['Remember, you should continue to respond only to the INK COLOR of each word.\n\n',...
    'You should NOT respond based on the content of the word.\n\n ',...
    'Please let the experimenter know if you have any questions before you begin.',...
    ],1);

keyMappingReminder(p);

end