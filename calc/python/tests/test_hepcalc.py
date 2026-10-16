import json

import pytest
import sympy as sp
from hepcalc import bridge, results
from hepcalc.paths import ANALYTIC


def test_value_formatting():
    assert results._fmt({"value": 868.5447, "digits": 4, "unit": "pb"}) == r"868.5\,\mathrm{pb}"
    assert results._fmt({"value": 1.2e-12, "digits": 2}) == r"1.2\times 10^{-12}"


@pytest.mark.skipif(not (ANALYTIC / "sigma_tot.json").exists(), reason="run `make calc` first")
def test_bridge_roundtrip():
    """The exported sigma_tot must equal 4 pi alpha^2 / (3 s)."""
    s, alpha = sp.symbols("s alpha")
    assert sp.simplify(bridge.load("sigma_tot") - 4 * sp.pi * alpha**2 / (3 * s)) == 0


def test_tex_and_mathematica_forms_present():
    for path in ANALYTIC.glob("*.json"):
        record = json.loads(path.read_text())
        assert record["mathematica"] and record["tex"], path.name
