#!/usr/bin/env python3
import sys
from nilearn import plotting, datasets, surface
import nibabel as nib
import matplotlib.pyplot as plt


# Load fsaverage surface
fsaverage = datasets.fetch_surf_fsaverage()

# Load t-map NIfTI file
tmap_path = "/users/dyee7/data/mri-data/TCB/spm-data/groupstats/glm7_Pmod_RewPenTask_RTACC_interact_rwls/C2_CuesxRew/tfce10000_wholeBrain/T_tfce_tstat_fwep_c1_tstat_masked_p05.nii"  # Path to your t-map NIfTI file

# Project tmap to surface (if needed)
texture = surface.vol_to_surf(tmap_path, fsaverage.pial_left)

# Plot
plotting.plot_surf_stat_map(
    fsaverage.infl_left, texture,
    hemi='left', colorbar=True,
    bg_map=fsaverage.sulc_left,
    threshold=2.0, cmap='cold_hot',
    title="Left Hemisphere t-map"
)
plotting.show()


