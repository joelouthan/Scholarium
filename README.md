# Scholarium

Write seminary and academic papers in Markdown. Build to DOCX with one command.
Never open Microsoft Word.

```
semnew BI11 "The Covenant of Grace"   # creates a new paper from the template
sembuild BI11_Smith_The_Covenant.md   # exports to DOCX
```

## How it works

1. Write your paper in Markdown with inline `[@citekey, page]` citations
2. Maintain your bibliography in [Zotero](https://www.zotero.org/) with the [Better BibTeX](https://retorque.re/zotero-better-bibtex/) plugin — it auto-exports a `.bib` file
3. Run `sembuild` — [pandoc](https://pandoc.org/) + [citeproc](https://pandoc.org/MANUAL.html#citation-rendering) formats every footnote, generates the bibliography, and applies your school's Word styles

The result is a properly formatted `.docx` ready for submission — cover page, Turabian footnotes, bibliography, page breaks — all generated from plain text.

## Prerequisites

| Tool | Install |
|------|---------|
| [pandoc](https://pandoc.org/) v3+ | `brew install pandoc` |
| [poppler](https://poppler.freedesktop.org/) | `brew install poppler` |
| [Zotero](https://www.zotero.org/) | Download from zotero.org |
| [Better BibTeX for Zotero](https://retorque.re/zotero-better-bibtex/) | Install via Zotero plugins |

## Setup

### 1. Clone the repo

```bash
git clone git@github.com:joelouthan/Scholarium.git
cd scholarium
```

### 2. Add your reference files

Place two files in `reference/` (see [reference/README.md](reference/README.md)):

- `reference/reference.docx` — your school's Word style template
- `reference/turabian-fullnote-bibliography.csl` — Turabian CSL file

Or set environment variables to point to existing files:

```bash
export SCHOLARIUM_REFERENCE_DOC="/path/to/reference.docx"
export SCHOLARIUM_CSL="/path/to/turabian.csl"
```

### 3. Configure your shell

Add to your `~/.zshrc` (or `~/.bashrc`):

```bash
export SCHOLARIUM_ROOT="$HOME/Documents/Seminary"   # where your papers live
export SCHOLARIUM_AUTHOR="Your Full Name"
export SCHOLARIUM_SCHOOL="Your Seminary Name"
export SCHOLARIUM_EDITOR="code"                     # or "zed", "nvim", etc.

source /path/to/scholarium/shell/scholarium.zsh
```

Then reload: `source ~/.zshrc`

### 4. Add your class codes

Edit `shell/scholarium.zsh` and populate `SCHOLARIUM_CLASSES` with your school's course codes and professors:

```zsh
SCHOLARIUM_CLASSES[BI11]="BI11: Old Testament Introduction|Professor Name"
SCHOLARIUM_CLASSES[ST21]="ST21: Systematic Theology I|Professor Name"
```

### 5. Set up Zotero auto-export

In Zotero with Better BibTeX installed:

1. `File → Export Library`
2. Format: **Better BibTeX**
3. Check **Keep updated** and **Background export**
4. Save to `$SCHOLARIUM_ROOT/library.bib`

Better BibTeX will keep `library.bib` in sync automatically whenever you add or edit sources.

### 6. (Optional) VS Code snippets

Copy the contents of [`vscode/footnote-snippets.json`](vscode/footnote-snippets.json) into your VS Code Markdown snippets file:

`Cmd+Shift+P → Snippets: Configure User Snippets → markdown.json`

Also enable snippet suggestions for Markdown in your VS Code `settings.json`:

```json
"[markdown]": {
  "editor.quickSuggestions": {
    "other": "on"
  }
}
```

## Writing papers

### Create a new paper

```bash
semnew BI11 "The Covenant of Grace"
# Creates: $SCHOLARIUM_ROOT/BI11/BI11_Smith_The_Covenant_of_Grace.md
# Opens in your editor with YAML front matter pre-filled
```

### YAML front matter

```yaml
---
school: "Your Seminary"
title: "The Covenant of Grace"
author: "Your Name"
course: "BI11: Old Testament Introduction"
professor: "Professor Name"
date: "April 27, 2026"
bibliography: /path/to/library.bib
---
```

### Citations

Scholarium uses pandoc's citeproc with Turabian full-note bibliography style.
The CSL handles footnote formatting automatically — first cite is full, subsequent
cites use short-title form.

```markdown
Simple citation with page number.[@citekey, 66]

Multiple sources in one footnote.[@citekey1, 12; @citekey2, 45]

Citation with your own commentary.^[See @citekey, 88, for a fuller treatment.]
```

**Finding cite keys:** In Zotero with Better BibTeX, the cite key appears in the
Info panel for each item. The Zotero Citation Picker VS Code extension lets you
search your library and insert cite keys without leaving the editor.

### Bibliography section

End every paper with:

```markdown
# Bibliography {.unnumbered}
```

Leave it empty — citeproc fills in all cited entries automatically on build.

### Build to DOCX

```bash
sembuild BI11_Smith_The_Covenant_of_Grace.md
# Output: $SCHOLARIUM_ROOT/BI11/BI11_Smith_The_Covenant_of_Grace.docx
```

## Project structure

```
scholarium/
├── templates/
│   ├── cover-page.lua           # Generates cover page from YAML metadata
│   ├── bibliography-break.lua   # Inserts page break before Bibliography
│   ├── build.sh                 # pandoc build script
│   └── paper-template.md        # Starter template for new papers
├── shell/
│   └── scholarium.zsh           # Shell functions: semnew, sembuild
├── vscode/
│   └── footnote-snippets.json   # VS Code snippets for Turabian footnotes
├── reference/
│   └── README.md                # Instructions for reference.docx and CSL
└── .markdownlint.json           # Suppresses MD025 (multiple H1s)
```

## Cover page

The `cover-page.lua` filter generates a DOCX cover page from the YAML front
matter fields: `school`, `title`, `author`, `course`, `professor`, `date`.

Spacing values (in twips) can be adjusted in `cover-page.lua` to match your
school's layout requirements. See comments in the file.

## License

MIT
