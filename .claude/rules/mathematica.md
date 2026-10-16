---
paths:
  - "calc/mathematica/**"
---

# Mathematica rules

- Use the Mathematica MCP tools (`evaluate`, `verify_derivation`, `notebooks`), never the
  `wolframscript` CLI or hand-written `.nb` files.
  - Run a script: `evaluate(file="<absolute path to script>.wl")`, then `make values`.
  - Explore: `evaluate(code)`; prefer one compound expression over many round-trips.
  - Show plots/notebooks to the user: `evaluate(code, target="notebook")`.
- Pipeline scripts are plain-text `.wl` files in `scripts/`, numbered `NN_name.wl`, and
  begin with `Get[FileNameJoin[{DirectoryName[$InputFileName], "..", "Project.wl"}]]`.
- Shared definitions (Dirac algebra helpers, kinematics, model parameters, package
  loading such as FeynCalc) go in `Project.wl`, not copied between scripts.
- Use the symbol names from `notes/conventions.md` (`s`, `theta`, `alpha`, ...) so
  `hepcalc.bridge` can parse exported expressions with sympy.
- Outputs only through `ExportAnalytic[name, expr]` and `ExportValues[name, <|...|>]`.
  Value keys are letters only (they become `\val<Key>` LaTeX macros) and must be unique project-wide.
- Every script asserts its own checks and fails with `Exit[1]` on failure.
- Set `$Assumptions` for symbols (positivity, reality) instead of sprinkling `Assuming`.
- Notebooks in `notebooks/` are exploratory scratch; once a result matters, move it into a script.
