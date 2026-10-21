# Phase117 — remove representation and fallback work from array loops

2026-10-21. [Design](../../design/phase117/array-facts-and-scalar-code.md) ·
[Measurements](results.json) · [Reproduction](../../selfhost/tools/performance/phase117/README.md) ·
[Evidence capsule](evidence/summary.json).

**Selected result:25.2% faster generated programs geometrically across the44 timed
members of the original45 corpus; up to5× on array workloads.** The matched
upstream-C gap falls from5.308× to4.240×. This is20.12% less execution time,
not parity. All405 original complete-output/count observations pass.

The source remains the compiler written in Bend. The measured programs are native
QBE executables emitted by its checked hosted development API. No new native
compiler image, B1/B2 native-chain speed claim or installed-default promotion is
made. Phase114 source02 remains the qualified native checkpoint. No PR comment
was posted.

## What changed and why it worked

Phase116 correctly identified a representation/fact gap. QBE was repeatedly
checking scalar cells, decoding immutable handles, moving results through scratch,
and eventually walking scalar cells as owning Terms. The existing certificate
already established scalar/unshared arrays; that information needed to survive
allocation, access, loop boundaries and destruction together.

1. **Reuse the existing packed32 runtime representation.** Additive descriptor
   capability3 selects the mature scalar-array implementation, including allocation,
   cloning, access and shallow destruction. Capability1 preserves uniform64.
   State/descriptor ABI layout and heap-word locations stay fixed. Shared cases
   retain `term_peek`; no unshared-runtime flag is enabled. Old runtime objects
   reject capability3. The cached runtime changes two capability declarations;
   it is still compiled once with GCC10-O2 and strict FP contraction settings.
2. **Preserve exact entry-handle facts.** A bounded analysis tracks full-word
   origins through copies, known private buffer slots, exact array result conventions,
   branches and every backedge. Unknown calls/writes invalidate memory facts;
   aliases and unsupported cases retain original guards. Pure base/mask/layout
   projection moves to entry; payload operations remain in semantic order.
3. **Version the whole loop.** When every access belongs to an invariant handle,
   the original raw/dynamic checks run once. A passing invocation executes a direct
   worker without internal fallback calls; a failing invocation calls the original
   complete guarded worker with the original arguments/output ABI. This removes
   cold joins and call-preserved scratch/live ranges from the hot machine loop.
4. **Expose facts across a small function boundary.** The general inlining body
   limit rises384→512; other argument/result/stack/growth limits stay unchanged.
   Edit distance's hot helper had391 nodes, just seven over the previous gate.
   Inlining lets the loop analysis see its accesses. No function/workload names
   participate in any admission rule.

[Source/proof audit](array-proof-audit.md) separates the original verifier's
assumptions from new analysis obligations. Original source-derived IR passes both
parent and candidate verifiers. These derived emission templates are not a new
formally verified backend. Checked source, finite analysis controls, independent
oracles, ABI controls and actual machine inspection provide separate evidence.

## Ablations and transfer

Three rotated serial rounds use the unchanged original50ms profile and complete
output/count evaluator. Each campaign has its own fresh Phase114/upstream roles;
rows below are ablations, not one simultaneous measurement. Units are milliseconds.

| Candidate | Fold128 | Edit distance |
| --- | ---: | ---: |
| Scalar checks removed, uniform layout | 429 | 348 |
| Packed allocation/access/destruction | 305 | 347 |
| Packed + metadata hoist v1 | 300 | 345 |
| Packed + corrected metadata facts v2 | 217 | 344 |
| Packed + inlining512 only | — | 282 |
| Packed + invariants + inlining + versioning | 136 | 110 |
| Matched final-pair Phase114 | 592 | 390 |
| Matched final-pair upstream C | 50 | 51 |

The v1 miss mattered: a fresh disjoint output allocation unnecessarily erased
knowledge of an earlier scratch store. SET metadata moved out of the loop, but
GET metadata did not. Preserving prior disjoint slots enabled both; emitted
machine code and runtime changed together. Branch intersections subsequently
retain only identical nonzero origins, allowing facts to survive scalar decisions.

