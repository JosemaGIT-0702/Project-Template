# Coding guidelines

Adapted from [andrej-karpathy-skills](https://github.com/forrestchang/andrej-karpathy-skills)
(MIT, © forrestchang), itself based on Andrej Karpathy's notes on LLM coding pitfalls.
Applies to code, LaTeX and notes alike. These rules favour caution over speed; for trivial
tasks, use judgment.

## 1. Think before coding
- State your assumptions. If a request has more than one reading, list them; don't pick one silently.
  If something is unclear, stop, say what is confusing, and ask.
- If a simpler approach exists (e.g. an existing `Project.wl`/`hepcalc` helper, or a
  function from `supergrav.wl`), say so. Push back when warranted.
- Physics assumptions (truncation, ansatz, gauge, regime) follow `physics.md`.

## 2. Simplicity first
- Write the minimum code that solves the problem. No features, options or abstractions that
  weren't asked for, and no wrappers for single-use code.
- No error handling for impossible scenarios. This does **not** cover physics checks:
  `AssertZero`/`CheckFailed`/`assert` cross-checks are required (CLAUDE.md rule 2), not
  speculative.
- If 200 lines could be 50, rewrite them. Ask: would an experienced colleague call this overcomplicated?

## 3. Surgical changes
- Touch only what the task needs. Don't "improve" adjacent code, comments, formatting or
  prose; don't refactor what isn't broken. In `.tex` files, don't reword sentences nobody
  asked about (keeps the one-sentence-per-line diffs clean).
- Match the existing style (tabs, naming, comment density), even if you'd do it differently.
- Remove imports, variables, macros or values that *your* change made unused. Mention
  pre-existing dead code; don't delete it unless asked.
- Never edit generated files to make something pass: fix the script and regenerate.
- The test: every changed line traces directly to the request.

## 4. Goal-driven execution
- Turn the task into a check you can run, and loop until it passes:
  - new analytic result -> an `AssertZero` against an independent check (EOM, constraint,
    limit, numerics) in the script, or `/verify`;
  - bug -> a failing check or `uv run pytest` test that reproduces it, then the fix;
  - refactor -> `make calc` outputs and `make test` unchanged before and after;
  - paper edit -> `make paper` builds without new warnings.
- For multi-step tasks, state a brief plan first:
  ```
  1. [step] -> verify: [check]
  2. [step] -> verify: [check]
  ```
- Report what was actually verified, and what was not.
