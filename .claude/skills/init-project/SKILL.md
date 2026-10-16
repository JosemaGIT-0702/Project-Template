---
name: init-project
description: Turn a fresh copy of the HEP project template into a real project - set title, authors, conventions, remove the example calculation, verify the build. Use right after creating a repo from the template.
disable-model-invocation: true
---

# Initialise a new project from the template

Interview the user briefly (one round of questions, using AskUserQuestion), then apply.

1. **Ask**: working title; authors + affiliations + emails; one-paragraph physics goal;
   conventions that differ from `notes/conventions.md` (metric, $\epsilon^{0123}$,
   covariant-derivative sign, $\gamma_5$ scheme, regularisation); extra tools needed
   (FeynCalc, FORM, Julia, MadGraph, ...); whether to keep the e+e- -> mu+mu- example.
2. **Paper**: set `\title`, `\author`, `\affiliation`, `\emailAdd` in `paper/main.tex`;
   put the goal as a draft paragraph in `sections/introduction.tex` with `\todo`s.
3. **Conventions**: update `notes/conventions.md`, and propagate to
   `calc/mathematica/Project.wl` (header comment, `$Metric`), `calc/python/hepcalc/constants.py`,
   `paper/macros.tex`, `paper/sections/appendix.tex`.
4. **Example**: unless kept, remove it completely:
   - delete `calc/mathematica/scripts/01_ee_mumu.wl`, `calc/python/scripts/02_ee_mumu_numerics.py`,
     `results/01_ee_mumu.json`, `results/02_ee_mumu_numerics.json`,
     `results/analytic/dsigma_dOmega.json`, `results/analytic/sigma_tot.json`,
     `paper/generated/eq_dsigma_dOmega.tex`, `paper/generated/eq_sigma_tot.tex`,
     `paper/figures/ee_mumu_dsigma.pdf` (keep the `.gitkeep` files);
   - replace `sections/setup.tex` and `sections/results.tex` with a skeleton: the
     `\section{}` + `\label{}` lines and one `\todo{}` line describing what goes there
     (derived from the physics goal);
   - remove the "Example citation" sentence from `sections/introduction.tex` and the
     `Weinberg:1967tq` entry from `references.bib` (unless the user wants to cite it);
   - in `README.md`, replace the paragraph starting "The included e⁺e⁻ → μ⁺μ⁻ example";
   - run `make values`: `values.tex` must then contain only its header comment, and
     `grep -rn "ee_mumu\|valSigma\|valAFB\|valSqrtS" paper calc` must find nothing.
5. **Extra tools**: follow `calc/other/README.md` for each (directory, runner entry in
   `tools/run-calcs.sh`, a rule file in `.claude/rules/`). For Mathematica packages
   (FeynCalc etc.), add the `Needs[...]` to `Project.wl` and check it loads via the MCP.
6. **Python**: rename the project in `pyproject.toml` (`name`, keep package `hepcalc`), `uv sync`.
7. **Verify**: `make calc-py`, `make test` and `make paper` all succeed (with no
   calculations yet, `make calc-py` just prints a note). Report what changed.
8. Replace the template entry in `notes/log.md` with the project's first entry, update
   the `README.md` title/description, and offer to make the initial commit.
