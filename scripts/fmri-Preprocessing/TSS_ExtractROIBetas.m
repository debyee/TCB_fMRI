function TSS_ExtractROIBetas
%% Extract ROI Betas 
% NOTE: It is important to make sure that you have spm downloaded and the
% path added, as this script requires spm functions.

%% Add spm path
addpath /gpfs/data/ashenhav/mri-data/analysistools/spm12

%% Change These Variables (Directories, Subject Numbers, GLM name)

    % Relevant Directories (Change as needed)    
    dir_ROI = '/gpfs/data/ashenhav/mri-data/TCB/masks/TCB_FINAL_2023/'; 
    dir_ROI = '/gpfs/data/ashenhav
    dir_BETA = '/gpfs/data/ashenhav/mri-data/TCB/spm-data/';
    dir_save = '/gpfs/data/ashenhav/mri-data/TCB/data/fMRI/fMRI-BetaExport_2023-05-16';
    
    % Subject Numbers
    % NOTE: Subject 2047 and 2112 did not work for the GLM, need to debug on oscar.
    SUBIDS = [2011 2012 2013 2014 2015 2017 2019 ...
            2020 2021 2022 2024 2026 2027 2028 2029 ...
            2030 2031 2032 2033 2034 2035 2036 2037 2038 2039 ...
            2040 2041 2042 2043 2044 2045 2046 2048 2049 ... 
            2050 2051 2053 2054 2055 2057 2058 2059 ...
            2060 2061 2062 2063 2064 2065 2066 2067 2068 2069 ...
            2070 2071 2072 2073 2074 2075 2076 2077 2078 2079 ...
            2081 2082 2083 2084 2085 2086 2088 ...
            2090 2091 2093 2094 2097 2098 2099 ...
            2103 2105 2106 2107 2108 2109 ...
            2111 2113 2115 2116 2117 2118 2119 2120 ...
            2121 2122 2123 2124 2125 2126 2127];
    
   % SUBIDS = [2085]; % for testing only 
    
    GLM_name = 'glm10_AllIntervals_rwls';

