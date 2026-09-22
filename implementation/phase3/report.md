# Phase 3 implementation report

Phase 3 is integrated on top of the frozen phase 2 baseline from `f92d922`.
The design is [design/phase3/compiler_efficiency.md](../../design/phase3/compiler_efficiency.md).
The implementation adds measured fast paths while keeping the old checker,
diagnostic and isolated-worker paths available as correctness fallbacks.

The central result is a faster development loop with separate controls for
compiler work, validation startup and generated-program runtime:

| Area | Controlled evidence | Result |
|---|---|---|
| Exact diagnostics | Three alternating fresh-process samples of rejected `bytes_ops`, separately primed Base caches | Complete check 9.286 s → 0.728 s, 12.75x; identical result; positive control unchanged |
| Persistent typed validation | Three alternating eight-probe batches, including reversed order | Median 13.434 s → 11.607 s, 1.16x; exact observations unchanged |
| Persistent upstream validation | Same scheduling experiment with pinned TypeScript | Median 4.479 s → 2.049 s, 2.19x; exact observations unchanged |
| Annotation | Checked arity-128 application; three alternating uninstrumented repetitions | 2,256 ms → 24.4 ms; exact annotated core; synthetic phase measurement |
| String comparison runtime | Public `String.cmp`, exact runtime bytes, ABBA order | Equal ASCII 8.50x; late astral mismatch 4.11x; primitive microbenchmarks |
| Native annotation context | Three alternating synthetic 1,024-definition merges, including index construction | 1,693 ms → 85.8 ms, 19.7x; 165 exact comparisons and three checked C outputs |
| Bend source correctness | Complete assembled annotation/diagnostic source loaded and checked by frozen B1 | Empty checker error; 34.6 s load and 2:58.3 check |
| Runtime boundary behavior | 63,668 comparisons against checked pinned Base, including map/set ordering | All passed, including exact malformed Unicode errors |

The typed worker benchmark uses the checked named-ABI B1 artifact
`7740bc5a…`; it measures transport and startup reuse. The diagnostic benchmark
compares the frozen baseline B1 with a rebuilt candidate from pinned upstream.
Neither substitutes for measuring the combined self-emitted H artifact.
The full H fixed-point and broad conformance gates therefore remain required
before promoting a new default distribution.

## Combined compiler measurements

The final [small-workload comparison](final-small-compiler.json) passed all
96 exact outcome, emitted-byte and execution checks. It alternated historical H,
current H, current B1 and pinned TypeScript in three rounds on CPU1. All Bend
variants used one frozen current host, separately primed validated Base caches
and a shared output runtime; each compiler retained its own embedded runtime.
TypeScript had no serialized Base cache. The timings below are complete request
medians, including loading/checking/emission where applicable; module startup,
before/after identity checks and report IO are outside this request timer.

| Request | Historical H | Current H | Current B1 | Pinned TS |
|---|---:|---:|---:|---:|
| Tree, checked JS emission | 3.101 s | 3.141 s | 1.684 s | 0.392 s |
| List sort, checked JS emission | 5.963 s | 5.880 s | 2.993 s | 0.417 s |
| Bytes operations, exact rejection | 25.716 s | 2.228 s | 0.798 s | 0.359 s |

The combined H rejection path is **11.54x faster** on this case. Positive
compilation is effectively unchanged: current H remains 8.02x and 14.08x slower
than TS on these two request workloads. The synthetic annotation/runtime gains
do not imply a similar whole-compiler gain. Process-wall medians, which also
include benchmark supervision and identity work, are respectively 4.351/7.067 s
for current H positive emissions and 1.761/1.798 s for TS. The full request and
process results remain separate in the archive and
[reproduction recipe](../../selfhost/tools/performance/phase3/final-compiler-compare.md).

