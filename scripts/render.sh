#!/usr/bin/env bash
# Render a part to STL.
#
#   scripts/render.sh tray            -> dist/vesa_tray-tray.stl
#   scripts/render.sh pads            -> dist/vesa_tray-pads.stl
#   scripts/render.sh tray vesa_pattern=75 speaker_w=120
#
# Extra args are passed through as OpenSCAD -D overrides (key=value).
# Requires OpenSCAD on PATH (or set OPENSCAD_BIN) and BOSL2 on OPENSCADPATH.
set -euo pipefail

PART="${1:-tray}"; shift || true
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OPENSCAD_BIN="${OPENSCAD_BIN:-openscad}"
OUT_DIR="${ROOT}/dist"
mkdir -p "$OUT_DIR"
OUT="${OUT_DIR}/vesa_tray-${PART}.stl"

args=("$OPENSCAD_BIN" -o "$OUT" --export-format=binstl -D "Part=\"${PART}\"")
for kv in "$@"; do
  args+=(-D "$kv")
done
args+=("${ROOT}/vesa_tray.scad")

echo "Rendering ${PART} -> ${OUT}"
"${args[@]}"
echo "Done: ${OUT}"
