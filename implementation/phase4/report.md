# Phase 4 structural compiler optimization report

Status: in progress. Authorized window: 2026-09-22, approximately 14:16–20:16 UTC.
Design: [structural compiler speed](../../design/phase4/structural_compiler_speed.md).
Starting compiler revision: `89e2c83`. The design was committed and pushed as
`4f59f08` before production compiler edits.

## Current result checkpoint

The normal checked development loop is a **20.735-second B1 rebuild** followed
by a cold **16.483-second paired 21-case command**; reused validation has a
**9.328-second median**. Four-core [frontend scheduling](frontend-scheduling.md)
reduces the complete observation gate from **17m16s to 4m59s** (3.47× workflow
throughput), preserving all exact results and replay histories. Full
self-compilation remains an integration gate.
The source changes have passed a checked fixed point and the selected native
gates, and preserved all 2,756 frontend observations. The 560 existing TypeScript
differences remain; this is not full conformance.

The corrected private compiler passes all four full-source emissions, each
exactly equal to proven H. Control/profile mean process wall is
**805.634→787.260 seconds** (2.28% less); the two pairs improve 3.91% and 0.75%.
The candidate ranges from 749.523 to 824.998 seconds, with mean maximum-child RSS
3.16% higher. Its 11.3% core gain therefore becomes a modest whole-source gain.
See the [complete comparison](private-full-source.md), which retains drift and
all observations. Final private frontend results also preserve every one of the
2,756 raw results and verdicts. Canonical packaging now reproduces both exact
images and passes 25 unit checks plus seven profile guards; the reviewed
`--profile=phase4-boolean-stable` option is supported explicitly.

The final [small comparison](private-final-small.md) passes 72/72 observations.
Private H takes 35.0%/36.9% less request time than public H on successful tree/list
compilation, but remains 5.14×/8.05× the pinned TypeScript request time. B1 remains
the faster JavaScript development compiler. Public user-program output is
unchanged by these private-image optimizations.

The final [B1 string-equality experiment](b1-native-equality.md) finds a larger,
separate bottleneck: generic equality reconstructs strings only to discard them.
A guarded primitive-string path reduces core requests by **35.58% and 35.13%**
in opposite orders, with 909 helper controls, twelve exact selected observations
and unchanged complete frontend results. One complete-source run takes
**348.373 seconds** and emits exactly the proven H. A fresh opposite-order
full-source comparison is planned as P4-026; the single observation is not its
performance result. This remains a derivative of one exact checked B1 image,
not a new checked bootstrap or a general optimization for future source edits.

The experiment workflow now follows the useful file-based methodology from
`rom1504/math`: [numbered records](../../experiments/ledger.md), a bounded
[current strategy](../../experiments/STEERING.md), explicit rejection criteria,
raw evidence, counterexamples and a recorded decision after each experiment.
The [checked artifact capsule](final-source-capsule/README.md) and
[exact private images](private-final-images/README.md) can be restored without
rerunning compiler builds merely to recover an experimental starting point.
Historical proof paths and status are preserved.

## Experiment decision index

The [chronological ledger](../../experiments/ledger.md) preserves earlier decisions
and their corrections. This index gives the latest disposition; an accepted
experiment applies only to its stated source, artifact or worker boundary.