A [fresh checked-build and validation observation](evidence/cold-edit-loop.json)
completed in **36.350 seconds inside the tool**, including a 16.444-second B1
build and 16.348 seconds for 21 live paired frontend cases. The compiler-side
Base cache began absent. All nine checked-positive and 12 parse-negative witnesses
passed. This consumes an already assembled source and excludes Node startup;
OS caches were not flushed, and TS stayed loaded within the process. It is one
workflow observation, not a repeated speedup over phase2's earlier 40-second loop.
The build uses pinned upstream to emit the driver-facing B1 API, then runs the
Bend-written compiler for candidate validation. Its narrower export contract
and bootstrap route differ from asking H to reproduce the full compiler library.

The [live pinned TS full-source control](final-fullsource-typescript.json) passed
three serial fresh-process runs: **49.468, 49.647 and 49.636 seconds** inside the
compile timer, with a 50.062-second median process wall. Each run performed full
checking/ownership/closed-book gates and emitted identical TS bytes. The actual
current H classifier independently confirmed exactly 1,497 library roots. This
uses the same final source and canonical Base as the native and H runs, but the
runs were not paired or interleaved. The TS modules were copied unchanged to a
private location. Broader H exports include runtime helpers; equality of selected
roots does not imply identical default export sets or emitter output bytes.

The [final native workflow](native-final.md) compiles the same final source into
**exactly the same 1,131,553 JavaScript bytes** as B1 stage2, SHA `360bb62b…`.
Its single full-source observation took 287.315 seconds internally and 287.540
seconds including the outer process, on CPU0. The B1 stage2 run took 704.229
seconds on CPU3. Native is about 5.74x the separately sampled TS process median;
that descriptive ratio is not a same-core paired estimate. The native build's
checked JS/C emission took 40.655 seconds, followed by a 71.932-second cache miss;
a subsequent verified cache hit took 1.846 seconds. These preparation costs are
separate from compiler execution. Eleven native/JS cases and the updated
production validator pass. This proves native execution of the compiler emitting
JS, not a native-output fixed point.

## Implemented source changes

`src/check/annotate.bend` now recognizes a Ref/Var-headed application spine and
infers each intermediate function type once. It preserves the original
annotation shape and falls back to `ka_app` for every other application. The
operation-count probe that motivated this change measured the baseline growth
at depth 8, 16, 32 and 64 as:

| Depth | `ka_type` calls | `core_beta` calls | substitutions |
|---:|---:|---:|---:|
| 8 | 36 | 173 | 308 |
| 16 | 136 | 985 | 2,600 |
| 32 | 528 | 6,577 | 21,328 |
| 64 | 2,080 | 47,969 | 172,704 |

The [annotation differential](annotation-spine.md) checks 34 kernel-checked terms
and five source fixtures, including dependent types, erased arguments, alias and
variable heads, annotation barriers and explicit beta reduction. Annotated core,
emitted JavaScript and executed results match the frozen API exactly. At arity
128, `ka_type` calls fall from 8,256 to one, `core_beta` from 366,273 to 258 and
recursive substitution from 1,389,888 to 16,383. The separate uninstrumented
annotation medians were 2,256 ms and 24.4 ms. Telescope substitution is still
quadratic; this does not establish a 92x whole-compiler improvement.

The source overlay built successfully in 17.1 seconds; the integrated source was
then checked as a complete assembled compiler with B1. The combined frozen source is now undergoing a checked self-emission chain;
whole-H timings are separate from these component measurements.

The diagnostic path now has an exact-prefix replay entry. It independently
verifies exact cached-prefix identity, seeds the same normalization context, walks only
the unchecked suffix and reproduces the final open-law check. A mismatch falls
back to the legacy full diagnostic path. The loader records a request-local
`FLoadTrace`, including declaration-event counts, so origin lookup can use the
actual graph order instead of reloading and reparsing the graph. The host still
compares the detailed error with the authoritative checker error before
rendering it. The B1 check above validates the complete new Bend implementation;
the [diagnostic differential](diagnostic-reuse.json) adds 204 exact assertions
across 23 rows, including prefix mutations, Base seed invalidation, loader errors,
Unicode, imports, declaration events and complete host output. A standalone
22-module frontend/loader component also builds without diagnostic/checker modules.
The controlled [diagnostic benchmark](diagnostic-benchmark.json) records all
12 fresh-process samples and identities. Its negative-check speedup is 12.75x;
process wall including startup, before/after input hashing and report IO improves
6.21x. The positive `list_sort` control is 2.111 s versus 2.112 s.

