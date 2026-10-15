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
  --cases "$(cat selfhost/tools/performance/phase93/measured-cases.txt)" \
  --target-ms 250 --out selfhost/build/phase93/calibrate-FRESH
python3 -B selfhost/tools/performance/phase93/run.py measure \
  --acquired selfhost/build/phase93/acquire-FRESH/report.json \
  --plans selfhost/build/phase93/calibrate-FRESH/report.json \
  --cases "$(cat selfhost/tools/performance/phase93/measured-cases.txt)" \
  --rounds 3 --out selfhost/build/phase93/measure-FRESH
```

The commands acquire all 45 points; the explicit measured-case file excludes
only the proven zero-work `scalar-region-0` from calibration/timing. Recheck
that control separately when changing code generation.

Use `--cases id1,id2` for a fast screen, reusing acquired executables and an
existing calibration plan. `--target-ms` and `--rounds` vary timing depth;
all final intervals must still be at least100 ms. Acquisition is a separate cost.
The initial campaign splits five pilot points from the other40, and each command
accepts multiple acquisition/plan reports. Do not pass overlapping cases.

`collect.py` combines disjoint three-round measurement reports into the
45-point scoreboard and CSV. Every point must have measured results or an
explicit, evidence-backed zero-work classification passed with `--unmeasured`.
The initial campaign finds `scalar-region-0` optimized to a direct count by both
backends: its ratio is undefined. Aggregates cover the other 44 points, with
equal-point and equal-original-source weighting reported separately.

`calibrate-broad01` stopped at that zero-work point. `resume-calibration.py`
preserves the failed report and reuses its ten complete calibration plans;
`calibrate-broad02` covers the remaining 29. The 39-point broad measurement
explicitly excludes only the named zero-work control. The five pilot points
remain in the final aggregate. No failed calibration interval is a final timing.

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