| Experiments | Final disposition | Where the result applies |
| --- | --- | --- |
| P4-001, P4-016: private calls and lexical-scope correction | Accepted after fixing the full-source counterexample | Dedicated private compiler process; original failed image remains rejected |
| P4-002: indexed final-definition selection | Accepted | Final-definition selection in Bend, guarded malformed-name fallback |
| P4-003: substitution-stable telescope suffixes | Accepted after fixing initial error order | Checking/annotation in the combined Bend source |
| P4-004: projection and representation | Accessor work included in the private image; broader layout migration deferred | Component evidence does not predict a representation-wide gain |
| P4-005, P4-006: normalization and direct tag shortcuts | Rejected | No material real-core benefit |
| P4-007: nullary sharing | Deferred | Small/inconsistent core benefit despite a list-workload improvement |
| P4-008: native flags/PGO | O2 retained; PGO deferred | 9.1% full-source mean gain has roughly nine minutes of setup |
| P4-009, P4-012, P4-019, P4-020: stability/Boolean profile | Accepted as an explicit opt-in | Exact reviewed H; 2.28% full-source mean gain, retained drift and RSS increase |
| P4-010: weak-head pair memoization | Rejected | Core time and memory regress despite many hits |
| P4-011: ordinary-call uncurrying | Rejected | Zero eligible sites in the actual image |
| P4-013, P4-021: edit loop and frontend scheduling | Accepted | Checked development workflow and four-core validation |
| P4-014: full-source inspector sampling | Rejected | Deadline/resource incident; bounded profiles replace it |
| P4-015: exact Con-arm fusion | Rejected | Inconsistent material core benefit |
| P4-017: native frontend mode switch | No-go without a protocol design | Native compile mode cannot silently replace exact parse/check observations |
| P4-018: native annotation parallelism | Rejected | Exact trees, but roughly 11.5% worse component time in both orders |
| P4-022, P4-023: residual profiles and family counts | Completed diagnostic evidence | Samples/counts are not speed estimates |
| P4-024: native equality in B1 | Correctness gates passed; experimental exact artifact | 35.1–35.6% core gain, unchanged full frontend and full H output |
| P4-025: narrow saturated substitution workers | Rejected | 7.25%/1.99% core gains fail the consistent-5% threshold |
| P4-026: B1 equality full-source comparison | In progress under a fixed deadline | Fresh opposite-order comparison, separate from the prior correctness run |

The [next lowering design](../../design/phase4/next_compiler_lowering.md) records
the remaining architectural questions and their cheapest falsifiers. General
typed workers across matches, constructor continuations and compiler-wide
identifier representation are larger changes. None inherits a speed promise
from dispatch samples or the rejected narrow worker.

## Frozen starting point

[baseline.json](baseline.json) identifies 73 captured artifacts in
`selfhost/build/phase4/baseline`, including the 59 source modules, manifest,
assembled source, B1 and H APIs, runtime, host helpers, and prior evidence.
The original files remain available. The canonical pinned Base is shared;
separately keyed, previously validated Base cache entries were copied for the
diagnostic runs.

| Artifact | SHA-256 |
| --- | --- |
| B1 API | `8787894920cc8959ab0abec28ddae0ea0dc05ad7665dc6f4d43f845445e60923` |
| H API | `360bb62bec910e8148a8c24ee63c1a350a8fda06c206bdd5f04c153a006804de` |
| Assembled compiler | `936266643e95973709bac4b567289c5792decadbb3297f90018ed5052582d772` |
| Runtime | `26f5eee2f54b194b64f768df6ff505c67bf7a5df2159aa06caf53ecba54e910b` |
| Base | `b8c2734d45ec6b4ce70fee70ff06ef35e08fce885af8852d8eb77dbff020e946` |

The reference remains untouched TypeScript revision
`6018e28ecc67cf1fffc0c20c64b11023474c2df8`. Phase 3 established approximately
50 seconds for full-source TypeScript compilation, 250 seconds for native O2,
704 seconds for B1, and 1,980 seconds for H. Those observations have different
run histories; they are starting context, not a new causal benchmark.

## Successful-compilation profiles

The new diagnostic tool
[`cpu-profile.mjs`](../../selfhost/tools/performance/phase4/cpu-profile.mjs)
captures V8 exclusive CPU samples and synchronous top-level compiler API spans.
It hashes consumed inputs before and after the request and retains the emitted
output. Base preparation and dependency discovery precede the profile. Discovery
therefore warms the process; these instrumented observations are not fresh-process
timing benchmarks and are not used as the denominator of speedup claims.

Both initial runs used the frozen H API, CPU 1, Node v24.18.0, a 4 MiB V8 stack,
4 GiB old-space limit, and a 1,000 microsecond sampling interval.

