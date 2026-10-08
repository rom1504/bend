# Phase67 native loop

Root alone executes target jobs; all commands below own the existing single
ExecutionGuard, use CPU3, 1 GiB Node heap, 4 MiB stack, 2 GiB tree RSS and a 4 GiB
available-memory floor. Do not wrap them in another guard or run concurrently.

`freeze.py` only hashes files. `run.py acquire` emits current TypeScript and Bend
native C for the same maintained Phase46 wrappers, builds both with the same
Clang22 and `-std=c11 -O3 -lpthread -lm`, and checks three independently computed
results. No fast-math; native threads1/GPUoff. Compilers, source, C/runtime effect
providers, compiler driver/core shared libraries, linkers, resource headers and method identities are frozen before
execution and checked again afterward. Selected C include/library environment variables are recorded and checked; the
system C library/OS are host dependencies, so this is not a hermetic toolchain.
Current installed release integrity is
verified. Use `--api <checked api>` to freeze a separately named candidate recipe.

```sh
python3 selfhost/tools/performance/phase67/benchmark/freeze.py \
  --out selfhost/build/phase67/native-baseline02-recipe.json
python3 selfhost/tools/performance/phase67/benchmark/run.py acquire \
  --recipe selfhost/build/phase67/native-baseline02-recipe.json \
  --out selfhost/build/phase67/native-baseline02 --cases numeric,array,closures
python3 selfhost/tools/performance/phase67/benchmark/run.py calibrate \
  --recipe selfhost/build/phase67/native-baseline02-recipe.json \
  --acquired selfhost/build/phase67/native-baseline02 \
  --out selfhost/build/phase67/native-calibration02
python3 selfhost/tools/performance/phase67/benchmark/run.py measure \
  --recipe selfhost/build/phase67/native-baseline02-recipe.json \
  --acquired selfhost/build/phase67/native-baseline02 \
  --plan selfhost/build/phase67/native-calibration02/plan.json \
  --out selfhost/build/phase67/native-timing02 --rounds 4
```

Add `--cases tree,map,lexer` in a fresh acquisition and pass both acquisition
folders to calibration/measurement when expanding; also pass
`--cases numeric,array,closures,tree,map,lexer` to those commands. `--roles selfhost` avoids
rebuilding the reference for a candidate. Never combine recipes/images in one
run; compare their complete reports afterward. Runtime iteration reuses the
binaries and never repeats Bend or Clang compilation. All output folders are
fresh; failures remain recorded.

Acquisition clocks distinguish import/setup, checked Bend-to-C request and
Clang build. Selfhost prepares API-specific Base before its request; TypeScript
loads Base during checking. Thus these acquisition clocks are a useful native
pipeline diagnostic, not the existing Phase66 JS compilation-parity score.
Clang wall clocks include process launch and polling. Runtime is independently
timed inside the program, with the same input cycle, repetitions and warmups
for both roles. Startup, emission and C build are excluded; formatting/printing
the final digest is included. Calibration is not final measurement. The default
calibration targets 120 ms for the faster role and caps predicted slower work
at 16 s. Millisecond clock samples below 100 ms remain explicitly unqualified;
zero clocks cannot imply free work. Rounds rotate role order; use an even number
for equal position counts. Six families are diagnostic coverage, not full native
conformance or a representative universal speed claim.

`analyze.py --acquired <acquisition>/report.json --timing <timing>/report.json
--out <fresh-summary.json>` derives medians, source sizes and separate Clang
clocks. It refuses to pool recipes or use calibration as final timing. Its
`allTimingQualified` flag must be true before publishing speed conclusions;
otherwise ratios are only diagnostics. `shape.py --acquired <acquisition>
--out <fresh-shape.json>` counts explicitly defined textual patterns and records
C hashes. These are static syntax counts, never dynamic allocation counts.

The first screen's retained `native-plan-screen03.json` uses two rotated rounds,
61440 array repetitions, and one eighth as many warmups as measured repetitions.
Its derivation preserves the initial low-resolution calibration and predicts a
25-second largest process. Use the identical plan for the atoms/scalars ablations.
A candidate that becomes fast enough to produce <100 ms intervals needs a fresh
plan and both roles remeasured; never reinterpret short clocks as precise gains.

## Fast Bend-only optimization loop

The TS-resolved array plan must run our slower executable for many seconds to
measure TS above the millisecond-clock floor. Routine optimization should instead
compare the selected Bend baseline and a new Bend candidate, keeping expensive
TS-resolved observations for occasional qualification.

`fast-plan.py` derives fixed counts from qualified timings of one explicitly
selected immutable API. The Phase67 six-family plan targets 200 ms of measured
work and approximately 25 ms warmup per cell, giving a predicted **2.824 seconds
of measured plus warmup work over twelve samples**. Process startup, method/input
hashing and independent oracle calculation are additional wall time. Compilation
and Clang builds remain separate costs.

```sh
python3 selfhost/tools/performance/phase67/benchmark/run.py measure \
  --recipe selfhost/build/phase67/native-scalars01-recipe.json \
  --acquired selfhost/build/phase67/native-scalars01 \
             selfhost/build/phase67/native-heldout-scalars01 \
  --plan selfhost/build/phase67/native-fast06-plan01.json \
  --out selfhost/build/phase67/native-fast06-replay01 \
  --cases numeric,array,closures,tree,map,lexer --roles selfhost --rounds 2
```

The recorded first run completed all twelve checks in **7.00 seconds of recorded
campaign wall time**, plus initial setup/input hashing. Its native child
processes totaled **2.83 seconds**, with **2.47 seconds** inside measured
intervals; the guard accounted for **3.41 seconds** of worker wall time. All
intervals were **182–230 ms**, and peak tree RSS was **25.7 MiB**. See
[validation](../../../../../implementation/phase67/evidence/native-fast06-validation01.json).
These fast-plan timings have different repetition/warmup counts from the full
TS-resolved campaign and are not pooled into its published score.

Use a fresh output name after each replay. This reuses compiled
executables and does not invoke Bend or Clang. A future candidate gets its own
checked API, recipe and acquisition, then uses this **same** fast plan. Require
independent results and every measured interval ≥100 ms. If improvements make a
candidate too fast, derive a new plan and remeasure both candidate and baseline.
Do not put TS into this Bend-only plan and publish sub-millisecond ratios.

The selected recipe points to an immutable checked API, so it survives release
promotion. `native-baseline02-recipe.json` refers to the formerly installed live
release and is historical after promotion; its original closed observations are
still valid. Baseline03 proves continuation through identical frozen old API
bytes. Restoring the Phase67 artifacts and its pinned prerequisites is required
when binaries or image paths are absent from a checkout.
