#!/bin/bash
# map_tfce_to_fslR32k.sh
set -euo pipefail

# ---- PATHS ----
CONTRAST_ROOT="/users/dyee7/data/mri-data/TCB/spm-data/groupstats/glm7_Pmod_RewPenTask_RTACC_interact_rwls"
OUTROOT="/users/dyee7/data/mri-data/TCB/surfmaps_fslr32k/glm7_Pmod_RewPenTask_RTACC_interact_rwls"

TPL_DIR="/users/dyee7/data/mri-data/TCB/atlases/Conte69_atlas-v2.LR.32k_fs_LR.wb/32k_ConteAtlas_v2"

# Midthickness surfaces
L_MID="${TPL_DIR}/Conte69.L.midthickness.32k_fs_LR.surf.gii"
R_MID="${TPL_DIR}/Conte69.R.midthickness.32k_fs_LR.surf.gii"

# ---- OPTIONS ----
SMOOTH_FWHM=2   # 0 to skip smoothing

# Target basenames (exact)
C1="T_tfce_tstat_fwep_c1_tstat_masked_p05.nii"
C2="T_tfce_tstat_fwep_c2_tstat_masked_p05.nii"

# ---- CHECKS ----
command -v wb_command >/dev/null 2>&1 || { echo "wb_command not found in PATH"; exit 1; }
[[ -f "$L_MID" && -f "$R_MID" ]] || { echo "Missing midthickness surfaces in $TPL_DIR"; exit 1; }

echo "Input root : $CONTRAST_ROOT"
echo "Output root: $OUTROOT"
echo "Atlas      : $TPL_DIR"
echo "Smoothing  : ${SMOOTH_FWHM}mm (0 = off)"
echo

# Helper: choose .nii or .nii.gz if present
pick_file() {
  local dir="$1" base="$2"
  if   [[ -f "$dir/$base"       ]]; then echo "$dir/$base"
  elif [[ -f "$dir/${base}.gz"  ]]; then echo "$dir/${base}.gz"
  else echo ""
  fi
}

# Find all tfce* directories
mapfile -t TFCE_DIRS < <(find "$CONTRAST_ROOT" -type d -name "tfce*")

total_dirs=${#TFCE_DIRS[@]}
mapped_files=0
both_present=0
dirs_with_missing=0
missing_total=0
declare -a SUMMARY_MISSING=()

if [[ $total_dirs -eq 0 ]]; then
  echo "[WARN] No tfce* directories found under $CONTRAST_ROOT"
fi

for tdir in "${TFCE_DIRS[@]:-}"; do
  relpath="${tdir#$CONTRAST_ROOT/}"
  outdir="$OUTROOT/$relpath"
  mkdir -p "$outdir"

  f_c1="$(pick_file "$tdir" "$C1")"
  f_c2="$(pick_file "$tdir" "$C2")"

  missing=()
  [[ -z "$f_c1" ]] && missing+=("$C1(.gz)")
  [[ -z "$f_c2" ]] && missing+=("$C2(.gz)")

  if [[ ${#missing[@]} -gt 0 ]]; then
    dirs_with_missing=$((dirs_with_missing+1))
    missing_total=$((missing_total+${#missing[@]}))
    miss_join=$(printf ", %s" "${missing[@]}"); miss_join="${miss_join:2}"
    SUMMARY_MISSING+=("$relpath  →  missing: $miss_join")
    printf "[WARN] Missing in %s:\n" "$relpath"
    for m in "${missing[@]}"; do echo "       - $m"; done
  else
    both_present=$((both_present+1))
  fi

  for fp in "$f_c1" "$f_c2"; do
    [[ -z "$fp" ]] && continue
    fname="$(basename "$fp")"
    stem="${fname%.nii.gz}"; stem="${stem%.nii}"

    echo "[MAP] $relpath/$fname → $outdir"
    wb_command -volume-to-surface-mapping "$fp" "$L_MID" "$outdir/${stem}_L.func.gii" -trilinear
    wb_command -volume-to-surface-mapping "$fp" "$R_MID" "$outdir/${stem}_R.func.gii" -trilinear
    mapped_files=$((mapped_files+2))

    if [[ "$SMOOTH_FWHM" -gt 0 ]]; then
      wb_command -metric-smoothing "$L_MID" "$outdir/${stem}_L.func.gii" "$SMOOTH_FWHM" "$outdir/${stem}_L.s${SMOOTH_FWHM}.func.gii"
      wb_command -metric-smoothing "$R_MID" "$outdir/${stem}_R.func.gii" "$SMOOTH_FWHM" "$outdir/${stem}_R.s${SMOOTH_FWHM}.func.gii"
    fi
  done
done

echo
echo "==================== Summary ===================="
echo "TFCE directories scanned     : $total_dirs"
echo "Surface files created (L+R)  : $mapped_files"
echo "Dirs with both c1 & c2 found : $both_present"
echo "Dirs with missing targets    : $dirs_with_missing"
echo "Total missing (c1/c2)        : $missing_total"
if [[ "${#SUMMARY_MISSING[@]}" -gt 0 ]]; then
  echo
  echo "Folders with missing targets:"
  for line in "${SUMMARY_MISSING[@]}"; do
    echo " - $line"
  done
fi
echo "================================================="
echo "TFCE → fsLR32k mapping complete ✅"