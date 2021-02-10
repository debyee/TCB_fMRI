function TCB_runLevel2_group(root_path,dir_contrast, design_foldername, contrast_name)
    %function TCB_runLevel2_group
    %% TCB_runLevel_fMRIModelSpec_Estimate
    % Script that takes participant ID number and runs an SPM batch script that
    % sets up the fMRI Model Specification and Calculates the Beta Estimates
    % for each of the regressors/conditions based upon the design matrix
     
    %% ---------------- Initialize spm  ------------------------------
    spm('defaults', 'FMRI');
    spm_jobman('initcfg');                         % necessary for parallel job submits
    
    %% ---------------- Customize these variables -----------------------------
    
    %participant_id = '2008';
    %root_path = '/Volumes/dyee7/data/mri-data/TCB/spm-data/'; % testing local
    %design_foldername = 'design_CueInt8_EventEpoch_rwls';
    %design_SOTS = 'TCB_Event_CueInterval_GainLossHighLow_sots_allTcat';
    
    root_path = '/gpfs/data/ashenhav/mri-data/TCB/spm-data/'; % testing on oscar
    dir_contrast='/gpfs/data/ashenhav/mri-data/TCB/spm-data/groupstats/design_Cue4_Event_rwls/C1_Cue_TaskvsBaseline';
    design_foldername='design_Cue4_Event_rwls';
    contrast_name='C1_Cue_TaskvsBaseline'; 
    %dir_participants=fullfile(dir_contrast,'/participant_numbers.txt');
 
    %% ---------------- Change directory -----------------------------
    % Change current directory to location of the subject design to write
    % contrasts in the same folder.
    
    % Identify contrast niftis
    allRuns = dir(fullfile(root_path,'groupstats',design_foldername,contrast_name,'/sub*.nii'));
    allRuns = {allRuns(:).name}';
    allRuns = fullfile(root_path,'groupstats',design_foldername,contrast_name,allRuns,',1');

    % % Identify the functional runs
    % allRuns = dir(fullfile(root_path,['sub-',participant_id],'func/sub*.nii'));
    % allRuns = {allRuns(:).name}';
    % allRuns = fullfile(root_path,['sub-',participant_id],'func',allRuns);
    
    % % Directories for the batch
    % dir_spec = fullfile(root_path,['sub-',participant_id],design_foldername);
    % dir_SOTS = fullfile(root_path,['sub-',participant_id],'SOTS',[design_SOTS,'.mat']);
    % dir_motReg = fullfile(root_path,['sub-',participant_id],design_foldername,'curSubRegMat.mat');
    % dir_SPMfile = fullfile(root_path,['sub-',participant_id],design_foldername,'SPM.mat');
    
    
    %% ---------------- Set Up the Batch variable -----------------------------
    % Model Speification
    matlabbatch{1}.spm.stats.factorial_design.dir = {dir_contrast};
    matlabbatch{1}.spm.stats.factorial_design.des.t1.scans = {allRuns};
    matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
    matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
    matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
    matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
    matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
    matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
    % Factorial Design specification
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
    matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
    % Model Estimation
    matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = contrast_name;
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = 1;
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.delete = 0;
    
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