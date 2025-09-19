#!/bin/bash
#SBATCH -t 0:60:00
#SBATCH --mem=3GB
#SBATCH -N 1
#SBATCH -n 5
#SBATCH -c 1
#SBATCH --mail-type=ALL
#SBATCH --mail-user=debbie_yee@brown.edu
#SBATCH --account=carney-ashenhav-condo  
#SBATCH -J fMRI_L1_GLM
#SBATCH -o logs/runLevel1_%x-%J_log.txt
#SBATCH -e logs/runLevel1_%x-%J_error.txt
#SBATCH --array=233,234

# Loading matlab and spm for analysis
module load matlab/R2019a
module load spm/spm12

#--------- CONFIGURE THESE VARIABLES ---------
# This line makes our bash script complain if we have undefined variables
set -u

# Define root path for where preprocessed and unzipped data live
root_path='/gpfs/data/ashenhav/mri-data/TCB/spm-data/'

# Define the GLM you want to run (see case function below)
RunGLM=10

# Case Function: Define available GLMs
case ${RunGLM} in 
    1)
        echo "Running GLM 1: 4 regressors: 4 Cues, 1 TaskBug"
        design_foldername="glm1_Event_Cue_rwls"
        design_SOTS="TCB_Event_Cue_RewPenHighLow_sots_allTcat"
        echo "Foldername is: ${design_foldername}"
        echo "SOTS is:  ${design_SOTS}"
        ;;
    2)
        echo "Running GLM 2: 8 regressors, 4 Cues, 4 Int, 1 TaskBug"
        design_foldername='glm2_Event_CueInt_rwls'
        design_SOTS="TCB_Event_CueInt_RewPenHighLow_sots_allTcat"
        echo "Foldername is: ${design_foldername}"
        echo "SOTS is:  ${design_SOTS}"
        ;;
    3)
        echo "Running GLM 3: 12 regressors, 4 Cues, 4 Int, 4 Fb, 1 TaskBug"
        design_foldername="glm3_Event_CueIntFb_rwls"
        design_SOTS="TCB_Event_CueIntFb_RewPenHighLow_sots_allTcat"
        echo "Foldername is: ${design_foldername}"
        echo "SOTS is:  ${design_SOTS}"
        ;;
    4)
        echo "Running GLM 4: 8 regressors (cue, int fb, error), 1 Taskbug, Pmod with Reward, Penalty"
        design_foldername="glm4_Pmod_RewPen_rwls"
        design_SOTS="TCB_Pmod_RewPen_sots_allTcat"
        echo "Foldername is: ${design_foldername}"
        echo "SOTS is: ${design_SOTS}"
        ;;
    5)
        echo "Running GLM 5: 12 regressors (cue, int, fb, error), 1 Taskbug, Pmod with Reward, Penalty, IntervalNum, IntervalLength, MeanCongruency"
        design_foldername="glm5_Pmod_RewPenTask_rwls"
        design_SOTS="TCB_Pmod_RewPenTask_sots_allTcat"
        echo "Foldername is: ${design_foldername}"
        echo "SOTS is: ${design_SOTS}"
        ;;
    6)
        echo "Running GLM 6: 16 regressors (cue, int, fb, error), 1 Taskbug Pmod with Reward, Penalty, IntervalNum, IntervalLength, MeanCongruency, RT center, Accuracy, RT*Rew, RT*Pen"
        design_foldername="glm6_Pmod_RewPenTask_RTACC_rwls" 
        design_SOTS="TCB_Pmod_RewPenTask_RTACC_sots_allTcat"
        echo "Foldername is: ${design_foldername}"
        echo "SOTS is: ${design_SOTS}"
        ;;
    7)
        echo "Running GLM 7: 18 regressors (cue, int, fb, error, taskbug), Pmod with Reward, Penalty, RT center, Accuracy, IntervalNum, IntervalLength, RT*Rew, RT*Pen"
        design_foldername="glm7_Pmod_RewPenTask_RTACC_interact_rwls"
        design_SOTS="TCB_Pmod_RewPenTask_RTACC_interact_sots_allTcat"
        echo "Foldername is: ${design_foldername}"
        echo "SOTS is: ${design_SOTS}"
        ;;
    8)
        echo "Running GLM 8: 5/6 regressors (cue (fixed), int, fb, error, taskbug), Pmod with Reward, Penalty, RT center, Accuracy, IntervalNum, IntervalLength, RT*Rew, RT*Pen"
        design_foldername="glm8_Pmod_RewPenTask_RTACC_CueFixed_rwls"
        design_SOTS="TCB_Pmod_RewPenTask_RTACC_CueFixed_sots_allTcat"
        echo "Foldername is: ${design_foldername}"
        echo "SOTS is: ${design_SOTS}"
        ;;
    9)
        echo "Running GLM 9: 5/6 regressors (cue (fixed), int, fb, error, taskbug), Pmod with Reward, Penalty, RT center, Accuracy, IntervalNum, IntervalLength, RT*Rew, RT*Pen"
        design_foldername="glm9_Pmod_RewPenTask_RTACC_CueFixed_interact_rwls"
        design_SOTS="TCB_Pmod_RewPenTask_RTACC_CueFixed_interact_sots_allTcat"
        echo "Foldername is: ${design_foldername}"
        echo "SOTS is: ${design_SOTS}"
        ;;
    10)
        echo "Running GLM 10: All Intervals, single beta extraction, 128*3 beta estimates minus task bug intervals (Include Error Regressors and TaskBug Regressor)"
        design_foldername="glm10_AllIntervals_rwls"
        design_SOTS="TCB_AllIntervals_sots_allTcat"
        echo "Foldername is: ${design_foldername}"
        echo "SOTS is: ${design_SOTS}"
        ;;
    # 11)
    #     echo "Running GLM 11: 5/6 regressors (cue (fixed), int, fb, error, taskbug), Pmod with Reward, Penalty, RT center, Accuracy, IntervalNum, IntervalLength"
    #     design_foldername="design_AllIntervPmod_RewPenRTaccIntFixed_rwls"
    #     design_SOTS="TCB_Event_AllIntervPmod_RewPenRTaccIntFixed_sots_allTcat"
    #     echo "Foldername is: ${design_foldername}"
    #     echo "SOTS is: ${design_SOTS}"
    #     ;;
    # 12)
    #     echo 'Running GLM 12: All Intervals, FIR analyses, knots from cue onset'
    #     design_foldername="design_AllIntervals_FIR_rwls"
    #     design_SOTS="TCB_AllIntervals_FIR_sots_allTcat"
    #     echo "Foldername is: ${design_foldername}"
    #     echo "SOTS is: ${design_SOTS}"
    #     ;;
