function drawBanks(p,isFilled)

% efficacy frame banks
Screen('FrameRect',p.wPtr,p.color.darkGrey,[p.xCenter-550,p.yCenter+150,p.xCenter+550,p.yCenter+400],5);
Screen('LineStipple', p.wPtr, 1, 5)
Screen('DrawLine', p.wPtr,p.color.darkGrey,p.xCenter-550,p.yCenter-400,p.xCenter+550,p.yCenter-400,5);
Screen('DrawLine', p.wPtr,p.color.darkGrey,p.xCenter-550,p.yCenter-150,p.xCenter+550,p.yCenter-150,5);
Screen('DrawLine', p.wPtr,p.color.darkGrey,p.xCenter-550,p.yCenter-400,p.xCenter-550,p.yCenter-150,5);
Screen('DrawLine', p.wPtr,p.color.darkGrey,p.xCenter+550,p.yCenter-400,p.xCenter+550,p.yCenter-150,5);
Screen('LineStipple', p.wPtr, 0)

if isFilled
    Screen('FillRect',p.wPtr,p.color.darkGrey,[p.xCenter-550,p.yCenter-400,p.xCenter+550,p.yCenter-150],5);
end

end