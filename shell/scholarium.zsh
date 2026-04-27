# scholarium.zsh — Shell functions for Markdown → DOCX academic paper workflow
#
# Source this from your ~/.zshrc:
#   source ~/path/to/scholarium/shell/scholarium.zsh
#
# Required configuration (set these before sourcing, or export in ~/.zshrc):
#   export SCHOLARIUM_ROOT="$HOME/Documents/Seminary"
#   export SCHOLARIUM_AUTHOR="Your Full Name"
#   export SCHOLARIUM_SCHOOL="Your Seminary Name"
#
# Optional:
#   export SCHOLARIUM_EDITOR="code"   # default: code (VS Code)

# ── Defaults ──────────────────────────────────────────────────────────────────
: "${SCHOLARIUM_ROOT:=$HOME/Documents/Seminary}"
: "${SCHOLARIUM_AUTHOR:=Your Name}"
: "${SCHOLARIUM_SCHOOL:=Your Seminary}"
: "${SCHOLARIUM_EDITOR:=code}"

# ── Class lookup table ────────────────────────────────────────────────────────
# Format: SCHOLARIUM_CLASSES[CODE]="CODE: Class Name|Professor Name"
# Replace with your school's class codes and professors.
typeset -A SCHOLARIUM_CLASSES
SCHOLARIUM_CLASSES[BI11]="BI11: Old Testament Introduction|Professor Name"
SCHOLARIUM_CLASSES[BI13]="BI13: New Testament Introduction|Professor Name"
SCHOLARIUM_CLASSES[ST21]="ST21: Systematic Theology I|Professor Name"
SCHOLARIUM_CLASSES[HT11]="HT11: Historical Theology I|Professor Name"
# Add more as needed...

# ── semnew ────────────────────────────────────────────────────────────────────
# Creates a new paper from the template with YAML front matter pre-filled.
# Usage: semnew CLASSCODE "Paper Title"
# Example: semnew BI11 "The Covenant of Grace"
function seminary-new() {
  local classcode="${1:?Usage: semnew CLASSCODE 'Paper Title'}"
  local title="${2:?Usage: semnew CLASSCODE 'Paper Title'}"

  # Build filename: strip colons, replace spaces with underscores
  local slug="${title//:/}"
  slug="${slug// /_}"
  local lastname="${SCHOLARIUM_AUTHOR##* }"
  local dest="$SCHOLARIUM_ROOT/$classcode/${classcode}_${lastname}_${slug}.md"

  # Look up class name and professor
  local classinfo="${SCHOLARIUM_CLASSES[$classcode]}"
  local classname professor
  if [[ -n "$classinfo" ]]; then
    classname="${classinfo%%|*}"
    professor="${classinfo##*|}"
  else
    classname="$classcode: Unknown Class"
    professor="Unknown"
    echo "Warning: '$classcode' not found in SCHOLARIUM_CLASSES. Edit YAML manually."
  fi

  local today
  today=$(date "+%B %d, %Y")

  mkdir -p "$SCHOLARIUM_ROOT/$classcode"

  {
    printf -- '---\n'
    printf 'school: "%s"\n'     "$SCHOLARIUM_SCHOOL"
    printf 'title: "%s"\n'      "$title"
    printf 'author: "%s"\n'     "$SCHOLARIUM_AUTHOR"
    printf 'course: "%s"\n'     "$classname"
    printf 'professor: "%s"\n'  "$professor"
    printf 'date: "%s"\n'       "$today"
    printf 'bibliography: %s/library.bib\n' "$SCHOLARIUM_ROOT"
    printf -- '---\n'
    # Append template body (everything after the closing --- of the template)
    awk '/^---$/{n++; if(n==2){found=1; next}} found{print}' \
      "$SCHOLARIUM_ROOT/templates/paper-template.md"
  } > "$dest"

  echo "Created: $dest"
  "$SCHOLARIUM_EDITOR" "$dest"
}

# ── sembuild ──────────────────────────────────────────────────────────────────
# Builds a Markdown paper to DOCX. Output goes to the same folder as the input.
# Usage: sembuild paper.md
function seminary-build() {
  local input="${1:?Usage: sembuild <paper.md>}"
  [[ "$input" != /* ]] && input="$(pwd)/$input"
  local classcode
  classcode=$(basename "$input" | cut -d_ -f1)
  local output="$SCHOLARIUM_ROOT/$classcode/$(basename "${input%.md}").docx"
  bash "$SCHOLARIUM_ROOT/templates/build.sh" "$input" "$output"
}

alias semnew='seminary-new'
alias sembuild='seminary-build'
