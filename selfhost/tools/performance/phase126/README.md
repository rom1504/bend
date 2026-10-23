# Phase126 selected source32 reproduction

The selected compiler is `observer-divmod-source32`, with the additive
`runtime-divmod01` runtime. Source33's later optimizer is **excluded**. Its
checked API and five-program experiment are separate evidence; they cannot
replace source32 inputs or qualify its products. The installed compiler remains
unchanged.

Run commands from the repository root. Compiler, build, executable and timing
commands belong to the root's serial CPU3 lane. Every replay destination must
be fresh. The `replay32` names below are fresh-destination examples; input paths
intentionally refer to the selected, already authenticated bytes. Retain failed
attempts. Do not execute inner plan jobs outside the outer guard or launch both
native plans into their shared artifact paths.

## Selected identities and source reconstruction

The source manifest is
`selfhost/build/phase126/observer-divmod-source32/manifest.json`, SHA256
`59d6a0a835761dc293d022847e9df6a91abb34ee01fd26dd9ed9905d61dd20b9`.
It pins the parent, module inventory, overrides and protected declarations.
Its `checked: false` describes preparation, not the later checked API result.

| Artifact | SHA256 |
| --- | --- |
| `observer-divmod-source32/compiler.bend` | `40c469114c4d1c75dceab456e1979bb5c0278744a02e6dbe4a37e63667740abb` |
| `phase111/p126-observer32-api/api.mjs` | `a532828f4da3588c6e69ed6db80dbf4508ad9f1789e9d34b60d3df5566ef1446` |
| `phase111/p126-observer32-api/report.json` | `4529cfeeecf417a26ef4163b1b35c6b8d90488df2db094e4a0dc7389e94274a3` |
| `runtime-divmod01/runtime.c` | `2125198f0a44bac52de957754190d759161a289c5d6f8c802248ae24b41bfc52` |
| `runtime-divmod01/runtime.o` | `5cbc477f3f04fe87621fde3e347a913b869727aa8365a22af31d71c1d097d011` |
| `runtime-divmod01/report.json` | `5b5f57ea8d35fc2ad5c03f2bb3f854d0513b2f9d8ea12211505805d544860880` |

Unqualified paths in this table are under `selfhost/build/phase126`; paths
beginning `phase111/` are under `selfhost/build`. Native source authority is
`native/layered-authority07.json`, SHA256
`081e1c66cb287662fad3d895f0f8b08d3ccc87ab75e413ad5e507b56d40a55a8`.
The native gate independently replays the complete declaration-overlay chain,
including observer26 → divmod27 → SCC30 → native-App shape32. It retains the
original checked-request entry and verifier gates.

Reconstruct the final layer from its authenticated parent without a compiler:

```sh
python3 -B selfhost/tools/performance/phase126/product-primitive/prepare-divmod-app.py \
  --parent selfhost/build/phase126/tail-scc-source30/manifest.json \
  --modules selfhost/tools/performance/phase126/product-primitive/divmod-app-manifest01.json \
  --out selfhost/build/phase126/replay32-source
sha256sum selfhost/build/phase126/replay32-source/compiler.bend
```

The source hash must equal the selected hash above. The new manifest records
its new output path; do not substitute it into a frozen existing plan.
The excluded source33 hash is
`3843dfbfa136bfd800ecb70c5b6bb33e8a8a2ccb585030755d2d4882b162269e`.
Its changed hook and five added declarations are recorded in
`product-primitive/source32-33-inventory.json`.

## Checked API, runtime and finite predicates

The selected API report is complete and checked. Reacquisition uses the exact
same 15 exports:

