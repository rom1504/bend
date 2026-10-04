# Phase46: JavaScript versus C — keep JS primary

Completed 2026-10-04. The selected compiler remains **Phase45 worker23**; no
compiler, runtime or release image changed. The upstream pin remains
`018751270e800bc222a93dad7f257083ee53a5f7`.

**Continue optimizing JavaScript. The existing C backend is useful for diagnosis,
but switching to it would slow sustained execution on five of these six workloads
and roughly tie on the sixth.** Upstream C is substantially faster, demonstrating
native potential that our current native lowering does not realize. Direct LLVM
or assembly would not automatically remove the observed high-level machinery.

The [design](../../design/phase46/backend-comparison.md) was committed and pushed
before measurement (`92c7583`); the harness/protocol checkpoint is `52494a1`.
See the [protocol and retained corrections](protocol.md),
[source/counter findings](source-findings.md),
[machine-readable summary](evidence/summary.json) and
[reproduction guide](../../selfhost/tools/performance/phase46/README.md).

## What was measured

Six existing sources cover numeric recurrence, closures, recursive trees, mutable
arrays, immutable Map updates and mixed control/string processing. All four
products compile the same Bend wrapper: upstream/selfhost, each targeting JS/C.
There are **24 passing one-shot observations, 24 passing final wrapper checks,
96 independent input-cycle oracles, 72 passing timing samples and 72 passing cold
process observations**. These scopes overlap and are not a language conformance
test count. The first native batch wrapper exposed a real IO.args mismatch,
recorded below; that failed attempt is not counted as passing.

Three fresh-process rounds rotate roles. Each paired cell has the same input
schedule, repetition count and warmup count. All measured batches exceed100ms;
the shortest is112ms. Integer-millisecond clocks include checksum formatting and
printing to force the result. This is fixed-warmup batch performance, not proven
V8 steady state or fully position-balanced sampling. Profiles are separate.

Node24.18.0 and Clang22.1.4 run on CPU3, native threads1/GPUoff, with the existing
exclusive guard, a1GiB Node heap,2GiB tree RSS limit and4GiB free-memory floor.
Clang uses `-std=c11 -O3 -lpthread -lm` and its explicit resource-header path;
there is no fast-math. The native sparse virtual heap is not capped by RLIMIT_AS.
The largest supervised process tree was929MiB, below the ceiling; available
memory stayed above25GiB. No OOM or target deadline occurred.

## Sustained execution

Each entry is the median batch duration divided by its invocation count, in
**microseconds per workload invocation**, including the shared Bend observer.
Lower is better. This normalization makes the different batch sizes readable;
all four cells in each row execute exactly the same number of invocations.

| Workload | Upstream JS | Our JS | Upstream C | Our C | Our C / our JS |
| --- | ---: | ---: | ---: | ---: | ---: |
| Numeric recurrence | 7.60 | 9.48 | 3.24 | 47.71 | 5.03× |
| Captured closures | 22.36 | 11.71 | 4.33 | 11.91 | 1.02× |
| Recursive tree | 466.18 | 1458.82 | 148.53 | 1871.32 | 1.28× |
| Array fold | 53.96 | 82.89 | 2.73 | 358.28 | 4.32× |
| Map churn | 751.84 | 1073.53 | 343.75 | 2847.43 | 2.65× |
| Lexer | 2289.35 | 3613.43 | 469.91 | 10331.02 | 2.86× |

Our C/upstream C ratios are14.74× numeric,2.75× closures,12.60× tree,
**131.03× array**,8.28× Map and21.99× lexer. Upstream C beats upstream JS by
2.19–19.73× on these rows. The native target offers a useful ceiling to study;
our current C path offers no sustained-speed shortcut in this sample.

All three samples are retained. Maximum-minus-minimum ranges reach11.6% of a
cell median (upstream arrayC); therefore the1.02× closure difference should be
read as a rough tie, not a meaningful regression. Large gaps are much larger
than observed round variation. The array's initial sub-millisecond calibration
required a second calibration and an explicit15-second slow-cell allowance;
one sample took15.060seconds. All processes stayed within45seconds.

**These results do not replace the maintained Phase45 score of3.0787×.** The
six-source selection is smaller, uses a16-input cycle and calls from a Bend batch
instead of a host JS-library loop. Root context can select a different private
worker and amortize entry guards. Map churn is not the separate Map/Set feature
test with the approximately57× gap. Phase45 already measured closures256 faster
than upstream. No universal speed ranking or full-corpus native result is claimed.

## What explains the native gap

The strongest finding is excessive **call and aggregate transport before machine
optimization**. Upstream turns numeric recursion into a scalar loop and carries
array/accumulator pairs in separate locals. Our C retains curried closures,
capture blocks, heap tuples and many continuation segments. Its host segment
functions are marked noinline. Clang sees the emitted runtime protocol rather
than the original simple source loop.

Two separately instrumented saved-C derivatives compare17 versus1 repetitions,
warmups0. Both retain correct outputs. The difference adds16 workloads; small
argument/printing overhead also changes. Counters include reused allocator blocks.

| Workload/product | Extra heap allocation requests | Extra host segment entries | Extra generic closure entries |
| --- | ---: | ---: | ---: |
| Numeric, upstream C | 2 | 3 | 0 |
| Numeric, our C | 32,821 | 558,426 | 49,277 |
| Array, upstream C | 18 | 3 | 0 |
| Array, our C | 393,340 | 2,885,057 | 327,842 |

