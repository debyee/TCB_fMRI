function TCB_runLevel1_contrast(participant_id,root_path, design_foldername)
% function TCB_runLevel1_contrast
% Script that creates contrasts at first level analysis (single subject)

%% ---------------- Initialize spm  ------------------------------
spm('defaults', 'FMRI');
spm_jobman('initcfg');                         % necessary for parallel job submits

%% ---------------- Customize these variables -----------------------------

%participant_id=('2014');
%root_path='/gpfs/data/ashenhav/mri-data/TCB/spm-data/';
%design_foldername='design_Cue4_Event_rwls';

% Directories for the batch
dir_level1Data = fullfile(root_path,['sub-',participant_id],design_foldername);
dir_SPMfile = fullfile(root_path,['sub-',participant_id],design_foldername,'SPM.mat');

%% ---------------- Change directory -----------------------------
% Change current directory to location of the subject design to write
% contrasts in the same folder.
cd(dir_level1Data);

%% ---------------- Set Up the Batch variable ------------------------------
% Identify the spm mat file to read in.
matlabbatch{1}.spm.stats.con.spmmat = {dir_SPMfile};

% Task Contrasts (Control: Task vs. Baseline)
matlabbatch{1}.spm.stats.con.consess{1}.tcon.name = 'Cue_TaskvsBaseline';
matlabbatch{1}.spm.stats.con.consess{1}.tcon.weights = [.25 .25 .25 .25 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
matlabbatch{1}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
matlabbatch{1}.spm.stats.con.consess{2}.tcon.name = 'Int_TaskvsBaseline';
matlabbatch{1}.spm.stats.con.consess{2}.tcon.weights = [0 0 0 0 .25 .25 .25 .25 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
matlabbatch{1}.spm.stats.con.consess{2}.tcon.sessrep = 'none';

% Cue Related Contrasts
matlabbatch{1}.spm.stats.con.consess{3}.tcon.name = 'Cue_HighvsLowReward';
matlabbatch{1}.spm.stats.con.consess{3}.tcon.weights = [0.5 0.5 -0.5 -0.5 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
matlabbatch{1}.spm.stats.con.consess{3}.tcon.sessrep = 'none';
matlabbatch{1}.spm.stats.con.consess{4}.tcon.name = 'Cue_HighvsLowPenalty';
matlabbatch{1}.spm.stats.con.consess{4}.tcon.weights = [0.5 -0.5 0.5 -0.5 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
matlabbatch{1}.spm.stats.con.consess{4}.tcon.sessrep = 'none';

% Interval Related Contrasts
matlabbatch{1}.spm.stats.con.consess{5}.tcon.name = 'Int_HighvsLowReward';
matlabbatch{1}.spm.stats.con.consess{5}.tcon.weights = [0 0 0 0 0.5 0.5 -0.5 -0.5 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
matlabbatch{1}.spm.stats.con.consess{5}.tcon.sessrep = 'none';
matlabbatch{1}.spm.stats.con.consess{6}.tcon.name = 'Int_HighvsLowPenalty';
matlabbatch{1}.spm.stats.con.consess{6}.tcon.weights = [0 0 0 0 0.5 -0.5 0.5 -0.5 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
matlabbatch{1}.spm.stats.con.consess{6}.tcon.sessrep = 'none';

% Feedback Related Contrasts
matlabbatch{1}.spm.stats.con.consess{7}.tcon.name = 'Fb_HighvsLowReward';
matlabbatch{1}.spm.stats.con.consess{7}.tcon.weights = [0 0 0 0 0 0 0 0 0.5 0.5 -0.5 -0.5 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
matlabbatch{1}.spm.stats.con.consess{7}.tcon.sessrep = 'none';
matlabbatch{1}.spm.stats.con.consess{8}.tcon.name = 'Fb_HighvsLowPenalty';
matlabbatch{1}.spm.stats.con.consess{8}.tcon.weights = [0 0 0 0 0 0 0 0 0.5 -0.5 0.5 -0.5 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
matlabbatch{1}.spm.stats.con.consess{8}.tcon.sessrep = 'none';

% matlabbatch{1}.spm.stats.con.consess{5}.tcon.name = 'Cue_GAIN-HighvsLow';
% matlabbatch{1}.spm.stats.con.consess{5}.tcon.weights = [1 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
% matlabbatch{1}.spm.stats.con.consess{5}.tcon.sessrep = 'none';
% matlabbatch{1}.spm.stats.con.consess{6}.tcon.name = 'Cue_LOSS-HighvsLow';
% matlabbatch{1}.spm.stats.con.consess{6}.tcon.weights = [0 0 1 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
% matlabbatch{1}.spm.stats.con.consess{6}.tcon.sessrep = 'none';
% matlabbatch{1}.spm.stats.con.consess{7}.tcon.name = 'Cue_HIGH-GainvsLoss';
% matlabbatch{1}.spm.stats.con.consess{7}.tcon.weights = [1 0 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
% matlabbatch{1}.spm.stats.con.consess{7}.tcon.sessrep = 'none';
% matlabbatch{1}.spm.stats.con.consess{8}.tcon.name = 'Cue_LOW-GainvsLoss';
% matlabbatch{1}.spm.stats.con.consess{8}.tcon.weights = [0 1 0 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
% matlabbatch{1}.spm.stats.con.consess{8}.tcon.sessrep = 'none';

% Interval Related Contrasts
% matlabbatch{1}.spm.stats.con.consess{9}.tcon.name = 'Int_HighvsLow';
% matlabbatch{1}.spm.stats.con.consess{9}.tcon.weights = [0 0 0 0 0.5 -0.5 0.5 -0.5 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
% matlabbatch{1}.spm.stats.con.consess{9}.tcon.sessrep = 'none';
% matlabbatch{1}.spm.stats.con.consess{10}.tcon.name = 'Int_GainvsLoss';
% matlabbatch{1}.spm.stats.con.consess{10}.tcon.weights = [0 0 0 0 0.5 0.5 -0.5 -0.5 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
% matlabbatch{1}.spm.stats.con.consess{10}.tcon.sessrep = 'none';
% matlabbatch{1}.spm.stats.con.consess{11}.tcon.name = 'Int_GAIN-HighvsLow';
% matlabbatch{1}.spm.stats.con.consess{11}.tcon.weights = [0 0 0 0 1 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
% matlabbatch{1}.spm.stats.con.consess{11}.tcon.sessrep = 'none';
% matlabbatch{1}.spm.stats.con.consess{12}.tcon.name = 'Int_LOSS-HighvsLow';
% matlabbatch{1}.spm.stats.con.consess{12}.tcon.weights = [0 0 0 0 0 0 1 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
% matlabbatch{1}.spm.stats.con.consess{12}.tcon.sessrep = 'none';
% matlabbatch{1}.spm.stats.con.consess{13}.tcon.name = 'Int_HIGH-GainvsLoss';
% matlabbatch{1}.spm.stats.con.consess{13}.tcon.weights = [0 0 0 0 1 0 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
% matlabbatch{1}.spm.stats.con.consess{13}.tcon.sessrep = 'none';
% matlabbatch{1}.spm.stats.con.consess{14}.tcon.name = 'Int_LOW-GainvsLoss';
% matlabbatch{1}.spm.stats.con.consess{14}.tcon.weights = [0 0 0 0 0 1 0 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
% matlabbatch{1}.spm.stats.con.consess{14}.tcon.sessrep = 'none';
% Flag to overwrite existing contrasts
matlabbatch{1}.spm.stats.con.delete = 1;

%% -------------- Run the Batch for fMRI contrasts -------------

spm_jobman('run', matlabbatch);


end