# Phase126: compose useful optimizations and remove failed machinery

Campaign in progress, starting `3c94d98` at 2026-10-22 22:59 UTC. The authorized
three-hour window ends around 01:59 UTC. Phase125 remains the native-qualified
checkpoint; no Phase126 native qualification or installed selection change yet.

## Findings established by the first focused experiments

1. Persistent local float values help, but a typed private ABI did not. In a
   rotated paired run, active-ray medians were1175ms local-only,1297ms typed and
   1712ms Phase125. The simpler option also won ordinary ray,1835/1863/1973ms;
   recurrence418/419/416ms was neutral. Keep the successful cleanup and discard
   the extra ABI/analysis from the candidate. The compact implementation emits
   byte-identical QBE to the selected prior composition on all three sources.
2. Finite scalar tables compose with the float cleanup. Table-only active-ray
   median1391ms versus1692ms parent; their composition903ms versus1699ms parent
   and201ms upstream. Actual scalar definitions/refusals are independently
   inspected, including full-width Nat defaults. This remains a focused result.
3. A safe conditional in recursive argument preparation blocked a whole local
   continuation region. Admitting that exact retained branch cuts ordinary-ray
   runtime1911→561ms, with upstream229ms. Tree-bitonic, Mandelbrot and local-fold
   in the same screen remain approximately unchanged. The column worker now
   uses the existing explicit-stack region instead of scheduler transfers.

These numbers are compiled-program execution time. They are not compiler
throughput or a replacement for the original44-point geometric mean. Full
composition, additional controls, broad timing and integration are still pending.

## Current evidence

- [Design](../../design/phase126/persistent-private-values.md).
- [Float experiment](../../experiments/phase126/P126-001-persistent-float-regions.md)
  and `selfhost/build/phase126/local-typed-paired01/report.json`.
- [Table experiment](../../experiments/phase126/P126-002-finite-scalar-selectors.md),
  `table-inspect02/report.json` and `combined-screen08/report.json` under Phase126.
- [Conditional recursion experiment](../../experiments/phase126/P126-003-conditional-recursive-preparation.md),
  `resume-finite10/report.json` and `resume-screen10/report.json` under Phase126.
- [Machine evidence](machine-audit-v02.md), [local ablation](machine-audit-local06.md),
  [table review](table-review.md), [recursion review](scalar-resume-review.md).

All timed observations use the unchanged complete-result/count oracle, selected
Phase125 runtime, branch-aligned QBE machine builds and one guarded CPU3 lane.
Frozen sources, failed acquisitions and unsupported control literals remain
preserved. Agents inspect disjoint code/proofs/tooling; only the root runs targets.

## Remaining work in this campaign

Test the missing F32-to-U32 operand case, exact Nat predecessor projection and
bounded constructor identity. Test table-call composition if ready. Retain only
measured useful changes, then run ordinary controls, the frozen45 corpus and a
matched compiler-cost screen. A native checkpoint is contingent on material
benefit, memory/disk headroom and enough remaining time; it is not inferred from
hosted benchmark success. Final report will replace these pending statements.
