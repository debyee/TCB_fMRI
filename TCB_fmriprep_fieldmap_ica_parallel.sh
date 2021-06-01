#!/bin/bash
#SBATCH -t 24:00:00
#SBATCH --mem=128GB
#SBATCH -N 1
#SBATCH -n 32
#SBATCH --mail-type=ALL
#SBATCH --mail-user=debbie_yee@brown.edu
#SBATCH --account=carney-ashenhav-condo  
#SBATCH -J TCB-fmriprep-fieldmap_ica
#SBATCH --output logs/fmriprep-log-%J.txt
#SBATCH --error logs/fmriprep-error-%J.txt
#SBATCH --array=135

#--------- CONFIGURE THESE VARIABLES ---------

bids_root_dir=/gpfs/data/ashenhav/mri-data/TCB     # based on oscar path
#bids_root_dir=/gpfs/data/bnc/scratch
investigator=shenhav                            # investigator
study_label=201226                              # study label 
fmriprep_version=20.2.0   #20.0.6               # check /gpfs/data/bnc/simgs/poldracklab for the latest version
#nthreads=64 				                    # heuristic: 2x number of cores 

#----------- Dictionaries for subject specific variables -----
# Dictionary of labels per subject
declare -A labels=([135]="tcb2043" )
		#    [136]="tcb2049"  )
		#    [137]="tcb2031"  )
		#    [138]="tcb2041"  \
		#    [139]="tcb2043"  \
        #    [140]="tcb2042"  \
        #    [141]="tcb2045"  \
        #    [142]="tcb2044"  \
        #    [143]="tcb2047"  )

# Use the task array ID to get the right value for this job
# These are defined with the SBATCH header
SUBJ_LABEL=${labels[${SLURM_ARRAY_TASK_ID}]}

#--------- Run FMRIPREP --------- 

# runs singularity for each subject
singularity run --cleanenv                                              	        \
    --bind ${bids_root_dir}/${investigator}/study-${study_label}:/data              \
    --bind /gpfs/scratch/dyee7:/scratch                                             \
    --bind /gpfs/data/bnc/licenses:/licenses                                        \
    /gpfs/data/bnc/simgs/poldracklab/fmriprep-${fmriprep_version}.sif               \
    /data/bids /data/bids/derivatives/fmriprep-${fmriprep_version}-nofs             \
    participant 															        \
    --participant-label ${SUBJ_LABEL} 								                \
    --fs-license-file /licenses/freesurfer-license.txt 						        \
    -w /scratch/fmriprep 													        \
    --stop-on-first-crash                            						        \
    --nthreads 64 															        \
    --write-graph 															        \
    --use-aroma   
