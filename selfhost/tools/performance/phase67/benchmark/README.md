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
