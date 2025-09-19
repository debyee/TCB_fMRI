function [p,practice,results] = block(p,practice,results)

p.startInterval = ((p.curBlockNum - 1) * p.numIntervalsPerBlock) + 1;
p.endInterval = p.curBlockNum * p.numIntervalsPerBlock;

if p.isScanningVersion
    Screen('TextSize',p.wPtr, 50);
    DrawFormattedText(p.wPtr,'The task is about to begin...','center','center',p.color.white,70);
    Screen('Flip',p.wPtr);
    results.timing.scanBlockWaitInstrglobal(p.curBlockNum) = GetSecs;
    disp('Waiting for TTL trigger...');
    FlushEvents('keyDown');
    keyWaitTTL(p.device.num.ttl,p.TTLkey);
    triggerTime = GetSecs;
    results.timing.scanBlockStartTTLglobal(p.curBlockNum) = triggerTime;
    fixation(p,p.color.white);
    
    try
        saveResults(p,practice,results)
    catch
        save(fullfile([p.session.versionPath,'/Results'],['TSS_',p.subID,'_',p.date,'.mat']),'p','results');
    end
    disp('Trigger detected!');
    WaitSecs(p.durStartDummyScans - (GetSecs - triggerTime));
end

for intervalNum = p.startInterval:p.endInterval
    
    p.curIntervalNum = intervalNum;
    
    [p,practice,results] = interval(p,practice,results);
    
end

if p.isScanningVersion
    WaitSecs(p.durEndDummyScans);
    results.timing.scanBlockEndAbsolute(p.curBlockNum) = GetSecs;
    results.timing.scanBlockEndRelative(p.curBlockNum) = results.timing.scanBlockEndAbsolute(p.curBlockNum) - results.timing.scanBlockStartTTLglobal(p.curBlockNum);
end

try
    saveResults(p,practice,results)
catch
    save(fullfile([p.session.versionPath,'/Results'],['TSS_',p.subID,'_',p.date,'.mat']),'p','results','practice');
end
end