```sh
python3 -B selfhost/tools/performance/phase111/guard.py \
  --out selfhost/build/phase126/replay32-api-guard --seconds 90 \
  --rss-mib 2048 --available-mib 16384 --file-mib 64 --cpu 3 -- \
  python3 -B selfhost/tools/performance/phase111/check-api.py \
  --source selfhost/build/phase126/observer-divmod-source32/compiler.bend \
  --out selfhost/build/phase111/p126-replay32-api \
  p88_cache_prepare p86_prepare p86_plan p111_runtime_admission \
  p111_emit_admitted p111_compile_source p126sc_controls p126sc_candidates \
  p126dp_controls p126dp_app_controls p126bp_controls p126nt_controls \
  p126lc_controls p126rc_controls p126i_controls

python3 -B selfhost/tools/performance/phase111/guard.py \
  --out selfhost/build/phase126/replay32-runtime-guard --seconds 60 \
  --rss-mib 2048 --available-mib 16384 --file-mib 64 --cpu 3 -- \
  python3 -B selfhost/tools/performance/phase126/product-primitive/runtime-divmod.py \
  --out selfhost/build/phase126/replay32-runtime
```

The runtime builder authenticates the selected Phase125 C prefix, adds the
exact reviewed full-width Nat.divmod helper, and retains its GCC identity and
`-O2 -std=gnu11 -ffp-contract=off` flags. Source32 must use the divmod runtime;
the integrated emitter's older default is not an acceptable substitute.
The remaining recipes use the pinned acquired API/runtime so all input
identities remain the same as the recorded campaign.

```sh
python3 -B selfhost/tools/performance/phase111/guard.py \
  --out selfhost/build/phase126/replay32-finite-guard --seconds 60 \
  --rss-mib 2048 --available-mib 16384 --file-mib 64 --cpu 3 -- \
  node --stack-size=8192 \
  selfhost/tools/performance/phase126/finite-composition-v2.mjs \
  selfhost/build/phase111/p126-observer32-api/report.json \
  selfhost/build/phase126/replay32-finite \
  p126sc_controls=16 p126dp_controls=16 p126dp_app_controls=5 \
  p126bp_controls=11 p126nt_controls=16 p126lc_controls=9 \
  p126rc_controls=13 p126i_controls=12
```

The recorded `observer32-finite/report.json` passes all **98** finite predicates.
These checked Bend predicates include refusals; they are not 98 ordinary
compiled programs or a complete proof of arbitrary programs.

## Ordinary semantic controls

Use the final `controls/cases12.json`, SHA256
`f8676302d55ccc625443591499e5884807542822a62c41a81cc57d484f939e2c`.
It pins nine sources and their independent complete-output oracles. Earlier
cases07/10/11 attempts and partial emission failures remain preserved.

```sh
python3 -B selfhost/tools/performance/phase111/guard.py \
  --out selfhost/build/phase126/replay32-controls-emit-guard --seconds 180 \
  --rss-mib 2048 --available-mib 16384 --file-mib 64 --cpu 3 -- \
  env P118_RUNTIME_REPORT=selfhost/build/phase126/runtime-divmod01/report.json \
  P118_CASE_MANIFEST=selfhost/tools/performance/phase126/controls/cases12.json \
  node --stack-size=8192 --max-old-space-size=1536 \
  selfhost/tools/performance/phase118/emit-integrated.mjs \
  selfhost/build/phase111/p126-observer32-api/report.json \
  selfhost/build/phase126/observer-divmod-source32/manifest.json \
  selfhost/build/phase118/p126-replay32-controls \
  p126-two-function-tail-scc p126-float-boundaries03 p126-float-state01 \
  p126-finite-selectors02 p126-routing-ordinary p126-owner-identity01 \
  p126-nat-boundaries03 p126-shift-tree03 divmod-boundaries

python3 -B selfhost/tools/performance/phase111/guard.py \
  --out selfhost/build/phase126/replay32-controls-run-guard --seconds 180 \
  --rss-mib 2048 --available-mib 16384 --file-mib 64 --cpu 3 -- \
  python3 -B selfhost/tools/performance/phase123/functional-aligned.py \
  --emission selfhost/build/phase118/p126-replay32-controls/report.json \
  --manifest selfhost/tools/performance/phase126/controls/cases12.json \
  --out selfhost/build/phase118/p126-replay32-controls-run \
  --label p126-replay32-controls
```

