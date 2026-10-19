(* ::Package:: *)
(* wormholes.wl -- EXAMPLE project package (from arXiv:2605.16168; /init-project removes it).

   The analytically extended BPS wormholes of sec. 2.2 (examples 1, 2, 5), shared by the pipeline
   scripts 01, 02 and 06. Ghost scalars only, d+1 = GhostDimension[ex] + 1 bulk dimensions,
   ds^2 = dr^2 + e^{2A(r)} eta_{mu nu} dx^mu dx^nu, BPS equations eta^a' = -d_a W, A' = -W/(2(d-1)).
   Functions take every symbol as an argument, so expressions live in the calling script's context.
   Loaded with LoadPackage["wormholes"].
*)

BeginPackage["Wormholes`"];

GhostDimension::usage = "GhostDimension[ex] is the boundary dimension d of example ex (\"ex1\", \"ex2\", \"ex5\").";
GhostSuperpotential::usage = "GhostSuperpotential[ex, L, {eta1, ...}] is the superpotential W(eta) after the \
analytic extension (sec. 2.2).";
GhostFlow::usage = "GhostFlow[ex, L, r, shifts] is the list of closed-form BPS profiles eta^a(r); shifts = {r0} \
(ex1, ex2) or {r1, r2} (ex5).";
GhostWarp::usage = "GhostWarp[ex, L, r, a0, shifts] is the warp factor e^{2A(r)} of the flow GhostFlow[ex, L, r, shifts].";
GhostMinkowskiA0::usage = "GhostMinkowskiA0[ex] is the a0 for which both boundary metrics are Minkowski with unit \
normalisation, e^{2A} ~ e^{2|r|/L} (sec. 4.2), for vanishing shifts.";

Begin["`Private`"];

GhostDimension["ex1"] = 4;
GhostDimension["ex2"] = 3;
GhostDimension["ex5"] = 4;

(* 1. Coulomb branch of N=4 SYM *)
GhostSuperpotential["ex1", L_, {eta_}] := 6/L Cos[eta/Sqrt[3]];
GhostFlow["ex1", L_, r_, {r0_}] := {2 Sqrt[3] ArcTan[E^(2 (r - r0)/L)]};
GhostWarp["ex1", L_, r_, a0_, {r0_}] := E^(2 a0)/Sin[First[GhostFlow["ex1", L, r, {r0}]]/Sqrt[3]];
GhostMinkowskiA0["ex1"] = Log[2]/2;

(* 2. Coulomb branch of ABJM *)
GhostSuperpotential["ex2", L_, {eta_}] := 4/L Cos[eta/2];
GhostFlow["ex2", L_, r_, {r0_}] := {4 ArcTan[E^((r - r0)/L)]};
GhostWarp["ex2", L_, r_, a0_, {r0_}] := E^(2 a0)/Sin[First[GhostFlow["ex2", L, r, {r0}]]/2]^2;
GhostMinkowskiA0["ex2"] = Log[4]/2;

(* 5. GPPZ, two ghosts *)
GhostSuperpotential["ex5", L_, {eta1_, eta2_}] := 3/L (Cos[eta1/Sqrt[3]] + Cos[eta2]);
GhostFlow["ex5", L_, r_, {r1_, r2_}] := {2 Sqrt[3] ArcTan[E^((r - r1)/L)], 2 ArcTan[E^(3 (r - r2)/L)]};
GhostWarp["ex5", L_, r_, a0_, {r1_, r2_}] := E^(2 a0) Cosh[(r - r1)/L] Cosh[3 (r - r2)/L]^(1/3);
GhostMinkowskiA0["ex5"] = Log[2^(4/3)]/2;

End[];
EndPackage[];
