#!/bin/bash
#SBATCH -t 00:30:00
#SBATCH --mem=128GB
#SBATCH -N 1
#SBATCH -n 4
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=debbie_yee@brown.edu
#SBATCH --account=carney-ashenhav-condo  
#SBATCH -J TCB_TFCE
#SBATCH --output logs/tcb-tfce-%J.txt

#--------- Variables ---------
# root directory
root_dir="/oscar/data/ashenhav/mri-data/TCB"
# spm directory
spm_dir="/oscar/data/ashenhav/mri-data/analysistools/spm12"

# Get glm information based on input to this batch
glmNum=$1

# based on glm #, which file has the info we need?
glmInfoFile=glm"${glmNum}"_info.txt

# Read the list of contrasts from our glm info file
IFS=$'\n' read -d '' -r -a contrasts < ~/data/mri-data/TCB/scripts/fmri-Preprocessing/GLM_info/"${glmInfoFile}"

# Define the folder name to select the glm name
name="${contrasts[0]}"	



#--------------------------------------------------------------------------------------------------------------
# load modules:

module load matlab/R2019a-rjyk3ws
module load fsl

echo; echo; echo; echo;
echo "========== tcb level 2 TFCE =========="
echo "dir: '${root_dir}' | name: '${name}'"
echo; echo; echo; echo;

echo 'started at:'
date
echo; echo; echo; echo;

# do level 2 estimate 
matlab-threaded –nodisplay -nodesktop -r "TCB_wholeBrain_TFCE('${root_dir}', '${spm_dir}','${name}')"

echo; echo; echo; echo;
echo 'finished at:'
date

