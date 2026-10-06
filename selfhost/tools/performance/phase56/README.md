# Phase56 compiler-image qualification and preservation

The installed checked B1 is `checked-string01`: API `12861977…`, source
`5356ec99…`, and self-emitted B2 `3f652f7d…`. The direct runtime remains
`c328b773…`. The [main report](../../../../implementation/phase56/README.md)
records qualification and installation status. All five release steps passed,
including 42 legacy and 24 default CLI observations. B2 is separately qualified;
the installed API remains B1. An existing plan alone is not a successful run.
This directory contains methods, not a replacement compiler ABI.

| Tool | Purpose and input contract |
| --- | --- |
| `string-equality/candidate.patch`, `source.json` | Recorded native `String.eq` source change and its exact source identities. |
| `qualification/string-controls-v2.mjs BASELINE_ATTEMPT CANDIDATE_ATTEMPT NEW_OUT` | Primitive UTF-16 String values, evaluation order, canonical ownership and user-name/duplicate refusals. V1's failed harness remains preserved. |
| `bootstrap/prepare-candidate.py plan ATTEMPT NEW_OUT` | Data-only derivation of tiny/full 77-root emission and eight ordinary-driver checks, using the frozen Phase55 methods. Writes a serial, individually guarded `run.sh`. |
| `bootstrap/setup-v2.mjs` | Validates `image-pins.json`; stages the genuine B1 or B2 with private unchanged driver/runtime and an empty Base cache. Never fabricates a checked B2 attempt. |
| `qualification/self-check-v2.mjs IMAGE_PINS NEW_OUT` | B2 freshly checks its complete source. Type acceptance and expected `@unsafe` proof-trust failure are separate observations. |
| `bootstrap/reproduce-v2.mjs IMAGE_PINS NEW_OUT` | Unsplit B2→B3 emission and complete byte equality on the exact source/77-root closure. Its inherited checking lane is separate from the fresh self-check. |
| `qualification/plan-v2.py`, `acquire-v2.mjs`, `*-controls-v2.mjs` | Fresh B2 source/numeric/composition/overapplication acquisitions and independent oracles. |
| `qualification/benchmark-equality.mjs IMAGE_PINS B1_MANIFEST NEW_OUT` | B2 checks/emits 23 sources; all 45 raw/observer point modules must equal selected B1. It executes no benchmark programs. |
| `performance/compare.py` | Exact host02/candidate raw and observer comparison, dated Phase53 byte join, and changed-point timing plan. |
| `latency/run.py`, `worker.mjs` | Evening/lexer × B1/B2/TypeScript × three fresh rotated rounds; private Base priming and output oracles outside the timed requests. |

Use Node **24.18.0**, CPU3, a 1,024 MiB heap, 2,048 MiB tree-RSS bound and
4,096 MiB free-memory floor as recorded. Run targets serially. A command that
already owns `ExecutionGuard` or the bounded supervisor must not be nested under
another owner of that lock. Existing acquisition/timing parsers require CPU3 to
remain in their controller's allowed affinity; use CPU0 only for data-only tools.
Every replay needs fresh output names. After publication, use a separate replay
workspace: these names must not append work to the original closed campaign.
Commands below assume that workspace's repository root.

The original candidate plan and binding are in raw
`bootstrap-string01-plan/{plan.json,image-pins.json}`. To regenerate the same
method with fresh output paths, first write a new plan, then inspect/run its script:

```sh
PYTHONDONTWRITEBYTECODE=1 taskset -c 0 python3 selfhost/tools/performance/phase56/bootstrap/prepare-candidate.py plan selfhost/build/phase56/checked-string01 selfhost/build/phase56/bootstrap-replay01
bash selfhost/build/phase56/bootstrap-replay01/run.sh
```

For a separate bounded self-check or fixed-point replay, use the original image
binding and fresh output/supervisor directories. These are target jobs:

```sh
python3 -B selfhost/tools/performance/phase32/bounded-run.py --seconds 300 --rss-mib 2048 --available-mib 4096 selfhost/build/phase56/self-check-replay01-supervisor -- taskset -c 3 /home/ai/.nvm/versions/node/v24.18.0/bin/node --max-old-space-size=1024 --stack-size=4096 selfhost/tools/performance/phase56/qualification/self-check-v2.mjs selfhost/build/phase56/bootstrap-string01-plan/image-pins.json selfhost/build/phase56/self-check-replay01
python3 -B selfhost/tools/performance/phase32/bounded-run.py --seconds 300 --rss-mib 2048 --available-mib 4096 selfhost/build/phase56/reproduce-replay01-supervisor -- taskset -c 3 /home/ai/.nvm/versions/node/v24.18.0/bin/node --max-old-space-size=1024 --stack-size=4096 selfhost/tools/performance/phase56/bootstrap/reproduce-v2.mjs selfhost/build/phase56/bootstrap-string01-plan/image-pins.json selfhost/build/phase56/reproduce-replay01
```

