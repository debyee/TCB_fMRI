#!/bin/bash
#SBATCH -t 0:30:00
#SBATCH --mem=2GB
#SBATCH -N 1
#SBATCH -n 5
#SBATCH --mail-type=ALL
#SBATCH --mail-user=debbie_yee@brown.edu
#SBATCH --account=carney-ashenhav-condo  
#SBATCH -J fMRI_L2_group
#SBATCH -o logs/runLevel2_%x-%J_log.txt
#SBATCH -e logs/runLevel2_%x-%J_error.txt

# Loading matlab and spm for analysis
module load matlab/R2019a
module load spm/spm12


#--------- Variables ---------

# This line makes our bash script complain if we have undefined variables
set -u

#--------- CONFIGURE THESE VARIABLES ---------
participant_numbers=('2011' '2012' '2013' '2014' '2015' '2017' '2019' '2020' '2021' '2022'
                     '2024' '2026' '2027' '2028' '2029' '2030' '2031' '2032' '2033' '2034'
                     '2035' '2036' '2037' '2038' '2039' '2040' '2041' '2042' '2043' '2044' 
                     '2045' '2046' '2047' '2048' '2049' '2050' '2051' '2053' '2054' '2055'
                     '2057' '2058' '2059' '2060' '2061' '2062' '2063' '2064' '2065' '2066'
                     '2067' '2068' '2069' '2070' '2071' '2072' '2073' '2074' '2075' '2076' 
                     '2077' '2078' '2079' '2081' '2082' '2083' '2084' '2085' '2086' '2088' 
                     '2090' '2091' '2093' '2094' '2097' '2098' '2099' '2103' '2105' '2106' 
                     '2107' '2108' '2109' '2111' '2112' '2113' '2115' '2116' '2117' '2118' 
                     '2119' '2120' '2121' '2122' '2123' '2124' '2125' '2126' '2127')


# Define root path for where preprocessed and L1 data live                      
root_path='/gpfs/data/ashenhav/mri-data/TCB/spm-data/'

# Define the GLM you want to run (see case function below)
RunGLM=9

# Case Function: Define available GLMs
case ${RunGLM} in 
    1)
        echo "Running L2 analyses on GLM 1: 4/5 regressors, 4 Cues, TaskBug Regressor"
        design_foldername="glm1_Event_Cue_rwls"
        echo "Foldername is: ${design_foldername}"
        ;;
    2)
        echo "Running L2 analyses on GLM 2: 8/9 regressors, 4 Cues, 4 Int, TaskBug Regressor"
        design_foldername="glm2_Event_CueInt_rwls"
        echo "Foldername is: ${design_foldername}"
        ;;
    3)
        echo "Running L2 analyses on GLM 3: 12/13 regressors, 4 Cues, 4 Int, 4 Fb, TaskBug Regressor"
        design_foldername="glm3_Event_CueIntFb_rwls"
        echo "Foldername is: ${design_foldername}"
        ;;
    4)
        echo "Running L2 analyses on GLM 4: Baseline Pmod with Reward, Penalty"
        design_foldername="glm4_Pmod_RewPen_rwls"
        echo "Foldername is: ${design_foldername}"
        ;;
    5)
        echo "Running L2 analyses on GLM 5: Pmod with Reward, Penalty, Interval Num, Interval Length, Mean Congruency"
        design_foldername="glm5_Pmod_RewPenTask_rwls"
        echo "Foldername is: ${design_foldername}"
        ;;
    6)
        echo "Running L2 analyses on GLM 6: Pmod with Reward, Penalty, Interval Num, Interval Length, Mean Congruency, RT, Accuracy, RT*Rew, RT*Pen"
        design_foldername="glm6_Pmod_RewPenTask_RTACC_rwls"
        echo "Foldername is: ${design_foldername}"
        ;;
    7)
        echo "Running L2 analyses on GLM 7: Pmod with Reward, Penalty, Reward*Penalty, Interval Num, Interval Length, Mean Congruency, RT, Accuracy, RT*Rew, RT*Pen"
        design_foldername="glm7_Pmod_RewPenTask_RTACC_interact_rwls"
        echo "Foldername is: ${design_foldername}"
        ;; 
    8)
        echo "Running L2 analyses on GLM 8: Pmod with Reward, Penalty, (Cue_Fixed), Interval Num, Interval Length, Mean Congruency, RT, Accuracy, RT*Rew, RT*Pen"
        design_foldername="glm8_Pmod_RewPenTask_RTACC_CueFixed_rwls"
        echo "Foldername is: ${design_foldername}"
        ;;
    9)
        echo "Running L2 analyses on GLM 9: Pmod with Reward, Penalty, Rew*Pen, (CueFixed) Interval Num, Interval Length, Mean Congruency, RT, Accuracy, RT*Rew, RT*Pen"
        design_foldername="glm9_Pmod_RewPenTask_RTACC_CueFixed_interact_rwls"
        echo "Foldername is: ${design_foldername}"
        ;;    
    # 10)
    #     echo "Running L2 analyses on GLM 8: 5/6 regressors (cue (fixed), int, fb, error, taskbug), Pmod with Reward, Penalty, RT center, Accuracy, IntervalNum, IntervalLength"
    #     design_foldername="design_AllIntervPmod_RewPenRTaccIntFixed_rwls"
    #     echo "Foldername is: ${design_foldername}"
    #     ;;
    # 11)
    #     echo "Running L2 analyses on GLM 10: All Intervals, FIR analyses, knots from cue onset"
    #     design_foldername="design_AllIntervals_FIR_rwls"
    #     echo "Foldername is: ${design_foldername}"
    #     ;;

