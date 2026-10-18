# Direct QBE backend for the Bend compiler written in Bend

Phase111 adds a general structured native backend to the checked Bend compiler.
It emits QBE IL directly and links a separately cached runtime object. Ordinary
program construction needs no generated C translation unit or cproc invocation.
The retained runtime is still written in C and is compiled once per cache
identity. Initial checked development APIs are acquired with the pinned
TypeScript compiler.

**Status: experimental, not the installed default.** Checked-source execution
and structural controls have passed finite gates; complete direct native image
acquisition and a byte-exact native fixture request have succeeded. Native
self-compilation, broad conformance and comparative speed remain separate gates. Read the [Phase111 report](../../implementation/phase111/README.md)
for the latest completed gates and failures. The installed
[`selfhost/bend` CLI](NATIVE_CLI.md), JavaScript release and
[Phase108 cproc/QBE route](QBE_COMPILER.md) remain available.

## Architecture and language boundaries

```text
Bend source + authenticated Base/prepared Base
  → existing Bend parser, checker, erasure and checked request
  → Bend lowering to typed segments, values, calls and program metadata
  → Bend structural/ABI verifier
  → Bend emission of QBE IL and data
  → QBE → GNU assembler → object
  → GCC linker driver + cached runtime object → native executable
```

The parser, type checker, ownership placement, erasure, structured lowering,
verification and QBE emission are Bend code. The Python and JavaScript tools
transport files, acquire checked APIs, supervise commands and retain receipts;
they do not implement semantic lowering. QBE supplies machine optimization,
register allocation and assembly emission. Invoking GCC to link existing
objects does not compile a per-program C file.

The generic segment route represents complete 64-bit Terms, U32 values and
pointers separately. It retains constructors, closures, continuations, the
register bank and reference counting. Calls use a versioned scalar runtime ABI;
program constructor/function tables, show descriptors and effect names are QBE
data. Incoming continuation width is distinct from a segment's output width.
QBE constructs SSA from mutable typed temporaries. The route deliberately
bypasses optional mature optimized C-worker and static-image planning while
establishing the generic semantic path.

This is broader than the earlier scalar Nx prototype and is distinct from the
[Phase110 ownership kernel route](OWNED_NATIVE_IR.md). It does not claim that all
Phase110 ownership optimizations have been composed into the generic backend.
See the [module list](../../selfhost/tools/performance/phase111/modules.txt),
[lowering audit](../../implementation/phase111/segment-lowering-audit.md),
[runtime boundary](../../implementation/phase111/runtime-notes.md) and
[emitter notes](../../implementation/phase111/emitter-notes.md).

## Admitted environment

The present machine ABI is Linux x86-64, System V, **one CPU worker and GPU off**:
`--threads 1 --gpu off`. This is sequential execution of the admitted Bend
semantics, not qualification of CPU parallel scaling, CUDA or Metal. Benchmark
process affinity is a separate control: current experiment receipts use CPU3.

The source entry retains the mature one-source/Base frontend contract. Use the
selected, authenticated Base and its matching prepared carrier/stamp. Base and
cache are trusted immutable inputs, not caller-supplied semantic certificates.
The native entry takes paths to those assets; a bare low-level command is not an
untrusted cache admission interface. Live mode checks Base from source, while
cache mode reuses the selected authenticated preparation. Never substitute an
arbitrary Base/cache and describe the result as the qualified route.

The cached runtime has a fixed foreign-provider set: IO args/print/print_err/now,
selected file operations and the three NativeHost operations. Arbitrary custom
foreign C, network/device effects or a new provider require explicit admission
and a new runtime cache. Unsupported providers fail at source/backend admission;
there is no fallback to C generation. See the exact
[provider catalogue and provenance](../../selfhost/tools/performance/phase111/runtime/effects/README.md).

The [structural verifier](../../implementation/phase111/verify-audit.md) checks
identities, widths, definite assignment, terminal paths, import signatures,
static counts and bounded accesses. It does not prove Term ownership,
initialization of every scratch byte, whole-compiler correctness or correctness
of foreign code. Differential outputs, runtime boundaries and bootstrap checks
remain independent gates.

## Fast checked-source development loop

Run from the repository root. Every output directory below must be fresh and
remain under `selfhost/build/phase111`; replace the example suffixes for later
runs. Generated APIs, native objects and temporary outputs are local artifacts,
not assumed to be present in a fresh clone. Restore their authenticated receipts
or acquire them before running the next command.

Source preparation only authenticates the selected mature compiler and appends
exact Phase111 modules:

```sh
python3 -B selfhost/tools/performance/phase111/prepare.py \
  --out selfhost/build/phase111/user-source01
```

Acquire a checked development API with the pinned bootstrap compiler under the
existing process-tree guard:

```sh
python3 -B selfhost/tools/performance/phase86/guard.py \
  --out selfhost/build/phase111/user-api01-guard \
  --seconds 90 --rss-mib 2048 --available-mib 4096 --cpu 3 -- \
  python3 -B selfhost/tools/performance/phase111/check-api.py \
    --source selfhost/build/phase111/user-source01/compiler.bend \
    --out selfhost/build/phase111/user-api01 p111_compile_source
```

