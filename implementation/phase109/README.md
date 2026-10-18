# Phase109 — structured ownership before machine lowering

Baseline `caee748`; [design](../../design/phase109/direct-owned-ir.md),
[usage](../../docs/self_hosted/OWNED_NATIVE_IR.md),
[replay](../../selfhost/tools/performance/phase109/README.md).

Implementation and small-kernel qualification are complete. Native selected-library
image acquisition is in progress; this paragraph will be replaced by its actual
outcome before the phase closes. Production compiler selection is unchanged.

## What changed and what we learned

The new Bend-written path consumes actual `NativeErasedBody` facts from the
existing checked frontend. It preserves ownership operations until Nx lowering,
then emits QBE directly. Explicit imports reuse the production heap/refcount
runtime; worker C is never an intermediate representation. Actual compiler
`nt_reverse<List<String>>`, unrelated Base `String.reverse.go`, and separately
checked discard/duplication functions exercise the path.

The decisive observation is that direct QBE and direct Clang initially had nearly
identical slow performance. The expensive boundary was our runtime interface.
After validating entry assumptions, trusted calls remove redundant per-node
checks. A generic take/build/tail fusion retains a consumed heap shell, reducing
allocation and transfer work without changing source algorithms. Shared and
static cases retain their conservative runtime behavior.

This supports structured ownership lowering as the migration direction. It does
not establish that adding SSA, replacing QBE, or removing cproc alone would make
the full compiler faster. The mature C worker already has an ordinary direct
loop; no per-cell continuation dispatch was eliminated here.

## Repeated runtime result

Five alternating rounds, 20 repetitions of 65,536 List<String> cells per round;
exact independent observations and zero-live-allocation checks on every call.
Graph setup, observation and release are outside the worker clock. Values below
are medians from `paired02`, not whole-program or full-compiler measurements.

| Worker | Time per round | Relative to production Clang |
|---|---:|---:|
| Initial direct QBE, checked imports | 67.36 ms | 4.78× |
| Initial direct Clang, checked imports | 67.63 ms | 4.80× |
| Direct QBE, trusted imports | 23.65 ms | 1.68× |
| Direct QBE, fused reconstruction | 19.52 ms | 1.39× |
| Direct Clang, same fused graph | 18.87 ms | 1.34× |
| Existing production worker, GCC | 12.96 ms | 0.92× |
| Existing production worker, Clang | 14.09 ms | 1.00× |
| Existing production worker, cproc/QBE control | 78.80 ms | 5.59× |

The fused direct-QBE worker is **3.45× faster than the initial direct-QBE
implementation**, and **4.04× faster than the matched cproc/QBE worker control**.
The latter uses the same exact runtime core but lacks Phase108 v3 accessor
expansions. It is not the Phase108 full compiler, an upstream comparison, or a
prediction of the full compiler's improvement. Production Clang can inline its
runtime in the same translation unit; direct emitters share a separately compiled
runtime object. That boundary is intentional and explicitly measured.

## Mechanism and remaining gap

[Machine evidence](evidence/machine-summary.json) and the
[runtime audit](runtime-audit.md) show six/five/three hot-loop calls in the raw,
trusted and fused QBE workers. Their worker sizes are 186/166/138 bytes. Fused
Clang uses the same three imports and is only about 3.5% faster in the repeated
comparison. Existing integrated Clang uses 775 bytes for its optimized worker.

The residual interface retains a tiny out-of-line tag accessor, a dynamic field
index, stack-stored extracted children, context scratch transfer and a separate
constructor helper. The next useful experiment is a typed multiple-result
ownership interface and preserved constructor constants. A new machine backend
would not remove this semantic work by itself.

## Correctness and scope

- 35 Nx structural/import controls, 28 ownership controls, 19 fusion controls.
- 38 admission controls: six authentic positives and 32 malformed/unsupported
  mutations. Before the shape/catalogue gate, 12 malformed inputs were accepted;
  all are now refused. Preserve `admission-before01` as a real rejected boundary.
- Five capture-interface controls, eleven runtime fail-stop controls and five
  positive lifetime/reconstruction controls.
- Three policies × three operation families × two direct backends × thirteen
  independent graph observations; nine additional production reverse profiles
  pass the same thirteen observations. Each case checks aliases after dropping
  the result, empty scratch and zero live heap words. Both suite01 and suite02
  pass; all nine QBE products are unchanged by the strengthened admission gate.
- Twelve matched full-C builds execute exact outputs across three source controls
  and four transport/backend configurations, including non-tail recursion.

The fixed runtime descriptor and checked source contract are part of admission.
Ownership validation is not a type/layout proof for arbitrary external inputs.
One CPU context is supported; the scheduler, GPU, closures, general calls, foreign
effects and full-language self-hosting remain outside this slice.

## Iteration cost, unsuccessful attempts and accounting

The checked Bend API builds in about 1.4 s. The full semantic suite takes 10.39 s;
the initial suite including three timing rounds took 23.48 s. The final paired
screen took 18.60 s. These clocks make backend/interface experiments practical
without rebuilding a compiler image for every edit.

Direct worker build observations with cached runtime are about 30–35 ms for QBE
and 48–53 ms for Clang. Runtime/harness acquisition is additional; production
whole-translation-unit build times do more work and are not a fair cold build
speedup denominator. Tiny full-C control builds likewise do not measure general
compilation speed.

Preserved rejected/setup attempts include an empty-facts capture caused by using
the wrong BookCache lookup; Bend structural/affinity syntax rejections; cproc
rejecting GNU allocator-alignment syntax (replaced with equivalent C11 alignment
for every comparison); the deliberately exposed admission mutations; and a
timing-summary key collision in paired01. The latter's executions completed but
summary failed; paired02 fixes the collector and is the reported measurement.

Root serialized target work on CPU3. Four agents prepared disjoint runtime,
lowering, library/validator and independent-control work; target execution stayed
with root. Disk cleanup authenticated archived Phase108 products before deleting
134,682,257 rebuildable bytes. No OOM, timeout, broad45 campaign or production
promotion is claimed. Billing/quota usage is not exposed by these tools.

## Decision

Continue toward direct structured IR, keeping cproc as the working full compiler
reference and bootstrap. Extend semantic coverage before deleting that fallback.
The next gate should cover general typed descriptors and ordinary calls, with a
compiler-hot scanner and a genuinely continuation-heavy computation. Preserve
ownership structure until machine lowering, compare against unchanged mature
native workers, and use the seconds-long loop before another full image.

Separate audits: [lowering](lowering-audit.md), [Nx](nx-audit.md),
[runtime](runtime-audit.md), [controls](controls-audit.md),
[native integration](native-integration-audit.md).
