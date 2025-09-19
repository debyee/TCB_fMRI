function [p,practice,results] = setSubID(p)
%function [p,practice] = setSubID(p)
%SUBIDSETUP Summary of this function goes here
%   Detailed explanation goes here



%% Load practice files
pFiles = dir('Results/*_practice_*.mat');
pFileNames = {pFiles(:).name};
pFileNames = cell2mat(pFileNames);


%% Load results files
files = dir([p.session.versionPath,'/Results/*.mat']);
fileNames = {files(:).name};
fileNames = cell2mat(fileNames);


%% Prompt to input subID
p.subID = input('What is the subject number? (e.g., 0001): ','s');
p.subIDNum = str2num(p.subID);

p.restart = 0; % default assume that we are not restarting from a prior session
if p.restart == 0
    practice = [];
    results = [];
end

if ~isfield(p,'isTestingVersion')
    
    %% Check if subID already used
    pattern = ['TSS_',p.session.versionPath,'_',p.subID];
    rExist = strfind(fileNames,pattern);
    
    % if subject data does exist, will ask whether to overwrite data
    if ~(isempty(rExist))
        overwrite = input('CAUTION: This subject number has already been used. Do you want to continue? (y = yes, n = no): ','s');
        if strcmpi(overwrite,'y') || strcmpi(overwrite,'Y')            
            prevFile = dir([p.session.versionPath,'/Results/',pattern,'*mat']);
            load([p.session.versionPath,'/Results/',prevFile.name]);
            p.restart = 1; % yes, we are restarting a prior session
            %curBlockNumInput = input('What block would you like to start with? (e.g. 1, 2, etc.): ','s');
            curBlockNumInput = input('What block would you like to start with? (e.g. 1, 2, etc.): ');
            while 1
                switch curBlockNumInput
                    case 1
                        break
                    case 2
                        break
                    case 3
                        break
                    case 4
                        break
                    case 5
                        break
                    case 6
                        break
                    case 7
                        break
                    case 8
                        break
                    otherwise
                        curBlockNumInput = (input('Invalid block number to start with, please enter again: '));
                end
            end
            %p.curBlockNum = str2num(curBlockNumInput);
            p.curBlockNum = curBlockNumInput;
        elseif strcmpi(overwrite,'n') || strcmpi(overwrite,'N')
            error('runTSS is stopped to avoid overwriting subject data.')
        else
            error('Error. Input must be y or n.')
        end
    end
end


end

