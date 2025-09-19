function instructions(p,msg,wait,yAdjust,txtsize,wrap)
%INSTRUCTIONS Summary of this function goes here
%   Detailed explanation goes here

% If yAdjust is not an input, set to default y position
if ~exist('yAdjust','var')
    yAdjust = 'center';
end

% If txtsize is not an input, set to default
if ~exist('txtsize','var')
    txtsize = 36;
end

% If wrap specification is not an input, set to default
if ~exist('wrap','var')
    wrap = 60;
end


Screen('TextSize',p.wPtr, txtsize);
DrawFormattedText(p.wPtr,msg,'center',yAdjust,p.color.white,wrap);
Screen(p.wPtr,'Flip');
WaitSecs(wait);

keyWaitTTL(p.device.num.exptr,p.exptrKey)

end