esac

# Define the contrast array based upon the design_foldername
if [[ "${design_foldername}" == "glm1_Event_Cue_rwls" ]]; then

    echo "GLM1: Event-epoch with 4 regressors."
    # Declare an associate array with relevant contrasts
    declare -A contrast=(['1']='C1_Cue_TaskvsBaseline'  \
                        ['2']='C2_Cue_HighvsLowReward'  \
                        ['3']='C3_Cue_HighvsLowPenalty' )

elif [[ "${design_foldername}" == "glm2_Event_CueInt_rwls" ]]; then

    echo "GLM2: Event-epoch with 8 regressors."
    # Declare an associate array with relevant contrasts
    declare -A contrast=(['1']='C1_Cue_TaskvsBaseline'  \
                        ['2']='C2_Int_TaskvsBaseline'   \
                        ['3']='C3_Cue_HighvsLowReward'  \
                        ['4']='C4_Cue_HighvsLowPenalty' \
                        ['5']='C5_Int_HighvsLowReward'  \
                        ['6']='C6_Int_HighvsLowPenalty' )

elif [[ "${design_foldername}" == "glm3_Event_CueIntFb_rwls" ]]; then

    echo "GLM3: Event-epoch with 12 regressors."
    # Declare an associate array with relevant contrasts
    declare -A contrast=(['1']='C1_Cue_TaskvsBaseline'  \
                        ['2']='C2_Int_TaskvsBaseline'   \
                        ['3']='C3_Cue_HighvsLowReward'  \
                        ['4']='C4_Cue_HighvsLowPenalty' \
                        ['5']='C5_Int_HighvsLowReward'  \
                        ['6']='C6_Int_HighvsLowPenalty' \
                        ['7']='C7_Fb_HighvsLowReward'   \
                        ['8']='C8_Fb_HighvsLowPenalty'  )
    
elif [[ "${design_foldername}" == 'glm4_Pmod_RewPen_rwls' ]]; then

    echo "GLM4: 13 contrasts, pmod with Reward and Penalty"
    # Declare an associate array with relevant contrasts
    declare -A contrast=(['1']='C1_Cues'            \
                        ['2']='C2_CuesxRew'         \
                        ['3']='C3_CuesxPen'         \
                        ['4']='C4_CuesxRew-Pen'     \
                        ['5']='C5_Int'              \
                        ['6']='C6_IntxRew'          \
                        ['7']='C7_IntxPen'          \
                        ['8']='C8_IntxRew-Pen'      \
                        ['9']='C9_Int-Cue'          \
                        ['10']='C10_IntxRew-CuexRew'\
                        ['11']='C11_IntxPen-CuexPen'\
                        ['12']='C12_Fb'             \
                        ['13']='C13_Error'          )

elif [[ "${design_foldername}" == 'glm5_Pmod_RewPenTask_rwls' ]]; then

    echo "GLM5: 17 contrasts, pmod with Reward, Penalty, Interval Num, Interval Length, Mean Congruency"
    # Declare an associate array with relevant contrasts
    declare -A contrast=(['1']='C1_Cues'                \
                        ['2']='C2_CuesxRew'             \
                        ['3']='C3_CuesxPen'             \
                        ['4']='C4_CuesxIntervalNum'     \
                        ['5']='C5_CuesxRew-Pen'         \
                        ['6']='C6_Int'                  \
                        ['7']='C7_IntxRew'              \
                        ['8']='C8_IntxPen'              \
                        ['9']='C9_IntxIntervalNum'      \
                        ['10']='C10_IntxIntervalLength' \
                        ['11']='C11_IntxMeanCongruency' \
                        ['12']='C12_IntxRew-Pen'        \
                        ['13']='C13_Int-Cue'            \
                        ['14']='C14_IntxRew-CuexRew'    \
                        ['15']='C15_IntxPen-CuexPen'    \
                        ['16']='C16_Fb'                 \
                        ['17']='C17_Error'              )