The completed originals are `self-check-string01/` and `reproduce-string01/`.
Fresh type acceptance does not turn the explicitly unsafe compiler source into
a mathematical proof. Exact B2/B3 bytes do not independently prove correctness.

To reproduce B2 semantic gates, generate a fresh bounded plan:

```sh
python3 -B selfhost/tools/performance/phase56/qualification/plan-v2.py --image-pins selfhost/build/phase56/bootstrap-string01-plan/image-pins.json --out-base selfhost/build/phase56/semantic-replay01 --plan-file selfhost/build/phase56/semantic-replay01-plan.json
python3 -B selfhost/tools/performance/phase55/run-retention-plan.py selfhost/build/phase56/semantic-replay01-plan.json selfhost/build/phase56/semantic-replay01-execution
```

The generated plan uses the unchanged serial scheduler; each command carries
its own bounds. For B2 benchmark-byte replay, supervise
`qualification/benchmark-equality.mjs` with the same Node/CPU/memory options and
arguments `bootstrap-string01-plan/image-pins.json`, `string01-full/manifest.json`
and a fresh Phase56 output path. Those first two paths are under
`selfhost/build/phase56/`. This transfers only evidence applicable to exact B1
output; it is not another runtime measurement.

[Generated-program replay instructions](performance/README.md) give the existing
`phase53/acquire.py --set full` command, exact comparison, and changed-only
`programs/run.py` timing. The selected acquisition changed only Map/Set; the other
44 point modules retain dated evidence. Do not pool historical and fresh samples
into a claimed new corpus aggregate. The [performance report](../../../../implementation/phase56/performance.md)
records the fresh 15-sample comparison.

The small compiler-latency screen is independently replayable:

```sh
PYTHONDONTWRITEBYTECODE=1 taskset -c 0 python3 selfhost/tools/performance/phase56/latency/run.py selfhost/build/phase56/latency-replay01 --image-pins selfhost/build/phase56/bootstrap-string01-plan/image-pins.json
```

It owns its guard. Its [report](../../../../implementation/phase56/latency.md)
separates import + request, request-only, process wall, preparation and RSS;
generated-program speed is a different metric.

Eight maintained legacy suites use the existing runner:
`python3 -B selfhost/tools/performance/phase47/qualify.py selfhost/build/phase56/checked-string01 selfhost/build/phase56/maintained-replay01`.
Release qualification uses the five steps recorded in raw
`release-plan-string01.json` / `release-execution-plan-string01.json`: install,
verify-before, 42 legacy CLI observations, 24 default observations, verify-after.
For a new run, generate a fresh plan with
`phase53/release-qualification-plan-v1.py ATTEMPT NEW_OUTPUT --plan NEW_PLAN` and
follow its guard policy. Installation is a distinct action, not implicit in
running a semantic or performance screen.

After publication, the publication index names the raw archive and its
`archive.json` inventory, normally under `artifacts/raw/`. Verify the archive
SHA-256 before restoring. Members are relative to the raw root: restore them
into an **empty** `selfhost/build/phase56/`, preserving every member name. Do not
extract them at repository root or overwrite a live campaign. Validate member
hashes against the inventory. Earlier phases, including Phase53–55, are separate
read-only dependencies; restore their own archives to their original raw roots
if needed.

Receipts contain absolute paths from `/home/ai/bend2/build/publish/bend`. Use that
layout for exact historical verification, or derive a reviewed new plan that
explicitly rebinds inputs; never rewrite consumed receipts to make them pass.
Retain frozen consumed tools, command arrays, failures, deadlines and successor
derivations. Original `setup.mjs` / `reproduce.mjs` describe the earlier host02
image; `reproduce-clean.mjs` and the clean release plan are unexecuted alternatives,
not evidence for selected string01. Likewise, the latency draft's old binding
was never executed. Only matching completed receipts establish which producer
and image were actually consumed. Closed Phase54/55 raw trees remain unwritten.
