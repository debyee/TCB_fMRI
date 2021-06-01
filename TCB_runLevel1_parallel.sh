#!/bin/bash
#SBATCH -t 2:00:00
#SBATCH --mem=128GB
#SBATCH -N 1
#SBATCH -n 16
#SBATCH -c 1
#SBATCH --mail-type=ALL
#SBATCH --mail-user=debbie_yee@brown.edu
#SBATCH --account=carney-ashenhav-condo  
#SBATCH -J fMRIModelSpec_Esimate_parallel
#SBATCH -o logs/runLevel1_%x-%J_log.txt
#SBATCH -e logs/runLevel1_%x-%J_error.txt
#SBATCH --array=135

# Loading matlab and spm for analysis
module load matlab/R2019a
module load spm/spm12

#--------- CONFIGURE THESE VARIABLES ---------
# This line makes our bash script complain if we have undefined variables
set -u

#participant_numbers=('2011' '2012' '2013' '2014','2015','2017','2019','2020','2022') 
# Note: skip subject 2018
root_path='/gpfs/data/ashenhav/mri-data/TCB/spm-data/'
#design_foldername='design_Cue4_Event_rwls'
#design_SOTS='TCB_Event_Cue_RewPenHighLow_sots_allTcat'
design_foldername='design_CueIntFb12_EventEpoch_rwls'
design_SOTS="TCB_Event_CueIntervalFb_RewPenHighLow_sots_allTcat"

#--------- MAKE REGRESSORS FOR INTERCEPTS AND DEMEANING ---------
# Create stimulus onset files for each participant 
matlab-threaded -nodisplay -nodesktop -r "TCB_makeSOTS;exit;"
# Create run and motion regressors for each participant
matlab-threaded -nodisplay -nodesktop -r "TCB_makeRegressor('${design_foldername}');exit;"

# Dictionary of labels per subject 
# NOTE: set array numbers at the SLURM heading at top of script
declare -A participant_numbers=([135]="2028" ) #\
                                # [136]="2027" \
                                # [137]="2028" \
                                # [138]="2030" \
                                # [139]="2031" \
                                # [140]="2032" \
                                # [141]="2033" \
                                # [142]="2035")

# Completed: 2011,2012,2013,2014,2015,2017,2019,2020,2022,2026,2027,2030,2031,2032,2033,2035
# Skipped: 2018

# Use the task array ID to get the right value for this job
# These are defined with the SBATCH header
PAT_NUM=${participant_numbers[${SLURM_ARRAY_TASK_ID}]}

echo "Running job array number: "$SLURM_ARRAY_TASK_ID
echo "Processing participant: "${PAT_NUM}

# Loop over participants and run level 1 analyses in SPM
#for pid in "${participant_numbers[@]}"; do
    
    echo
    echo "Running Subject ${PAT_NUM}"
    echo "Root Path is ${root_path}"
    echo "Design Contrast is ${design_foldername}"
    echo "Stimulus Onset File is ${design_SOTS}" 
    echo

    #--------- RUNNING FMRI MODEL SPECIFICATION AND ESTIMATES ---------
    # If SPM.mat file already exists, then remove it
    spm_mat_file="${root_path}sub-${PAT_NUM}/${design_foldername}/SPM.mat"
    echo ${spm_mat_file}
    if [[ -f ${spm_mat_file} ]]; then
        echo "SPM mat file ${spm_mat_file} exists. Will delete and overwrite."
        rm ${spm_mat_file}
    else
        echo "No SPM mat file found. Will create a new SPM.mat file."
    fi
    
    # Run matlab script to specify model and calculate estimates
    matlab-threaded -nodesktop -nodisplay -r "TCB_runLevel1_fMRIModelSpec_Estimate('${PAT_NUM}','${root_path}','${design_foldername}','${design_SOTS}');exit;"
    # #matlab-threaded -nodisplay -r "TCB_runLevel1GLM_fMRIModelSpec_Estimate('${pid}','${root_path}','${design_foldername}','${design_SOTS}');exit;"
    echo "Subject ${PAT_NUM} estimates calculated."

    #--------- RUNNING FMRI MODEL CONTRASTS ---------
    matlab-threaded -nodesktop -nodisplay -r "TCB_runLevel1_contrast('${PAT_NUM}','${root_path}','${design_foldername}');exit;"
    #matlab-threaded -nodesktop -r "TCB_runLevel1_contrast('${pid}','${root_path}','${design_foldername}');exit;"
    echo "Subject ${PAT_NUM} contrast maps created."

#done
