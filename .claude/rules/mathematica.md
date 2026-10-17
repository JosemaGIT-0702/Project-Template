---
paths:
  - "calc/mathematica/**"
---

# Mathematica rules

- Use the official Wolfram MCP server (tools `WolframLanguageEvaluator`, `ReadNotebook`,
  `WriteNotebook`, `SymbolDefinition`, `CodeInspector`, `TestReport`), never the
  `wolframscript` CLI or hand-written `.nb` files.
  - Run a script: `WolframLanguageEvaluator` with `Get["<absolute path to script>.wl"]`,
    then `make values`.
  - The MCP kernel is persistent and parses symbols into a private `Sessions`...`` context, so
    scripts must not rely on `Global``: they isolate themselves with `ScriptBegin["ScriptNN"]` /
    `ScriptEnd[]` (see below). Never use `Global`x` in `Project.wl` or scripts.
  - Explore: evaluate code directly; prefer one compound expression over many round-trips.
  - Look up definitions with `SymbolDefinition` instead of guessing.
  - Notebooks for the user: `WriteNotebook`; read one back with `ReadNotebook`.
- Pipeline scripts are plain-text `.wl` files in `scripts/`, numbered `NN_name.wl`. They begin with
  `Get[FileNameJoin[{DirectoryName[$InputFileName], "..", "Project.wl"}]];` then
  `ScriptBegin["ScriptNN"];` (private, freshly wiped context; `$Assumptions` reset) and end with
  `ScriptEnd[];` after the final `Print["NN_name: OK"]`. `CheckFailed` calls `ScriptEnd[]` itself.
  The coordinates `r` and `x` are shared symbols exported by `Project.wl`; do not `ClearAll` them.
- Shared definitions (curvature helpers, ansätze, superpotentials, model parameters, package
  loading such as xAct or FeynCalc) go in `Project.wl`, not copied between scripts.
- Use the symbol names from `notes/conventions.md` (`r`, `u`, `L`, `eta`, ...) so
  `hepcalc.bridge` can parse exported expressions with sympy.
- Outputs only through `ExportAnalytic[name, expr]` and `ExportValues[name, <|...|>]`.
  Value keys are letters only (they become `\val<Key>` LaTeX macros) and must be unique project-wide.
- Every script asserts its own checks with `AssertZero` / `CheckFailed` from `Project.wl`
  (they `Exit[1]` under wolframscript and `Abort[]` in the MCP kernel; look for `CHECK FAILED`
  in the output).
- Geometry: use `RicciTensor`, `EinsteinTensor`, `ScalarLaplacian`, `DomainWallMetric` from
  `Project.wl` (conventions in its header) rather than re-deriving curvature by hand.
- Keep scripts fast (< 1 min): `Simplify` on explicit special-function profiles can run for
  minutes and blocks the MCP kernel. Prefer eliminating derivatives with first-order/BPS
  equations, `TimeConstrained`, or the numerical fallback built into `AssertZero`. If the
  kernel hangs, reconnect the server with `/mcp` in Claude Code.
- Set `$Assumptions` for symbols (positivity, reality) instead of sprinkling `Assuming`.
- Notebooks in `notebooks/` are exploratory scratch; once a result matters, move it into a script.
