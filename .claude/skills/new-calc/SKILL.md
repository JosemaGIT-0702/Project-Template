---
name: new-calc
description: Scaffold a new reproducible calculation (Mathematica .wl or Python .py) in the numbered pipeline, wired to export results to the paper. Use when starting a new analytic or numerical computation.
argument-hint: "<short_name> [mathematica|python] [what it computes]"
---

# Scaffold a calculation

Arguments: `$ARGUMENTS`

1. Choose the language: analytic/symbolic -> Mathematica; numerics, fits, plots -> Python.
   If unclear, ask.
2. Pick the next free global number: list `calc/*/scripts/[0-9]*` and take max+1
   (two digits). Filename `NN_<short_name>.wl` or `.py`, snake_case.
3. Create the script from the matching template below, with a header stating: what it
   computes, assumptions/approximations, inputs (which earlier scripts / `data/raw`
   files), outputs (exact files and value keys).
4. Implement the calculation **with at least one built-in check** that aborts on failure
   (see `.claude/rules/physics.md`).
5. Run it (Mathematica via MCP `evaluate(file=...)`; Python via `uv run python <file>`),
   then `make values`.
6. If results belong in the paper, use them via `\val<Key>` / `\input{generated/eq_<name>}`
   and run `make paper`.
7. Append a line to `notes/log.md`.

## Mathematica template

```mathematica
(* ::Package:: *)
(* NN_name.wl -- <what it computes>
   Assumptions: ...
   Inputs: ...
   Outputs: results/analytic/<name>.json, results/NN_name.json *)

Get[FileNameJoin[{DirectoryName[$InputFileName], "..", "Project.wl"}]];
$Assumptions = s > 0;

result = ...;

(* checks *)
If[!TrueQ[Simplify[<check> == 0]], Print["CHECK FAILED: <what>"]; Exit[1]];

ExportAnalytic["<name>", result];
ExportValues["NN_name", <|"<Key>" -> <|"value" -> ..., "digits" -> 4, "unit" -> "pb"|>|>];
Print["NN_name: OK"];
```

## Python template

```python
"""NN_name -- <what it computes>

Assumptions: ...
Inputs: ...
Outputs: results/NN_name.json, paper/figures/<fig>.pdf
"""

from hepcalc import bridge, plotting
from hepcalc.constants import ALPHA_EM, GEV2_TO_PB
from hepcalc.results import export_values

# f = bridge.lambdify("<analytic name>", "s", "alpha")
...
assert ..., "check failed: <what>"

export_values("NN_name", {"<Key>": {"value": ..., "digits": 4, "unit": "pb"}})
print("NN_name: OK")
```