%% Extract the Average Betas for each ROI

    % Initialize empty cells to store subject data into tables 
    subDataAll = {};      

    % Identify ROI Masks for Extraction
    ROIS = dir([dir_ROI,'*.nii']);
    ROIS = ROIS(~startsWith({ROIS.name},'.'));
    ROIS = {ROIS(:).name};
    
    % Load ROI Masks to cell array
    allROIMasks = cell(length(ROIS),4);
   
    for ri = 1:length(ROIS)
        
        % Column 1: Name of ROI Mask
        allROIMasks{ri,1} = ROIS{ri}(1:end-4);
        
        % Column 2: Filepath for ROI Mask
        allROIMasks{ri,2} = fullfile(dir_ROI,ROIS{ri});
        
        % Column 3: Identify header info for ROI mask
        % Use spm_vol if .img, or spm_vol_nifti if .nii extension
        if strcmp(allROIMasks{ri,2}(end-2:end),'img')
            allROIMasks{ri,3} = spm_vol(allROIMasks{ri,2});
        elseif strcmp(allROIMasks{ri,2}(end-2:end),'nii')
            allROIMasks{ri,3} = spm_vol_nifti(allROIMasks{ri,2});
        else
            error('Unrecognizable image format for ROI Mask (not .img or .nii) Please check your images.'); 
        end
        
        % Column 4: Loaded ROI mask 
        allROIMasks{ri,4} = spm_read_vols(allROIMasks{ri,3});
    end
    

    
    % Loop through Subjects and Extact Betas for each ROI and Interval
    for si = 1:length(SUBIDS) % si = 1
        
        % Note to indicate current subject
        disp(append("Extracting ROIs for Subject ", num2str(SUBIDS(si))))
       
        % Create allSubBetas cell to load beta estimates
        % Column 1: Beta Number
        allSubBetas = dir([dir_BETA,'sub-',num2str(SUBIDS(si)),'/',GLM_name,'/beta*.nii']);
        allSubBetas = {allSubBetas(:).name}';
        
        % Note if allSubBetas is empty, then report error
        if isempty(allSubBetas)
            error('allSubBetas cell is empty. Please check your spm-data folder for beta files.'); 
        end
        
        % Note to indicate current subject
        disp(append("Reading in Beta files for Subject ", num2str(SUBIDS(si))))
        
        for bi = 1:length(allSubBetas(:,1))

            % Column 2: Filepath for the Beta nifti
            allSubBetas{bi,2} = fullfile(dir_BETA,['sub-',num2str(SUBIDS(si))],GLM_name,allSubBetas{bi,1});
        
            % Column 3: Identify header info for Beta nifti
            % Use spm_vol if .img, or spm_vol_nifti if .nii extension
            if strcmp(allSubBetas{bi,2}(end-2:end),'img')
                allSubBetas{bi,3} = spm_vol(allSubBetas{bi,2});
            elseif strcmp(allSubBetas{bi,2}(end-2:end),'nii')
                allSubBetas{bi,3} = spm_vol_nifti(allSubBetas{bi,2});
            else
                error('Unrecognizable image format for Beta nifti (not .img or .nii) Please check your images.'); 
            end
                       
            % Column 4: Loaded Beta nifti 
            allSubBetas{bi,4} = spm_read_vols(allSubBetas{bi,3});

        end

        % Create cell table for subject beta extractions 
        allBetasExtracted = cell(length(allSubBetas(:,1)),length(ROIS)*3+2);
        allBetasExtracted(:,1) = repmat(num2cell(SUBIDS(si)),length(allSubBetas(:,1)),1);
        allBetasExtracted(:,2) = allSubBetas(:,1);
        
        % Note to indicate ROI extraction
        disp(append("Performing the ROI Extraction for Subject ", num2str(SUBIDS(si))))
        
        % Loop through ROIs and extract beta estimates for each subject
        for ri = 1:length(ROIS) % ri = 1
            
            % For each subject, loop through beta
            for bi = 1:length(allSubBetas(:,1))
  
               % Check that the ROI masks are same dimension as beta niftis
                if ~sum(allROIMasks{ri,3}.dim == allSubBetas{bi,3}.dim) == 3
                    error('ROI mask not same dimension as Beta image. Please check your image dimensions.'); 
                end 

                % Perform the roi extraction 
                % Reference AS_ExtractVals_auto.m or Andy's brain blog: 
                indx = find(allROIMasks{ri,4});
                colx = ri*3;
                allBetasExtracted{bi,colx} = nanmean(allSubBetas{bi,4}(indx));
                allBetasExtracted{bi,colx+1} = nanvar(allSubBetas{bi,4}(indx));
                allBetasExtracted{bi,colx+2} = length(indx);
                
                %tmp_roi = spm_read_vols(allROIMasks{bi,2},1);
                %indx = find(tmp_roi>0);
                %[x,y,z] = ind2sub(size(tmp_roi),indx);
                %[x,y,z] = ind2sub(size(tmp_roi),indx);
                %XYZ = [x y z]';
                %allBetasExtracted{bi,3} = nanmean(spm_get_data(allSubBetas{bi,4}, XYZ),2);
               
            end
        end

        % Create ROI labels for table
        label_mean = cellfun(@(c) [c '_mean'], allROIMasks(:,1), 'uni', false);
        label_var = cellfun(@(c) [c '_var'], allROIMasks(:,1), 'uni', false);
        label_voxel = cellfun(@(c) [c '_voxelnum'], allROIMasks(:,1), 'uni', false);
        label_ROIS = reshape([label_mean label_var label_voxel]',length(label_mean)*3,1);
        
        % After completing extraction per subject, consolidate 
        curSubData = cell2table(allBetasExtracted);
        curSubData_header = [{'SubID','BetaNum'}, label_ROIS'];
        curSubData.Properties.VariableNames = curSubData_header;
        
        
%         curSubData_header = {'SubID','BetaNum','DACC_mean','DACC_var','DACC_voxelnum', ...
%             'LeftAI_mean','LeftAI_var','LeftAI_voxelnum','LeftDLPFC_mean','LeftDLPFC_var','LeftDLPFC_voxelnum','LeftIFG_mean','LeftIFG_var','LeftIFG_voxelnum','LeftVS_mean','LeftVS_var','LeftVS_voxelnum', ...
%             'RightAI_mean','RightAI_var','RightAI_voxelnum','RightDLPFC_mean','RightDLPFC_var','RightDLPFC_voxelnum','RightIFG_mean','RightIFG_var','RightIFG_voxelnum','RightVS_mean','RightVS_var','RightVS_voxelnum', ...
%             'VMPFC_mean','VMPFC_var','VMPFC_voxelnum'};
        
        
        %% CONCATENATE DATA TABLES ACROSS SUBJECTS 
        % subDataAll = vertcat(subDataAll,curSubData); 
        
        %% SAVE THE DATA AFTER EVER SUBJECT ADDED
        pathToSave_Beta = strcat(dir_save,'/data_fMRI-TCB_RewardPenalty_BetasExtracted_sub-',num2str(SUBIDS(si)),'.csv');
        writetable(curSubData,pathToSave_Beta);
        %writetable(subDataAll,pathToSave_Beta);
        
        disp(append("ROI Extraction Complete for Subject ", num2str(SUBIDS(si))))

    end
    
    
% Note to indicate completed
disp(append("ROI Extraction Complete for All Subjects!"))


end

% spm_vol(allROIMasks{1,1})
% 
% spm_vol_nifti([dir_BETAs,'sub-2074/design_AllIntervals_rwls/beta_0001.nii'])
