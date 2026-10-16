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
- Shared definitions (curvature helpers, ansätze, superpotentials, model parameters, package
  loading such as xAct or FeynCalc) go in `Project.wl`, not copied between scripts.
- Use the symbol names from `notes/conventions.md` (`r`, `u`, `L`, `eta`, ...) so
  `hepcalc.bridge` can parse exported expressions with sympy.
- Outputs only through `ExportAnalytic[name, expr]` and `ExportValues[name, <|...|>]`.
  Value keys are letters only (they become `\val<Key>` LaTeX macros) and must be unique project-wide.
- Every script asserts its own checks with `AssertZero` / `CheckFailed` from `Project.wl`
  (they `Exit[1]` under wolframscript and `Abort[]` in the MCP kernel).
- Geometry: use `RicciTensor`, `EinsteinTensor`, `ScalarLaplacian`, `DomainWallMetric` from
  `Project.wl` (conventions in its header) rather than re-deriving curvature by hand.
- Keep scripts fast (< 1 min): `Simplify` on explicit special-function profiles can run for
  minutes and blocks the MCP kernel. Prefer eliminating derivatives with first-order/BPS
  equations, `TimeConstrained`, or the numerical fallback built into `AssertZero`. If the
  kernel hangs, `kernel(action="restart")`.
- Set `$Assumptions` for symbols (positivity, reality) instead of sprinkling `Assuming`.
- Notebooks in `notebooks/` are exploratory scratch; once a result matters, move it into a script.
