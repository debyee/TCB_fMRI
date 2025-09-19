#!/bin/bash
#SBATCH -t 4:00:00
#SBATCH --mem=8GB
#SBATCH -N 1
#SBATCH -n 8
#SBATCH -c 1
#SBATCH --mail-type=ALL
#SBATCH --mail-user=debbie_yee@brown.edu
#SBATCH --account=carney-ashenhav-condo  
#SBATCH -J pTFCE
#SBATCH -o logs/pTFCE_%x-%J_log.txt
#SBATCH -e logs/pTFCE_%x-%J_error.txt

# Loading R for analysis (check version of R)
module load R/4.2.0
module load gcc/10.2 pcre2/10.35 intel/2020.2 texlive/2018

echo "Started Probabilistic Threshold Free Cluster Enhancement For Group Level Stats Started."

#--------- CONFIGURE THESE VARIABLES ---------
# This line makes our bash script complain if we have undefined variables
set -u                

#--------- RUN pTFCE in R script ---------
Rscript TCB_pTFCE.R

echo "Completed Probabilistic Threshold Free Cluster Enhancement For Group Level Stats."