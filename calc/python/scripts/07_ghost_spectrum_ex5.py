"""EXAMPLE numerics (from arXiv:2605.16168; /init-project removes it).

Lowest normal-mode masses M^2 L^2 of the coupled ghost fluctuations Z^a on the example-5 (GPPZ)
wormhole, app. C: table 1, row "Example 5". With L = 1 and u = r/L,

    Z'' + 4 A' Z' + (M^2 e^{-2A} + Q(u)) Z = 0,      Z = (Z^1, Z^2),

with Q_ab from 06_ghost_fluctuations_ex5.wl and e^{2A} = warp_ex5 from 01. Q is even in u.

Boundary u -> -oo: Q -> 3, Z ~ e^u (source) or e^{3u} (vev, normalisable).
Throat u = 0: Q ~ -2 e e^T / u^2 with e = (1, sqrt 3)/2 the direction of eta0', so along e
Z ~ u^2 or 1/u (singular), and along n = (sqrt 3, -1)/2, Z ~ 1 or u. As in examples 1 and 2 the
problem splits at the singular throat; on the half line u < 0 a normal mode is normalisable at the
boundary, has no 1/u term and, by the u -> -u symmetry, is even (Z.n ~ 1) or odd (Z.n ~ u).
Table 1 lists the odd sector, which is what the throat conditions of the original notebook
(github.com/JosemaGIT-0702/Wormhole-Spectrum, example 5) select approximately: they take
per-field exponents (1 + sqrt 3)/2 and (1 + sqrt 7)/2 that neglect the off-diagonal 1/u^2
coupling, hence the 0.3% differences with its 18.6245, 37.2224, 65.0409.

Method: shooting, two solutions from each end matched at u_m, zeros of the 4x4 Wronskian.
Checks: independence of the cutoffs (boundary cutoff, matching point); an independent
one-sided method (integrate the boundary solutions to the throat and impose the throat
conditions there); no negative M^2 in either sector (stability); agreement with the
notebook values at the 0.5% level.

Outputs: results/07_ghost_spectrum_ex5.json
"""

import numpy as np
import sympy as sp
from hepcalc import bridge
from hepcalc.results import export_values
from scipy.integrate import solve_ivp
from scipy.optimize import brentq

N_MODES = 3
NOTEBOOK_VALUES = [18.6245, 37.2224, 65.0409]  # original notebook, example 5 (shooting)
M2_SCAN = np.arange(1.0, 80.0, 1.0)  # where to look for zeros of the Wronskian
M2_NEGATIVE = np.arange(-20.0, 0.0, 1.0)  # an instability would show up here
U_BOUNDARY, U_MATCH, DELTA = 15.0, -0.5, 1e-5  # boundary cutoff, matching point, throat cutoff

q11, q12, q22, warp = (
	bridge.lambdify(name, "u")
	for name in ("ghost_ex5_Q11", "ghost_ex5_Q12", "ghost_ex5_Q22", "warp_ex5")
)
u = sp.Symbol("u")
dA = sp.lambdify(u, sp.diff(sp.log(bridge.load("warp_ex5")) / 2, u))
E_PAR = np.array([1, np.sqrt(3)]) / 2
E_PERP = np.array([np.sqrt(3), -1]) / 2


def rhs(x, y, m2):
	z, dz = y[:2], y[2:]
	q = np.array([[q11(x), q12(x)], [q12(x), q22(x)]])
	return np.concatenate([dz, -4 * dA(x) * dz - (m2 / warp(x) * np.eye(2) + q) @ z])


def evolve(x0, x1, y0, m2):
	return solve_ivp(rhs, (x0, x1), y0, args=(m2,), method="DOP853", rtol=1e-12, atol=1e-14).y[
		:, -1
	]


def boundary_solutions(m2, x1, u_boundary=U_BOUNDARY):
	"""The two normalisable solutions Z ~ e^{3u} c (overall e^{3u} dropped), evolved to x1."""
	return [evolve(-u_boundary, x1, np.concatenate([c, 3 * c]), m2) for c in np.eye(2)]


def throat_solutions(m2, sector, x1, delta=DELTA):
	"""u^2 along E_PAR and 1 (even) or u (odd) along E_PERP at u = -delta, evolved to x1."""
	par = np.concatenate([delta**2 * E_PAR, -2 * delta * E_PAR])
	perp = (
		np.concatenate([E_PERP, 0 * E_PERP])
		if sector == "even"
		else np.concatenate([-delta * E_PERP, E_PERP])
	)
	return [evolve(-delta, x1, y, m2) for y in (par, perp)]


def wronskian(m2, sector="odd", u_boundary=U_BOUNDARY, u_match=U_MATCH):
	cols = boundary_solutions(m2, u_match, u_boundary) + throat_solutions(m2, sector, u_match)
	return np.linalg.det(np.array([c / np.linalg.norm(c) for c in cols]).T)


def throat_conditions(m2, sector="odd", delta=1e-4):
	"""One-sided method: 1/u coefficient along E_PAR and the forbidden E_PERP mode at u = -delta."""
	rows = []
	for y in boundary_solutions(m2, -delta):
		z, dz = y[:2], y[2:]
		x = -delta
		singular = x * (2 * z @ E_PAR - x * dz @ E_PAR) / 3  # Z.e = a u^2 + b/u  ->  b
		forbidden = (
			dz @ E_PERP if sector == "even" else z @ E_PERP - x * dz @ E_PERP
		)  # u or 1 coefficient
		rows.append([singular, forbidden])
	rows = np.array(rows)
	return np.linalg.det(rows / np.linalg.norm(rows, axis=1, keepdims=True))


def roots(f, grid, **kw):
	vals = np.array([f(x, **kw) for x in grid])
	brackets = np.nonzero(np.sign(vals[:-1]) != np.sign(vals[1:]))[0]
	return np.array(
		[brentq(lambda x: f(x, **kw), grid[i], grid[i + 1], xtol=1e-11) for i in brackets]
	)


spectrum = roots(wronskian, M2_SCAN)[:N_MODES]
assert len(spectrum) == N_MODES, f"found {spectrum}"

# cutoffs: boundary cutoff and matching point
for kw in ({"u_boundary": 20.0}, {"u_match": -1.5}):
	other = [
		brentq(lambda x, kw=kw: wronskian(x, **kw), m - 0.2, m + 0.2, xtol=1e-11) for m in spectrum
	]
	assert np.allclose(other, spectrum, rtol=1e-8), f"depends on {kw}: {other}"

# independent one-sided method
one_sided = np.array([brentq(throat_conditions, m - 0.2, m + 0.2, xtol=1e-11) for m in spectrum])
assert np.allclose(one_sided, spectrum, rtol=1e-4), f"one-sided method disagrees: {one_sided}"

# stability: no zero of the Wronskian at M^2 < 0, in either sector
for sector in ("odd", "even"):
	assert len(roots(wronskian, M2_NEGATIVE, sector=sector)) == 0, (
		f"negative M^2 in the {sector} sector"
	)

assert np.allclose(spectrum, NOTEBOOK_VALUES, rtol=5e-3), (
	f"far from the notebook values: {spectrum}"
)

export_values(
	"07_ghost_spectrum_ex5",
	{
		f"MSqExFive{label}": {"value": m2, "digits": 5}
		for label, m2 in zip(("First", "Second", "Third"), spectrum)
	},
)

print(f"07_ghost_spectrum_ex5: OK  M^2 L^2 = {np.array2string(spectrum, precision=6)}")
