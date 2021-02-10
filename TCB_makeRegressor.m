function TCB_makeRegressor(design_foldername)
% Takes in subnum, which is a numeric variable of the subject number.
% NOTE: you must run this from the 'scripts' folder in TCB, and there must
% be a "spm-data" folder in TCB. otherwise this script will not work. (Will
% need to likely fix in the long run but this seemed the most reasonable
% for not hard coding any variables in here)

% design_foldername='design_Cue4_Event';
% subnum=2002;

if exist('design_foldername') 

    % Create array of subjects
    cur_path = pwd;
    allSubs = dir(fullfile(cur_path(1:end-7),['spm-data/sub*']));
    allSubs = {allSubs(:).name};
    numSubs = length(allSubs);
    
    % Loop over the subject folders
    for subi = 1:numSubs
        
         
        %% ------ Create Regressor for Intercepts and Demeaned Blockeds ----------
        % Create array of nifti runs, if exists then make regressors. 
        % If niftis don't exist, then skip the subject 
        allRuns = dir(fullfile(cur_path(1:end-7),'spm-data/',char(allSubs(subi)),'func/sub*.nii'));
        if size(allRuns,1)>0
            
            allRuns = {allRuns(:).name};
            numBlocks = length(allRuns);
            
            % Loop through all blocks and create an array with the intercepts and demeaned values
            for runi = 1:numBlocks
                
                % extract nifit header info to get image size per run
                block_info = niftiinfo(fullfile(cur_path(1:end-7),'spm-data/',char(allSubs(subi)),'func/',char(allRuns(runi))));
                numActualTRsPerBlock =  block_info.ImageSize(4);
                
                % initialize empty array to fill
                tmpAllMeans = zeros(numActualTRsPerBlock,numBlocks-1);
                tmpAllTrends = zeros(numActualTRsPerBlock,numBlocks);
                
                % assign values to the arrays
                if runi<length(allRuns)
                    tmpAllMeans(1:numActualTRsPerBlock,runi) = 1;
                end
                tmpAllTrends(1:numActualTRsPerBlock,runi) = linspace(-1,1,numActualTRsPerBlock);
                
                % Concatenate the arrays
                tmpR = horzcat(tmpAllMeans,tmpAllTrends);
                if runi==1
                    R = tmpR;
                else
                    R = vertcat(R,tmpR);
                end
                
            end
            
            % Create names for the regressors to be saved along with the 'R' matrix
            names_Means = arrayfun(@(x) strcat('M',x),num2str(1:size(tmpAllMeans,2),'%1d'),'UniformOutput',false);
            names_Trends = arrayfun(@(x) strcat('T',x),num2str(1:size(tmpAllTrends,2),'%1d'),'UniformOutput',false);
            names = {names_Means{:},names_Trends{:}};
            
            % Save Regressor Matrix and save to subject design folder
            if ~exist(design_foldername)
                designPath = strcat(cur_path(1:end-7),'spm-data/',char(allSubs(subi)),'/',design_foldername);
                mkdir(designPath)
            end
            curSubPath = fullfile(cur_path(1:end-7),'spm-data/',char(allSubs(subi)),design_foldername,'curSubRegMat.mat');
            save(curSubPath,'R','names');
            disp(['Success! You have saved the Intercept Regressor Matrix for SPM for ',char(allSubs(subi))]);
            
            %% ------ Create Regressor for Motion Parameters ----------
            % Create array of confound files
            cur_path = pwd;
            confoundFiles = dir(fullfile(cur_path(1:end-7),'spm-data/',char(allSubs(subi)),'confounds/*regressors.tsv'));
            confoundFiles = {confoundFiles(:).name};
            numConfFiles = length(confoundFiles);
            
            % Loop over each of the confounds and create an array with all
            % confounds
            for confi = 1:numConfFiles
                
                % Read in confound file
                tmpcf = tdfread(fullfile(cur_path(1:end-7),'spm-data/',char(allSubs(subi)),'confounds/',char(confoundFiles(confi))));
                
                % Create regressor matrix and array of names
                tmpR = horzcat(tmpcf.trans_x, tmpcf.trans_y, tmpcf.trans_z,tmpcf.rot_x, tmpcf.rot_y, tmpcf.rot_z);
                names = {'tx','ty','tz','rx','ry','rz'};
                
                % Concatenate arrays
                if confi==1
                    R = tmpR;
                else
                    R = vertcat(R,tmpR);
                end
                
            end
            
            % Save Regressor Matrix and save to subject design folder
            curSubPath = fullfile(cur_path(1:end-7),'spm-data/',char(allSubs(subi)),design_foldername,'curMotionRegMat.mat');
            save(curSubPath,'R','names');
            disp(['Success! You have saved the Motion Regressor Matrix for SPM for ',char(allSubs(subi))]);
            
        elseif size(allRuns,1)==0
            disp(['Error! No nifits were detected for ',char(allSubs(subi)),'. Regressors were not created for this subject.']);
        else
            disp(['Error with detecting nifti files for ',char(allSubs(subi))]);
        end
    end
    
else
    disp('Design (Condition) Folder Name not detected. Regressors could not be created.');
end


end