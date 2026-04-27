#!/bin/bash
# build.sh — Convert a Markdown paper to DOCX
#
# Usage:
#   bash templates/build.sh paper.md
#   bash templates/build.sh paper.md output.docx
#
# Configuration (via environment variables):
#   SCHOLARIUM_REFERENCE_DOC  Path to your school's .docx style template
#                             Default: reference/reference.docx (inside this repo)
#   SCHOLARIUM_CSL            Path to your CSL citation style file
#                             Default: reference/turabian-fullnote-bibliography.csl

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

REFERENCE_DOC="${SCHOLARIUM_REFERENCE_DOC:-$REPO_DIR/reference/reference.docx}"
CSL="${SCHOLARIUM_CSL:-$REPO_DIR/reference/turabian-fullnote-bibliography.csl}"
LUA_COVER="$SCRIPT_DIR/cover-page.lua"
LUA_BIB="$SCRIPT_DIR/bibliography-break.lua"

INPUT="${1:?Usage: build.sh <paper.md> [output.docx]}"
OUTPUT="${2:-${INPUT%.md}.docx}"

[[ "$INPUT"  != /* ]] && INPUT="$(pwd)/$INPUT"
[[ "$OUTPUT" != /* ]] && OUTPUT="$(pwd)/$OUTPUT"

if [[ ! -f "$REFERENCE_DOC" ]]; then
  echo "Error: reference doc not found at $REFERENCE_DOC"
  echo "Set SCHOLARIUM_REFERENCE_DOC or place your school's .docx at reference/reference.docx"
  exit 1
fi

if [[ ! -f "$CSL" ]]; then
  echo "Error: CSL file not found at $CSL"
  echo "Set SCHOLARIUM_CSL or place your CSL file at reference/turabian-fullnote-bibliography.csl"
  exit 1
fi

echo "Building: $INPUT"
echo "Output:   $OUTPUT"

pandoc "$INPUT" \
  --output "$OUTPUT" \
  --reference-doc "$REFERENCE_DOC" \
  --csl "$CSL" \
  --citeproc \
  --lua-filter "$LUA_COVER" \
  --lua-filter "$LUA_BIB" \
  --wrap=none

echo "Done: $OUTPUT"
