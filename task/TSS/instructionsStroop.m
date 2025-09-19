function instructionsStroop(p,wait)

%% Written Instructions
if p.session.isGamified
    instructions(p,['In this practice, you will see color words printed in different ink colors. \n\n',... 
    'Importantly, you should respond only to the INK COLOR of each word. \n\n',...
    'You should NOT respond based on the content of the word.',...
    ],wait);
else
    instructions(p,['In this practice, you will see color words printed in different ink colors. \n\n',...
        'Importantly, you should respond only to the INK COLOR of each word. \n\n',...
        'You should NOT respond based on the content of the word.',...
        ],wait);
end

%% Example 1
Screen('TextSize',p.wPtr, 40);
DrawFormattedText(p.wPtr,'For example, you may see the word blue printed in red ink.\n\nWhat is the correct response?',...
    'center','center', p.color.white, 70,[],[],[],[],[(p.xCenter - 200),(p.yCenter - 250),(p.xCenter + 200),(p.yCenter - 150)]);
Screen('TextSize',p.wPtr, 70);
DrawFormattedText(p.wPtr,'BLUE','center','center',p.color.red,60);
Screen('FrameRect',p.wPtr,p.color.lightGrey,[p.xCenter-200,p.yCenter-85,p.xCenter+200,p.yCenter+85],2);
Screen(p.wPtr,'Flip');
WaitSecs(1);
keyWaitTTL(-1,p.exptrKey)


%% Example 2
Screen('TextSize',p.wPtr, 40);
DrawFormattedText(p.wPtr,'For example, you may see the word green printed in yellow ink.\n\nWhat is the correct response?',...
    'center','center', p.color.white, 70,[],[],[],[],[(p.xCenter - 200),(p.yCenter - 250),(p.xCenter + 200),(p.yCenter - 150)]);
Screen('TextSize',p.wPtr, 70);
DrawFormattedText(p.wPtr,'GREEN','center','center',p.color.yellow,60);
Screen('FrameRect',p.wPtr,p.color.lightGrey,[p.xCenter-200,p.yCenter-85,p.xCenter+200,p.yCenter+85],2);
Screen(p.wPtr,'Flip');
WaitSecs(1);
keyWaitTTL(-1,p.exptrKey)



instructions(p,['There is no time limit during this practice.\n\nPlease do your best to make sure you press the key that corresponds to the INK COLOR of the word.',...
    ],wait);

keyMappingReminder(p);

end