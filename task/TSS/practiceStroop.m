function [p,practice,results] = practiceStroop(p,practice,results)
%PRACTICE Summary of this function goes here
%   Detailed explanation goes here

stimuli = p.practiceStimuli.stroop;
p.pracWithDeadline = 0;

for trialNum = 1:p.numPracTrials.stroop
    
    %%% Add deadline half way through practice (with instructions)
    if trialNum == (p.numPracTrials.stroop/2 + 1)
        p.pracWithDeadline = 1;
        
        instructions(p,'You have finished this practice.',.2);
        
        instructions(p,['There will now be a time limit.\n\n',...
            'To be correct, you will need to respond before time runs out.\n\n',...
            'If you are too slow, you will be told you missed that trial.',...
            ],1);
        keyMappingReminder(p);
    end
    
    stim = stimuli(trialNum);
    practice.stroop.stimuli{trialNum} = stim;
    
    %%% Target presentation
    Screen('TextSize',p.wPtr,65);
    %DrawFormattedText(p.wPtr,stim.Text,'center','center',stim.InkCode, 70,[],[],[],[],[(p.xCenter - 200),(p.yCenter - 50),(p.xCenter + 200),(p.yCenter + 50)]);
    %DrawFormattedText(p.wPtr,stim.Text,'center','center',stim.InkCode, 70,[],[],[],[],[(p.xCenter - 200),(p.yCenter),(p.xCenter + 200),(p.yCenter)]);
    DrawFormattedText(p.wPtr,stim.Text,'center','center',stim.InkCode);
    % frame orientation
    Screen('FrameRect',p.wPtr,p.color.lightGrey,[p.xCenter-200,p.yCenter-85,p.xCenter+200,p.yCenter+85],2);
    [fixedStimStart] = Screen(p.wPtr,'Flip');
    
    if p.pracWithDeadline == 1
        [resp, rt] = ORcollectResponse(p.timing.pracRtDeadline,-1,p.keyArrayStrVec);
    elseif p.pracWithDeadline == 0
        [resp, rt] = ORcollectResponse(inf,-1,p.keyArrayStrVec);
    end
    
    %%% FEEDBACK
    if resp == stim.ColorAns
        acc = 1;
    else
        acc = 0;
    end
    
    if resp > 0
        if acc
            feedback = 'Correct';
        else
            feedback = 'Incorrect';
        end
    else
        feedback = 'Miss';
    end
    
    %%% Feedback presentation
    Screen('TextSize',p.wPtr, 65);
    %DrawFormattedText(p.wPtr,feedback,'center','center',p.color.white, 70,[],[],[],[],[(p.xCenter - 200),(p.yCenter - 50),(p.xCenter + 200),(p.yCenter + 50)]);
    %DrawFormattedText(p.wPtr,feedback,'center','center',p.color.white, 70,[],[],[],[],[(p.xCenter - 200),(p.yCenter),(p.xCenter + 200),(p.yCenter)]);
    DrawFormattedText(p.wPtr,feedback,'center','center',p.color.white);
    % frame orientation
    Screen('FrameRect',p.wPtr,p.color.lightGrey,[p.xCenter-200,p.yCenter-85,p.xCenter+200,p.yCenter+85],2);
    Screen(p.wPtr,'Flip');
    WaitSecs(p.timing.pracFbDuration);
  
    practice.stroop.resp(trialNum) = resp;
    practice.stroop.rt(trialNum) = rt;
    practice.stroop.acc(trialNum) = acc;
    
    try
        saveResults(p,practice,results)
    catch
        %save(fullfile([p.session.versionPath,'/Results'],['TSS_',p.subID,'_',p.date,'.mat']),'p','results');
        save(fullfile([p.session.versionPath,'/Results'],['TSS_',p.session.versionPath,'_practice_',p.subID,'_',p.date,'.mat']),'p','practice','results');
    end
end

try
    saveResults(p,practice,results)
catch
    %save(fullfile([p.session.versionPath,'/Results'],['TSS_',p.subID,'_',p.date,'.mat']),'p','results');
    save(fullfile([p.session.versionPath,'/Results'],['TSS_',p.session.versionPath,'_practice_',p.subID,'_',p.date,'.mat']),'p','practice','results');
end

end

