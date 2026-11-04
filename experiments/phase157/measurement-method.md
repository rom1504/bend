# Phase157 same-source native measurement method

Prepared 2026-11-04 from source and host metadata only. This preparation did not
execute a compiler, benchmark target, hardware-counter probe or profiler capture.
It proposes a small adapter around existing process measurement, not another
benchmark framework.

## What is being compared

Use four independently built executables for the **same checked Bend workload**:
`bendc-gc`, `bendc-rc`, `upstream-c`, and `ours-qbe`. Pin the common source, input,
complete expected output, compiler/runtime identities, emitted code, machine
compiler and flags, executable, command, and explicit environment. Record any
backend-specific entry wrapper; common source does not imply identical runtime
implementation or optimization settings. GC versus RC is a useful within-bendc
ablation; comparisons across all four bundles do not isolate memory management.

Name the region accurately: an extracted real compiler pass is a generated
program workload, not a complete compiler request or self-build. A full request
must retain source loading, checking, lowering, emission and final cleanup. Keep
executable acquisition and machine construction separate from execution. No
ratio against historical runs or unrelated self-build timings.

## Smallest useful runner

Reuse `selfhost/tools/build/common.py`: `pin`, `verify`, `fresh_output`, `run`,
`same_bytes`, `write_json`. `run()` already provides a bounded process session,
fresh stdout/stderr files, exact `wait4` user/system CPU and peak RSS, whole-call
monotonic elapsed time, exit status and timeout status. Its elapsed boundary
includes launching the child, opening output streams and watchdog completion;
post-run SHA256 hashing is outside that interval. Keep that boundary identical
for every role. Compute `cpuSeconds = userSeconds + systemSeconds`; Linux
`peakRssKiB` is KiB, not bytes. For these directly invoked native binaries,
process CPU includes all their threads, even if they share one pinned CPU.

The adapter needs only frozen roles/workloads, a bounded calibration loop,
balanced orders, per-call output checks, and summary/report writing. Follow
`experiments/phase154/tools/time-native.py` for complete outputs, calibration and
retained negative evidence; do not import that phase-specific runner. Follow
`experiments/phase156/tools/requests-v2.py` for real-request boundaries and exact
oracles, without copying its phase-specific semantic controls. Pin the actual
adapter and maintained helper in the report, and recheck all input identities
at completion.

`selfhost/tools/bench/bench.py` remains the maintained original-corpus runner.
Its native program catalog has a specific argv/count protocol, and its compiler
mode requires real request/source-to-executable scope. Do not label this new
extracted pass a compiler request merely to fit that schema. The existing
profiler's `run.py::execute()` also reports faults and context switches if those
diagnostics become necessary; a new process supervisor is unnecessary.

## Timing policy and fast-loop budgets

1. Check complete independent output once for every role before timing. Compare
   complete output for every timed request that emits it, and check again after
   timing. An empty benchmark stdout is not a correctness oracle. A source-level
   repetition harness must consume changing results and charge construction,
   allocation, iteration state, final consumption and teardown; it must not
   benchmark a discarded expression or cached constant result.
2. Run one fresh process at a time on CPU3. Record actual inherited affinity
   `[3]`, exact cwd/argv/environment, all raw timings and failures. Reject ambient
   sampling/counter/preload variables. Retain backend-specific runtime settings
   explicitly; single-CPU affinity alone does not make their schedulers or
   worker counts equivalent. Use one runtime worker/GPU off where supported.
3. If the workload has a sound repeated-work interface, calibrate **one common
   work count for all roles**, increasing geometrically until the fastest role
   takes at least `max(0.2 seconds, 3 * maximum zero-work elapsed time)`.
   Zero-work calls are optional only where they mean genuine setup/teardown;
   report their costs without subtracting them. Repetition measures throughput
   inside a fresh process, not cold per-request latency. For a real fixed cold
   request, preserve the request and its clock instead of batching it to erase
   startup. Mark too-short observations as underresolved.
4. For four-role evidence, use four rounds, each with all roles. One balanced
   order is `A B C D`, `B D A C`, `C A D B`, `D C B A`, with the role-to-letter
   assignment fixed in advance. Each role occupies each position once and each
   directed adjacent pair appears once. Four ordinary cyclic rotations are an
   acceptable simpler alternative. A partial block is preliminary, not balanced
   evidence. Keep calibration and output controls outside the timed summary.
