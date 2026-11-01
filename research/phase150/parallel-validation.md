# Phase150 separate-process validation pilot

Status: the bounded two-process pilot passed on Node. All eight independent
correctness reports pass, with exact QBE, objects and outputs across schedules.
The selected workflow averages 3.269→1.936s (40.8% less elapsed time), over two
alternating pairs. This is scheduling feasibility on two small retained fixtures,
not a compiler/program benchmark or a change to serial production policy.
The Bun runtime control failed and remains negative evidence. Compiler source,
runtime, qualification tools and installed selections are unchanged.

The bounded question is whether two independent finite correctness jobs finish
sooner when their native compiler processes overlap. This does not enable multiple
heap mutators inside a QBE process and does not measure a compiler optimization.
The current [parallel-validation proposal](../../docs/self_hosted/parallel-validation.md)
remains the broader, unimplemented scheduling policy.

## Existing machinery and the narrow missing piece

The maintained [qualification runner](../../selfhost/tools/build/qualification.py)
accepts explicit catalog subsets. It authenticates the image, Base, providers,
fixture and oracle; compiles and builds each selected program; executes with
`--threads 1 --gpu off`; compares full stdout/stderr and exit status; and retains
all case-level receipts. Its loop is serial and it does not acquire a guard.
Two separate invocations can therefore use disjoint output roots beneath the
same aggregate supervisor without modifying a host tool.

The maintained [disk guard](../../selfhost/tools/build-retention/guard.py) accepts
a CPU mask and follows its one child process tree. Its RSS limit applies to the
whole tree, including both compiler jobs, coordinator and tools. One invocation
retains the usual shared Phase32 lock, disk reserve and available-memory floor.
The pilot never starts a second guard or uses another lock path. These are
sampled safeguards, not hard kernel memory/disk quotas or independent per-worker
reservations. A shared 2 GiB aggregate limit is deliberately small for two small
fixtures. Each worker therefore also fits within that total reservation.

There is an important backend boundary. The pinned direct-JS
`Process.run` provider in `selfhost/.bootstrap/upstream-phase66/bend2/effs/process_run.js`
uses `Bun.spawnSync`. Merely writing `IO.fork` does not establish concurrent
subprocess execution on that backend. The maintained descriptor JS runtime
[`selfhost/src/runtime.mjs`](../../selfhost/src/runtime.mjs) already implements
asynchronous `Process.run` using `node:child_process.spawn`, with separate pipes,
a combined output cap and direct-child timeout. `IO.fork` schedules asynchronous
actions there. The selected public CLI exposes this existing backend explicitly
as `--legacy-js`; using it requires no new JavaScript orchestration code. The
helper is source-checked and acquired with the pinned Bun, then the frozen
generated coordinator executes with the already pinned Node24.22.1 and
`--max-old-space-size=1024`. The reason for this engine boundary is the exact
runtime-control evidence below.

The current direct-QBE effect table does not bind `Process.run`. Its
[runtime contract](../../selfhost/src/runtime/qbe/README.md) permits host IO
workers while retaining exactly one Bend heap mutator. The pilot uses the
descriptor-JS coordinator and separate ordinary QBE subprocesses, avoiding any
runtime/provider expansion.

The maintained [benchmark runner](../../selfhost/tools/bench/bench.py) checks a
single CPU affinity and rotates fresh roles serially. It is untouched and does
not run inside these throughput jobs. No profiling or generated-program timing
may overlap the pilot's root-owned lane.

## Fixed experiment

The helper is
[`parallel-validation.bend`](../../selfhost/tests/phase150/parallel-validation.bend).
Its only real jobs are `focused/nt-reverse` on CPU0 and `focused/lexer-scan` on
CPU1. Both are retained independent whole-output controls from the maintained
catalog. Their native image is explicitly `assets-native.json:qbe-n2`; all other
qualification settings and CPUs are identical in serial and parallel modes.
Each starts with a fresh process and fresh output directory. Prepared Base is
read-only. Compilation of the helper disables the hosted Base cache to avoid
creating shared preparation artifacts.

