function TCB_runLevel1_contrast(participant_id,root_path, design_foldername)
%function TCB_runLevel1_contrast
% Script that creates contrasts at first level analysis (single subject)

%% ---------------- Initialize spm  ------------------------------
spm('defaults', 'FMRI');
spm_jobman('initcfg');                         % necessary for parallel job submits
spm_get_defaults('cmdline',true);              % command line, no pop-up

%% ---------------- Customize these variables -----------------------------

% basepath = '/Volumes/TCB/';

% participant_id=('2011');
% root_path=[basepath,'spm-data/'];
% design_foldername='glm1_Event_Cue_rwls';

% Directories for the batch
dir_level1Data = fullfile(root_path,['sub-',participant_id],'/',char(design_foldername));
dir_SPMfile = fullfile(root_path,['sub-',participant_id],char(design_foldername),'SPM.mat');

% Load the task bug file and define number of nuisance regressors depending
% on whether the taskbug regressor is included.
basepath = '/gpfs/data/ashenhav/mri-data/TCB/'; 
load([basepath,'data/behavior/formatted/allTaskBugIntervalsRemove.mat'])
ix_TaskBug = [allTaskBugIntervalsRemove{:,1}] == str2num(participant_id);
if (allTaskBugIntervalsRemove{ix_TaskBug,2} ~= 0)
    num_nuisanceRegressors = 17;
else
    num_nuisanceRegressors = 16;
end

disp(['Number of nuisance regressors is: ', num2str(num_nuisanceRegressors)]);

%% ---------------- Change directory -----------------------------
% Change current directory to location of the subject design to write
% contrasts in the same folder.
cd(dir_level1Data);

%% ---------------- Set Up the Batch variable ------------------------------
% Identify the spm mat file to read in.
matlabbatch{1}.spm.stats.con.spmmat = {dir_SPMfile};
% Flag to overwrite existing contrasts
matlabbatch{1}.spm.stats.con.delete = 1;

% Spit out text in log to indicate which design you are running
display(['Creating contrasts for design ', char(design_foldername)])

