# Direct assembly target

The maintained `x86` target emits GNU-style AMD64 SysV assembly from Bend's
checked native program, then uses the declared assembler and linker to build
a Linux ELF. Compiler algorithms live in
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
[Phase183 report](../../implementation/phase183/README.md) records its source,
actual generations, qualification and audited installation.

## Current development pipeline

Phase186 adds bounded optimizations to the maintained source; the installed
Phase183 image remains a separately qualified artifact until release promotion.
See the [Phase186 report](../../implementation/phase186/README.md) for actual
candidate identities, runtime results and native qualification status.

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
`--target x86` selects a linked ELF. `--run` builds a temporary executable,
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
capture `program.s`. To assemble and link in the same request, use `native.py`:

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

Choose fresh paths and resource limits appropriate to the workload. The build
retains `program.s`, `program.o`, `program` and its report. `--expected-assembly`
checks complete emitted bytes against an existing independent reference;
`--expected-stdout` additionally executes the program and compares complete
stdout. `--ir existing.s --target x86` constructs machine products from retained
assembly without a compiler request. An alternate runtime needs explicit
`--runtime`, `--runtime-abi 11102` and its actual
`--runtime-argument-convention bend-rts-v1`; filenames do not establish an ABI.

## Bootstrap the assembly compiler

First acquire N0 from the checked x86 profile with a qualified QBE producer.
Under the resource guard, use `native.py --target qbe` with that source and
`--output-stage N0 --output-protocol native-x86-source-v1`. For example, select
`--image-key qbe-n2 --host native --stage N2`, retain the source map above, and
write to `selfhost/build/current-x86-seed`. N0's machine construction uses QBE;
its executed compiler entry emits x86 assembly. The output protocol describes
the acquired executable's interface, separately from the backend that built it.

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

Actual N0 emits N1, actual N1 emits N2, and actual N2 emits S3. The chain compares
complete `n1/program.s`, `n2/program.s` and `s3/program.s`; S3 is emission, not
another claimed executable generation. The `bend-native-bootstrap-chain` report
records `target: x86` and `assemblyFixedPoint`. `machineIdentity` separately
records assembly, object and ELF equality between N1 and N2. Object or ELF
differences cannot skip N2 execution. A fixed point neither installs an image
nor establishes semantic conformance.

## Benchmark and profile

Use the existing [native45 catalog](../../selfhost/tools/bench/catalogs/native45/catalog.json)
and its independent outputs. Copy the
[current acquisition recipe](../../selfhost/tools/bench/examples/acquire-native.json)
with its paths resolved, and set the candidate role to `target: "x86"` with
`imageKey: "x86-n2"` for an installed N2, or explicit `image` and `imageReceipt`
for a development image. Preserve its actual `host`, `stage`, `policy` and
qualification status. Keep the upstream C role for independent comparison; do
not reuse historical runtime measurements as a fresh denominator.

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
Static inspection accepts assembly directly:

```sh
python3 -B selfhost/tools/bench/inspect.py --target x86 \
  --source selfhost/build/current-x86-build/program.s \
  --binary selfhost/build/current-x86-build/program \
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
`qualification.py --target x86 --suite all` uses this catalog through the
asset declaration or explicit `--catalog`; historical default catalogs are
separate authorities. Machine ABI controls, namespace hygiene, the ten current
runtime controls, live/cache agreement, public-command behavior, and actual
bootstrap each have their own receipts.

Installed N2 passes all 64 cases with no unsupported cases and all ten current
runtime controls. Actual N1/N2/S3 emit identical complete assembly; N1/N2
objects also agree. Their ELF files differ only in `.strtab`, with all allocated
sections identical. The independently checked source has zero unresolved holes.
These are finite execution, reproduction and source-acceptance results, not a
new kernel proof or whole-compiler correctness theorem.

The [Phase183 control adapters](../../selfhost/tests/phase183/abi-audit.md)
preserve the fixture oracles, and the
[Phase183 report](../../implementation/phase183/README.md) links the completed
current-image receipts and audited release promotion. New source edits or
rebuilt images require their own relevant gates. The
[Phase181 report](../../implementation/phase181/README.md) preserves historical
ABI11101 measurements; they do not qualify the current ABI11102 target or imply
a current speed advantage over QBE.

## Current performance boundary

The maintained Phase185 source now has qualified explicit QBE and assembly N2
candidates. On44 timed cases from native45, assembly is5.56× our C backend and
QBE1.48×. Selected assembly kernels improve1.34–6.35× over retained Phase183
products; there is no full45 old-assembly score. Both new native chains reproduce,
both pass64 finite cases, and assembly passes the ten current runtime controls.
The installed selector remains Phase183 pending coherent all-target publication.
See the [current performance report](../../implementation/phase185/README.md) and
[explicit candidate commands](../../implementation/phase185/native-qualification.md).

For the installed Phase183 version, native self-emission
is about 1.96× the QBE-built seed time. The maintained fast-five screen finds
assembly about 25–50× QBE time on three list/numeric kernels; these cases are
not the full45 runtime score. The20s budget expires on the unchanged repetition
counts. Use an explicit `--set fast --budget 300 --rounds 3` for this target;
budget presets are ceilings, not a promise that every selected target finishes.
One upstream batch remains below the resolution threshold, so this screen has
no admitted set-wide geometric mean. See the [measured report](../../implementation/phase183/README.md).