5. Qualify only complete oracle-passing observations above the declared minimum
   observed duration; otherwise increase common work or report underresolution.
   Summarize per-role median elapsed, user/system/total CPU and maximum observed
   peak RSS, plus elapsed and CPU ratios to the *same-block* upstream role.
   Show all round values and spread. Four observations do not establish a
   confidence interval or a general compiler speedup. Report wall/CPU divergence
   rather than silently treating scheduler delay as executed work.

Suggested budgets are ceilings, not promises of complete coverage:

| Ceiling | Useful scope after executable acquisition |
| --- | --- |
| 20s | One workload: four correctness controls and a short feasibility/calibration screen; balanced timing only if it fits |
| 60s | One admitted workload, all four roles and one complete balanced block |
| 300s | A few structurally distinct admitted workloads, balanced blocks and held-out output controls |
| 600s | The same bounded matrix with additional confirmation or a separate diagnostic capture |

Include controls, calibration, failed calls and report work in the campaign
budget. Each child deadline is the lesser of its explicit cap and remaining
campaign time. Preserve incomplete results; never silently drop the slow role or
time one role at less work to finish a block. No page-cache flushes: cold means
fresh process and no semantic/object cache reuse, not cold OS storage caches.

## Hardware instruction counts: unavailable in the inspected environment

Read-only host observations:

- Kernel `5.10.0-46-amd64`; `perf_event_paranoid=3`.
- Effective, permitted and bounding capability sets are all zero;
  `NoNewPrivs=1`, seccomp mode2.
- `/usr/bin/perf` is a shell launcher for `perf_5.10`; no matching executable was
  found on PATH or in the inspected `/usr/lib` locations.
- `taskset` and `gprof` are present; `valgrind`, `likwid-perfctr` and an external
  `time` executable were not found on PATH. None is required for `wait4` timing.

These observations provide no usable hardware-counter path and strongly suggest
unprivileged `perf_event_open` will be denied. No actual syscall probe was made,
so record `instructionCounts: unavailable` with these reasons, not a measured
permission-error result. Do not change global sysctls for this comparison.

If a later host explicitly supports counters, use a **separate diagnostic run**
of the exact executable with user-space instructions and cycles, recording event
support, inheritance/thread coverage, elapsed/enabled/running time and any
multiplexing. Compare successful identical-output runs at equal work. Counts of
assembly instructions, symbols, sampled PCs or `gprof` calls are not executed
instruction counts. Rebuilding with `-pg` changes code and is not a clean timing
substitute; simulated-instruction profiling would also be a separate method.

## Optional profiling after a clear difference appears

Reuse `selfhost/tools/profiler/{freeze,run,analyze,compare}.py`, initially for
physical leaf PCs on exact pinned ELF files. Keep instrumented captures out of
clean timing. The current `sample.c` samples **main-thread CPU only** and reports
main-thread/process CPU clocks: require at least95% main-thread coverage before
attributing a whole process. A runtime can execute most work on another thread
despite single-CPU affinity. Low-coverage results remain incomplete, not proof
that the main-thread idle path dominates the workload.

Our QBE dispatch/context hooks and unwind tables do not automatically apply to
bendc's generated functions, custom runtime stack or upstream C. Use physical
ELF/source symbols where available; qualify any rebuilt debug image against
the actual clean machine text before transferring attribution. New diagnostic
runtime hooks require their own source/output checks. Inspect generated code
with maintained `selfhost/tools/bench/inspect.py` or ELF tools as structural
evidence, without presenting lexical/static counts as dynamic execution cost.

## Resource and evidence closure

Root owns the only execution lane. Place the adapter under one outer
`selfhost/tools/build-retention/guard.py` invocation with CPU3,
`--rss-mib 2048`, `--reserve-mib 5120`, explicit whole-run `--disk-mib`, a bounded
`--seconds`, and every fresh `--run-root`. Keep the campaign's16GiB host-headroom
policy via `--available-mib 16384`. Do not nest guards. The guard's observed
process-tree RSS ceiling and `wait4` per-child RSS are distinct measurements.
Do not replace the RSS ceiling with a2GiB virtual-address limit: bendc's runtime
reserves a much larger virtual value stack, which need not be resident.

Retain one canonical executable/emitted product per role, frozen source/input
and oracle bytes, raw observations, exact build/measurement methods and failed
attempts. Avoid per-round executable copies and unnecessary debug rebuilds.
Close the guarded run into verified retained evidence with the existing
build-retention tools. A successful screen establishes only its stated source,
workload, runtime configuration and executable identities.