The original45 campaign confirms transfer to related programs that were not used
for the first pair tuning. It is historical coverage, not a blind holdout.

Runtime reference binaries are the frozen Phase114 source01 corpus; source02
supplies the qualified parent and independent verifier. Phase114 documents its
namespace-traversal repair. These are not new matched N1/N2 measurements.

| Original45 case | Phase114 | Selected | Upstream C | Speedup |
| --- | ---: | ---: | ---: | ---: |
| editdist | 391 | 110 | 51 | 3.55× |
| local-pair | 388 | 109 | 50 | 3.56× |
| local-fold | 420 | 85 | 50 | 4.94× |
| variation-local-fold-8192-123 | 420 | 84 | 50 | 5.00× |
| variation-local-fold-128-0 | 587 | 136 | 50 | 4.32× |
| tree-bitonic | 336 | 335 | 50 | 1.00× |
| lexer | 340 | 338 | 47 | 1.01× |
| scalar-region-8192 | 107 | 107 | 50 | 1.00× |

Exact per-case samples in `results.json` govern rounding and interpretation.
The zero-work sentinel passes correctness but contributes no speed ratio.
Array versioning activates in eight programs. The scope of the gain is specific:
this general array transformation does not yet remove the ownership/continuation
costs of tree, map, text and other workload families.

A longer five-round closure recheck finds one real caution: `coverage-closures-64`
is604 versus586ms, about3.1% slower. The256 variant is618 versus625ms; its initial
small regression does not persist. Both generated QBE files differ from the old
ones only in the capability descriptor; a runtime/code-layout effect is plausible,
but not established mechanistically. Do not describe this candidate as universally
nonregressing or silently omit that case.

## Compiler cost, code size and iteration cost

One warmup and three alternating measured rounds compare complete hosted requests
from prepared Base. Every candidate QBE is byte-identical to its independently
verified/built broad emission, and outputs are stable across rounds.

| Request | Parent seconds | Candidate seconds | Change |
| --- | ---: | ---: | ---: |
| Fold128 | 4.140 | 4.295 | +3.7% |
| Edit distance | 6.217 | 7.692 | +23.7% |
| Lexer | 5.989 | 5.953 | −0.6% |

The three-request geometric cost increases8.46%. In edit distance, median lowering
rises3.566→4.271s and emission0.964→1.399s; verification also grows with the larger
IR. Thus faster generated execution is not automatically a faster research loop,
especially when a candidate is built and executed only briefly. These are hosted
API costs, not remeasured native N1/N2 compilation throughput.

Selected source grows50,590→51,056 physical lines:466 lines,0.92%,54 new helpers
and seven overridden parent declarations. The broad emitted QBE grows38,182,706→
39,079,507bytes,2.35%. Generated fallback workers and expanded inline regions account
for real code, not free abstraction. Unselected controls/prototypes are not part
of this source count.

The fast pair typically needs11s for a checked API,20s for emission and6s for
build/timing. Broad45 emission took282.49s, followed by115.13s build/timing. For
runtime-only experiments, the new authenticated object-relink harness reuses the
same QBE/object identities and still reruns all original output checks. Its full
45 relink/timing campaign took107.11s, avoiding repeated emission and assembly.
No mutable cache or autonomous search framework was introduced.

## What the new profiles say

Four unchanged-binary captures at8ms/13ms intervals pass output gates and have
zero lost/overrun samples:793 usable instruction-leaf samples total.
[Raw attribution](hotspots.json) and [machine loop](machine/version01-fold.asm).

- Fold:59.0% in the direct loop,28.2% in `blk_new`,5.9% in the operation dispatcher,
  and1.8% in generic destruction. Phase116 destruction was21.7%. These are sampled
  proportions, not direct estimates of absolute category speedups.
- Edit distance:353/354 samples are now in `$product.row`; the former separate
  cell boundary is gone from the hot computation.

The selected fold loop contains no calls or scratch-result traffic. Entry checks
and address/mask projection dominate entry; loads/stores use32-bit cells. The
remaining gap includes the actual kernel and initialization, while unrelated
program families still retain their distinct Phase116 ownership bottlenecks.

## Rejected or deferred attempts

