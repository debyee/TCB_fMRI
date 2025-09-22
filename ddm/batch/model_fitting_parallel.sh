#!/bin/bash
#SBATCH --account=carney-ashenhav-condo
#SBATCH --time=200:00:00
#SBATCH --mem-per-cpu=3G
#SBATCH -n 1
#SBATCH -c 20
#SBATCH -N 1
#SBATCH --mail-type=ALL
#SBATCH --mail-user=debbie_yee@brown.edu
#SBATCH -J model_fit1_TCB
#SBATCH -o logs/fit_array-%a_job-%j.out
#SBATCH --array=368

# NOTE: make sure you activate conda environment with hddm before launching script
# conda activate hddm_env_python3
# module list, module purge, module load gcc/6.5.0-lwshmxc, followed by conda activate py3HDDM (updated 4/10/24)


# -c = CPU Cores
# -N = Nodes
# -n = Number of tasks
# -mem

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
                    [343]="model30"                                 \
                    [344]="model31"                                 \
                    [345]="model32"                                 \
                    [346]="model33"                                 \
                    [347]="model34"                                 \
                    [348]="model35"                                 \
                    [349]="model36"                                 \
                    [350]="model37"                                 \
                    [351]="model38"                                 \
                    [352]="model39"                                 \
                    [353]="model30"                                 \
                    [354]="model31"                                 \
                    [355]="model32"                                 \
                    [356]="model33"                                 \
                    [357]="model34"                                 \
                    [358]="model35"                                 \
                    [359]="model36"                                 \
                    [360]="model37"                                 \
                    [361]="model38"                                 \
                    [362]="model39"                                 \
                    [363]="model40"                                 \
                    [364]="model41"                                 \
                    [365]="model42"                                 \
                    [366]="model43"                                 \
                    [367]="model44"                                 \
                    [368]="model45"                                 \
                    [369]="model46"                                 \
                    [370]="model47"                                 \
                    [371]="model48"                                 \
                    [372]="model49"                                 \
                    [373]="model50"                                 \
                    [374]="model51"                                 \
                    [375]="model52"                                 \
                    [376]="model53"                                 \
                    [377]="model54"                                 \
                    [378]="model55"                                 \
                    [379]="model56"                                 \
                    [380]="model57"                                 \
                    [381]="model58"                                 \
                    [382]="model59"                                 \
                    [383]="model60"                                 )

# Use task array ID to get right value for this job
# These are defined within the sbatch header
MODEL_LABEL=${labels[${SLURM_ARRAY_TASK_ID}]}

# Echo the model for the log
echo "The current model is ${MODEL_LABEL}"

# Run python script for each model in parallel
# adding '-u' flag removes the buffer  for writing out log files 
python -u ../HDDM_scripts/model_fitting_extended.py ../models/${MODEL_LABEL}.json

