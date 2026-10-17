# Phase102 corrected native default

For ordinary requests, the newer [Bend CLI](NATIVE_CLI.md) runs these compiler
algorithms directly as `selfhost/bend INPUT.bend -o OUTPUT.c`, without Python.
This page retains the supervised stage-selection and exact historical admission
interface used for benchmarking.

Corrected candidate04 is the default native B1/B2 compiler. Its exact source is
`projection-cost-source01/compiler.bend`, SHA256
`63ef222c4c6de73bb54c8e51d3b0a0552979b5791ea98e64d1098051a9cda237`:
1,788,947 bytes and 39,372 physical lines, 582 above Phase98. It retains the
worker, observer and constructor transformations and corrects the projected-cost
policy for forced inline hints. The [promotion report](../../implementation/phase102/default-promotion.md)
records qualification, measurements and the completed default selection.
Candidate03 and its original measurements remain historical.

## Compile

From the repository root, use fresh output paths:

```sh
python3 -B selfhost/native.py input.bend -o output.c
python3 -B selfhost/native.py input.bend -o output-b1.c --stage b1
```

The first command runs genuine self-hosted native B2. The second selects its
qualified upstream-built B1 parent. Python authenticates assets and bounds the
request; compiler algorithms execute in the native Bend image. These commands
emit C. Building and executing the generated program are separate operations.

`--live` checks Base instead of using its authenticated prepared carrier.
`--calls 5` requires five identical complete C outputs. The default deadline is
60 seconds; `--seconds` accepts 1–600. Existing outputs are refused. Every request
retains raw evidence under `selfhost/build/native/requests/`. An explicit
`--selection PATH` can still choose a retained historical admission pointer.

## Restore and replay

The stable request capsule is
`selfhost/tools/native/releases/phase102-assets04/receipt.json`, SHA256
`fadcf2ad594121d695acada6b3bb453c9b21000df1e03fde6e8e6c47e5e7d7e4`.
It was sealed from the actual default pointer; verification passes for all
35 files with zero missing. Restore missing assets, then verify them with:

```sh
python3 -B selfhost/tools/native/assets.py restore selfhost/tools/native/releases/phase102-assets04/receipt.json
python3 -B selfhost/tools/native/assets.py restore selfhost/tools/native/releases/phase102-assets04/receipt.json --verify-only
```

Restore refuses changed existing bytes or modes and requires the recorded
checkout location. The stable capsule includes the default selection path;
`phase102-staged04` preserves a separate explicit pointer. Verification did not
exercise an actual missing-file restoration. Keep old capsules unchanged: their
historical default-pointer bytes differ by design. Request capsules contain the
images and launch assets; large qualification products and raw experiment
history are preserved separately.

Replay the exact source without running a compiler, using fresh output paths:

```sh
python3 -B selfhost/tools/native/profile.py --profile selfhost/tools/native/profiles/phase102-lowering04/profile.json --out-source /tmp/compiler-phase102-default.bend --receipt /tmp/compiler-phase102-default-replay.json
```

The immutable [lowering04 profile](../../selfhost/tools/native/profiles/phase102-lowering04/profile.json)
has SHA256 `386fe7a769890eb84495ee8b362eb8c9d34b6e9183b7dece7c195a63b55d6edb`.
Source replay is separate from native qualification. Name this profile explicitly:
`profile.py` retains its historical Phase98 default.

## Qualification and measured tradeoffs

Admission is `selfhost/build/phase102/native-chain04/admission.json`, SHA256
`a8a7abd1c985604d7d3e944c558a770c08e3e43d9035dfe54977d122e880c8b0`.
The genuine B1→B2 chain and exact self-C/diagnostic fixed point pass, alongside
live/cache/refusal controls, broad45, 69 eligible native fixtures and 3 expected
rejections per stage, the backend bridge and original five final-image controls.
The nine public CLI controls and actual default cached-small request also pass.
B1 ELF: `b2aec9e6…aea7a66`; B2 ELF: `85a70429…9ec60f7`.

The stable selection SHA256 is
`abcf83f679c38aacd21dc121dcc479337f9e4bd77001be8dbfa261da6ca20285`.
The promotion receipt preserves the exact preceding Phase98 pointer and binds
the source-specific performance acceptance.

Compiler and program measurements remain separate. The repeated six-source
compiler screen uses 27.6% less B2 request time and 31.1% less B2 process time
than the same Phase98 stage; B1 is about 2.6% slower. Single full-self observations
do not establish a self-compilation speed gain. Separately, 44 warmed program
points have equal-point runtime ratios of 0.9365× Phase98 and 1.0435× upstream;
source weighting gives 0.9362× and 1.0653×. All six complete application points
improve on Phase98, while compiler-text indexing and four-worker rendering
remain slower than upstream. See the report for samples, remaining gaps and
both the initial numeric slowdown and its neutral balanced repeat.

## Supported boundary

Compiler requests use one CPU worker with GPU disabled. The host accepts one
canonical Base-importing source and nine authenticated effects: `IO.args`,
`IO.print`, `IO.now`, `IO.print_err`, `File.open`, `File.read`, `File.size`,
`File.write` and `File.close`. Full module imports and frontend observation are
outside this entry. Provider identity and trusted source origin remain required;
unsupported optimization shapes retain owning fallbacks.

Finite controls and a source-bound fixed point are not a universal compiler or
native-memory proof. GPU and parallel compiler-host qualification are not claimed.
The installed JavaScript release remains separate. The 34,231-line canonical
module inventory is unchanged; the current native profile is separately assembled.
