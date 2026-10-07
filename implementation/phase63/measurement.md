# Phase63 measurement protocol and status

The compiler-speed experiments use a controlled derivative of Phase61's frozen
method06. The [reproduction guide](../../selfhost/tools/performance/phase63/latency/README.md)
records factories, candidate bindings, root-only target recipes and limitations.

The historical baseline is actual State08 B2, module SHA256
`23bd6a48b9ed48b58bdc81245c3e40978735f8386c3eb6029b92701511986477`, produced by
the genuine checked State08 attempt. Its comparison TS pin remains
`018751270e800bc222a93dad7f257083ee53a5f7`. Before a candidate B2 exists, source
screening uses its actual checked B1 against State08 checked B1; that preliminary
comparison cannot replace the genuine B2/TS headline.

Each image consumes its own checked snapshot driver, source, runtime and private
API-keyed cache. Cache format changes are explicitly admitted by a frozen method
and decoded by that image's own snapshot helper. State08's historical workflow
audit input resolves only through an exact byte-identical checked snapshot row;
current executing tools remain independently pinned. No historic receipt or
installed artifact is modified.

The method retains separate compilation-only and import/API-load/first-request
clocks. Preparation, cache priming and post-return full raw-byte comparison are
outside these clocks. Moving work into import does not eliminate it from the
combined metric. Prepared disk caches do not imply a warm process or cold OS
cache. Later requests have their own observations and do not replace first
requests. All timing samples use serial CPU3 guarded workers; diagnostic
profiles are separate.

Screening starts with Numeric and MapSet, confirmation adds raytrace, held-out
checks cover Lexer and Evening, and the final intended broad comparison uses
23 sources × 3 roles × 3 rotated rounds = 207 fresh workers. A one-round screen
does not have balanced role positions; `screen-balanced` explicitly provides
one complete rotation. Two-round three-role confirmation is likewise an early
decision tool, not a balanced broad claim.

Factories have materialized methods01/02 and baseline bindings01/02 under
`selfhost/build/phase63`. Method02 additionally stages the new graph helper from
actual candidate snapshots and pins the live workflow's driver/helper import
dependencies independently. State08 remains on its frozen legacy helper set.

Root's first preparation (`baseline-latency01/preparation/report.json`) failed
correctly when `workflow.mjs` changed during execution: final stable-input checks
observed size 18,531 → 18,587 bytes and changed timestamps. Its only launched
baseline worker reached image setup, Base priming and cache verification before
the final input-stability refusal; worker wall was 6.334 seconds. Other roles
never launched, and no clean timing sample resulted. The failed method, binding,
worker and parent receipts remain unchanged. Fresh `baseline-latency02` bindings
are ready for method02 after the root freezes all host edits.

This remains tooling readiness, not a timing result or semantic qualification.
No target was executed by the measurement agent. Root
will add actual run identities, failures and results after execution. Production
promotion, emitted-program behavior, B2 own-source acceptance and fixed-point
equality remain separate gates.

The data-only export factory now records an exact source-backed old86 + new8
proposal and joins it only after the actual checked bootstrap exists. The
separate root-only API validator checks exact exports and callable functions.
The genuine-B2 producer uses the new JDPlan path and retains both tiny
plan/split equality and compatibility-library equality; its derivation and
checked source/helper identities are recorded. Final qualification method
generation preserves the existing oracles and reproduces B3 through that same
actual plan API. These readiness statements do not imply execution or passing
results.

## State05: preliminary checked-B1 screen

The [data-only analysis](evidence/state05-b1-screen.json) joins the completed
`state05-b1-latency/screen/report.json`, exact binding and preparation receipts.
Both Bend roles are genuinely checked **B1** images. These measurements do not
update the historical genuine-B2/TS headline.

All six fresh workers pass complete raw-module equality. Each cell has one
sample, with baseline/candidate/TS in fixed order; this is a rejection screen,
not a balanced or statistically established population result.

| Input / clock | State08 B1 | State05 B1 | Pinned TS | Candidate / baseline |
|---|---:|---:|---:|---:|
| Numeric, compilation | 539.51 ms | 448.15 ms | 320.47 ms | 0.831× |
| MapSet, compilation | 2,157.50 ms | 1,783.85 ms | 638.74 ms | 0.827× |
| Numeric, import + API + compilation | 595.20 ms | 505.67 ms | 580.67 ms | 0.850× |
| MapSet, import + API + compilation | 2,213.38 ms | 1,841.30 ms | 900.36 ms | 0.832× |

Equal-source geometric means show **17.13% less compilation time** and **15.93%
less combined-first time** than State08 B1. Candidate/TS is 1.976× compilation
and 1.335× combined on these two inputs only. This combined source change does
not isolate individual features. The next decision requires genuine B2 and
confirmation/held-out coverage.

