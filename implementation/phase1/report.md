# Phase 1 implementation: faster checked bootstrap

Status: validation in progress. This report will be completed before publication.

## Implemented scope

The [design](../../design/phase1/faster_bootstrap.md) identified repeated host work,
expensive generated calls, primitive dispatch and missing backend indexes. This
implementation addresses those concrete costs without changing the dependent
checker or moving compiler algorithms into JavaScript.

| Area | Change | Preserved contract |
|---|---|---|
| Measurement | Explicit compiler/runtime/host selection, immutable input hashes, separate cache modes, raw per-phase and process measurements | Full checking and output validation; failures remain failures |
| Parsed source | `FParsedSource` carries the discovery parse into graph loading and main-name reporting | Raw `FSource`, import/alias/cycle/error behavior and seed fallback |
| Backend context | `book_context` prepares one index after specialization and reuses it in annotation, layout and emission | Immutable first-match lookup, fresh-binder bound, full type context |
| Repeated selections | Reuse full JS roots/stops within the invocation | Annotation retains its existing full-context call; native selection remains separate |
| Primitive dispatch | Preserve Base `String.contains`, `starts_with`, `reverse`, `is_empty` | Same intrinsic classification for reachability/emission; user definitions preserved |
| Choice calls | Structurally prove Boolean/Unit choice and inline fully applied literal thunks | Condition/branch order, partial and dynamic arguments, erased slots, trampoline |
| Record accessors | Prove complete live-field matching and select one field through a direct worker | Generic ABI, field-copy/read order, function fields; eta-short/effect/erasure fallbacks |
| Matcher initialization | Cache pure top-level matcher wrappers | Delayed arm bodies, live globals, computed initializer effects and application order |
| Deep closures | Keep factory-marked thunks on the generic call path | Existing depth protection and lexical captures |

An intermediate CPU profile attributed about 31% of samples to generic `apply`,
with further time in forcing, matching and global initialization. Record accessors
were repeatedly passing through those paths. That observation motivated the
projection worker; it is not a speculative argument-array ownership change.

The original compiler artifacts, source snapshot, baseline measurements and tag
remain historical evidence. The new compiler must earn its own compatibility and
fixed-point evidence. The complete implementation remains under `selfhost/`.

## Why these changes reduce work

The host previously parsed a file during import discovery and then supplied its
text to a loader that parsed it again. The new
[`FParsedSource`](../../selfhost/src/load/modules.bend) carries that first parse
through the existing source ABI. Graph qualification, validation, alias handling
and binder freshening still run. This saves a parse, not a check. Differential
loader cases compare complete results and errors; two emitted fixtures preserved
bytes before introducing the intentional backend changes.

[`book_context`](../../selfhost/src/core/index.bend) prepares the existing
persistent name index and fresh-binder bound after specialization. The host
passes this full context into annotation, layout and selected emission. The
selected output list remains separate from the lookup context; pruning must not
remove type or constructor information needed by later phases. The immutable
index is reused only with its own book.

[`choice.bend`](../../selfhost/src/back/js/choice.bend) replaces the repeated
construction and application of literal branch thunks with a conditional after
proving the combinator's body. It retains factory-marked closures on the generic
path. [`projection.bend`](../../selfhost/src/back/js/projection.bend) emits 66
one-argument record access workers in the final compiler, retaining the runtime's
field copy. Pure matcher-wrapper caching removes another initializer/force path;
it does not cache arm results or computed initializers. These changes reduce the
cost of the compiler executing its own generated JavaScript.

The final assembled source is 557,709 bytes across 59 modules. It contains all
1,391 original definitions plus 21 support definitions. No declaration or checker
stage was removed to improve a timing. Component verification passed all 19
groups, and the orchestration/harness suite passed its 23 existing tests plus
three new merge-safety tests and an explicit worker-resource propagation test.

## Checked self-hosting result

