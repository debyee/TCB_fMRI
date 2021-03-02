#!/bin/bash
#SBATCH -t 01:00:00
#SBATCH --mem=64GB
#SBATCH -N 1
#SBATCH -n 16
#SBATCH --mail-type=ALL
#SBATCH --mail-user=debbie_yee@brown.edu
#SBATCH --account=carney-ashenhav-condo  
#SBATCH -J TCB-postfmriprep-smooth
#SBATCH --output logs/TCB-postfmriprep-dataformat-%J.txt

# Directories
bids_dir=/gpfs/data/ashenhav/mri-data/TCB/shenhav/study-201226/bids/derivatives/fmriprep-20.2.0-nofs/fmriprep/
spm_dir=/gpfs/data/ashenhav/mri-data/TCB/spm-data/

# Participant, session, and run labels
participant_labels=("tcb2021" "tcb2024")
participant_numbers=(2021 2024)
#participant_labels=( "tcb2011" "tcb2012" "tcb2013" "tcb2014" "tcb2015" "tcb2020" "tcb2017" "tcb2018" "tcb2019" "tcb2022")
#participant_numbers=( 2011 2012 2013 2014 2015 2020 2017 2018 2019 2022 )
run_labels=( "1" "2" "3" "4" "5" "6" "7" "8")
session_label=("01")

# Move the relevant bids derivatives to the spm-data folder for 1st level analysis
for pid in "${!participant_labels[@]}"; do

    # SUBJECT DIRECTORY
    # If folder for subject does not exist, then create it
    subj_dir="${spm_dir}sub-${participant_numbers[pid]}/"
    if [[ -d ${subj_dir} ]]; then
        echo "${subj_dir} exists"
    else
        echo "${subj_dir} does not exist. Will create a subject directory."
        mkdir ${subj_dir}
    fi

    # FUNCTIONAL BOLD EPI RUNS
    # If folder for functional runs does not exist, then create it
    func_dir="${spm_dir}sub-${participant_numbers[pid]}/func/"
    if [[ -d ${func_dir} ]]; then
        echo "${func_dir} exists"
    else
        echo "${func_dir} does not exist. Will create a func directory."
        mkdir ${func_dir}
    fi

    for rid in "${run_labels[@]}"; do
        # paths
        ica_filename="sub-${participant_labels[pid]}_ses-${session_label}_task-TSSblock_run-${rid}_space-MNI152NLin6Asym_desc-smoothAROMAnonaggr_bold.nii.gz"
        bids_ica_filepath="${bids_dir}sub-${participant_labels[pid]}/ses-${session_label}/func/${ica_filename}"
        #echo ${bids_ica_filepath}      
        # copy processed image (smoothing & ica) to spm folder
        echo "Moving Functional Run ${rid} for Subject ${participant_numbers[pid]}" 
        cp -r ${bids_ica_filepath} ${func_dir}
        
    done
    
    # DECOMPRESSING COMPRESSED NIFTIS, NECESSARY FOR SPM 
    # unzips each of the compressed niftis recursively within the spm-data folder (.nii.gz -> .nii)
    echo "Unzipping functional runs"
    gunzip -rf "${func_dir}"

    # ANATOMICAL IMAGES AND BRAIN MASKS
    # If folder for anatomical images does not exist, then create it
    anat_dir="${spm_dir}sub-${participant_numbers[pid]}/anat/"
    if [[ -d ${anat_dir} ]]; then 
        echo "${anat_dir} exists"
    else
        echo "${anat_dir} does not exist. Will create an anat directory."
        mkdir ${anat_dir}
    fi
    
    # paths
    anat_filename="sub-${participant_labels[pid]}_ses-${session_label}_acq-memprageRMS_desc-preproc_T1w.nii.gz"
    bids_anat_filepath="${bids_dir}sub-${participant_labels[pid]}/ses-${session_label}/anat/${anat_filename}"
    echo "Moving Anat Image for Subject ${participant_numbers[pid]}"
    cp -r ${bids_anat_filepath} ${anat_dir}

    mask_filename="sub-${participant_labels[pid]}_ses-${session_label}_acq-memprageRMS_desc-brain_mask.nii.gz"
    bids_mask_filepath="${bids_dir}sub-${participant_labels[pid]}/ses-${session_label}/anat/${mask_filename}"
    echo "Moving Mask Image for Subject ${participant_numbers[pid]}"
    cp -r ${bids_mask_filepath} ${anat_dir}    
    
    anatMNI_filename="sub-${participant_labels[pid]}_ses-${session_label}_acq-memprageRMS_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz"
    bids_anatMNI_filepath="${bids_dir}sub-${participant_labels[pid]}/ses-${session_label}/anat/${anatMNI_filename}"
    echo "Moving Anat MNI Image for Subject ${participant_numbers[pid]}"
    cp -r ${bids_anatMNI_filepath} ${anat_dir}
    
    maskMNI_filename="sub-${participant_labels[pid]}_ses-${session_label}_acq-memprageRMS_space-MNI152NLin2009cAsym_desc-brain_mask.nii.gz"
    bids_maskMNI_filepath="${bids_dir}sub-${participant_labels[pid]}/ses-${session_label}/anat/${maskMNI_filename}"
    echo "Moving Mask MNI Image for Subject ${participant_numbers[pid]}"
    cp -r ${bids_maskMNI_filepath} ${anat_dir}

    # DECOMPRESSING COMPRESSED NIFTIS, NECESSARY FOR SPM 
    # unzips each of the compressed niftis recursively within the spm-data folder (.nii.gz -> .nii)
    echo "Unzipping anatomical and mask images"
    gunzip -rf "${anat_dir}" 


    ## CONFOUND REGRESSORS
    # If folder for confound regressors does not exist, then create it
    conf_dir="${spm_dir}sub-${participant_numbers[pid]}/confounds/"
    if [[ -d ${conf_dir} ]]; then 
        echo "${conf_dir} exists"
    else
        echo "${conf_dir} does not exist. Will create an anat directory."
        mkdir ${conf_dir}
    fi   

    # copy confound tsv files to spm folder
    echo "Copying confound regressor files"
    bids_conf_filepath="${bids_dir}sub-${participant_labels[pid]}/ses-${session_label}/func/"
    find ${bids_conf_filepath} -name "*confounds_timeseries.tsv" -exec cp '{}' ${conf_dir} \;

done