The screen took **9.353 seconds** including its validation overhead; its sample
execution stage was 8.965 seconds. Separate reusable preparation took **14.185
seconds** for all three roles. Candidate Base priming took 3.156 seconds versus
2.752 seconds for the baseline; complete preparation processes took 6.692 versus
6.227 seconds. Prepared-cache first-request improvements therefore do not imply
cheaper cache creation. Candidate API load was 52.61/52.64 ms versus baseline
51.60/51.74 ms, so this screen's request reduction was not obtained by moving
the same time into API load.

The separately supervised State05 checked build and strict36 gate passed in
58.071 seconds with peak process-tree RSS 1,596,743,680 bytes. Its recorded
bootstrap child took 37.677 seconds, Base preparation 3.544 seconds, and selected
validation 7.695 seconds; these child durations are parts of the outer build,
not additional elapsed time.

Through the screen's last worker at **20:29:42 UTC**, the recorded campaign had
elapsed **25 minutes 18.140 seconds** since 20:04:24. The union of 23 completed
supervisor intervals was **128.916 seconds (8.49%)**, including five failed
receipts. Reused preparations and nested intervals are not counted twice. The
remaining 23 minutes 9.224 seconds are unclassified elapsed time, including
source/tool work and review—not measured waiting. Later controls and B2 work
are deliberately outside this cutoff.

## State05: actual B2 path and stage diagnostic

The [separate diagnostic](evidence/state05-stages01.json) completed all six
workers and raw-output oracles in **8.406 seconds**. It uses real State08 and
State05 B2 images. Ordinary `inspect` receives no API override, preserving its
private admission paths; synchronous entry observers see the actual functions
called. The [reproducer](../../selfhost/tools/performance/phase63/latency/stages/README.md)
records the exact insertion-only driver derivation and unchanged clean inputs.

For **both** inputs the candidate calls ready-prefix seeding, world checking,
plan selection and plan emission exactly once. Legacy prefix checking and
legacy reach/library calls are absent. This rules out silent fallback as the
reason for limited gains in these observations. Neither B2 uses the positional
ABI adapter here: observed encode/invoke/decode phase counts and times are zero.

| Diagnostic boundary | Numeric old → new | MapSet old → new |
|---|---:|---:|
| Base cache read/decode/admission, inclusive | 153.23 → 182.76 ms | 152.71 → 178.69 ms |
| Freshening (`f_prefix_graph_trace`) | 51.66 → 2.83 ms | 37.20 → 10.55 ms |
| User-source completion | 42.56 → 33.17 ms | 205.86 → 155.29 ms |
| Prefix checker → prepared-world checker | 123.53 → 59.61 ms | 203.52 → 175.44 ms |
| Emitted reach → plan selection | 28.10 → 41.49 ms | 366.41 → 396.06 ms |
| Library emission → retained-plan emission | 18.08 → 40.38 ms | 290.39 → 140.64 ms |

The new cache decoder consumes approximately **119 ms for the mandatory book
graph and 53–54 ms for prepared state**. Those are children of the cache total,
not additional costs. Prepared world/freshening work is avoided, but decoding
the richer saved representation offsets part of the gain. The transport needs
its own improvement or ablation before it can be called a cold-request win.

The combined plan-selection/emission boundary improves on MapSet by about
120 ms but regresses on Numeric by about 36 ms in this diagnostic. MapSet still
spends 396 ms in plan selection, 141 ms in plan emission, 120 ms in annotation
and 62 ms in layout checking. This directs the next investigation toward
plan construction/remaining lowering and host exports as well as transport;
zero observed ABI conversion makes pre-encoding for that adapter irrelevant
to these particular B2 requests.

Each cell is one instrumented first request. The exclusive stage partitions
close, but hooks perturb JIT/GC and execution time. These differences locate
work; they do not establish isolated feature speedups or replace clean latency
measurements. Narrow TS checking still includes a different Base boundary.

## State05: clean genuine-B2 screen and broader byte gate

The [follow-up receipts](evidence/state05-followups.json) keep clean timings,
candidate-only byte checks and host-only counterfactuals separate. The clean
State05 B2 image was genuinely emitted by checked State05 B1; it is not a B1
image with a bootstrap sidecar. All six screen workers pass full raw-output
equality in 7.992 seconds.