The completed receipts are `phase118/p126-final32-controls-d/report.json` and
`phase118/p126-final32-controls-run/report.json` under `selfhost/build`.
All nine programs passed the unchanged Phase112 observer after the aligned
Phase123 machine build. This gate is separate from native focused19/full45.

## Frozen broad runtime campaign

The exact current plan is
`selfhost/build/phase126/final32-broad-whole-plan01.json`, SHA256
`87bd9a5f2c0e85f1ddc7e2fc8c69079ea812e07dcb9e499321c7d50d6f6dcbc8`.
Its parent is `final32-broad-plan01.json`, SHA256
`63867a74fb45061d2d20065de630dbfd892ad5bb8948b433fd62662fbf7b3a4e`.
For a separate replay, prepare fresh paths:

```sh
python3 -B selfhost/tools/performance/phase126/broad-plan.py prepare \
  --api-report selfhost/build/phase111/p126-observer32-api/report.json \
  --source-manifest selfhost/build/phase126/observer-divmod-source32/manifest.json \
  --runtime-report selfhost/build/phase126/runtime-divmod01/report.json \
  --label replay32 --out selfhost/build/phase126/replay32-broad-plan.json
python3 -B selfhost/tools/performance/phase126/broad-whole-plan.py prepare \
  --plan selfhost/build/phase126/replay32-broad-plan.json \
  --out selfhost/build/phase126/replay32-broad-whole-plan.json
```

Root executes only the emitted `rootGuardCommand`. The single outer guard keeps
CPU3, 2 GiB RSS and 16 GiB available memory; its expressly authorized 8 MiB
individual-file limit requires more than 176 MiB free at startup. Six fresh
emitter processes handle 8/8/8/8/8/5 original cases. The unchanged merger and
ordered-45 assertion precede the aligned build and three rotated timing rounds
at scale4. There are 45 complete-output controls and 44 ratios; only the original
zero-work `scalar-region-0` is excluded from timing ratios. Comparison roles
are the selected Phase125 products and pinned upstream products.

The native qualification's one-shot programs cannot supply these batch timings:
their source bytes differ in all 45 cases. See [BROAD-WHOLE.md](BROAD-WHOLE.md)
for the exact guard derivation and the preserved negative reuse audit. Final
results belong in `final32-emission.json`, `final32-screen/report.json` and
`final32-summary.json` under `selfhost/build/phase126`. Plan preparation is not
evidence that those jobs completed, and the five-case observer32 screen is not
the broad result.

Historical Phase125 broad emission took 513.83 seconds and its aligned build plus
screen 227.26 seconds: about 12.4 minutes combined. A 13–16 minute planning
estimate allows fresh-process overhead and source32 variation; the actual
3330-second outer deadline and per-job deadlines remain unchanged. Prior QBE
plus build directories occupied 93.26 MiB. Adding 64 MiB slack gives 157.26 MiB,
an observed-size forecast rather than an aggregate output guarantee. Check disk
again after native qualification; [the storage audit](../../../build/phase126/broad-storage-audit01.json)
does not reserve space.

## Native source32 qualification

The selected ABI receipt is `selfhost/build/phase126/native32-abi01.json`
(SHA256 `a464c08f61a59d33f5cb512a25924d89e2e131bb48a76803dbacb9763ac9a7d4`).
The active plan is `native32-staged-plan01.json`
(SHA256 `a84f90bdc2504e38bee4aad3575a99c859e66ccd67ad657a08e2d6543bbaff61`).
Its retained unstaged parent is `native32-plan01.json`; do not execute both.
A separate replay uses the same gates and fresh destinations:

