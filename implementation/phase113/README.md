# Phase113 — whole functions, products and machine-value facts

**Generated programs improved; parity and native integration are unfinished.**
Candidate31 passes all 270 broad output/count observations. Across the 44 timed
points of the original 45-program corpus, its geometric-mean slowdown is
**7.088× upstream**, compared with the previous facts baseline's **15.943×**:
a 2.249× normalized improvement, or 55.54% less time. These are separate controlled
campaigns on the same frozen corpus/profile. The paired six-development-case
comparison improves 6.505×, from 37.206× to 5.720× upstream.

All 80 ordinary regression jobs pass. Full compiler acquisition, however, hits
the 600-second limit during lowering, so no candidate31 native N1/N2 is qualified.
Phase112 facts remains the qualified native checkpoint; installed production
selection is unchanged. This phase improves generated code, not every metric.

The [design](../../design/phase113/qbe-program-parity.md) separates generated
program runtime, native compiler request time, image construction, conformance
and source complexity. The frozen Phase112 facts baseline takes 15.943 times
upstream time over 44 measurable broad-corpus points; the six-case development
screen below is a different denominator.

## Findings

**Preserve complete functions before constructing runtime continuations.**
The Bend-written path reuses the checked/erased core, mature ownership decisions
and generic fallback, but retains ordinary calls, local joins and self-tail
loops. In the first admitted scalar loop, seven static frame sites disappeared;
the body fell from 18,636 to 6,473 bytes, with seven ordinary calls remaining.
The [reachable-call witness](../../selfhost/tools/performance/phase113/direct/structural-witness08.md)
distinguishes this from emitting an unused optimized function.

**Flatten products before allocation, then optimize the exposed bodies.**
Explicit result vectors and caller-owned output slots remove temporary array
result tuples. For the same two local-pair workload evaluations, diagnostic
allocations fell from 657,030 to 126; continuation frames fell from 262,727 to
59. Term keeps remained around 525,000. These are overlapping event counts,
not CPU shares. [Counter receipt](../../selfhost/build/phase113/four-role-counter-summary01/report.json).

**Keep ownership and machine-value facts distinct.** Mature match-field masks
and a full-width Nat immediate kind remove trivial ownership operations without
narrowing Terms. Canonical Succ extraction removes a helper/scratch round trip.
The [exact ray comparison](interim03/files/003-ray16-static-delta.json) accounts
for the entire inline15-to-shared16 QBE change as 111 successor replacements
across 12 functions. It establishes a static transformation, not a dynamic
call count or isolated runtime attribution.

**Compose bounded inlining with operation-derived facts.** Scalar and product
inliners preserve ordered ownership operations, argument snapshots, parallel
result transfer and fresh namespaces. Range facts derive from actual machine
operations, not scalar ownership tags. Simplifying completed callees before
table insertion avoids solving every admission boundary by increasing limits.
Guarded array emission, array-handle identity and a separately admitted stable
heap-base path expose further work while retaining conservative fallbacks.
The [experiment records](../../experiments/phase113/P113-004-operation-derived-range-facts.md)
and [composition record](../../experiments/phase113/P113-005-bottom-up-and-array-identities.md)
retain the intermediate scopes and gates.

All compiler passes and new rendering rules are implemented in Bend. Host tools
transport checked requests, supervise builds and collect independent evidence;
they do not perform semantic lowering. The array-result runtime extension
retains the original array representation and underlying ownership operations.

The 1× plan's complete-function and local-loop work is implemented and exercised
on ordinary programs. The 10× extension delivered flat products, typed facts and
composable bounded optimization. Full native integration remains blocked by
lowering cost. The 100× shared cross-backend optimization foundation and
self-optimization research loop were not completed; these labels described
ambition levels, not promised numerical gains.

## Three-round development runtime comparison

All five roles used the same frozen workloads, repetition counts, CPU3 affinity,
one worker, GPU off, and full-output/count checks. Values below are medians in
milliseconds, not compiler request times. Upstream products use the pinned
TypeScript compiler's C backend and Clang-O3; our products use direct QBE.

