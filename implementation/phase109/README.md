# Phase109 — structured ownership before machine lowering

Baseline `caee748`; [design](../../design/phase109/direct-owned-ir.md),
[usage](../../docs/self_hosted/OWNED_NATIVE_IR.md),
[replay](../../selfhost/tools/performance/phase109/README.md).

The direct ownership slice and its native selected-library frontend are
implemented and qualified. Production compiler selection is unchanged; cproc is
retained for full-language bootstrapping, not used in this slice's ordinary
source-to-QBE requests.

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

Fused-QBE round times range from 19.40 to 19.65 ms; production Clang ranges
from 13.97 to 15.60 ms. Five rounds support a useful local screen, not a broad
performance distribution. The trusted policy changes both checks and immediate
discriminant reuse, so their individual contributions are not isolated.

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

## Native Bend frontend qualification

The native entry appends the same owned/Nx modules to the selected mature Bend
compiler, renaming only its old main. It calls the unchanged `p86_plan`, obtains
real `NativeErasedBody` through `ns_body`, and executes the new lowering and QBE
emitter in native Bend. The frontend is not the earlier scalar-only substitute.

`native-source02` checks and emits through the existing native B2 in 111.79 s;
its C/cproc/QBE image build takes 38.52 s. Peak process-tree RSS is about 1.0 GiB
and 2.1 GiB respectively. This approximately 150-second acquisition is a one-time
cost, not paid for each worker edit or request, and not a B1/B2 self-hosting metric.

`native-qualify01` completes in 9.73 s:

- All nine source-contract/policy combinations emit exactly the hosted QBE bytes,
  followed by the one documented newline from `IO.print`.
- A live-Base request matches cached preparation; the IR JSON functions also
  match the independently hosted products.
- Changed source, wrong source contract, unknown policy and unknown format all
  reject with the expected status and diagnostic.
- A fresh QBE/as/link build from the actual native-produced text passes all
  thirteen runtime observations and lifetime checks.

Cached selected requests take 0.528–0.544 s in this finite qualification run;
the live-Base request takes 3.094 s. These are single process observations, not
paired compilation comparisons. The authenticated convenience interface is
`native/emit.py`; its actual request and exact output pass `native-public01`.
The raw native image also runs directly without Python. No Bun, Clang or cproc
runs on either ordinary source-to-QBE request path.

The image deliberately accepts only the frozen source texts and fixed runtime
entry contracts. Native erasure alone does not prove an arbitrary polymorphic
function's external representation. General typed ABI admission is a next gate,
not a capability inferred from passing these selected source contracts.

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

The experimental implementation adds 568 physical Bend lines for ownership
model/lowering/admission/verification/policies, 231 for library imports and its
comparison C emitter, and 90 for the native entry: 889 lines excluding controls.
It reuses the existing Nx model, verifier, optimizer and QBE emitter. The runtime
adapter is 242 C lines plus a 46-line header. Host tools transport data, invoke
tools and compare observations; compiler transformations remain in Bend. This is
additive research code, not a reduction of the production compiler's line count.
Production conformance and B1/B2 compilation metrics are unchanged/unremeasured.

Preserved rejected/setup attempts include an empty-facts capture caused by using
the wrong BookCache lookup; Bend structural/affinity syntax rejections; cproc
rejecting GNU allocator-alignment syntax (replaced with equivalent C11 alignment
for every comparison); the deliberately exposed admission mutations; and a
timing-summary key collision in paired01. The latter's executions completed but
summary failed; paired02 fixes the collector and is the reported measurement.
The first native entry also lacked an explicit `NxLibrary` annotation; checking
refused it after 40.25 s. A small fixture with exact interface signatures and
explicitly mocked semantic bodies was then used only for entry typechecking.
Its first invocation incorrectly requested an IO API export; the corrected
non-IO export passes. Actual native semantic qualification uses the real frontend,
not these mocks. A fixture-preparation receipt error is retained separately.

Root serialized target work on CPU3. Four agents prepared disjoint runtime,
lowering, library/validator and independent-control work; target execution stayed
with root. [Guard accounting](evidence/accounting.json) records 34 guarded jobs
and 311.0 seconds (5.18 minutes) of occupancy, including failed attempts; this
excludes agent work, editing, inspection and evidence sealing. The phase took
roughly forty minutes of wall time. Disk cleanup authenticated archived Phase108 products before deleting
134,682,257 rebuildable bytes. No OOM, timeout, broad45 campaign or production
promotion is claimed. Billing/quota usage is not exposed by these tools.

The [evidence manifest](evidence/manifest.json) binds the compressed observation
capsule, including failed runs, source/runtime snapshots, generated IR, native
image acquisition and every final observation. The separate machine capsule
preserves full disassemblies without filling source review with generated text.
All 1,911 members of the 10.90 MB observation capsule were reread and verified
against their exact sizes and SHA-256 identities before publication.

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
