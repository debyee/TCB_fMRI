#!/bin/bash
#SBATCH -t 04:00:00
#SBATCH --mem=16GB
#SBATCH -m arbitrary
#SBATCH -N 1
#SBATCH -c 2
#SBATCH --account=carney-ashenhav-condo  
#SBATCH -J xnat2bids
#SBATCH --output logs/xnat2bids-%J.txt
#SBATCH --array=135,137

# Reference:
# https://github.com/brown-bnc/sanes_sadlum/blob/main/preprocessing/xnat2bids/run_xnat2bids.sh

#--------- Variables ---------
# This line makes our bash script complaint if we have undefined variables
set -u

# Read variables in the .env file in current directory
# This will read:
# XNAT_USER, XNAT_PASSWORD
set -a
[ -f .bashrc ] && . .bashrc
set +a

# uncomment to print environment variables with XNAT in the name
# printenv | grep XNAT

#--------- xnat-tools ---------
# version of xnat2bids being used
version=v1.0.3
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
# Dictionary of sessions per subject
declare -A sessions=([137]="XNAT5_E00002" \
                     [135]="XNAT5_E00003")

# Dictionary of labels per subject
declare -A labels=([137]="tcb2013" \
				   [135]="tcb2014")

# Dictionary of series to skip per subject (ignore the non-RMS T1)
declare -A skip_map=([137]="-s 6" \
                    [135]="-s 6")
# declare -A skip_map=([137]="-s 6 -s 15 -s 16 -s 17 -s 18" \
#                     [135]="-s 6 -s 8 -s 15 -s 16 -s 17 -s 18")

# Use the task array ID to get the right value for this job
# These are defined with the SBATCH header
XNAT_SESSION=${sessions[${SLURM_ARRAY_TASK_ID}]}
SUBJ_LABEL=${labels[${SLURM_ARRAY_TASK_ID}]}
SKIP_STRING=${skip_map[${SLURM_ARRAY_TASK_ID}]}

echo "Processing session:"
echo ${XNAT_SESSION}
echo "Subject label:"
echo ${SUBJ_LABEL}
echo "Series to skip:"
echo ${SKIP_STRING}

# session by XNAT Accession Number (see XNAT2BIDS documentation)
#sessions_all=("XNAT3_E00044", "XNAT3_E00045")

# participant labels for bids-postprocess
# will add "IntendedFor" argument to fieldmap jsons
#participant_labels=("tcb2011","tcb2012")

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
 	singularity exec --no-home -B ${data_dir} ${simg} \
	 	xnat2bids ${XNAT_SESSION} ${bids_root_dir} \
    	-u ${XNAT_USER} \
    	-p "${XNAT_PASSWORD}" \
    	-f ${bidsmap_file} \
		-s 6 \
	   	-v -v --overwrite
fi
		# ${SKIP_STRING} \

#--------- Run bids-postprocess ---------
# runs singularity command to add "IntendedFor" argument to fieldmap jsons
# NOTE: You will have to verify that the participant_labels are correct above
if "${run_bidspostprocess}"; then
	bids_sub_dir="${bids_root_dir}/${investigator_name}/study-${study_label}/bids/"
	echo "EXPERIMENT DIRECTORY: ${bids_sub_dir}"

	singularity exec --no-home -B ${data_dir} ${simg} \
		bids-postprocess ${XNAT_SESSION} ${bids_sub_dir} \
		-v -v \
		--includeseq ${SUBJ_LABEL} 
fi


# for XNAT_SESSION in "${!sessions_all[@]}"
# do  
# done
# for XNAT_SESSION in "${sessions_all[@]}"
# do
# done
	# singularity exec --contain -B ${data_dir} ${simg} \
    # 	xnat-dicom-export ${XNAT_SESSION} ${bids_root_dir} \
    # 	-u ${XNAT_USER} \
    # 	-p "${XNAT_PASSWORD}" \
    # 	-f ${bidsmap_file} \
	# -i 7 -v -v --overwrite

  	# singularity exec --contain -B ${data_dir} ${simg} \
    #     xnat-heudiconv ${bids_root_dir} \
    #     -u ${XNAT_USER} \
    #     -p "${XNAT_PASSWORD}" \
    #     -f ${bidsmap_file} \
    #     -i 7 -v -v --overwrite

			#--log-file "bidspostprocess-${XNAT_SESSION}"     

	# # Calls 'bids-postprocess' executable from xnat-tools
	# singularity exec -B "${bids_sub_dir}":/data/xnat/bids-export 				\
	# /gpfs/data/bnc/simgs/brownbnc/xnat-tools-${version}.sif bids-postprocess    \
	# --bids_experiment_dir /data/xnat/bids-export                                \
	# --session ${sessions_all[sid]} --session_suffix ${session_suffix} 	        \
	# --subjlist ${participant_labels[sid]}          


