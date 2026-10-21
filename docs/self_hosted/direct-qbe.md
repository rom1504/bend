# Direct QBE backend for the Bend compiler written in Bend

## Phase114 qualified native checkpoint

The [Phase114 report](../../implementation/phase114/README.md) records a direct-QBE
candidate whose broad generated-program runtime is 5.386× pinned upstream C/Clang,
down from 7.082× in the matched campaign. All 405 output/count observations pass;
this is 44 timed programs plus one zero-work control, not a compiler-throughput
ratio. Local recursive regions and a bounded continuation table provide most
of the gain. The C runtime object is unchanged and cached; ordinary program
emission does not use C or cproc.

[Reproduction](../../selfhost/tools/performance/phase114/README.md) distinguishes
source01, which produced the timed programs, from source02, which repairs a
stack-consuming verifier traversal for full native acquisition. **Source02 N1
and N2 are now qualified:** the hosted and N1 self-emitted QBE agree in all
74,220,801 bytes. Each generation passes focused19 (16 positive executions and
3 expected refusals), and N2 passes all 45 one-shot conformance programs.
These are separate from source01's hosted batch-runtime measurements; there is
no claim of a native-produced full45 runtime campaign or N2-to-N3 reproduction.

The three-source, three-round compiler-request screen passes all 27 observations.
N1/N2 request-time ratios are 2.82490×/2.82713× upstream; request-plus-machine-build
ratios are 1.35522×/1.35687×. Native QBE requests use authenticated prepared Base
and a cached runtime object; upstream C/Clang requests load source Base and
recompile runtime C. These clocks are distinct from generated-program runtime.
See [native results](../../implementation/phase114/native-results.md) and the
[reporting-only selection](../../implementation/phase114/selection.json).
Installed production selection is unchanged. The float-lane and table-buffer
prototypes are excluded from this checkpoint.


Phase111 adds a general structured native backend to the checked Bend compiler.
It emits QBE IL directly and links a separately cached runtime object. Ordinary
program construction needs no generated C translation unit or cproc invocation.
The retained runtime is still written in C and is compiled once per cache
identity. Initial checked development APIs are acquired with the pinned
TypeScript compiler.

**Historical Phase112 checkpoint:** its `facts` composition established direct
native self-hosting and remains reproducible; Phase114 source02 is the newer
qualified experiment described above. Neither changes the installed default.
The Phase112 facts image reproduces its complete 46.54 MB QBE module in 275.72 seconds, builds its
successor, and passes focused semantics for both generations and the original
45-program corpus through N2. Its final N1/N2 compiler-request ratios are2.057×/2.071×upstream, and
the44-point generated-program ratio is15.943×upstream. Ready-executable stage
sums are approximately1×in the three-source screen under the documented cached
runtime policy. The smaller `word` compiler remains a qualified historical checkpoint.
Qualification is not a parity claim. The immediates experiment is excluded, and
the production source/runtime selection is unchanged. See the
[Phase112 report](../../implementation/phase112/README.md) and the earlier
[Phase111 report](../../implementation/phase111/README.md). The
installed [`selfhost/bend` CLI](NATIVE_CLI.md), JavaScript release and
[Phase108 cproc/QBE route](QBE_COMPILER.md) remain available.

## Architecture and language boundaries

Phase113's [whole-function and flat-product candidate](../../implementation/phase113/README.md)
is the intermediate development checkpoint. It adds complete call/loop regions, flat
product results, bounded inlining, operation-derived range facts and explicit
machine-width emission. All transformations remain Bend code. Its six-case
development screen is 6.5× faster than facts. The original broad45 corpus passes
all270 output/count checks and averages7.088×upstream across44 timed points,
versus the prior facts15.943×campaign. Full compiler acquisition hits
the 600-second limit while lowering, so that checkpoint did not replace the
qualified facts native image. Phase114 subsequently completed its own native
chain. The Phase113 report separates broad program runtime,
finite correctness checks and the unfinished native-generation gate.

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
QBE constructs SSA from mutable typed temporaries. Phase111 established this
generic semantic path without optional optimized C-worker/static-image planning.
Phase112 adds Bend passes for liveness, scalar/accessor expansion, private
workers and local loops, static images, bounded continuation fusion, and reuse
of mature selector/Word-pattern recognition. The facts integration also composes
bounded worker regions, pure-assignment/branch fusion and typed ownership facts.
Unsupported optimization shapes
retain the generic segment path; those passes do not introduce per-program C.

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