| Program | Upstream | Frozen facts | Heap22 | Width30 | Selected wide31 |
|---|---:|---:|---:|---:|---:|
| Scalar-region8192 | 16 | 177 | 39 | 33 | 33 |
| Local-pair | 15 | 2,143 | 157 | 126 | 118 |
| Edit-distance | 15 | 2,157 | 157 | 126 | 118 |
| Active ray256 | 15 | 922 | 135 | 133 | 127 |
| Lexer | 14 | 211 | 111 | 110 | 108 |
| Closures256 | 15 | 189 | 63 | 63 | 63 |
| Geometric mean relative to upstream | 1.000× | 37.206× | 6.565× | 5.909× | 5.720× |

The graded receipt is `selfhost/build/phase112/p113-final31-screen/phase113-report.json`.
All 90 complete-output observations passed (six cases × five roles × three
rounds). The profile targets roughly 15 ms upstream batches and uses a 1 ms
clock, so small nearby differences remain unresolved. These development cases
are selected and overlap workload families; the original45 survey is separate.
The wider policy is slightly faster here, but its aggregate advantage over
normal width30 is only about 3.3%, so it is not a large independent result.

## Original 45-program survey

The checked API31 compiled all original frozen batch sources through the Bend
array/direct-QBE pipeline. The unchanged broad runner then measured candidate
and upstream in three rotated rounds: all 270 complete outputs and success
counts passed. Forty-four points contribute ratios; the zero-work control is
correctness-only. CPU3, one worker, GPU off, inputs, repetition counts, source
oracles and the 50 ms upstream profile are unchanged.

| Program/input | Previous facts / upstream | Candidate31 / upstream |
|---|---:|---:|
| Scalar-region8192 | 11.780× | 2.130× |
| Edit-distance | 142.784× | 7.358× |
| Local-pair | 139.137× | 7.760× |
| Active ray256 | 60.039× | 8.294× |
| Lexer | 13.569× | 7.638× |
| Tree-bitonic | 10.585× | 11.120× |
| List pipeline128 | 14.080× | 14.265× |
| Geometric mean, all 44 timed points | **15.943×** | **7.088×** |

[All 45 rows](broad-runtime.csv) and [derived metrics](results.json) preserve the
denominators. The 38 points outside this phase's actual six development cases
average 7.349× upstream. They are historical workloads, not unseen research
holdouts. The runner's inherited `phase112Heldout` label names a different six/38
partition and must not be relabeled as Phase113's partition.

The catastrophic array-product gaps narrowed substantially. Several tree/list
cases are little changed or modestly slower; the largest remaining ratio is
14.265× on list-pipeline128. Thus the gain is not universal, and three rounds
do not establish a confidence interval or justify strong small-percentage
claims. Upstream-normalized old/new ratios compare separate campaigns; the
within-campaign six-case comparison provides stronger paired evidence.

This survey uses the checked hosted compiler API, not candidate31 N2. Native
products are real QBE/as/link executables, but their compiler host was Bun.
Acquisition and execution clocks remain separate. The first 360-second build
guard completed 33 products including six reused builds; a fresh continuation
completed the remaining 12 in 137.361 s. Authentication plus the runtime campaign
took 114.157 s. The partial attempt is retained and is not marked successful.

## Correctness failure and current correction

Branch24 reduced Boolean-control code but failed the original local-pair
complete-output check. Its screen stopped incomplete, so its partial timings
cannot support a performance claim. Exact source admission and finite checks
did not establish native correctness.
[Failure receipt](../../selfhost/build/phase112/p113-branch-screen24/report.json).

