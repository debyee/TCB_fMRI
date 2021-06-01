#!/bin/bash
#SBATCH -t 12:00:00
#SBATCH --mem=128GB
#SBATCH -N 1
#SBATCH -n 16
#SBATCH --mail-type=ALL
#SBATCH --mail-user=debbie_yee@brown.edu
#SBATCH --account=carney-ashenhav-condo  
#SBATCH -J fMRI_L2_group
#SBATCH -o logs/runLevel2_%x-%J_log.txt
#SBATCH -e logs/runLevel2_%x-%J_error.txt

# Loading matlab and spm for analysis
module load matlab/R2019a
module load spm/spm12


#--------- Variables ---------

# This line makes our bash script complaint if we have undefined variables
set -u

#--------- CONFIGURE THESE VARIABLES ---------
participant_numbers=('2011' '2012' '2013' '2014' '2015' '2017' '2019' '2020' '2021' '2022' '2024' 
                    '2026' '2027' '2028' '2030' '2031' '2032' '2033' '2035')
root_path='/gpfs/data/ashenhav/mri-data/TCB/spm-data/'
design_foldername='design_CueIntFb12_EventEpoch_rwls'  #'design_Cue4_Event_rwls'

# Declare an associate array with relevant contrasts
declare -A contrast=(['1']='C1_Cue_TaskvsBaseline'   \
                     ['2']='C2_Int_TaskvsBaseline'   \
                     ['3']='C3_Cue_HighvsLowReward'  \
                     ['4']='C4_Cue_HighvsLowPenalty' \
                     ['5']='C5_Int_HighvsLowReward'  \
                     ['6']='C6_Int_HighvsLowPenalty' \
                     ['7']='C7_Fb_HighvsLowReward'   \
                     ['8']='C8_Fb_HighvsLowPenalty'  )

#contrasts=('C1_Cue_TaskvsBaseline' 'C2_Cue_HighvsLowReward' 'C3_Cue_HighvsLowPenalty')
#contrasts_num=('0001','002','003')
#design_SOTS='TCB_Event_Cue_RewPenHighLow_sots_allTcat'
#design_foldername="design_CueInt8_EventEpoch_rwls"
#design_SOTS="TCB_Event_CueInterval_GainLossHighLow_sots_allTcat"

#--------- SETUP FOLDERS FOR GROUP STATS ---------
# If groupstats folder does not exist, then create it
groupstats_folder="${root_path}groupstats"
echo ${groupstats_folder}
if [[ -d ${groupstats_folder} ]]; then
    echo "${groupstats_folder} exists. No changes required."
else
    echo "${groupstats_folder} not found. Will create a new folder."
    mkdir ${groupstats_folder}
fi

# If contrasts folder do not exist for the design, then create them
for cid in "${!contrast[@]}"; do
    contrast_folder="${root_path}groupstats/${design_foldername}/${contrast[$cid]}"
    echo ${contrast_folder}
    if [[ -d ${contrast_folder} ]]; then
        echo "${contrast_folder} exists. No changes required."
    else
        echo "${contrast_folder} not found. Will create a new folder."
        mkdir -p ${contrast_folder}
    fi

    # Move contrasts from Level1 folder to groupstats folder
    for pid in "${participant_numbers[@]}"; do
        #echo "${root_path}sub-${pid}/${design_foldername}/con_000${cid}.nii" "${root_path}/groupstats/${design_foldername}/${contrast[$cid]}/sub-${pid}_con_001${cid}.nii"
        echo "Moving contrast: Subject ${pid} Contrast ${cid} to Folder ${contrast[$cid]}"
        cp "${root_path}sub-${pid}/${design_foldername}/con_000${cid}.nii" "${root_path}/groupstats/${design_foldername}/${contrast[$cid]}/sub-${pid}_con_000${cid}.nii" 
        cp "${root_path}sub-${pid}/${design_foldername}/spmT_000${cid}.nii" "${root_path}/groupstats/${design_foldername}/${contrast[$cid]}/sub-${pid}_spmT_000${cid}.nii" 
    done

done

# Sanity Check to check the keys. If you want to loop over values, remove "!" from before array
# for i in "${!contrast[@]}"
# do
#   echo "key  : $i"
#   echo "value: ${contrast[$i]}"
# done


#--------- RUN LEVEL 2 ANALYSIS ---------
#matlab-threaded -nodisplay -nodesktop -r "TCB_makeRegressor('${design_foldername}');exit;"

# iterate over each contrast 
for cid in "${!contrast[@]}"; do

    # Identify subjects for group analysis, save to text file
    contrast_folder="${root_path}groupstats/${design_foldername}/${contrast[$cid]}"
    echo "${contrast_folder}"
    echo ${participant_numbers[@]} >> "${contrast_folder}/participant_numbers.txt"

    # If SPM.mat file already exists, then remove it
    spm_mat_file="${contrast_folder}/SPM.mat"
    echo ${spm_mat_file}
    if [[ -f ${spm_mat_file} ]]; then
        echo "SPM mat file ${spm_mat_file} exists. Will delete and overwrite."
        rm ${spm_mat_file}
    else
        echo "No SPM mat file found. Will create a new SPM.mat file."
    fi

    # Runs Level 2 analyses 
    matlab-threaded -nodesktop -nodisplay -r "TCB_runLevel2_group('${root_path}','${contrast_folder}','${design_foldername}','${contrast[$cid]}');exit;"
    # if issues, try: #matlab -nodesktop -r addpath '/gpfs/rt/7.2/opt/spm/spm12' "TCB_runLevel2_group('${root_path}','${contrast_folder}','${design_foldername}','${contrast[$cid]}');exit;"
    echo "Contrast ${cid} analyzed."

done