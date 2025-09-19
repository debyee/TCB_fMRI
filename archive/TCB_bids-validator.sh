#!/bin/bash
#SBATCH -t 04:00:00
#SBATCH -mem=32GB
#SBATCH -n 1
#SBATCH -c 8
#SBATCH --mail-type=ALL
#SBATCH --mail-user=debbie_yee@brown.edu
#SBATCH --account=carney-ashenhav-condo  
#SBATCH -J TCB-bids-validator
#SBATCH --output slurm-logs/TCB-xnat2bids-log-%J.txt

#--------- Run bids-validator on bids folder ---------

version=v1.5.2 # check latest available version
bids_directory=/gpfs/data/ashenhav/mri-data/TCB/shenhav/study-201226/bids/
#bids_directory=/gpfs/data/bnc/scratch/shenhav/study-201226/bids/


singularity exec -B ${bids_directory}:/data:ro \
/gpfs/data/bnc/simgs/bids/validator-${version}.sif bids-validator /data


