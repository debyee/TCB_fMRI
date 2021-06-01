function TCB_runLevel1_fMRIModelSpec_Estimate(participant_id,root_path, design_foldername, design_SOTS)
%function TCB_runLevel1_fMRIModelSpec_Estimate
%% TCB_runLevel1GLM_fMRIModelSpec_Estimate
% Script that takes participant ID number and runs an SPM batch script that
% sets up the fMRI Model Specification and Calculates the Beta Estimates
% for each of the regressors/conditions based upon the design matrix
 
%% ---------------- Initialize spm  ------------------------------
spm('defaults', 'FMRI');
spm_jobman('initcfg');                         % necessary for parallel job submits
spm_get_defaults('cmdline',true);              % command line, no pop-up

%% ---------------- Customize these variables -----------------------------

%participant_id = '2008';
%root_path = '/gpfs/data/ashenhav/mri-data/TCB/spm-data/'; % testing on oscar
%root_path = '/Volumes/dyee7/data/mri-data/TCB/spm-data/'; % testing local
%design_foldername = 'design_CueInt8_EventEpoch_rwls';
%design_SOTS = 'TCB_Event_CueInterval_GainLossHighLow_sots_allTcat';

%participant_id=('2012');
%root_path='/gpfs/data/ashenhav/mri-data/TCB/spm-data/';
%design_foldername='design_Cue4_Event_rwls';
%design_SOTS='TCB_Event_Cue_RewPenHighLow_sots_allTcat';

% Identify the functional runs
allRuns = dir(fullfile(root_path,['sub-',participant_id],'func/sub*.nii'));
allRuns = {allRuns(:).name}';
allRuns = fullfile(root_path,['sub-',participant_id],'func',allRuns);

% Directories for the batch
dir_spec = fullfile(root_path,['sub-',participant_id],design_foldername);
dir_SOTS = fullfile(root_path,['sub-',participant_id],'SOTS',[design_SOTS,'.mat']);
dir_motReg = fullfile(root_path,['sub-',participant_id],design_foldername,'curSubRegMat.mat');
dir_SPMfile = fullfile(root_path,['sub-',participant_id],design_foldername,'SPM.mat');


%% ---------------- Set Up the Batch variable -----------------------------
% Expand images
matlabbatch{1}.spm.util.exp_frames.files = allRuns;
matlabbatch{1}.spm.util.exp_frames.frames = Inf;
% Model Specification
matlabbatch{2}.spm.tools.rwls.fmri_rwls_spec.dir = {dir_spec};
matlabbatch{2}.spm.tools.rwls.fmri_rwls_spec.timing.units = 'secs';
matlabbatch{2}.spm.tools.rwls.fmri_rwls_spec.timing.RT = 1.2;
matlabbatch{2}.spm.tools.rwls.fmri_rwls_spec.timing.fmri_t = 16;
matlabbatch{2}.spm.tools.rwls.fmri_rwls_spec.timing.fmri_t0 = 8;
matlabbatch{2}.spm.tools.rwls.fmri_rwls_spec.sess.scans(1) = cfg_dep('Expand image frames: Expanded filename list.', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
matlabbatch{2}.spm.tools.rwls.fmri_rwls_spec.sess.cond = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {}, 'orth', {});
matlabbatch{2}.spm.tools.rwls.fmri_rwls_spec.sess.multi = {dir_SOTS};
matlabbatch{2}.spm.tools.rwls.fmri_rwls_spec.sess.regress = struct('name', {}, 'val', {});
matlabbatch{2}.spm.tools.rwls.fmri_rwls_spec.sess.multi_reg = {dir_motReg};
matlabbatch{2}.spm.tools.rwls.fmri_rwls_spec.sess.hpf = Inf;
matlabbatch{2}.spm.tools.rwls.fmri_rwls_spec.fact = struct('name', {}, 'levels', {});
matlabbatch{2}.spm.tools.rwls.fmri_rwls_spec.bases.hrf.derivs = [0 0];
matlabbatch{2}.spm.tools.rwls.fmri_rwls_spec.volt = 1;
matlabbatch{2}.spm.tools.rwls.fmri_rwls_spec.global = 'None';
matlabbatch{2}.spm.tools.rwls.fmri_rwls_spec.mthresh = 0.8;
matlabbatch{2}.spm.tools.rwls.fmri_rwls_spec.mask = {''};
matlabbatch{2}.spm.tools.rwls.fmri_rwls_spec.cvi = 'wls';
% Calculate Estimates
%matlabbatch{3}.spm.tools.rwls.fmri_rwls_est.spmmat = {dir_SPMfile};
%matlabbatch{3}.spm.stats.fmri_est.write_residuals = 1;
%matlabbatch{3}.spm.tools.rwls.fmri_rwls_est.method.Classical = 1;


%% -------------- Run the Batch for fMRI Model Specification  -------------

spm_jobman('run',matlabbatch);


%% -------------- Run the rWLS estimate manually -------------

cd(dir_spec);
s = load(dir_SPMfile);
spm_rwls_spm(s.SPM);
%out.beta = cellfun(@(fn)fullfile(SPM.swd,fn), cellstr(char(SPM.Vbeta(:).fname)),'UniformOutput',false);
%out.mask = {fullfile(SPM.swd,SPM.VM.fname)};
%out.resms = {fullfile(SPM.swd,SPM.VResMS.fname)};        


end