elif [[ "${design_foldername}" == 'glm6_Pmod_RewPenTask_RTACC_rwls' ]]; then

    echo "GLM6: 21 contrasts, pmod with Reward, Penalty, IntervalNum, Interval Length, Mean Congruency, RT, Accuracy, RT*Rew, RT*Pen"
    # Declare an associate array with relevant contrasts
    declare -A contrast=(['1']='C1_Cues'                \
                        ['2']='C2_CuesxRew'             \
                        ['3']='C3_CuesxPen'             \
                        ['4']='C4_CuesxIntervalNum'     \
                        ['5']='C5_CuesxRew-Pen'         \
                        ['6']='C6_Int'                  \
                        ['7']='C7_IntxRew'              \
                        ['8']='C8_IntxPen'              \
                        ['9']='C9_IntxIntervalNum'      \
                        ['10']='C10_IntxIntervalLength' \
                        ['11']='C11_IntxMeanCongruency' \
                        ['12']='C12_IntxavgRT'          \
                        ['13']='C13_IntxavgACC'         \
                        ['14']='C14_IntxavgRTxRew'      \
                        ['15']='C15_IntxavgRTxPen'      \
                        ['16']='C16_IntxRew-Pen'        \
                        ['17']='C17_Int-Cue'            \
                        ['18']='C18_IntxRew-CuexRew'    \
                        ['19']='C19_IntxPen-CuexPen'    \
                        ['20']='C20_Fb'                 \
                        ['21']='C21_Error'              )

elif [[ "${design_foldername}" == 'glm7_Pmod_RewPenTask_RTACC_interact_rwls' ]]; then

    echo "GLM7: 23 contrasts, pmod with Reward, Penalty, IntervalNum, Interval Length, Mean Congruency, RT, Accuracy, RT*Rew, RT*Pen"
    # Declare an associate array with relevant contrasts
    declare -A contrast=(['1']='C1_Cues'                \
                        ['2']='C2_CuesxRew'             \
                        ['3']='C3_CuesxPen'             \
                        ['4']='C4_CuesxIntervalNum'     \
                        ['5']='C5_CuesxRewxPen'         \
                        ['6']='C6_CuesxRew-Pen'         \
                        ['7']='C7_Int'                  \
                        ['8']='C8_IntxRew'              \
                        ['9']='C9_IntxPen'              \
                        ['10']='C10_IntxIntervalNum'    \
                        ['11']='C11_IntxIntervalLength' \
                        ['12']='C12_IntxMeanCongruency' \
                        ['13']='C13_IntxavgRT'          \
                        ['14']='C14_IntxavgACC'         \
                        ['15']='C15_IntxavgRTxRew'      \
                        ['16']='C16_IntxavgRTxPen'      \
                        ['17']='C17_IntxRewxPen'        \
                        ['18']='C18_IntxRew-Pen'        \
                        ['19']='C19_Int-Cue'            \
                        ['20']='C20_IntxRew-CuexRew'    \
                        ['21']='C21_IntxPen-CuexPen'    \
                        ['22']='C22_Fb'                 \
                        ['23']='C23_Error'              )

