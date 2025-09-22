#!/bin/bash
#SBATCH --account=carney-ashenhav-condo
#SBATCH --time=120:00:00
#SBATCH --mem-per-cpu=10G
#SBATCH -n 1
#SBATCH -c 15
#SBATCH -N 1
#SBATCH --mail-type=ALL
#SBATCH --mail-user=debbie_yee@brown.edu
#SBATCH -J model_ppc_TCB
#SBATCH -o logs/ppc_array-%a_job-%j.out
#SBATCH --array=249

# NOTE: make sure you activate conda environment with hddm before launching script
# conda activate hddm_env_python3
# module list, module purge, module load gcc/6.5.0-lwshmxc, followed by conda activate py3HDDM (updated 4/10/24)

#----------- Dictionaries for model specific variables -----
# Dictionary of model labels
declare -A labels=( [201]="model1_RewPen"                           \
                    [202]="model2_RewPenInt"                        \
                    [203]="model3_RewPen_SRT"                       \
                    [204]="model4_RewPenInt_SRT"                    \
                    [205]="model5_RewPen_SRT_Striatum_Cue"          \
                    [206]="model6_RewPen_SRT_AI_Cue"                \
                    [207]="model7_RewPen_SRT_dACC_ctrl_Cue"         \
                    [208]="model8_RewPen_SRT_dACC_sal_Cue"          \
                    [209]="model9_RewPen_SRT_dACC_ctrl_Interval"    \
                    [210]="model10_RewPen_SRT_dACC_sal_Interval"    \
                    [211]="model11_RewPen_SRT_PFCl_ctrl_Interval"   \
                    [212]="model12_RewPen_SRT_PFCl_sal_Interval"    \
                    [213]="model13_RewPen_SRT_IFG_Interval"         \
                    [214]="model1"                                  \
                    [215]="model2"                                  \
                    [216]="model3"                                  \
                    [217]="model4"                                  \
                    [218]="model5"                                  \
                    [219]="model6"                                  \
                    [220]="model7"                                  \
                    [221]="model8"                                  \
                    [222]="model9"                                  \
                    [223]="model10"                                 \
                    [224]="model11"                                 \
                    [225]="model12"                                 \
                    [226]="model13"                                 \
                    [227]="model14"                                 \
                    [228]="model15"                                 \
                    [229]="model16"                                 \
                    [230]="model17"                                 \
                    [231]="model18"                                 \
                    [232]="model19"                                 \
                    [233]="model20"                                 \
                    [234]="model21"                                 \
                    [235]="model22"                                 \
                    [236]="model23"                                 \
                    [237]="model24"                                 \
                    [238]="model25"                                 \
                    [239]="model26"                                 \
                    [240]="model27"                                 \
                    [241]="model28"                                 \
                    [242]="model29"                                 \
                    [243]="model30"                                 \
                    [244]="model31"                                 \
                    [245]="model32"                                 \
                    [246]="model33"                                 \
                    [247]="model34"                                 \
                    [248]="model35"                                 \
                    [249]="model36"                                 \
                    [250]="model37"                                 \
                    [251]="model38"                                 \
                    [252]="model39"                                 \
                    [253]="model30"                                 \
                    [254]="model31"                                 \
                    [255]="model32"                                 \
                    [256]="model33"                                 \
                    [257]="model34"                                 \
                    [258]="model35"                                 \
                    [259]="model36"                                 \
                    [260]="model37"                                 \
                    [261]="model38"                                 \
                    [262]="model39"                                 \
                    [263]="model40"                                 \
                    [264]="model41"                                 \
                    [265]="model42"                                 \
                    [266]="model43"                                 \
                    [267]="model44"                                 \
                    [268]="model45"                                 \
                    [269]="model46"                                 \
                    [270]="model47"                                 \
                    [271]="model48"                                 \
                    [272]="model49"                                 \
                    [273]="model50"                                 \
                    [274]="model51"                                 \
                    [275]="model52"                                 \
                    [276]="model53"                                 \
                    [277]="model54"                                 \
                    [278]="model55"                                 \
                    [279]="model56"                                 \
                    [280]="model57"                                 \
                    [281]="model58"                                 \
                    [282]="model59"                                 )


# Use task array ID to get right value for this job
# These are defined within the sbatch header
MODEL_LABEL=${labels[${SLURM_ARRAY_TASK_ID}]}

# Echo the model for the log
echo "ModelName: ${MODEL_LABEL}"

# Run python script for each model in parallel
# adding '-u' flag removes the buffer  for writing out log files 
python -u ../HDDM_scripts/model_posterior_predictive_check_extended.py ../models/${MODEL_LABEL}.json