| Input / clock | State08 B2 | State05 B2 | Pinned TS |
|---|---:|---:|---:|
| Numeric, compilation | 476.04 ms | 408.02 ms | 320.44 ms |
| MapSet, compilation | 1,544.67 ms | 1,353.51 ms | 630.73 ms |
| Numeric, import + API + compilation | 583.28 ms | 505.07 ms | 580.25 ms |
| MapSet, import + API + compilation | 1,652.96 ms | 1,451.68 ms | 894.11 ms |

On these **two sources only**, equal-source geometric means are 0.867× old B2
compilation time and 1.653× TS; combined-first ratios are 0.872× old B2 and
1.189× TS. Each cell has one fixed-order sample. This is preliminary evidence
of a 13.3% compilation reduction, not a replacement for the 23-source balanced
headline. Candidate API loading also fell from about 103–104 to 92–93 ms.

The separate `state05-b2-bytegate23/report.json` completes **23/23 fresh source
compilations** in 31.134 seconds. Every full emitted module equals its qualified
reference, covering the modules used by all 45 program points. This gate has
zero fresh runtime executions and no baseline/TS timing roles: it establishes
artifact preservation on those sources, not broader speed or full semantics.

## State05: what sampled CPU work supports

The [CPU ancestry analysis](evidence/state05-cpu01.json) reconstructs raw V8
sample parents and produces disjoint semantic and mechanism partitions. The
two candidate-only first-window profiles contain 395/1,075 samples and
580.175/1,600.645 ms admitted weighted time for Numeric/MapSet, with no negative
deltas. The campaign takes 4.085 seconds and both raw-output checks pass.
Import and module parsing are inside this diagnostic window.

| Disjoint semantic region | Numeric | MapSet |
|---|---:|---:|
| Prepared cache read/decode/admission | 27.06% | 10.01% |
| Module parsing | 18.00% | 6.55% |
| Source loading | 9.41% | 12.20% |
| Checking | 10.89% | 9.80% |
| Annotation | 0.86% | 7.47% |
| Plan selection | 8.03% | 26.71% |
| Final library emission | 2.45% | 9.24% |
| Garbage collection | 6.20% | 5.46% |

Remaining regions are listed in the evidence; the complete partition sums to
100%. A second view groups mechanisms. It must not be added to this table.
MapSet's independent substitution/normalization family union is 14.96%, and
its host-export union is 9.24%; those overlap each other and their parent
stages. Native host walking alone is an inclusive 6.03%, already inside host
exports. These numbers support sharing type/normal-form facts across plan,
annotation and wrapper generation; they do not imply every sampled operation
can be eliminated. No paired TS CPU profile establishes which work is excess.

The generated implementation of `index_hash` uses a Unicode-aware destructive
String loop (`codePointAt`, head/suffix slicing, FNV U32 multiplication), matching
[its Bend source](../../selfhost/src/core/index.bend). However, **no named
`index_hash` frame was sampled**. Inlining or sampling can hide it, so this is
neither evidence of zero cost nor support for a large hashing claim. The wider
index/book/lookup union is 13.55% on Numeric and 8.66% on MapSet; hashing is only
one possible component of that work.

MapSet's sampled String-library union is 3.28%. Generated `String.contains` and
`String.starts_with` destructure String values repeatedly; generated-JS text
inspection calls them in the direct backend. A proven native-string lowering
could reduce that work, but this profile supports a small bounded experiment,
not a parity prediction. Unicode semantics and exact body recognition remain
requirements. The strongest measured next steps are the cache decoder and
repeated host/type traversal, followed by sharing plan and annotation facts.

## State05: fast host-helper counterfactuals

The host-only loop copies the actual prepared State05 B2 project and changes
only the recorded graph decoder helper. API/image, driver, Base, runtime and
cache bytes stay identical. Every worker uses ordinary `inspect` and saves its
complete module for exact comparison. These are explicitly diagnostic images,
without fabricated checked sidecars or production qualification.

| Helper experiment | Samples per role/source | Numeric compilation ratio | MapSet compilation ratio | Campaign wall |
|---|---:|---:|---:|---:|
| Literal object shapes | 1 | 0.893× | 0.967× | 13.946 s |
| Specialized constructors v1 | 1 | 0.807× | 0.921× | 13.599 s |
| Specialized constructors v2 | 2, reversed order | 0.761× | 0.855× | 27.884 s |

Each ratio compares that experiment's own unchanged baseline. Separate
campaigns must not be compared directly. All 4/4, 4/4 and 8/8 workers pass
exact module equality. The v2 confirmation gives 23.9%/14.5% lower mean
compilation time and 20.7%/13.8% lower combined-first time. There is no TS role.
Malformed-cache differential controls, checked integration, actual new B2 and
broader qualification are still required before promoting these gains.

## Final qualification readiness

