---
name: init-project
description: Turn a fresh copy of the HEP project template into a real project - set title, authors, conventions, remove the example paper, verify the build. Use right after creating a repo from the template.
disable-model-invocation: true
---

# Initialise a new project from the template

Interview the user briefly (one round of questions, using AskUserQuestion), then apply.

1. **Ask**: working title; authors + affiliations + emails; one-paragraph physics goal;
   conventions that differ from `notes/conventions.md` (signature, curvature sign,
   action normalisation / $\kappa$ vs. $G$, form and spinor conventions, units such as
   $\ell_s$, $\alpha'$, $L$); extra tools needed (xAct, FeynCalc, FORM, Julia, ...);
   whether to keep the example paper (arXiv:2605.16168) for reference.
2. **Paper**: set `\title`, `\author`, `\affiliation`, `\emailAdd`, `\abstract` and
   `\acknowledgments` in `paper/main.tex`; remove the "EXAMPLE paper" comment.
3. **Example**: unless kept, remove it completely:
   - delete `calc/mathematica/scripts/01_wormhole_backgrounds.wl`,
     `calc/mathematica/scripts/02_ghost_fluctuations.wl`,
     `calc/python/scripts/03_ghost_spectrum.py`, `calc/python/scripts/04_mutual_information.py`,
     `calc/python/scripts/05_ghost_spectrum_ex2.py`;
   - delete every file in `results/` and `results/analytic/`, every `paper/generated/eq_*.tex`,
     `paper/figures/mutual_information.pdf`, `paper/images/tachyoncondensation.png`
     (keep the `.gitkeep` files);
   - delete all of `paper/sections/*.tex` and create `introduction.tex`, `setup.tex`,
     `results.tex`, `conclusions.tex` and `appendix.tex`, each with only its `\section{}` +
     `\label{}` and one `\todo{}` derived from the physics goal; update the `\input`s in
     `main.tex` to match;
   - reset `paper/references.bib` to its 3-line header comment;
   - keep the preamble of `main.tex` (packages, `\crefalias`) as is; in `paper/macros.tex` keep the
     abbreviation, general and editing blocks and drop the macros marked "example paper";
   - in `README.md`, replace the paragraph about the example (search for "2605.16168");
   - in `CLAUDE.md`, delete the "## The example" section;
   - run `make values`: `values.tex` must then contain only its header comment, and
     `grep -rln "2605.16168\|wormhole\|ghost\|eq_warp\|valMI\|valMSq" paper calc notes CLAUDE.md README.md`
     must find nothing.
4. **Conventions**: rewrite `notes/conventions.md` with the project's conventions (keep its
   headings), and propagate to `calc/mathematica/Project.wl` (header comment; adapt the
   geometry helpers if the signature or curvature sign changes), `calc/python/hepcalc/constants.py`
   and `paper/macros.tex`. Put a short conventions paragraph in `sections/appendix.tex`.
5. **Extra tools**: follow `calc/other/README.md` for each (directory, runner entry in
   `tools/run-calcs.sh`, a rule file in `.claude/rules/`). For Mathematica packages
   (xAct, FeynCalc, ...), add the `Needs[...]` to `Project.wl` and check it loads via the MCP.
6. **Python**: rename the project in `pyproject.toml` (`name`, keep package `hepcalc`), `uv sync`.
7. **Verify**: `make calc-py`, `make test` and `make paper` all succeed (with no
   calculations yet, `make calc-py` just prints a note). Report what changed.
8. Replace the template entry in `notes/log.md` with the project's first entry, update
   the `README.md` title/description, and offer to make the initial commit.