The conformance harness has an explicit `--worker-mode persistent`. Adapter
contracts declare `persistentLanes` and `createPersistentSession`; the typed and
pinned-reference adapters currently allow parse/check only. Each request has a
fresh graph, work directory, deadline and response, and each worker is bounded
by request count and RSS. Queue commands and completions are bounded and
atomic, late FD3 notifications are ignored only when they identify a completed
request, and a crash or timeout kills the process group. Persistent session
history contains result digests and supports sequence-aware replay. The
isolated mode remains the default and is unchanged in its trust boundary.
The [worker report](persistent-workers.md) records 19 passing recovery/replay
tests and the controlled three-round comparison. Earlier measurements without
explicit cache preparation are superseded. Two pre-existing exact-diagnostic
failures remain failures in both modes; this experiment establishes mode parity,
not a fully passing selection.

`tools/performance/rapid/native-compiler-cache.mjs` adds a content-addressed
Clang cache for already checked C emission. The key covers C bytes and canonical
input path, preprocessed headers, the native build plan with output paths
normalized, the compiler executable hash and full version, optimization level,
relevant environment and both host tool hashes. Each lookup preprocesses the
input; a miss verifies the source, headers and compiler again after compilation.
It publishes the cached binary before its record while holding an exclusive
lock and refuses corrupt or locked entries. System linker and libraries must
remain stable: this is a host-local cache, not a hermetic toolchain.

A deterministic compiler fixture verifies miss/hit reuse, executable publication,
header changes, flag changes, executable changes with an unchanged advertised
version, lock refusal and corruption refusal. This caught and fixed a real
publication defect in the initial implementation. The [real Clang cache check](native-cache-actual.md) also passed on a checked
195 KB borrow/fork program: miss and hit produced byte-identical binaries, both
printing `2003000`. The single miss took 1.875 seconds including 1.573 seconds
of compilation; the hit took 0.238 seconds including header preprocessing.
All 157 observed header identities were retained and verified. These are single
correctness-run observations, not repeated whole-compiler benchmarks.

The JavaScript runtime comparison implementation is canonical in
`src/runtime/js/core.mjs` and `base.mjs`; `src/runtime.mjs` was regenerated by
the existing builder. It uses a single code-point walk, returns the existing
`String.cmp` pair shape, and validates malformed UTF-16 only when that code unit
is reached. The measured speedup is for generated-runtime execution, not a
claim about compiler throughput. The [exact-byte differential evidence](runtime-string-order.json)
and `selfhost/tests/runtime-string-order.mjs` make these measurements reproducible.
Final review caught a diagnostic mismatch in the first comparator: invalid scalar
values now reproduce upstream’s exact error text. The earlier ad hoc 17.3x kernel
measurement is superseded by the final-runtime ABBA measurements above. A controlled compiler-side String intrinsic
experiment was null: tree controls were 2.846 s, comparison override 2.845 s,
and all-string override 2.832 s; the source being compiled did not call those
primitives, while the B1 profile hotspot was already-emitted `String.eq`.

The [native backend changes](native-context.md) normalize each unchanged telescope
once per nonempty step and build one annotation index before context merging.
They retain first-match semantics for duplicate definitions, including `Absent`,
and use legacy lookup whenever a `BookCache` marker is present. An early overlay
violated that marker boundary; the differential gate caught it before promotion.
The retained rejected report explains the fix. Three checked fixtures emit exactly
the same C, and normalization counts fall from 32 to 16 for a 16-argument fill
or live-count calculation. These changes reduce compiler work; they do not change
native program code or establish a native execution speedup.

The frozen combined API is `8787894920cc8959ab0abec28ddae0ea0dc05ad7665dc6f4d43f845445e60923`,
from assembled source `936266643e95973709bac4b567289c5792decadbb3297f90018ed5052582d772`.
Its [checked integration build](evidence/native-context-integration-build.json)
ran pinned upstream loading, type checking, ownership, closed-book checking and
library emission explicitly in one process after synchronous child supervision
failed. It records the clean upstream pin and before/after source input hashes.
The previous bootstrap metadata supplying the module list and export names was
not itself included in that drift check; the report records the actual modules
and export names used. This is a checked integration report, not a bootstrap
sidecar or a claim that the ordinary bootstrap child succeeded.

