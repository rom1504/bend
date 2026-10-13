# Phase85: attributing fresh-request cost to V8

Research date: 2026-10-13. This document contains executable-option inspection,
primary-source research and a proposed diagnostic method. **No Bend compiler,
benchmark or generated program was run by this agent.** Root owns all target
execution under the existing resource guard. No production change is proposed
until attribution establishes a mechanism with a meaningful cost budget.

The first question is whether the remaining cost is JavaScript execution,
first-use V8 compilation, allocation/GC, or scheduling of background work.
Faster subsequent requests alone cannot distinguish these explanations.

## Exact local toolchain

Inspected executable:
`/home/ai/.nvm/versions/node/v24.18.0/bin/node`.

| Item | Observed value |
|---|---|
| Node | `v24.18.0` |
| Embedded V8 | `13.6.233.17-node.50` |
| Node binary SHA256 | `41a74efb34cbde5c7632cdac0cf8bd1a14d0b8d73dc1e82755014d9a9ce70f5c` |
| Complete local `--v8-options` output SHA256 | `6f9d611b440a45ed92fa1c0a4914599d7e5a31319ca352af9c8e19f8a1f009d6` |

Commands performed were `--version`, `-p 'JSON.stringify(process.versions)'`,
`--v8-options` and `sha256sum`. The complete options output is temporarily at
`/tmp/phase85-v8-options.txt`; preserve it with root's run evidence if used.
These are option/build observations, not evidence that a particular function
actually reached a tier. Record `process.execArgv`, the Node identity and the
actual environment options with every target run.

The pinned release's [CLI documentation](https://nodejs.org/download/release/v24.18.0/docs/api/cli.html)
describes startup CPU profiling, its default 1,000-microsecond interval, V8 log
processing and the V8 background pool. It warns that V8 options are not stable
Node interfaces; use this executable's options rather than flags copied from a
different release.

## Available controls and their interpretation

The values below come from the local executable's option descriptions/defaults.

| Option | Local meaning / default | Diagnostic use |
|---|---|---|
| `--max-opt=1` | Ceiling at Sparkplug; normal maximum is `999` | Remove optimizing tiers while retaining baseline machine code |
| `--max-opt=2` | Ceiling at Maglev | Remove final-tier optimization |
| `--no-maglev` | Maglev is normally enabled | Optional test of the path directly toward TurboFan |
| `--no-opt` | Alias disabling TurboFan | **Does not disable Maglev** |
| `--disable-optimizing-compilers` | Normally false | Broader optimizer-off alternative; not needed alongside `max-opt=1` |
| `--jitless` | Normally false; disallows runtime executable-memory allocation | Expensive interpreter-oriented endpoint, not the first screen |
| `--no-concurrent-recompilation` | Recompilation normally asynchronous | Optional compiler-scheduling intervention |
| `--no-concurrent-sparkplug` | Concurrent baseline normally enabled | Isolate baseline scheduling alongside the preceding control if needed |
| `--single-threaded` | Normally false; background tasks disabled | Broad intervention including GC; unsuitable as a pure JIT control |
| `--max-optimized-bytecode-size` | `61440` | Function bytecode-size threshold, not source bytes |
| `--concurrent-sparkplug-max-threads` | `1` | Available baseline compiler concurrency cap |
| `--concurrent-maglev-max-threads` | `2` | Available mid-tier compiler concurrency cap |
| `--concurrent-turbofan-max-threads` | `4` | Available final-tier compiler concurrency cap |
| `--lazy` | Enabled | Import completion need not include every function's bytecode compilation |
| `--trace-opt`, `--trace-deopt`, `--trace-osr` | Disabled | Tier decisions, invalidations and active-loop transitions |
| `--trace-baseline` | Disabled | Baseline compilation events |
| `--trace-file-names` | Disabled | Distinguish image, host and upstream functions |
| `--trace-gc-nvp` | Disabled | Collection events in machine-readable form |
| `--maglev-stats-nvp`, `--turbo-stats-nvp` | Disabled | Optional compilation statistics; diagnostic only |
| `--print-bytecode`, `--print-bytecode-filter` | Disabled / `*` | Targeted actual bytecode length and shape |
| `--prof`, `--log-code` | Disabled | Statistical/native attribution and code-event mapping |
| `--log-function-events` | Disabled | Parse/compile/execute events; changes feedback allocation |
| `--runtime-call-stats`, `--rcs-cpu-time` | Disabled | Optional internal timing; confirm output availability in Node |

