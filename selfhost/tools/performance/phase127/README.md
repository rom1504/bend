# Phase127 profiling workbench

The reusable tools are under `selfhost/tools/profiler/`. This directory supplies
frozen workload inputs; it does not implement another compiler or profiling
runtime. Native compiler requests are prepared by `prepare.py`. The small
[live-bank experiment](live-bank/README.md) is separate from profiler transfer.

## Ordinary-program transfer

`prepare-programs.py` reuses the Phase126 mandelbrot and tree-bitonic programs
from `final32-screen/report.json` and their exact QBE/object/build receipts.
Mandelbrot supplies numeric work; tree-bitonic supplies allocation, ownership
and control flow. This demonstrates transfer to two workloads, not complete
language coverage. Their frozen batches previously took about0.8 and1.0seconds.

```sh
python3 -B selfhost/tools/performance/phase127/prepare-programs.py prepare \
  --out selfhost/build/phase127/programs01 \
  --sampler-report selfhost/build/phase127/sampler-cfi03/report.json
```

Preparation is already complete for `programs01`; use a fresh output for a
replay. It emits `baseline-manifest.json`, `plan.json`, and per-program
`owners.json`, `runtime-input.json`, and `runtime/plan.json`. Only source/JSON
materialization occurs. Original generated `program.o` objects are retained;
diagnostic builds compile the small instrumented runtime and relink them.

The output contract derives from the independent frozen checksum oracle and
the retained command: exact checksum line, exact warmup line, exact repetition
line, then exactly one unsigned elapsed-time line. Candidate, previous phase,
and upstream retained observations must all satisfy it. Stderr must be empty.
The script neither learns a checksum from a new run nor normalizes other text.

The root agent owns every resource-intensive execution and uses CPU3. Run the
two `guardedBuildCommands` in `programs01/plan.json` sequentially. They call the
generic `build-runtime.py` with150second/2GiB guards. Then bind the actual build
products without running either program:

```sh
python3 -B selfhost/tools/performance/phase127/prepare-programs.py seal \
  --plan selfhost/build/phase127/programs01/plan.json \
  --out selfhost/build/phase127/programs01/diagnostic-manifest.json
```

`baseline-manifest.json` runs only original binaries. The sealed diagnostic
manifest contains both originals and runtime-instrumented relinks, binding
their build receipts and exact object identities. Use the generic runner's
`--check-only` before target execution if the preparation was resumed later.

```sh
python3 -B selfhost/tools/performance/phase111/guard.py \
  --out selfhost/build/phase127/programs01/run-guard --seconds 120 \
  --rss-mib 2048 --available-mib 16384 --file-mib 64 --cpu 3 -- \
  python3 -B selfhost/tools/profiler/run.py \
  --manifest selfhost/build/phase127/programs01/diagnostic-manifest.json \
  --out selfhost/build/phase127/programs01/run \
  --modes clean,sample,events --rounds 1 --periods-us 8000,13000
```

The original clean rows measure complete-process runtime. Context-only and
counter-enabled relinks are diagnostics; their overhead does not become the
headline program runtime. Two sampling periods provide a small stability
check, not statistical performance qualification.

Owner maps contain561 exact dispatch FIDs for mandelbrot and505 for tree-bitonic.
Their lexical grouping is conditional on the documented lowering contract;
the maps retain unknown private/composite origins. `attribute.py` can combine
each run's `analysis.json`, `callers.txt` and `contexts.txt` with the sampler's
frozen unwind table and that program's `owners.json`. Event mode uses
`--events EVENTS --binary DIAGNOSTIC_PROGRAM --owners OWNERS --out FRESH_OUT`.
These are physical/active-dispatch observations, not dynamic logical stacks,
allocation provenance or source-line information.

Preparation alone establishes no semantic or performance result for the
instrumented relinks. Preserve failed captures, independent output checks,
coverage diagnostics and the original qualified binaries.