# XNAT_USER=dyee7                                		# based on xnat username. define password in environment variable only!
# data_dir=/gpfs/data/ashenhav/                       # working directory for data
# bids_root_dir=${data_dir}/mri-data/TCB     	        # where the data will be output

# investigator_name="shenhav"
# study_label=201226
# #bids_root_dir=/gpfs/data/bnc/scratch               # for beta testing on bnc scratch folder

# # session label (default is "01", will only need to change if multi-session)
# session_suffix="01"

# # session by XNAT Accession Number (see XNAT2BIDS documentation)
# sessions_all=( "XNAT3_S00044" "XNAT3_S00045")

# # bids-postprocess function, will add "IntendedFor" argument to fieldmap jsons.
# participant_labels=("tcb2011","tcb2012")

# # boolean for processing subjects with reguluar and irregular runs 
# # RUN if 'true', DO NOT RUN if 'false'
# process_reg=true
# process_irreg=false
# process_fieldmap_addIntendedFor=true   
# #--------- END Define Variables ---------                   

# #--------- Run xnat2bids with regular runs ---------
# # NOTE: if your files are not named according to the BIDS convention, you will need
# # a .json file that will specify how you want to rename the DICOM images
# # xnat2bids has two separate functions, xnat-dicom-export and xnat-heudiconv

# echo -n "XNAT Password?: "
# read -s XNAT_PASS

# if "$process_reg" ; then  
# 	for session in "${sessions_all[@]}"
# 	do 
# 		# runs singularity command to extract DICOMs from xnat and export to BIDS
# 		singularity exec -B ${bids_root_dir}:/data/xnat/bids-export 				\
# 		/gpfs/data/bnc/simgs/brownbnc/xnat-tools-${version}.sif xnat2bids			\
# 		-u ${xnat_user} -p ${XNAT_PASS}	                                \
# 		--session ${session} --session_suffix ${session_suffix}                     \
#         --bids_root_dir /data/xnat/bids-export                                      \
# 		--bidsmap_file /data/xnat/bids-export/bidsmaps/XNAT2_TCB.json	

# 		echo "Subject ${session} complete"			
# 	done
# fi
# #--------- Run xnat2bids with regular runs ---------


# #--------- Run xnat2bids with irregular runs ---------
# # NOTE: for each session, you will need to specify which runs to skip (see xnat for reference)
# if "$process_irreg" ; then  

# 	# # TCB2001 
# 	# session="XNAT2_E00003"
# 	# singularity exec -B ${bids_root_dir}:/data/xnat/bids-export 				\
# 	# /gpfs/data/bnc/simgs/xnat-tools/xnat-tools-${version}.sif xnat2bids        	\
# 	# --user ${xnat_user} --password ${XNAT_PASS}									\
# 	# --session ${session} --bids_root_dir /data/xnat/bids-export                 \
# 	# --bidsmap_file /data/xnat/bids-export/bidsmaps/XNAT2_TCB.json				\
# 	# --skiplist 7 8 9 10 --session_suffix 01

# 	# TCB2006 
# 	session="XNAT2_E00004"
# 	singularity exec -B ${bids_root_dir}:/data/xnat/bids-export 				\
# 	/gpfs/data/bnc/simgs/brownbnc/xnat-tools-${version}.sif xnat2bids      \
# 	--user ${xnat_user} --password ${XNAT_PASS}									\
# 	--session ${session} --session_suffix ${session_suffix}                     \
#     --bids_root_dir /data/xnat/bids-export                                      \
# 	--bidsmap_file /data/xnat/bids-export/bidsmaps/XNAT2_TCB.json				\
# 	--skiplist 13 14        
# 	#--seqlist 8 9 10 11 12 15 16 17
	
#     echo "Irregular Complete"                                                    
# fi 
# #--------- Run xnat2bids with irregular runs ---------


# #--------- Run bids-postprocess to add "IntendedFor" argument to fieldmap jsons ---------
# # NOTE: You will have to verify that the participant_labels are correct above
# if "$process_fieldmap_addIntendedFor"; then  
#     for sid in "${!sessions_all[@]}"
# 	do  
# 		bids_sub_dir="${bids_root_dir}/${investigator_name}/study-${study_label}/bids/"
# 		echo "EXPERIMENT DIRECTORY: ${bids_sub_dir}"

#         # Calls 'bids-postprocess' executable from xnat-tools
#         singularity exec -B "${bids_sub_dir}":/data/xnat/bids-export 				\
#         /gpfs/data/bnc/simgs/brownbnc/xnat-tools-${version}.sif bids-postprocess    \
#         --bids_experiment_dir /data/xnat/bids-export                                \
#         --session ${sessions_all[sid]} --session_suffix ${session_suffix} 	        \
#         --subjlist ${participant_labels[sid]}                                       
#     done
# fi
