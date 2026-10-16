"""EXAMPLE numerics (delete once your project has real calculations).

Consumes the analytic dsigma/dOmega from 01_ee_mumu.wl, integrates it
numerically, cross-checks against the analytic sigma_tot, and makes a figure.

Outputs: results/02_ee_mumu_numerics.json, paper/figures/ee_mumu_dsigma.pdf
"""

import numpy as np
from hepcalc import bridge, plotting
from hepcalc.constants import ALPHA_EM, GEV2_TO_PB
from hepcalc.results import export_values
from scipy.integrate import quad

SQRT_S = 10.0  # GeV

dsigma = bridge.lambdify("dsigma_dOmega", "s", "theta", "alpha")
sigma_tot = bridge.lambdify("sigma_tot", "s", "alpha")
s = SQRT_S**2


def dsigma_dcos(c):
    return 2 * np.pi * dsigma(s, np.arccos(c), ALPHA_EM) * GEV2_TO_PB


numeric, _ = quad(dsigma_dcos, -1, 1)
analytic = sigma_tot(s, ALPHA_EM) * GEV2_TO_PB
rel_diff = abs(numeric / analytic - 1)
assert rel_diff < 1e-10, f"numeric vs analytic sigma_tot disagree: {rel_diff:.2e}"

forward = quad(dsigma_dcos, 0, 1)[0]
export_values("02_ee_mumu_numerics", {
    "SigmaTotNum": {"value": numeric, "digits": 4, "unit": "pb"},
    "SigmaRelDiff": {"value": rel_diff, "digits": 2},
    "AFB": {"value": round((2 * forward - numeric) / numeric, 12) + 0.0, "digits": 2},
})

plotting.use_paper_style()
fig, ax = plotting.figure()
c = np.linspace(-1, 1, 200)
ax.plot(c, dsigma_dcos(c), label=rf"$\sqrt{{s}} = {SQRT_S:g}$ GeV")
ax.set_xlabel(r"$\cos\theta$")
ax.set_ylabel(r"$\mathrm{d}\sigma/\mathrm{d}\cos\theta$ [pb]")
ax.set_xlim(-1, 1)
ax.set_ylim(bottom=0)
ax.legend(frameon=False)
plotting.save(fig, "ee_mumu_dsigma")

print(f"02_ee_mumu_numerics: OK  sigma = {numeric:.4f} pb (rel. diff {rel_diff:.1e})")