% Specify specific contrasts based on the design
    
    %% GLM 1: 4 regressors: 4 Cues
    if strcmp(design_foldername,'glm1_Event_Cue_rwls')

        % Task Contrasts (Control: Task vs. Baseline)
        matlabbatch{1}.spm.stats.con.consess{1}.tcon.name = 'Cue_TaskvsBaseline';
        matlabbatch{1}.spm.stats.con.consess{1}.tcon.weights = [.25 .25 .25 .25 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
        % Cue Related Contrasts
        matlabbatch{1}.spm.stats.con.consess{2}.tcon.name = 'Cue_HighvsLowReward';
        matlabbatch{1}.spm.stats.con.consess{2}.tcon.weights = [0.5 0.5 -0.5 -0.5 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{3}.tcon.name = 'Cue_HighvsLowPenalty';
        matlabbatch{1}.spm.stats.con.consess{3}.tcon.weights = [0.5 -0.5 0.5 -0.5 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{3}.tcon.sessrep = 'none';

    %% GLM 2: 8 regressors: 4 Cues, 4 Int
    elseif strcmp(design_foldername,'glm2_Event_CueInt_rwls')

        % Task Contrasts (Control: Task vs. Baseline)
        matlabbatch{1}.spm.stats.con.consess{1}.tcon.name = 'Cue_TaskvsBaseline';
        matlabbatch{1}.spm.stats.con.consess{1}.tcon.weights = [.25 .25 .25 .25 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{2}.tcon.name = 'Int_TaskvsBaseline';
        matlabbatch{1}.spm.stats.con.consess{2}.tcon.weights = [0 0 0 0 .25 .25 .25 .25 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{2}.tcon.sessrep = 'none';

        % Cue Related Contrasts
        matlabbatch{1}.spm.stats.con.consess{3}.tcon.name = 'Cue_HighvsLowReward';
        matlabbatch{1}.spm.stats.con.consess{3}.tcon.weights = [0.5 0.5 -0.5 -0.5 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{3}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{4}.tcon.name = 'Cue_HighvsLowPenalty';
        matlabbatch{1}.spm.stats.con.consess{4}.tcon.weights = [0.5 -0.5 0.5 -0.5 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{4}.tcon.sessrep = 'none';

        % Interval Related Contrasts
        matlabbatch{1}.spm.stats.con.consess{5}.tcon.name = 'Int_HighvsLowReward';
        matlabbatch{1}.spm.stats.con.consess{5}.tcon.weights = [0 0 0 0 0.5 0.5 -0.5 -0.5 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{5}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{6}.tcon.name = 'Int_HighvsLowPenalty';
        matlabbatch{1}.spm.stats.con.consess{6}.tcon.weights = [0 0 0 0 0.5 -0.5 0.5 -0.5 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{6}.tcon.sessrep = 'none';

    
    %% GLM 3: 12 regressors: 4 Cues, 4 Int, 4 Fb
    elseif strcmp(design_foldername,'glm3_Event_CueIntFb_rwls')

        % Task Contrasts (Control: Task vs. Baseline)
        matlabbatch{1}.spm.stats.con.consess{1}.tcon.name = 'Cue_TaskvsBaseline';
        matlabbatch{1}.spm.stats.con.consess{1}.tcon.weights = [.25 .25 .25 .25 0 0 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{2}.tcon.name = 'Int_TaskvsBaseline';
        matlabbatch{1}.spm.stats.con.consess{2}.tcon.weights = [0 0 0 0 .25 .25 .25 .25 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{2}.tcon.sessrep = 'none';

        % Cue Related Contrasts
        matlabbatch{1}.spm.stats.con.consess{3}.tcon.name = 'Cue_HighvsLowReward';
        matlabbatch{1}.spm.stats.con.consess{3}.tcon.weights = [0.5 0.5 -0.5 -0.5 0 0 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{3}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{4}.tcon.name = 'Cue_HighvsLowPenalty';
        matlabbatch{1}.spm.stats.con.consess{4}.tcon.weights = [0.5 -0.5 0.5 -0.5 0 0 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{4}.tcon.sessrep = 'none';

        % Interval Related Contrasts
        matlabbatch{1}.spm.stats.con.consess{5}.tcon.name = 'Int_HighvsLowReward';
        matlabbatch{1}.spm.stats.con.consess{5}.tcon.weights = [0 0 0 0 0.5 0.5 -0.5 -0.5 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{5}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{6}.tcon.name = 'Int_HighvsLowPenalty';
        matlabbatch{1}.spm.stats.con.consess{6}.tcon.weights = [0 0 0 0 0.5 -0.5 0.5 -0.5 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{6}.tcon.sessrep = 'none';

        % Feedback Related Contrasts
        matlabbatch{1}.spm.stats.con.consess{7}.tcon.name = 'Fb_HighvsLowReward';
        matlabbatch{1}.spm.stats.con.consess{7}.tcon.weights = [0 0 0 0 0 0 0 0 0.5 0.5 -0.5 -0.5 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{7}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{8}.tcon.name = 'Fb_HighvsLowPenalty';
        matlabbatch{1}.spm.stats.con.consess{8}.tcon.weights = [0 0 0 0 0 0 0 0 0.5 -0.5 0.5 -0.5 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{8}.tcon.sessrep = 'none';

    %% GLM 4: Baseline Pmod with Reward, Penalty (8 regressors)
    elseif strcmp(design_foldername,'glm4_Pmod_RewPen_rwls')
    
        % Parametric Modulator Contrasts 
        % Cues
        matlabbatch{1}.spm.stats.con.consess{1}.tcon.name = 'Cues';
        matlabbatch{1}.spm.stats.con.consess{1}.tcon.weights = [1 0 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{2}.tcon.name = 'CuesxRew';
        matlabbatch{1}.spm.stats.con.consess{2}.tcon.weights = [0 1 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{3}.tcon.name = 'CuesxPen';
        matlabbatch{1}.spm.stats.con.consess{3}.tcon.weights = [0 0 1 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{3}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{4}.tcon.name = 'CuesxRew-Pen';
        matlabbatch{1}.spm.stats.con.consess{4}.tcon.weights = [0 1 -1 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{4}.tcon.sessrep = 'none';
        % Response Intervals
        matlabbatch{1}.spm.stats.con.consess{5}.tcon.name = 'Int';
        matlabbatch{1}.spm.stats.con.consess{5}.tcon.weights = [0 0 0 1 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{5}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{6}.tcon.name = 'IntxRew';
        matlabbatch{1}.spm.stats.con.consess{6}.tcon.weights = [0 0 0 0 1 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{6}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{7}.tcon.name = 'IntxPen';
        matlabbatch{1}.spm.stats.con.consess{7}.tcon.weights = [0 0 0 0 0 1 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{7}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{8}.tcon.name = 'IntxRew-Pen';
        matlabbatch{1}.spm.stats.con.consess{8}.tcon.weights = [0 0 0 0 1 -1 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{8}.tcon.sessrep = 'none';
        % Cue vs Resp Interval (Interval Minus Cue)
        matlabbatch{1}.spm.stats.con.consess{9}.tcon.name = 'Int-Cue';
        matlabbatch{1}.spm.stats.con.consess{9}.tcon.weights = [-1 0 0 1 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{9}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{10}.tcon.name = 'IntxRew-CuexRew';
        matlabbatch{1}.spm.stats.con.consess{10}.tcon.weights = [0 -1 0 0 1 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{10}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{11}.tcon.name = 'IntxPen-CuexPen';
        matlabbatch{1}.spm.stats.con.consess{11}.tcon.weights = [0 0 -1 0 0 1 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{11}.tcon.sessrep = 'none';
        % Feedback
        matlabbatch{1}.spm.stats.con.consess{12}.tcon.name = 'Fb';
        matlabbatch{1}.spm.stats.con.consess{12}.tcon.weights = [0 0 0 0 0 0 1 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{12}.tcon.sessrep = 'none';
        % Error
        matlabbatch{1}.spm.stats.con.consess{13}.tcon.name = 'Error';
        matlabbatch{1}.spm.stats.con.consess{13}.tcon.weights = [0 0 0 0 0 0 0 1 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{13}.tcon.sessrep = 'none';
        
    %% GLM 5: BASELINE Pmod with Reward, Penalty, Interval Num, Interval Length, Mean Congruency (12 regressors)
    elseif strcmp(design_foldername,'glm5_Pmod_RewPenTask_rwls')
        
        % Parametric Modulator Contrasts 
        % Cues
        matlabbatch{1}.spm.stats.con.consess{1}.tcon.name = 'Cues';
        matlabbatch{1}.spm.stats.con.consess{1}.tcon.weights = [1 0 0 0 0 0 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{2}.tcon.name = 'CuesxRew';
        matlabbatch{1}.spm.stats.con.consess{2}.tcon.weights = [0 1 0 0 0 0 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{3}.tcon.name = 'CuesxPen';
        matlabbatch{1}.spm.stats.con.consess{3}.tcon.weights = [0 0 1 0 0 0 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{3}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{4}.tcon.name = 'CuesxIntervalNum';
        matlabbatch{1}.spm.stats.con.consess{4}.tcon.weights = [0 0 0 1 0 0 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{4}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{5}.tcon.name = 'CuesxRew-Pen';
        matlabbatch{1}.spm.stats.con.consess{5}.tcon.weights = [0 1 -1 0 0 0 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{5}.tcon.sessrep = 'none';
        % Response Intervals
        matlabbatch{1}.spm.stats.con.consess{6}.tcon.name = 'Int';
        matlabbatch{1}.spm.stats.con.consess{6}.tcon.weights = [0 0 0 0 1 0 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{6}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{7}.tcon.name = 'IntxRew';
        matlabbatch{1}.spm.stats.con.consess{7}.tcon.weights = [0 0 0 0 0 1 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{7}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{8}.tcon.name = 'IntxPen';
        matlabbatch{1}.spm.stats.con.consess{8}.tcon.weights = [0 0 0 0 0 0 1 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{8}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{9}.tcon.name = 'IntxIntervalNum';
        matlabbatch{1}.spm.stats.con.consess{9}.tcon.weights = [0 0 0 0 0 0 0 1 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{9}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{10}.tcon.name = 'IntxIntervalLength';
        matlabbatch{1}.spm.stats.con.consess{10}.tcon.weights = [0 0 0 0 0 0 0 0 1 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{10}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{11}.tcon.name = 'IntxMeanCongruency';
        matlabbatch{1}.spm.stats.con.consess{11}.tcon.weights = [0 0 0 0 0 0 0 0 0 1 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{11}.tcon.sessrep = 'none';        
        matlabbatch{1}.spm.stats.con.consess{12}.tcon.name = 'IntxRew-Pen';
        matlabbatch{1}.spm.stats.con.consess{12}.tcon.weights = [0 0 0 0 0 1 -1 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{12}.tcon.sessrep = 'none';
        % Cue vs Resp Interval (Interval Minus Cue)
        matlabbatch{1}.spm.stats.con.consess{13}.tcon.name = 'Int-Cue';
        matlabbatch{1}.spm.stats.con.consess{13}.tcon.weights = [-1 0 0 0 1 0 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{13}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{14}.tcon.name = 'IntxRew-CuexRew';
        matlabbatch{1}.spm.stats.con.consess{14}.tcon.weights = [0 -1 0 0 0 1 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{14}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{15}.tcon.name = 'IntxPen-CuexPen';
        matlabbatch{1}.spm.stats.con.consess{15}.tcon.weights = [0 0 -1 0 0 0 1 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{15}.tcon.sessrep = 'none';       
        % Feedback
        matlabbatch{1}.spm.stats.con.consess{16}.tcon.name = 'Fb';
        matlabbatch{1}.spm.stats.con.consess{16}.tcon.weights = [0 0 0 0 0 0 0 0 0 0 1 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{16}.tcon.sessrep = 'none';
        % Error
        matlabbatch{1}.spm.stats.con.consess{17}.tcon.name = 'Error';
        matlabbatch{1}.spm.stats.con.consess{17}.tcon.weights = [0 0 0 0 0 0 0 0 0 0 0 1 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{17}.tcon.sessrep = 'none';

    %% GLM 6: BASELINE Pmod with Reward, Penalty, Interval Num, Interval Length, Mean Congruency, RT, Accuracy, RT*Rew, RT*Pen (16 regressors)
    elseif strcmp(design_foldername,'glm6_Pmod_RewPenTask_RTACC_rwls')
        
        % Parametric Modulator Contrasts 
        % Cues
        matlabbatch{1}.spm.stats.con.consess{1}.tcon.name = 'Cues';
        matlabbatch{1}.spm.stats.con.consess{1}.tcon.weights = [1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{2}.tcon.name = 'CuesxRew';
        matlabbatch{1}.spm.stats.con.consess{2}.tcon.weights = [0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{3}.tcon.name = 'CuesxPen';
        matlabbatch{1}.spm.stats.con.consess{3}.tcon.weights = [0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{3}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{4}.tcon.name = 'CuesxIntervalNum';
        matlabbatch{1}.spm.stats.con.consess{4}.tcon.weights = [0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{4}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{5}.tcon.name = 'CuesxRew-Pen';
        matlabbatch{1}.spm.stats.con.consess{5}.tcon.weights = [0 1 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{5}.tcon.sessrep = 'none';
        % Response Intervals
        matlabbatch{1}.spm.stats.con.consess{6}.tcon.name = 'Int';
        matlabbatch{1}.spm.stats.con.consess{6}.tcon.weights = [0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{6}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{7}.tcon.name = 'IntxRew';
        matlabbatch{1}.spm.stats.con.consess{7}.tcon.weights = [0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{7}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{8}.tcon.name = 'IntxPen';
        matlabbatch{1}.spm.stats.con.consess{8}.tcon.weights = [0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{8}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{9}.tcon.name = 'IntxIntervalNum';
        matlabbatch{1}.spm.stats.con.consess{9}.tcon.weights = [0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{9}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{10}.tcon.name = 'IntxIntervalLength';
        matlabbatch{1}.spm.stats.con.consess{10}.tcon.weights = [0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{10}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{11}.tcon.name = 'IntxMeanCongruency';
        matlabbatch{1}.spm.stats.con.consess{11}.tcon.weights = [0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{11}.tcon.sessrep = 'none';            
        matlabbatch{1}.spm.stats.con.consess{12}.tcon.name = 'IntxavgRT';
        matlabbatch{1}.spm.stats.con.consess{12}.tcon.weights = [0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{12}.tcon.sessrep = 'none';        
        matlabbatch{1}.spm.stats.con.consess{13}.tcon.name = 'IntxavgACC';
        matlabbatch{1}.spm.stats.con.consess{13}.tcon.weights = [0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{13}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{14}.tcon.name = 'IntxavgRTxRew';
        matlabbatch{1}.spm.stats.con.consess{14}.tcon.weights = [0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{14}.tcon.sessrep = 'none';  
        matlabbatch{1}.spm.stats.con.consess{15}.tcon.name = 'IntxavgRTxPen';
        matlabbatch{1}.spm.stats.con.consess{15}.tcon.weights = [0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{15}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{16}.tcon.name = 'IntxRew-Pen';
        matlabbatch{1}.spm.stats.con.consess{16}.tcon.weights = [0 0 0 0 0 1 -1 0 0 0 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{16}.tcon.sessrep = 'none';
        % Cue vs Resp Interval (Interval Minus Cue)
        matlabbatch{1}.spm.stats.con.consess{17}.tcon.name = 'Int-Cue';
        matlabbatch{1}.spm.stats.con.consess{17}.tcon.weights = [-1 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{17}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{18}.tcon.name = 'IntxRew-CuexRew';
        matlabbatch{1}.spm.stats.con.consess{18}.tcon.weights = [0 -1 0 0 0 1 0 0 0 0 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{18}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{19}.tcon.name = 'IntxPen-CuexPen';
        matlabbatch{1}.spm.stats.con.consess{19}.tcon.weights = [0 0 -1 0 0 0 1 0 0 0 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{19}.tcon.sessrep = 'none';
        % Feedback
        matlabbatch{1}.spm.stats.con.consess{20}.tcon.name = 'Fb';
        matlabbatch{1}.spm.stats.con.consess{20}.tcon.weights = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{20}.tcon.sessrep = 'none';
        % Error
        matlabbatch{1}.spm.stats.con.consess{21}.tcon.name = 'Error';
        matlabbatch{1}.spm.stats.con.consess{21}.tcon.weights = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{21}.tcon.sessrep = 'none';
        
    %% GLM 7: BASELINE Pmod with Reward, Penalty, Rew*Pen, Interval Num, Interval Length, Mean Congruency, RT, Accuracy, RT*Rew, RT*Pen (18 regressors)
    elseif strcmp(design_foldername,'glm7_Pmod_RewPenTask_RTACC_interact_rwls')
        
     % Parametric Modulator Contrasts 
        % Cues
        matlabbatch{1}.spm.stats.con.consess{1}.tcon.name = 'Cues';
        matlabbatch{1}.spm.stats.con.consess{1}.tcon.weights = [1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{2}.tcon.name = 'CuesxRew';
        matlabbatch{1}.spm.stats.con.consess{2}.tcon.weights = [0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{3}.tcon.name = 'CuesxPen';
        matlabbatch{1}.spm.stats.con.consess{3}.tcon.weights = [0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{3}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{4}.tcon.name = 'CuesxIntervalNum';
        matlabbatch{1}.spm.stats.con.consess{4}.tcon.weights = [0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{4}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{5}.tcon.name = 'CuesxRewxPen';
        matlabbatch{1}.spm.stats.con.consess{5}.tcon.weights = [0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{5}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{6}.tcon.name = 'CuesxRew-Pen';
        matlabbatch{1}.spm.stats.con.consess{6}.tcon.weights = [0 1 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{6}.tcon.sessrep = 'none';
        % Response Intervals
        matlabbatch{1}.spm.stats.con.consess{7}.tcon.name = 'Int';
        matlabbatch{1}.spm.stats.con.consess{7}.tcon.weights = [0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{7}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{8}.tcon.name = 'IntxRew';
        matlabbatch{1}.spm.stats.con.consess{8}.tcon.weights = [0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{8}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{9}.tcon.name = 'IntxPen';
        matlabbatch{1}.spm.stats.con.consess{9}.tcon.weights = [0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{9}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{10}.tcon.name = 'IntxIntervalNum';
        matlabbatch{1}.spm.stats.con.consess{10}.tcon.weights = [0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{10}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{11}.tcon.name = 'IntxIntervalLength';
        matlabbatch{1}.spm.stats.con.consess{11}.tcon.weights = [0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{11}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{12}.tcon.name = 'IntxMeanCongruency';
        matlabbatch{1}.spm.stats.con.consess{12}.tcon.weights = [0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{12}.tcon.sessrep = 'none';            
        matlabbatch{1}.spm.stats.con.consess{13}.tcon.name = 'IntxavgRT';
        matlabbatch{1}.spm.stats.con.consess{13}.tcon.weights = [0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{13}.tcon.sessrep = 'none';        
        matlabbatch{1}.spm.stats.con.consess{14}.tcon.name = 'IntxavgACC';
        matlabbatch{1}.spm.stats.con.consess{14}.tcon.weights = [0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{14}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{15}.tcon.name = 'IntxavgRTxRew';
        matlabbatch{1}.spm.stats.con.consess{15}.tcon.weights = [0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{15}.tcon.sessrep = 'none';  
        matlabbatch{1}.spm.stats.con.consess{16}.tcon.name = 'IntxavgRTxPen';
        matlabbatch{1}.spm.stats.con.consess{16}.tcon.weights = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{16}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{17}.tcon.name = 'IntxRewxPen';
        matlabbatch{1}.spm.stats.con.consess{17}.tcon.weights = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{17}.tcon.sessrep = 'none';        
        matlabbatch{1}.spm.stats.con.consess{18}.tcon.name = 'IntxRew-Pen';
        matlabbatch{1}.spm.stats.con.consess{18}.tcon.weights = [0 0 0 0 0 0 1 -1 0 0 0 0 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{18}.tcon.sessrep = 'none';
        % Cue vs Resp Interval (Interval Minus Cue)
        matlabbatch{1}.spm.stats.con.consess{19}.tcon.name = 'Int-Cue';
        matlabbatch{1}.spm.stats.con.consess{19}.tcon.weights = [-1 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{19}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{20}.tcon.name = 'IntxRew-CuexRew';
        matlabbatch{1}.spm.stats.con.consess{20}.tcon.weights = [0 -1 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{20}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{21}.tcon.name = 'IntxPen-CuexPen';
        matlabbatch{1}.spm.stats.con.consess{21}.tcon.weights = [0 0 -1 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{21}.tcon.sessrep = 'none';
        % Feedback
        matlabbatch{1}.spm.stats.con.consess{22}.tcon.name = 'Fb';
        matlabbatch{1}.spm.stats.con.consess{22}.tcon.weights = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{22}.tcon.sessrep = 'none';
        % Error
        matlabbatch{1}.spm.stats.con.consess{23}.tcon.name = 'Error';
        matlabbatch{1}.spm.stats.con.consess{23}.tcon.weights = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{23}.tcon.sessrep = 'none';

    %% GLM 8: BASELINE Pmod with Reward, Penalty, CueFixed, Interval Num, Interval Length, Mean Congruency, RT, Accuracy, RT*Rew, RT*Pen (20 regressors)
    elseif strcmp(design_foldername,'glm8_Pmod_RewPenTask_RTACC_CueFixed_rwls')

        % Parametric Modulator Contrasts 
        % Cues
        matlabbatch{1}.spm.stats.con.consess{1}.tcon.name = 'RFixCues';
        matlabbatch{1}.spm.stats.con.consess{1}.tcon.weights = [1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{2}.tcon.name = 'RFixCuesxRew';
        matlabbatch{1}.spm.stats.con.consess{2}.tcon.weights = [0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{3}.tcon.name = 'RFixCuesxPen';
        matlabbatch{1}.spm.stats.con.consess{3}.tcon.weights = [0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{3}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{4}.tcon.name = 'RFixCuesxIntervalNum';
        matlabbatch{1}.spm.stats.con.consess{4}.tcon.weights = [0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{4}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{5}.tcon.name = 'RFixCuesxRew-Pen';
        matlabbatch{1}.spm.stats.con.consess{5}.tcon.weights = [0 1 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{5}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{6}.tcon.name = 'PFixCues';
        matlabbatch{1}.spm.stats.con.consess{6}.tcon.weights = [0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{6}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{7}.tcon.name = 'PFixCuesxRew';
        matlabbatch{1}.spm.stats.con.consess{7}.tcon.weights = [0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{7}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{8}.tcon.name = 'PFixCuesxPen';
        matlabbatch{1}.spm.stats.con.consess{8}.tcon.weights = [0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{8}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{9}.tcon.name = 'PFixCuesxIntervalNum';
        matlabbatch{1}.spm.stats.con.consess{9}.tcon.weights = [0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{9}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{10}.tcon.name = 'PFixCuesxRew-Pen';
        matlabbatch{1}.spm.stats.con.consess{10}.tcon.weights = [0 0 0 0 0 1 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{10}.tcon.sessrep = 'none';
        % Response Intervals
        matlabbatch{1}.spm.stats.con.consess{11}.tcon.name = 'Int';
        matlabbatch{1}.spm.stats.con.consess{11}.tcon.weights = [0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{11}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{12}.tcon.name = 'IntxRew';
        matlabbatch{1}.spm.stats.con.consess{12}.tcon.weights = [0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{12}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{13}.tcon.name = 'IntxPen';
        matlabbatch{1}.spm.stats.con.consess{13}.tcon.weights = [0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{13}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{14}.tcon.name = 'IntxIntervalNum';
        matlabbatch{1}.spm.stats.con.consess{14}.tcon.weights = [0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{14}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{15}.tcon.name = 'IntxIntervalLength';
        matlabbatch{1}.spm.stats.con.consess{15}.tcon.weights = [0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{15}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{16}.tcon.name = 'IntxMeanCongruency';
        matlabbatch{1}.spm.stats.con.consess{16}.tcon.weights = [0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{16}.tcon.sessrep = 'none';            
        matlabbatch{1}.spm.stats.con.consess{17}.tcon.name = 'IntxavgRT';
        matlabbatch{1}.spm.stats.con.consess{17}.tcon.weights = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{17}.tcon.sessrep = 'none';        
        matlabbatch{1}.spm.stats.con.consess{18}.tcon.name = 'IntxavgACC';
        matlabbatch{1}.spm.stats.con.consess{18}.tcon.weights = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{18}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{19}.tcon.name = 'IntxavgRTxRew';
        matlabbatch{1}.spm.stats.con.consess{19}.tcon.weights = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{19}.tcon.sessrep = 'none';  
        matlabbatch{1}.spm.stats.con.consess{20}.tcon.name = 'IntxavgRTxPen';
        matlabbatch{1}.spm.stats.con.consess{20}.tcon.weights = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{20}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{21}.tcon.name = 'IntxRew-Pen';
        matlabbatch{1}.spm.stats.con.consess{21}.tcon.weights = [0 0 0 0 0 0 0 0 0 1 -1 0 0 0 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{21}.tcon.sessrep = 'none';
        % Cue vs Resp Interval (Interval Minus Cue)
        matlabbatch{1}.spm.stats.con.consess{22}.tcon.name = 'Int-RFixCue';
        matlabbatch{1}.spm.stats.con.consess{22}.tcon.weights = [-1 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{22}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{23}.tcon.name = 'IntxRew-RFixCuexRew';
        matlabbatch{1}.spm.stats.con.consess{23}.tcon.weights = [0 -1 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{23}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{24}.tcon.name = 'IntxPen-RFixCuexPen';
        matlabbatch{1}.spm.stats.con.consess{24}.tcon.weights = [0 0 -1 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{24}.tcon.sessrep = 'none';      
        matlabbatch{1}.spm.stats.con.consess{25}.tcon.name = 'Int-PFixCue';
        matlabbatch{1}.spm.stats.con.consess{25}.tcon.weights = [0 0 0 0 -1 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{25}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{26}.tcon.name = 'IntxRew-PFixCuexRew';
        matlabbatch{1}.spm.stats.con.consess{26}.tcon.weights = [0 0 0 0 0 -1 0 0 0 1 0 0 0 0 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{26}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{27}.tcon.name = 'IntxPen-PFixCuexPen';
        matlabbatch{1}.spm.stats.con.consess{27}.tcon.weights = [0 0 0 0 0 0 -1 0 0 0 1 0 0 0 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{27}.tcon.sessrep = 'none';       
        % Feedback
        matlabbatch{1}.spm.stats.con.consess{28}.tcon.name = 'Fb';
        matlabbatch{1}.spm.stats.con.consess{28}.tcon.weights = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{28}.tcon.sessrep = 'none';
        % Error
        matlabbatch{1}.spm.stats.con.consess{29}.tcon.name = 'Error';
        matlabbatch{1}.spm.stats.con.consess{29}.tcon.weights = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{29}.tcon.sessrep = 'none';

    %% GLM 9: BASELINE Pmod with Reward, Penalty, Rew*Pen, Interval Num, Interval Length, Mean Congruency, RT, Accuracy, RT*Rew, RT*Pen (23 regressors)
    elseif strcmp(design_foldername,'glm9_Pmod_RewPenTask_RTACC_CueFixed_interact_rwls')

        % Parametric Modulator Contrasts 
        % Cues
        matlabbatch{1}.spm.stats.con.consess{1}.tcon.name = 'RFixCues';
        matlabbatch{1}.spm.stats.con.consess{1}.tcon.weights = [1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{2}.tcon.name = 'RFixCuesxRew';
        matlabbatch{1}.spm.stats.con.consess{2}.tcon.weights = [0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{3}.tcon.name = 'RFixCuesxPen';
        matlabbatch{1}.spm.stats.con.consess{3}.tcon.weights = [0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{3}.tcon.sessrep = 'none';     
        matlabbatch{1}.spm.stats.con.consess{4}.tcon.name = 'RFixCuesxIntervalNum';
        matlabbatch{1}.spm.stats.con.consess{4}.tcon.weights = [0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{4}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{5}.tcon.name = 'RFixCuesxRewxPen';
        matlabbatch{1}.spm.stats.con.consess{5}.tcon.weights = [0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{5}.tcon.sessrep = 'none';  
        matlabbatch{1}.spm.stats.con.consess{6}.tcon.name = 'RFixCuesxRew-Pen';
        matlabbatch{1}.spm.stats.con.consess{6}.tcon.weights = [0 1 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{6}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{7}.tcon.name = 'PFixCues';
        matlabbatch{1}.spm.stats.con.consess{7}.tcon.weights = [0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{7}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{8}.tcon.name = 'PFixCuesxRew';
        matlabbatch{1}.spm.stats.con.consess{8}.tcon.weights = [0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{8}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{9}.tcon.name = 'PFixCuesxPen';
        matlabbatch{1}.spm.stats.con.consess{9}.tcon.weights = [0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{9}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{10}.tcon.name = 'PFixCuesxIntervalNum';
        matlabbatch{1}.spm.stats.con.consess{10}.tcon.weights = [0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{10}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{11}.tcon.name = 'PFixCuesxRewxPen';
        matlabbatch{1}.spm.stats.con.consess{11}.tcon.weights = [0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{11}.tcon.sessrep = 'none';  
        matlabbatch{1}.spm.stats.con.consess{12}.tcon.name = 'PFixCuesxRew-Pen';
        matlabbatch{1}.spm.stats.con.consess{12}.tcon.weights = [0 0 0 0 0 1 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{12}.tcon.sessrep = 'none';
        % Response Intervals
        matlabbatch{1}.spm.stats.con.consess{13}.tcon.name = 'Int';
        matlabbatch{1}.spm.stats.con.consess{13}.tcon.weights = [0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{13}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{14}.tcon.name = 'IntxRew';
        matlabbatch{1}.spm.stats.con.consess{14}.tcon.weights = [0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{14}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{15}.tcon.name = 'IntxPen';
        matlabbatch{1}.spm.stats.con.consess{15}.tcon.weights = [0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{15}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{16}.tcon.name = 'IntxIntervalNum';
        matlabbatch{1}.spm.stats.con.consess{16}.tcon.weights = [0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{16}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{17}.tcon.name = 'IntxIntervalLength';
        matlabbatch{1}.spm.stats.con.consess{17}.tcon.weights = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{17}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{18}.tcon.name = 'IntxMeanCongruency';
        matlabbatch{1}.spm.stats.con.consess{18}.tcon.weights = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{18}.tcon.sessrep = 'none';            
        matlabbatch{1}.spm.stats.con.consess{19}.tcon.name = 'IntxavgRT';
        matlabbatch{1}.spm.stats.con.consess{19}.tcon.weights = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{19}.tcon.sessrep = 'none';        
        matlabbatch{1}.spm.stats.con.consess{20}.tcon.name = 'IntxavgACC';
        matlabbatch{1}.spm.stats.con.consess{20}.tcon.weights = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{20}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{21}.tcon.name = 'IntxavgRTxRew';
        matlabbatch{1}.spm.stats.con.consess{21}.tcon.weights = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{21}.tcon.sessrep = 'none';  
        matlabbatch{1}.spm.stats.con.consess{22}.tcon.name = 'IntxavgRTxPen';
        matlabbatch{1}.spm.stats.con.consess{22}.tcon.weights = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{22}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{23}.tcon.name = 'IntxavgRTxRewxPen';
        matlabbatch{1}.spm.stats.con.consess{23}.tcon.weights = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{23}.tcon.sessrep = 'none';        
        matlabbatch{1}.spm.stats.con.consess{24}.tcon.name = 'IntxRew-Pen';
        matlabbatch{1}.spm.stats.con.consess{24}.tcon.weights = [0 0 0 0 0 0 0 0 0 0 0 1 -1 0 0 0 0 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{24}.tcon.sessrep = 'none';
        % Cue vs Resp Interval (Interval Minus Cue)
        matlabbatch{1}.spm.stats.con.consess{25}.tcon.name = 'Int-RFixCue';
        matlabbatch{1}.spm.stats.con.consess{25}.tcon.weights = [-1 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{25}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{26}.tcon.name = 'IntxRew-RFixCuexRew';
        matlabbatch{1}.spm.stats.con.consess{26}.tcon.weights = [0 -1 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{26}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{27}.tcon.name = 'IntxPen-RFixCuexPen';
        matlabbatch{1}.spm.stats.con.consess{27}.tcon.weights = [0 0 -1 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{27}.tcon.sessrep = 'none';      
        matlabbatch{1}.spm.stats.con.consess{28}.tcon.name = 'Int-PFixCue';
        matlabbatch{1}.spm.stats.con.consess{28}.tcon.weights = [0 0 0 0 0 -1 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{28}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{29}.tcon.name = 'IntxRew-PFixCuexRew';
        matlabbatch{1}.spm.stats.con.consess{29}.tcon.weights = [0 0 0 0 0 0 -1 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{29}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{30}.tcon.name = 'IntxPen-PFixCuexPen';
        matlabbatch{1}.spm.stats.con.consess{30}.tcon.weights = [0 0 0 0 0 0 0 -1 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{30}.tcon.sessrep = 'none';       
        % Feedback
        matlabbatch{1}.spm.stats.con.consess{31}.tcon.name = 'Fb';
        matlabbatch{1}.spm.stats.con.consess{31}.tcon.weights = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{31}.tcon.sessrep = 'none';
        % Error
        matlabbatch{1}.spm.stats.con.consess{32}.tcon.name = 'Error';
        matlabbatch{1}.spm.stats.con.consess{32}.tcon.weights = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 zeros(1,num_nuisanceRegressors)];
        matlabbatch{1}.spm.stats.con.consess{32}.tcon.sessrep = 'none';

        %% GLM 10: AllIntervals, no contrast needed
    elseif strcmp(design_foldername,'glm10_AllIntervals_rwls')
        
       fprintf('GLM10 does not have a contrast. \n');
        
    else
        error('Not a valid design foldername! Check that your variables are correctly labelled')
    end


%% -------------- Run the Batch for fMRI contrasts -------------

spm_jobman('run', matlabbatch);


end