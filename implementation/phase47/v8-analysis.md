# Phase 47: raw-array discrepancy and V8 discriminator

Status: root executed the clean public-call screen described below. This agent
read its evidence and performed only static source analysis and Node v24.18.0
`--check`; no benchmark, profile, trace, or compiler build was executed by
this agent. The consumed driver remains frozen at SHA256
`593a57dcc87af18a7acd7f887df98f0bbc38c85b45217e0312a23bd3e0b6c00c`.

## Observations and comparability

The saved diagnostic Phase 46 batch ablation has five rotated rounds in
`selfhost/build/phase47/array-timing01/report.json`: median original 680 ms,
inline store 683 ms, invariant backing view 186 ms, invariant view plus length
186 ms. The view ratio is 3.656x. These rewritten modules are explicitly
`productionSafe: false`; this establishes a mechanism opportunity on that
saved workload, not a safe compiler implementation or a library speed forecast.

The initial checked Phase 47 array01 local-fold canary improved roughly
90 to 85 microseconds, 1.057x; the replicated public-call screen below
supersedes that preliminary timing. This result is distinct from the
saved batch ablation. Their boundaries and inputs differ: the Phase 46 Bend
batch calls bench internally with alternating lengths and 16 seeds, whereas
the maintained library caller repeatedly calls public bench(4096,17).
The batch can amortize admission across its internal calls.

Source reviewed: `selfhost/build/phase47/array01-fast/modules/local-fold.mjs`,
its `raw-local-fold.js.txt`, Phase46 array batch source and timing report,
and `selfhost/tools/performance/phase37/fixtures-historical/local-fold.bend`.
The checked array01 compiler/module hashes remain recorded in its bundle
manifest; this driver records each actual module hash rather than assuming
that a variant belongs to that compiler.

## Three competing mechanisms

1. **Entry guard cost cancels body savings.** At module line 241,
   `arrayViewHostGuard` calls full `regionHostGuard()` before `localGuard`.
   With no active region proof, the latter at line 205 checks 40 numeric hook
   descriptors (16 initial, 20 Math, four DataView), four floatView own
   descriptors, 15 protocol descriptors, prototype relationships, and two
   prototype-name arrays. It also uses captured `hasOwn` checks on descriptors.
   Array-view admission adds fill/isSafeInteger descriptors and Object's
   prototype check. Existing `localGuard` at line 164 checks a smaller local
   protocol and scalar dependencies. These repeated public-entry checks are
   real source work; their actual optimized cost has not been measured here.

2. **Loop pointer remains loop carried.** Raw fold.loop, named
   `$R_102_111_108_100_46_108_111_111_112`, no longer invokes arraydata.
   However its backing array enters as `$w0`, passes through the small write
   IIFE, and is returned as `$n2_0` to the next iteration. A compiler invariant
   pointer variant removes that dependency explicitly. V8 may already infer
   identity after inlining; the source difference alone cannot establish it.

3. **Inlining/tiering affects the residual.** The write IIFE and containing
   worker can become optimized at different points. Code size, feedback and
   call sites influence V8 decisions. A direct store variant tests this, but
   a trace saying an IIFE was inlined does not prove the array identity or
   length was hoisted. The saved inline-only batch result already argues
   against a large benefit from that isolated change on the saved batch.

These hypotheses can coexist. None currently establishes a V8 failure or a
regression in the checked compiler.

## Small discriminating experiment

Use fresh processes with the same pinned Node executable and CPU placement.
Run the lowerer's original, inline-write, invariant-pointer, both, and exact
entry-guard-bypass emitted variants through the same driver. The bypass is
an unsafe diagnostic, even when its outputs match; do not promote it into a
compiler change. Keep module generation receipts separately.

Start with fixed n=4096, seed=17, 8192 public calls after 8192 warmups. Repeat
clean runs in rotated order. If guard bypass alone reveals a substantial body
gain, guard cost is a supported causal explanation for this variant. If the
pointer variant alone wins under the same guard, investigate loop state.
If only the combined variant wins, report their interaction rather than
assigning the gain independently. A guard-bypass no-opportunity result weakens
this guard hypothesis but does not explain the saved batch difference.

Optional n=0 calibration measures entry plus allocation and empty-loop costs,
not a pure guard cost. It has independent expected result zero and the same
public-call count; changed body hotness and tiering limit subtraction from
n=4096. Do not treat a difference of medians as a precise guard measurement.

