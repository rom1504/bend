# Direct x86 target

The maintained `x86` target emits ELF64 objects or GNU-style AMD64 SysV assembly
from Bend's checked native program. Direct objects are the executable-build
default; assembly remains an explicit output. Both use the declared linker to
build a Linux ELF, and only the assembly route runs an assembler. Compiler
algorithms live in
[`selfhost/src/back/x86/`](../../selfhost/src/back/x86/). The target shares the
frontend, native lowering, verifier and sequential runtime with QBE; it does
not invoke QBE's machine-code stage. The runtime contract is ABI11102.

The active language pin is upstream
`9a4223d577ba56a0cb53d1fd952d2b481c38930f` (Bend2.0.40). The supported execution
policy is one mutator with GPU disabled. Other architectures, GPU execution,
parallel policies and unrestricted foreign interfaces are outside this target's
current scope. Target support, finite qualification, bootstrap reproduction and
performance are separate claims. The [current selector](../../selfhost/manifests/current.json)
and its gate receipts bind the installed x86 N2 at `selfhost/dist/x86/bend`;
the operational asset key is `x86-n2`. The
[Phase189 report](../../implementation/phase189/README.md) records the newer
Phase188 x86 source, actual object generations, qualification and completed
installation. Its operational asset maps are published. The previous Phase183
image and selector remain available for rollback.

## Current development pipeline

The Phase189 release selects the checked Phase188 source, including the bounded
Phase186 optimizations and the shared typed machine boundary. JS/C/QBE retain
their exact Phase182 image and source identities; x86 qualification belongs to
its own source and image. See the [Phase186 report](../../implementation/phase186/README.md)
for its original candidate runtime measurements and the
[Phase188 report](../../implementation/phase188/README.md) for the typed refactor.

The assembly backend reuses checked scalar-array and late native expansions,
then applies stable copy elimination, scalar facts, dead-assignment removal and
local stack-cell forwarding before machine placement. Temporary values confined
to one call-free region can use caller-saved registers; values crossing calls,
branches or loop boundaries keep the conservative homes. Scalar binary emission
uses known destination registers directly, and admitted binary F32 operations
use scalar SSE instructions under the same numeric contract as QBE. Unknown
cases retain the original lowering. These are compiler algorithms written in
Bend, not host-language code-generation shortcuts.

Phase186 adds private-memory elimination, bounded expression reuse, direct ABI
moves, selective saves and explicit F32 operand plans. Closed canonical F32
regions can retain XMM values; exact U32-to-F32 calls use direct instructions.
Unknown calls, escaped values and control-flow boundaries preserve conservative
homes. The same verified state-transfer and Char expansions also serve QBE.
The [qualified candidate guide](../../implementation/phase186/native-qualification.md)
provides explicit N2 commands; source changes do not silently replace installed images.

The passes operate on the existing verified native statements. They preserve
entry setup versus loop-backedge semantics, operand snapshots, alias barriers,
widths, effect order and the runtime ABI. Finite adversarial machine controls
and native qualification are separate from the unchanged final IR verifier;
these optimizations do not establish an end-to-end compiler theorem.

## Public commands

Run the installed compiler from the repository root:

```sh
selfhost/bend --target x86 input.bend -o output.s
selfhost/bend --target x86 input.bend -o output
selfhost/bend --target x86 input.bend --run
selfhost/bend --target x86 input.bend --run -- first-argument second-argument
```

An output ending in `.s` selects assembly emission; any other output name with
`--target x86`, including `.o`, selects a linked ELF. In the Phase189 release,
ELF builds and `--run` use direct Bend-emitted objects without an assembler.
The authenticated selector records `defaultEmission: object`; a previous
selector without that field retains assembly behavior for rollback. `--run`
builds a temporary executable,
preserves application arguments after `--`, and returns the program's status.
`--live` selects live Base preparation; the default uses the authenticated
prepared Base. The wrapper supplies the selected runtime's sequential arguments.
Keep ambient `BENDRTS` unset.