| Exclusive sampled function | Tree | List sort |
| --- | ---: | ---: |
| Generic `apply` | 38.76% | 38.38% |
| `force` | 6.40% | 6.37% |
| Garbage collection | 5.52% | 6.60% |
| `call` | 2.97% | 3.59% |
| `project` | 2.57% | 2.50% |
| Global `get` | 1.93% | 2.89% |

The instrumented request took 3.472 seconds for tree and 6.390 seconds for list
sort. Checking, graph loading, and annotation account for most API wall time;
the runtime helper costs cut across those phases. Samples support investigating
dispatch and allocation, but cannot be summed into an achievable speedup.

Retained reports and raw profiles:

- [Tree report](evidence/h-tree-profile.json) and
  [compressed CPU profile](evidence/h-tree-profile.cpuprofile.gz).
- [List-sort report](evidence/h-list-profile.json) and
  [compressed CPU profile](evidence/h-list-profile.cpuprofile.gz).

A full-source B1 inspector profile failed to finish within its 1,800-second
external deadline (exit 124); no completed profile or valid timing was produced.
Other workers experienced scheduling delays, deadline failures, and an exit 137
during the same period. The sampler may have contributed resource pressure, but
the exact host cause is unproven. All affected timing conclusions were withheld
and the agents repeated their controlled matrices after recovery. The
[incident record](evidence/resource-incident.json) preserves the incomplete run
and excluded window, 14:39–14:57 UTC. Subsequent profiles use a small input,
three-minute maximum deadline and 3 GiB heap through
[`bounded-profile.mjs`](../../selfhost/tools/performance/phase4/bounded-profile.mjs).

## Compiler experiments and decisions

The private-image experiment isolates all compiler function objects in a child
process and transports data-only requests/results. This makes stronger internal
call specialization possible without changing the ordinary public library ABI.
The clean final prototype matrix passed 48 exact observations. Public-H to
private-image medians were 2.957 to 2.095 seconds for tree, 5.384 to 3.776 seconds
for list sort, and 52.212 to 34.651 seconds for a real 312-declaration compiler
fragment. See the [private-image report](private-image.md) for controls,
intermediate experiments, and the exact boundary assumptions.

The [private build/run and finite-batch package](private-cli.md) is now implemented
and tested. Artifact verification and startup can erase inner compiler gains on
very small requests. A 21-case private batch takes 17.524 seconds versus 43.023
seconds for separate private CLI invocations; reused B1 is faster at 7.850
seconds. All 315 focused observations agree exactly. The original-source private
image also [preserves all 2,756 frontend observations](frontend.md), including
exact diagnostics and all 560 existing differences from live TypeScript. An
additional [tag-comparison transform](tag-comparisons.md) was rejected after
showing no real-core gain despite a 1–2% change on small requests.
Sharing private [nullary values](nullary-values.md) was also deferred: list sort
improved 7.6%, but the real-core median changed only 1.4%, with one pair flat.

The first final-source private full compile found an emission regression:
specialized workers lost a block-local generated helper table and returned
`F is not defined`. Its complete error observation and failed 602-second outer
measurement are retained in [P4-016](../../experiments/phase4/P4-016-private-lexical-scope.md).
The [lexical-scope correction](private-scope-fix.md) now passes 25 package tests,
14 actual split-worker controls and the exact escaped-string output comparison;
its corrected full-source run now passes with exact H output. The combined
profile passes both complete source runs and its final-image frontend audit.
The original failed image remains rejected; these gates apply to the corrected
image identities, not to earlier selected successes.
The [54-observation final small matrix](small-comparison.md) remains scoped to
its tested inputs, including its recorded negative-case regression.

The representation experiment found millions of projection copies but no clear
gain from removing those copies alone. Its first pilot included uncached Base
loading/checking and must not be compared directly with the warm-cache profiles
above. Follow-up experiments distinguish projection calls from data layout.

