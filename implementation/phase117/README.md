# Phase117 — packed scalar arrays and versioned loops

Work in progress, 2026-10-21. [Design](../../design/phase117/array-facts-and-scalar-code.md).
Qualified parent: Phase114 source02; installed selection unchanged.

The checked Bend candidate reuses the mature packed32 scalar-array runtime,
preserves exact entry-handle facts across a loop, and puts the complete guarded
fallback in a separate worker. A modest general inlining limit increase exposes
cross-function facts. No workload-name matching or host-language IR transform.

Matched pair, three rotated rounds, unchanged Phase112 output/count oracle and
frozen50ms repetition profile:

| Change | Fold128 ms | Edit distance ms |
| --- | ---: | ---: |
| Phase114 baseline | 592 | 390 |
| Scalar checks removed | 429 | 348 |
| Packed allocation/access/destruction | 305 | 347 |
| Packed + invariant metadata | 217 | 344 |
| Packed + inlining512 only | — | 282 |
| Packed + inlining512 + invariants + versioning | 136 | 110 |
| Upstream C, matched final screen | 50 | 51 |

Ablation rows come from separate serial three-round campaigns, with their own
fresh baseline/upstream observations. These are selected historical programs,
not a broad score or proof of parity. Combined speedups are4.35× and3.55× versus
QBE; remaining gaps2.72× and2.16× upstream. All18 combined observations and11
ordinary controls pass. Broad45, fallback ABI controls and compiler-cost checks
are in progress; no native successor qualification or production promotion.

Selected checked source:
`selfhost/build/phase117/version-source03/compiler.bend`, SHA256
`8010f9b5691a32f9b8d3a45da444e05b4bf4275fd1380e2acb122bfd2e53fec6`.
API: `selfhost/build/phase111/p117-version-api03/report.json`.
Runtime: `selfhost/build/phase117/runtime01/report.json`.
Reproduction modules live in `selfhost/tools/performance/phase117/`:
`packed-arrays.bend`, `array-invariants-packed-v4.bend`, `inline-512.bend`,
`array-versioning-v2.bend`; compose using `prepare-v2.py` with explicit parent
and module overrides recorded in the source manifest.

See [array proof audit](array-proof-audit.md), [scalar audit](scalar-audit.md),
and [machine code](machine/version01-fold.asm). The fast fold loop no longer
contains calls or scratch-result traffic; raw/dynamic checks and descriptor
projection dominate entry, not each iteration. Boolean normalization removed
instructions but gave no meaningful runtime gain and remains excluded.

Failures retained: initial source-composition mistake, incomplete API export
list, control-binding type annotations, versioning match/affinity annotations,
and an ordinary-oracle schema adapter mismatch with identical actual output.
The first hoist prototype lost GET facts at a fresh allocation and did not
produce its intended gain; preserving disjoint prior slots fixed it. No failing
compiler result has been reclassified as a pass by weakening the oracle.
