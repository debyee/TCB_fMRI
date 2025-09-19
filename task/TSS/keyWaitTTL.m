function Rtime = keyWaitTTL(deviceNum, TTLkey)

if ~exist('TTLkey','var')
    TTLkey = 't';
end


TTLpress = 'b'; keyDownX = 0; Rtime = 0; keyX = '';   % temp assignment
while 1
    if ~exist('deviceNum','var')
        [keyDownX,Rtime,keyX] = KbCheck;
    else
        [keyDownX,Rtime,keyX] = KbCheck(deviceNum);
    end
    
    if keyDownX
        TTLpress = KbName(keyX);
        if ~strcmpi(TTLpress,'Return')
            TTLpress = TTLpress(1);
        end
    end
    keyDownX = 0;
    
    if length(TTLkey)>1
        if ~isempty(strfind(TTLkey,TTLpress))
            break;
        end
    else
        if (strcmpi(TTLpress,TTLkey))
            break; 
        end
    end
end
return