function calcReward
clear all  
  
p = [];
p = setVersion(p);
p.subID = input('What is the subject number? (e.g., 0001): ','s');

resultsFile = dir([pwd,'/',p.session.versionPath,'/Results/TSS_',p.session.versionPath,'_',p.subID,'_*.mat']);
load([p.session.versionPath,'/Results/',resultsFile.name]);

try
    disp(['Calculating Bonus for participant for participant ',p.subID]);
    
    if p.session.isGainLoss == 1
        gainLow = results.interval.reward(results.interval.isGain == 1 & results.interval.rewLevel == 0);
        gainLowSample = randsample(gainLow,p.numBlocks);
        gainLowTotal = sum(gainLowSample);

        gainHigh = results.interval.reward(results.interval.isGain == 1 & results.interval.rewLevel == 1);
        gainHighSample = randsample(gainHigh,p.numBlocks);
        gainHighTotal = sum(gainHighSample);

        lossLow = results.interval.reward(results.interval.isGain == 0 & results.interval.rewLevel == 0);
        lossLowSample = randsample(lossLow,p.numBlocks);
        lossLowTotal = sum(lossLowSample);

        lossHigh = results.interval.reward(results.interval.isGain == 0 & results.interval.rewLevel == 1);
        lossHighSample = randsample(lossHigh,p.numBlocks);
        lossHighTotal = sum(lossHighSample);

        bonusGems = p.initialGemEndowment + gainLowTotal + gainHighTotal + lossLowTotal + lossHighTotal;
        p.session.bonusEarned = bonusGems * p.conversionFactor;

    elseif p.session.isRewardPenalty == 1
        
        GemTotal = nan(1,p.numBlocks);
        ix_int = (1:p.numIntervalsPerBlock:p.numIntervals);
        
        for b = 1:p.numBlocks
        
            block = results.interval.netreward(ix_int(b):ix_int(b)+p.numIntervalsPerBlock-1);
            blocksample = randsample(block,4);
            blockTotal = sum(blocksample);
            
            GemTotal(b) = blockTotal;

        end
        
        bonusGems = sum(GemTotal);
        p.session.bonusEarned = bonusGems * p.conversionFactor;
        
%         rew1pen1 = results.interval.netreward(results.interval.rewLevel == 0 & results.interval.penaltyLevel == 0);
%         rew1pen1Sample = randsample(rew1pen1,p.numBlocks);
%         rew1pen1Total = sum(rew1pen1Sample);
% 
%         rew1pen2 = results.interval.netreward(results.interval.rewLevel == 1 & results.interval.penaltyLevel == 1);
%         rew1pen2Sample = randsample(rew1pen2,p.numBlocks);
%         rew1pen2Total = sum(rew1pen2Sample);
% 
%         rew2pen1 = results.interval.netreward(results.interval.rewLevel == 0 & results.interval.penaltyLevel == 0);
%         rew2pen1Sample = randsample(rew2pen1,p.numBlocks);
%         rew2pen1Total = sum(rew2pen1Sample);
% 
%         rew2pen2 = results.interval.reward(results.interval.rewLevel == 1 & results.interval.penaltyLevel == 1);
%         rew2pen2Sample = randsample(rew2pen2,p.numBlocks);
%         rew2pen2Total = sum(rew2pen2Sample);

        %bonusGems = rew1pen1Total + rew1pen2Total + rew2pen1Total + rew2pen2Total;
        %p.session.bonusEarned = bonusGems * p.conversionFactor;
        


    elseif p.session.isLossPenalty
        
        GemTotal = nan(1,p.numBlocks);
        BombsTotal = repmat(p.initialBombsPerTurn*p.numBlocks,1,p.numBlocks);
        ix_int = (1:p.numIntervalsPerBlock:p.numIntervals);
        
        for b = 1:p.numBlocks
        
            block = results.interval.netreward(ix_int(b):ix_int(b)+p.numIntervalsPerBlock-1);
            blocksample = randsample(block,4);
            blockTotal = sum(blocksample);
            
            GemTotal(b) = blockTotal;
        end
        
        bonusGems = sum(GemTotal);
        p.session.bonusGemsEarned = bonusGems;
        p.session.bonusEarned = (p.initialGemEndowment - sum(BombsTotal) + bonusGems) * p.conversionFactor;
        
%         rew1pen1 = results.interval.reward(results.interval.rewLevel == 0 & results.interval.penaltyLevel == 0);
%         rew1pen1Sample = randsample(rew1pen1,p.numBlocks);
%         rew1pen1Total = sum(rew1pen1Sample);
% 
%         rew1pen2 = results.interval.reward(results.interval.rewLevel == 1 & results.interval.penaltyLevel == 1);
%         rew1pen2Sample = randsample(rew1pen2,p.numBlocks);
%         rew1pen2Total = sum(rew1pen2Sample);
% 
%         rew2pen1 = results.interval.reward(results.interval.rewLevel == 0 & results.interval.penaltyLevel == 0);
%         rew2pen1Sample = randsample(rew2pen1,p.numBlocks);
%         rew2pen1Total = sum(rew2pen1Sample);
% 
%         rew2pen2 = results.interval.reward(results.interval.rewLevel == 1 & results.interval.penaltyLevel == 1);
%         rew2pen2Sample = randsample(rew2pen2,p.numBlocks);
%         rew2pen2Total = sum(rew2pen2Sample);
% 
%         bonusGems = (rew1pen1Total + rew1pen2Total + rew2pen1Total + rew2pen2Total)*2;
%         p.session.bonusEarned = bonusGems * p.conversionFactor;
%         p.session.bonusEarned = (p.initialGemEndowment-bonusGems ) * p.conversionFactor; 
    end

  
catch
    warning('Problem using calcReward. Check function calcReward.m');
end


msg = ['Rewards earned = $', num2str(p.session.bonusEarned)];

disp(msg);

save([p.session.versionPath,'/Results/',resultsFile.name]);

%keyboard

end

