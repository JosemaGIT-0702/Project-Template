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
4. **Example**: unless kept, delete `calc/mathematica/scripts/01_ee_mumu.wl`,
   `calc/python/scripts/02_ee_mumu_numerics.py`, their outputs in `results/`,
   `paper/generated/eq_*`, `paper/figures/ee_mumu_dsigma.pdf`, and the example text in
   `sections/setup.tex` / `sections/results.tex`. Rebuild `values.tex` with `make values`.
5. **Extra tools**: follow `calc/other/README.md` for each (directory, runner entry in
   `tools/run-calcs.sh`, a rule file in `.claude/rules/`). For Mathematica packages
   (FeynCalc etc.), add the `Needs[...]` to `Project.wl` and check it loads via the MCP.
6. **Python**: rename the project in `pyproject.toml` (`name`, keep package `hepcalc`), `uv sync`.
7. **Verify**: `make test` and `make paper` succeed. Report what changed.
8. Add the first entry to `notes/log.md`, update `README.md` title/description, and offer
   to make the initial commit.
