function TCB_wholeBrain_TFCE(root_dir, spm_dir, name, varargin)
%% this is adapted from a script originally written by
% Harrison Ritz 2021 


% debugging
% root_dir="/oscar/data/ashenhav/mri-data/TCB/"
% spm_dir="/oscar/data/ashenhav/mri-data/analysistools/spm12"
% name="glm7_Pmod_RewPenTask_RTACC_interact_rwls"

nPerm = 10000;


dir(root_dir)
%% === set variables
addpath(genpath(spm_dir)); % add spm12 folder with bug-squashed rwls
spm('defaults', 'fmri')
tfceDir = sprintf('tfce%d', nPerm);

% set default RAM & use RAM for analysis
spm_get_defaults('maxmem', 128 * 2^30)
spm_get_defaults('resmem',true)
spm_get_defaults('cmdline',true)



%% load variables 
% GLM name
% name = varargin{1};

if length(varargin) >= 1 && ~isempty(varargin{1})
    maskName = varargin{1};
    tfceDir = [tfceDir, maskName]
else
    maskName = [];
    tfceDir = [tfceDir, '_wholeBrain']
end


%% folders & names
analysis    = sprintf('%s', name);
pt_dir      = sprintf('%s/spm-data/*/%s', root_dir, analysis);


%% === get conditions
wt_name = [];

% loads in contrast folders/names 
contrastFolders = dir(fullfile(root_dir, '/spm-data/groupstats/', name, 'C*_*'));

fileNames = {contrastFolders([contrastFolders.isdir]).name};



cons = 1:size(contrastFolders,1);

 %% === get mask
 if ~isempty(maskName)
    mask = fullfile(root_dir, 'masks', maskName);
    usemask =1;
 else
    mask =[];
    usemask =0;
 end



%% === estimate second level for each condition
spm_jobman('initcfg')

for cc = 1:length(cons)
    partialFileName = sprintf("C%d_", cc);

    % Find the index of files that contain the partial file name
    matchingIndex = find(contains(fileNames, partialFileName));


    % define save path
    %dirPALM = sprintf('%s/analysis/fmri/scripts/palm', root_dir);
    dirPALM = sprintf('%s/scripts/fmri-Preprocessing/palm', root_dir);
    
    %save_dir = sprintf('%s/spm-data/groupstats/%s/%s/%s', root_dir, analysis, contrastFolders(cons(cc)).name, tfceDir);
    %save_dir = sprintf('%s/spm-data/groupstats/%s/%s/%s', root_dir, analysis, char(fileNames(matchingIndex)), tfceDir);
    save_dir = sprintf('%s/spm-data/groupstats/%s/%s/%s', root_dir, analysis, char(fileNames(matchingIndex)), tfceDir);

    dirIN = fullfile(save_dir, 'con4D.nii');
    dirOUT = fullfile(save_dir, 'T');
    
    % make save path
    if exist(save_dir, 'dir')
        rmdir(save_dir, 's'); % remove existing results folder
    end
    mkdir(save_dir);
    
    


    % get files
    cl = dir(fullfile(pt_dir, sprintf('con_%.4d.nii', cons(cc))));
    cf = [];
    for ci = 1:length(cl)

        % read
        cf = fullfile(cl(ci).folder, cl(ci).name);
        VolIn = spm_vol(cf);

        % prep
        Vo      = struct(...
            'fname',    dirIN,...
            'dim',      VolIn(1).dim,...
            'dt',       [spm_type('float32') spm_platform('bigend')],...
            'mat',      VolIn(1).mat,...
            'n',        [ci 1],...
            'descrip',  'con');

        % write
        spm_write_vol(Vo, spm_read_vols(VolIn));

    end

    
    
    % batch -- convert to 4d
    %     matlabbatch = [];
    %
    %     matlabbatch{1}.spm.util.cat.vols = cf;
    %     matlabbatch{1}.spm.util.cat.name = dirIN;
    %     matlabbatch{1}.spm.util.cat.dtype = 0;
    %     matlabbatch{1}.spm.util.cat.RT = NaN;
    %
    %
    %     % === RUN BATCH
    %     tic
    %     spm_jobman('run', matlabbatch);
    %     toc
    
    
    % === TFCE =============
    system(sprintf('sbatch --export=dirPALM="%s",mask="%s",dirIN="%s",dirOUT="%s",nPerm=%d,usemask=%d %s/scripts/fmri-Preprocessing/runTFCE.sh', dirPALM, mask, dirIN, dirOUT, nPerm, usemask, root_dir))
    
    
end

end