The final bootstrap API emitted stage 2 in **767.922 seconds** (12.80 minutes).
Stage 2 then fully checked and emitted the same frozen source in **2,366.759
seconds** (39.45 minutes). The two outputs are byte-identical, SHA-256
`44227e5e9aa714682c3a5f042cbf38fce86cc6bc510265aeda75103ed242579a`.
The chain completed at 06:45:16 UTC on September 21, 2026; its two checked
compilations took 52.24 minutes in total. This is the changed-source correctness
proof, not the same-source speedup measurement.

The [distributed artifacts](../../selfhost/dist/phase1/README.md) include the
bootstrap API, self-emitted API, frozen source/map, runtime and provenance.
The [fixed-point report](evidence/fixedpoint-final.json) records launch arguments,
source/runtime/host hashes, both successful exits and both output hashes.

## Correctness evidence

Focused checks cover parsed-source equivalence for valid, aliased, repeated,
cyclic, missing and malformed modules; indexed context idempotence; 4,004 new
string comparisons against pinned Base; user overrides; partial calls; computed
thunk evaluation; both Boolean branches; 50,000 tail calls; and 70 nested choices
with captured values. The existing component, backend, foreign-function, layout,
provenance, string-equality and argument-ownership regressions also run.

A first candidate build was deliberately interrupted during checking after code
review found that choice inlining could bypass the existing closure-depth guard.
The corrected candidate has a dedicated regression. An intermediate stage 2
then passed focused and backend checks and supplied the CPU profile. Its second
build and partial corpus run were stopped after the profile motivated projection
workers, freeing resources for the final candidate. These interrupted attempts
remain separate and are not completed fixed points or performance samples.

The projection-worker candidate subsequently completed a byte-identical stage
2/stage 3 fixed point (SHA-256 `bbf05713efe49dca6f4d9716d59d23c8f57e1aa2f864311aee3afe97590e04fe`). Its native `base/string_kit.bend`
probe exceeded the existing 300-second limit, including a repeat on a dedicated
physical core. That failed gate prompted pure matcher-wrapper caching. The
partial 408-probe corpus run and both timeouts remain separate evidence; neither
is counted as completed final validation. The final candidate passed this probe in **246.908 seconds**, with the
unchanged 300-second limit. This is regression evidence, not a controlled
old/new native benchmark. The filtered report correctly remains incomplete as a
whole-corpus conformance claim.

The final corpus is partitioned into 64 disjoint fixture groups, with unchanged
300-second per-probe deadlines. Historical probe durations guide scheduling only.
The merger checks every expected `(fixture, lane)` exactly once, identical
inventories and artifact hashes, and unchanged timeout policies; it retains every
verdict. Raw group reports and their checksums accompany the combined report.
An initial two-worker run was stopped to adopt this scheduling; its partial rows
are excluded, not mixed with later outcomes. The first shard attempt then exposed
a configuration error: workers used Node's default stack rather than the 4 MiB
stack already used for self-builds and measurements. The large cubic literal
fixture exhausted that default stack. The runner now accepts explicit worker
stack and heap limits and records them; the full run uses 4 MiB and 4 GiB, with
the same 300-second timeout. The previously failing cubic-literal fixture passed checking in 99.091 seconds
with the documented stack. Default-stack results remain separate failed
evidence, not candidate passes.

## Measurement protocol

All comparisons use pinned upstream `6018e28ecc67cf1fffc0c20c64b11023474c2df8`,
Node 24.18.0, the same source and Base paths, fresh processes and CPU affinity 2.
Small workloads use a 4 MiB JS stack and 4 GiB old-space ceiling; full compiler
runs use the same stack and a 12 GiB ceiling for both control and candidate.
Compilation excludes imports, output-file writing and generated-program execution;
process wall time and import latency are recorded separately. Peak RSS is a
process high-water mark, not per-phase allocation.

The original five workloads are retained. The matrix includes pinned upstream,
old/new upstream-emitted Bend APIs and old/new self-emitted Bend APIs. Seven
repetitions rotate variant order. Separate cold/warm Base-cache comparisons use
the tree/IO input; scaling adds 64 and 1,024 declarations around the original 256.
Cache priming is a separately recorded invocation. Full-source comparison uses
the exact archived compiler source on both sides; rebuilding the changed source
is a separate correctness proof.

