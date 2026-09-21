# Controlled compiler baseline

This harness measures the supplied compiler artifacts without rebuilding or editing
them. It compares the exact pinned TypeScript implementation, the supplied
upstream-emitted Bend API (`dist/typed-api.mjs`), and the self-emitted Bend API
(`dist/selfhost/seed-verification/seed.mjs`). It does not use the legacy prototype.

Run from this checkout with Node 24 or newer, Python 3 and Linux `taskset`:

```sh
BEND_UPSTREAM="$PWD/.bootstrap/upstream" \
BEND_BENCH_NODE=/absolute/path/to/node \
BEND_BENCH_CPU=2 \
  python3 tools/performance/run.py build/performance/new-baseline
```

The output directory must not already exist. Upstream must be clean at
`6018e28ecc67cf1fffc0c20c64b11023474c2df8`. All files listed in the distribution's
archive manifest must still match their original hashes. That last requirement
is intentional for this **pre-change baseline** harness; a future candidate
benchmark must explicitly record its own identities instead of silently reusing
this baseline's provenance.

Each workload runs three times per implementation, in a fresh Node process each
time. Orders rotate upstream/bootstrap/selfhost, bootstrap/selfhost/upstream,
selfhost/upstream/bootstrap. Everything runs serially on the chosen logical CPU.
These are first-compilation measurements: there are no JIT warmups. Filesystem
caches are not flushed. Node's persistent compilation cache is disabled and all
processes use the same 4 MB JS stack and 4 GB old-space ceiling. These settings
are limits, not preallocated or measured memory requirements. The machine may
have unrelated activity; load averages, CPU governor and resource information
are recorded. CPU affinity does not isolate the CPU's SMT sibling.

Both sides read the same input files and the same upstream Base path. The port's
existing full-work path is selected by withholding the optional seed-loading and
check-prefix entry points from the measurement adapter. Every sample parses and
checks all of Base. No compiler implementation changes, checker bypasses, or
cached checker verdicts are involved. This measures full uncached work, **not**
the default CLI's performance with a previously validated Base cache.

The three main cases compile executable JavaScript: a U32 constant importing
Base, the recursive tree/IO fixture, and upstream's list-sort fixture. The worker
measures load/check/emission, then saves the program. The controller executes
every resulting program outside compiler timing and compares its output with
`42`, `42`, or `6`. Runtime execution speed and native/GPU performance are not
part of this comparison.

Two supplemental cases check a tiny no-Base datatype and 256 generated constant
declarations. They validate successful complete checking rather than execute a
program. The adapter withholds `driver_report` and `f_main_names` so neither side
pays for presentation-only declaration formatting. The port still performs its
normal specialization; upstream instantiation occurs within checking. Phase
boundaries remain different. Upstream executable output is saved as CommonJS
(`.cjs`), and port output as ESM (`.mjs`); neither program's bytes are rewritten.

The worker records compiler-module import latency separately from pipeline
latency. The controller records total process wall time, which also includes
Node startup, output-file writing, JSON serialization and exit. Peak RSS is the
child's high-water mark through compilation, including imports and the runtime;
it is not per-phase allocation or a measure of minimum required heap. Compiler
CPU time and emission size are also recorded. All public port API calls are timed;
upstream has coarse load/check/emit timing. Their phase boundaries differ, so
phase timings are for attribution, not direct phase speed ratios.

`report.json` contains every sample, commands, timestamps, identities, validation
results, median/min/max timings and median ratios. Failures and 180-second
timeouts remain failures; they are never zero-time successes. A ratio is emitted
only when all three samples of both implementations pass. Per-process stderr,
stdout, and emitted programs stay beside the report. Program-byte identity is
not required across different backends; output semantics are checked instead.

The initial trials under `build/performance/baseline` and
`build/performance/controlled-baseline` are infrastructure diagnostics, not valid
samples. Only the completed `controlled-baseline-v2` run is the recorded baseline. Python is used for the measured
controller because Node's `spawnSync` reports `EPERM` under this sandbox.

Publish a completed run's summary and raw measurements with:

```sh
python3 tools/performance/summarize.py build/performance/new-baseline/report.json
```

The publication step requires all 45 samples to succeed. The separate
[negative validation record](../../benchmarks/harness-negative-validation.json)
confirms that every adapter rejects the invalid-type fixture without writing an
output artifact.
