---
paths:
  - "paper/**/*.tex"
  - "paper/**/*.bib"
---

# LaTeX rules (JHEP)

- One sentence per line in `.tex` files (clean git diffs).
- Notation only via `macros.tex`; add a macro rather than repeating raw markup.
- Numbers from calculations: `\val<Key>` only. Never type a computed number.
- Generated equations: `\input{generated/eq_<name>}` inside the math environment.
- Cross-references with `\cref{}`; labels prefixed `sec:`, `eq:`, `fig:`, `tab:`, `app:`.
- Every displayed equation that is referenced gets a `\label`; end displayed equations
  with punctuation (`\,.` / `\,,`) as part of the sentence.
- Citations: INSPIRE texkeys only (`Author:YYYYxx`). Never invent a key; use `/add-reference`.
- `\todo{}` and `\authnote{}{}` are fine in drafts; `/build-paper` lists them.
- Do not edit `jheppub.sty`, `JHEP.bst`, or anything in `paper/generated/`.
- After edits, build with `make paper` and fix new warnings (undefined refs/citations,
  overfull boxes > 5pt).
- HEP style: `\cref` gives "eq. (2.1)", "fig. 1"; use `\Cref` at the start of a sentence; units with
  `\GeV`, `\pb`; italic for variables, roman for labels (`m_\text{H}`, `\mathrm{d}`).
