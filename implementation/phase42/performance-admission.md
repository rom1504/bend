# Phase42 performance admission

Admit checked16 for release, with the tradeoffs below. The exact machine decision
is `integration03/performance-admission.json` in the archived Phase42 campaign.
It binds the checked attempt, API, runtime, semantic closure, full runtime
comparison, compiler cost, confirmation and profile reports.

All 45 maintained points and 669 fresh runtime samples complete successfully.
The equal-point geometric mean of candidate/TypeScript time is **8.86×**, down
from **12.57×** for Phase41 in the same runs. Giving each of the 23 source paths
equal weight instead gives **11.42×**, down from **15.40×**. Neither statistic
estimates the average speed of arbitrary Bend programs. Overall parity was not
achieved; only one catalog point runs faster than TypeScript.

The admitted benefits are large and repeat across input sizes: trees improve
6.27–8.02×, BSTs 23.66–26.96× and list pipelines 2.72–6.65× over Phase41. The
512-element list pipeline takes 0.605× TypeScript time. The full table preserves
unchanged workloads and losing medians, rather than reporting only these gains.

The principal runtime tradeoff is expression128: its original full-run median
is 10.98% slower, with overlapping ranges and substantial within-sample drift.
A separate 60-second-protocol confirmation is 2.51% slower, also with overlapping
ranges. Expression32's original improvement also shrinks in that confirmation.
The second run neither replaces the first nor proves the regression absent.
Accept this observed small-workload tradeoff for the larger confirmed gains;
retain it as a target for subsequent work.

Compilation is a separate cost. Four-source request medians change by +5.79%
for pair, −6.17% for tree, −6.03% for numeric recurrence and +6.69% for list.
Source grows by 1,158 physical Bend lines and 141 definitions, with three added
runtime lines. This release is a performance improvement with a maintenance and
compilation tradeoff, not a simplification result.

Admission preserves the published host initialization contract, public fallback,
deep iterative fallback and all final semantic requirements. It does not claim
arbitrary preimport host replacement, universal backend/GPU conformance or a new
self-emitted fixed point. The actual installed release is established separately
by [integration](integration.md).
