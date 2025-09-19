function keyMappingReminder(p)

%% Key Mapping Reminder Screen
Screen('TextSize',p.wPtr, 50);
DrawFormattedText(p.wPtr,'Key Mapping:','center','center', p.color.white, 70,[],[],[],[],[(p.xCenter - 200),(p.yCenter - 250),(p.xCenter + 200),(p.yCenter - 150)]);

if p.responseBox
    Screen('FillOval', p.wPtr, p.stimulus.inkCodes{1}, [(p.xCenter - 225), (p.yCenter - 50), (p.xCenter - 150), (p.yCenter + 25)]);
    Screen('FillOval', p.wPtr, p.stimulus.inkCodes{2}, [(p.xCenter - 125), (p.yCenter - 50), (p.xCenter - 50), (p.yCenter + 25)]);
    Screen('FillOval', p.wPtr, p.stimulus.inkCodes{3}, [(p.xCenter + 50), (p.yCenter - 50), (p.xCenter + 125), (p.yCenter + 25)]);
    Screen('FillOval', p.wPtr, p.stimulus.inkCodes{4}, [(p.xCenter + 150), (p.yCenter - 50), (p.xCenter + 225), (p.yCenter + 25)]);
else
    
    Screen('FillRect', p.wPtr, p.stimulus.inkCodes{1}, [(p.xCenter - 225), (p.yCenter - 50), (p.xCenter - 150), (p.yCenter + 25)]);
    DrawFormattedText(p.wPtr,upper(p.keyArrayStrVec(1)),'center','center',p.color.black, 70,[],[],[],[],[(p.xCenter - 225), (p.yCenter - 70), (p.xCenter - 150), (p.yCenter + 25)]);
    
    Screen('FillRect', p.wPtr, p.stimulus.inkCodes{2}, [(p.xCenter - 125), (p.yCenter - 50), (p.xCenter - 50), (p.yCenter + 25)]);
    DrawFormattedText(p.wPtr,upper(p.keyArrayStrVec(2)),'center','center',p.color.black, 70,[],[],[],[],[(p.xCenter - 125), (p.yCenter - 70), (p.xCenter - 50), (p.yCenter + 25)]);
    
    Screen('FillRect', p.wPtr, p.stimulus.inkCodes{3}, [(p.xCenter + 50), (p.yCenter - 50), (p.xCenter + 125), (p.yCenter + 25)]);
    DrawFormattedText(p.wPtr,upper(p.keyArrayStrVec(3)),'center','center',p.color.black, 70,[],[],[],[],[(p.xCenter + 50), (p.yCenter - 70), (p.xCenter + 125), (p.yCenter + 25)]);
    
    Screen('FillRect', p.wPtr, p.stimulus.inkCodes{4}, [(p.xCenter + 150), (p.yCenter - 50), (p.xCenter + 225), (p.yCenter + 25)]);
    DrawFormattedText(p.wPtr,upper(p.keyArrayStrVec(4)),'center','center',p.color.black, 70,[],[],[],[],[(p.xCenter + 150), (p.yCenter - 70), (p.xCenter + 225), (p.yCenter + 25)]);

end

Screen(p.wPtr,'Flip');
WaitSecs(.5);
keyWaitTTL(p.device.num.exptr,p.exptrKey)


%% Start Screen
if ~p.isScanningVersion
    Screen('TextSize',p.wPtr, 50);
    DrawFormattedText(p.wPtr,'Press any button to start.','center','center',p.color.white, 70,[],[],[],[],[(p.xCenter - 200),(p.yCenter - 50),(p.xCenter + 200),(p.yCenter + 50)]);
    Screen(p.wPtr,'Flip');
    WaitSecs(.5);
    KbWait(-1);

    Screen('TextSize',p.wPtr, 100);
    %DrawFormattedText(p.wPtr,'+','center','center',p.color.white, 70,[],[],[],[],[(p.xCenter - 200),(p.yCenter - 50),(p.xCenter + 200),(p.yCenter + 50)]);
    DrawFormattedText(p.wPtr,'+','center','center',p.color.white, 70);
    Screen(p.wPtr,'Flip');
    WaitSecs(1);
end

end



