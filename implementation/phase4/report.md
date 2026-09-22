# Phase 4 structural compiler optimization report

Status: in progress. Authorized window: 2026-09-22, approximately 14:16–20:16 UTC.
Design: [structural compiler speed](../../design/phase4/structural_compiler_speed.md).
Starting compiler revision: `89e2c83`. The design was committed and pushed as
`4f59f08` before production compiler edits.

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

## Experiments underway

The private-image experiment isolates all compiler function objects in a child
process and transports data-only requests/results. This makes stronger internal
call specialization possible without changing the ordinary public library ABI.
The clean final prototype matrix passed 48 exact observations. Public-H to
private-image medians were 2.957 to 2.095 seconds for tree, 5.384 to 3.776 seconds
for list sort, and 52.212 to 34.651 seconds for a real 312-declaration compiler
fragment. See the [private-image report](private-image.md) for controls,
intermediate experiments, and the exact boundary assumptions.

A supported private build/run tool is being validated. Its outer process cost
must also be measured: artifact verification and startup can erase inner compiler
gains on very small requests. Full frontend observations are underway. An
additional [tag-comparison transform](tag-comparisons.md) was rejected after
showing no real-core gain despite a 1–2% change on small requests.
Sharing private [nullary values](nullary-values.md) was also deferred: list sort
improved 7.6%, but the real-core median changed only 1.4%, with one pair flat.

The representation experiment found millions of projection copies but no clear
gain from removing those copies alone. Its first pilot included uncached Base
loading/checking and must not be compared directly with the warm-cache profiles
above. Follow-up experiments distinguish projection calls from data layout.

The analysis experiment found many repeated weak-head-normalization requests for
terms already in weak head normal form. Conservative `All`/`ADT` shortcuts passed
their semantic controls but did not deliver a material whole-H gain, so they were
not promoted. A stronger constructor-telescope fact is being tested separately:
closed terms without beta-reducible applications can avoid repeated structural
substitution. Source and H gates remain pending for that candidate.

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
measurements are separate from the pending combined-source native build.

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

## Pending completion gates

The guarded selection algorithm has passed its focused checks and is integrated;
the default distributed API has not been replaced. Combined-source checking,
broader exact conformance, final controlled timing, checked self-reproduction,
and native validation where affected remain to be completed during this pass.
The [development guide](../../docs/PHASE4_DEVELOPMENT.md), linked from both READMEs,
documents the checked-overlay and bounded-profiling workflows.