- Boolean normalization removes ten normalizations in the scalar case but gives
  no meaningful runtime gain. Eight finite controls pass; exclude the added pass.
- General bounded unroll2 passes source checks,36 original observations, a60-point
  longer direct comparison and an ordinary0/1/3/17 iteration control. It adds
  6.0%,11.3%,11.1% on three folds and zero on edit distance. Keep it optional:
  limited broad contribution does not justify adding107 lines to the selection.
- Global cached-runtime GCC-O3 reduces fold128136→110ms, but worsens tree/map cases.
  No Bend/QBE bytes change. Reject global policy promotion.
- Requesting O3 only for the unchanged allocator retains the small-fold benefit.
  A complete405-observation follow-up passes, but geometric speedup over Phase114
  changes only1.25185→1.25830 (about0.5% relative), with new2–4% slowdowns. Its own
  matched gaps are5.351→4.253×. This does not justify another platform-specific
  build policy; keep the simpler GCC-O2 runtime selected. Do not combine its best
  point with the selected candidate's aggregate.

All failures are preserved in [failed-attempts.json](failed-attempts.json): source
composition/export/annotation mistakes, the first missed GET fact, and an ordinary
oracle schema mismatch. In the latter, actual output was exactly correct; the
Phase111 oracle used `exitCode` while Phase112 expects `status`. `controls02.json`
translates only that schema, preserving all expected bytes. A concurrent-lane
launch and a low-disk launch were refused before child execution; neither guard
was weakened. No failure/invalid-runtime probes were introduced.

## Correctness, provenance and selection

- Checked source/API and original independent IR verifier retained.
- 22 finite origin/branch/backedge/alias/refusal controls pass; these are executable
  analysis checks, not a proof of whole-compiler correctness.
- 11 ordinary array/owner/boxed/atomic controls pass for the selected candidate.
- Forced-slow ordinary fold/edit controls pass, exercising scalar/product fallback
  ABI. Fallback adds one wrapper frame per admitted direct-call level, not per
  loop iteration; full compiler/native-stack qualification remains outstanding.
- All405 selected original45 observations pass. Across selected and rejected
  experiments, independent replay checks1,198 observations with the original
  output/count/elapsed oracle; every non-sentinel interval is at least20ms.

Selected source SHA256:
`8010f9b5691a32f9b8d3a45da444e05b4bf4275fd1380e2acb122bfd2e53fec6`.
The [selection receipt](selection.json) binds source/API/runtime/controls and the
specific broad campaign. It is a reporting selection, not an installed release.
The capsule retains exact emitted QBE, assembly, profiles, outputs, receipts,
selected source and rejected attempts. Parent APIs, ELF/object files and toolchain
are separately pinned dependencies; recipes remain necessary to reproduce them.

Root used one guarded CPU3 execution lane,2GiB tree caps and16GiB available floor.
Two existing agents performed bounded source/audit work and no target execution.
54 target guards total1,188.92s (19.82min), including17.48s failed guards; maximum
recorded tree RSS is1,508,560,896bytes (1.405GiB). Remaining session time is design,
implementation, audits, artifact management and reporting; those categories were
not separately instrumented. Exact byte/mode hard-link dedup retains every frozen
path and content while recovering disk space. No prior result was deleted.

## What to do next

1. Target the broad untouched ownership cost: preserve borrowed observer results
   and typed ownership extraction across complete functions; use Phase116's hot
   map/tree/text sites and existing mature-C plans. This has more coverage headroom
   than another small array-loop pass. Shared RFC paths must remain correct.
2. Make profitable inlining/analysis cheaper: avoid repeatedly validating/rebuilding
   unchanged parts of expanded plans. First isolate edit distance's extra lowering
   and verification cost; do not generalize the measured hosted regression to N1/N2.
3. Integrate and qualify the selected source/runtime through the native chain when
   sufficient disk is available. Keep the qualified image until that gate passes.

This is progress toward a better optimization engine: new legal transformations
create useful alternatives that Phase115's policy search lacked, and object reuse
makes their evaluation cheaper. It does **not** demonstrate recursive research
acceleration: the compiler executable has not yet been replaced by a faster
qualified successor, and validated improvements per total research budget have
not been compared between controlled research loops.
