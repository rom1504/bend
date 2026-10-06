# Four-image compiler latency method

The clean screen passed **24 fresh worker processes and 96 checked compilation
requests**. Preparation also passed complete value oracles and exact output
equality for the three Bend compiler images. The full run took **302.934 s**,
including **280.623 s** summed worker wall time; its separately prepared caches
were reused. The [saved-data summary](evidence/latency-summary.json) recomputes
all timing statistics from the actual worker receipts.

It compares the same two compiler inputs through four explicit images:

| Role | Actual compiler |
| --- | --- |
| `raw` | Checked Bend compiler emitted by the pinned upstream TypeScript backend, before image transformations |
| `source` | Installed derived B1: that checked image plus the recorded equality and choice transformations |
| `direct` | The qualified direct B2 emitted from the same Bend compiler source |
| `typescript` | Pinned handwritten TypeScript compiler |

The selected image identities come from Phase56's `image-pins.json`; Phase57's
[setup](../../selfhost/tools/performance/phase57/setup.mjs) verifies the original
checked attempt and B2 provenance. It creates no checked bootstrap sidecar for
B2. Each Bend role has its own private project and API-keyed Base cache. Raw B1
does not inherit the historical source/direct driver-comparison qualification.

## Measured results

All values below are medians in milliseconds across three fresh processes.
“Load” is host import plus actual API loading. “Later request” first takes the
median of the three subsequent requests within each process, then the median of
those three process medians; it is not nine independent samples.

| Input | Image | Load | First request | Load + first | Later request |
| --- | --- | ---: | ---: | ---: | ---: |
| Evening | Handwritten TS | 270.928 | 665.315 | 936.243 | 435.221 |
| Evening | Raw upstream-emitted Bend | 52.310 | 6,080.248 | 6,132.372 | 4,914.050 |
| Evening | Derived B1 | 63.456 | 2,870.013 | 2,933.172 | 1,890.678 |
| Evening | Direct B2 | 104.591 | 4,995.347 | 5,099.937 | 3,459.756 |
| Lexer | Handwritten TS | 269.437 | 377.738 | 646.561 | 260.369 |
| Lexer | Raw upstream-emitted Bend | 53.639 | 3,383.028 | 3,436.847 | 2,372.518 |
| Lexer | Derived B1 | 55.366 | 1,775.839 | 1,831.205 | 1,005.586 |
| Lexer | Direct B2 | 104.569 | 3,102.228 | 3,208.694 | 1,816.816 |

The direct B2 image takes **16.84% less load-plus-first-request time on Evening
and 6.64% less on lexer than raw upstream-emitted Bend**. Its later-request
medians take **29.59% and 23.42% less time**, respectively. Thus this experiment
does not support the explanation that our backend simply makes this compiler
slower than the unmodified upstream backend.

Derived B1 remains faster than both. The raw/derived ratios are **2.091× /
1.877×** for load plus first request and **2.599× / 2.359×** for later requests
(Evening / lexer). Direct B2/derived B1 is **1.739× / 1.752×** initially and
**1.830× / 1.807×** later. B1 includes its recorded equality, 3,315 literal-choice
and 329 tail-choice transformations. This compares their combined image with the
raw image; it does not identify the contribution of any one transformation.

Relative to handwritten TS, derived B1 is **3.133× / 2.832×** for load plus first
request and **4.344× / 3.862×** later. Direct B2 is **5.447× / 4.963×** initially
and **7.949× / 6.978×** later. These are different compiler implementations and
host pipelines, so those ratios are not an intrinsic Bend-language penalty.
TypeScript benefits from removal of its roughly 270 ms import cost on later
requests; the ratio can worsen while every compiler becomes faster.

B2’s actual API load medians are **99.293 ms / 99.422 ms**. Including its roughly
5 ms driver import, loading is only about **2.1% / 3.3%** of its initial totals.
Startup therefore cannot account for most of the observed B2-versus-B1 gap on
these two inputs. Request execution, adaptation, validation and caching remain
within the ordinary-request measurement; CPU profiles are needed to attribute
their costs.

### Individual subsequent-request sequences

