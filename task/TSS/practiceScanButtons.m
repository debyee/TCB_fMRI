function [p] = practiceScanButtons(p)

msg = 'You are going to practice using the new buttons.\n\nPress the button that corresponds to the color of the Xs.';
instructions(p,msg,.5);
keyMappingReminder(p);

for curTrialNum = 1:p.numPracticeScanButtons
    % Stimulus
    Screen('TextSize',p.wPtr,65);
    stim = p.stimuli(curTrialNum);
    DrawFormattedText(p.wPtr,'XXXXX','center','center',stim.InkCode);
    Screen('FrameRect',p.wPtr,p.color.lightGrey,[p.xCenter-200,p.yCenter-85,p.xCenter+200,p.yCenter+85],2);
    Screen(p.wPtr,'Flip');

    % Response 
    [resp, ~] = ORcollectResponse(inf,p.device.num.resp,p.keyArrayStrVec);
    %[resp, ~] = ORcollectResponse(inf,-1,p.keyArrayStrVec);
    if resp == stim.ColorAns
        acc = 1;
    else
        acc = 0;
    end
    
    % Feedback
    if acc
        feedback = 'Correct';
    else
        feedback = 'Incorrect';
    end

    Screen('TextSize',p.wPtr, 50);
    DrawFormattedText(p.wPtr,feedback,'center','center',p.color.white, 70);
    Screen('FrameRect',p.wPtr,p.color.lightGrey,[p.xCenter-200,p.yCenter-85,p.xCenter+200,p.yCenter+85],2);
    Screen(p.wPtr,'Flip');
    WaitSecs(p.timing.pracFbDuration);
end

msg = 'You finished this practice.\n\nPlease stay still while the scan finishes.';
instructions(p,msg,.5);

end
