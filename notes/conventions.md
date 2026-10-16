# Conventions

Single source of truth for notation and conventions. `calc/mathematica/Project.wl`,
`calc/python/hepcalc/constants.py` and `paper/macros.tex` must agree with this file.
Fill in / change at project start (`/init-project`), then treat as frozen; any later
change must be propagated to all three places and noted in `log.md`.

## Units and kinematics
- Natural units $\hbar = c = 1$; energies in GeV; cross sections reported in pb.
- Metric $g_{\mu\nu} = \mathrm{diag}(+1,-1,-1,-1)$.
- Mandelstam: $s=(p_1+p_2)^2$, $t=(p_1-k_1)^2$, $u=(p_1-k_2)^2$.

## Field theory
- $\epsilon^{0123} = +1$ *(state the sign; it differs between textbooks)*.
- Covariant derivative $D_\mu = \partial_\mu - i e Q A_\mu$ *(sign convention!)*.
- $e^2 = 4\pi\alpha$, $\alpha^{-1} = 137.035999$ (Thomson limit).
- Dirac matrices in the Dirac representation for explicit computations;
  $\gamma_5 = i\gamma^0\gamma^1\gamma^2\gamma^3$.
- Dimensional regularisation: $d = 4 - 2\epsilon$, $\MSbar$ scale $\mu$. *(if relevant)*

## Numerical inputs
- PDG 2024 values (cite `ParticleDataGroup:2024cfk`). Masses in `hepcalc/constants.py`.

## Symbol names across tools
| Physics | Mathematica | Python (sympy) | LaTeX |
|---|---|---|---|
| $s$ | `s` | `s` | `s` |
| $\theta$ (CM scattering angle) | `theta` | `theta` | `\theta` |
| $\alpha$ | `alpha` | `alpha` | `\alpha` |
