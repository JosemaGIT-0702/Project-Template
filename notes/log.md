# Research log

Newest entries on top. One entry per working session: what was done, what was
found, what is open. Agents append here via `/log`.

## 2026-10-17
- Done: replaced the community Mathematica MCP by the official Wolfram MCP server
  (`Wolfram/AgentTools` 2.2.0, server `Wolfram`, tools `mcp__Wolfram__*`), installed globally per
  user; no `.mcp.json` in the template (machine-specific paths), install snippet in README.
  Updated `CLAUDE.md`, `.claude/rules/mathematica.md`, skills (new-calc, verify, sync-results, ...),
  `.claude/settings.json`.
- Done: the MCP kernel parses symbols into a private `Sessions`...`` context, which broke
  `Project.wl` (`Global`r`) and leaked state between runs. `Project.wl` now exports `r`, `x` and
  provides `ScriptBegin`/`ScriptEnd` (private wiped context, state restored, also on `CheckFailed`);
  scripts 01 and 02 wrapped in them; new-calc template updated.
- Results (verified): scripts 01/02 pass under MCP, `wolfram -script` and `wolframscript`; outputs
  identical to the committed ones (timestamps and ~1e-11 noise in Python values only); a corrupted
  superpotential in a scratch copy is caught (`wolframscript` exit 1); `make calc` and `make test`
  (34 passed) OK. Committed as d8c9e18 and pushed to both remotes.
- Problems: under `wolfram -script` (not `wolframscript`) `$ScriptCommandLine` is empty, so a failed
  check exits 0 (pre-existing; CI and `make calc` unaffected). Script 02 prints a harmless
  `FindInstance::vlist` message under MCP only.
- Next: (1) `/init-project` when starting a real project; (2) example 5 of table 1 (see below).

## 2026-10-16 (later)
- Added `05_ghost_spectrum_ex2.py`: table 1, example 2, following the original notebook
  (Wormhole-Spectrum repo). M^2 L^2 = 8.147523, 57.262502, 137.373804 (table: 8.148, 57.26, 137.4).
  Checks: v-equation = eq. (C.4); notebook's closed-form solution solves it; regularity relation
  C2 = 8 i sqrt(4+lam)|lam| C1 reproduced numerically; no zero of C2/C1 for -4 < M^2 L^2 < 0.
- Next: example 5 (coupled Z_chi, Z_alpha; shooting + Wronskian matching) in a later session.

## 2026-10-16
- Template example: arXiv:2605.16168 (supergravity wormholes, pseudo-Hermitian duals).
  Scripts `01_wormhole_backgrounds.wl`, `02_ghost_fluctuations.wl`, `03_ghost_spectrum.py`,
  `04_mutual_information.py` reproduce the BPS flows + EOMs, the Z_eta equation of app. C,
  table 1 (example 1) and fig. 2 / the large-width fits. Delete with `/init-project`.
- Open: table 1 row for example 5 is still quoted from the original notebook.