## Historical Phase112 qualified checkpoint and reproduction

The facts integration is recorded by `phase112/facts-full-jobs01`. Its N1 and
N2 each pass 16 focused positive executions and three expected refusals. N2
also passes all 45 positive compile/build/execute cases in
`phase111/p112-facts-n2-full45-01`. Native self-emission takes 275.721 seconds and
reproduces all 46,541,018 QBE bytes exactly. Each compiler ELF is 10,022,768 bytes;
the allocated code/data comparison passes except build ID. These are completed
correctness/bootstrap observations. Final broad runtime passes270 full outputs
and counts. The original Phase111 N2 comparison measures3.32×faster requests. Consult the
[phase report](../../implementation/phase112/README.md) for the final facts broad
runtime and `transport04` comparison rather than substituting the historical
word numbers below.

Historical word clocks measure different things and remain a separate baseline:

| Measurement | Qualified word result | Scope |
|---|---:|---|
| Native compiler self-emission | 349.70 s | N1 checks/emits its exact source; N2 QBE is byte-exact |
| N2/N1 compilation request time | 0.9969× | Same source, three small inputs, three rotated rounds |
| N1 / N2 request time versus upstream | 2.4560× / 2.4483× | Native source→QBE versus TypeScript/Bun source→C |
| N1 / N2 ready-executable time versus upstream | 1.1498× / 1.1467× | Sum of compiler and machine-build stages |
| Generated-program runtime versus upstream | 24.8680× | Geometric mean across 44 measurable corpus points |

The request/build screen is `phase112/transport03/report.json`. It includes fresh
process startup and uses the prepared Base cache. Native construction reuses a
cached runtime object; the upstream C/Clang recipe recompiles its runtime. Thus
the ready-executable ratio compares these configured workflows, not equal-format
frontend throughput or equal runtime-cache policy. N1/N2 are route-local
generations, not replacements for production B1/B2 labels. The historical role
keys `phase111` and `phase112` in this receipt mean **word N1 and word N2**;
its explicit lineage field defines them.

Both native generations pass 16 focused positive executions and three expected
source/backend refusals. Word N2 also compiles all 45 frozen batch inputs. The
three-round `phase112/word-broad-runtime01/report.json` records 270 correct full
output/count observations across upstream and word roles. One zero-work control
is excluded from ratios, leaving 44 measured points from 23 historical families.
The 38 measured points outside the initial six-case screen average 26.9836×.
They are historical corpus extensions, not unseen independent research holdouts.
These finite gates establish neither whole-language correctness nor satisfactory
generated-code speed. See [broad-gap.md](../../implementation/phase112/broad-gap.md)
for the missing flat-product and complete-loop optimizations.

### Historical facts provenance and recipe

All paths below are relative to `selfhost/build/`; each facts product has its own
adjacent receipt. Sources/APIs and native generations must not be interchanged:

| Role | Recorded artifact | SHA256 prefix |
|---|---|---|
| Checked source | `phase112/facts-source01/compiler.bend` | `1df2df372cb3614f7` |
| Hosted checked Bend API | `phase111/p112-facts-api02/api.mjs` | `fa5e5cb08194f0ab8` |
| N1, built through that API | `phase111/p112-facts-full-native01/program` | `7a029fd20c9961a57` |
| N1-produced full QBE | `phase111/p112-facts-self01/program.ssa` | `15e95d0792ce4eb86` |
| N2, built from N1's QBE | `phase111/p112-facts-self01/build/program` | `2bde69816ff10f8dc` |

