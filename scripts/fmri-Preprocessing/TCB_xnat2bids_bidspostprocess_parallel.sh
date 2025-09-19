#!/bin/bash
#SBATCH -t 01:00:00
#SBATCH --mem=4GB
#SBATCH -m arbitrary
#SBATCH -N 1
#SBATCH -c 2
#SBATCH --account=carney-ashenhav-condo  
#SBATCH -J xnat2bids
#SBATCH --output logs/xnat2bids-%J.txt
#SBATCH --array=233,287
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
XNAT_USER=8bb481dc-fb84-411f-bbc2-f8d42db1f197
XNAT_PASSWORD=B2yuNlSNerXyAxhAAOszo2Gg9SYbgIq33TQHl9bfQB2wz7Ua2M91un8yn1rQFL8c
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
# Dictionary of sessions per subject
declare -A sessions=([201]="XNAT3_E00044" \
					[202]="XNAT3_E00045" \
					[203]="XNAT5_E00002" \
					[204]="XNAT5_E00003" \
					[205]="XNAT5_E00005" \
					[206]="XNAT5_E00007" \
					[207]="XNAT7_E00010" \
					[208]="XNAT5_E00006" \
					[209]="XNAT7_E00039" \
					[210]="XNAT7_E00007" \
					[211]="XNAT7_E00023" \
					[212]="XNAT7_E00043" \
					[213]="XNAT7_E00045" \
					[214]="XNAT7_E00054" \
					[215]="XNAT7_E00057" \
					[216]="XNAT7_E00042" \
					[217]="XNAT7_E00046" \
					[218]="XNAT7_E00047" \
					[219]="XNAT7_E00053" \
					[220]="XNAT7_E00062" \
					[221]="XNAT7_E00050" \
					[222]="XNAT7_E00061" \
					[223]="XNAT7_E00058" \
					[224]="XNAT7_E00060" \
					[225]="XNAT7_E00064" \
					[226]="XNAT7_E00063" \
					[227]="XNAT7_E00065" \
					[228]="XNAT7_E00069" \
					[229]="XNAT7_E00068" \
					[230]="XNAT7_E00075" \
					[231]="XNAT7_E00074" \
					[232]="XNAT7_E00080" \
					[233]="XNAT7_E00079" \
					[234]="XNAT_E00005"  \
					[235]="XNAT7_E00081" \
					[236]="XNAT_E00009"  \
					[237]="XNAT13_E00001" \
					[238]="XNAT13_E00002" \
					[239]="XNAT13_E00005" \
					[240]="XNAT13_E00012" \
					[241]="XNAT14_E00004" \
					[242]="XNAT14_E00005" \
					[243]="XNAT15_E00001" \
					[244]="XNAT16_E00002" \
					[245]="XNAT16_E00001" \
					[246]="XNAT16_E00006" \
					[247]="XNAT16_E00003" \
					[248]="XNAT17_E00003" \
					[249]="XNAT18_E00002" \
					[250]="XNAT17_E00002" \
					[251]="XNAT17_E00004" \
					[252]="XNAT18_E00001" \
					[253]="XNAT20_E00003" \
					[254]="XNAT17_E00006" \
					[255]="XNAT21_E00004" \
					[256]="XNAT20_E00002" \
					[257]="XNAT23_E00003" \
					[258]="XNAT23_E00005" \
					[259]="XNAT27_E00031" \
					[260]="XNAT27_E00035" \
					[261]="XNAT27_E00037" \
					[262]="XNAT27_E00036" \
					[263]="XNAT27_E00043" \
					[264]="XNAT27_E00051" \
					[265]="XNAT27_E00052" \
					[266]="XNAT27_E00050" \
					[267]="XNAT29_E00006" \
					[268]="XNAT29_E00007" \
					[269]="XNAT29_E00009" \
					[270]="XNAT29_E00016" \
					[271]="XNAT29_E00020" \
					[272]="XNAT29_E00028" \
					[273]="XNAT29_E00056" \
					[274]="XNAT29_E00057" \
					[275]="XNAT29_E00059" \
					[276]="XNAT29_E00060" \
					[277]="XNAT29_E00061" \
					[278]="XNAT29_E00063" \
					[279]="XNAT29_E00122" \
					[280]="XNAT29_E00126" \
					[281]="XNAT29_E00143" \
					[282]="XNAT29_E00124" \
					[283]="XNAT29_E00138" \
					[284]="XNAT29_E00145" \
					[285]="XNAT29_E00151" \
					[286]="XNAT30_E00002" \
					[287]="XNAT30_E00013" \
					[288]="XNAT30_E00020" \
					[289]="XNAT_E00014"   \
					[290]="XNAT_E00016"   \
					[291]="XNAT_E00018"   \
					[292]="XNAT_E00020"   \
					[293]="XNAT_E00043"	  \
					[294]="XNAT_E00044"   \
					[295]="XNAT_E00045"   \
					[296]="XNAT_E00051"   \
					[297]="XNAT_E00057"   \
					[298]="XNAT_E00067"   \
					[299]="XNAT_E00070"	  )

