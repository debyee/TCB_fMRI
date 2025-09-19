#!/usr/bin/env bash
# Threshold all TFCE contrasts under a root directory by calling:
#   python3 threshold_tfce_p_and_tstat.py <pmap> <tstat> <alpha>
#
# Finds both *_fwep_* and *_corrp_* p-maps (nii / nii.gz), matches *_tstat_* by contrast.
#
# Usage:
#   ./run_tfce_thresholds.sh <ROOT_DIR> [--alpha 0.05] [--script /path/to/threshold_tfce_p_and_tstat.py] [--dry-run]
#
# Examples:
#   ./run_tfce_thresholds.sh /path/to/groupstats
#   ./run_tfce_thresholds.sh /path/to/groupstats --alpha 0.01
#   ./run_tfce_thresholds.sh /path/to/groupstats --script ~/bin/threshold_tfce_p_and_tstat.py --dry-run

set -euo pipefail
IFS=$'\n\t'

# --------- defaults ---------
ROOT_DIR=""
ALPHA="0.05"
TH_SCRIPT="threshold_tfce_p_and_tstat.py"
DRY_RUN="0"

# --------- args ---------
if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <ROOT_DIR> [--alpha 0.05] [--script /path/to/threshold_tfce_p_and_tstat.py] [--dry-run]" >&2
  exit 1
fi

ROOT_DIR="$1"; shift || true
while [[ $# -gt 0 ]]; do
  case "$1" in
    --alpha)   ALPHA="${2:-}"; shift 2 ;;
    --script)  TH_SCRIPT="${2:-}"; shift 2 ;;
    --dry-run) DRY_RUN="1"; shift ;;
    *) echo "Unknown arg: $1" >&2; exit 1 ;;
  endesac
done

if [[ ! -d "$ROOT_DIR" ]]; then
  echo "❌ Not a directory: $ROOT_DIR" >&2; exit 1
fi
if ! command -v python3 >/dev/null 2>&1; then
  echo "❌ python3 not found in PATH" >&2; exit 1
fi
# Allow script to be in PATH or a file path
if ! command -v "$TH_SCRIPT" >/dev/null 2>&1; then
  if [[ ! -f "$TH_SCRIPT" ]]; then
    echo "❌ threshold script not found: $TH_SCRIPT" >&2; exit 1
  fi
fi

echo "🔎 Root: $ROOT_DIR"
echo "α (alpha): $ALPHA"
echo "Python script: $TH_SCRIPT"
[[ "$DRY_RUN" == "1" ]] && echo "🔍 Dry-run mode (no outputs will be written)"

# --------- helpers ---------
get_contrast_token() {
  # return c<digits> from filename ending with _cX.nii(.gz)
  local fname="$1"
  if [[ "$fname" =~ _c([0-9]+)\.nii(\.gz)?$ ]]; then
    echo "c${BASH_REMATCH[1]}"
  else
    echo ""
  fi
}

prefer_existing_path() {
  # given a base without extension, choose .nii if present else .nii.gz else empty
  local base="$1"
  if [[ -f "${base}.nii" ]]; then
    echo "${base}.nii"
  elif [[ -f "${base}.nii.gz" ]]; then
    echo "${base}.nii.gz"
  else
    echo ""
  fi
}

find_matching_tstat() {
  # args: dir pmap_basename
  local dir="$1"; local pmapbase="$2"
  local cnum
  cnum="$(get_contrast_token "$pmapbase")"
  # First try canonical T_tfce_tstat_cX
  local cand
  cand="$(prefer_existing_path "${dir}/T_tfce_tstat_${cnum}")"
  [[ -n "$cand" ]] && { echo "$cand"; return 0; }

  # Derive from p-map by replacing fwep/corrp/uncp with tstat
  local derived="${pmapbase//_fwep_/_tstat_}"
  derived="${derived//_corrp_/_tstat_}"
  derived="${derived//_uncp_/_tstat_}"
  cand="$(prefer_existing_path "${dir}/${derived%.nii}")"
  [[ -n "$cand" ]] && { echo "$cand"; return 0; }
  [[ -f "${dir}/${derived}" ]] && { echo "${dir}/${derived}"; return 0; }
  [[ -f "${dir}/${derived/.nii/.nii.gz}" ]] && { echo "${dir}/${derived/.nii/.nii.gz}"; return 0; }

  # Fallback: any *_tstat_* with same contrast
  while IFS= read -r -d '' f; do
    if [[ "$(basename "$f")" =~ _c([0-9]+)\.nii(\.gz)?$ ]] && [[ "c${BASH_REMATCH[1]}" == "$cnum" ]]; then
      echo "$f"; return 0
    fi
  done < <(find "$dir" -maxdepth 1 -type f \( -name "*_tstat_*.nii" -o -name "*_tstat_*.nii.gz" \) -print0)

  echo ""  # not found
}

# --------- main loop ---------
# find both fwep & corrp corrected maps
find "$ROOT_DIR" -type f \( \
  -name "T_tfce_fwep_c*.nii"   -o -name "T_tfce_fwep_c*.nii.gz" \
  -o -name "T_tfce_corrp_c*.nii" -o -name "T_tfce_corrp_c*.nii.gz" \
\) -print0 | while IFS= read -r -d '' PMAP; do
  DIR="$(dirname "$PMAP")"
  BASE="$(basename "$PMAP")"
  CNUM="$(get_contrast_token "$BASE")"

  if [[ -z "$CNUM" ]]; then
    echo "⚠️  Skip (can’t parse contrast): $PMAP"
    continue
  fi

  TSTAT="$(find_matching_tstat "$DIR" "$BASE")"
  if [[ -z "$TSTAT" ]]; then
    echo "❗ No matching T-stat for $PMAP"
    continue
  fi

  echo "→ Contrast ${CNUM}"
  echo "   p-map : $PMAP"
  echo "   tstat : $TSTAT"

  if [[ "$DRY_RUN" == "1" ]]; then
    echo "   (dry-run) python3 $TH_SCRIPT \"$PMAP\" \"$TSTAT\" \"$ALPHA\""
  else
    python3 "$TH_SCRIPT" "$PMAP" "$TSTAT" "$ALPHA"
  fi
  echo
done

echo "✅ Done."