elif [[ "${design_foldername}" == 'glm8_Pmod_RewPenTask_RTACC_CueFixed_rwls' ]]; then

    echo "GLM8: 29 contrasts, pmod with Reward, Penalty, CueFixed, Interval Num, Interval Length, Mean Congruency, RT, Accuracy, RT*Rew, RT*Pen"
    # Declare an associate array with relevant contrasts
    declare -A contrast=(['1']='C1_RFixCues'                \
                        ['2']='C2_RFixCuesxRew'             \
                        ['3']='C3_RFixCuesxPen'             \
                        ['4']='C4_RFixCuesxIntervalNum'     \
                        ['5']='C5_RFixCuesxRew-Pen'         \
                        ['6']='C6_PFixCues'                 \
                        ['7']='C7_PFixCuesxRew'             \
                        ['8']='C8_PFixCuesxPen'             \
                        ['9']='C9_RFixCuesxIntervalNum'     \
                        ['10']='C10_PFixCuesxRew-Pen'       \
                        ['11']='C11_Int'                    \
                        ['12']='C12_IntxRew'                \
                        ['13']='C13_IntxPen'                \
                        ['14']='C14_IntxIntervalNum'        \
                        ['15']='C15_IntxIntervalLength'     \
                        ['16']='C16_IntxMeanCongruency'     \
                        ['17']='C17_IntxavgRT'              \
                        ['18']='C19_IntxavgACC'             \
                        ['19']='C19_IntxavgRTxRew'          \
                        ['20']='C20_IntxavgRTxPen'          \
                        ['21']='C21_IntxRew-Pen'            \
                        ['22']='C22_Int-RFixCue'            \
                        ['23']='C23_IntxRew-RFixCuexRew'    \
                        ['24']='C24_IntxPen-RFixCuexPen'    \
                        ['25']='C25_Int-RFixCue'            \
                        ['26']='C26_IntxRew-RFixCuexRew'    \
                        ['27']='C27_IntxPen-RFixCuexPen'    \
                        ['28']='C28_Fb'                     \
                        ['29']='C29_Error'                  )

elif [[ "${design_foldername}" == 'glm9_Pmod_RewPenTask_RTACC_CueFixed_interact_rwls' ]]; then

    echo "GLM9: 32 contrasts, pmod with Reward, Penalty, CueFixed, Rew*Pen, Interval Num, Interval Length, Mean Congruency, RT, Accuracy, RT*Rew, RT*Pen"
    # Declare an associate array with relevant contrasts
    declare -A contrast=(['1']='C1_RFixCues'                \
                        ['2']='C2_RFixCuesxRew'             \
                        ['3']='C3_RFixCuesxPen'             \
                        ['4']='C4_RFixCuesxIntervalNum'     \
                        ['5']='C5_RFixCuesxRewxPen'         \
                        ['6']='C6_RFixCuesxRew-Pen'         \
                        ['7']='C7_PFixCues'                 \
                        ['8']='C8_PFixCuesxRew'             \
                        ['9']='C9_PFixCuesxPen'             \
                        ['10']='C10_RFixCuesxIntervalNum'   \
                        ['11']='C11_PFixCuesxRewxPen'       \
                        ['12']='C12_PFixCuesxRew-Pen'       \
                        ['13']='C13_Int'                    \
                        ['14']='C14_IntxRew'                \
                        ['15']='C15_IntxPen'                \
                        ['16']='C16_IntxIntervalNum'        \
                        ['17']='C17_IntxIntervalLength'     \
                        ['18']='C18_IntxMeanCongruency'     \
                        ['19']='C19_IntxavgRT'              \
                        ['20']='C20_IntxavgACC'             \
                        ['21']='C21_IntxavgRTxRew'          \
                        ['22']='C22_IntxavgRTxPen'          \
                        ['23']='C23_IntxavgRTxPen'          \
                        ['24']='C24_IntxRew-Pen'            \
                        ['25']='C25_Int-RFixCue'            \
                        ['26']='C26_IntxRew-RFixCuexRew'    \
                        ['27']='C27_IntxPen-RFixCuexPen'    \
                        ['28']='C28_Int-RFixCue'            \
                        ['29']='C29_IntxRew-RFixCuexRew'    \
                        ['30']='C30_IntxPen-RFixCuexPen'    \
                        ['31']='C31_Fb'                     \
                        ['32']='C32_Error'                  )
                
else
    echo "design_foldername not defined! please try again"
    exit 1
fi

#contrasts=('C1_Cue_TaskvsBaseline' 'C2_Cue_HighvsLowReward' 'C3_Cue_HighvsLowPenalty')
#contrasts_num=('0001','002','003')
#design_SOTS='TCB_Event_Cue_RewPenHighLow_sots_allTcat'
#design_foldername="design_CueInt8_EventEpoch_rwls"
#design_SOTS="TCB_Event_CueInterval_GainLossHighLow_sots_allTcat"

#--------- SETUP FOLDERS FOR GROUP STATS ---------
# If groupstats folder does not exist, then create it
groupstats_folder="${root_path}groupstats"
echo ${groupstats_folder}
if [[ -d ${groupstats_folder} ]]; then
    echo "${groupstats_folder} exists. No changes required."
else
    echo "${groupstats_folder} not found. Will create a new folder."
    mkdir ${groupstats_folder}
fi