The analysis experiment found many repeated weak-head-normalization requests for
terms already in weak head normal form. Conservative `All`/`ADT` shortcuts passed
their semantic controls but did not deliver a material whole-H gain, so they were
not promoted. The stronger constructor-telescope fact is now integrated and
documented in the combined-source checkpoint below. Its component gates pass;
the [completed fixed point and full frontend sweep](final-source.md) now validate the combined source separately.

The conformance inventory now captures Git output through files and rejects any
subprocess error even when a supervisor also reports status zero. This environment
reproduced `spawnSync git EPERM` alongside valid stdout/status zero with synchronous
pipe capture. File capture succeeded; 15 inventory/judge tests, including an
explicit error-with-zero-status regression test, passed. The frozen Phase 4
frontend harness consumes the corrected inventory; compiler semantics are
unchanged by this supervision fix.

The completed [native flag study](native-opt.md) keeps O2 as the ordinary build
choice. PGO reduced full-source time from a two-sample O2 mean of 280.227 seconds
to 254.775 seconds, 9.1% less time, across opposite-order pairs. Its roughly
nine-minute setup projects about 23 full compiles to repay and is tied to the
exact native compiler C. O3 and ThinLTO showed insufficient small-workload gains.
All 56 benchmark/training compilations and 11 semantic cases passed; every
full-source output reproduced the proven Phase 3 H bytes. These flag-only
measurements are separate from the [completed combined-source native build and comparison](native-final.md).

Indexed final-definition selection is now integrated in the Bend sources for
`driver_final` and `sp_canonical`. The old routines repeatedly filter all prior
declarations. The new helper preserves last-definition-wins order and the initial
list's unrelated duplicates, with the original path below 256 events. The
[independent audit](book-final-audit.md) caught a malformed-UTF-16 error-order
change in the first index prototype. The integrated version uses a nonthrowing
name guard and falls back to the unchanged original algorithm for those inputs.

The checked integrated overlay passed 105 structural cases, a real full FNV
collision, and 23 actual Bend-emitted H boundary cases plus eight name-validity
controls. On the actual parsed compiler book (3,212 events), B1 final-definition
selection improved from 2.151 seconds to 0.115 seconds, 18.75x; Base selection
improved 1.42x under B1 and 1.40x in the H component. These are component results,
not full-compilation gains. See [the real-book report](book-final-real.md).

The guarded source candidate's fresh-process three-way comparison passed all
27 exact observation/output/execution samples. Tree request medians were
1.679 seconds for baseline B1, 1.588 seconds for the candidate, and 0.402 seconds
for pinned TypeScript. List-sort medians were 3.038, 2.950, and 0.436 seconds.
The unchanged rejection control was 0.816 versus 0.811 seconds. The modest
whole-request changes are distinct from the large isolated-helper improvement.
The [complete comparison](evidence/book-final-guarded-small.json.gz),
[checked build](evidence/book-final-checked-build.json), and
[component gate](evidence/book-final-guarded-component.json) retain identities.

The shared
[`checked-overlay.mjs`](../../selfhost/tools/performance/phase4/checked-overlay.mjs)
builds such overlays in new directories, verifies frozen and actual consumed
inputs, checks the pinned upstream checkout, assembles the full compiler, runs
type/ownership/completeness checks, and emits selected API roots. It does not
fabricate normal bootstrap metadata. Its caller supplies process resource limits
and a deadline.

## Combined-source integration checkpoint

The final constructor-telescope optimization is now integrated alongside guarded
book selection. Its [component report](analysis-telescopes.md) records a fresh
H median of 53.545 to 42.908 seconds, 19.9% less time, with exact output and
dependent-type, diagnostic and native controls. The earlier normalization
shortcut was [not promoted](analysis-normalization.md).