Each cell is the three request times, in milliseconds, from one process.
The third subsequent request is still often faster than the first: derived B1
falls about **24–26%** in all six processes, while direct B2 falls about
**10–22%**. Raw Evening also has a conspicuous final-request increase in round 3.
These are warmed windows with clear trends, not established steady state.

| Input | Image | Round 1 | Round 2 | Round 3 |
| --- | --- | --- | --- | --- |
| Evening | Handwritten TS | 482.6 → 510.9 → 383.2 | 451.3 → 435.2 → 359.0 | 429.8 → 481.9 → 343.7 |
| Evening | Raw upstream-emitted Bend | 5,238.7 → 4,751.7 → 4,914.0 | 5,180.8 → 4,489.1 → 4,846.2 | 5,152.6 → 4,467.9 → 6,115.3 |
| Evening | Derived B1 | 2,303.2 → 1,904.6 → 1,721.9 | 2,326.6 → 1,871.1 → 1,744.8 | 2,313.2 → 1,890.7 → 1,714.2 |
| Evening | Direct B2 | 4,049.8 → 3,459.8 → 3,172.4 | 4,072.3 → 3,473.2 → 3,318.3 | 4,127.3 → 3,440.2 → 3,207.2 |
| Lexer | Handwritten TS | 272.7 → 244.7 → 260.4 | 293.2 → 279.0 → 247.2 | 262.2 → 247.3 → 254.8 |
| Lexer | Raw upstream-emitted Bend | 2,716.2 → 2,504.3 → 2,412.5 | 2,708.1 → 2,360.5 → 2,372.5 | 2,563.8 → 2,324.7 → 2,320.3 |
| Lexer | Derived B1 | 1,157.7 → 1,005.6 → 880.3 | 1,165.7 → 901.4 → 864.6 | 1,158.0 → 1,023.4 → 879.2 |
| Lexer | Direct B2 | 1,887.3 → 1,798.9 → 1,706.2 | 1,899.8 → 1,865.4 → 1,717.6 | 1,914.8 → 1,816.8 → 1,695.1 |

The full screen is `selfhost/build/phase57/latency-full01/report.json`, SHA256
`887e5fd28d6bd189159ae77f8a13557e045ee56ede88c515f7de3699f0e7561f`.
The earlier one-round lexer pilot remains separate and is not pooled into these
statistics. No clean profile duration or historical Phase56 timing is pooled
either. These results qualify two compiler workloads, not the 45-point generated
program corpus or compilation of the whole compiler. They do not claim statistical
significance, a stationary throughput limit or a specific causal optimization.

## Timing and checks

The default inputs are `test-evening-program` and `lexer` from the maintained
Phase37 catalog. Preparation primes each Bend Base cache once, compiles both
sources, executes their complete value oracles and compares all three Bend
outputs byte for byte. TypeScript output must pass the same value oracles; its
JavaScript text need not match. Preparation and provenance checks are outside
request timings and remain separately accounted.

Each of three rounds starts a fresh process for each input and role. Role order
rotates cyclically; three rounds cannot fully balance four order positions.
The worker records:

1. Host import: TypeScript compiler modules or the ordinary Bend driver.
2. Actual ordinary `D.loadApi()` time for Bend, including ABI checks/adaptation.
   TypeScript loads during the preceding import, so its separate API time is zero.
3. The first checked direct-library request, and the sum of all three intervals.
4. Three subsequent ordinary library requests in the same process. Every request
   creates a new source book; no persistent inspector or injected API is used.

Every emitted output must remain byte-identical to its role's prepared, executed
oracle. Byte comparison and recording happen after each clean request's clock.
Repeated timings are reported in order and as a median per process; those three
requests are not three independent process samples. Warmed execution is not a
claim of JIT stationarity. Process wall time and peak RSS include preparation
checks, all four requests and reporting, so they are not first-request latency.

