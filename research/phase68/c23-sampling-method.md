# Main-thread native CPU sampling for compiler23

This is a diagnostic method, not a compiler optimization or a clean performance
measurement. It requires Linux x86-64 and the sequential native benchmark mode
(`--threads 1`, GPU off, no parallel `!` work). It profiles the **generated native
program**, not Node running the compiler.

## Why this method

The available `perf` command is a missing-kernel-tools wrapper and the machine's
`perf_event_paranoid` setting is 3. A `-pg` rebuild provides useful independent
call counts, but instrumentation changes every instrumented function prologue,
which can alter small-call-heavy code. The sampler below uses `LD_PRELOAD` and
leaves executable instructions unchanged. It remains an instrumented run:
signals consume CPU, interrupt execution and may influence scheduling.

The implementation is
[`sample-preload.c`](../../selfhost/tools/performance/phase68/parity-survey/sample-preload.c)
and the reader is
[`sample-analysis.py`](../../selfhost/tools/performance/phase68/parity-survey/sample-analysis.py).
No native benchmark was executed during preparation of this method. GCC strict
syntax checking and Python AST parsing passed. The Lean-bundled Clang alone
could not find `stddef.h`; use GCC for this independent preload library or the
repository's complete Clang include arguments.

## What it records

A preload constructor creates a POSIX `CLOCK_THREAD_CPUTIME_ID` timer on the
initial/main thread. Linux `SIGEV_THREAD_ID` directs notifications to that same
thread. The handler records the interrupted RIP from `ucontext_t` into a fixed
100,000-entry buffer. It performs no allocation, symbolization, I/O or locking;
only guaranteed lock-free atomic counters and the PC store are used. Timer
overruns and full-buffer drops are counted separately.

The default interval is 1,000 microseconds of **main-thread CPU time**, adjustable
through `BEND_SAMPLE_PERIOD_US` from 250 to 100,000. The constructor refuses an
already handled/ignored or initially blocked reserved signal (`SIGRTMIN + 6`).
The target must not subsequently use that signal. Normal exit disables sampling
and writes the PCs, final `/proc/self/maps`, main-thread CPU time, wall time,
sample/drop/overrun counts and a signal-handler-integrity flag. The file is
created exclusively at startup; an existing path is never overwritten.

Only normal exit produces a complete file. Timeout, `_exit`, signal death, write
failure or a different thread initiating exit leaves invalid or incomplete
evidence. The analyzer rejects incomplete output, empty profiles, full-buffer
drops, changed handler disposition and exit on another thread. Keep such failed
attempts rather than replacing their output.

## Build and execution

Run all target compilation and execution through the root's existing single
CPU3 resource-guard lane. The commands here are the **inner commands**, not a
replacement for that guard. Use fresh paths under the new Phase68 survey run.

```sh
gcc -std=c11 -O2 -Wall -Wextra -Werror -fPIC -shared \
  selfhost/tools/performance/phase68/parity-survey/sample-preload.c \
  -o /absolute/fresh/sampler.so -lrt
```

Rebuild the saved generated C with exactly its original optimization flags,
defines, runtime inputs and toolchain, adding `-g` for inlined function/line
information. Check `.text` equality with the saved executable before treating
the profile as belonging to that executable. `-fno-omit-frame-pointer`, `-pg`
and sanitizer flags are unnecessary and would change the code being profiled.

```sh
env LD_PRELOAD=/absolute/fresh/sampler.so \
  BEND_SAMPLE_OUT=/absolute/fresh/tree-current23.samples \
  BEND_SAMPLE_PERIOD_US=1000 \
  /absolute/current23-debug-executable [the existing benchmark arguments]
```

Apply `LD_PRELOAD` only to the target child: do not preload the shell, guard,
`taskset`, `time`, Python or the compiler. Preserve stdout/stderr, exit status,
arguments, tool/library/executable hashes, resource receipts and the existing
independent output oracle. Profiling success does not replace correctness.

```sh
python3 selfhost/tools/performance/phase68/parity-survey/sample-analysis.py \
  --samples /absolute/fresh/tree-current23.samples \
  --baseline /absolute/saved-clean-executable \
  --debug /absolute/current23-debug-executable \
  --output /absolute/fresh/tree-current23.profile.json
```

