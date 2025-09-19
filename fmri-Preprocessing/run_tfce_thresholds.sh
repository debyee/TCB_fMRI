#!/usr/bin/env bash
# Usage: ./run_tfce_thresholds.sh /path/to/groupstats
set -euo pipefail
shopt -s nullglob

ROOT="${1:-}"
if [[ -z "$ROOT" ]]; then
  echo "Usage: $0 /path/to/groupstats"
  exit 1
fi

# normalize ROOT
if command -v realpath >/dev/null 2>&1; then
  ROOT="$(realpath "$ROOT")"
else
  ROOT="$(python3 - <<'PY'
import os,sys; print(os.path.realpath(sys.argv[1]))
PY
"$ROOT")"
fi

echo "Root: $ROOT"

pick_img () {  # picks .nii or .nii.gz for a given base (no extension)
  local base="$1"
  [[ -f "${base}.nii" ]] && { echo "${base}.nii"; return; }
  [[ -f "${base}.nii.gz" ]] && { echo "${base}.nii.gz"; return; }
  echo ""
}

for CONTRAST_DIR in "$ROOT"/C*/ ; do
  TFCE_DIR="${CONTRAST_DIR%/}/tfce10000_wholeBrain"
  [[ -d "$TFCE_DIR" ]] || { echo "⚠️  Skipping $(basename "$CONTRAST_DIR") (no tfce10000_wholeBrain)"; continue; }

  echo "📂 Processing: $TFCE_DIR"

  # Only the base p-maps: .../T_tfce_tstat_fwep_c#.nii[.gz]
  pmaps=( "$TFCE_DIR"/T_tfce_tstat_fwep_c[0-9].nii "$TFCE_DIR"/T_tfce_tstat_fwep_c[0-9].nii.gz \
          "$TFCE_DIR"/T_tfce_tstat_fwep_c[0-9][0-9].nii "$TFCE_DIR"/T_tfce_tstat_fwep_c[0-9][0-9].nii.gz )
  (( ${#pmaps[@]} )) || { echo "   (no base p-maps found)"; continue; }

  for PMAP in "${pmaps[@]}"; do
    BASENAME="$(basename "$PMAP")"
    # Strict regex: exactly T_tfce_tstat_fwep_c<digits>.<ext>
    if [[ "$BASENAME" =~ ^T_tfce_tstat_fwep_(c[0-9]+)\.nii(\.gz)?$ ]]; then
      CONTRAST="${BASH_REMATCH[1]}"       # e.g., c1, c2, c11
    else
      # skip derived files like *_pmap_thr_*, *_sigmask_*, *_tstat_masked_*
      echo "   ↪︎ Skipping non-base p-map: $BASENAME"
      continue
    fi

    TSTAT="$(pick_img "$TFCE_DIR/T_tfce_tstat_${CONTRAST}")"
    if [[ -z "$TSTAT" ]]; then
      echo "   ❗ Missing T-stat for ${CONTRAST} (looked for .nii/.nii.gz)"
      continue
    fi

    echo "→ Running: python3 threshold_tfce_p_and_tstat.py \"$TFCE_DIR\" \"$(basename "$PMAP")\" \"$(basename "$TSTAT")\""
    python3 threshold_tfce_p_and_tstat.py "$TFCE_DIR" "$(basename "$PMAP")" "$(basename "$TSTAT")"
  done
done

echo "✅ All done!"