Driver CLI (paths are examples; every output directory must be new):

```sh
NODE=/home/ai/.nvm/versions/node/v24.18.0/bin/node
DRIVER=selfhost/tools/performance/phase47/v8-probe.mjs
MODULE=selfhost/build/phase47/array01-fast/modules/local-fold.mjs
taskset -c 3 "$NODE" "$DRIVER" "$MODULE" NEW_CLEAN_OUT clean 4096 17 8192 8192
taskset -c 3 "$NODE" --trace-opt --trace-deopt --trace-turbo-inlining "$DRIVER" "$MODULE" NEW_TRACE_OUT trace 4096 17 8192 8192
taskset -c 3 "$NODE" "$DRIVER" "$MODULE" NEW_CPU_OUT cpu 4096 17 8192 8192
```

Root should wrap these in the existing bounded-run queue; no parallel heavy
jobs. Save trace stdout/stderr alongside report.json. First use traces only
for the variants distinguished by clean results; use CPU profiling only if
those leave the mechanism unresolved. Markers delimit import, warmup and
measurement. Deopts before warmup ends differ from repeated measurement
bailouts. No forced optimization or native-syntax intrinsics are used.

## Driver and interpretation boundaries

The driver imports each original variant unchanged and calls default.bench.
An independent 128-cell BigInt oracle calculates the result before timing;
maintained input must equal 2339999928. Every call checks its result and
updates an externally recorded checksum. A separate BigInt digest oracle
checks warmup and measurement digests. First-call/import/warmup time are
recorded separately; the common assertion/digest harness is included in
measurement and may itself affect inlining or dominate very short n=0 calls.

Clean mode rejects trace/prof/inspect/native-syntax/no-opt/jitless flags.
Trace and CPU timings are labeled instrumented diagnostics and must not be
pooled with clean timing. CPU sampling starts after warmup, records source
positions and URLs, and writes a complete cpuprofile. Identically named
original/raw workers can coexist in one module: attribute samples by URL and
line/column rather than name alone. Hit shares are compositional, not exact
exclusive cost or proof of a hoisted operation.

The report hashes the consumed producer, module and Node binary, and records
process.versions including actual V8. Freeze this producer once consumed;
any later change needs a new filename. It does not certify source provenance,
semantic host-mutation safety, aliases, error order, or production admission.
Those belong to the checked-emission receipts and existing semantic controls.

## Relation to V8 research

See `research/compilers_architecture_and_techniques/v8.md` for primary-source
symbols and links at pinned V8 13.8.258.18. That historical source pin is not
asserted to equal the installed Node's V8; the diagnostic records the latter.
V8 can inline small calls and propagate known representations/maps, while
unknown effects or aliasing constrain load elimination. Inlining is budgeted;
source code growth and a new call graph can change profitability. Stable
private array shapes help feedback but do not prove invariant backing
identity. These are source-supported explanations to test, not measurements
of this program. Bend's AOT host guard returning to its generic path is not
V8 speculative deoptimization; V8 deopt traces must be interpreted separately.


## Measured public-call screen: attribution update

Evidence: `selfhost/build/phase47/array-public-timing01/report.json` and its
18 individual result/runner records. Three rotated fresh-process rounds per
variant, CPU 3, Node 24.18.0 / V8 `13.6.233.17-node.50`, 8192 warmups and
8192 public calls of bench(4096,17). All calls matched 2339999928; warmup and
measured digests matched 51846597. The runner closes the variant identities
against `array-checked-probe01/manifest.json`. Its diagnostic safety refusal
still applies: output equality and speed do not certify a compiler transform.

| Variant | Median us/call | Observed range us/call |
| --- | ---: | ---: |
| Phase45 worker23 bytes, reacquired through worker02 | 90.854 | 90.502–91.191 |
| Checked array01 original | 84.207 | 83.419–85.508 |
| Write inline | 63.809 | 63.437–64.790 |
| Invariant alias | 86.680 | 84.053–93.869 |
| Combined inline and invariant | 63.986 | 63.757–64.363 |
| Entry guard bypass | 73.694 | 72.317–73.936 |

