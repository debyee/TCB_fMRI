function saveResults(p,practice,results)

% Save practice data for Session 1 outside scanner
if p.isPracticeSession == 1 
    save(fullfile([p.session.versionPath,'/Results'],['TSS_',p.session.versionPath,'_practice_',p.subID,'_',p.date,'.mat']),'p','practice','results');

elseif (p.isPracticeSession == 0)
    % Save practice data for Session 3 outside scanner
    if (p.curBlockNum == 0 && p.curSession == 3) 
        save(fullfile([p.session.versionPath,'/Results'],['TSS_',p.session.versionPath,'_practice_',p.subID,'_',p.date,'.mat']),'p','practice','results');
    % Save task data for Session 3 outside scanner
    elseif (p.curBlockNum > 0 && p.curSession == 3) 
        save(fullfile([p.session.versionPath,'/Results'],['TSS_',p.session.versionPath,'_',p.subID,'_',p.date,'.mat']),'p','practice','results');
    else 
        save(fullfile([p.session.versionPath,'/Results'],['TSS_',p.session.versionPath,'_',p.subID,'_',p.date,'.mat']),'p','practice','results');
    end
else
    error('p.isPracticeSession not defined. Check runTSS.m script')
end

end

