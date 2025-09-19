function drawReward(p,row1YLoc)

leftXLoc = p.xCenter;
rightXLoc = p.xCenter;
row2YLoc = row1YLoc+80;

% drawBanks(p,0);

size = 75;
leftItem = 0;
count = 1;

if p.onlineFeedback || p.openBanks
    while count <= p.rewardsToDraw
        
        if mod(count,2) && leftItem == 1
            leftItem = 0;
        elseif mod(count,2) && leftItem == 0
            leftItem = 1;
        end
        
        if mod(count,2)     % odd
            if leftItem
                Screen('DrawTexture',p.wPtr,p.feedbackTexture,[],[leftXLoc-size, row1YLoc, leftXLoc, row1YLoc+size]);
            else
                Screen('DrawTexture',p.wPtr,p.feedbackTexture,[],[rightXLoc, row1YLoc, rightXLoc+size, row1YLoc+size]);
            end
        else                % even
            if leftItem
                Screen('DrawTexture',p.wPtr,p.feedbackTexture,[],[leftXLoc-size, row2YLoc, leftXLoc, row2YLoc+size]);
                leftXLoc = leftXLoc-size;
            else
                Screen('DrawTexture',p.wPtr,p.feedbackTexture,[],[rightXLoc, row2YLoc, rightXLoc+size, row2YLoc+size]);
                rightXLoc = rightXLoc+size;
            end
        end
        
        count = count + 1;
        
    end
end

end