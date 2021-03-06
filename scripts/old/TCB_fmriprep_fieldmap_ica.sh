#!/bin/bash
#SBATCH -t 24:00:00
#SBATCH --mem=128GB
#SBATCH -N 1
#SBATCH -n 32
#SBATCH --account=carney-ashenhav-condo  
#SBATCH -J TCB-fmriprep-fieldmap_ica
#SBATCH --output logs/fmriprep-log-%J.txt
#SBATCH --error logs/fmriprep-error-%J.txt

#--------- CONFIGURE THESE VARIABLES ---------

bids_root_dir=/gpfs/data/ashenhav/mri-data/TCB     # based on oscar path
#bids_root_dir=/gpfs/data/bnc/scratch
#participant_labels=( "tcb2002" "tcb2003" "tcb2004" "tcb2005" "tcb2008" )
#participant_labels=( "tcb2006" )
participant_labels=( "tcb2011" "tcb2012" )
investigator=shenhav                            # investigator
study_label=201226                              # study label 
fmriprep_version=20.2.0   #20.0.6               # check /gpfs/data/bnc/simgs/poldracklab for the latest version
#nthreads=64 				                    # heuristic: 2x number of cores 


#--------- FMRIPREP ---------

for pid in "${participant_labels[@]}"; do
    
    # runs singularity for each subject
    singularity run --cleanenv                                              	        \
        --bind ${bids_root_dir}/${investigator}/study-${study_label}:/data              \
        --bind /gpfs/scratch/dyee7:/scratch                                             \
        --bind /gpfs/data/bnc/licenses:/licenses                                        \
        /gpfs/data/bnc/simgs/poldracklab/fmriprep-${fmriprep_version}.sif               \
        /data/bids /data/bids/derivatives/fmriprep-${fmriprep_version}-nofs             \
        participant 															        \
        --participant-label ${pid} 								                        \
        --fs-license-file /licenses/freesurfer-license.txt 						        \
        -w /scratch/fmriprep 													        \
        --stop-on-first-crash                            						        \
        --nthreads 64 															        \
        --write-graph 															        \
        --use-aroma                                                                     \
        #--fs-no-reconall     
        #--use-syn-sdc
        #--force-syn                                                   
done