The current correction makes the Boolean result width explicit: recognized pure
1/0 diamonds normalize the condition to a U32 Boolean and zero-extend it into
the original U64 destination. A separate narrow arithmetic renderer handles
only proven low32 operation/mask patterns and also emits explicit extension.
The original QBE source and toolchain are unchanged. Custom minimal diagnostic
attempts were aborted or inconclusive; the ordinary complete local-pair output
is the authoritative correction gate. See
[P113-006](../../experiments/phase113/P113-006-explicit-machine-widths.md).

Source30 uses the normal inlining policy; source31 is a parallel wider-policy
variant with the same width correction. Each has its own six-program build and runtime observations. Candidate31 also
passed the six extra field/array fixtures and twelve original native controls.

| Gate | Observed status | Record |
|---|---|---|
| Source30/source31 APIs | Checked, complete | [30](../../selfhost/build/phase111/p113-width-api30/report.json), [31](../../selfhost/build/phase111/p113-wide-api31/report.json) |
| Bool normalization | 112 focused controls passed | [Controls](../../selfhost/build/phase113/bool-width-controls01/report.json) |
| Machine-width arithmetic | 22 structural controls and 128 native observations passed | [Controls](../../selfhost/build/phase113/width-native30/report.json) |
| Exact source/runtime composition | Admitted bytes; not semantic qualification | [30](../../selfhost/build/phase113/array-composition-admission30/manifest.json), [31](../../selfhost/build/phase113/array-composition-admission31/manifest.json) |
| Ordinary source30/31 campaign | Complete: all 80 jobs passed | [Batch](../../selfhost/build/phase113/width-wide30-31-native/report.json) |
| Matched current-candidate runtime | Three rounds, all 90 outputs passed | [Candidate31 product map](../../selfhost/build/phase113/wide-bench-plan31-reports.json) |
| Full hosted compiler acquisition | Stopped at the 600 s job limit during lowering; no N1 produced | [Receipt](../../selfhost/build/phase113/p113-final31-qualification/report.json) |
| Native self-emission/successor | Not run: predecessor acquisition did not complete | [Native plan31](../../selfhost/build/phase113/native-final31-plan.json) |
| Broad 45-case native-generation campaign | Not run: requires qualified N2 | [Broad plan31](../../selfhost/build/phase113/native-final31-batch45-plan.json) |
| Broad 45-case hosted compilation and native execution | All 45 products authenticated; all 270 observations pass | [Final receipts](evidence/final31/manifest.json) |

Full control rows and preserved failures belong in the evidence archive, rather
than an undifferentiated pass total. Earlier finite tests include 148 fact/product
rows, 78 range groups with 483 observations, independent inliner trace checks,
and owned/shared native fixtures. These establish their recorded scopes, not a
whole-compiler proof. [Interim02](evidence/interim02/index.json) and
[interim03](interim03/index.json) retain those receipts and limitations.

## Complexity and campaign accounting

| Assembled source | Physical lines | Nonblank, non-comment lines | Bytes |
|---|---:|---:|---:|
| Frozen facts baseline | 44,389 | 31,709 | 2,028,063 |
| Candidate31 | 48,839 | 35,010 | 2,232,290 |

Counts were read directly from the source files pinned by the
[source31 manifest](../../selfhost/build/phase113/wide-source31/manifest.json).
Physical lines use `splitlines()`; the nonblank count excludes blank lines and
lines whose first nonspace character is `#`. These are assembled-source counts,
including embedded control helpers, not production-only implementation size.
The increase is 4,450 physical lines (10.03%); this campaign is not a large
LOC reduction. Keep standalone controls, transports and archives separate from
that denominator.

The sequence was design/freeze at 18:07, complete-function/product gates during
the first hour, range/composition evidence through source19 around 19:37,
branch24's semantic rejection around 19:48, then source30/31 checking and focused
width gates around 20:39–20:43. All target work remained in the coordinator's
serial CPU3 lane. Exact-byte deduplication recovered 1,051,717,632 allocated
bytes without deleting artifact paths. The frozen
[time account](time-account-checkpoint.md) measures 47m00.404s of finalized guard
coverage through the native timeout, including 11m31.772s in unsuccessful guards.
The 44m42.201s uncovered interval around the interruption is left unattributed;
elapsed time is not a measure of active agent work. The later broad run is
separate from this checkpoint.

