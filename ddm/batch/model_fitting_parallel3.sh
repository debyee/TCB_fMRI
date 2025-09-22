#!/bin/bash
#SBATCH --account=carney-ashenhav-condo
#SBATCH --time=180:00:00
#SBATCH --mem-per-cpu=20G
#SBATCH -n 1
#SBATCH -c 5
#SBATCH -N 1
#SBATCH --mail-type=ALL
#SBATCH --mail-user=debbie_yee@brown.edu
#SBATCH -J model_fit3
#SBATCH -o logs/fit_array-%a_job-%j.out
#SBATCH --array=309-313

# NOTE: make sure you activate conda environment with hddm before launching script
module purge
conda activate hddm_env_python3
# module purge, followed by conda activate py3HDDM (updated 4/10/24)

#----------- Dictionaries for model specific variables -----
# Dictionary of model labels
declare -A labels=( [301]="model1_RewPen"                           \
                    [302]="model2_RewPenInt"                        \
                    [303]="model3_RewPen_SRT"                       \
                    [304]="model4_RewPenInt_SRT"                    \
                    [305]="model5_RewPen_SRT_Striatum_Cue"          \
                    [306]="model6_RewPen_SRT_AI_Cue"                \
                    [307]="model7_RewPen_SRT_DACC_ctrl_Cue"         \
                    [308]="model8_RewPen_SRT_DACC_sal_Cue"          \
                    [309]="model9_RewPen_SRT_DACC_ctrl_Interval"    \
                    [310]="model10_RewPen_SRT_DACC_sal_Interval"    \
                    [311]="model11_RewPen_SRT_PFCl_ctrl_Interval"   \
                    [312]="model12_RewPen_SRT_PFCl_sal_Interval"    \
                    [313]="model13_RewPen_SRT_IFG_Interval"         \
                    [314]="model1"                                  \
                    [315]="model2"                                  \
                    [316]="model3"                                  \
                    [317]="model4"                                  \
                    [318]="model5"                                  \
                    [319]="model6"                                  \
                    [320]="model7"                                  \
                    [321]="model8"                                  \
                    [322]="model9"                                  \
                    [323]="model10"                                 \
                    [324]="model11"                                 \
                    [325]="model12"                                 \
                    [326]="model13"                                 \
                    [327]="model14"                                 \
                    [328]="model15"                                 \
                    [329]="model16"                                 \
                    [330]="model17"                                 \
                    [331]="model18"                                 \
                    [332]="model19"                                 \
                    [333]="model20"                                 \
                    [334]="model21"                                 \
                    [335]="model22"                                 \
                    [336]="model23"                                 \
                    [337]="model24"                                 \
                    [338]="model25"                                 \
                    [339]="model26"                                 \
                    [340]="model27"                                 \
                    [341]="model28"                                 \
                    [342]="model29"                                 \
                    [343]="model30"                                 )

#----------- Run model fitting script -----     

# Use task array ID to get right value for this job
# These are defined within the sbatch header
MODEL_LABEL=${labels[${SLURM_ARRAY_TASK_ID}]}

# Echo the model for the log
echo "The current model is ${MODEL_LABEL}"

# Run python script for each model in parallel
# adding '-u' flag removes the buffer  for writing out log files 
python -u ../HDDM_scripts/model_fitting_extended.py ../models/${MODEL_LABEL}.json

