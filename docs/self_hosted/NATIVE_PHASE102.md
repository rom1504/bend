# Phase102 qualified native candidate: opt-in use

Phase102 candidate03 is a semantically qualified native B1/B2 compiler, available
through an explicit selection. **Phase98 remains the default.** Candidate03
improves the measured applications and broad runtime aggregate, but reproducible
local-fold regressions of roughly 10–19% block default promotion. See the
[campaign report](../../implementation/phase102/README.md) and
[runtime diagnosis](../../implementation/phase102/runtime-regression-review.md).

The exact candidate is `projection-cold-source01/compiler.bend`, SHA256
`b3927732f2250c19a7a8988dab7cbf30726359c18b5305f73c28cadddb902d1f`:
1,788,748 bytes and 39,370 physical lines, 580 above Phase98. It composes direct
workers, lowers bounded constructor recursion to loops, removes immediately
projected observer products, and preserves each destination's cold-field policy.
The [lowering guide](phase102-native-lowering.md) explains the mechanisms.

## Compile with candidate03

From the repository root, use a fresh output path and the explicit pointer:

```sh
python3 -B selfhost/native.py input.bend -o output-phase102.c --selection selfhost/build/phase99/phase102-release03/selection.json
python3 -B selfhost/native.py input.bend -o output-phase102-b1.c --selection selfhost/build/phase99/phase102-release03/selection.json --stage b1
```

The first command selects candidate03 B2; the second selects its upstream-built
B1 parent. Omitting `--selection` continues to select Phase98. Ordinary requests
execute the native Bend compiler; Python authenticates assets and bounds the
request. These commands emit C. Building and executing the generated program
are separate operations.

`--live` checks Base instead of using its authenticated prepared carrier.
`--calls 5` requires five identical complete C outputs. The default request
deadline is 60 seconds; `--seconds` accepts 1–600. Existing output paths are
refused. Raw request evidence remains under `selfhost/build/native/requests/`.

## Restore request assets and replay source

The candidate's staged request capsule is
`selfhost/tools/native/releases/phase102-staged03/receipt.json`, SHA256
`0a5280e88ff057eb4d69878f57380761ec925bcdee9bdae88314d83a71d5bc95`.
Sealing and verification pass for all 36 files, with zero missing files.
To restore missing assets and verify them, use:

```sh
python3 -B selfhost/tools/native/assets.py restore selfhost/tools/native/releases/phase102-staged03/receipt.json
python3 -B selfhost/tools/native/assets.py restore selfhost/tools/native/releases/phase102-staged03/receipt.json --verify-only
```

Restoration preserves the explicit staged selection path and does not replace
the Phase98 default pointer. It refuses changed existing files or modes. The
capsule is for the recorded checkout location because source identities and
Base-cache paths are absolute. It contains request assets; large qualification
products and raw experiment history belong to the separate evidence archive.
Verification did not exercise an actual missing-file restoration.

The immutable [lowering03 profile](../../selfhost/tools/native/profiles/phase102-lowering03/profile.json)
replays the exact candidate without executing a compiler. Use fresh paths:

```sh
python3 -B selfhost/tools/native/profile.py --profile selfhost/tools/native/profiles/phase102-lowering03/profile.json --out-source /tmp/compiler-phase102.bend --receipt /tmp/compiler-phase102-replay.json
```

The 26,753-byte delta reverses to the committed D04 source. Its experimental
source-transport metadata is separate from native image qualification; source
replay alone does not qualify a compiler.

## Qualification and measured tradeoffs

Admission is `selfhost/build/phase102/native-chain03/admission.json`, SHA256
`585103080cb206fc8a845924147824f18bc1d82cdacabe5b4f9b88f25fab6188`.
The genuine B1→B2 chain, exact self-C/diagnostic fixed point, live/cache/refusal
controls, broad45, 69 native fixtures per stage, backend bridge and original
five final-image controls pass. All nine public CLI controls also pass.
B1's ELF is `314b90d4…52f7e12`; B2's is `57104046…97aacbe`.

Four alternating rounds compare complete application processes, including
startup and IO. The independent 50-input suite passes 165 complete outputs.

| Application | Candidate03 / Phase98 | Candidate03 / upstream |
|---|---:|---:|
| Source index, 10,000 generated definitions | 0.531 | 0.915 |
| Source index, compiler text | 0.510 | 1.102 |
| Renderer, one worker | 0.731 | 0.988 |
| Renderer, four workers | 0.792 | 1.129 |
| Dependency planner, DAG800 | 0.653 | 0.220 |
| Dependency planner, chain1000 | 0.682 | 0.246 |

Separately, 44 positive-work benchmark points have an equal-point geometric
mean of **0.9553× Phase98** and **1.0628× upstream** runtime. Equal original-source
weighting gives 0.9608× and 1.0822×. These warmed program timings exclude compiler
requests, Clang builds and startup; the zero-work control has no ratio. Aggregates
do not erase individual regressions. The reproduced local-fold slowdown is
associated with newly forced inline hints and keeps this release opt-in.

## Supported boundary

Compiler requests use one CPU worker with GPU disabled. The maintained host
accepts one canonical Base-importing source and nine authenticated effects:
`IO.args`, `IO.print`, `IO.now`, `IO.print_err`, `File.open`, `File.read`,
`File.size`, `File.write` and `File.close`. It does not provide the full module
import or frontend observation interface. Provider identity and trusted source
origin remain required; unsupported optimization shapes use owning fallbacks.

Finite controls and a source-bound self fixed point are not a universal compiler
or native-memory proof. GPU and parallel compiler-host qualification are not
claimed. The installed JavaScript release and canonical source modules remain
separate. The later projection-cost candidate04 is experimental and is not
part of this admission, selection or source profile.
