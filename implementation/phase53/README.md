# Phase53: correct direct JavaScript and make it the default

The compiler remains implemented in Bend. This phase corrects F32 bit transport,
changes ordinary JavaScript compilation to direct output, and tests ordered
intrinsic lowering for further execution-speed gains.

[Design](../../design/phase53/default-direct-and-ordered-expressions.md) ·
[NaN diagnosis](nan-payload.md) · [Independent review](review.md) ·
[Benchmark plan](../../selfhost/tools/performance/phase53/PLAN.md) ·
[Scaling limits](scaling.md) · [Table opportunity](table-opportunity.md).

## Corrected baseline checkpoint

`checked-corrected01` built in 58.687 seconds and passed the strict focused
frontend gate. All 29 independent semantic fixtures were freshly compiled.
The unchanged 96 scenarios then completed in 11.079 seconds:

| Qualification | Result |
| --- | ---: |
| Candidate source oracles | **96/96** |
| Pinned TypeScript source oracles | **95/96** |
| Exact differential agreement | **95/96** |

The remaining difference is a reference defect, not a candidate-oracle waiver:
`f32_table_nan_bits.bend` expects 40, the corrected candidate returns **40**, and
pinned TypeScript returns **1**. The prior direct image returned 39 cold. The
runtime now writes directly to fresh typed-array storage, avoiding an ordinary
JavaScript array that can lose a NaN payload. No global payload canonicalization,
source-golden change or shared mutable conversion buffer was introduced.

The source-oracle and reference-differential results remain separate. This
targeted suite does not establish universal language/host conformance or a new
self-emitted compiler fixed point. Additional cold/repeated controls and final
selected-image qualification are separate gates.

The driver now defaults to direct JavaScript for program/library emission and
`--run`. `--legacy-js` and API `backend: 'js'` preserve the descriptor interface;
native targets and pure interpretation retain their existing routes. Maintained
private compiler-image workers explicitly select their legacy ABI. Actual CLI
routing controls pass; installation/relocation tests are still pending.

The corrected baseline deliberately contains no optimization of Bend emitter
functions. Its generated compiler API is the same `472da578…` as Phase52, while
the direct runtime and driver identities differ. Qualification and benchmark
bindings therefore check the entire selected input identity, not API hash alone.

Evidence: `selfhost/build/phase53/checked-corrected01`,
`semantic-corrected01-acquisition01/manifest.json`, and
`semantic-corrected01-controls01/report.json`. The complete final campaign will
be preserved in one closed raw archive at publication. Phase52 evidence remains
unchanged. Optimization, final measurements and installation are in progress.
