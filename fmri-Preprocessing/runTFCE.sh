#!/bin/bash
#SBATCH -t 24:00:00
#SBATCH --mem=64GB
#SBATCH --constraint=cascade
#SBATCH -N 1
#SBATCH -n 8
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=debbie_yee@brown.edu
#SBATCH --account=carney-ashenhav-condo  
#SBATCH -J run-tfce
#SBATCH --output /oscar/data/ashenhav/mri-data/TCB/analysis/fmri/scripts/logs/tfce-%J.txt

# load module
module load fsl
module load matlab/R2019a

# display info
echo; echo; echo; echo;
echo 'dirPALM: ' 	${dirPALM}
echo 'mask: ' 		${mask}
echo 'dirIN: ' 		${dirIN}
echo 'dirOUT: ' 	${dirOUT}
echo 'nPerm: ' 		${nPerm}
echo 'usemask: ' 	${usemask}
echo; echo; echo; echo;

echo 'started at:'
date
echo; echo; echo; echo;

#[ -z ${mask} ]

# if [ ${usemask} == 1 ]; then 
#     echo "using mask ${mask}"
# else
#     echo "Running Whole Brain"
# fi

if [ ${usemask} == 1 ]; then 
    echo "using mask ${mask}"
    matlab-threaded –nodisplay -nodesktop -r "addpath('${dirPALM}'); palm('-i', '${dirIN}', '-m', '${mask}', '-o', '${dirOUT}', '-T', '-n', ${nPerm}, '-logp', '-quiet')"
else
    echo "Running Whole Brain"
    matlab-threaded –nodisplay -nodesktop -r "addpath('${dirPALM}'); palm('-i', '${dirIN}', '-o', '${dirOUT}', '-T', '-n', ${nPerm}, '-logp', '-quiet')"
fi

matlab-threaded –nodisplay -nodesktop -r "flip_nii('${dirOUT}', 1)"

echo; echo; echo; echo;
echo 'finished at:'
date