`full-api05/api.mjs` is a recorded checked development API, with its source and
bootstrap hashes in the adjacent `report.json`. The following five-case loop
uses that API and the separately acquired `runtime-source03/runtime.o`:

```sh
python3 -B selfhost/tools/performance/phase86/guard.py \
  --out selfhost/build/phase111/user-fast01-guard \
  --seconds 120 --rss-mib 2048 --available-mib 4096 --cpu 3 -- \
  python3 -B selfhost/tools/performance/phase111/coverage/run.py \
    --api selfhost/build/phase111/full-api05/api.mjs \
    --runtime selfhost/build/phase111/runtime-source03/runtime.o \
    --out selfhost/build/phase111/user-fast01 --mode cache
```

The default covers captured closures, non-tail recursion, array aliasing with IO,
U32 readback and Unicode String readback. Use `--names NAME ...` for selected
frozen cases or `--mode live` for live Base. The runner stops on its first failure
by default. It preserves separate source-admission, lowering, IR, assembly,
linking and execution status; a valid unsupported program is a backend gap.
The [coverage guide](../../selfhost/tools/performance/phase111/coverage/README.md)
lists the focused and broader sources and independent expected outputs.

To inspect one request, invoke the recorded Bun executable on
`selfhost/tools/performance/phase111/emit.mjs CHECKED_API INPUT FRESH_OUT cache`
under the same guard. It writes `program.ssa` and an emission receipt. Then run
`build.py --source FRESH_OUT/program.ssa --runtime RUNTIME_OBJECT --out FRESH_BUILD`
under the guard. Add `--expected EXPECTED_FILE` to require exact independent
stdout. The builder records QBE, assembly and link clocks separately.

This development API is a hosted Bend compiler generated by TypeScript. It is
useful for fast correctness feedback and is not a measurement of native compiler
speed or proof of direct self-hosting. The
[staged diagnostic](../../selfhost/tools/performance/phase111/STAGED-EMIT.md)
separates preparation, frontend, lowering, verification and emission when a
larger input fails; use a small matched product before a full compiler request.

## Runtime acquisition and native entry

Runtime preparation is source-only:

```sh
python3 -B selfhost/tools/performance/phase111/runtime/materialize.py \
  --out selfhost/build/phase111/user-runtime01
```

It authenticates the retained runtime and providers, writes `runtime.c` plus
headers and a manifest, and records the exact GCC command for acquiring
`runtime.o`. Run that recorded build command under the process-tree guard.
Reuse the resulting object only for its matching ABI/provider identity; runtime
acquisition time is a separate clock from ordinary program construction.

A Phase111 native image, once acquired and qualified, can use the supervised
[native emission tool](../../selfhost/tools/performance/phase111/native-emit.py).
For example, substitute the actual acquired image path in this command:

```sh
python3 -B selfhost/tools/performance/phase86/guard.py \
  --out selfhost/build/phase111/user-native01-guard \
  --seconds 360 --rss-mib 4096 --available-mib 16384 --cpu 3 -- \
  python3 -B selfhost/tools/performance/phase111/native-emit.py \
    --image selfhost/build/phase111/ACQUIRED_IMAGE/program \
    --source selfhost/tools/performance/phase111/coverage/fixtures/higher-order-capture.bend \
    --out selfhost/build/phase111/user-native01 --mode cache \
    --runtime selfhost/build/phase111/runtime-source03/runtime.o
```

`ACQUIRED_IMAGE` is a placeholder, not a claim that a qualified image exists at
that path. The wrapper authenticates selected Base/cache assets, retains raw
QBE output and can build it with the supplied cached runtime. Add
`--reference API_EMIT_DIRECTORY` for exact comparison with a saved hosted
emission, or `--expected EXPECTED_FILE` to execute the generated program and
require independent stdout. Live mode changes Base preparation. The actual
image provenance and qualification must remain visible in the adjacent report.

The underlying image argument contract is:

```text
IMAGE --threads 1 --gpu off -- ABS_INPUT ABS_BASE cache ABS_CARRIER STAMP
IMAGE --threads 1 --gpu off -- ABS_INPUT ABS_BASE live UNUSED UNUSED
```

It reads source and trusted assets, runs the checked Bend compiler and prints
QBE chunks to stdout. It does not launch QBE or a linker itself. Preserve the
exit status and diagnostics before treating stdout as a valid `.ssa` product.
The supervised native-emission tool and its receipts should be preferred over
manual output redirection; native invocation becomes a qualified workflow only
when the report records the corresponding acquired image and controls.

Do not describe compiling a small program or emitting the compiler through the
hosted API as native self-compilation. The full gate requires building the
compiler executable directly from QBE, having that executable check and emit
its own exact source, building its successor, and passing independent controls.
Full jobs need the established 4 GiB process-tree cap and 16 GiB available-memory
floor. Keep large/timed jobs serial and preserve failed receipts.

## What to measure

Keep these clocks separate: checked API/image acquisition, Base preparation,
Bend source-to-QBE compilation, QBE object construction, assembly/linking,
compiler self-emission, and generated-program execution. A reduction in machine
build time can coexist with a slower compiler executable. Current Phase111
finite correctness results do not replace production B1/B2/upstream benchmarks
or establish a new speed ratio. The [metric definitions](METRICS.md) and
[Phase111 report](../../implementation/phase111/README.md) identify the evidence
needed for each claim.