`selfhost/bend input.bend -o output.s` also selects assembly. The JS launcher
accepts the same x86 forms, for example
`node selfhost/cli.mjs --target x86 input.bend --run`. Existing output files and
symlinks are refused, and the output parent must already exist. Default C and JS
routes retain their existing interfaces. A missing qualified x86 component is
an admission error; development images use the explicit tools below.

## Build with an explicit image

The [source manifest](../../selfhost/src/compiler.json) owns the `x86` profile,
including backend modules and its reachable native entry closure:

```sh
python3 -B selfhost/tools/build/source.py assemble \
  --manifest selfhost/src/compiler.json --root selfhost --profile x86 \
  --out selfhost/build/current-x86-source/compiler.bend \
  --map selfhost/build/current-x86-source/compiler.map.json
```

Source assembly executes no compiler. Independently check the resulting source
with the [maintained source-check workflow](workflow.md#assemble-before-building).
Its bytes and source map identify this profile; a QBE source image or a hosted
API has a separate identity. Hosted JS emission does not implement the native
`native-x86-source-v1` request protocol.

Set `X86_IMAGE`, `X86_RECEIPT` and `X86_STAGE` to an actual compiler executable,
its complete maintained image-binding receipt, and its recorded generation.
The receipt must advertise `native-x86-source-v1` and target `x86`. A preflight
request authenticates the source, image, Base and preparation mode without
running the target:

```sh
python3 -B selfhost/tools/build/request.py \
  --assets selfhost/manifests/assets-native.json \
  --image "$X86_IMAGE" --image-receipt "$X86_RECEIPT" \
  --host native --stage "$X86_STAGE" --target x86 --mode cache \
  --source input.bend --out selfhost/build/current-x86-request \
  --seconds 60 --plan
```

Remove `--plan` and execute inside one [resource guard](build-retention.md) to
capture `program.s`. Raw requests remain assembly by default; add `--emit object`
to capture `program.o`. To emit an object and link in the same request, use
`native.py`, whose x86 source-build default is object:

```sh
python3 -B selfhost/tools/build-retention/guard.py \
  --out selfhost/build/current-x86-build-guard \
  --run-root selfhost/build/current-x86-build --disk-mib 512 \
  --seconds 150 --rss-mib 3072 --available-mib 16384 --file-mib 128 --cpu 3 -- \
  python3 -B selfhost/tools/build/native.py \
    --assets selfhost/manifests/assets-native.json \
    --image "$X86_IMAGE" --image-receipt "$X86_RECEIPT" \
    --host native --stage "$X86_STAGE" --target x86 --mode cache \
    --source input.bend --out selfhost/build/current-x86-build --seconds 120
```

Choose fresh paths and resource limits appropriate to the workload. The default
build retains `program.o`, `program` and its report. It records the emission
format and skipped assembler. Use `--expected-object` to check complete object
bytes against an existing independent reference. For the assembly route, add
`--emit assembly --retain-ir` and choose fresh output and guard paths; that build
also retains `program.s`, and `--expected-assembly` checks complete assembly bytes.
`--expected-stdout` additionally executes the program and compares complete
stdout. `--ir existing.s --target x86` constructs machine products from retained
assembly without a compiler request; `--ir existing.o --target x86 --emit object`
links retained object bytes. An alternate runtime needs explicit
`--runtime`, `--runtime-abi 11102` and its actual
`--runtime-argument-convention bend-rts-v1`; filenames do not establish an ABI.

## Bootstrap the x86 compiler

First acquire N0 from the checked x86 profile with a qualified QBE producer.
Under the resource guard, use `native.py --target qbe` with that source and
`--output-stage N0 --output-protocol native-x86-source-v1`. For example, select
`--image-key qbe-n2 --host native --stage N2`, retain the source map above, and
write to `selfhost/build/current-x86-seed`. N0's machine construction uses QBE;
its executed compiler entry supports x86 assembly and object emission. The output
protocol describes the acquired executable's interface, separately from the
backend that built it.

Then run the maintained chain on the **same** x86 source:

```sh
python3 -B selfhost/tools/build-retention/guard.py \
  --out selfhost/build/current-x86-chain-guard \
  --run-root selfhost/build/current-x86-chain --disk-mib 4096 \
  --seconds 1830 --rss-mib 4096 --available-mib 16384 --file-mib 512 --cpu 3 -- \
  python3 -B selfhost/tools/build/bootstrap.py \
    --assets selfhost/manifests/assets-native.json \
    --image selfhost/build/current-x86-seed/program \
    --image-receipt selfhost/build/current-x86-seed/report.json \
    --host native --stage N0 --target x86 --mode cache \
    --source selfhost/build/current-x86-source/compiler.bend \
    --out selfhost/build/current-x86-chain --seconds 1800
```

The generic bootstrap deliberately retains assembly as its default. Actual N0
emits N1, actual N1 emits N2, and actual N2 emits S3. The chain compares
complete `n1/program.s`, `n2/program.s` and `s3/program.s`; S3 is emission, not
another claimed executable generation. The `bend-native-bootstrap-chain` report
records `target: x86` and `assemblyFixedPoint`. `machineIdentity` separately
records assembly, object and ELF equality between N1 and N2. Object or ELF
differences cannot skip N2 execution. A fixed point neither installs an image
nor establishes semantic conformance.

For an object chain, add `--emit object` and choose fresh output/guard paths.
The tool compares `n1/program.o`, `n2/program.o` and `o3/program.o`, recording
`objectFixedPoint`; O3 is an emission, not an executable generation. This generic
recipe does not rename the release's real lineage: Phase189 reused a QBE-built
N1 and object-built N2, then built an actual N3 from the same source and required
complete object-byte equality with the object that produced N2.

## Benchmark and profile

Use the existing [native45 catalog](../../selfhost/tools/bench/catalogs/native45/catalog.json)
and its independent outputs. Copy the
[current acquisition recipe](../../selfhost/tools/bench/examples/acquire-native.json)
with its paths resolved, and set the candidate role to `target: "x86"` with
`imageKey: "x86-n2"` for an installed N2, or explicit `image` and `imageReceipt`
for a development image. Preserve its actual `host`, `stage`, `policy` and
qualification status. Keep the upstream C role for independent comparison; do
not reuse historical runtime measurements as a fresh denominator.
This acquisition adapter currently uses raw requests and therefore selects
assembly; it does not inherit `native.py`'s object default. Use explicitly
recorded `--emit object` native builds for object comparisons, and consume the
actual output format recorded in each receipt.

```sh
python3 -B selfhost/tools/bench/acquire.py \
  --recipe x86-benchmark.json --cases coverage-numeric-recurrence-256 \
  --seconds 300 --out selfhost/build/current-x86-bench-products --plan
```

Acquire under one guard by removing `--plan` and adding `--guarded`. Acquisition
emits `programs.manifest.json` and, when exact replay is available,
`compiler.manifest.json`. Under a separate guard, the corresponding timing
command is:

```sh
python3 -B selfhost/tools/bench/bench.py run \
  --manifest selfhost/build/current-x86-bench-products/programs.manifest.json \
  --cases coverage-numeric-recurrence-256 --budget 20 --rounds 2 --guarded \
  --out selfhost/build/current-x86-bench-run
```

Use the compiler manifest for compiler-request timing. Program execution,
compiler emission, complete source-to-executable construction and profiling
have separate clocks and budgets. See the [benchmark guide](../../selfhost/tools/bench/README.md)
for 20/60/300/600-second ceilings, rotation, larger case sets and quality gates.
Static inspection accepts assembly directly. Use the assembly bootstrap above,
or an explicit `native.py --emit assembly --retain-ir` build with its own receipt;
the default object build has no `program.s`:

```sh
python3 -B selfhost/tools/bench/inspect.py --target x86 \
  --source selfhost/build/current-x86-chain/n2/program.s \
  --binary selfhost/build/current-x86-chain/n2/program \
  --out selfhost/build/current-x86-inspection
```

The [native profiler](PROFILING.md) samples the linked ELF using explicit
workloads and independent output oracles. Prepare its sampler and recipe as
documented there, freeze with `profiler/freeze.py`, then run
`profiler/run.py --modes clean,sample` under the guard. Keep clean timing separate
from diagnostic captures. Assembly ownership maps use:

```sh
python3 -B selfhost/tools/profiler/owners.py \
  --assembly selfhost/build/current-x86-chain/n2/program.s \
  --build-receipt selfhost/build/current-x86-chain/n2/report.json \
  --source-map selfhost/build/current-x86-source/compiler.map.json \
  --source-root selfhost \
  --emitter-source selfhost/src/back/x86/program.bend \
  --emitter-source selfhost/src/back/x86/function.bend \
  --output selfhost/build/current-x86-chain/owners.json
```

This offline command binds the emitted assembly, completed build and actual
source map. `attribute.py` additionally validates the mapping against the
sampled ELF. Declaration ownership is conditional on the lowering contract;
it does not reconstruct every inlined origin or turn source counts into time.

## Qualification boundaries

The current finite source/output authority is the
[64-case catalog](../../selfhost/tests/phase182/qualification-catalog.json),
whose upstream pin must agree with the selected assets. Maintained
`qualification.py --target x86 --emit object --suite all` uses this catalog through the
asset declaration or explicit `--catalog`; historical default catalogs are
separate authorities. Machine ABI controls, namespace hygiene, the ten current
runtime controls, live/cache agreement, public-command behavior, and actual
bootstrap each have their own receipts. Qualification defaults to assembly for
compatibility; always select `--emit object` explicitly for the object release gate.

The installed Phase189 x86 N2 has complete object-byte reproduction from its actual
QBE-built N1 → object-built N2 → object-built N3 lineage. Its independently
checked Phase188 source has zero unresolved holes. All 64 finite catalog cases
and ten runtime controls pass through direct objects. All 14 installed
public-command controls pass, with separate receipts in the Phase189 report.
These are finite execution, reproduction and source-acceptance boundaries, not
a new kernel proof or whole-compiler correctness theorem.

The [Phase183 control adapters](../../selfhost/tests/phase183/abi-audit.md)
preserve the fixture oracles, and the
[Phase189 report](../../implementation/phase189/README.md) links the current
image receipts and completed release installation. New source edits or
rebuilt images require their own relevant gates. The
[Phase181 report](../../implementation/phase181/README.md) preserves historical
ABI11101 measurements; they do not qualify the current ABI11102 target or imply
a current speed advantage over QBE.

## Current performance boundary

Phase188's controlled identical-source compiler build takes 205.019s through
objects versus 197.400s through assembly. The previous object implementation
took 315.348s: a 35.0% reduction, but the new object route still takes 1.039×
assembly time. These are single controlled build observations, not confidence
intervals or generated-program runtime measurements. The Phase189 default
change does not claim a speed advantage over assembly.

Phase188 preserves the corresponding Phase187 machine code and data on the full
compiler and both routes of the 45-program corpus. The object and assembly
formats still have different branch-relaxation/alignment policies. See the
[Phase188 measurements](../../implementation/phase188/README.md) for exact scope;
older [Phase186 runtime results](../../implementation/phase186/runtime-summary.md)
retain their original image and workload identities.

## Direct object output

The default native executable route writes ELF64 using Bend, skipping the
external assembler while retaining the authenticated linker and runtime. Shared
typed instructions feed both consumers; the object route never constructs or
parses assembly text. See [object emission](x86-objects.md) for supported scope,
limits, qualification and explicit assembly comparisons.


## Qualified research source after the installed release

[Phase193](../../implementation/phase193/README.md) qualifies the maintained x86
source through direct-object N1→N2→N3 reproduction, independent source checking,
native64/runtime10 and all45 ordinary outputs. Four checked-hosted products and
all45 N1/N2 products agree exactly. It composes the existing verified helper and
continuation plans with a bounded code-growth policy; the common runtime and
final verifier are unchanged.

Fresh native45 timing is2.117890×mature Bend C, 4.16% less than Phase192. Four native
compiler requests take9.32% less time, while the same-producer source-cost screen
is2.94% slower. These are separate program/compiler metrics; full-source builds
and all regressions are in the report. Current qualified research N2 is
`selfhost/build/phase193/budget-native-self01/program` with its `report.json`.
Installed Phase189 remains the default; selecting this research image is explicit.
Finite qualification and reproduction do not establish whole-compiler correctness.