The array difference adds65,544 fold iterations. Our diagnostic performs roughly
six small allocation requests,44 segment entries and five generic closure entries
per iteration. It adds only16 array-sized blocks, as does upstream. Generated
Array.set writes in place; the whole-array copying helpers have no generated
callers. This evidence supports tuple/capture/dispatch overhead rather than
per-update array copying. Upstream also uses packed U32 storage while ours uses
generic runtime words, but doubled element width alone does not explain131×.

Instrumentation makes operations observable and can inhibit Clang optimization.
These are counts in the diagnostic derivatives, **not exact allocation counts in
the untouched optimized binaries or a division of the measured time gap**.
The [source findings](source-findings.md) give anchors, predictions and limits.

Four V8 CPU profiles cover numeric and array programs from both compilers. Numeric
profiles place over95% of samples in batch/recurrence loops; array profiles place
most work in the fold/batch loops. Our array profile has about1.6% GC samples,
versus about11.2% upstream, so “more GC” does not explain our remaining JS slowdown
in this case. These profiles include startup, warmup and measured work. Native
sampling was unavailable: the installed perf wrapper cannot find `perf_5.10`.
That failed probe is retained; native operation counters are not sampled profiles.

## Compilation, cold turnaround and memory

Native still offers faster cold process turnaround and lower observed RSS here.
Three-run medians for launching one pure workload and printing its result are
29–47ms upstreamJS,49–89ms ourJS,1.9–2.2ms upstreamC and1.9–9.7ms ourC.
This includes kernel work and readback, **not isolated runtime startup**. Timed
native processes peak around6.7–6.8MiB in most cases; our tree reaches58.4MiB and
lexer10.4MiB. JavaScript peaks around56–94MiB. These are observed process peaks,
not the native runtime's much larger sparse virtual reservation.

Compilation costs work against a wholesale switch for the development loop:

| Batch wrapper | Our JS checked emission, seconds | Our C checked emission, seconds | Additional Clang/link, seconds |
| --- | ---: | ---: | ---: |
| Numeric | 3.33 | 3.78 | 16.18 |
| Closures | 3.35 | 3.84 | 16.58 |
| Tree | 5.70 | 4.82 | 21.88 |
| Array | 3.50 | 3.86 | 16.82 |
| Map | 12.98 | 5.72 | 39.28 |
| Lexer | 7.37 | 4.47 | 21.57 |

These are single acquisition observations including verification/orchestration,
not repeated compiler-throughput benchmarks. The common CLI/batch wrapper makes
our C output1.95–4.03MB, versus upstream's0.116–0.322MB. Simpler pure mains cost
0.64–22.44seconds in Clang for our C; the timing harness materially increases
native emitted size and build cost. This is another reason to simplify lowering
before bypassing C and emitting LLVM IR directly.

## Native semantic gap retained

Our native runtime's IO.args excludes the executable name; active upstream and
both JS products include it. The first batch wrapper consequently ran the wrong
counts only in our C. The final common wrapper reads the final two arguments
and every output is checked against its exact intended count. This is an
experiment adaptation, **not a conformance fix**. The old native help option also
differs in static source inspection; that second observation was not executed.
Native runtime origin6018e28 and its adaptations remain distinct from upstream
0187512, so four-way differences compare complete compiler/runtime products.

## Next action

Return to JavaScript optimization with a narrow, reusable hypothesis:
**a proven fresh private array should permit caching its backing storage and
length outside a hot loop, then emitting direct reads/writes.** The hot JS fold
already forwards tuple fields and avoids generic call dispatch; it still calls
`arraydata` for reads and again through `arrayset` for writes, with handle/tag
checks and index conversion. Upstream uses raw indexed access. This is a more
specific next experiment than assuming the native allocation problem remains
unchanged in our JS output.

First try a saved-output ablation and small independent controls to establish
whether V8 already removes the redundant work. Then implement the surviving
transformation through shared ownership/use/effect facts, run the five canaries
and an affected corpus slice. Require fresh nonescaping storage, preserve alias
writes, zero-iteration and first-demand/error behavior, and retain host conversion
permissions. A public array or opaque callback must not silently inherit the
private proof. No workload-name rules or forecast speedup is needed to test this.

For eventual native work, normalize known calls into explicit argument lists
before closure conversion and scalar-replace local tuples, then consider lowering
proved first-order graphs through a shared high-level representation. A native
primitive/array path is valuable only after its runtime semantics are qualified.
Known-call and aggregate facts remain valuable shared work; this experiment
shows why each target needs its own activation and residual-cost check.
Fix IO.args with a focused boundary test before promoting native CLI behavior.
These are recommendations; no optimization or runtime repair was installed here.

Direct LLVM/assembly is deferred. Clang already supplies LLVM optimization, and
the measured defects arise before that boundary. Native hosting of the compiler
itself also remains a separate, unmeasured question.

## Cost and preservation

The completed375 supervised jobs consumed12.39minutes in total; their occupied
interval union is also12.39minutes because execution stayed serial. This includes
failed setup/wrapper attempts, checked emissions, Clang, calibrations, timings,
profiles, counters and cold runs. Reading, reasoning, agent coordination, report
writing and publication are not individually timed; the remaining elapsed time
must not be called idle. Agents handled source selection, native analysis, oracle
production and independent review while root owned target execution.

The [capsule manifest](evidence/capsule.json) inventories the
[raw evidence capsule](evidence/capsule.tar.gz), including generated sources,
binaries, profiles, failed attempts, commands, tool snapshots and observations.
The [summary](evidence/summary.json) contains full sample values, resource receipts,
compile costs, cold medians and diagnostics. The original design remains frozen.
Unrelated starting work and closed Phase45 evidence are preserved. No PR comment
was posted.