At 16:22 UTC the complete combined source passed the untouched pinned TypeScript
checker, ownership validation and zero unresolved holes. The builder also checked
that every requested API root exists. Source SHA-256 is
`34c6ef63931e522a96a4203f8bbd8e103d3a27636cce5dd42d9ec57a8587d122`;
checked B1 API SHA-256 is
`0653f21e7e227bf7bf7e3ad777630da64d520534753900636a571ed57a43f810`.
The [checked-build record](evidence/combined-checked.json.gz) retains all consumed
module identities. A fresh full checked B1-to-H-to-H reproduction started at
16:23 UTC on CPU 2, with a frozen host, canonical Base, 4 MiB stack, 12 GiB heap
and a one-hour deadline per stage. The [full proof completed](final-source.md) at
17:01:13 UTC; actual stage2 and stage3 files are byte-identical. The component
gain is not substituted for these independently completed measurements.

The first checked self-emission completed in 670.766 seconds and produced H SHA
`b33b38e32a263bf78e1d43cf459b7abf9a41d78d112d71a25f87ddba7bd09bf8`.
Stage3 completed in 1,591.343 seconds with identical bytes; all consumed proof
inputs and all 59 current/frozen module identities were independently verified.
On exactly the same source and canonical Base,
[three pinned TypeScript samples](typescript-final.md) have a 50.937-second
compiler median and a 51.443-second process median. Actual H confirms all 1,522
ordered library roots. This is the full library policy, not the limited bootstrap
API's export set; the proof and timing runs have distinct cache/run histories.

The [normal development commands](development-final.md) now have final-source
evidence: a genuine 54-export checked bootstrap takes 20.735 seconds, followed by
16.483 seconds for a cold 21-case live paired smoke command. Their child-process
sum is 37.217 seconds. Three warm invocations have a 9.328-second process median,
with unchanged observations and diagnostics. A separate in-process checked-build
experiment took [39.490 seconds](evidence/cold-combined.json.gz), excluding source
assembly and its outer Node startup. Neither is compared causally with the older
Phase 3 workflow, which used a different source and measurement harness.

## Completed combined-source gates

The [full final-source frontend sweep](final-source.md) preserves all 2,756 prior
parse/check observations over 1,378 fixtures, including exact diagnostics. There
are zero candidate/reference history changes, zero new mismatches, zero resolved
mismatches and the same 560 existing live TypeScript differences. All observations
completed without worker failures or timeouts. This is regression evidence, not
full language conformance. A 3.204-second unrelated audit overlapped CPU 1 during
the sweep; no controlled frontend timing claim is made.

The [integrated native compiler](native-final.md) passed checked C emission,
actual O2 cache miss/hit, 11 selected semantic cases and seven full-source output
comparisons against the proven H bytes. Three same-source old/new O2 pairs lower
median compile time from 284.807 to 245.364 seconds (13.85% less); individual
paired reductions range from 6.05% to 14.28%, with the control drift retained.
Build expenses are reported separately.

The guarded selection and telescope algorithms are integrated; the default
distributed API has not been replaced. Combined-source checking, checked
self-reproduction, complete frontend observation preservation and selected
native validation are complete. Final private-image gates and opt-in packaging
also pass. Four-core frontend scheduling is validated; the native annotation
fork is rejected for an 11.5% component regression in both orders. These
workflow/private-image experiments retain their separate source and ABI boundaries. The
[development guide](../../docs/PHASE4_DEVELOPMENT.md), linked from both READMEs,
documents the checked-overlay and bounded-profiling workflows.

## Residual costs and final bounded experiments

The [new B1/private core profiles](residual-profile.md) use complete, bounded
10 ms sampling and exact output, with raw profiles and consumed images archived.
Generic private application remains prominent (28.16% exclusive samples), while
B1 retains trampoline and string-comparison work. The
[lowering comparison](residual-architecture.md) connects actual generated code to
specific hypotheses, without using those samples as a speedup ceiling.