[`parallel-validation-plan.json`](parallel-validation-plan.json) records exact
argument arrays, fresh artifact/guard roots, deadlines and expected controls.
The root executed the independent upstream source check, coordinator acquisition,
positive Node control and outer cancellation before
the order `serial01, parallel01, parallel02, serial02`. This gives two alternating
serial/parallel pairs. It is a feasibility screen; the earlier policy's three
complete alternating trials and adoption criteria remain unmet by this smaller
design alone. The maintained `hosted.mjs acquire` and `stage0-library.mjs` check
the complete standalone book with upstream `book_valid`, reject unresolved
holes and emit only the pure `p150pv_summary` export. The
[export selection](../../selfhost/tests/phase150/parallel-validation-exports.json)
declares a JS component API for the acquisition tool's metadata contract; it is
not an executable compiler API. Require its `complete:true, checked:true` receipt
before treating the source as independently checked. Legacy-backend compiler
acceptance is a separate observation; neither establishes a BendTT kernel proof.

Each child `Process.run` has a 65,536-byte combined output ceiling and 75-second
timeout. Each qualification source request has 20 seconds, machine construction
20 seconds and execution 10 seconds. The outer trial has 160 seconds, 128 MiB
additional disk, 2 GiB aggregate tree RSS, 16 GiB available-memory floor and the
unchanged 5 GiB disk reserve. The root must verify current CPU topology and
affinity before scheduling CPU0/1; the historical proposal describes them as
different physical cores, with siblings4/5.

The coordinator logs task-labelled start/end clocks, complete subprocess stdout,
stderr and exits. It requires the exact current qualification success-summary
prefix and counts, exit0 and empty stderr. This is a transport check; it does not
replace reading the complete reports. The root must audit the exact two case IDs,
`complete` and `passed`, unchanged inputs, the retained independent oracle
comparisons and complete emission/build/execute receipts. An exit0 alone is
insufficient. Corresponding emitted QBE, program objects and outputs must match
across all schedules. Missing results, unsupported cases and any mismatch fail
the pilot; no favorable subset replaces the fixed selection.

`control` checks separate alpha/beta subprocess pipes, Linux timeout110 and
rejection of an empty success summary. Its complete expected stdout is a
[separate literal fixture](../../selfhost/tests/phase150/parallel-validation-control.stdout).
`cancel` starts a 60-second sleep while the outer guard expires after two seconds;
it must leave an incomplete deadline receipt and no owned descendants. The root
must inspect process termination before admitting further work. `Process.run`
owns only its immediate child; descendant cleanup remains the outer supervisor's
responsibility. No general daemon/process-group scheduler is claimed.

## Evidence and decision boundary

Report the outer guard's monotonic `wallSeconds` as selected-workflow completion
time, including supervisor/startup, input verification, compiler/machine work
and exact output checks. The descriptor runtime's `IO.now` currently uses
`Date.now`, so those logged task clocks are wall-clock overlap diagnostics only.
They are neither a high-resolution monotonic timer nor generated-program timing
samples. Both native programs run fixed ordinary correctness inputs; their
durations do not become a runtime benchmark score.

Record sampled aggregate peak RSS, minimum available memory, disk peak,
before/after swap counters, command affinities, source/tool identities and full
failure evidence. Report each paired wall ratio and its direction; two pairs
cannot establish a stable confidence interval or a full-campaign gain. A fast
parallel result does not qualify arbitrary worker counts, host lease arbitration,
cached acquisitions or broad parallel compiler validation.

After each guard, reconcile full reports and check descendants. Before returning
to measurement mode, drain the pilot completely and verify quiet CPUs/processes.
The unchanged shared lock excludes other cooperating jobs for each window; root
scheduling excludes noncooperating targets. Close every run, including expected
cancellation, through maintained `close.py`, retaining the exact compiler/program
outputs and receipts or a verified archive. No retention pruning is needed for
this bounded experiment.

The fixed native target is the consolidated ordinary QBE N2 asset
`367b639915c0bbc8906fc5827b002ca2c7fc07acc238034e54be994f8833d251`
(19,100,528 bytes), whose metadata retains the qualified Phase146 source
identity and canonical-source equivalence. It is not a Phase150 compiler
candidate and does not provide new Phase147/150 qualification. The coordinator
uses the selected installed JS B2 API separately. Both identities must remain
fixed across all schedules.

