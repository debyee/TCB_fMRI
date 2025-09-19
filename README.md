# TCB_fMRI

This is a repository for the fMRI study on Reward and Penalty and Mental Effort Allocation (in prep).

In the root directory, below are the following folders:

**task**: This contains the matlab code for experimental task. to run the task, you will need to launch the 'runTSS' folder. Data are output to the *TCB_RewardPenalty* folder.

Note that the Stroop stimuli are built in a manner that requires a stimulus.m file to be present. 


**fmri-Prepreprocessing**: This contains the bash and matlab scripts for using fmriprep to transfer DICOM files on an online XNAT server to a computer server, convert to bids format, and uses the fmriprep pipeline to preprocess the data. The batch scripts are parallelized to submit multiple preprocessing jobs to a computer cluster. Whole brain analyses are performed in SPM (matlab), and GLMs are performed to extract trial-level activation to be analyzed outside the traditional fMRI software packages (e.g., in R, python). Threshold free cluster enhancement was performed on group level contrastats and thresholded at p<.05, and 3d volumes were transformed to surface based maps for visualization (using connectome workbench) which requires the Conte Atlas.

The relevant scripts are detailed in the README.rtf, and are also listed below. 

*  TCB_xnat2bids.sh
*  TCB_bids-validator.sh
*  TCB_fmriprep_fieldmap_ica_parallel.sh
*  TCB_postfmriprep_dataforamt.sh


*  TCB_runLevel1.sh
*  TCB_makeSOTS.m
*  TCB_makeRegressor.m
*  TCB_runLevel1_fMRIModelSpec_Estimate.m
*  TCB_runLevel1_contrast.m
*  TCB_runLevel2.sh
*  TCB_wholebrain_TFCE.sh
*  check_tfce_map.py
*  run_tfce_thresholds.sh
*  threshold_tfce_p_and_tstat.py
*  map_tfce_to-fsLR32k.sh  



**ddm**: This contains the scripts for launching the ddms on a computer cluster. 

**analysis**: This contains the R scripts for data formatting (e.g., imputation, consondliation across different datasets), and the statistical anslyses and data visualization for the manuscript.

* 1_TCB-Manuscript-CleanSRMsandLikert-impute.Rmd 
* 2_TCB-Manuscript-FormatData.Rmd
* 3_TCB_Manuscript-Stats.Rmd

**archive**: This contains older fmri preprocessing scripts. 

The corresponding OSF repsitory is: https://osf.io/hjz6v/

Any further questions should be directed to Debbie Yee (debbie_yee@brown.edu).