esac

# #--------- MAKE REGRESSORS FOR INTERCEPTS AND DEMEANING ---------
# Create stimulus onset files for each participant 
matlab-threaded -nodisplay -nodesktop -r "TCB_makeSOTS;exit;"
# Create run and motion regressors for each participant
matlab-threaded -nodisplay -nodesktop -r "TCB_makeRegressor('${design_foldername}','${root_path}');exit;"

# Dictionary of labels per subject 
# NOTE: set array numbers at the SLURM heading at top of script
declare -A participant_numbers=([201]="tcb2011" \
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

# Completed: 2011,2012,2013,2014,2015,2017,2019,2020,2022,2026,2027,2030,
# 2031,2032,2033,2035,2028,2029,2037,2038,2036,2034,2040,2039,2041,2043,
# 2042,2045,2044,2047,2046,2049,2048,2050,2051,2053,2054,2044,2057,2058,
# 2059,2060,2061,2062,2063,2064,2065,2066,2067,2068,2069,2070,2071,2072,
# 2073,2074,2075,2076,2077,2078,2079,2081,2082,2086,2088,2091,2093,2084,
# 2090,2097,2098,2094,2085,2099,2103,2105,2106,2017,2108,2109,2111,2116,
# 2112,2119,2113,2120,2117,2118,2126,2124,2123,2121,2125,2127
# Skipped: 2018

# Use the task array ID to get the right value for this job
# These are defined with the SBATCH header
PAT_NUM=${participant_numbers[${SLURM_ARRAY_TASK_ID}]:3:7}

echo "Running job array number: "$SLURM_ARRAY_TASK_ID
echo "Processing participant: "${PAT_NUM}

#--------- WRITE SUBJECT NUMBER AND CONTRAST IN LOG FILE ---------
# For each participant, run level 1 analyses in SPM
echo
echo "Running Subject ${PAT_NUM}"
echo "Root Path is ${root_path}"
echo "Design Contrast is ${design_foldername}"
echo "Stimulus Onset File is ${design_SOTS}" 
echo

#--------- CREATE FOLDERS FOR GLMS IF THEY DONT EXIST ---------
# Check for GLM foldername, create if does not exist
echo "Checking for ${design_foldername}"
if [ ! -d "${root_path}sub-${PAT_NUM}/${design_foldername}" ]; then
    echo "GLM Foldername ${design_foldername} does not exist. Will create folder"
    mkdir "${root_path}sub-${PAT_NUM}/${design_foldername}"
else
    echo "GLM Foldername ${design_foldername} exists."
fi

#--------- RUNNING FMRI MODEL SPECIFICATION AND ESTIMATES ---------
# If SPM.mat file already exists, then remove it
spm_mat_file="${root_path}sub-${PAT_NUM}/${design_foldername}/SPM.mat"
echo "Checking for ${spm_mat_file}"
if [[ -f ${spm_mat_file} ]]; then
    echo "SPM mat file ${spm_mat_file} exists. Will delete and overwrite."
    rm ${spm_mat_file}
else
    echo "No SPM mat file found. Will create a new SPM.mat file."
fi

# Run matlab script to specify model and calculate estimates
matlab-threaded -nodesktop -nodisplay -r "TCB_runLevel1_fMRIModelSpec_Estimate('${PAT_NUM}','${root_path}','${design_foldername}','${design_SOTS}');exit;"
# #matlab-threaded -nodisplay -r "TCB_runLevel1GLM_fMRIModelSpec_Estimate('${pid}','${root_path}','${design_foldername}','${design_SOTS}');exit;"
echo "Subject ${PAT_NUM} estimates calculated."


#--------- RUNNING FMRI MODEL CONTRASTS ---------
matlab-threaded -nodesktop -nodisplay -r "TCB_runLevel1_contrast('${PAT_NUM}','${root_path}','${design_foldername}');exit;"
#matlab-threaded -nodesktop -r "TCB_runLevel1_contrast('${pid}','${root_path}','${design_foldername}');exit;"
echo "Subject ${PAT_NUM} contrast maps created."


