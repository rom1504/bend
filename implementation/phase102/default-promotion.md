# Corrected Phase102 candidate04: promoted native default

**Corrected candidate04 is now the default native compiler.** Its genuine B1/B2
chain, semantic qualification, source-specific performance acceptance, public
CLI and actual default smoke are complete. Both staged and stable request
capsules are sealed and verified. The coordinator accepted the measured tradeoff
for this exact source. This report
supplements the [original campaign](README.md):
its candidate03 measurements and rejected attempts remain historical.

The exact source is `projection-cost-source01/compiler.bend`, SHA256
`63ef222c4c6de73bb54c8e51d3b0a0552979b5791ea98e64d1098051a9cda237`:
1,788,947 bytes and 39,372 physical lines, 582 above Phase98. It corrects the
projected-cost policy used to choose forced inline hints, retaining the earlier
worker, observer and constructor transformations. The immutable
[lowering04 profile](../../selfhost/tools/native/profiles/phase102-lowering04/profile.json)
replays this exact source; source transport remains separate from qualification.

## Completed native qualification

The [admission](../../selfhost/build/phase102/native-chain04/admission.json) is
complete with `qualified: true`, `inputsUnchanged: true` and
`defaultSelection: false`. No candidate03 admission was substituted.

| Gate | Candidate04 result |
|---|---|
| Upstream-built native B1 | PASS, `native-b1-04/b1.json` |
| Independent same-source reference and genuine B1 self emission | PASS, exact complete diagnostics |
| Genuine B1-built native B2 | PASS, `native-chain04/b2.json` |
| B2 self fixed point | PASS, exact complete C and diagnostics |
| Native live/cache/refusal controls | PASS for both stages |
| Broad semantic programs | PASS, all 45 |
| Native conformance | PASS, 69 eligible fixtures and 3 expected rejections per stage; 31 unchanged exclusions |
| Final-source backend bridge | PASS, 70 obligations |
| Native mechanism correspondence | PASS, 19 sources / 38 emissions; 136 output observations: 115 fresh, 21 inherited after exact C correspondence |
| Original five final-image controls | PASS |

Paths in the table are beneath `selfhost/build/phase102/`. The genuine self-C
fixed point is 30,373,059 bytes, SHA256
`ed60e46ccb281b6aa2a0764bd418f0f01057b060fe7d90ef6160ddf1afe11498`.
B1's ELF SHA256 is
`b2aec9e660bed602f29d7666ce6d14724d7e78c7582393d53f25d7d69aea7a66`;
B2's is `85a70429493fe779a08f983d497ceee10dbe8aaec510d43c6ff220aa19ec60f7`.
These are exact product identities and finite qualification results, not a
universal compiler or native-memory proof.

## Compiler measurements

The repeated six-source screen uses four balanced rounds against the same
installed Phase98 stage. Each screen records 48 exact C/diagnostic observations.
The table gives equal-case geometric means of candidate/comparator time ratios;
lower is faster.

| Compiler stage | Request time / Phase98 | Whole-process time / Phase98 |
|---|---:|---:|
| B1 | 1.026011 | 1.026269 |
| B2 | 0.724500 | 0.689040 |

B1 is about 2.6% slower on this screen; B2 uses about 27.6% less request time
and 31.1% less process time. These are different stage-specific results, from
[B1 screen04](../../selfhost/build/phase99/phase102-b1-screen04/report.json) and
[B2 screen04](../../selfhost/build/phase99/phase102-b2-screen04/report.json).
They are compiler request measurements, not generated-program runtime.

The full-source chain records single request observations: 147.217 seconds for
the independent Phase98 B2 reference, 126.584 seconds for candidate B1 self
emission, and 150.846 seconds for candidate B2 self reproduction. These are
chain observations, not a repeated self-compilation speed comparison; no
self-speed gain is claimed. The actual B2 Clang build takes 374.033 seconds
with 2,601,885,696 bytes peak process-tree RSS. Build time is separate from
compiler execution and remains within the original 420-second guard.

## Corrected application screen

The current-source [projection-cost screen](../../selfhost/build/phase102/projection-cost-screen01/report.json)
records four alternating rounds and 72 complete output observations. These
ratios compare generated application processes, including startup and IO; they
do not time the native compiler image.

| Complete application | Candidate04 / Phase98 | Candidate04 / upstream |
|---|---:|---:|
| Source index, 10,000 generated definitions | 0.525 | 0.912 |
| Source index, compiler text | 0.510 | 1.077 |
| Renderer, one worker | 0.734 | 0.986 |
| Renderer, four workers | 0.788 | 1.195 |
| Dependency planner, DAG800 | 0.665 | 0.224 |
| Dependency planner, chain1000 | 0.685 | 0.246 |

All six points improve on Phase98 in this screen. Upstream remains faster on
compiler-text indexing and the four-worker renderer. The generated-definition
index point is short, about 56 ms for the candidate, so small differences there
should not be generalized. These are candidate04 observations; the original
candidate03 table is retained unchanged in the campaign report.

## Broad runtime and performance acceptance

