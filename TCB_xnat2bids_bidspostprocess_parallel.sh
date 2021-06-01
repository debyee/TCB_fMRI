#!/bin/bash
#SBATCH -t 01:00:00
#SBATCH --mem=32GB
#SBATCH -m arbitrary
#SBATCH -N 1
#SBATCH -c 2
#SBATCH --account=carney-ashenhav-condo  
#SBATCH -J xnat2bids
#SBATCH --output logs/xnat2bids-%J.txt
#SBATCH --array=200
#SBATCH --mail-type=ALL
#SBATCH --mail-user=debbie_yee@brown.edu

# Reference:
# https://github.com/brown-bnc/sanes_sadlum/blob/main/preprocessing/xnat2bids/run_xnat2bids.sh

#--------- Variables ---------
# This line makes our bash script complaint if we have undefined variables
set -u

# Read variables in the .env file in current directory
# This will read:
# XNAT_USER, XNAT_PASSWORD
# set -a
# [ -f .bashrc ] && . .bashrc
# set +a

# Create temporary token for XNAT, so your password is not saved anywhere!
# To generate, run the following command: bash /gpfs/data/bnc/scripts/xnat-token
XNAT_USER=9c99df1f-20fc-4757-ac8c-74176a7218f0
XNAT_PASSWORD=7mr09viokCMV3Rx4iSnxzkilZfksHCNdEJFkhyEgsPSRtuj006NLqJyp3AmyVNTe
# XNAT_USER=dyee7
# XNAT_PASSWORD=

# uncomment to print environment variables with XNAT in the name
# printenv | grep XNAT

#--------- xnat-tools ---------
# version of xnat2bids being used
version=v1.0.5        #v1.0.3
# Path to Singularity Image for xnat-tools (maintained by bnc)
simg=/gpfs/data/bnc/simgs/brownbnc/xnat-tools-${version}.sif

#--------- directories ---------
# Your working directory in Oscar, usually /gpfs/data/<your PI's group>.
# We pass (bind) this path to singularity so that it can access/see it
data_dir=/gpfs/data/ashenhav

# Output directory
# It has to be under the data_dir, otherwise it won't be seen by singularity
# bids_root_dir=${data_dir}/shared/bids-export/${USER}
bids_root_dir=${data_dir}/mri-data/TCB   
mkdir -p -m 775 ${bids_root_dir} || echo "Output directory already exists"

# Bidsmap file for your study
# It has to be under the data_dir, otherwise it won't be seen by singularity
#bidsmap_file=${data_dir}/shared/xnat-tools-examples/${USER}/bidsmaps/sanes_sadlum.json
bidsmap_file=${bids_root_dir}/bidsmaps/XNAT2_TCB.json	

#----------- Dictionaries for subject specific variables -----
# Check for XNAT Ascension Number Here: https://xnat.bnc.brown.edu/data/experiments/
# Old link: https://bnc.brown.edu/xnat/data/experiments/
# Dictionary of sessions per subject
declare -A sessions=([200]="XNAT_S00010" )
		    #  [201]="XNAT7_E00081" ) #\
		    #  [202]="XNAT7_E00074" \
		    #  [203]="XNAT7_E00075" \
			#  [204]="XNAT7_E00079" )

# Dictionary of labels per subject
declare -A labels=([200]="tcb2050" )
		#    [201]="tcb2049" ) #\
		#    [202]="tcb2045" \
		#    [203]="tcb2044" \
		#    [204]="tcb2047")

# Dictionary of series to skip per subject (ignore the non-RMS T1)
declare -A skip_map=([200]="-s 6" )
		    #  [201]="-s 6" 			) #\
 		    #  [202]="-s 6" 			\
		    #  [203]="-s 6" 			\
			#  [204]="-s 6 -s 9" 		)
# declare -A skip_map=([137]="-s 6 -s 15 -s 16 -s 17 -s 18" \
#                     [135]="-s 6 -s 8 -s 15 -s 16 -s 17 -s 18")

# Use the task array ID to get the right value for this job
# These are defined with the SBATCH header
echo ${SLURM_ARRAY_TASK_ID}
XNAT_SESSION=${sessions[${SLURM_ARRAY_TASK_ID}]}
SUBJ_LABEL=${labels[${SLURM_ARRAY_TASK_ID}]}
SKIP_STRING=${skip_map[${SLURM_ARRAY_TASK_ID}]}

echo "Processing session:"
echo ${XNAT_SESSION}
echo "Subject label:"
echo ${SUBJ_LABEL}
echo "Series to skip:"
echo ${SKIP_STRING}

#----------- Study variables -----
investigator_name="shenhav"
study_label=201226

run_xnat2bids=true
run_bidspostprocess=true

#--------- Run xnat2bids ---------
# runs singularity command to extract DICOMs from xnat and export to BIDS
# this command tells singularity to launch out xnat-tools-${version}.sif image
# and execute the xnat2bids command with the given inputs.
# The `-B ${data_dir}` makes that directory available to the singularity container
# The file system inside your container is not the same as in Oscar, unless you bind the paths
# The -i passes a sequence to download, without any -i all sequences will be processed
if "${run_xnat2bids}"; then
 	singularity exec --no-home -B ${data_dir} ${simg} 	\
	 	xnat2bids ${XNAT_SESSION} ${bids_root_dir} 		\
    	-u ${XNAT_USER} 	\
    	-p ${XNAT_PASSWORD} \
    	-f ${bidsmap_file} 	\
		-v --overwrite		\
		${SKIP_STRING} 	
	   	
fi

# -h https://xnat.bnc.brown.edu \

#--------- Run bids-postprocess ---------
# runs singularity command to add "IntendedFor" argument to fieldmap jsons
# NOTE: You will have to verify that the participant_labels are correct above
if "${run_bidspostprocess}"; then
	bids_sub_dir="${bids_root_dir}/${investigator_name}/study-${study_label}/bids/"
	echo "EXPERIMENT DIRECTORY: ${bids_sub_dir}"

	singularity exec --no-home -B ${data_dir} ${simg} 		\
		bids-postprocess ${XNAT_SESSION} ${bids_sub_dir} 	\
		-v -v											\
		--includesubj ${SUBJ_LABEL} 
fi