Linux self-host resource validation now reads the current process's soft stack
limit from `/proc/self/limits`. This preserves the required 2:1 OS/V8 stack margin
while avoiding dependency on shell stdout delivery under process supervisors.
Other platforms retain the existing path. Regression coverage checks both the
admitted limit and refusal above the safety boundary before a report is created.

## Experiments that remain outside production

* [Checker suffix indexing](signature-index.md) gave 1.57x on 1,024 synthetic
  law/fill pairs, but only 182.9 → 168.2 seconds on one real compiler-source
  check. Eager scheduling adds work before early errors. The checked Bend overlay,
  exact randomized/error controls, patch and build recipe are retained; the
  production kernel is unchanged. Incremental scheduling is the next hypothesis.
* [Scalar specialization](../../selfhost/tools/performance/phase3/scalar-reassessment.md)
  made a checked arithmetic loop 1.41x faster and reduced tree compilation by
  6.69% in three alternating samples. However, a getter on the exported primitive's
  `.code` field changes exception behavior. All 8,400 ordinary boundary cases
  passed, but that counterexample blocks integration.
* [Emission analysis](emission-analysis.md) found no consistent benefit from
  replacing definition concatenation with fragment joining. Deep lambda emission
  does repeat substitution work: a disposable closed/application-free term cache
  reduced one depth-128 case from 70.40 to 18.11 ms, but gave no gain at depth 64.
  A generic absent-variable shortcut is incorrect because substitution also
  beta-reduces application nodes. A Bend representation change needs realistic
  workload evidence before promotion.

## Validation performed

The following checks passed:

* JavaScript syntax checks for all new/changed harness, adapter and cache tools.
* ABI, inventory, judge, selection, native-build, native-cache and persistent-worker tests.
* 21 native build-report identity/timing tests, including real cache-hit validator execution.
* Exact persistent-versus-isolated typed observations for six mixed fixtures.
* Complete B1 loading and checking of the assembled compiler source, with and
  without the application-spine overlay as separate controls.
* Candidate smoke checks for positive programs and the `bad-type` rejection,
  including exact diagnostic text against frozen H.
* 63,668 runtime comparator and map/set assertions against pinned Base, plus
  argument-ownership/trampoline regression.

The [combined component archive](components.md) covers core checking, frontend,
all ten JS backend suites, and 22 compiled/executed C programs. The original
suite reports 26/30 entries passing; its four failures are preserved. Explicit
supplements pass the same semantic assertions where subprocess pipe capture or
bootstrap-only metadata blocked the original harness. The 46 live paired
frontend witnesses pass. TCP/UDP remain unvalidated because even a minimal Node
listener is refused by this sandbox. File-backed child observations also verify
resource argument propagation.

Earlier root-supervised `spawnSync` attempts returned `EPERM`; those failed
attempts remain recorded. Separate local subprocess validation passed all 19
persistent/targeted tests, including existing isolated replay. The bundled Clang
16 toolchain passed the real miss/hit and executable-output gate.
The integrated H fixed point remains a release gate.

## Remaining work and interpretation

The combined source/API/runtime/host are frozen for the checked stage2/stage3
self-emission proof. Combined component and small-workload comparisons have
completed; the full frontend sweep and the H reproduction stage are still running.
Until those gates finish, no new default distribution is promoted and no combined
whole-compiler speedup is claimed. Full language conformance remains a separate
objective; existing exact-diagnostic failures remain failures.

For ordinary iteration, use the checked B1 component build and targeted
parse/check workers. Run a full self-emission chain after a coherent batch of
compiler changes, using immutable inputs. The native cache removes repeated C
builds after checked emission; it does not replace source checking. This keeps
expensive reproduction proof out of each edit/test cycle without treating a
partial gate as a release proof.