Root requested data-only State06 plans after its strict36 build passed. The
generated `state06-final-plans/index.json` binds the actual checked attempt,
export admission and frozen qualification method01; its SHA256 is
`c5abc44224a84dc8f24671150b731de0f67fe3c86947df9b075bc6fa03c697da`.
It contains four exact root launch commands for checked-B1, genuine bootstrap,
B2/self-check/fixed-point qualification and release preparation. No bootstrap
reuse was supplied and no stage was executed by the measurement agent.
State06 remains a provisional selection while further source changes are
investigated; plans do not authorize skipping the recorded stage barriers.

The reviewed staging code copies and pins the selected graph helper, preserves
the decoder-authoritative frame3 admission, and uses the plan-based genuine
B2/B3 emission. Logical exported roots number 94; B2 also retains reachable
internal definitions, so exact default-export-key checks apply only to the
checked B1 facade. Release preparation produces commands and never installs.

The first State06 final checked run subsequently stopped at composition controls:
both TS and candidate reported `spawnSync .../node EPERM` and `healthy:false`,
although their observed events and values agreed. The receipt remains failed
and preserved; matching observations do not override process-health checks.
At root's request, the data-only factory created fresh `state06r2-final-plans`
and `final-state06r2` bindings, reusing the already recorded genuine State06 B2
through its original bootstrap pins. The new index SHA256 is
`57d0cb0f0fb6a6ae433a35c2bbe6a2b10a8ad7f8b9ce18aac7e8274b963c1cd5`.
Before handoff, all 114 live manifest modules, `compiler.json` and seven host
helpers matched the selected State06 snapshot byte-for-byte. Snapshot staging
supplies the compiler image and driver; maintained8 additionally checks current
host/manifest equality and reads the maintained live test scripts. No retry
target was executed by the measurement agent.

## State06: balanced 23-source compilation result

The [compact broad evidence](evidence/state06-broad3.json) records **207/207
passing workers**: 23 independent source modules × three roles × three fresh
processes. Role order rotates across rounds so every role occupies each order
position once per source. Both Bend roles are genuine B2 images. Every emitted
module passes the full qualified raw-byte oracle; the timing run performs no
fresh generated-program runtime executions.

| Equal-source geometric mean | State08 B2 / TS | State06 B2 / TS | State06 / State08 |
|---|---:|---:|---:|
| Compilation, first request | 2.07151× | **1.67547×** | **0.80881×** |
| Host import + API + first request | 1.41480× | **1.17557×** | **0.83091×** |

These use each source/role's median of three observations, then give every
source equal weight. State06 reduces compilation time by **19.12%** and the
combined first-use clock by **16.91%** against the same-campaign old baseline.
All 23 source medians improve: compilation ratios span 0.75161–0.85552×,
combined ratios 0.79106–0.87129×. No source regresses against the baseline on
either median clock. Three samples are enough for this screening/confirmation
method, but do not establish statistical significance.

The remaining compilation gap to TS spans **1.13086×** for Numeric to
**2.04147×** for Lexer. The six largest ratios are:

| Source | State06 compilation | TS compilation | Ratio |
|---|---:|---:|---:|
| Lexer | 786.25 ms | 385.14 ms | 2.041× |
| Active raytrace | 1,045.61 ms | 527.06 ms | 1.984× |
| Mandelbrot grid | 803.81 ms | 405.37 ms | 1.983× |
| MapSet | 1,240.61 ms | 637.18 ms | 1.947× |
| Symbolic regression | 716.51 ms | 368.11 ms | 1.946× |
| Raytrace | 1,037.54 ms | 534.93 ms | 1.940× |

Including host/API import changes the range to **0.78721–1.48916× TS** and
puts five sources below TS: local fold, scalar region, closures, expression,
and Numeric. This reflects a useful first-use advantage on those sources;
compilation itself remains slower than TS on every source. The evidence file
contains the full 23-source, six-clock matrix. Its 45 associated runtime points
are not counted as 45 independent compilation programs.

The broad campaign takes **264.991 seconds**, with **228.455 seconds** inside
its serial worker interval union. Peak observed tree RSS is 181,800,960 bytes.
Existing cache preparation is reused; this does not make cache creation free.
Final semantic, self-hosting and release qualification remain separate gates.

The [interim phase time account](evidence/time-account-interim02.json) cuts off
at **21:18:39.947 UTC**, not at phase completion. Since 20:04:24, elapsed time
is 74m15.947s. The union of 360 closed guard receipts, including 11 failures,
is **19m52.415s (26.76%)**; nested/reused intervals are counted once. Remaining
54m23.531s is unclassified wall time, not measured waiting or idle time.
No open worker was present at that cutoff. The data-only helper can produce
a fresh account at the final selected-state cutoff.
