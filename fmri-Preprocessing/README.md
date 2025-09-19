# Summary of fmri preprocessing scripts

## Preprocessing Scripts (using fMRIPrep, in bash):

	Step 1: TCB_xnat2bids_bidspostprocess.sh 
	sh script that pulls data from XNAT and converts to BIDS format)
	(Note: xnat2bids_checkfunctions.sh can be called to look at the available functions)

	Step 1a: TCB_bids-validator.sh 
	(bash script that validates that your data is in BIDS format)

	Step 2: TCB_fmriprep_fieldmap_ica_parallel.sh
	(bash script that runs fmriprep with field map correction and ica)
	
	Step 3: TCB_postfmriprep_dataformat.sh 
	(bash script that will move anatomical, functional images and confounds to spm folder and prepare data for first level analysis) 

## 1st Level Subject Analysis GLM in SPM

    Step 4: TCB_runLevel1.sh
	(bash script that will run several matlab scripts to make regressors, run the first level GLM)
	
	This script will run the following scripts (which need to be built beforehand):

	    TCB_makeSOTS.m 
        (matlab script that creates stimulus onset files (SOTS) for each of the relevant conditions & contrasts)

		TCB_makeRegressor.m
		(matlab script that creates intercept regressor for each subject\'92s SPM Design Matrix when SOTS are all concatenated) 

		TCB_runLevel1_fMRIModelSpec_Estimate.m
		(matlab script that sets up the GLM and calculates beta estimates for first level analyses

		TCB_runLevel1_contrast.m
        (matlab script that runs the contrasts for the first level GLM)


## 2nd Level Group Analysis GLM in SPM

    TCB_runLevel2_group.sh\
	(bash script that wll run matlab script to run Level 2 analyses)

## Extracting ROI Betas (e.g., from AllIntervals GLM10)

## Whole Brain Analysis: Threshold-Free Cluster Enhancement (TFCE)\

    TCB_wholebrain_TFCE.sh
	(bash script that will run the threshold-free cluster enhancement of the whole brain glms specific)
	Note: this requires installation of the TFCE package and the palm folder
	Permutation Analysis of Linear Models: https://web.mit.edu/fsl_v5.0.10/fsl/doc/wiki/PALM.html
	This also requires the GLM_info folder
	Output files in *tfce10000_wholeBrain* folder

	check_tfce_map.py
	(this script checks whether the TFCE maps onto positive or negative values)
	
	run_tfce_thresholds.sh\
	(bash script that thresholds to p<.05 for the TFCE images)

	This script calls the following scripts:

		threshold_tfce_p_and_tstat.py
		(python script that thresholds the p<.05 on the TFCE images)

## Other Miscellaneous code:

	TCB_pTFCE.sh\
	(bash script that runs probabilistic Threshold-free cluster enhancement: https://spisakt.github.io/pTFCE/)
	Note: did not use this for the final manuscript, but is available for reference

    Thie script calls the following script:

	    TCB_pTFCE.R\
		(R script that reads in the nifti, performs the pTFCE, and writes out a nifti file) 
	

## Mapping the 3d volumes to surface based template (Conte69 atlas fsl32k)

	map_tfce_to-fsLR32k.sh\
	(bash script that transforms volume to surface mapping using the connectome workbench)
	Connectome Workbench: https://www.humanconnectome.org/software/get-connectome-workbench