Write-inline improves the unchanged checked array01 median by 1.320x
(20.398 us/call), and the Phase 45 bytes by 1.424x. Combined offers no further
observed gain. Invariant-alias alone does not improve these samples; one of
its three observations is slower. Guard bypass improves original by 1.143x
(10.513 us/call) but is weaker than write-inline and unsafe as a production
proposal. Thus the guard hypothesis explains a material component of this
workload, but cannot account for the strongest remaining opportunity.
The narrow supported mechanism is emitted write shape on the already raw
backing array. Pointer identity alone is not supported as the principal
limitation in this checked public-call context.

The saved Phase 46 batch gave a different ordering: shell inline 683 ms
versus original 680 ms, while raw backing view was 186 ms. These experiments
start from different modules and transformations, and use different call
boundaries and input sequences. The Phase 46 store inline retained its
original descriptor/backing-data path; the checked array01 write-inline
operates inside an already raw-array residual. Effect interactions, call
context, feedback, and code layout are possible explanations. Neither
experiment establishes which V8 optimization produced the difference.
Do not transfer the 3.656x batch ratio to public-call library execution or
call the contrasting inline outcomes contradictory.

## Focused V8 diagnostics worth running next

Two trace runs and two CPU runs, unchanged original versus write-inline,
are worthwhile if root needs a cause beyond the source-shape ablation.
Use the frozen driver and the exact original/write-inline module paths
below, with fresh output and bounded-run capture as in the earlier recipe.
Keep all instrumented timings separate from the clean table.

```sh
ORIGINAL=selfhost/build/phase47/array-checked-probe01/original/program.mjs
INLINE=selfhost/build/phase47/array-checked-probe01/write-inline/program.mjs
taskset -c 3 "$NODE" --max-old-space-size=1024 --trace-opt --trace-deopt --trace-turbo-inlining "$DRIVER" "$ORIGINAL" NEW_ORIGINAL_TRACE trace 4096 17 8192 8192
taskset -c 3 "$NODE" --max-old-space-size=1024 --trace-opt --trace-deopt --trace-turbo-inlining "$DRIVER" "$INLINE" NEW_INLINE_TRACE trace 4096 17 8192 8192
taskset -c 3 "$NODE" --max-old-space-size=1024 "$DRIVER" "$ORIGINAL" NEW_ORIGINAL_CPU cpu 4096 17 8192 8192
taskset -c 3 "$NODE" --max-old-space-size=1024 "$DRIVER" "$INLINE" NEW_INLINE_CPU cpu 4096 17 8192 8192
```

Trace question: does the raw fold.loop reach the same optimization tier
before measurement in both variants, and do either show recurring deopts
inside the measurement interval? Does the original store IIFE inline into
the raw worker, or is its caller refused because of size/feedback/budget?
Use named marker intervals and optimization IDs; do not interpret a refusal
for a same-named unused descriptor worker as a refusal for the raw worker.
Successful inlining alone cannot prove the resulting machine code is equal.

CPU question: does the roughly 20 us/call clean reduction reside in the raw
fold worker/write closure, while host-guard and harness work remain similar?
Compare sample counts normalized to completed public calls as well as shares;
both profiles contain the same number of verified calls. Account for sampling
interval and profile duration. A rising guard share can reflect a shrinking
body rather than greater guard cost. Anonymous IIFE samples may disappear
through inlining, so attribution to the containing worker is also relevant.
These short windows provide coarse attribution, not exact instruction cost.

If both variants optimize without recurring deopts and the original IIFE is
already inlined, the trace weakens a simple tiering/non-inlining explanation.
CPU body attribution would still support a residual code-shape effect;
proving a specific missed load/store or representation optimization would
require optimized-code/IR evidence. That heavier investigation is outside
this bounded recipe and is unnecessary before testing the safe emitted
inline-store change against the established semantic controls.

## Actual trace and CPU results

Root completed all four jobs in `selfhost/build/phase47/v8-diagnostics01`.
Both trace reports and both CPU reports are complete/passed, preserve the
frozen producer identity, and return expected digest 51846597. Trace stdout
is in `job-trace-{original,write-inline}/stdout.log`; stderr files are empty.
The actual trace flags were `--trace-opt --trace-deopt`, without
`--trace-turbo-inlining`. Consequently these traces do not answer the IIFE
inlining or budget-refusal question from the proposed recipe.

Both raw fold.loop functions completed non-OSR TURBOFAN_JS optimization
before `P47_V8 warmup-end`. Both have zero bailout records between
`measure-start` and `measure-end`. The inline variant had insufficient keyed
access feedback before warmup and a wrong-map bailout during warmup;
those do not recur in its measurement. Oracle and digest-oracle bailouts
before import are harness setup, not generated benchmark failures.
This weakens explanations based on a persistently lower loop tier or recurring
measurement deoptimization. It does not prove equivalent optimized code.

