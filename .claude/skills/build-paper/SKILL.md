---
name: build-paper
description: Compile the LaTeX paper, diagnose and fix errors and warnings, and report TODOs. Use when the user asks to build/compile the paper or after editing .tex files.
---

# Build the paper

1. Run `make paper` (rebuilds `values.tex`, then latexmk). If it fails, read the first
   error in `paper/main.log` (lines starting `./file.tex:NN:` thanks to `-file-line-error`)
   and fix the source -- never edit `paper/generated/` or the JHEP style files.
2. Once it compiles, scan `paper/main.log` and report, grouped:
   - undefined references / citations (`grep -E "undefined" main.log`). For a missing
     citation, offer `/add-reference`; never invent a BibTeX entry;
   - multiply-defined labels;
   - overfull hboxes > 5pt (with file:line);
   - `\val...` macros that are undefined (means a result key was renamed/removed).
3. List remaining `\todo{}` / `\authnote{}{}` with file:line
   (`grep -n '\\todo\|\\authnote' paper/sections/*.tex`).
4. Report the page count and anything you changed. Do not change physics content to
   silence a warning without saying so.