[P4-023](matcher-family-counts.md) counts 67,779,248 generic applications and
13,429,155 partial records in the real core request. The two substitution helpers
account for 8.68% of those applications and 18.22% of partial records. These are
operation counts, not allocated bytes or a time ceiling. They justify the
bounded [P4-025 worker experiment](../../experiments/phase4/P4-025-substitution-workers.md),
whose independent [semantic review](private-substitution-workers-review.md)
checks the actual changed caller, staged malformed-input fallback, beta rebuild,
metadata, deep terms and 100,000 tail steps. All 157 semantic controls and four
exact core outputs pass, but the speed pairs improve 7.25% and only 1.99%.
The candidate is rejected at its predeclared consistent-5% threshold, with no
full-source escalation or production promotion. Fewer partial records do not
guarantee a stable material gain.

[P4-024](b1-native-equality.md) completes its guarded B1 pilot, full frontend gate
and exact complete-source emission. The selected request gain is 35.35% by the
two-pair core mean, with lower observed peak RSS. Both the actual derived image
and its ordinary checked seed are preserved with honest provenance. The
[frontend archive](b1-native-equality-frontend.md) preserves all 2,756 observations,
45 worker histories and 1,494 input mappings. P4-026 measures full-source speed
separately rather than deriving it from the profile or selected benchmark.

## What improved, and what remains expensive

The supported path for new source edits is the checked B1 rebuild followed by
focused persistent checks. Four-worker scheduling makes broad regression checks
fit within about five minutes on the recorded machine. Neither requires waiting
for a self-build after every edit. Checked self-reproduction remains necessary
at a source integration boundary, with exact provenance and output checks.

Compiler throughput still trails the original TypeScript compiler. On the final
complete source and library-root policy, the recorded process measurements are:

| Compiler execution route | Process wall | Ratio to TypeScript | Measurement scope |
| --- | ---: | ---: | --- |
| Pinned TypeScript | 51.443 s | 1.00× | Three-run median |
| Bend source, native O2 | 245.364 s | 4.77× | New-compiler median in three alternating pairs |
| Experimental equality B1 | 348.373 s | 6.77× | One exact-output gate; controlled comparison separate |
| Ordinary checked B1 | 670.766 s | 13.04× | Checked fixed-point first stage |
| Optional private H profile | 787.260 s | 15.30× | Two-run mean in the four-row private comparison |
| Public Bend-emitted H | 1,591.343 s | 30.93× | Checked fixed-point second stage |

These cross-route ratios describe recorded observations. They are not a fresh
randomized comparison: processes, cache histories, physical cores and resource
boundaries differ. The linked route-specific reports contain the actual causal
comparisons, distributions and memory observations. B1 executes the compiler
written in Bend after TypeScript emits its JavaScript; it is distinct from
compiling the same input directly with the original TypeScript compiler.

The source algorithms, native lane and private representation changes improve
compiler execution. The final private and B1 derivatives emit unchanged program
bytes, so these measurements do not establish faster generated user programs.
Earlier generated-runtime work remains scoped to its own Phase 3 evidence.
The 560 exact frontend differences from upstream remain open conformance work.
No optimization result makes this checker a trusted proof verifier.

## Final review and artifact integrity

The independent [code review](final-code-review.md) examined the six changed Bend
modules, private-profile selection, lexical scope, demand order, graph freshness,
cache identities and the process boundary. Its 31 exact reviewed file identities
are preserved; it found no new blocker within the stated typed-data assumptions.
It did not run another compiler or claim universal equivalence.

The separate [identity audit](evidence/final-integrity.json) verifies every one
of the 59 current and frozen modules against the checked-build report, both
actual fixed-point byte sequences, and the exact source/B1/runtime/Base/private/
derived-image identities. The pinned upstream tracked checkout is unchanged.
The human-written `bend2/bend.ts`, distributed compiler artifacts and public
runtime are unchanged from the campaign's starting revision. This is a read-only
integrity check, distinct from the semantic and performance gates above.

The [preservation index](../../experiments/PRESERVATION.md) links actual archived
images, histories, outputs, caches, source and consumed tools. It retains the
identified early-history gaps. Restoring an old image does not validate a new
source edit, rewrite a historical proof or make its canonical paths relocatable.