The analyzer independently requires equal `.text` SHA-256 values for the clean,
sampled and debug executables and equal sampled/debug `.text` address layouts.
It maps the sampled PC through `/proc/self/maps` and ELF `PT_LOAD` offsets before
calling `addr2line -a -f -C -i`. It records leaf function, outer emitted function,
inlined source location, raw PC counts and separate shared-library/unmapped
counts. Inline ancestors are **lexical DWARF ancestry**, not a dynamic call
stack. Shared libraries are bucketed by mapping, not silently charged to the
nearest executable function. All percentages use every sample as denominator.

If a `-g` rebuild changes `.text`, do not override the gate. Either choose a
debug build configuration that preserves it or establish a separate clean
timing baseline for the new binary and label that scope. Equal `.text` is a
machine-code check; it does not establish data-section, source, toolchain,
runtime or input identity, which still belong in the campaign manifest.

## Statistical and interpretation limits

- Sample startup, runtime initialization and teardown are included. Choose
  enough benchmark repetitions that the intended computation dominates, and
  keep candidate/upstream input work identical.
- Aim for several thousand delivered samples per role before making precise
  hot-path percentage claims. A 200 ms run at 1 ms has only roughly 200 samples.
  Treat first shorter runs as method smoke tests.
- Repeat a key profile at another interval (for example 997 or 1,307 us) to
  detect fixed-period aliasing. Linux CPU-timer delivery granularity and
  delayed signals can differ from the nominal interval; report overruns and
  achieved sample rate. Do not distribute overruns across observed PCs as if
  the missing samples had known locations.
- This has no dynamic call stack, allocation attribution or hardware counter
  data. Relate hot inlined source lines to generated-code structure and separate
  operation counts; a frequent operation is not necessarily expensive.
- Samples cover the initial thread only. If worker/GPU activity matters, this
  method is insufficient. It also cannot apportion waiting time or explain
  off-CPU costs.
- Compare candidate and upstream with identical work and clean runtime ratios.
  A hot percentage is a share of that role's CPU time, not a speedup estimate.
  For a rough absolute cost screen, multiply by clean main-thread runtime and
  label the startup and sampling assumptions.
- Keep profiled clocks out of clean speed ratios. Establish overhead with a
  paired unprofiled/profiled smoke if overhead might materially change the
  workload. A large or unstable overhead invalidates direct interpretation.

This method is intended to discriminate representation, allocation, ownership,
direct-call and scheduler-boundary hypotheses before compiler changes. It does
not by itself demonstrate that any proposed transformation is safe or faster.

## Coverage check added before the first successful profile

The frozen original sampler remains above. The follow-up
[`sample-preload-v2.c`](../../selfhost/tools/performance/phase68/parity-survey/sample-preload-v2.c)
adds a `CLOCK_PROCESS_CPUTIME_ID` start/end measurement and the footer field
`process_cpu_ns`. GCC strict syntax checking passed. The existing analyzer
retains this extra field without changing the original parsing contract.

The runner must record `main_thread_cpu_ns / process_cpu_ns`. A profile can be
valid for its main thread while omitting substantial worker computation. Use a
ratio of at least 0.95 as a screening requirement before treating its shares as
near-complete CPU attribution, and disclose the remaining omission. A ratio
below that threshold requires worker sampling or a separately qualified
sequential diagnostic. Thread flags alone do not establish this coverage.

This check uncovered a concrete difference in the saved generated C:

| Family | compiler23 `BANGS` | Upstream `BANGS` |
| --- | ---: | ---: |
| Numeric, array, closures, Map | 0 | 0 |
| Tree | 39 | 0 |
| Lexer | 16 | 0 |

This is not merely an unexplained flag difference. The imported historical
[tree fixture](../../selfhost/tools/performance/phase37/fixtures-historical/tree-bitonic.bend)
contains an unused original `main()` calling `bsort!` and `scan!`. Its benchmark
entry `bench` calls the same functions without bang. The imported
[lexer fixture](../../selfhost/tools/performance/phase37/fixtures-historical/lexer.bend)
likewise has an unused original `main()` calling `batch!`, while `bench` calls
ordinary `batch`.

[`nc_bangs_book`](../../selfhost/src/back/native/book.bend) scans every definition
body before reachability from the active main. `nc_compile_def` then marks
reached functions whose names occur in this whole-book set. The resulting tree
flags name exactly the direct `bsort`/`scan` segments and their continuations;
lexer flags name direct `batch` and its continuations. `nf_candidates` and
`nq_candidates` also consult this whole-book bang set, so it can restrict worker
admission. Upstream collects `FL.bangs` while walking its reachable-definition
queue, excluding the unused imported mains.