The root's `parallel-source-check01` failed after about0.84s because the first
draft placed `match args` within a `do` block; this parser permits that match
at the head of a separate definition. Its rejected source is preserved at
`selfhost/build/phase150/parallel-source-check01/rejected-source.bend`.
The helper now calls a separate `p150pv_args`. The second source check rejected
an inference boundary in `p150pv_observe`, pointing to the dependent `Pair`/Sigma
type while unpacking nested positively annotated fields. That exact source is
preserved in `parallel-source-check02/rejected-source.bend`. The helper now
unpacks the ordinary unannotated tuple pattern used by the pinned Process.run
tests, then passes the four fields to an explicitly typed logging function.
`IO.fork`/`IO.join` use the same explicit result types as the pinned
`tests/io/process_run_parallel.bend` control. The plan now names fresh
`parallel-source-check03` passed, followed by `parallel-acquire01`. These source
rejections are not pilot observations. The checked/acquired source identity is
`38a3d4777c69858baf8954c9b00af0ee708fe51e8ab5270e816dc2d3abc77c7b`
(5,464 bytes), copied to `parallel-acquire01/source.bend` before further edits.

`parallel-control01` failed in0.230s with exit1 after confirming empty-summary
rejection. The original combined condition did not identify which pipe or timeout
branch failed. The consumed expected output is preserved in that control's
`expected.stdout`; the exact generated coordinator remains in acquire01.
Offline inspection confirms the generated program retains the existing async
`Process.run` registration and guards its foreign fallback with `!hasOwn(G)`.
This does not establish whether Bun's process event ordering, an OS failure or
another runtime boundary caused the failed observation.

The diagnostic revision prints the actual exit/streams or error code/message of
each pipe and the timeout result before applying the same original criteria.
It uses consuming, explicitly typed helpers to avoid duplicating nested result
patterns. Source-check04 independently accepted the complete6,919-byte source
`ef0c032daf9141e444e08653d25e7deee6acf27483a63426d25eda4301c2b3c6`,
with `complete:true`, `checked:true`, child status0, no error and exactly the
`p150pv_summary` component export. This is a component/source check, not an
executable compiler API or kernel proof. Acquire02 produced the411,620-byte
coordinator `38d6e8d4023f96e02ff79598447dc8d98a20e13d473da264bc9a87679d18e0e0`.

The diagnostic Bun control02 returned errno1 (`Operation not permitted`) for
both alpha/beta pipe operations. Its timeout branch correctly returned errno110.
The same generated coordinator, unchanged, passed `parallel-node-control01`
under Node24.22.1: both exact pipe outputs, timeout110, empty-summary rejection,
exit0 and empty stderr match the independent fixture. Thus the evidence locates
an engine/provider boundary for these process operations. It does not establish
the underlying Bun/OS failure mechanism, generic Bend parallel support or a
runtime repair. No runtime or provider was edited.

The selected Node executable is126,879,696 bytes with hash
`e32e2d16081cf644f88392934288086e7662529d0d43277c34f7aad2207cfafb`,
already pinned by maintained law assets. The plan records its explicit path and
1 GiB heap cap for control, cancellation and all trials; acquisition remains on
Bun. Completed setup paths are marked consumed. Cancellation01 and all four
trial output paths are now consumed evidence.

[`parallel-pins.json`](parallel-pins.json) freezes41 inputs before those trials:
source, source-check evidence, component API, acquired coordinator, successful
Node control, current selector, compiler/tool/runtime assets, qualification
methods and exact two source/oracle pairs. It records the successful independent
source-check audit. All 41 pins remained unchanged after the trials. The consumed
plan and helper have not been edited.

## Measured outcome and independent audit

The [result capsule](parallel-results.json) records the complete receipts,
per-case hashes, direct byte comparisons, task intervals and resource evidence.
The root executed all targets; this investigation's audit performed only file
reads, hashing, `cmp` and `readelf` inspection.

| Schedule | Guard wall seconds | Peak aggregate RSS, MiB | Task overlap, ms |
| --- | ---: | ---: | ---: |
| serial01 | 3.550699 | 107.11 | 0 |
| parallel01 | 1.963697 | 150.34 | 1,138 |
| parallel02 | 1.908356 | 156.13 | 1,092 |
| serial02 | 2.987908 | 107.35 | 0 |

