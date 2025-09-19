function flipTime = fixation(p,color)
%FIXATION Summary of this function goes here
%   Detailed explanation goes here

Screen('TextSize',p.wPtr, 100);

% 1 = DY laptop, 2 = AS laptop, 3 = MRF Scanner computer
if p.curDevice == 1
    DrawFormattedText(p.wPtr,'+','center',p.yCenter+35,color);
elseif p.curDevice == 2
    DrawFormattedText(p.wPtr,'+','center','center',color);
elseif p.curDevice == 3
    DrawFormattedText(p.wPtr,'+','center','center',color);
    %DrawFormattedText(p.wPtr,'+','center','center',color);
end


flipTime = Screen(p.wPtr,'Flip');


end