Including the three broad acquisition/measurement guards, the final union is
3,431.946 s (57m11.946s) across 76 finalized guards. Nested stage timers are not
added to this total. The [final account](results.json) records the additional
receipts; this measures guarded wall occupancy, not CPU time, quota or authoring.

## Reproduction and committed evidence

The [selected recipe and commands](../../selfhost/tools/performance/phase113/README.md)
identify source31, the checked API, runtime and prior frozen dependencies.
[Selection](selection.json) explicitly records experimental status and failed
native promotion. All 106 ordered module/override entries are tracked; no host
language implements the new semantic transformations.

The [final manifest](evidence/final31/manifest.json) and
[compressed receipts](evidence/final31/receipts.tar.gz) preserve 246 exact JSON
files in 1,149,834 bytes. Original absolute paths identify receipt provenance;
the archive contains those JSONs, not the external compiler/API/ELF products.
The ledger records 2,848 verified external references and one earlier live guard
snapshot in the frozen time account that has since changed to its final receipt.
No missing reference is hidden. The first collector attempt
misresolved interim03-relative paths; the final collector resolves that capsule's
declared index-relative paths and retains the original attempt locally.

Capsule completeness means the selected evidence was copied. Its
`nativeQualified:false` remains authoritative. Earlier
[interim02](evidence/interim02/index.json) and [interim03](interim03/index.json)
preserve the development history and failed controls. No PR comment was posted.

## Full-compiler scaling limitation

The final source31 hosted acquisition stopped after 600.764 guarded seconds.
The frontend completed in 204.208 s, preparation in 1.484 s and runtime admission
in 0.093 s. Lowering then remained unfinished for approximately 394 seconds.
Peak process-tree RSS was 3,974,184,960 bytes, below the 4 GiB cap; the recorded
failure was the per-job time limit, not an out-of-memory termination. No full
QBE module, N1, N2 or new native compiler-request ratio was produced. The source
check passed; native self-hosting qualification did not.

The next step is to isolate this scaling regression. The older facts acquisition's lowering was
about 31 s, but its source and pipeline differ, so that is context rather than
a controlled pass-cost attribution. Both the inliner and range optimizer verify
their full inputs and outputs inside lowering, in addition to the explicit final
verification stage. Whole-program planning, repeated scans and expanded bodies
may also contribute. Their individual costs have not been measured here. The
[source audit](../../selfhost/tools/performance/phase113/direct/scaling.md)
identifies repeated product-suffix construction and fact-map joins, and gives
an ordinary staged timing experiment that preserves every verifier.

The qualified Phase112 facts integration therefore remains the native checkpoint.
Faster generated development programs do not establish a faster compiler, and
the Phase113 candidate is not promoted over that checkpoint.

## Next experiments

1. Isolate whole-function planning, inlining, range propagation and verification
   on the same checked compiler request, beginning with bounded source sizes.
   Look for repeated whole-program work and superlinear growth before another
   full acquisition. Preserve the final independent verifier.
2. Preserve array descriptor and immutable-handle facts across row loops. The
   current cell still has guarded accesses and substantial stack traffic; merely
   increasing the inline limit does not remove those obligations.
3. Recognize generic signed-shift and Boolean identities. The scalar hot loop
   now has no machine calls or negative-rbp spills, but still has 121 assembly
   instructions versus roughly 40 in the upstream loop.
4. Explore flat tagged state and narrow destination-passing for constructor
   spines. Lexer state allocation and non-tail String reconstruction survive
   the current product optimization.

The [remaining-code audit](../../selfhost/tools/performance/phase113/direct/remaining.md)
separates observed static code from unmeasured speed hypotheses. Parity has not
been reached. Do not remove guards, weaken output gates or promote partial
bootstrap results to make the figures look better.