In the saved compiler23 runtime, `corpus_eval` chooses its first `work_loop`
mode with `!BANGS && (pool_size == 1 || fid_nofk(...))`. A fork reply can then
enter `pool_open` and `cube_run`; `--threads 1` still permits a separate pool
worker. Therefore these false bang roots are a plausible cause of both missing
main-thread attribution and excess scheduler/continuation work. The source
inspection establishes the metadata discrepancy; it does **not** establish its
runtime speed effect. A saved-C diagnostic and eventually reachable-scope bang
analysis are the discriminating next steps. A general correction must preserve
genuinely reachable bang references, closure reachability and device roots.

## Sampling the persistent worker threads

The first main/process clock observations confirmed that the unchanged
compiler23 tree and lexer execute almost all their CPU work away from the main
thread. Their sparse main-thread samples remain useful coverage failures, not
CPU profiles of the complete computation. The follow-up
[`sample-preload-threads.c`](../../selfhost/tools/performance/phase68/parity-survey/sample-preload-threads.c)
interposes `pthread_create` and installs the same thread CPU timer inside a
wrapper around each created thread's entry function. Build this derivative with
`-pthread -ldl -lrt` and the existing shared-library flags. Earlier sampler
versions remain unchanged.

The derivative supports at most 32 lifetime threads, each with a fixed 25,000-PC
buffer (approximately 6.4 MiB altogether). Initial-exec thread-local storage
holds the handler's slot pointer, avoiding allocation or `__tls_get_addr` on the
signal path. Every PC prefix is published with release/acquire atomic counters.
No sample storage is reused or freed. A cleanup handler records final CPU time
for returning, exiting or cancelled threads; live thread clocks are queried at
main exit. The native pool workers loop indefinitely and are not joined, so the
sampler deliberately does not attempt to join them.

At exit a global flag suppresses further recordings and each published timer is
disarmed. The sampler dumps only fully published PC prefixes. It never deletes
timer IDs or restores the signal disposition while a live thread could still
be finishing a notification; process exit reclaims this bounded state. This is
an exit-only diagnostic library, not a reusable profiler for `dlclose`, forked
processes or unbounded thread creation.

The format retains the existing analyzer contract but adds
`sampler_scope=all_created_threads` and these coverage fields:

- `sampled_thread_cpu_ns`: sum of captured CPU deltas across registered threads.
- `threads_allocated`, `threads_ready`, `threads_ended`: slot/lifecycle counts.
- `thread_overflow`: threads beyond the fixed capacity, which run unprofiled.
- `thread_clock_failures`: live/exited clock attribution failures.
- `timer_disarm_failures`: diagnostic failures while stopping thread timers.

Require no overflow, all allocated slots ready, no clock failures, and
`sampled_thread_cpu_ns / process_cpu_ns >= 0.95` before making near-complete
process CPU claims. A failed `pthread_create` leaves a conservatively unready
slot; retain and label that attempt. Check any timer-disarm failure separately.
Different thread windows have small startup/shutdown offsets, so coverage is a
screen rather than an exact CPU accounting identity. The analyzer's original
hardcoded main-thread-only limitation is superseded **only** when this explicit
sampler scope and its coverage evidence are retained; its no-dynamic-stack and
sampling-overhead limitations still apply.

Strict Clang22 syntax checking, using the recipe's bundled include path, passed
before handing this derivative to the root's guarded build/run lane. Preparation
and review did not execute any native target in this source-only lane.

Use the accompanying
[`sample-analysis-v2.py`](../../selfhost/tools/performance/phase68/parity-survey/sample-analysis-v2.py)
for this derivative. It preserves the first reader unchanged, parses optional
thread/CPU fields as integers, emits scope-correct limitations, and records a
`coverage` summary with the above 95% process-CPU and lifecycle checks plus a
500-sample minimum. A partial main-thread profile remains readable with
`usable_for_process_cpu_attribution=false`. Parsing the saved samples03 tree
candidate, upstream tree and closure candidate profiles confirmed that the
candidate tree's roughly 0.94% main-thread CPU coverage is rejected for process
attribution while the other two samples have approximately complete main-thread
CPU coverage. This check was offline; it did not rerun target programs.
