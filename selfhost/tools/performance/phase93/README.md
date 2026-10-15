# Original45 native generated-program runtime

[Design](../../../../design/phase93/native-program-runtime.md) ·
[Results](../../../../implementation/phase93/README.md).

This suite preserves the historical JS catalog's 45 fixed input points across
23 programs. Closed Bend wrappers read workload arguments and repetition counts
at runtime and validate every complete result. Programs are freshly emitted by
native B1/B2 and upstream TypeScript's C backend. Exact native B1/B2 C equality
permits one shared executable per point. Both executable roles use pinned
Clang22, `-std=c11 -O3 -lpthread -lm`, CPU3, one thread and GPU off.

Run commands from the repository root. Use fresh output directories. Preparation
is offline; acquisition, calibration, measurement and scaling use serial guarded
targets. Do not launch two commands concurrently. No compiler image rebuild is
needed. Compiler and Clang times are recorded outside the execution metric.

```sh
python3 -B selfhost/tools/performance/phase93/prepare.py \
  --out selfhost/build/phase93/fixtures-FRESH
python3 -B selfhost/tools/performance/phase93/run.py acquire \
  --manifest selfhost/build/phase93/fixtures-FRESH/manifest.json \
  --out selfhost/build/phase93/acquire-FRESH
python3 -B selfhost/tools/performance/phase93/run.py calibrate \
  --acquired selfhost/build/phase93/acquire-FRESH/report.json \
  --target-ms 250 --out selfhost/build/phase93/calibrate-FRESH
python3 -B selfhost/tools/performance/phase93/run.py measure \
  --acquired selfhost/build/phase93/acquire-FRESH/report.json \
  --plans selfhost/build/phase93/calibrate-FRESH/report.json \
  --rounds 3 --out selfhost/build/phase93/measure-FRESH
```

Use `--cases id1,id2` for a fast screen, reusing acquired executables and an
existing calibration plan. `--target-ms` and `--rounds` vary timing depth;
all final intervals must still be at least100 ms. Acquisition is a separate cost.
The initial campaign splits five pilot points from the other40, and each command
accepts multiple acquisition/plan reports. Do not pass overlapping cases.

`collect.py` combines disjoint three-round measurement reports into the complete
45-point scoreboard and CSV; it refuses incomplete coverage. It reports equal
point weighting and equal original-source weighting separately.

The primary clock is the in-program IO.now interval: workload, complete-result
validation, loop and final counter print. Startup, initial output and at most32
warmup calls are excluded. Native code has no JIT warmup; this is a fresh-process
batch scope, not a claim to match the old JS harness's one-second warmup. Clock
resolution is1 ms. Inner process time is also retained; the supervisor's polling
clock is never used as program execution time. Three alternating rounds provide
a screen with ranges, not a statistical confidence interval.

Repeated fixed inputs can expose loop-invariant optimization. Representative
generated C and optimized ELF disassembly are checked separately, as is doubled
repetition scaling. Keep zero-work controls and any inconclusive points visible.
Strings and the generic-array serializer are fully compared, so validation cost
belongs to the named benchmark. Do not infer a JS-versus-C speedup from ratios
against different historical baselines.