```sh
python3 -B selfhost/tools/performance/phase126/native/rebind-abi-v5.py \
  --source-manifest selfhost/build/phase126/observer-divmod-source32/manifest.json \
  --api-report selfhost/build/phase111/p126-observer32-api/report.json \
  --runtime-report selfhost/build/phase126/runtime-divmod01/report.json \
  --out selfhost/build/phase126/replay32-abi.json
python3 -B selfhost/tools/performance/phase126/native/plan-v2.py prepare \
  --api selfhost/build/phase111/p126-observer32-api/api.mjs \
  --source selfhost/build/phase126/observer-divmod-source32/compiler.bend \
  --runtime selfhost/build/phase126/runtime-divmod01/runtime.o \
  --abi-receipt selfhost/build/phase126/replay32-abi.json \
  --tag p126-replay32-native --out selfhost/build/phase126/replay32-native-plan.json
python3 -B selfhost/tools/performance/phase126/native/stage-plan-v2.py \
  --plan selfhost/build/phase126/replay32-native-plan.json \
  --out selfhost/build/phase126/replay32-native-staged-plan.json
```

Execute only the staged plan's `rootGuardCommand`: twelve serial jobs retain
full hosted emission → aligned N1 → N1 focused19 → native self-emission →
aligned N2 → exact raw-QBE comparison → N2 focused19/full45. Staging adds actual
disk checkpoints and hash-plus-byte-verified deduplication of closed products;
it removes no semantic gate. Limits are CPU3, 6 GiB RSS, 16 GiB available,
128 MiB per file and 4200 seconds. Details are in
[native/README-staged.md](native/README-staged.md).

Completion requires the actual `phase113/p126-native32-qualification/report.json`,
outer `phase126/p126-native32-qualification-guard/process.json`, comparison
`phase126/p126-native32-qbe-comparison.json`, and referenced suite receipts
under `selfhost/build`. Planned image paths are
`phase111/p126-native32-n1/program` and
`phase111/p126-native32-self/build/program`. A successful plan constructor or
checked API alone does not establish native qualification, ELF equality,
N2 self-reproduction or production promotion.

## Matched compiler cost

The completed hosted cost receipt is
`selfhost/build/phase118/p126-final32-cost/report.json`. One warmup and three
rotated pairs cover `test-rle-roundtrip` and `lexer`, with each producer's output
checked against its own exact prior emission. Source32/Phase125 geometric
ratios are **1.08745× total request time** and **1.13212× admitted-stage time**
(higher is slower). This is a two-request hosted result, not native compiler
throughput or generated-program runtime.

```sh
python3 -B selfhost/tools/performance/phase111/guard.py \
  --out selfhost/build/phase126/replay32-cost-guard --seconds 300 \
  --rss-mib 2048 --available-mib 16384 --file-mib 64 --cpu 3 -- \
  env P118_PARENT_SELECTION=implementation/phase125/candidate.json \
  P118_PARENT_API_REPORT=selfhost/build/phase111/p125-verified06-api/report.json \
  P118_RUNTIME_REPORT=selfhost/build/phase126/runtime-divmod01/report.json \
  P118_PARENT_EMISSION_REPORT=selfhost/build/phase125/broad-emission06.json \
  P118_EXPECT_EMISSION_REPORT=selfhost/build/phase118/p126-observer32-emit/report.json \
  selfhost/.bootstrap/bun-1.4.3/bun \
  selfhost/tools/performance/phase118/cost-v2.mjs \
  selfhost/build/phase111/p126-observer32-api/report.json \
  selfhost/build/phase126/observer-divmod-source32/manifest.json \
  selfhost/build/phase118/p126-replay32-cost test-rle-roundtrip lexer
```

Optional native N1/N2 request timing is separately prepared by
`native/timing-plan.py` only after all twelve qualification jobs succeed; see
[native/README-timing.md](native/README-timing.md). Its unchanged inner runner
requires 256 MiB free before every request. Do not lower that gate to fit the
campaign, or report an unrun optional block as a result.

These recipes were checked against source and actual manifests/command receipts
without executing targets. Earlier implementation experiments, failed controls,
source33, rejected tree-reshape variants, and partial screens remain separate
from the selected source32 qualification and broad denominator.
