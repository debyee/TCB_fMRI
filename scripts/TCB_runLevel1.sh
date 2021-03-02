#!/bin/bash
#SBATCH -t 12:00:00
#SBATCH --mem=128GB
#SBATCH -N 1
#SBATCH -n 16
#SBATCH --mail-type=ALL
#SBATCH --mail-user=debbie_yee@brown.edu
#SBATCH --account=carney-ashenhav-condo  
#SBATCH -J fMRIModelSpec_Esimate
#SBATCH -o logs/runLevel1_%x-%J_log.txt
#SBATCH -e logs/runLevel1_%x-%J_error.txt

# Loading matlab and spm for analysis
module load matlab/R2019a
module load spm/spm12

#--------- CONFIGURE THESE VARIABLES ---------
#participant_numbers=('2013' '2014' '2015' '2017' '2019' '2022') 
participant_numbers=('2021' '2024') 
# Note: skip subject 2018
# Completed: 2011,2012,2013,2014,2015,2017,2019,2020,2022
root_path='/gpfs/data/ashenhav/mri-data/TCB/spm-data/'
#design_foldername='design_Cue4_Event_rwls'
#design_SOTS='TCB_Event_Cue_RewPenHighLow_sots_allTcat'
design_foldername='design_CueIntFb12_EventEpoch_rwls'
design_SOTS="TCB_Event_CueIntervalFb_RewPenHighLow_sots_allTcat"

#--------- MAKE REGRESSORS FOR INTERCEPTS AND DEMEANING ---------
# matlab-threaded -nodisplay -nodesktop -r "TCB_makeSOTS;exit;"
# matlab-threaded -nodisplay -nodesktop -r "TCB_makeRegressor('${design_foldername}');exit;"

# Loop over participants and run level 1 analyses in SPM
for pid in "${participant_numbers[@]}"; do
    
    echo
    echo "Running Subject ${pid}"
    echo "Root Path is ${root_path}"
    echo "Design Contrast is ${design_foldername}"
    echo "Stimulus Onset File is ${design_SOTS}" 
    echo

    #--------- RUNNING FMRI MODEL SPECIFICATION AND ESTIMATES ---------
    # If SPM.mat file already exists, then remove it
    spm_mat_file="${root_path}sub-${pid}/${design_foldername}/SPM.mat"
    echo ${spm_mat_file}
    if [[ -f ${spm_mat_file} ]]; then
        echo "SPM mat file ${spm_mat_file} exists. Will delete and overwrite."
        rm ${spm_mat_file}
    else
        echo "No SPM mat file found. Will create a new SPM.mat file."
    fi
    
    # Run matlab script to specify model and calculate estimates
    matlab-threaded -nodesktop -nodisplay -r "TCB_runLevel1_fMRIModelSpec_Estimate('${pid}','${root_path}','${design_foldername}','${design_SOTS}');exit;"
    #matlab-threaded -nodisplay -r "TCB_runLevel1GLM_fMRIModelSpec_Estimate('${pid}','${root_path}','${design_foldername}','${design_SOTS}');exit;"
    echo "Subject ${pid} estimates calculated."

    #--------- RUNNING FMRI MODEL CONTRASTS ---------
    matlab-threaded -nodesktop -nodisplay -r "TCB_runLevel1_contrast('${pid}','${root_path}','${design_foldername}');exit;"
    #matlab-threaded -nodesktop -r "TCB_runLevel1_contrast('${pid}','${root_path}','${design_foldername}');exit;"
    echo "Subject ${pid} contrast maps created."

done