There is no OS page-cache flush. Bend has a primed checked Base disk cache, while
TypeScript freshly loads/checks its book. Ordinary API/request code retains its
own hashing, cache reads and validation. Excluded provenance reads differ across
roles and may affect filesystem and heap state. Therefore these are scoped
ordinary-request comparisons, not a language-speed constant or a pure codegen
microbenchmark. Raw-versus-derived B1 isolates the recorded image transformations
more closely than derived B1 versus B2 does.
The first generated file is saved and its bytes checked before the next request;
later outputs are compared and hashed between requests. Those excluded operations
can also affect heap state and scheduling, and are identical in method across roles.

## Replays

From the repository root, with the restored Phase56 artifact paths intact:

```sh
PYTHONDONTWRITEBYTECODE=1 taskset -c 0 python3 selfhost/tools/performance/phase57/latency/run.py selfhost/build/phase57/latency-preparation-NEW --prepare-only
PYTHONDONTWRITEBYTECODE=1 taskset -c 0 python3 selfhost/tools/performance/phase57/latency/run.py selfhost/build/phase57/latency-pilot-NEW --preparations selfhost/build/phase57/latency-preparation-NEW/report.json --cases lexer --rounds 1
PYTHONDONTWRITEBYTECODE=1 taskset -c 0 python3 selfhost/tools/performance/phase57/latency/run.py selfhost/build/phase57/latency-clean-NEW --preparations selfhost/build/phase57/latency-preparation-NEW/report.json
```

The runner owns the single execution guard; do not wrap it in another guarded
target job. Target children run serially on CPU3, with 1 GiB Node heap, 2 GiB
process-tree RSS limit and 4 GiB available-memory floor. Default deadlines are
180 seconds per child and 1,800 seconds overall. Outputs must be fresh Phase57
directories. `--cases`, `--roles`, `--rounds` and deadline options support bounded
follow-ups. Reused preparations retain their original identities and cache files;
they must cover the requested roles/cases and exact same image bindings/tools.

## Separate diagnostics

The diagnostic-only `latency/run-v3.py` successor with `--mode cpu` or
`--mode allocation` runs the same import, first request and three
subsequent requests before enabling the inspector. It then profiles complete
ordinary requests for approximately five seconds, capped at 32 requests; an
active request finishes rather than being truncated. Exact-output validation is
inside the profile window and remains visible as harness cost. CPU uses 1 ms
sampling; allocation uses 128 KiB sampling and includes collected objects.
Raw profiles and summaries are preserved. Neither mode contributes clean timing
statistics. A focused example is:

```sh
PYTHONDONTWRITEBYTECODE=1 taskset -c 0 python3 selfhost/tools/performance/phase57/latency/run-v3.py selfhost/build/phase57/lexer-cpu-NEW --preparations selfhost/build/phase57/latency-preparation-NEW/report.json --cases lexer --rounds 1 --mode cpu
```

The trace mode in `run-v3.py`, inherited from trace-only `run-v2.py`, retains V8
optimization/deoptimization and GC trace output, plus
the driver's existing `BEND_TYPED_TRACE` phase messages. Those flags apply only
to diagnostic sample children, never clean preparation or timing runs. Trace
output includes import and warmup as well as the bounded repeated-request window;
it does not automatically establish per-phase CPU attribution. No global graph,
assembly or inlining dump is enabled. A later targeted trace should use a proven
hot function and its own bounded output recipe.

This successor preserves the consumed clean worker and runner. It adds ordered
`BEND_PHASE57_TRACE` stdout records around host import, API loading, first,
subsequent and diagnostic requests, retaining the same records in `traceWindows`.
Each marker has an ISO wall time and `performance.now()` timestamp. V8 events
without timestamps can be assigned to their surrounding log window; that is the
window in which they were reported, not proof that concurrent optimization work
occurred entirely within it. GC isolate clocks are retained without inventing a
conversion to the marker clock. The exact parent/child edits are recorded in
`latency/trace-markers-v2.json`.

The original CPU attempt failed during profile summarization on small negative
V8 sample deltas; that failure remains separate from the successful clean run.
The v3 worker imports the reviewed profiler successor instead of modifying the
consumed v1/v2 files. Its exact edits are in `latency/profile-successor-v3.json`.

This successor reuses the Phase56 latency boundaries, shared execution guard,
and maintained profile summaries. It does not modify compiler source, installed
images, historical receipts or the generated-program benchmark.
