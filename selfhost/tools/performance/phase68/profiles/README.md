# Phase68 saved-native diagnostics

Root alone runs these commands. They acquire the existing ExecutionGuard and
launch serial CPU3 targets, with a 2 GiB process-tree RSS limit and 4 GiB free
memory floor. Do not wrap them in a second guard. Output directories must be
fresh and inside the root-created `selfhost/build/phase68` directory. Source and
data preparation can use CPU0. No production or Phase67 raw file is changed.

The first command is the strongest cheap fallback when native `perf` sampling
is unavailable. It measures dynamic allocation, refcount and transport counts
for the selected `c76f1113…` native C and pinned upstream C. It derives saved-C
instrumentation, builds it with the same Clang22 `-std=c11 -O3 -lpthread -lm`
recipe, then checks independent outputs at one and seventeen repetitions, with
zero warmups. Subtraction adds exactly one sixteen-input cycle; IO/digest work
also changes. Expected target occupancy is roughly one minute, dominated by
three selfhost C builds. This estimate is prospective.

```sh
python3 selfhost/tools/performance/phase68/profiles/run.py \
  --out selfhost/build/phase68/native-counts01 \
  --cases numeric,array,lexer --roles selfhost,upstream
```

The counters are heap allocation calls/classes/requested capacity, local-list
allocator misses, frees, term keep/drop entries, refcount wrapping and bumping,
units added to refcounts, actual refcount decrement sites, host segment entries
and generic closure entry. Every emitted segment receives its own entry
counter. `topSegmentDeltas` binds the hottest frequency deltas to the original
C symbol and line, decoding Bend's decimal-codepoint symbol spelling. These are
operation frequencies, **not sampled time percentages**. Requested capacity is
not retained memory, useful payload, RSS or operating-system allocations.

The optional bounded `gprof` acquisition adds `-pg` to those same flags. The
unchanged source is rebuilt; its original executable is preserved. It runs a
one-repetition smoke and ten times the Phase67 fast-plan repetitions (roughly
two seconds of uninstrumented selfhost work) with zero warmups. Each result is
checked against the independent oracle. `--profile-multiplier` accepts 1–20.
This mode is primarily for selfhost localization; upstream may be below its
sample threshold at the same work count.

```sh
python3 selfhost/tools/performance/phase68/profiles/run.py \
  --mode gprof --out selfhost/build/phase68/native-gprof01 \
  --cases numeric,array --roles selfhost
```

The report preserves each `gmon` file, exact profiler binary identity and flat
report. `samplingUsable` requires at least 0.1 seconds of attributed samples and
a positive-time symbol; it does not establish precision. GNU gprof samples at
coarse intervals, and instrumentation alters code layout and function-call
costs. Shared-library work and profiling overhead are not fully attributed in
its flat table. Do not interpret `-pg` clocks or its percentages as clean
runtime comparisons. The generated numeric/array sources have `BANGS=0` and
with `--threads 1` enter `work_loop` in sequential mode from main's IO loop;
no pool worker is needed for the hot pure recurrence/fold. Runtime helper
threads remain a limitation of process-wide statistical profiling. Check that
actual hot symbols are workload segments before interpreting a profile.

Every run retains a fresh `perf stat -e task-clock -- true` capability probe.
Source-only inspection found `/usr/bin/perf` is a wrapper dispatching to a
missing versioned executable and `perf_event_paranoid` is 3. No package is
downloaded, no permissions are changed, and failed capability/build/run attempts
remain in their fresh output directory. The runner does not automatically
switch sampling methods if the host changes; a successful perf capability
probe would justify a separate explicit perf plan.

All receipts bind the current source artifacts, original emission/acquisition
receipts, selected immutable API and compiler inputs, native toolchain files,
flags/environment, harness and oracle. Saved C is self-contained; the original
historical upstream acquisition's live installed API need not remain current.
Source/data validation only checked syntax and transformation anchors before
root execution. Numerical conclusions require successful root receipts.

Add `--cases closures,tree,map` in a fresh output folder for broader coverage.
The two products retain different runtime revisions. Counter differences
therefore motivate compiler/runtime hypotheses, and do not isolate one layer
or attribute a percentage of the clean runtime gap to it.
