# Reproduce Phase168

Run from the repository root. The maintained Phase152 source and explicit assets
must match the pinned extraction/checked API receipts. The final API source
reproduces byte-for-byte; see [reproduction.json](reproduction.json). All compiler
semantics are implemented in Bend. Host scripts assemble source, transport
requests, invoke existing tools, measure and compare independently fixed outputs.

Use fresh paths and one CPU3 execution lane. Every compiler/program execution
uses the maintained resource guard, with its default 5GiB reserve. Disk is nearly
full on the original host: make room by reviewing and applying only verified
retention plans before replay; never lower the reserve. Do not nest guards.

## Extract source

```sh
python3 -B experiments/phase168/tools/prepare-imports.py \
  --out selfhost/build/phase168/repro-source
python3 -B experiments/phase163/tools/prepare.py \
  --module selfhost/tests/phase167/verifier-workload.bend \
  --export main --export p167w_check \
  --out selfhost/build/phase168/repro-fixture
```

The compiler source must hash to `836b64c1d88e18502dbff738e7837056f7d73059ba2ee4f16f82dca2d06bbce3`.
The verifier fixture must hash to `ff6b4083aa2f3e034f3b4f8e43dfb25d93a4f524685934e0ee13845278033ef3`.
The manifests report zero production replacements and two experimental ones:
`p168_closed` and `p168v_prepare`. `--allow-overrides` is restricted by the source
extractor's parent checks; it does not authorize editing the maintained compiler.

## Acquire and check the experimental API

```sh
python3 -B selfhost/tools/build-retention/guard.py \
  --out selfhost/build/phase168/repro-api-guard \
  --run-root selfhost/build/phase168/repro-api \
  --seconds 100 --disk-mib 32 --rss-mib 3072 --available-mib 16384 -- \
  selfhost/.assets/bin/bun selfhost/tools/build/hosted.mjs acquire \
  --source selfhost/build/phase168/repro-source/compiler.bend \
  --exports selfhost/build/phase168/repro-source/exports.json \
  --upstream selfhost/.bootstrap/upstream-phase66 \
  --engine selfhost/.assets/bin/bun --out selfhost/build/phase168/repro-api
```

Under a separate fresh 60s/4MiB/2GiB guard, run
`bun experiments/phase168/tools/controls-v2.mjs API/report.json OUT` using the
pinned Bun path. Require all 68 controls. See the original `controls03` guard
command and [receipt](evidence/controls03/report.json) for exact invocation.

## Complete build and execution pairs

For each role `baseline` and `imports`, use fresh paths:

```sh
python3 -B selfhost/tools/build-retention/guard.py \
  --out selfhost/build/phase168/repro-baseline-guard \
  --run-root selfhost/build/phase168/repro-baseline \
  --seconds 90 --disk-mib 16 --rss-mib 3072 --available-mib 16384 -- \
  python3 -B experiments/phase168/tools/one-build-v4.py \
  --receipt selfhost/build/phase168/repro-api/report.json \
  --source selfhost/build/phase168/repro-fixture/compiler.bend \
  --role baseline --preparation cache \
  --out selfhost/build/phase168/repro-baseline
```

Change all `repro-baseline` paths and role to `imports` for the candidate. The
`imports-stock` role is the matched callable-view control with the old registry.
Both import roles use the same public-copy verification and arrays-off policy;
only early registry imports differ. All initial actual-program gates still run.

`--preparation cache` authenticates the shared standard-Base carrier in both
routes. It does not cache the input source frontend or candidate backend. For
an all-live-Base experiment use `live` on **both** roles and label it separately.
Compare complete build time and combined backend/render time. The baseline
cursor and candidate materialization place rendering in different subintervals.

Under a fresh 60s/4MiB/2GiB guard:

```sh
python3 -B experiments/phase167/tools/runtime.py \
  --build selfhost/build/phase168/repro-baseline/report.json \
  --build selfhost/build/phase168/repro-imports/report.json \
  --expected 768 --rounds 4 --out selfhost/build/phase168/repro-runtime
```

For the transfer pair, use the frozen Phase166 lookup fixture
`selfhost/build/phase166/lookup-source02/compiler.bend`, SHA256
`4627d3b8c7b8291277574a1fc68bdf6afc972be1e32f8d1d8620c62eb4bdf181`, and independent
expected output `3279346725`. Its extraction and literal complete-record oracles
are documented in [Phase166](../phase166/README.md). Do not tune the fixture or
replace complete output comparison with exit-code agreement.

Sharing/non-tail recursion uses `selfhost/tests/phase167/closures-workload.bend`,
expected `20040`. Map/IO uses the native45 catalog's
`coverage-map-churn-128.bend` fixture and the maintained Phase167 `map-oracle.py`
adapter; its frozen point expects `3714872484` plus iteration/time fields. Use
the committed `closures01`, `runtime-closures01`, `map01` and `map-oracle01` guard
receipts to recover exact arguments. They are semantic gates, not speed scores.

## Evidence and retention

Final source/API identities, stage intervals, toolchain pins, every guarded
command, failed API03 stderr and complete runtime samples are retained in
[evidence](evidence). Native products remain under `selfhost/build/phase168`;
archives are under `selfhost/build-retention/phase168-*-close`.
Baseline01's SSA/assembly/object were individually pruned after archive-member
verification; restore its archive before replaying the historical offline census.
Baseline02/03 and final/transfer products remain available.

`collect.py` reconstructs [metrics.json](metrics.json) from the original named
runs and copies their receipts. `view-census.py` and `imports-census.py` perform
offline QBE inspection; neither launches a target. Earlier harness versions are
frozen provenance, not the final entry point.

Close every new guard through `selfhost/tools/build-retention/close.py`, using
fresh retention paths and the actual completed/failed classification. No pilot
result here qualifies a native compiler or changes the installed selection.
