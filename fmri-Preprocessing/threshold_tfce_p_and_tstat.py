


#!/usr/bin/env python3
import sys, os, math
import numpy as np
import nibabel as nib

def detect_map_kind(vals):
    vmin, vmax, vmean = float(vals.min()), float(vals.max()), float(vals.mean())
    if vmax <= 1.0001:
        return "one_minus_p" if vmean > 0.5 else "p"
    elif 1.5 < vmax < 20:
        return "neglog10p"
    else:
        return "unknown"

def build_sig_mask(pdata, kind, alpha):
    if kind == "p":
        mask = np.isfinite(pdata) & (pdata <= alpha)
        hint = f"p-map: p <= {alpha}"
    elif kind == "one_minus_p":
        thr = 1.0 - alpha
        mask = np.isfinite(pdata) & (pdata >= thr)
        hint = f"1-p map: (1-p) >= {thr}"
    elif kind == "neglog10p":
        thr = -math.log10(alpha)
        mask = np.isfinite(pdata) & (pdata >= thr)
        hint = f"-log10(p) map: -log10(p) >= {thr:.3f}"
    else:
        raise ValueError("Could not determine p-map scaling.")
    return mask, hint

def main(directory, pmap_file, tstat_file, alpha=0.05):
    # Full paths
    pmap_path = os.path.join(directory, pmap_file)
    tstat_path = os.path.join(directory, tstat_file)

    p_img = nib.load(pmap_path)
    t_img = nib.load(tstat_path)
    p_data, t_data = p_img.get_fdata(), t_img.get_fdata()

    if p_data.shape != t_data.shape:
        raise ValueError(f"Shape mismatch: p-map {p_data.shape} vs t-stat {t_data.shape}")

    p_vals = p_data[np.isfinite(p_data)]
    kind = detect_map_kind(p_vals)

    mask, hint = build_sig_mask(p_data, kind, alpha)

    stem = os.path.splitext(os.path.splitext(pmap_file)[0])[0]  # handle .nii.gz
    alpha_str = str(alpha).replace("0.", "p")  # e.g. 0.05 -> "p05"

    mask_path = os.path.join(directory, f"{stem}_sigmask_{alpha_str}.nii")
    pthr_path = os.path.join(directory, f"{stem}_pmap_thr_{alpha_str}.nii")
    tmask_path = os.path.join(directory, f"{stem}_tstat_masked_{alpha_str}.nii")

    nib.save(nib.Nifti1Image(mask.astype(np.uint8), p_img.affine, p_img.header), mask_path)
    nib.save(nib.Nifti1Image(np.where(mask, p_data, 0), p_img.affine, p_img.header), pthr_path)
    nib.save(nib.Nifti1Image(np.where(mask, t_data, 0), t_img.affine, t_img.header), tmask_path)

    vmin, vmax, vmean = float(p_vals.min()), float(p_vals.max()), float(p_vals.mean())
    kind_label = {"p":"p", "one_minus_p":"1-p", "neglog10p":"-log10(p)"}.get(kind, "unknown")
    print(f"P-map stats: min={vmin:.4f}, max={vmax:.4f}, mean={vmean:.4f}")
    print(f"Detected p-map type: {kind_label}")
    print(f"Applied threshold rule: {hint}")
    print(f"Significant voxels: {int(mask.sum())} / {mask.size}")
    print("Saved:")
    print(f"  mask         -> {mask_path}")
    print(f"  p-map thr    -> {pthr_path}")
    print(f"  tstat masked -> {tmask_path}")

if __name__ == "__main__":
    if len(sys.argv) < 4 or len(sys.argv) > 5:
        print("Usage: python threshold_tfce_p_and_tstat.py <directory> <pmap_file> <tstat_file> [alpha]")
        sys.exit(1)

    directory = sys.argv[1]
    pmap_file = sys.argv[2]
    tstat_file = sys.argv[3]
    alpha = float(sys.argv[4]) if len(sys.argv) == 5 else 0.05
    main(directory, pmap_file, tstat_file, alpha)