The API is Bend code compiled initially by pinned TypeScript/Bun. N1 and N2 are
native executables of that same Bend source. The source composition manifest
pins the baseline, every module snapshot, substitutions and source hash; the API
receipt pins checked source and bootstrap inputs. Emission/build receipts pin
QBE, runtime object, toolchain and binary. Complete QBE bytes agree across the
bootstrap. Authenticated ELF comparison finds matching checked headers, program
headers and allocated code/data except the build ID; whole executable files
differ and are not reported as byte-identical.

Prepare a fresh source composition without executing a compiler:

```sh
python3 -B selfhost/tools/performance/phase112/prepare-candidate.py \
  --profile facts --out selfhost/build/phase112/user-facts-source01
```

The [recipe](../../selfhost/tools/performance/phase112/recipes.json) and generated
`profile.json` describe module order and overrides. To reproduce this exact
checkpoint, compare the resulting source's full hash with the recorded manifest;
a current recipe with changed modules is a new candidate. Do not overwrite or
silently rebind historical artifacts. API acquisition uses `phase111/check-api.py`
with this source, a fresh Phase111 output directory, and these exports for staged
acquisition: `p111_compile_source`, `p88_cache_prepare`, `p86_prepare`, `p86_plan`,
`p111_runtime_admission`, `p112s_lower_request`, `p112s_verify`, `p112s_chunks`.

The recorded `phase112/facts-full-plan01.json` gives the acquisition recipe:
`phase112/staged-emit.mjs API SOURCE FRESH_EMISSION cache static`, then
`phase111/build.py --source FRESH_EMISSION/program.ssa --runtime RUNTIME_OBJECT
--out FRESH_BUILD`, followed by focused native qualification. Run each target
under the full-job guard described below. For self-reproduction use
`phase111/native-emit.py --image N1 --source THE_SAME_SOURCE --reference
HOSTED_EMISSION --runtime RUNTIME_OBJECT --out FRESH_SELF_BUILD --seconds 650`.
The successor is `FRESH_SELF_BUILD/build/program`; qualify it independently.
Saved plan paths are evidence, not commands safe to rerun into existing outputs.

The facts source is 44,389 lines, 8.00% larger than Phase111's assembled source.
The historical word source is 43,588 lines (+6.05%); its QBE is 28.46 MB versus
46.54 MB for facts, and its compiler ELF is 8.08 MB versus 10.02 MB. The newer
integration therefore trades additional source/generated-code size for its
optimization capabilities; it is not a size-reduction claim.
The [complexity inventory](../../implementation/phase112/complexity.md) separates
retained implementation, embedded controls and unselected experiments. The
[evidence capsule guide](../../implementation/phase112/evidence/README.md)
describes receipt preservation; large local products require authenticated
reacquisition in a fresh clone.

## Baseline fast checked-source development loop

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
uses that API and the separately acquired `runtime-source04/runtime.o`:

```sh
python3 -B selfhost/tools/performance/phase86/guard.py \
  --out selfhost/build/phase111/user-fast01-guard \
  --seconds 120 --rss-mib 2048 --available-mib 4096 --cpu 3 -- \
  python3 -B selfhost/tools/performance/phase111/coverage/run.py \
    --api selfhost/build/phase111/full-api05/api.mjs \
    --runtime selfhost/build/phase111/runtime-source04/runtime.o \
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
This materializer describes the generic Phase111 cache. Qualified Phase114
source02 uses the product-extended Phase113 runtime object in the command below,
with its own source/build manifest; these runtime objects are not interchangeable.

The qualified Phase114 source02 successor can use the supervised
[native emission tool](../../selfhost/tools/performance/phase111/native-emit.py).
Run from the repository root with fresh output directories. This example checks,
emits, builds and executes the unchanged captured-closure fixture against its
independent expected stdout:

```sh
python3 -B selfhost/tools/performance/phase111/guard.py \
  --out selfhost/build/phase114/user-native01-guard \
  --seconds 180 --rss-mib 4096 --available-mib 16384 --file-mib 128 --cpu 3 -- \
  python3 -B selfhost/tools/performance/phase111/native-emit.py \
    --image selfhost/build/phase111/p114-native-final02-self/build/program \
    --source selfhost/tools/performance/phase111/coverage/fixtures/higher-order-capture.bend \
    --out selfhost/build/phase111/p114-user-native01 --mode cache \
    --runtime selfhost/build/phase113/runtime-products-build01/runtime.o \
    --expected selfhost/tools/performance/phase111/coverage/expected/higher-order-capture.stdout \
    --seconds 60 --build-seconds 20
