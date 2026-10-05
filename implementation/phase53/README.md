# Phase53: correct direct JavaScript and make it the default

The compiler remains implemented in Bend. This phase corrects F32 bit transport,
changes ordinary JavaScript compilation to direct output, and tests ordered
intrinsic lowering for further execution-speed gains.

[Design](../../design/phase53/default-direct-and-ordered-expressions.md) ·
[NaN diagnosis](nan-payload.md) · [Qualification](qualification.md) · [Independent review](review.md) ·
[Benchmark plan](../../selfhost/tools/performance/phase53/PLAN.md) ·
[Scaling limits](scaling.md) · [Table opportunity](table-opportunity.md) ·
[Source accounting](complexity.md).

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

## Expanded controls and optimization admission

The correction/default-only eight-point screen completes all 72 samples in
57.429 seconds. Corrected/TypeScript is 1.224461 and prior direct06/TypeScript
is 1.226614: performance is effectively unchanged (1.001759 times speedup).
No point regresses more than 10%. These eight points are a rejection screen,
not the final 45-point result.

New computed-U32 callback controls exposed another existing interface gap:
direct06/corrected01 call `f` then `g`, while the pinned emitter's nested-prefix
policy calls `g` then `f`. The initial independent test assumed left-to-right
execution; its failure remains preserved. A versioned correction follows the
published upstream-callable contract and the audited emitter implementation,
leaving values/errors and all other expectations unchanged. Corrected01 fails
those two revised interface controls; default release promotion remains pending.

The [refined plan](../../design/phase53/ordered-prefix-evaluation-order.md)
addresses this in a composable ordered-expression representation, including
unknown calls, constructors and expression lets. The first isolated prototype
was superseded before compilation or timing. Ordered02 now passes all 96 original
source scenarios, 18 composition controls and 34 numeric controls. Pinned
TypeScript's original NaN failure and six corresponding cold reference failures
remain visible. Maintained-suite, performance and installed-interface gates
remain separate; no mismatch is waived.
