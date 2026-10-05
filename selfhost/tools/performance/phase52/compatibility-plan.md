# Phase52 legacy compatibility qualification plan

Prepared only; no targets executed by this author. Root schedules each command
serially after direct semantic jobs complete. Use fresh Phase52 outputs and the
actual final checked attempt. This tests default/legacy JavaScript separately
from the explicit direct ABI. No new harness is needed.

Run from the repository root. Set these task variables before executing:

```sh
P52_NODE=/home/ai/.nvm/versions/node/v24.18.0/bin/node
P52_ATTEMPT=/absolute/path/to/final-checked-attempt
P52_Q=/home/ai/bend2/build/publish/bend/selfhost/build/phase52/compatibility-NEW
```

## First: eight maintained suites

```sh
python3 selfhost/tools/performance/phase47/qualify.py \
  "$P52_ATTEMPT" "$P52_Q/maintained8"
```

This existing runner owns its ExecutionGuard; do not wrap it in another guard.
The parent must retain CPU3 in its allowed affinity. It selects the attempt's
API, frozen runtime, Base and upstream through `BEND_TYPED_API`,
`BEND_TYPED_RUNTIME`, `BEND_JS_RUNTIME`, `BEND_BASE` and `BEND_UPSTREAM`.
It requires live named host tools/compiler manifest to equal the selected frozen
snapshot. Reconcile the selected source before running; do not suppress this
identity check to accommodate an unselected draft.

Expected: complete passing report with eight tests: IR, backend, global
initializers, choice, arms, primitive guards, provenance and foreign. The runner
requires 37 IR checks, 1,129 primitive guards/25 observations and ten provenance
constructors. Each suite has a 120-second ceiling, CPU3, 1GiB heap, 2GiB tree RSS
and 4GiB available-memory floor. Historical maintained8 took about10s; this is a
planning estimate, not a candidate result.

## Second: legacy core8 rejection screen

Acquire default-JS output using the unchanged maintained producer, not Phase52's
direct producer. No `--backend direct` or `--direct-js` belongs in these commands.

```sh
python3 selfhost/tools/performance/programs/prepare.py \
  --catalog selfhost/tools/performance/phase37/catalog.json --set core \
  --role candidate --attempt "$P52_ATTEMPT" --node "$P52_NODE" --cpu 3 \
  --heap-mib 1024 --rss-mib 2048 --available-mib 4096 --timeout 180 \
  --out "$P52_Q/core8-emission"
python3 selfhost/tools/performance/programs/run.py \
  --catalog selfhost/tools/performance/phase37/catalog.json --set core \
  --baseline selfhost/tools/performance/phase51/bundles/baseline/manifest.json \
  --candidate "$P52_Q/core8-emission/manifest.json" --node "$P52_NODE" \
  --cpu 3 --rss-mib 2048 --available-mib 4096 --budget 20 \
  --out "$P52_Q/core8"
```

Both tools own their guards. Reuse a complete exact final-attempt legacy
acquisition instead when its source/catalog/API/runtime receipts match. Direct
output cannot substitute for legacy modules. The baseline bundle contains the
pinned TS role required by the unchanged runner; it is the preserved RNFA04
comparison baseline, not a fresh Phase51 emission. Require all eight complete
result oracles and no process/refusal errors. Treat short timing as a rejection
screen, not a new full-corpus performance claim. An input-only `--plan` invocation
may precede execution. Acquisition has a per-emission ceiling, not an assumed
20-second compilation budget.

## Third: installed and relocated 42 CLI checks

Only after root installs and verifies the selected release, set `P52_API_SHA` to
the actual final attempt API SHA256. The frozen Phase43 launcher is the exact
CPU3/1GiB successor reused in Phase51; do not substitute the original Phase23
CPU1/4GiB launcher.

```sh
python3 selfhost/tools/performance/phase46/job.py \
  --out "$P52_Q/job-release-verify" --seconds 120 -- \
  "$P52_NODE" --stack-size=4096 --max-old-space-size=1024 \
  selfhost/tools/development/release.mjs --verify
python3 selfhost/tools/performance/phase46/job.py \
  --out "$P52_Q/job-release-smoke" --seconds 1200 -- \
  "$P52_NODE" --stack-size=4096 --max-old-space-size=1024 \
  selfhost/build/phase43/integration01/final-plan/tools/release-smoke-launch.mjs \
  selfhost "$P52_Q/release-smoke" "$P52_API_SHA"
```

The launcher clears BEND_* overrides, NODE_OPTIONS and NODE_PATH for its children;
this proves the installed/relocated interface, not an environment-selected API.
It copies only the release file inventory and verification inputs into a new
relocated directory, without supplying an upstream checkout. Require launcher
complete/pass, exactly42 successful steps and the selected API hash. Steps cover
ordinary and relocated CLI behavior including interpretation, default JavaScript
output, native CPU compilation/execution and refusal paths. Native compilation
requires the available supported Clang; environment refusals remain failures
until explicitly resolved in a separate fresh receipt. Do not call matching
native failures successful conformance.

The 1200-second ceiling is inherited, not an expected runtime. This is a release
smoke gate, not full frontend inventory, direct IO qualification or fixed-point
proof. Direct option/help/ESM runtime inclusion needs its own Phase52 semantic
and release-integrity checks; the old42 do not acquire that new coverage merely
because the driver now accepts another flag.

## Scope and optional expansion

Do not run the whole `phase51/qualify-selected.py` queue: it confines output to
closed Phase51 raw and includes older focused acquisitions plus backend81.
Reuse the narrow existing tools above with Phase52 destinations. No closed raw
files or consumed scripts are modified.

If default emitter/runtime bytes changed beyond the additive direct interface,
root should also reuse the four focused exact-entry/nullary/array-view/array-tree
controls from the Phase51 qualification plan on fresh legacy emissions. Their
historical ordinary baselines and source/counter assertions remain mandatory;
do not replace them with direct ABI tests. Backend81 is a broader optional gate
when shared native/backend logic changed, not a prerequisite for an additive
JavaScript mode alone. Existing strict checked frontend witnesses remain
separate from these runtime observations.

The old installed-release receipt joiner can attest legacy API/runtime identity,
maintained8 and42CLI, but it does not specially attest the new direct runtime.
Root's Phase52 release inventory must include `src/runtime/js/direct.mjs` and all
direct compiler modules/host inputs, then verify their hashes after relocation.
Preserve unsuccessful receipts and report compatibility, direct qualification,
performance selection and installation as separate decisions.