All 45 candidate04 runtime products have fresh acquisition/build evidence:
106.923761 seconds of Clang work, zero reused products. Fresh comparisons of all
44 positive-work points are complete, with three alternating rounds against
each comparator. These are warmed generated-program timings; compiler requests,
Clang builds and startup are excluded. The zero-work control has no ratio.

| Runtime weighting | Candidate04 / Phase98 | Candidate04 / upstream |
|---|---:|---:|
| Equal catalog point geometric mean | 0.936547 | 1.043461 |
| Equal original source geometric mean | 0.936187 | 1.065286 |

The equal-point aggregate uses about 6.3% less runtime than Phase98 and remains
about 4.3% above upstream. Source weighting leaves a 6.5% upstream gap. The
completed [Phase98 comparison](../../selfhost/build/phase99/phase102-runtime-vs-phase9804/summary.json)
and [upstream comparison](../../selfhost/build/phase99/phase102-runtime-vs-upstream04/summary.json)
retain every original point and its raw samples.

Against Phase98, local-fold's original/128/8192 points are now
1.0040× / 1.0157× / 1.0000×; raytrace is 0.9922×. The list-pipeline128/512 gains
remain at 0.6447× / 0.6693×. The original numeric-recurrence256 screen records
1.0827× and remains in the broad aggregate. A separate
[eight-round alternating repeat](../../selfhost/build/phase93/phase102-promotion-numeric04/report.json)
passes all 16 complete outputs, with 249 ms medians for both roles and a 1.000×
ratio. Both datasets are retained; the repeat does not overwrite or retroactively
improve the first aggregate.

The exact-source [performance acceptance](../../selfhost/build/phase102/promotion04/performance-acceptance.json)
is complete with `accepted: true`. The coordinator accepts the corrected fold
behavior, retained application/list gains and improved B2 request screen, while
recording the upstream gaps, slight B1 slowdown and absence of a self-speed
claim. This is a finite measured release tradeoff, not universal speed or
correctness evidence.

## Completed default promotion and restoration

All nine [public CLI controls](../../selfhost/build/phase99/phase102-release04/public-cli/report.json)
pass. The [promotion preflight](../../selfhost/build/phase99/phase102-release04/promotion-check/report.json)
authenticates both stages, the exact source, CLI, capsule and performance
acceptance. The [atomic replacement receipt](../../selfhost/build/phase99/phase102-release04/promotion-apply/report.json)
records the new stable selection SHA256
`abcf83f679c38aacd21dc121dcc479337f9e4bd77001be8dbfa261da6ca20285`.
The old `0ec0287c…72fdf` pointer's exact bytes and permissions are preserved at
`phase102-release04/promotion-apply/previous-selection.json`.

The actual public entry was then invoked without `--selection`. Its
[default smoke](../../selfhost/build/phase99/phase102-release04/default-smoke/report.json)
passes, with all 94,160 C bytes and complete diagnostics equal to the admitted
B2 cached-small control. The raw request is
`selfhost/build/native/requests/20261017T001622Z-6nu6yhnr/report.json`.
No receipt from an explicit candidate03 invocation substitutes for this test.

Both [staged04](../../selfhost/tools/native/releases/phase102-staged04/receipt.json)
and [stable04](../../selfhost/tools/native/releases/phase102-assets04/receipt.json)
capsules are sealed and verified: 35 files each, zero missing. The stable receipt
SHA256 is `fadcf2ad594121d695acada6b3bb453c9b21000df1e03fde6e8e6c47e5e7d7e4`.
It preserves the actual default path; the staged capsule preserves its explicit
pointer path. Verification did not exercise an actual missing-file restoration.
The [current guide](../../docs/self_hosted/NATIVE_PHASE102.md) gives default use,
optional B1 selection, stable-capsule restoration and explicit lowering04 replay.
Consumed profile/launcher methods and historical capsules remain unchanged.

## Promotion-run time and evidence preservation

The [time account](../../selfhost/build/phase102/promotion04/time-account.json)
covers 2026-10-16 23:32:27 UTC through 2026-10-17 00:17:12 UTC: 2,685.073477
seconds (44 min 45 s) wall time. Its 1,739 recorded process intervals occupy a
union of 1,867.906627 seconds (31 min 08 s); 817.166850 seconds (13 min 37 s)
remain unclassified by those intervals. Overlapping intervals are not added as
elapsed time, and unclassified time is not labelled idle or implementation work.
This is the candidate04 promotion run, excluding the earlier campaign and later
documentation, archive and publication work.

The original 82,830,600-byte evidence archive and all candidate03 receipts are
preserved. The completed [incremental archive](evidence04/receipt.json) adds
11,200 files: 423,480,864 raw bytes compressed to 41,654,344 bytes. Every member
was read back and verified; all 34,940 baseline files remain byte/mode-identical,
with no missing baseline paths. Its receipt SHA256 is
`e17ec0dc172a174b51bd7d2a8c842a8b1848cd32fbb7f18243f0624ec0723856`.
The archive includes the new native chain, runtime samples, numeric repeat,
public requests, release capsules, methods and current usage guides. Reporting
documents are versioned in Git separately so this publication note does not
alter the frozen evidence inventory. See the [archive guide](evidence04/README.md).

No full-language, GPU, parallel compiler-host or universal program-speed claim
follows from these results.
