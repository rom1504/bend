# Experimental native closed-bundle compiler

This experiment executes the compiler's Bend implementation through the pinned
upstream native backend. It tests the execution backend hypothesis; it is not an
import-capable production compiler or evidence of native self-hosting.

The driver accepts a main module and its optional `Base` import. It rejects other
imports and required external JavaScript foreign assets. The existing executable
entry gate still requires `import Base`; the no-Base fixture checks that rejection.
Builtin IO foreign
definitions remain supported. Program and library modes use the same `j_roots`
policy as the existing typed driver, including the library's filled, non-template
user definitions and foreign definitions. The compiler algorithms remain Bend.

`native-bundle.bend` supplies the IO entry and composes the existing compiler
stages. Freeze a copy of the actual compiler modules with `native-bundle-prepare.mjs`,
then use `native-component.mjs` to check and build the resulting source. Run these
commands from `selfhost` (choose a new output directory each time):

```sh
node tools/performance/rapid/native-bundle-prepare.mjs . build/native-bundle
node --stack-size=4096 tools/performance/rapid/native-component.mjs \
  build/native-bundle/compiler.bend build/native-bundle/build --js --cpu=1
node tools/performance/rapid/native-compile-c.mjs \
  build/native-bundle/build/program.c build/native-bundle/build/program-o1 \
  --opt=O1 --cpu=1 --timeout-ms=180000
```

Keep the source-module and runtime hashes with the build report. An executable
built from a snapshot must be tested with the runtime from that same snapshot.

Run the executable through the guarded host wrapper:

```sh
node tools/performance/rapid/native-bundle-run.mjs \
  BINARY INPUT.bend BASE.bend RUNTIME.mjs OUTPUT.mjs program --cpu=1
```

Use `library` instead of `program` for exported definitions. The wrapper resolves
input paths, accepts regular input files no larger than 16 MiB, rejects output
aliases (including symlinks and hardlinks), and passes a private temporary output
to the native process. It publishes the output with a rename only after success.
Failure and timeout preserve a previous destination. The binary's direct CLI is
internal: the wrapper establishes its canonical-path and output-safety boundary.
The driver verifies EOF after its sized reads so a short read cannot silently
compile only a prefix. Handles close before read/size/write errors propagate.

The wrapper prints a JSON report containing input/output hashes, status, stderr,
`compileMs`, and `wallMs`. Native compilation timing starts after reading the
main, Base, and runtime; it ends after traversing the entire emitted source or
error. It includes parsing, graph loading, full checking, ownership checks,
TODO checks, specialization, entry validation, reachability, foreign checks,
annotation, layout checks, and JavaScript generation. Output writing follows the
timer. `wallMs` additionally includes native process startup and IO.

Compare `compileMs` only with a JavaScript invocation of the same Bend pipeline
using preloaded strings and the same final consumption step. The existing
`typed-driver.mjs` `inspect` timer includes source discovery and runtime IO, so
its time is a different scope. Compare process wall times separately. Use the
same canonical input and Base paths for byte-for-byte emitted output comparisons.

The experimental driver always fully checks the book and has no prefix cache.
Its acceptance gates and their order match an uncached host compile. It emits raw
checker diagnostics, without the host's optional diagnostic-origin replay or
source-location formatting. It omits optional declaration reports and resolves
one shared Base instance only. It computes the pure `j_stops` result once where
the host computes it again for annotation. These are explicit scope differences;
additional-import rejection is not claimed as host acceptance parity.

`native-bundle-fixtures/cases.json` describes a small validation set: Base, trees,
lists, builtin IO, non-BMP Unicode, library exports, parse/type/TODO/owned-name
errors, and additional-import rejection. The manifest contains expectations;
actual validation outcomes belong in run reports. The wrapper's filesystem and
failure behavior can be checked without a native compiler build:

```sh
node tools/performance/rapid/native-bundle-run.test.mjs
```

`native-bundle-validate.mjs CONFIG.json NEW_OUTPUT_DIRECTORY` runs the acceptance
fixtures against both the native executable and the existing typed driver using
fresh processes, full checking, identical source paths, emitted-byte comparison,
and program/library execution. Its configuration supplies `binary`, `api`,
`base`, `runtime`, `cpu`, and optional `timeoutMs`; paths resolve relative to the
configuration. `api` should be a checked API build of the same compiler source.
The additional-import and foreign-asset cases record explicit scope differences.

`native-bundle-measure.mjs CONFIG.json NEW_OUTPUT_DIRECTORY` compares the same
checked Bend pipeline emitted to native code and upstream JavaScript. Supply
`buildDirectory`, optional `cBuildReport` for a separate C-only build, `base`,
`runtime`, `cpu`, `repetitions` (default 3), and
`workloads: [{id, input, expected, mode: "program"}]`. Paths resolve relative to
the configuration. It records input/artifact hashes, emitted-byte equality,
execution, pipeline time, and process wall time. This comparison isolates the
execution backend; it does not measure the handwritten TypeScript compiler.

The build separates checked emission from C compilation, preserving both
reports so a slow optimization pass never forces repeating earlier work. O0 is
a feasibility build: it compiled the first full-compiler C snapshot in 18.6
seconds. Runtime optimization is a separate experiment. Default `--build` uses
O3; the initial combined 60-second bound left approximately 29 seconds for that
Clang pass before cancellation. A separate O1 pass exceeded its 60-second bound;
a second O1 build with a 180-second bound succeeded in 67.3 seconds. To reuse the
checked C for that optimized build, run `native-compile-c.mjs` with a fresh binary
path, `--opt=O1 --timeout-ms=180000`. These build results alone do not establish
native runtime performance. Use a supported Clang installation; the build tools
record the selected compiler, flags, source hashes, and available diagnostics.

The optimized prototype's measured runtime is 1.67–2.07 seconds on the three
small workloads and 4m25s for the compiler's complete frozen source. Its full
source output matches the checked JS fixed point byte-for-byte; this does not
establish a native self-hosting fixed point. See the
[implementation report](../../../../implementation/phase1/rapid_performance_experiments.md)
for exact artifacts, repeated small-workload comparisons, retained failures and
the separate TypeScript reference.

To exercise a complete current source assembly with the optimized executable,
keep this run separate from ordinary component checks:

```sh
node tools/assemble.mjs --output build/native-self-source.bend
node tools/performance/rapid/native-bundle-run.mjs \
  build/native-bundle/build/program-o1 build/native-self-source.bend \
  .bootstrap/upstream/bend2/base.bend build/native-bundle/src/runtime.mjs \
  build/native-self-source-api.mjs library --cpu=1 --timeout-ms=600000
```

The binary path must match the fresh optimized output chosen in the build step.
Use a compiler snapshot built from the intended source and its paired runtime;
output-hash comparison is only meaningful when source and runtime are identical.
