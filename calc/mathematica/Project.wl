(* ::Package:: *)
(* Project.wl -- shared definitions for every Mathematica script in this project.

   Load it at the top of each script with
       Get[FileNameJoin[{DirectoryName[$InputFileName], "..", "Project.wl"}]];
       ScriptBegin["ScriptNN"];   ... calculation ...   ScriptEnd[];
   ScriptBegin gives the script a private, freshly wiped context, so it behaves identically in
   `wolfram -script`/wolframscript and in the persistent, context-isolated kernel of the Wolfram
   MCP server (no clashes between `r`, `x`, ... of different scripts or sessions, no leaked state).
   The coordinates `r` and `x` are public symbols of this package (Project`r, Project`x), which is
   what lets DomainWallCoordinates agree with the symbols typed in a script.

   Conventions (keep in sync with notes/conventions.md):
     - mostly-plus signature (-,+,...,+)
     - Riemann tensor R^a_{bcd} = d_c Gamma^a_{db} - d_d Gamma^a_{cb} + Gamma^a_{ce} Gamma^e_{db} - Gamma^a_{de} Gamma^e_{cb},
       Ricci R_{bd} = R^a_{bad}, so AdS has R < 0
     - action (1/(16 Pi G)) Int sqrt(-g) [R - 1/2 (dphi)^2 - V],  2 kappa^2 = 16 Pi G
*)

BeginPackage["Project`"];

$ProjectRoot::usage = "$ProjectRoot is the absolute path of the repository root.";

r::usage = "r is the radial coordinate of DomainWallCoordinates (symbol shared by Project.wl and all scripts).";
x::usage = "x[i] are the boundary coordinates of DomainWallCoordinates (symbols shared by Project.wl and all scripts).";
ScriptBegin::usage = "ScriptBegin[\"ScriptNN\"] starts a pipeline script: wipes and enters the private context \
ScriptNN`, drops stale Global`/Sessions` contexts from $ContextPath and resets $Assumptions. \
Pair with ScriptEnd[] at the end of the script.";
ScriptEnd::usage = "ScriptEnd[] leaves the script context and restores $Context, $ContextPath and $Assumptions. \
Called automatically by CheckFailed, and safe to call twice.";

Christoffel::usage = "Christoffel[g, x] gives Gamma^a_{bc} for metric matrix g in coordinates x.";
RiemannTensor::usage = "RiemannTensor[g, x] gives R^a_{bcd} (conventions in Project.wl header).";
RicciTensor::usage = "RicciTensor[g, x] gives R_{bd} = R^a_{bad}.";
RicciScalar::usage = "RicciScalar[g, x] gives R = g^{bd} R_{bd}.";
EinsteinTensor::usage = "EinsteinTensor[g, x] gives G_{ab} = R_{ab} - 1/2 g_{ab} R.";
ScalarLaplacian::usage = "ScalarLaplacian[f, g, x] gives (1/sqrt(-g)) d_a (sqrt(-g) g^{ab} d_b f) for a Lorentzian metric g.";
DomainWallMetric::usage = "DomainWallMetric[A, d] is the metric dr^2 + e^{2A} eta_{mu nu} dx^mu dx^nu in d+1 \
dimensions (mostly plus), with coordinates {r, x0, ..., x(d-1)} returned by DomainWallCoordinates[d].";
DomainWallCoordinates::usage = "DomainWallCoordinates[d] gives {r, x[0], ..., x[d-1]}.";

ExportValues::usage = "ExportValues[name, <|key -> value, ...|>] writes results/<name>.json. \
Each key becomes the LaTeX macro \\val<Key> via `make values`. \
A value may be a number or <|\"value\" -> x, \"digits\" -> n (or \"decimals\" -> n), \"unit\" -> \"GeV\"|>.";
ExportAnalytic::usage = "ExportAnalytic[name, expr] writes results/analytic/<name>.json \
(InputForm + TeXForm) and paper/generated/eq_<name>.tex for \\input in the paper.";
ImportAnalytic::usage = "ImportAnalytic[name] reads back an expression saved with ExportAnalytic.";
AssertZero::usage = "AssertZero[label, expr] checks expr == 0 (or a list of zeros): Simplify for at most 20 s, \
then 40-digit evaluation at random points; calls CheckFailed if it is not zero.";
AssertNumericZero::usage = "AssertNumericZero[label, expr] checks expr == 0 only numerically (40 digits, random \
rational points for all free symbols); use it for asymptotic checks and when Simplify is hopeless.";
CheckFailed::usage = "CheckFailed[msg] prints the failure and stops: Exit[1] under wolframscript, Abort[] in an \
interactive/MCP kernel (so the kernel survives).";

Begin["`Private`"];

$ProjectRoot = FileNameDrop[
  If[StringQ[$InputFileName] && $InputFileName =!= "", $InputFileName,
     FileNameJoin[{Directory[], "calc", "mathematica", "Project.wl"}]], -3];

(* ---------- Riemannian geometry ---------- *)

Christoffel[g_, x_] := Module[{gi = Simplify[Inverse[g]], n = Length[x]},
  Simplify @ Table[
    1/2 Sum[gi[[a, e]] (D[g[[e, b]], x[[c]]] + D[g[[e, c]], x[[b]]] - D[g[[b, c]], x[[e]]]), {e, n}],
    {a, n}, {b, n}, {c, n}]];

RiemannTensor[g_, x_] := Module[{G = Christoffel[g, x], n = Length[x]},
  Simplify @ Table[
    D[G[[a, d, b]], x[[c]]] - D[G[[a, c, b]], x[[d]]] +
      Sum[G[[a, c, e]] G[[e, d, b]] - G[[a, d, e]] G[[e, c, b]], {e, n}],
    {a, n}, {b, n}, {c, n}, {d, n}]];

