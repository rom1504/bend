# Phase102 native release readiness

**Candidate03 is qualified and available for opt-in use. Phase98 remains the
default.** The source is `projection-cold-source01/compiler.bend`, SHA256
`b3927732f2250c19a7a8988dab7cbf30726359c18b5305f73c28cadddb902d1f`.
Native admission, all nine public CLI controls, staged capsule sealing and
verification are complete. The [candidate guide](../../docs/self_hosted/NATIVE_PHASE102.md)
provides exact restore, source replay and explicit `--selection` commands.

Default promotion is blocked by reproducible local-fold regressions of roughly
10–19%, associated with newly forced inline hints. The 44-point runtime aggregate
improves on Phase98, but does not erase those losses. No candidate03 gate
completion authorizes replacing the default pointer. Its SHA256 remains
`0ec0287c1c5e0b877b16a10e451bce4eb1fffa7b3795fcf634d742ea50772fdf`.

## Exact qualified product

| Artifact | Completed evidence |
|---|---|
| Final source and reversible Phase98 recipe | `phase102/projection-cold-source01/` |
| Genuine upstream-built B1 | `phase102/native-b1-03/b1.json` |
| Genuine B1-built B2 and exact self-C fixed point | `phase102/native-chain03/b2.json`, `b2-self/report.json` |
| Live/cache/refusal, broad45 and native69 per stage | `phase102/native-chain03/controls`, `broad45`, `conformance` |
| Backend bridge and original five final controls | `phase102/backend-specific03/report.json`, `native-chain03/final-controls/report.json` |
| Final admission | `phase102/native-chain03/admission.json`, SHA256 `58510308…ab6188` |
| Explicit staged pointer | `phase99/phase102-release03/selection.json`, SHA256 `211999d9…561f26` |
| Actual public CLI | `phase99/phase102-release03/public-cli/report.json`: 9/9 pass |

The table's paths are relative to `selfhost/build/`. Qualification binds this
exact source and both actual images; the self fixed point is not a universal
compiler-correctness proof. The independently expected application suite passes
50 inputs and 165 complete observations. The [campaign report](README.md) keeps
complete-process applications, warmed program runtime and compiler work separate.

The earlier candidate02 (`535c1f8f…`) remains a qualified checkpoint. Its cold-list
regression was diagnosed and repaired by candidate03. Its original receipts,
source and lowering02 profile remain unchanged; none was relabelled as a fresh
candidate03 execution.

## Immutable source transport

The [lowering03 profile](../../selfhost/tools/native/profiles/phase102-lowering03/profile.json)
replays candidate03 exactly. Profile SHA256 is `c8310996…fc95d4`; its compressed
delta is 26,753 bytes. `selfhost/build/phase102/profile-replay03/packaging.json`
records forward equality and inverse recovery of the committed D04 source.
This source-only package retains its experimental/qualification-free metadata;
the separate native admission supplies the image qualification.

Keep `profile.py` unchanged: earlier profiles pin it, and its historical default
still names Phase98. Documentation passes lowering03 explicitly. Admission uses
the exact Phase98-to-candidate03 recipe, not the compact D04 transport profile.
The recorded package command was:

```sh
python3 -B selfhost/tools/performance/phase102/package-source-profile.py \
  --recipe selfhost/build/phase102/projection-cold-source01/changes.json --name phase102-lowering03 \
  --out selfhost/tools/native/profiles/phase102-lowering03 \
  --verification-out selfhost/build/phase102/profile-replay03
```

Those paths exist and must not be reused. Replay to a fresh user output remains
available through the guide; it launches no compiler and changes no selection.

## Runtime evidence and product reuse

Candidate03's fresh 44-positive-point runtime comparison is 0.9553× Phase98
and 1.0628× upstream with equal catalog-point weighting; equal original-source
weighting gives 0.9608× and 1.0822×. The zero-work control has no ratio. The
[runtime review](runtime-regression-review.md) records individual regressions
and the balanced hint diagnosis. Semantic admission does not decide performance
acceptance, and these results do not authorize default promotion.

The reviewed `runtime-reuse.py` requires fresh final B1/B2 whole-C equality before
reusing any exact historical binary. It preserves old ELF/build provenance and
uses the unchanged timing function. Candidate03 changed all 45 products, so its
actual acquisition rebuilt all 45, reused zero and recorded 106.821 seconds of
Clang work. No build saving is claimed. The adapter authenticates the recorded
compiler executable and argv, without claiming a hermetic transitive-header or
library rebuild. Explicit new calibration contexts must bind the new source,
product manifest and adapter; candidate02 contexts cannot substitute.

## Completed staged release; no default replacement

The exact release commands used these candidate03 paths:

```sh
python3 -B selfhost/tools/performance/phase99/release/prepare.py selection --admission selfhost/build/phase102/native-chain03/admission.json --out selfhost/build/phase99/phase102-release03/selection.json
python3 -B selfhost/tools/performance/phase99/release/cli-controls.py selfhost/build/phase99/phase102-release03/selection.json selfhost/build/phase102/native-chain03/controls/report.json selfhost/build/phase99/phase102-release03/public-cli
python3 -B selfhost/tools/native/assets.py seal selfhost/build/phase99/phase102-release03/selection.json selfhost/tools/native/releases/phase102-staged03
python3 -B selfhost/tools/native/assets.py restore selfhost/tools/native/releases/phase102-staged03/receipt.json --verify-only
```

Creation outputs now exist. The capsule receipt is SHA256
`0a5280e88ff057eb4d69878f57380761ec925bcdee9bdae88314d83a71d5bc95`;
verification reports 36 files and zero missing. No actual missing-file restore
was exercised. The capsule preserves the staged pointer, source/images and
request assets at the recorded checkout location. It does not replace
`selfhost/tools/native/selection.json`. Old guides, capsules and profiles remain
immutable. No Phase102 stable-default capsule or default promotion is claimed.

## Experimental candidate04

`projection-cost-source01/compiler.bend`, SHA256
`63ef222c4c6de73bb54c8e51d3b0a0552979b5791ea98e64d1098051a9cda237`,
is a separate projected-cost policy experiment intended to address the hint
regression. Its checked API now passes; application/fold/ray emissions are being
evaluated. It has no inherited candidate03 native admission, public selection,
release capsule or lowering03 identity. Any later release needs its own exact
source evidence and completed applicable gates. Candidate03 remains frozen.

## Freeze and archive

After all target and metadata writers stop, `archive-v2.py` includes only native
request directories named by explicit complete CLI reports. It verifies receipt
pins and process captures, recursively preserves the actual raw files at their
original paths, and reads back every tar member against its hash and mode. Seven
synthetic helper controls pass in `archive-v2-method01/report.json`. The older
archive method omitted these public request directories and remains preserved.

```sh
python3 -B selfhost/tools/performance/phase102/archive-v2.py --frozen \
  --cli-report selfhost/build/phase99/phase102-release03/public-cli/report.json \
  --out implementation/phase102/evidence
```

This archives no unrelated native request history. Additional explicit request
receipts can use `--request-report`; no post-promotion default smoke is needed
because Phase98 remains selected. No archive is created by this document update.
Keep prior phase/toolchain capsules as dependencies, and report archive readback,
missing-file restoration, source replay, qualification and runtime acceptance
as separate observations.
