(* ::Package:: *)
(* 01_ee_mumu.wl -- EXAMPLE calculation (delete once your project has real ones).

   Tree-level e+ e- -> mu+ mu- in massless QED via explicit Dirac traces.
   Outputs:
     results/analytic/dsigma_dOmega.json, paper/generated/eq_dsigma_dOmega.tex
     results/analytic/sigma_tot.json,     paper/generated/eq_sigma_tot.tex
     results/01_ee_mumu.json  (checks consumed by the paper as \val... macros)
*)

Get[FileNameJoin[{DirectoryName[$InputFileName], "..", "Project.wl"}]];

ClearAll[s, theta, alpha];
$Assumptions = s > 0 && 0 <= theta <= Pi && alpha > 0;

(* Dirac representation *)
sigma = PauliMatrix /@ {1, 2, 3};
gam = Join[
  {ArrayFlatten[{{IdentityMatrix[2], 0}, {0, -IdentityMatrix[2]}}]},
  ArrayFlatten[{{0, #}, {-#, 0}}] & /@ sigma];
slash[p_] := Sum[$Metric[[m, m]] p[[m]] gam[[m]], {m, 4}];

(* CM-frame kinematics, massless *)
en = Sqrt[s]/2;
p1 = en {1, 0, 0, 1};  p2 = en {1, 0, 0, -1};
k1 = en {1, Sin[theta], 0, Cos[theta]};  k2 = en {1, -Sin[theta], 0, -Cos[theta]};

(* Spin-summed |M|^2 = e^4/s^2 Tr[p2 g^mu p1 g^nu] Tr[k1 g_mu k2 g_nu] *)
lep = Table[Tr[slash[p2] . gam[[m]] . slash[p1] . gam[[n]]], {m, 4}, {n, 4}];
had = Table[Tr[slash[k1] . gam[[m]] . slash[k2] . gam[[n]]], {m, 4}, {n, 4}];
msqAvg = Simplify[(1/4) (4 Pi alpha)^2/s^2 Tr[lep . $Metric . Transpose[had] . $Metric]];

(* Factor after eliminating Sin^2 keeps the textbook form (1 + Cos^2) instead of Cos[2 theta] *)
dsigmadOmega = Factor[Expand[TrigExpand[msqAvg/(64 Pi^2 s)] /. Sin[theta]^2 -> 1 - Cos[theta]^2]];
sigmaTot = Simplify[Integrate[dsigmadOmega Sin[theta], {theta, 0, Pi}, {phi, 0, 2 Pi}]];

(* Sanity checks -- fail loudly *)
If[Simplify[dsigmadOmega - alpha^2 (1 + Cos[theta]^2)/(4 s)] =!= 0,
  Print["CHECK FAILED: dsigma/dOmega"]; Exit[1]];
If[Simplify[sigmaTot - 4 Pi alpha^2/(3 s)] =!= 0,
  Print["CHECK FAILED: sigma_tot"]; Exit[1]];

ExportAnalytic["dsigma_dOmega", dsigmadOmega];
ExportAnalytic["sigma_tot", sigmaTot];

sqrtS = 10.; alphaVal = 1/137.035999;
ExportValues["01_ee_mumu", <|
  "SqrtSRef" -> <|"value" -> sqrtS, "digits" -> 2, "unit" -> "GeV"|>,
  "SigmaTotMma" -> <|"value" -> $GeV2ToPb sigmaTot /. {s -> sqrtS^2, alpha -> alphaVal},
                    "digits" -> 4, "unit" -> "pb"|>
|>];

Print["01_ee_mumu: OK  sigma_tot = ", sigmaTot];