# If contrasts folder do not exist for the design, then create them
for cid in "${!contrast[@]}"; do
    contrast_folder="${root_path}groupstats/${design_foldername}/${contrast[$cid]}"
    echo ${contrast_folder}
    if [[ -d ${contrast_folder} ]]; then
        echo "${contrast_folder} exists. No changes required."
    else
        echo "${contrast_folder} not found. Will create a new folder."
        mkdir -p ${contrast_folder}
    fi

    # Move contrasts from Level1 folder to groupstats folder
    for pid in "${participant_numbers[@]}"; do
        #echo "${root_path}sub-${pid}/${design_foldername}/con_000${cid}.nii" "${root_path}/groupstats/${design_foldername}/${contrast[$cid]}/sub-${pid}_con_001${cid}.nii"
        echo "Copying contrast: Subject ${pid} Contrast ${cid} to Folder ${contrast[$cid]}"
        if [ ${cid} -lt 10 ]; then
            cp "${root_path}sub-${pid}/${design_foldername}/con_000${cid}.nii" "${root_path}/groupstats/${design_foldername}/${contrast[$cid]}/sub-${pid}_con_000${cid}.nii" 
            cp "${root_path}sub-${pid}/${design_foldername}/spmT_000${cid}.nii" "${root_path}/groupstats/${design_foldername}/${contrast[$cid]}/sub-${pid}_spmT_000${cid}.nii" 
        elif [ ${cid} -ge 10 ]; then
            cp "${root_path}sub-${pid}/${design_foldername}/con_00${cid}.nii" "${root_path}/groupstats/${design_foldername}/${contrast[$cid]}/sub-${pid}_con_00${cid}.nii" 
            cp "${root_path}sub-${pid}/${design_foldername}/spmT_00${cid}.nii" "${root_path}/groupstats/${design_foldername}/${contrast[$cid]}/sub-${pid}_spmT_00${cid}.nii" 
        else
            echo 'Contrast not valid, please check contrast number.'
        fi
    done

done

# Sanity Check to check the keys. If you want to loop over values, remove "!" from before array
# for i in "${!contrast[@]}"
# do
#   echo "key  : $i"
#   echo "value: ${contrast[$i]}"
# done


#--------- RUN LEVEL 2 ANALYSIS ---------
#matlab-threaded -nodisplay -nodesktop -r "TCB_makeRegressor('${design_foldername}');exit;"

# iterate over each contrast 
for cid in "${!contrast[@]}"; do

    # Identify subjects for group analysis, save to text file
    contrast_folder="${root_path}groupstats/${design_foldername}/${contrast[$cid]}"
    echo "${contrast_folder}"
    echo ${participant_numbers[@]} >> "${contrast_folder}/participant_numbers.txt"

    # If SPM.mat file already exists, then remove it
    spm_mat_file="${contrast_folder}/SPM.mat"
    echo ${spm_mat_file}
    if [[ -f ${spm_mat_file} ]]; then
        echo "SPM mat file ${spm_mat_file} exists. Will delete and overwrite."
        rm ${spm_mat_file}
    else
        echo "No SPM mat file found. Will create a new SPM.mat file."
    fi

    # Runs Level 2 analyses 
    matlab-threaded -nodesktop -nodisplay -r "TCB_runLevel2_group('${root_path}','${contrast_folder}','${design_foldername}','${contrast[$cid]}');exit;"
    # if issues, try: #matlab -nodesktop -r addpath '/gpfs/rt/7.2/opt/spm/spm12' "TCB_runLevel2_group('${root_path}','${contrast_folder}','${design_foldername}','${contrast[$cid]}');exit;"
    echo "Contrast ${cid} analyzed."

done


# Probably can delete this later.

# GLM 3: 12 regressors, 4 Cues, 4 Int, 4 Fb (EventEpoch)
# design_foldername='design_CueIntFb12_EventEpoch_rwls'  

# GLM 4: 4 regressors (cue, int, fb, error), parametric modulator for Reward, Penalty 
#design_foldername='design_AllIntervPmod_RewPen_rwls'

# GLM 5: 4 regressors (cue, int, fb, error), parametric modulator for Reward, Penalty, avg RT and avg ACC 
# design_foldername='design_AllIntervPmod_RewPenRTacc_rwls'

# GLM 6: Pmod with Reward, Penalty, RewxPen Interaction, RT, and Accuracy
# design_foldername='design_AllIntervPmod_RewPenRTacc_interact_rwls'

# GLM 7: Pmod with Reward, Penalty, RewxPen Interaction
# design_foldername='design_AllIntervPmod_RewPenInteract_rwls'

# Echo the design for the log file
#echo "Running L2 analyses on ${design_foldername}"