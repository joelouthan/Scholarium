# reference/

Place two files here (both are gitignored — you supply them yourself):

## `reference.docx`

A Word document from your school that carries all the required styles: fonts,
heading levels, footnote formatting, margins, etc. pandoc uses this as
`--reference-doc` to inherit those styles into every paper you build.

Ask your school for a sample paper or style template in `.docx` format. Any
well-formatted `.docx` with the right styles will work.

Override the path with:
```bash
export SCHOLARIUM_REFERENCE_DOC="/path/to/your/reference.docx"
```

## `turabian-fullnote-bibliography.csl`

A CSL (Citation Style Language) file that tells pandoc/citeproc how to format
footnotes and bibliography entries. Scholarium is built around Turabian
full-note bibliography style.

Download the standard file from the CSL repository:
https://github.com/citation-style-language/styles/blob/master/chicago-fullnote-bibliography.csl

Your school may provide a customized version — use that if available.

Override the path with:
```bash
export SCHOLARIUM_CSL="/path/to/your/style.csl"
```