RicciTensor[g_, x_] := Module[{R = RiemannTensor[g, x], n = Length[x]},
  Simplify @ Table[Sum[R[[a, b, a, d]], {a, n}], {b, n}, {d, n}]];

RicciScalar[g_, x_] := Simplify[Tr[Inverse[g] . RicciTensor[g, x]]];

EinsteinTensor[g_, x_] := Simplify[RicciTensor[g, x] - 1/2 g RicciScalar[g, x]];

ScalarLaplacian[f_, g_, x_] := Module[{sq = PowerExpand[Sqrt[-Det[g]]], gi = Inverse[g]},
  Simplify[1/sq Sum[D[sq gi[[a, b]] D[f, x[[b]]], x[[a]]], {a, Length[x]}, {b, Length[x]}]]];

DomainWallCoordinates[d_Integer] := Join[{r}, Table[x[i], {i, 0, d - 1}]];
DomainWallMetric[A_, d_Integer] := DiagonalMatrix[Join[{1}, E^(2 A) Join[{-1}, ConstantArray[1, d - 1]]]];

(* ---------- checks ---------- *)

numericallyZero[flat_List] := Module[{vars, pts, vals},
  vars = Select[Union[Cases[flat, _Symbol, {-1}]], !NumericQ[#] &];
  (* random rationals in (0.11, 1.89) that avoid "special" values such as 1 or 1/2 *)
  pts = Table[Thread[vars -> (RandomInteger[{1100, 18900}, Length[vars]] + 3/7)/10000], {12}];
  (* asymptotic checks deep in AdS regions need ~100 extra digits to resolve e^{-200} terms *)
  vals = Block[{$MaxExtraPrecision = 500},
    Quiet[Max[Abs[N[flat /. #, 40]]] & /@ pts, {N::meprec, Power::infy, Infinity::indet}]];
  vals = Select[vals, NumericQ[#] && # < Infinity &];   (* skip points on singularities *)
  Length[vals] >= 6 && Max[vals] < 10^-25];

AssertZero[label_String, expr_] := Module[{flat = Flatten[{expr}], s},
  (* 1. symbolic, but never let Simplify run away *)
  s = TimeConstrained[Simplify[flat], 10, $Failed];
  If[s =!= $Failed && AllTrue[s, # === 0 &], Return[True]];
  (* 2. inconclusive: 40-digit evaluation at random rational points (positive, O(1)) *)
  If[numericallyZero[flat], Return[True]];
  CheckFailed[label <> "  residual: " <> ToString[Short[If[s === $Failed, flat, s], 3], InputForm]]
];

AssertNumericZero[label_String, expr_] :=
  If[numericallyZero[Flatten[{expr}]], True,
    CheckFailed[label <> "  residual: " <> ToString[Short[expr, 3], InputForm]]];

CheckFailed[msg_String] := (Print["CHECK FAILED: ", msg]; ScriptEnd[];
  If[Length[$ScriptCommandLine] > 0, Exit[1], Abort[]]);

(* ---------- script isolation ---------- *)

$scriptSaved = None;

ScriptBegin[id_String] := Module[{ctx = id <> "`"},
  ScriptEnd[];                                  (* recover from an earlier aborted run *)
  $scriptSaved = <|"Script" -> ctx, "ContextPath" -> $ContextPath, "Assumptions" -> $Assumptions|>;
  Quiet[Remove[Evaluate[ctx <> "*"]], Remove::rmnsm];
  $ContextPath = Select[$ContextPath, !StringStartsQ[#, "Global`" | "Sessions`"] &];
  $Assumptions = True;
  Begin[ctx];
  ctx];

ScriptEnd[] := If[AssociationQ[$scriptSaved], Module[{s = $scriptSaved},
  $scriptSaved = None;
  If[$Context === s["Script"], End[]];          (* pops the Begin of ScriptBegin *)
  $ContextPath = s["ContextPath"]; $Assumptions = s["Assumptions"];
  Null]];

(* ---------- export ---------- *)

ensureDir[d_] := If[!DirectoryQ[d], CreateDirectory[d, CreateIntermediateDirectories -> True]];

normalise[v_?NumericQ] := <|"value" -> N[v]|>;
normalise[a_Association] := MapAt[N, a, "value"];

ExportValues[name_String, vals_Association] := Module[{dir, file},
  dir = FileNameJoin[{$ProjectRoot, "results"}]; ensureDir[dir];
  file = FileNameJoin[{dir, name <> ".json"}];
  Export[file, normalise /@ vals, "RawJSON"];
  file
];

ExportAnalytic[name_String, expr_] := Module[{dir, gen, file},
  dir = FileNameJoin[{$ProjectRoot, "results", "analytic"}]; ensureDir[dir];
  gen = FileNameJoin[{$ProjectRoot, "paper", "generated"}]; ensureDir[gen];
  file = FileNameJoin[{dir, name <> ".json"}];
  Export[file, <|
    "name" -> name,
    "mathematica" -> ToString[expr, InputForm],
    "tex" -> ToString[TeXForm[expr]],
    "generated" -> DateString["ISODateTime"]|>, "RawJSON"];
  Export[FileNameJoin[{gen, "eq_" <> name <> ".tex"}],
    "% generated by calc/mathematica -- do not edit\n" <> ToString[TeXForm[expr]] <> "\n", "Text"];
  file
];

ImportAnalytic[name_String] := ToExpression[
  Import[FileNameJoin[{$ProjectRoot, "results", "analytic", name <> ".json"}], "RawJSON"]["mathematica"]];

End[];
EndPackage[];