This is a shared development machine, not an isolated performance lab. The long
control ran while development and candidate verification used other cores. One
short backend test batch used the control core's SMT sibling. Intermediate
validation used other cores, including SMT siblings. Final validation begins on physical cores 0 and 3, while its self-build uses
CPU 1 and benchmark processes remain serial on CPU 2. Disjoint fixture groups
add CPU 1 after the self-build and final profile, and CPU 2 after measurements
finish. The scheduling log records every assignment. The corpus avoids SMT
contention between its workers so that per-probe deadlines remain meaningful. Memory bandwidth,
shared caches, GC scheduling, CPU frequency and unrelated host activity remain
sources of variation. A single full-build measurement is descriptive, not a
statistical confidence interval or a cross-machine comparison.

## Small-workload phase evidence

Across seven uncached Base samples, the old/new self-emitted median compilation
is 43.979 / 17.608 seconds (**2.50×**). The combined changes reduce median graph
loading from 12.109 to 2.507 seconds, checking from 16.265 to 8.637 seconds, and
stop-set construction from 4.617 to 0.006 seconds. Preparing the indexed context
costs 0.305 seconds. These are per-phase medians, which need not sum to the median
of complete invocations; they are not independent optimization multipliers.

The public `f_parse` count remains two (program and Base). Reuse removes the
loader's internal reparsing. Full-root computation drops from two public calls
to one, and full-stop computation from three to two. The stop-set classifier calls `String.contains` on its intrinsic-name table;
that operation now retains its audited native implementation in the self-emitted
compiler. Its timing reduction therefore includes the repaired primitive path
and generated-worker improvements, rather than just one fewer traversal.

The original 3× uncached-program target is **not met** on this workload. Parsing
and checking now account for most of its remaining time. This does not justify
weakening checking or changing the benchmark to hide first-use cost.

## Full-source control

The local control compiled the archived 548,538-byte, 1,391-definition source
in 4,922.363 seconds (82.04 minutes), with a 10,245.1 MiB process peak RSS.
The pinned TypeScript compiler compiled the same source with all 1,391 exports
in 48.718 seconds and 1,731.65 MiB peak RSS. The port used a warm persistent Base
cache; upstream has no equivalent cache and ran with caching off. Those
measurements describe the implementations but are not a matched-cache speedup.
Library wrappers are backend-specific: upstream explicitly requests all source
definitions, while the port also retains Base foreign roots under its normal
library policy.
The final old/new self-emitted comparison uses the same warm-cache policy.

## Promotion status

The candidate is published as an explicit experimental artifact. The supplied
`dist/typed-api.mjs` remains the default while phase 1 targets and corpus gates
remain unmet. The new host retains compatibility with the old API through
capability checks. Source improvements, focused correctness evidence and a
successful self-build do not turn a timed-out native fixture into a pass.

## Deferred work

Source inspection corrected one detail in the design: the original host already
passed `j_stops(contextBook)` to annotation, rather than a stop set from selected
definitions. This implementation preserves that call and reuses the first full
stop set for reachability and layout; one redundant annotation stop computation
therefore remains.

First-use Base preparation still may repeat work; this change does not broaden
persistent cache trust or change cache schema. Constructor-owner indexes, checker
book maintenance, general direct-call workers, ownership-based argument-vector
elision, a lowering IR and lexer buffers are separate follow-ups. Their priority
will be based on the new profile and phase timings, rather than multiplying
hypothetical independent speedup factors.

Public `apply` still copies argument vectors as required by its mutation-isolation
contract. The checker still validates the actual declaration sequence. No cached
verdict is substituted for a complete candidate self-build, and no GPU execution
is inferred from native CPU or JavaScript results.

## Reproduction and use

See the [compiler guide](../../docs/BEND-IN-BEND.md), linked from the repository
README, for explicit artifacts, bootstrap and fixed-point commands. See the
[performance harness](../../selfhost/tools/performance/README.md) for configuration
and the original [baseline protocol](../../selfhost/tools/performance/BASELINE.md)
for historical measurements. Raw evidence and final results follow after the
current validation completes.
