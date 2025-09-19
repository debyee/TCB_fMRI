#!/bin/bash
#SBATCH -t 100:00:00
#SBATCH --mem-per-cpu=20G
#SBATCH -N 1
#SBATCH -n 10
#SBATCH --mail-type=ALL
#SBATCH --mail-user=debbie_yee@brown.edu
#SBATCH --account=carney-ashenhav-condo  
#SBATCH -J TCB-fmriprep-fieldmap_ica_par
#SBATCH --output logs/fmriprep-log-%J.txt
#SBATCH --error logs/fmriprep-error-%J.txt
#SBATCH --array=234-286

#--------- CONFIGURE THESE VARIABLES ---------

bids_root_dir=/gpfs/data/ashenhav/mri-data/TCB     # based on oscar path
#bids_root_dir=/gpfs/data/bnc/scratch
investigator=shenhav                            # investigator
study_label=201226                              # study label 
fmriprep_version=20.2.6   #20.0.6               # check ls ls /gpfs/data/bnc/simgs/nipreps/ for the latest version
#nthreads=64 				                    # heuristic: 2x number of cores 

#----------- Dictionaries for subject specific variables -----
# Dictionary of labels per subject
declare -A labels=( [201]="tcb2011" \
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

# Use the task array ID to get the right value for this job
# These are defined with the SBATCH header
SUBJ_LABEL=${labels[${SLURM_ARRAY_TASK_ID}]}

# creates tmp directory for temporary files (will be deleted after job is complete)
# Note: you can check to see that the files are being added while the job is running
# mkdir -p /tmp/fmriprep
mkdir -p /tmp/$SLURM_JOB_ID         

# Sets singularity scratch directory to scratch (before you run singularity command)
SINGULARITY_CACHEDIR=~/scratch

#--------- Run FMRIPREP --------- 

# runs singularity for each subject
singularity run --cleanenv                                              	        \
    --bind ${bids_root_dir}/${investigator}/study-${study_label}:/data              \
	--bind /tmp/$SLURM_JOB_ID:/scratch 												\
	--bind /gpfs/data/bnc/licenses:/licenses                                        \
    /gpfs/data/bnc/simgs/nipreps/fmriprep-${fmriprep_version}.sif                   \
    /data/bids /data/bids/derivatives/fmriprep-${fmriprep_version}-nofs             \
    participant 															        \
    --participant-label ${SUBJ_LABEL} 								                \
    --fs-license-file /licenses/freesurfer-license.txt 						        \
    -w /scratch/fmriprep 													        \
    --stop-on-first-crash                            						        \
    --nthreads 64 															        \
    --write-graph 															        \
    --use-aroma   


# --bind /gpfs/scratch/dyee7:/scratch                                             \
# --bind /tmp/fmriprep:/tmp                                                       \