There is still wrapper tier activity during measurement in both traces:
invokeExact, arrayViewHostGuard, arrayfill, code, and apply complete TurboFan
optimization there. The raw loop has settled, but the whole entry chain
is not at its final tier throughout these particular trace windows.
No comparison of instrumented trace times is used for the clean speed claim.

CPU attribution below aggregates duplicate profile nodes sharing exact
function name, URL, line and column. The raw-worker position is zero-based
line 829, column 2914, inside `$arrayViewBody`, distinguished from the
same-named original descriptor worker. Each profile executes 8192 verified
public calls after 8192 warmups.

| Sample location | Original samples (share) | Inline samples (share) |
| --- | ---: | ---: |
| Raw fold.loop | 409 (64.31%) | 386 (70.57%) |
| Garbage collector | 66 (10.38%) | 12 (2.19%) |
| regionHostGuard | 65 (10.22%) | 67 (12.25%) |
| scalarGuard | 27 (4.25%) | 29 (5.30%) |
| Anonymous public scalar-root entry | 29 (4.56%) | 27 (4.94%) |
| All profile samples | 636 | 547 |

Measured windows were 700.428 and 601.106 ms; total inspector profile
windows were 719.553 and 620.564 ms. Profiling starts before the measurement
marker and stops after it, so it includes a small amount of surrounding
harness/inspector work. These durations and their ratio are instrumented
diagnostics, not additions to the three-round clean screen.

The absolute guard sample counts remain similar across equal call counts;
their larger shares in the faster profile do not indicate a guard regression.
The raw-loop counts fall modestly, whereas GC samples fall substantially.
Per 1000 completed calls, raw-loop samples are 49.93 versus 47.12, GC samples
8.06 versus 1.46, and regionHostGuard samples 7.93 versus 8.18. This single
profile pair supports an allocation/GC component to the residual write-shape
benefit more strongly than reduced admission work. It does not identify the
allocated object, count allocations, show retained bytes, or prove that V8
eliminated the per-iteration function-expression closure. The write IIFE is
a plausible source-level candidate; the existing traces provide no direct
inlining evidence. Sampling variability and GC scheduling also limit any
precise attribution of the 20.398-us clean reduction.

Current conclusion: the clean controlled source ablation supports inline
writes on the raw backing array; observed steady raw-loop tier and absence
of measured deopts constrain the JIT explanation, and reduced sampled GC
suggests an allocation-related contribution. Neither backing-pointer alias
failure nor loop-tier instability is supported as the principal cause here.
No further execution is needed for this bounded investigation. A safe
compiler emission change should be judged by its semantic controls and
clean repeated canaries; proving an exact V8 allocation or machine-code
mechanism would be a separate, heavier diagnostic task.

## Array04 generic-row screen and confirmation

The short three-round canary initially showed complete-generic-row32 medians
0.378669 ms baseline versus 0.434411 ms candidate, approximately 14.7% slower.
Baseline samples were [0.421411, 0.377871, 0.378669]; candidate samples were
[0.442355, 0.387945, 0.434411]. Root then ran the separate five-round confirmation
`selfhost/build/phase47/array04-row-confirmation/report.json`, with 1000-ms
warmup, 50-ms calibration and 300-ms measurement targets. It passed:
0.377530 versus 0.383429 ms medians, 1.56% slower. Baseline range
0.371679–0.428078 overlaps candidate 0.379318–0.395353; candidate half-drift
values are all mildly negative, approximately -0.13% to -1.69%.
The large initial slowdown was not reproduced. The remaining small difference
and overlapping ranges do not establish that all variation is noise or that
no regression exists. Broader qualification is root's separate next gate.

Read-only generated-byte comparison used these exact observed modules:

- Baseline: `selfhost/build/phase45/full-preparation-worker23/modules/local-row-observed.mjs`,
  130300 bytes, SHA256 `00272df61c2eadb4fdf702e1f145de7c5df463d2fcb18d8e1f78982870c94686`.
- Array04: `selfhost/build/phase47/array04-fast/modules/local-row-observed.mjs`,
  148762 bytes, SHA256 `1244bb2ab31757cc8f5adf372924ea0f33ded13669ba2e1e97e77f79df0c2fe7`.