```

That path is a local acquisition artifact; restore or reproduce it in a fresh
checkout. The wrapper authenticates selected Base/cache assets, retains raw
QBE output and builds it with the supplied cached runtime. The example records
`program.ssa`, `build/program` and separate emission/build/expected-output gates.
For another source, replace `--source` and provide its independent `--expected`
file, or omit `--expected` for compile/build only. `--reference` accepts legacy
Phase111 emission receipts; the Phase114 staged-v2 full-source comparison uses
the original `compare-native-qbe.py` qualification gate instead. See the
[native replay instructions](../../selfhost/tools/performance/phase114/evidence/NATIVE.md).
Live mode changes Base preparation and is outside the current timing result. The actual
image provenance and qualification must remain visible in the adjacent report.

The underlying image argument contract is:

```text
IMAGE --threads 1 --gpu off -- phase111 ABS_INPUT ABS_BASE cache ABS_CARRIER STAMP
IMAGE --threads 1 --gpu off -- phase111 ABS_INPUT ABS_BASE live UNUSED UNUSED
```

The explicit `phase111` argument supplies the program-name slot consumed by the
Bend entry; this runtime does not prepend the executable name to `IO.args`.
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
build time can coexist with a slower compiler executable. The Phase112 and
Phase114 ratios above belong to their separately identified campaigns; their
difference does not isolate a regression. Finite
correctness results do not replace production B1/B2/upstream benchmarks. The
[metric definitions](METRICS.md) and
[Phase112 report](../../implementation/phase112/README.md) identify the evidence
needed for each claim.

## Full compiler builds and resource limits

The Phase111 complete source emits about 50.7 MB QBE and 68.8 MB assembly;
Phase112 word emits 28.46 MB and facts emits 46.54 MB QBE; qualified Phase114
source02 emits 74,220,801 QBE bytes. Its complete qualification guard took
1323.984 seconds and observed 3.820 GiB peak process-tree RSS. For full builds
use `selfhost/tools/performance/phase111/guard.py --file-mib 128` in place of
the historical Phase86 guard; its default memory/deadline supervision is shared,
and it requires additional disk headroom. The old64MiB cap is sufficient for
small fixtures but truncates the full assembly. Keep the4GiB/16GiB RSS/available
memory settings for full acquisition. See the report for exact retained commands.

Route-local labels N1/N2 mean the first direct-native compiler (acquired by the
checked JavaScript-hosted Bend API) and its native-built successor. They do not
replace the existing B1/B2 or upstream speed measurements.

## Historical Phase111 qualified native replay

The source is `full-source05/compiler.bend`; N1 is `full-native03/program`
and N2 is `native-self02/build/program`, under `selfhost/build/phase111/`.
Both use the cached `runtime-source04/runtime.o`. The report links exact source,
QBE, assembly, object, runtime and executable identities. Complete QBE/assembly/
object bytes agree; raw executables differ in linker file-symbol metadata and
build ID. Their loaded images agree except for the20-byte build-ID descriptor.

A whole compiler build requires Phase111's128MiB file cap. Runtime-only changes
can reuse an authenticated QBE object with `relink.py --build BUILD_DIRECTORY
--runtime NEW_RUNTIME_OBJECT --out FRESH_DIRECTORY`, under the usual guard.
This saves image reacquisition and QBE work; it does not skip semantic gates.

Use `coverage/native-run.py --suite fast` for five focused source cases and
`--suite focused` for all19. Each accepts `--image`, `--runtime` and a fresh
`--out`. The [full45 adapter](../../selfhost/tools/performance/phase111/coverage/full45/README.md)
provides disjoint six-case and39-case corpus partitions. These are correctness
replays with finite observations, not repeated performance benchmarks.
