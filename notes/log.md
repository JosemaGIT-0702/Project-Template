# Research log

Newest entries on top. One entry per working session: what was done, what was
found, what is open. Agents add entries here via `/log`.

## 2026-10-19 (LaTeX rules review of the example paper)
- Done: brought `paper/` in line with `.claude/rules/latex.md`: one sentence per line (scripted
  reflow, PDF text identical before/after); comments for every extra preamble package; raw markup
  replaced by macros (`\cN`, `\cC`, `\Real`, `\Imag`, `\SO`, `\U`, `\ISO`, `\SE`, `\KE`) and roman
  labels/operators (`\text{SYM}`, `\max`, `\cot`, `\text{D}`); hand-typed "Section/Figure \ref" ->
  `\cref`, `\eqref{tab:spectra}` bug fixed, `subsec:` labels -> `sec:`; display punctuation `\,.`/`\,,`
  (and missing/wrong ones); typos, incl. index slips in app. B (`\partial_{\eta^a}V`, `\chi^a`,
  a doubled `=0`). Also fixed a 20pt overfull box (app. A action) and `\begin{table}[]`.
- Done: Example 5 row of table 1 is no longer hand-typed. New `06_ghost_fluctuations_ex5.wl` derives
  the coupled invariant equations for n ghosts from the curvature of the perturbed metric (radial
  gauge, spin-0 rest-frame sector, H_S = 0); `07_ghost_spectrum_ex5.py` computes the spectrum
  (shooting + 4x4 Wronskian). Collocation sizes of `03` are exported (`\valNCollocation*`).
- Results: the n-ghost Q_ab is symmetric, reduces to the paper's Q_ZZ (B.34)-(B.36) for one ghost, and
  coincides term by term with the equations of the original notebook (example 5). At the throat
  Q ~ -2 e e^T/u^2 (e = (1, sqrt 3)/2): exponents {2, -1} along e, {0, 1} across. The notebook used
  per-field exponents (1+sqrt3)/2, (1+sqrt7)/2 (off-diagonal 1/u^2 coupling neglected). Odd sector
  (Z.n ~ u): 18.5638, 37.2209, 65.1191 (paper 18.62, 37.22, 65.04), independent of cutoffs (1e-8)
  and of the method (one-sided check, 1e-4). Table now shows these (user's choice). Even sector
  (Z.n ~ 1), excluded by the paper's conditions: 4.8205, 36.051, 40.097 (O(delta) throat error,
  converged to ~1e-4). No M^2 < 0 in either sector: stability conclusion unchanged.
- Done (follow-up): new project package `calc/mathematica/packages/wormholes.wl` (superpotentials,
  BPS profiles, warp factors, Minkowski a0 of examples 1, 2, 5), loaded by `01`, `02`, `06`; outputs
  of `01` byte-identical before/after. App. C now shows the example-5 equations from `06` (Q_ab in
  hyperbolic form, the throat matrix, the throat/boundary conditions used) and A_0, B_0, B_1 from `02`
  (partial fractions with p(s), q(s), so B_0 fits on a line; full forms still feed `03`). The analytic
  slopes `\valMISlopeAnalyticEx*` are quoted next to the fits in sec. 4. `02` and `06` cite this
  build's equation numbers; `02` check 3 is labelled as a comparison with the arXiv forms.
- Results: `03`, `04`, `07` reproduce their numbers with the new export forms (differences
  <= 1e-11 relative, printed digits unchanged).
- Bug fixed: `hepcalc.bridge.lambdify` (numpy) turned `Csch`, `Coth` into differences of exponentials,
  which cancel near 0 (relative error ~1e-16/x): with Q_ab in hyperbolic form `07` crawled for 30+ min
  integrating noise near the throat. Now rewritten as 1/sinh, cosh/sinh; regression test in
  `tests/test_hepcalc.py` (fails without the fix). `07` back to 1.5 min, same eigenvalues.
- Done: equation numbers in the comments of `01` and `04` now match this build ((2.6), (2.7), (4.25),
  (4.26), (4.30)); `03`, `05` were already right.
- Results: `FindInstance::vlist` in `02` came from `Solve[..., c]` with c > 0 in `$Assumptions`:
  Mathematica 15.0's assumption preprocessing in Solve calls `FindInstance[True, {}]` (reproduced
  with -32/41 + 3/c == 0 in a clean Module; gone with Assumptions -> True, same solution). Harmless;
  `02` now passes `Assumptions -> True` (equation linear in 1/c) and runs without messages.
- Verified (/verify of 06/07): example-5 equations identical to those of the authors' notebook (exact
  import, coefficients equal to 1e-77 incl. the M^2 term); Q even in u; Z gauge invariant; spectrum
  re-computed with Mathematica NDSolve (30 digits, other cutoffs): agrees with `07` to 2e-11.
- Open: the even sector is not mentioned in the paper; `\cite{code}` stays a non-INSPIRE `@misc`
  (accepted exception).
- Note: in this shell `grep` is ugrep, which skips `paper/main.log` as binary: use `/usr/bin/grep`.

## 2026-10-19
- Done: added `.claude/rules/coding.md` (always loaded), adapted from andrej-karpathy-skills (MIT,
  upstream commit 2c60614): think before coding, simplicity first, surgical changes, goal-driven
  execution, mapped to the repo (physics checks are required, not "speculative error handling";
  verification via `AssertZero`/pytest/`make calc`/`make paper`; no prose rewording in `.tex`;
  never edit generated files). Vendored instead of installing the plugin so coauthors get it and it
  can't change upstream. `CLAUDE.md` layout row and `README.md` mention it.
- Done: reviewed the template's structure for inconsistencies (example physics ignored).
  Fixed the docs (836e836): layout tables in `CLAUDE.md`/`README.md` (`tools/`, `.claude/`,
  `calc/python/notebooks/`, `hepcalc.paths`, `nbstrip.py`); `calc/other/` described as a README for
  sibling `calc/<tool>/` dirs; log entries go on top (`CLAUDE.md`, `/new-calc`, this header);
  `/sync-results` detects a failed `.wl` by `CHECK FAILED`/`$Aborted`, not `Exit[1]`; `make setup`
  row mentions the nbstrip filter; `physics.md` noted as always loaded; Python rule covers
  `tools/*.py`; `AssertZero` docs say 10 s (as the code); `wolfram -script` dropped from the docs
  (only the Wolfram MCP and `wolframscript` via `make calc` are used); `.claude/settings.json` layout.
- Done: fixed `tools/run-calcs.sh`: `make calc ONLY=03` matched nothing (pattern `03[0-9]*`); the
  filter is now a filename prefix (`-name "[0-9]*" -name "${ONLY}*"`).
- Results (verified with stubbed runners, nothing executed): `ONLY=03` selects only
  `03_ghost_spectrum.py`; no filter still runs all scripts in global order across languages; a
  filter matching nothing exits 1; an empty project exits 0. No outputs in `results/` changed.
- Open: rerun noise (timestamp in `ExportAnalytic` JSON, `CreationDate` in matplotlib PDFs); CI does
  not check committed outputs are current; deny rules miss `results/` and `paper/figures/`; Jupyter
  notebooks are not stripped; preamble packages without comments (`epsfig`, `bbm`, `verbatim`
  unused; `bbold` may override `\mathbb`); `mpmath` not declared in `pyproject.toml`.
- Next: (1) fix the rerun noise, then add a CI check that outputs are current; (2) extend the deny
  rules and decide on Jupyter output stripping; (3) clean up the `main.tex` preamble.

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
