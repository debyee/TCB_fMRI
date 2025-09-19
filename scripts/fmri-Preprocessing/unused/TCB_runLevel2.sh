#!/bin/bash
#SBATCH -t 12:00:00
#SBATCH --mem=128GB
#SBATCH -N 1
#SBATCH -n 16
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=hritz@brown.edu
#SBATCH --account=carney-ashenhav-condo  
#SBATCH -J TCB_runlevel1_fMRIModelSpec_Esimate
#SBATCH -o slurm-logs/%x-%J_log.txt
#SBATCH -e slurm-logs/%x-%J_error.txt

# Loading matlab and spm for analysis
module load matlab/R2019a
module load spm/spm12

#--------- CONFIGURE THESE VARIABLES ---------
participant_numbers=('2002' '2003' '2004' '2005' '2008')
root_path="/gpfs/data/ashenhav/mri-data/TCB/spm-data/"
design_foldername="design_CueInt8_EventEpoch_rwls"
design_SOTS="TCB_Event_CueInterval_GainLossHighLow_sots_allTcat"

#--------- RUN LEVEL 2 ANALYSIS ---------
#matlab-threaded -nodisplay -nodesktop -r "TCB_makeRegressor('${design_foldername}');exit;"




# Loop over participants and run level 2 analyses in SPM
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
        echo "No SPM mat file found."
    fi
    
    # Run matlab script to specify model and calculate estimates
    matlab-threaded -nodesktop -r "TCB_runLevel1GLM_fMRIModelSpec_Estimate('${pid}','${root_path}','${design_foldername}','${design_SOTS}');exit;"
    echo "Subject ${pid} estimates calculated."

    #--------- RUNNING FMRI MODEL CONTRASTS ---------
    matlab-threaded -nodesktop -r "TCB_runLevel1_contrast('${pid}','${root_path}','${design_foldername}');exit;"
    echo "Subject ${pid} contrast maps created."
done
