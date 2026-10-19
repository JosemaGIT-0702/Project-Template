"""Load analytic expressions exported by calc/mathematica (ExportAnalytic)."""

import json

import sympy as sp
from sympy.parsing.mathematica import parse_mathematica

from .paths import ANALYTIC


def load(name: str) -> sp.Expr:
	"""Return the sympy expression stored in results/analytic/<name>.json."""
	record = json.loads((ANALYTIC / f"{name}.json").read_text())
	return parse_mathematica(record["mathematica"])


def lambdify(name: str, *symbols: str, modules: str = "numpy"):
	"""Load an expression and turn it into a function of the given symbols.

	Example: f = lambdify("warp", "u"); use modules="mpmath" for high-precision work.
	"""
	expr = load(name)
	if modules == "numpy":
		# sympy's numpy printer writes csch, coth as differences of exponentials, which cancel
		# catastrophically near 0 (relative error ~1e-16/x); numpy's sinh, cosh do not
		expr = expr.replace(sp.csch, lambda x: 1 / sp.sinh(x)).replace(
			sp.coth, lambda x: sp.cosh(x) / sp.sinh(x)
		)
	return sp.lambdify([sp.Symbol(s) for s in symbols], expr, modules=modules)