# Dictionary of labels per subject
declare -A labels=([201]="tcb2011" \
					[202]="tcb2012" \
					[203]="tcb2013" \
					[204]="tcb2014" \
					[205]="tcb2015" \
					[206]="tcb2017" \
					[207]="tcb2019" \
					[208]="tcb2020" \
					[209]="tcb2021" \
					[210]="tcb2022" \
					[211]="tcb2024" \
					[212]="tcb2026" \
					[213]="tcb2027" \
					[214]="tcb2028" \
					[215]="tcb2029" \
					[216]="tcb2030" \
					[217]="tcb2031" \
					[218]="tcb2032" \
					[219]="tcb2033" \
					[220]="tcb2034" \
					[221]="tcb2035" \
					[222]="tcb2036" \
					[223]="tcb2037" \
					[224]="tcb2038" \
					[225]="tcb2039" \
					[226]="tcb2040" \
					[227]="tcb2041" \
					[228]="tcb2042" \
					[229]="tcb2043" \
					[230]="tcb2044" \
					[231]="tcb2045" \
					[232]="tcb2046" \
					[233]="tcb2047" \
					[234]="tcb2048" \
					[235]="tcb2049" \
					[236]="tcb2050" \
					[237]="tcb2051" \
					[238]="tcb2053" \
					[239]="tcb2054" \
					[240]="tcb2055" \
					[241]="tcb2057" \
					[242]="tcb2058" \
					[243]="tcb2059" \
					[244]="tcb2060" \
					[245]="tcb2061" \
					[246]="tcb2062" \
					[247]="tcb2063" \
					[248]="tcb2064" \
					[249]="tcb2065" \
					[250]="tcb2066" \
					[251]="tcb2067" \
					[252]="tcb2068" \
					[253]="tcb2069" \
					[254]="tcb2070" \
					[255]="tcb2071" \
					[256]="tcb2072" \
					[257]="tcb2073" \
					[258]="tcb2074" \
					[259]="tcb2075" \
					[260]="tcb2076" \
					[261]="tcb2077" \
					[262]="tcb2078" \
					[263]="tcb2079" \
					[264]="tcb2081" \
					[265]="tcb2082" \
					[266]="tcb2083" \
					[267]="tcb2086" \
					[268]="tcb2088" \
					[269]="tcb2091" \
					[270]="tcb2093" \
					[271]="tcb2084" \
					[272]="tcb2090" \
					[273]="tcb2097" \
					[274]="tcb2098" \
					[275]="tcb2094" \
					[276]="tcb2085" \
					[277]="tcb2099" \
					[278]="tcb2103" \
					[279]="tcb2105" \
					[280]="tcb2106" \
					[281]="tcb2107" \
					[282]="tcb2108" \
					[283]="tcb2109" \
					[284]="tcb2111" \
					[285]="tcb2116" \
					[286]="tcb2115" \
					[287]="tcb2112" \
					[288]="tcb2119" \
					[289]="tcb2113" \
					[290]="tcb2120" \
					[291]="tcb2117" \
					[292]="tcb2118" \
					[293]="tcb2126"	\
					[294]="tcb2124" \
					[295]="tcb2123" \
					[296]="tcb2121" \
					[297]="tcb2122" \
					[298]="tcb2125" \
					[299]="tcb2127"	)

