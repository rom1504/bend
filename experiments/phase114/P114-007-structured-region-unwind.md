# P114-007: keep unwind operations structured inside continuation regions

Hypothesis: the new closed continuation table still renders stack restoration
as opaque runtime calls. Reusing the already qualified structured frame/pop/get
operations should expose their loads and stores to QBE without changing the
explicit stack, ownership, scheduling or ABI. A separate precedence experiment
asks whether the table should be tried before the older single-continuation plans.

The original table and transport inventories remain frozen. Two small overlays
replace only table unwind rendering and public selection. The renderer uses
ordinary `N111Call` operations through `p114t_stmt`, sharing its site counter and
runtime offsets. The earlier direct/R/G/generic paths remain fallbacks. No source
name or benchmark identity participates in selection.

## Observed results

Three unchanged frozen kernels, three paired rounds, complete output/count gates:

| Experiment | Comparator | Candidate elapsed / comparator | Decision |
|---|---|---:|---|
| Structured unwind | Original table | 0.9446 | Retain |
| Table first alone | Original table | 1.0010 | No standalone benefit |
| Table first plus structured unwind | Structured unwind | 0.9680 | Select combined for broad qualification |
| Packed Take1 template, separate experiment | Original table | 0.9840 | Defer: small gain, list regression |

The joint comparison's medians in milliseconds are tree554→334, list701→290,
expression491→134 versus source31. Its three-case geometric mean is4.639735×
upstream, compared with source31's11.363529× in the same run. This is a selected
screen, not the45-program score. All45 measured observations and five ordinary
programs pass. Independent source review finds no defect but is not a proof.

Exact report: `selfhost/build/phase112/p114-first-unwind-screen01-measure/report.json`.
Source SHA256 `ba5be2e46ec43fe4f060d6fe361ced8c07eecce3ef8d7d821552c86f86a070c7`.
The final recipe reorders declarations during authenticated source transport;
its separately checked source hash differs. No final-product identity is assumed.
All isolated receipts and source/review details are in
[the ablation record](../../selfhost/tools/performance/phase114/recursive-table/ablations.md).

## Interpretation and limits

The interaction matters: H-first alone was neutral; using its structured unwind
for regions previously handled by the narrow paths improves the joint screen.
The largest gain still comes from eliminating global continuation dispatch, not
from adding isolated helper templates. Explicit frame storage and constructor
allocation remain. Final broad performance and native self-reproduction must be
measured on the selected exact source before promotion.
