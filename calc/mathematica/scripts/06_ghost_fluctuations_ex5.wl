(* ::Package:: *)
(* 06_ghost_fluctuations_ex5.wl -- EXAMPLE calculation (from arXiv:2605.16168; /init-project removes it).

   Gauge-invariant ghost fluctuations Z^a on the example-5 (GPPZ) wormhole, d = 4, two ghosts, app. C.
   The paper gives the invariant equation only for one ghost, eqs. (B.49)-(B.52); here it is derived for
   n ghosts from the curvature of the perturbed metric (packages/supergrav.wl). The example-5 background
   comes from packages/wormholes.wl.

   Assumptions: ghost scalars only, R_MN = -1/2 d_M eta^a d_N eta^a + G_MN V/(d-1), box eta^a + d_a V = 0.
   Radial gauge, spin-0 sector in the rest frame k = (w, 0) (M^2 = w^2), where by rotational symmetry
       h_tt = -e^{2A} F e^{-i w t},  h_ij = e^{2A} psi e^{-i w t} delta_ij,  delta eta^a = chi^a e^{-i w t}
   (H_S = 0: the traceless h_ij, which contain H_S, belong to the massive spin-2 multiplet).
   Invariants under the remnant diffeomorphism xi^r: Z^a = chi^a - eta0^a' psi/(2 A'), eq. (B.38).
   Result:  Z^a'' + d A' Z^a' + e^{-2A} M^2 Z^a + Q_ab Z^b = 0.
   Checks:
     - the background equations reduce to 0 with the substitution rules used below;
     - the linearised equations close on Z^a (the elimination has a solution) and Q_ab is symmetric;
     - for one ghost, Q_ab is Q_ZZ of eqs. (B.50)-(B.52);
     - the closed-form example-5 flow solves the BPS equations and matches warp_ex5 of 01;
     - near the boundary Q_ab -> V_ab = diag(3, 3)/L^2, i.e. m^2 L^2 = -3, Delta = 3 (and 1);
     - at the throat Q_ab ~ -2 e_a e_b/u^2, with e the unit vector along eta0' there.
   Outputs: results/analytic/ghost_ex5_Q{11,12,22}.json  Q_ab in units of 1/L^2, as functions of u = r/L
            (consumed by 07_ghost_spectrum_ex5.py, with warp_ex5 of 01, and app. C of the paper)
            results/analytic/ghost_ex5_throat{11,12,22}.json  lim u^2 Q_ab at the throat (app. C)
*)

Get[FileNameJoin[{DirectoryName[$InputFileName], "..", "Project.wl"}]];

ScriptBegin["Script06"];
LoadPackage["wormholes"];
$Assumptions = Element[u, Reals] && w > 0;

d = 4;
ph = E^(-I w t);
coords = {r, t, x1, x2, x3};
perturbedMetric = DiagonalMatrix[{1, -E^(2 A[r]) (1 + ep F[r] ph),
	E^(2 A[r]) (1 + ep psi[r] ph), E^(2 A[r]) (1 + ep psi[r] ph), E^(2 A[r]) (1 + ep psi[r] ph)}];
LoadGeometry[coords, perturbedMetric];

(* ---------- invariant equations for n ghosts ---------- *)

(* derivatives of the potential at the background, Vd[a] = d_a V, Vdd[a, b] = d_a d_b V *)
vdd[a_, b_] := Vdd[Min[a, b], Max[a, b]];
vSymbol[o_List] := Switch[Total[o],
	1, Vd[First@FirstPosition[o, 1]],
	2, vdd @@ Flatten[Table[ConstantArray[k, o[[k]]], {k, Length[o]}]]];