# Dictionary of series to skip per subject (ignore the non-RMS T1)
declare -A skip_map=([201]="-s 6" \
					[202]="-s 6" \
					[203]="-s 6" \
					[204]="-s 6" \
					[205]="-s 6" \
					[206]="-s 6" \
					[207]="-s 6" \
					[208]="-s 6" \
					[209]="-s 6" \
					[210]="-s 6" \
					[211]="-s 6" \
					[212]="-s 6" \
					[213]="-s 6" \
					[214]="-s 6" \
					[215]="-s 6" \
					[216]="-s 6" \
					[217]="-s 6 -s 12" \
					[218]="-s 6" \
					[219]="-s 6" \
					[220]="-s 6" \
					[221]="-s 6" \
					[222]="-s 6" \
					[223]="-s 6" \
					[224]="-s 6" \
					[225]="-s 6" \
					[226]="-s 6" \
					[227]="-s 6" \
					[228]="-s 6" \
					[229]="-s 6 -s 12" \
					[230]="-s 6" \
					[231]="-s 6" \
					[232]="-s 6" \
					[233]="-s 6 -s 9" \
					[234]="-s 6" \
					[235]="-s 6" \
					[236]="-s 6" \
					[237]="-s 6" \
					[238]="-s 6" \
					[239]="-s 6" \
					[240]="-s 6" \
					[241]="-s 6" \
					[242]="-s 6 -s 14" \
					[243]="-s 6" \
					[244]="-s 6" \
					[245]="-s 6" \
					[246]="-s 6" \
					[247]="-s 6" \
					[248]="-s 6" \
					[249]="-s 6" \
					[250]="-s 6" \
					[251]="-s 6" \
					[252]="-s 6" \
					[253]="-s 6" \
					[254]="-s 6" \
					[255]="-s 6" \
					[256]="-s 6 -s 13" \
					[257]="-s 6" \
					[258]="-s 6" \
					[259]="-s 6" \
					[260]="-s 6" \
					[261]="-s 6" \
					[262]="-s 6 -s 14" \
					[263]="-s 6" \
					[264]="-s 6" \
					[265]="-s 6" \
					[266]="-s 6" \
					[267]="-s 6" \
					[268]="-s 6" \
					[269]="-s 6" \
					[270]="-s 6" \
					[271]="-s 6" \
					[272]="-s 6" \
					[273]="-s 6" \
					[274]="-s 6" \
					[275]="-s 6" \
					[276]="-s 6" \
					[277]="-s 6 -s 9" \
					[278]="-s 6" \
					[279]="-s 6" \
					[280]="-s 6" \
					[281]="-s 6" \
					[282]="-s 6" \
					[283]="-s 6 -s 10" \
					[284]="-s 6" \
					[285]="-s 6" \
					[286]="-s 6" \
					[287]="-s 6" \
					[288]="-s 6" \
					[289]="-s 6" \
					[290]="-s 6" \
					[291]="-s 6" \
					[292]="-s 6" \
					[293]="-s 6" \
					[294]="-s 6" \
					[295]="-s 6" \
					[296]="-s 6" \
					[297]="-s 6" \
					[298]="-s 6" \
					[299]="-s 6"	)

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
		--cleanup 			\
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
		-v -v												\
		--includesubj ${SUBJ_LABEL} 
fi