The paired elapsed reductions are 44.7% and 36.1%. The two-sample means, also
the conventional two-sample medians, are 3.269304s serial and 1.936027s parallel:
0.5922× elapsed, or 1.689× selected-workflow throughput. Both pairs favor the
parallel schedule. The first serial run is appreciably longer than the second;
startup, cache and host variation are included, not separately explained.
These few small jobs provide no stable confidence interval, full-campaign gain
or generated-program speedup. Task overlap uses the documented wall clock and
is a scheduling diagnostic, not the source of the elapsed comparison.

All eight reports have the exact one-case selection, `complete:true`,
`passed:true`, pass1/fail0/unsupported0 and empty `changedInputs`. Each emission,
machine build and execution completed. All compiler and generated-program
commands retain `--threads 1 --gpu off`; the fixed taskset commands assign
nt-reverse to CPU0 and lexer-scan to CPU1 in both schedules. This verifies two
independent compiler processes with separate heaps; it enables no additional
mutator within either process.

The audit rehashed 162 distinct declared input/receipt/product pins without a
conflict or mismatch, including the 41 pretrial pins. Eight direct byte
comparisons match execution stdout to the independent retained oracle. Another
24 compare each case's complete QBE, object, stdout and assembly against
serial01 across the remaining schedules; all pass. The QBE files are actually
retained under each case's `emission/program.ssa`, so this is direct byte
comparison in addition to matching digests.

Six supplementary whole-ELF comparisons differ. In the inspected nt-reverse
serial01/serial02 pair, `readelf` identifies a single changed byte in the linker
FILE symbol containing the fresh absolute `program.o` path. Parallel names also
have different path lengths and their first difference lies in the build-ID
note. No whole-ELF equality or general normalization rule is claimed. The
unchanged QBE/object/assembly and exact independent output gates remain the
declared correctness evidence; all distinct executables are retained.

Parallel peak aggregate RSS is 156.13 MiB, versus 107.35 MiB for serial, within
the shared 2 GiB ceiling. Minimum sampled available memory is 23.801 GiB, above
the 16 GiB floor. Each trial allocates about 1.58 MiB under its 128 MiB disk budget.
The retained before/after host snapshots show unchanged `pswpin=60599`,
`pswpout=426877` and `oom_kill=0`; existing swap use did not increase.

Cancellation01 stopped for the expected outer deadline at 2.008152s and retained
exactly `cancel-control child-start` plus its newline. The root reported checking
that no owned sleep60/coordinator process remained; no separate persisted process
snapshot was supplied. Ordinary trials all exited0 with empty guard stderr.
This establishes the bounded cancellation control, not arbitrary daemon cleanup.

Retain this explicit Node-backed two-process correctness helper as feasible.
Do not infer a general scheduler or adopt a higher worker count: only two
fixtures and two alternating pairs were run, and the broader proposal's
three-trial, admission and measurement-lease rollout remains unqualified.
Root scheduling and the existing single guard continue to own quiet windows.
Campaign-wide costs and retention closure are accounted for by the root.

## Repeat the fixed parallel selection

After checking the frozen inputs and reserving the root's correctness lane, use
fresh paths for one bounded replay:

```sh
python3 -B selfhost/tools/build-retention/guard.py \
  --out selfhost/build/phase150/parallel-replay01-guard \
  --run-root selfhost/build/phase150/parallel-replay01 \
  --seconds 160 --disk-mib 128 --rss-mib 2048 --available-mib 16384 \
  --file-mib 128 --cpu 0,1 -- \
  /home/ai/.nvm/versions/node/v24.22.1/bin/node --max-old-space-size=1024 \
  selfhost/build/phase150/parallel-acquire02/coordinator.mjs -- \
  parallel selfhost/build/phase150/parallel-replay01
```

Change `parallel` to `serial` and use another fresh root for the same two jobs
without overlap. Inspect both complete qualification reports and independent
oracles, then close the guard through the maintained retention workflow.
This fixed helper is not an interface for arbitrary compiler candidates or
performance benchmarks.