(* Q[[a, b]] as a function of Ap = A', e[a] = eta0^a', Vd, Vdd; also returns the reduced background equations *)
invariantQ[n_Integer] := Module[{etaF, potential, bgArgs, einst, scal, lin, eqs, pert, jet, bgRules, red,
		vRules, reduce, z, allEqs, jets, solveRow, rows},
	etaF = Table[eta0[a][r] + ep chi[a][r] ph, {a, n}];
	potential = Vf @@ etaF;
	bgArgs = Sequence @@ Table[eta0[a][r], {a, n}];
	einst = RicciTensor + 1/2 Table[Sum[D[etaF[[a]], m] D[etaF[[a]], k], {a, n}], {m, coords}, {k, coords}] -
		perturbedMetric potential/(d - 1);
	scal = Table[scalarLaplacian[etaF[[a]]] + (Derivative @@ UnitVector[n, a])[Vf] @@ etaF, {a, n}];
	lin[x_] := Simplify[(D[x, ep] /. ep -> 0)/ph];
	(* rt, rr, tt, x1x1 Einstein equations and the scalar equations *)
	eqs = Join[lin /@ {einst[[1, 2]], einst[[1, 1]], einst[[2, 2]], einst[[3, 3]]}, lin /@ scal];
	pert = Join[{F, psi}, Table[chi[a], {a, n}]];
	jet[x_] := x /. {Derivative[k_][f_][r] /; MemberQ[pert, f] :> J[f, k], f_[r] /; MemberQ[pert, f] :> J[f, 0]};
	bgRules = {Derivative[k_][A][r] :> D[Ap[r], {r, k - 1}], Derivative[k_][eta0[a_]][r] :> D[e[a][r], {r, k - 1}]};
	(* background equations: (d-1) A'' = 1/2 e.e,  e^a' = -d A' e^a - V_a,  V0 = -1/2 e.e - d (d-1) A'^2 *)
	red = {
		Derivative[k_][Ap][r] :> D[Sum[e[a][r]^2, {a, n}]/(2 (d - 1)), {r, k - 1}],
		Derivative[k_][e[a_]][r] :> D[-d Ap[r] e[a][r] - Vd[a][r], {r, k - 1}],
		Derivative[k_][Vd[a_]][r] :> D[Sum[vdd[a, b][r] e[b][r], {b, n}], {r, k - 1}]};
	vRules = {Vf[bgArgs] -> -1/2 Sum[e[a][r]^2, {a, n}] - d (d - 1) Ap[r]^2,
		Derivative[o__][Vf][bgArgs] :> vSymbol[{o}][r]};
	reduce[x_] := FixedPoint[Expand[# /. red] &, x /. vRules /. bgRules];
	z[a_] := chi[a][r] - eta0[a]'[r] psi[r]/(2 A'[r]);
	(* the equations and the r-derivative of the rt constraint, in jet variables *)
	allEqs = reduce[jet[Append[eqs, D[eqs[[1]], r]]]];
	jets = Flatten[Table[J[f, k], {f, pert}, {k, 0, 2}]];
	(* Z^a'' + d A' Z^a' + e^{-2A} w^2 Z^a = -Q_ab Z^b + (combination of the equations) *)
	solveRow[a_] := Module[{lam = Array[l, Length[allEqs]], q = Array[qq, n], expr, sol},
		expr = Expand[reduce[jet[D[z[a], {r, 2}] + d A'[r] D[z[a], r] + E^(-2 A[r]) w^2 z[a]]] -
			lam . allEqs + Sum[q[[b]] reduce[jet[z[b]]], {b, n}]];
		(* the equations are not independent, so some multipliers stay free: Solve::svars is expected *)
		sol = Quiet[Solve[(Coefficient[expr, #] == 0 & /@ jets), Join[lam, q]], Solve::svars];
		If[sol === {}, CheckFailed["the linearised equations do not close on Z (row " <> ToString[a] <> ")"]];
		Simplify[q /. First[sol]]];
	rows = Table[solveRow[a], {a, n}];
	<|"Q" -> rows, "background" -> Simplify[reduce[{einst[[1, 1]], einst[[2, 2]]} /. ep -> 0]]|>];

two = invariantQ[2];
one = invariantQ[1];
AssertZero["background equations with the reduction rules", Join[two["background"], one["background"]]];
AssertZero["Q_ab symmetric", two["Q"] - Transpose[two["Q"]]];

(* ---------- check: one ghost, eqs. (B.50)-(B.51) ---------- *)
(* (B.50)-(B.51) with eta0'' and A'' from the background equations, eq. (B.52) *)
qZH = 1/(d - 1) (Ap[r] Vd[1][r] + d Ap[r]^2 e[1][r] + e[1][r]^3/(2 (d - 1)))/Ap[r]^2;   (* e^{2A} Q_ZH *)
qZZpaper = Vdd[1, 1][r] - 1/(d - 1) e[1][r]/Ap[r] Vd[1][r] - e[1][r] qZH;
AssertZero["one ghost: Q_ZZ vs (B.50)-(B.52)", one["Q"][[1, 1]] - qZZpaper];
AssertZero["two ghosts with eta^2 = 0 reduce to one ghost",
	(two["Q"][[1, 1]] /. {e[2][r] -> 0, Vd[2][r] -> 0, Vdd[1, 2][r] -> 0}) - one["Q"][[1, 1]]];

(* ---------- example 5 (L = 1, r1 = r2 = 0, Minkowski boundaries as in 01) ---------- *)
etas = {eta1, eta2};
W5 = GhostSuperpotential["ex5", 1, etas];
V5 = -1/2 Total[D[W5, #]^2 & /@ etas] - d/(4 (d - 1)) W5^2;
sol5 = Thread[etas -> GhostFlow["ex5", 1, u, {0, 0}]];
warp5 = GhostWarp["ex5", 1, u, GhostMinkowskiA0["ex5"], {0, 0}];
AssertZero["ex5: warp factor vs warp_ex5 of 01", warp5 - ImportAnalytic["warp_ex5"]];
dA5 = D[Log[warp5]/2, u];
AssertZero["ex5: BPS eta^a' = -d_a W", (D[etas /. sol5, u]) - (D[W5, #] & /@ etas /. sol5) * -1];
AssertZero["ex5: BPS A' = -W/(2(d-1))", dA5 - (-W5/(2 (d - 1)) /. sol5)];

bg5 = Join[{Ap[r] -> dA5}, Table[e[a][r] -> D[etas[[a]] /. sol5, u], {a, 2}],
	Table[Vd[a][r] -> (D[V5, etas[[a]]] /. sol5), {a, 2}],
	Flatten[Table[Vdd[a, b][r] -> (D[V5, etas[[a]], etas[[b]]] /. sol5), {a, 2}, {b, a, 2}]]];
(* hyperbolic form for the paper: FullSimplify of the exponential form, checked below *)
q5exp = Map[TimeConstrained[Simplify[TrigToExp[#]], 15, #] &, two["Q"] /. bg5, {2}];
q5 = Map[TimeConstrained[FullSimplify[ExpToTrig[#]], 15, #] &, q5exp, {2}];
AssertZero["ex5: hyperbolic form of Q_ab", q5 - q5exp];
AssertNumericZero["ex5: Q_ab -> diag(3, 3) at u -> -oo (m^2 L^2 = -3)", (q5 /. u -> -60) - 3 IdentityMatrix[2]];
AssertNumericZero["ex5: Q_ab -> diag(3, 3) at u -> +oo", (q5 /. u -> 60) - 3 IdentityMatrix[2]];

throat5 = Map[Normal[Series[u^2 #, {u, 0, 0}]] &, q5, {2}];
e5 = Normalize[D[etas /. sol5, u] /. u -> 0];
AssertZero["ex5: throat Q_ab ~ -2 e_a e_b/u^2", throat5 + 2 Outer[Times, e5, e5]];

ExportAnalytic["ghost_ex5_throat11", throat5[[1, 1]]];
ExportAnalytic["ghost_ex5_throat12", throat5[[1, 2]]];
ExportAnalytic["ghost_ex5_throat22", throat5[[2, 2]]];
ExportAnalytic["ghost_ex5_Q11", q5[[1, 1]]];
ExportAnalytic["ghost_ex5_Q12", q5[[1, 2]]];
ExportAnalytic["ghost_ex5_Q22", q5[[2, 2]]];

Print["06_ghost_fluctuations_ex5: OK"];
ScriptEnd[];