The 18462-byte increase separates exactly into the 820-byte dedicated
array-view runtime guard addition and 17642 bytes added inside `G["pair"]`.
Removing only that runtime addition makes the prefix byte-identical.
Both modules have 31 G definitions with the same names and order; pair is
its only changed definition. The pair change consists of a 17446-byte private
body declaration and 196-byte guarded entry. Its original helper declarations,
old selected path and generic fallback are retained. The private body contains
23 helper function declarations plus its returned root function. That extra
lexical construction occurs at module initialization, not during row.probe.
The two new captured host descriptors are also module-initialization work.

Following literal `get(G, name)` references transitively from row.probe gives
Array.get, Array.new, Array.set, b2u, cell, cell.f1–cell.f4, gen, init, prng,
row, row.probe, umin and umin.go. Every one of these definitions is byte-identical
between the two modules. Only batch references pair, and batch is not reached
from row.probe. Public observation is unchanged as well: the same wrapper calls
row.probe, maps its returned descriptor fields to backing arrays, and serializes
them with JSON.stringify. The unobserved local-row modules have the same two
changed sections and unchanged row.probe graph.

The ordinary runtime dispatch/forcing helpers are unchanged. Guard iteration
uses the requested names, not a whole-G scan; adding the private pair body
introduces no extra per-row call to arrayViewHostGuard or pair. On this static
call boundary there is no changed emitted operation reachable during row.probe.
This is stronger evidence against a directly added row-body/guard cost than
against incidental module-wide effects. The larger source, initialized private
closure graph, and shifted source positions are real differences, but neither
byte comparison nor the row timing establishes a JIT, GC, code-layout or
feedback cause. No such cause is assigned here. This investigation executed
no generated target, build, trace or profile for the row comparison.

## Array04 short-fold fixed entry cost

Five-round evidence in `selfhost/build/phase47/corpus-array04/runtime-1/report.json`
shows local-fold(128,0) median 7.705 us baseline versus 16.362 us candidate,
2.124x slower; their observed ranges, 7.391–7.767 and 15.679–16.496 us, do
not overlap. Local-fold(8192,123) instead improves from 173.065 to 110.662 us,
1.564x. These are measured input-specific results, not an inference about JIT.

Exact full local-fold array04 module SHA256 is
`939da9e9644487fcc8cef3b34436a529a796adbab352403c4bd2a7af002a5387`.
Both roots call their existing exact entry wrapper. Baseline's selected path
checks its two U32 inputs and localGuard once. Array04's successful raw path
adds arrayViewHostGuard before those same checks, and returns its private
body directly; it does not execute the subsequent old-path checks on success.
The host guard performs the full fixed descriptor/prototype/name audit
already enumerated above, once per invocation regardless of loop count.
The raw loop still evaluates Number and length for each demanded read/write;
its ordered statement store replaces the original write IIFE. Extra entry
proof cost can outweigh body savings on the short input. Source and these
measurements support that hypothesis but do not quantify its components yet.

Prepared guard-only diagnostic producer `array-guard-probe.py` and controller
`array-guard-measure.py` under `selfhost/tools/performance/phase47`. They are
unexecuted by this agent and frozen pending root consumption. Derivatives are
original, regionHostGuard(true), and bypass of only the array host guard;
all entry canonical-input and localGuard checks remain. Independent scalar
oracles cover (128,0), (4096,17), (8192,123). Five rotated fresh-process rounds
use 1000-ms warmup, 50-ms calibration and 200-ms target. Forty-five processes
require roughly 60–90 seconds; this is not a 30-second plan.

The integer-only diagnostic is not a general safe compiler proposal. Although
array admission rejects F32 literals/operations, it can admit an unused F32
public input whose validation calls Math.fround and Number.isNaN. Reuse of
alias-normalizing root/helper float-signature checks is therefore necessary
before choosing a narrower integer guard. Also, `j_primitive_u32` in
`primitive.bend` emits U32.div using Math.floor: the existing
regionU32FusionHooks retains imul but excludes floor. A general guard cannot
reuse that list unchanged merely because no F32 is present. It must retain
Math.floor as well, with complete primitive/entry/allocation dependency review.
Keep the fresh permission refusal, captured reflection, fill/isSafeInteger,
protocol/prototype checks and original fallback. No input threshold, source-name
rule, or unproved persistent permission is proposed. The diagnostic bypass
remains unsafe regardless of output equality or timing.
