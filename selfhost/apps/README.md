# Useful Bend applications

These small standalone applications exercise complete native workflows rather
than fixed-input kernel batches. They are examples to use and extend, not claims
to replace mature developer tools or renderers.

| Application | Useful result | Main workload |
| --- | --- | --- |
| [Source index](source-index/README.md) | Lexical inventory of a source file | File input, Unicode text scanning, names and output |
| [Image renderer](image-render/README.md) | Complete portable pixmap (PPM) image | Numeric computation, row rendering, parallel fork/join |
| [Dependency planner](dependency-plan/README.md) | Ordered dependency plan or explicit graph error | Shared subgraphs, irregular traversal and ordering |

Each directory contains ordinary `main.bend`, a documented command-line
interface, and an independent Python reference/checker. Inputs arrive at runtime;
the compiler cannot replace the application with a precomputed answer. Complete
outputs are checked. The supported input formats and limits are part of each
application's contract; these are finite checks, not whole-program proofs.

## Build and use

From the repository root, acquire all three applications with the qualified
native compiler and pinned upstream for comparison:

```sh
python3 -B selfhost/tools/performance/phase100/run.py acquire \
  --out selfhost/build/phase100/my-apps
```

The native compiler's executables are then at:

```text
selfhost/build/phase100/my-apps/source-index/b2.program
selfhost/build/phase100/my-apps/image-render/b2.program
selfhost/build/phase100/my-apps/dependency-plan/b2.program
```

Each application README shows its arguments. Put Bend runtime options before
`--` and application options after it. The renderer writes PPM to stdout, so
redirect it to a `.ppm` file. The other applications print text.

For an ordinary build without reference comparison, use
`python3 -B selfhost/native.py selfhost/apps/APP/main.bend -o app.c`, then build
the generated C with a suitable Clang and pthread/math support. The measured
recipe is Clang22, `-std=c11 -O3 -lpthread -lm`; the runner discovers the qualified
toolchain and its include path from the installed native build receipt.

## Development loop

```sh
python3 -B selfhost/tools/performance/phase100/run.py measure \
  --acquired selfhost/build/phase100/my-apps/report.json \
  --out selfhost/build/phase100/my-smoke
```

The [measurement guide](../tools/performance/phase100/README.md) describes larger
inputs, repeated execution, memory measurements and CPU-worker sweeps. Rebuild
after source changes; do not benchmark stale executables. Compiler B1/B2 timings,
Clang time, application runtime and correctness remain separate.

Read the [design](../../design/phase100/useful-applications.md) and
[results](../../implementation/phase100/README.md) for the measured scope,
remaining toolchain limitations and the next engineering priorities.