The pinned [flag definitions](https://github.com/nodejs/node/blob/v24.18.0/deps/v8/src/flags/flag-definitions.h)
confirm that `opt` aliases `turbofan`. `max_opt` weakly disables tiers above its
ceiling. `disable_optimizing_compilers` additionally changes field tracking and
other machinery; `jitless` also changes regexp execution. `single_threaded`
implies GC restrictions. These switches change execution as well as compilation;
differences between their request times are not measurements of JIT time.
Avoid contradictory flag combinations. IR tracing has its own concurrency
implications, so it belongs in a separate targeted investigation.

V8 describes Ignition, Sparkplug, Maglev and TurboFan as tiers with different
compilation-cost/code-quality tradeoffs. Maglev constructs specialized SSA while
building its graph; Sparkplug cheaply generates baseline code from bytecode.
Those architectural facts motivate the ablation, but their published browser
speedups are not predictions for Bend. [Maglev](https://v8.dev/blog/maglev),
[Sparkplug](https://v8.dev/blog/sparkplug).

## Function size: measure the thing the engine limits

Inventory generated source size and maximum individual function size as a cheap
screen, then inspect actual bytecode only for hot or unexpectedly unoptimized
functions. A megabyte module composed of small functions is different from one
large dispatch function. The 61,440 threshold is **bytecode bytes**, so neither
JavaScript characters, lines nor total module bytes establish that it was crossed.

The upstream [V8 13.6.233 tiering manager](https://github.com/v8/v8/blob/13.6.233/src/execution/tiering-manager.cc)
uses bytecode length in interrupt budgets. `InterruptBudgetFor` sharply increases
the budget above the size limit; `ShouldOptimize` also refuses oversized
TurboFan candidates. Thus normal entry to an optimizing tier can be delayed
before final-tier admission. Feedback changes can reset budgets, and OSR follows
its own transitions. This source is the matching upstream version family,
**not a claim that all Node `.17-node.50` patches were audited**.

Use a filtered `--print-bytecode` run to establish lengths and a separate
`--trace-opt-verbose --trace-deopt --trace-osr --trace-file-names` run to establish
what happens. An absent optimization event alone can mean insufficient hotness,
a filter, an outstanding job, unstable feedback or disabled optimization. It is
not evidence of a size bailout. Raising the limit blindly is not an acceptable
optimization: the local option explicitly notes assertion risk at large values.

If an actual hot dispatcher is too large, a general emitter change that splits
it into smaller functions is a testable hypothesis. Its costs include extra
calls, changed inlining and altered register/closure behavior. Preserve exact
compiler output and measure a fresh request before any broad rewrite.

## Attribute compilation, execution and GC separately

Use a common request timeline with boundaries before/after API import, before/
after prepared-state loading, and before/after each actual request. Preserve
the existing headline boundary: imported images/prepared Base are separate from
the fresh checked request. Lazy first-use compilation inside that request stays
inside its time. Do not redefine the metric to make it look faster.

| Evidence | What it can establish | What it cannot establish |
|---|---|---|
| Clean wall time plus process CPU deltas | Actual request latency and total process CPU consumed during it | The portion caused by JIT versus GC versus JS |
| Existing inspector CPU profile | Sampled JS stacks and isolate-thread activity during the selected interval | A census of all background compiler/GC thread work |
| Tier/deopt/baseline trace | Functions selected, compiled and invalidated; reported job durations | Additive request-wall costs when jobs overlap or begin outside the interval |
| GC trace | Observed collections and pauses during the request | Every allocation cost, background GC cost or exact allocated bytes |
| `--prof` with processed log | JS, native/C++ and shared-library sample attribution when symbols resolve | Complete background CPU, or proof that missing symbols were JIT |
| V8 trace events with thread IDs | Where emitted compile/GC slices fall relative to phases and threads | Uninstrumented work or additive totals for nested/overlapping slices |

Node's [process API](https://nodejs.org/download/release/v24.18.0/docs/api/process.html#processcpuusagepreviousvalue)
documents `process.cpuUsage()` in microseconds and notes that multiple CPU cores
can make CPU usage exceed elapsed time. Collect deltas alongside wall time;
retain actual CPU affinity. With the current CPU3-only process tree, background
threads compete for the same core. This is an explanation to test, not evidence
that more cores would provide the missing 25%.

The pinned [CPU profiler implementation](https://github.com/nodejs/node/blob/v24.18.0/deps/v8/src/profiler/cpu-profiler.cc)
constructs a sampler for the isolate's thread and maintains code-event/profiling
state. Treat `(program)`, `(idle)` and unclassified samples honestly; do not
declare them compiler work by subtracting named JavaScript from request time.
Inspector setup also has cost: start/stop profiling outside the measured region
while retaining separate setup clocks.

**`LazyCompile: foo` in a processed `--prof` report names executable JavaScript
code associated with `foo`; its ticks are not milliseconds spent compiling
`foo`.** V8's [sample-profiler documentation](https://v8.dev/docs/profile)
shows these entries under JavaScript execution and separately attributes native
work. For actual compiler time, inspect native compiler stacks or timed compile
events. Keep the raw log and unknown-symbol share; process it with the pinned
Node `--prof-process` rather than a different version's decoder.

GC pause evidence comes from [Node's GC tracing guide](https://nodejs.org/learn/diagnostics/memory/using-gc-traces).
Record event count, collection kind and pause durations. Sum only corresponding
pause fields, not nested/background fields. Heap size before/after a request
cannot recover bytes allocated during it. A separate sampled allocation profile
can locate sites, but samples with/without collected objects and different
sampling intervals are different measures. Do not run heap sampling together
with the first clean or CPU-attribution experiment.

## Minimal sequential diagnostic matrix

### Direct per-thread compilation accounting

For one bounded diagnostic request, enable
`--trace-event-categories=v8,disabled-by-default-v8.compile,node.perf.usertiming`
and choose an explicit `--trace-event-file-pattern`. Add `performance.mark`
boundaries around import and each request. Exit normally to flush the trace;
keep this separate from inspector, IR dumps and clean timing runs.

**Pinned-runtime correction from root's timeline01 run:** these `performance.mark`
calls did not enter the trace. The pinned
[usertiming implementation](https://github.com/nodejs/node/blob/v24.18.0/lib/internal/perf/usertiming.js#L167)
only enqueues/buffers them. The implemented timeline02 bridge instead logs
explicit job/PID/phase/call and `Number(process.hrtime.bigint()/1000n)` to stdout.
The pinned [tracing documentation](https://github.com/nodejs/node/blob/v24.18.0/doc/api/tracing.md#L116)
confirms this is the trace timestamp's time source, in microseconds. That gives
verified request alignment without a private event API. Identify the main thread
from its `JavaScriptMainThread` trace metadata when usertiming marks are absent.

The pinned [tracing controller](https://github.com/nodejs/node/blob/v24.18.0/deps/v8/src/libplatform/tracing/tracing-controller.cc#L107)
samples wall time and `ThreadTicks::Now()` at event begin/end. Its
[JSON writer](https://github.com/nodejs/node/blob/v24.18.0/deps/v8/src/libplatform/tracing/trace-writer.cc#L138)
emits OS `tid`, wall `ts`/`dur`, thread CPU `tts`/`tdur`, and flow `bind_id`.
[Node delegates to that writer](https://github.com/nodejs/node/blob/v24.18.0/src/tracing/node_trace_writer.cc#L99).
First verify nonzero usable CPU timestamps in the actual output. Identify the
main thread from the usertiming marks, not an assumed numeric thread ID.

`V8.OptimizeBackground` encloses a
[TurboFan job's execution](https://github.com/nodejs/node/blob/v24.18.0/deps/v8/src/compiler-dispatcher/optimizing-compile-dispatcher.cc#L84);
`V8.MaglevBackground` similarly encloses
[Maglev job execution](https://github.com/nodejs/node/blob/v24.18.0/deps/v8/src/maglev/maglev-concurrent-dispatcher.cc#L274).
Their prepare/finalize slices and `V8.CompileCode` expose main-thread compilation.
Use flow IDs to connect stages. Sum nonoverlapping outer compilation slices'
`tdur`, never both a job and its enclosing `V8.TurbofanTask`/`V8.MaglevTask`.
Report request-contained slices separately from boundary-straddling slices:
wall overlap cannot justify proportionally allocating CPU time. Wall duration
minus thread CPU is not a measurement of queue delay.

Coverage is incomplete: the pinned
[background Sparkplug compiler](https://github.com/nodejs/node/blob/v24.18.0/deps/v8/src/baseline/baseline-batch-compiler.cc#L44)
has runtime-counter scopes but no equivalent trace-event scope. Uncovered
time must not be classified automatically as JavaScript execution.

The source supports `disabled-by-default-v8.runtime_stats`, with worker tables
emitted as
[`V8.RuntimeStats` / `runtime-call-stats`](https://github.com/nodejs/node/blob/v24.18.0/deps/v8/src/logging/runtime-call-stats.cc#L325).
However, static inspection of this binary finds neither payload string nor
representative counter names, despite advertised flags. This strongly suggests
runtime-call-stat instrumentation was compiled out; availability has not been
demonstrated by a target run. Do not base the diagnostic on those tables or
spend a compiler rebuild to obtain them before using the available trace.

For the isolated lexer TurboFan ablation, pass the literal argv element
`--turbo-filter=-$jd$f_95_lex_95_scanned$scc` (single-quote it in a shell).
The leading minus excludes exactly that function; Maglev has its own filter.
The pinned [filter implementation](https://github.com/nodejs/node/blob/v24.18.0/deps/v8/src/utils/utils.cc#L228)
is not general glob matching: an initial `*` matches everything, so `*$scc`
does **not** select a suffix. `name*` selects a prefix; an unadorned name is exact.

### Screening sequence

Start with **Numeric and Map**, because they exercise different previously
observed costs. Include upstream TypeScript and genuine installed B2 in every
ablation; retain B1 in the initial clean comparison, adding its ablations only
if the B1/B2 difference is the active question. Keep complete output identity,
proof-report boundaries, prepared-state identity and resource limits unchanged.

1. **Clean baseline:** two rotated fresh-process rounds for B1/B2/TS on those
   two cases: 12 requests. Reuse a sufficiently recent, identically bounded
   clean baseline only if its identities and environmental context are intact.
2. **Tier screen:** one fresh request each for B2/TS under `--max-opt=1` and
   `--max-opt=2`, on both cases: eight requests. These large interventions
   screen hypotheses; repeat only a material discriminating result with
   interleaved default controls before estimating a benefit.
3. **Timeline diagnostics:** one B2/TS request per case with tier/deopt/GC
   traces and coarse request markers: four requests. Reuse the existing
   request CPU-profile mechanism in separate runs if its current evidence is
   insufficient; do not turn every measurement into a traced run.

This starts at 24 short requests, not a full benchmark or image rebuild. No
wall-time budget is promised here; root can stop after each stage if the
hypothesis is falsified. Diagnostics should preserve source/API/flags, traces,
exact C and all samples. Run serially under the established RSS/heap guard.

Read the results as follows:

- If optimizer-off is faster cold, the **net** benefit of optimizing during
  this request is negative. Attribute jobs and hot code before deciding whether
  smaller functions, different tier timing or persistent operation is better.
- If Maglev-only is faster than default, investigate final-tier work or churn.
  This does not prove that all TurboFan compilation time is removable.
- If optimizer-off is much slower, optimized code is already valuable; cutting
  source size or compilation jobs indiscriminately can regress execution.
- If GC pauses dominate a sizable portion, address measured allocation sites
  or lifetimes. B2's earlier lower allocation than TS remains relevant; do not
  re-assume a global allocation deficit from B1 evidence.
- If all modes retain the same dominant JS stacks, investigate compiler
  algorithms or generated instruction shape in those stacks.

Only if this matrix indicates compiler scheduling, add a default versus
`--no-concurrent-recompilation --no-concurrent-sparkplug` diagnostic with actual
tier-event confirmation. Do not use `--single-threaded` to attribute JIT alone.
A separate CPU-affinity experiment can test contention, but changing CPU count
changes the hardware condition and must be compared for both compilers.

## Warm requests answer a different question

For an optional same-process series, record the first and every subsequent
request separately, verifying all outputs. Import and prepare once; create a
fresh request through the same API each time. Do not silently switch to a memo
API, cache generated C, skip reporting, or carry compiler semantic products that
the cold API rebuilds.

Call the result **process-reuse benefit**, not JIT savings. Repetition can reuse
bytecode, inline-cache feedback, optimized code, OS file pages, module objects,
runtime caches and heap capacity; it also changes GC and background work timing.
One warm-up call may still leave queued jobs or unstable feedback. A useful
follow-up is a different held-out input after priming the same compiler: this
tests whether benefit transfers, without proving which state produced it.
Run a matched optimizer-off series only if it helps distinguish mechanisms;
the difference of cold/warm gaps is still not pure JIT time because tier choices
also change execution and allocation.

## Escalation tools and observer effects

For an unresolved attribution gap, use
`--trace-event-categories=v8,node.perf.usertiming` with coarse `performance.mark`
boundaries. The pinned [Node trace-event documentation](https://nodejs.org/download/release/v24.18.0/docs/api/tracing.html)
identifies V8 compile/execute/GC categories and user-timing marks; trace timestamps
share the monotonic time source used by `process.hrtime()` and use microseconds.
Check the actual emitted event names and thread IDs before designing a parser.
Preserve nested events rather than summing inclusive durations as separate work.

If low-level compiler attribution remains missing, V8 documents
`v8,disabled-by-default-v8.runtime_stats` for
[runtime-call-stat tracing](https://v8.dev/docs/trace), and its
[RCS guide](https://v8.dev/docs/rcs) describes detailed counters. The CLI examples
are for `d8`; local Node advertises the flags, but this agent has not established
which Node exit summaries or trace payloads are emitted. Confirm that in one
bounded diagnostic before expanding the matrix.

Keep `--log-function-events` separate: the 13.6 tiering source explicitly notes
eager feedback-vector allocation when logging those events. It changes the
state being observed. Avoid `--trace-turbo`/graph dumps and verbose per-node
tracing until one hot function is identified; both output volume and compiler
behavior can differ. Never put tracing/profiling clocks in a clean speed table.

Keep file logs bounded and retain a distinct exact-output receipt. Background
compilation durations may cross request boundaries, overlap and be reported
when a job finalizes, so their sum is neither a request critical path nor
necessarily thread CPU time. Quoting a large trace total as a predicted speedup
would repeat the opportunity-ceiling mistake from the native candidate study.

## What would justify an implementation

A promising result identifies a named cost, its observed phase and tier, a
general source/code-generation change, and a bounded removable fraction. Examples
are a hot oversized dispatcher that never optimizes, repeated deopts caused by
one general object-shape boundary, or material first-use parsing of emitted code
that can be structurally reduced. A flag win alone is not that explanation.

The installed Phase82 compilation ratio remains unchanged by this research.
The rejected Phase84 paired producer remains rejected; no V8 browser benchmark,
warm-request delta or missing profiler samples establish a new parity claim.
