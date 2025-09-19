#!/usr/bin/env python3
import sys
import numpy as np
import nibabel as nib
import math
import os

def main(filename):
    img = nib.load(filename)
    data = img.get_fdata()
    vals = data[np.isfinite(data)].ravel()

    vmin, vmax, vmean = float(vals.min()), float(vals.max()), float(vals.mean())
    print(f'File: {filename}')
    print(f'Min={vmin:.4f}, Max={vmax:.4f}, Mean={vmean:.4f}')
    print('Smallest 5:', np.sort(vals)[:5])
    print('Largest 5:', np.sort(vals)[-5:])

    guess = "Unknown"
    threshold_hint = None
    thr_value = None
    keep_higher = True  # by default

    # Guess type & set threshold
    if vmax <= 1.0001:  # in [0,1]
        if vmean > 0.5:
            guess = "Likely 1-p map (high = more significant)"
            thr_value = 0.95
            threshold_hint = "> 0.95 for p<0.05"
            keep_higher = True
        else:
            guess = "Likely p map (low = more significant)"
            thr_value = 0.05
            threshold_hint = "< 0.05 for p<0.05"
            keep_higher = False
    elif 1.5 < vmax < 20:  # maybe -log10(p)
        guess = "Likely -log10(p) map"
        thr_value = -math.log10(0.05)
        threshold_hint = f"> {thr_value:.3f} for p<0.05 (≈-log10(0.05))"
        keep_higher = True
    else:
        guess = "Map scaling unclear — no threshold applied"

    print("Guess:", guess)
    if threshold_hint:
        print("Suggested threshold:", threshold_hint)

    # Apply threshold if we know how
    if thr_value is not None:
        sig_mask = data >= thr_value if keep_higher else data <= thr_value
        sig_data = np.where(sig_mask, data, 0)

        base = os.path.basename(filename)
        stem, ext = os.path.splitext(base)
        if stem.endswith('.nii'):  # handle .nii.gz double ext
            stem = os.path.splitext(stem)[0]
        outname = stem + "_sig.nii"  # <-- now saving as uncompressed .nii
        outpath = os.path.join(os.path.dirname(filename), outname)

        nib.save(nib.Nifti1Image(sig_data, img.affine, img.header), outpath)
        print(f"Saved thresholded map to: {outpath}")
    else:
        print("No output saved — no threshold rule identified.")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python check_tfce_map.py <tfce_fwep_map.nii.gz>")
        sys.exit(1)
    main(sys.argv[1])



# python3 check_tfce_map.py ../../spm-data/groupstats/glm7_Pmod_RewPenTask_RTACC_interact_rwls/C2_CuesxRew/tfce10000_wholeBrain/T_tfce_tstat_fwep_c1.nii 
# File: ../../spm-data/groupstats/glm7_Pmod_RewPenTask_RTACC_interact_rwls/C2_CuesxRew/tfce10000_wholeBrain/T_tfce_tstat_fwep_c1.nii
# Min=0.0000, Max=4.0000, Mean=0.1852
# Smallest 5: [0. 0. 0. 0. 0.]
# Largest 5: [4. 4. 4. 4. 4.]
# Guess: Likely p map (threshold <0.05)