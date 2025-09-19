# Script for Running pTFCE on oscar/ccv
# By Debbie Yee, Feb 1, 2023
# More detailed instructions for implementing pTFCE can be found here: https://github.com/spisakt/pTFCE/wiki/3.-R-package

# Loading Required Packages
if (!require("pacman")) install.packages("pacman")
pacman::p_load(
  oro.nifti,
  pTFCE,
  neurobase,
  naturalsort)

## -------- EDIT THESE VARIABLES --- 
# Root directories
root_path="/gpfs/data/ashenhav/mri-data/TCB/spm-data/groupstats/"

# Identify all of the the glms
glms = list.files(root_path, pattern="glm")

# FOR DEBUGGING ONE GLM: 
#glms = "glm7_Pmod_RewPenTask_RTACC_interact_rwls"

# Loop through glms and identify contrasts
for (glmid in glms) {
  
  # Print the current glm
  print(paste0("The current glm is: ", glmid))
  
  # Identify contrast for each glm
  contrasts = naturalsort(list.files(paste0(root_path,glmid)))
  
  for (conid in contrasts) { 
    
    # Print the current contrasts
    print(paste0("The current contrast is: ", conid))
    
    # Step 1: Load the NIFTI data of your Z-score map.
    # Note: because this is SPM, we need to Z-score the T-map.
    Tmap = readNIfTI(paste0(root_path,glmid,"/",conid,"/spmT_0001.nii"))
    Z = qnorm(pt(Tmap, df=98, log.p = T), log.p = T )
    
    # Step 2: Load in the brain mask
    MASK = readNIfTI(paste0(root_path,glmid,"/",conid,"/mask.nii"))
    
    # Step 3: run pTFCE on Z-scored map
    pTFCE = ptfce(Z,MASK)
    
    # Step 5:  Save the enhanced Z-scored map as nifti: 
    writeNIfTI(pTFCE$Z, paste0(root_path,glmid,"/",conid,"/pTFCE-z-score-map"), gzipped = FALSE)
    
    # Print the current contrasts
    print(paste0("pTFCE for ", conid," is completed."))
  
    } # end loop over contrasts
  
  # Print the current glm
  print(paste0("All contrasts for ", glmid," is completed."))
  
} # end loop over glms




# # Step 1: Load the NIFTI data of your Z-score map.
# # Note: because this is SPM, we need to Z-score the T-map.
# Tmap = readNIfTI("/gpfs/data/ashenhav/mri-data/TCB/spm-data/groupstats/glm6_Pmod_RewPenTask_RTACC_rwls/C1_Cues/spmT_0001.nii")
# Z = qnorm(pt(Tmap, df=98, log.p = T), log.p = T )
# 
# # Step 2: Load in the brain mask
# MASK = readNIfTI("/gpfs/data/ashenhav/mri-data/TCB/spm-data/groupstats/glm6_Pmod_RewPenTask_RTACC_rwls/C1_Cues/mask.nii")
# 
# # Step 3: run pTFCE on Z-scored map
# pTFCE = ptfce(Z,MASK)
# 
# # Step 4 (Optional): View results
# # original Tmap
# orthographic(Tmap, zlim=c(0, max(pTFCE$Z)), crosshair=F)
# # original Zmap
# orthographic(Z, zlim=c(0, max(pTFCE$Z)), crosshair=F)
# # pTFCE
# orthographic(pTFCE$Z, zlim=c(0, max(pTFCE$Z)), crosshair=F)
# # pTFCE 
# orthographic(pTFCE$Z, zlim=c(pTFCE$fwer0.05.Z, max(pTFCE$Z)), crosshair=F)
# 
# # Step 5:  Save the enhanced image as nifti: 
# writeNIfTI(pTFCE$Z, "/gpfs/data/ashenhav/mri-data/TCB/spm-data/groupstats/glm6_Pmod_RewPenTask_RTACC_rwls/C1_Cues/pTFCE-z-score-map")
