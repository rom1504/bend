# Application development and measurement

This loop uses the installed Phase98 native B1/B2 compiler and pinned upstream
TypeScript/Bun to build the same standalone Bend applications. It does not rebuild
the compiler. Run from the repository root with the native release assets restored
as described in [the native guide](../../../../docs/self_hosted/NATIVE_PHASE98.md).

```sh
python3 -B selfhost/tools/performance/phase100/run.py acquire \
  --out selfhost/build/phase100/acquire-FRESH
python3 -B selfhost/tools/performance/phase100/run.py measure \
  --acquired selfhost/build/phase100/acquire-FRESH/report.json \
  --out selfhost/build/phase100/smoke-FRESH
python3 -B selfhost/tools/performance/phase100/run.py measure \
  --acquired selfhost/build/phase100/acquire-FRESH/report.json \
  --depth survey --rounds 4 --threads 1,2,4 \
  --out selfhost/build/phase100/survey-FRESH
```

Use `--apps source-index`, `--apps image-render`, or `--apps dependency-plan`
for a focused loop, and `--cases ID1,ID2` to select inputs. Output directories must
be fresh. Runtime jobs default to a 30-second deadline, configurable with
`--seconds` up to 120. All targets run serially under the existing shared guard
with a 2 GiB sampled RSS cap, 4 GiB available-memory floor and 512 MiB disk reserve.
The cap is a sampled process-tree guard, not a hard kernel memory limit.
`--acquired` also accepts several disjoint acquisition reports, allowing focused
app builds to be reused together without recompilation.

For optimization iterations, add `--fixtures PATH/TO/COMPLETED/report.json`.
This reuses the prior run's hash-verified input files and complete expected
outputs, without regenerating independent references. This matters for the
renderer: its Python oracle can take longer than the actual native executions.
The report names the original fixture run and oracle identities explicitly;
it does not claim fresh oracle execution. Keep the original run directory, or
restore it from the evidence archive. New compiler products still require a new
acquisition. Omit `--fixtures` when deliberately changing the application contract.

Compiler requests use prepared Base for our native stages; upstream checks Base
within its request. Request time and complete compiler-process time are reported
separately, with Clang outside both. Acquisition records one observation per
compiler/app, sufficient for workflow latency, not precise compiler ranking.
Complete B1/B2 C equality allows one native program executable to represent both.
Programs use matching Clang22 C11/O3 flags. Compiler source is unchanged.

Runtime measures complete process turnaround: startup, runtime argument parsing,
file I/O, useful computation and all output. A separate high-resolution child
clock avoids the guard's 20 ms polling resolution. Peak RSS and user/system CPU
time come from `getrusage`. Output is captured and independently compared after
the timed process. Oracle generation is outside this interval. Short observations
are flagged; they are latency observations, not precise throughput estimates.

Every repetition compares the complete output against the independent Python
reference, including invalid-input diagnostics. Two backend roles alternate
first position; an even round count balances order. Only cases marked parallel
receive the requested worker sweep. CPU affinity is CPU3 for one worker, CPU2/3
for two, and CPU0/1/2/3 for four: four distinct physical cores on the measured host.
GPU is off. A worker flag alone does not establish parallel execution or scaling.

Each acquisition binds the installed release, source, runtime/providers, upstream
source, toolchain and oracle. Each run retains the runner snapshot, commands,
stdout/stderr, full expected outputs, clocks and input identities. Failed runs
remain intact. Fixes get new directories; never patch an old result into passing.
An oracle-only correction or additional input set does not require rebuilding
unchanged Bend source: each measurement binds its actual oracle separately, while
the acquisition preserves the earlier oracle identity.

These application observations extend the [Phase93 kernel suite](../phase93/README.md).
Their different workloads and clocks must not be merged into its speed ratio.
Application checks are finite contracts; the existing formal compiler laws and
conformance results keep their documented scope.
