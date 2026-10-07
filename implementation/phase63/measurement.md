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
