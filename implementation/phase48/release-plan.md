# Phase48 candidate04 release recipe

Date: 2026-10-05. **Plan only; no installation or final release claim.** Root owns
all mutations and serial target jobs. The selected candidate is
`checked-combined-rnfa04`; Phase47 array06 remains installed until the barriers
below pass. This is a checked B1 derivative, not a new self-hosted fixed point.

## Exact selected identities

| Input | SHA-256 |
|---|---|
| `checked-combined-rnfa04/attempt.json` | `59dd57e733b27de66db5ef85181c1303ade7cbf6cb9f7430d49e283d00853764` |
| Selected equality API | `6f9d111aa68c19f3ce45b80785621d57c4d10efb12d50164f5cb0597bc952100` |
| Checked parent API | `479d31641b4304b9525da369a2c68992ac52f7f9b04eb5f961b9ce6a77b224c0` |
| Runtime | `880bce50e3194b9ee9d99bd57c18ef88bcb8925d9d1668dec6765040a4d3219b` |
| Assembled compiler source | `bb98f20f281b1a0cfa7171afd3e2f8d5977f0391a3edcc222add3d9d1c574283` |
| `snapshot/src/compiler.json` | `598d2563fecc08f64d7081501478c35dce20998b0e46f67e68b3290847779704` |
| Base | `c742fae9c49b14f0cc9128429a2c6109364c8a933a142f2c90b9f2e5fd976661` |
| Node v24.18.0 | `41a74efb34cbde5c7632cdac0cf8bd1a14d0b8d73dc1e82755014d9a9ce70f5c` |

All paths below are relative to `/home/ai/bend2/build/publish/bend`, unless an
absolute path is shown. `--attempt` and `--install-attempt` take the attempt
**directory**, not its JSON file. Output directories must be fresh; preserve
failed or interrupted jobs and use a new name for retries.

## Three integration barriers

1. **Focused semantic qualification.** Finish jobs 0–24 in
   `selfhost/build/phase48/final-qualification04/plan.json`, with every report
   bound to the exact selected attempt/API/runtime. Include the successor
   literal-count controls, independent count mapping, composite/F32 composition,
   prior view/tree contracts and native-rejection checks. Do not infer readiness
   merely from the plan's `complete` field: that describes a complete plan, not
   executed results. Preserve failed predecessors; the qualification receipt
   must join actual executions and identities.
2. **Reconcile maintained source to the frozen selected snapshot.** Stop before
   job 25. The current checkout is an experimental work area, not the release
   input. Inventory it, preserve deferred work, and make selected source/module
   membership exact as described below. Recheck the 103 protected files and index.
3. **Maintained semantic and backend qualification.** Only after source
   reconciliation, execute unchanged maintained8 and backend81 jobs 25–27.
   Maintain the source-manifest and host-tool equality checks in `qualify.py`.
   The backend inventory expects the historical classification **69 pass /
   eight not-applicable / four fail**, not 81 newly passing tests. Preserve and
   compare individual outcomes; do not relabel shared failures as conformance.

The unchanged full45 runtime comparison and selected compiler-cost evaluation
are subsequent selection gates. Their receipts must use this same API/runtime,
complete exact output checks and unchanged catalog weights. Review regressions,
drift and complexity explicitly. Focused semantic success alone does not
justify installation. Full frontend, GPU/native coverage and fixed-point
self-reproduction remain separate evidence.

## Source reconciliation, before maintained8

The [explicit source reconciliation recipe](source-reconciliation.md) is the
authoritative list of **13 selected-file copies and three archived removals**,
including the durable preimages of all 16 live versions. Root has completed
that reconciliation in `selfhost/build/phase48/source-reconciliation04.json`;
the semantic receipt checks all 188 live/frozen source files against it. The
inventory below records the earlier checkpoint, rather than instructions to
repeat completed work.

The authoritative tree is
`selfhost/build/phase48/checked-combined-rnfa04/snapshot/src`, whose manifest lists
**92 modules**. At this recipe's read-only checkpoint, the live manifest lists
86. Selected additions are `array-effects.bend`, `array-result.bend`,
`array-literals.bend`, `array-effect-guards.bend`, `ir/native-values.bend` and
`private-float.bend` under `src/back/js/`.

The following selected files differed from live bytes at that checkpoint:

```text
src/back/js/array-effects.bend
src/back/js/local.bend
src/back/js/region.bend
src/back/js/array-view.bend
src/back/js/array-literals.bend
src/back/js/fold.bend
src/back/js/tree.bend
src/back/js/ir/worker-model.bend
src/back/js/ir/worker-graph.bend
src/back/js/ir/worker-nat.bend
src/back/js/ir/worker-emit.bend
src/back/js/emit.bend
src/compiler.json
```

Three live-only files were absent from the selected snapshot:
`src/back/js/ir/function-flow.bend`, `function-flow-root.bend` and
`worker-values.bend`. These are deferred H/V work. Their absence from a manifest
alone is insufficient cleanup: do not leave them in the maintained compiler
source directory and silently suggest they are selected.

Before any overwrite/removal, root must retain an exact hash inventory of all
live/snapshot differences and unlisted files. Verify durable proposal copies of
all deferred bytes, including the existing worker-model/graph/nat/emitter edits,
not only the new files. Aggregate scalar/vector payloads are preserved in
[selfhost/tools/performance/phase48/proposals/aggregate-transport](../../selfhost/tools/performance/phase48/proposals/aggregate-transport/README.md);
H has separate function-flow integration artifacts. Check their bytes against
the live versions; names alone do not establish preservation. Preserve any
unmatched version as an explicit new proposal before removing it from live
`src`. Do not use an unreviewed recursive deletion or overwrite protected files.

Then reconcile the **entire selected `src` tree**, including exact compiler
manifest order, all 92 selected modules, assembled runtime and its JS/native
fragments, to the frozen snapshot. Use reviewed ordinary file copies, not a new
copy tool. Copying selected files alone does not remove live-only deferred
files: account for those explicitly after preservation. Re-inventory after
copying and require no unexplained difference or extra file in compiler `src`.
Do not copy the concurrent live worktree into the frozen attempt, and do not
change a checked snapshot to make it match the checkout.

Also compare the selected snapshot's host files
`typed-driver.mjs`, `compiler-abi.mjs`, `native-build.mjs`,
`node-resource-args.mjs`, `assemble.mjs`, `stage0-library.mjs` under `tools`.
Keep their exact selected versions; the maintained runner/installer check them.
The release installer separately records `cli.mjs`. Retain its intended bytes
and qualify them with the ordinary and relocated CLI checks; do not replace it
from a nonexistent snapshot path. Leave unrelated tests, tools, docs, raw
receipts and the protected 103 outside this source reconciliation.

Root should retain the before/after inventory, reviewed preservation paths and
hash equality as a release input. No source-copy commands have been executed by
the recipe author, and the list above must be refreshed if root has since
reconciled any file.

## Maintained8 and backend81 commands

Use the already bound plan jobs; these are their exact command interfaces.
`qualify.py` owns its resource guard. Do not add another outer wrapper around it.
The backend planner is data-only; its runner uses the established job wrapper.

```bash
P48_ATTEMPT=/home/ai/bend2/build/publish/bend/selfhost/build/phase48/checked-combined-rnfa04
python3 selfhost/tools/performance/phase47/qualify.py "$P48_ATTEMPT" selfhost/build/phase48/final-qualification04/maintained8
python3 selfhost/tools/performance/phase48/backend-plan.py "$P48_ATTEMPT" selfhost/build/phase48/final-qualification04/backend
python3 selfhost/tools/performance/phase46/job.py --out selfhost/build/phase48/final-qualification04/job-backend81 --seconds 930 -- python3 selfhost/build/phase43/integration01/final-plan/tools/backend-run.py selfhost/build/phase48/final-qualification04/backend/pilot.json
```

Do not repeat completed jobs or overwrite their directories. After these gates,
complete runtime/cost review and the root's selection decision before proceeding.

## Install, verify and 42 CLI checks

These commands reuse the unchanged release installer and the exact launcher
used successfully by Phase47 release06. Run serially, with no other target job.
The existing Phase46 job wrapper enforces CPU 3, 2GiB process-tree RSS and a 4GiB
available-memory floor, and removes inherited compiler/Node overrides. Node
explicitly receives a 1GiB heap and 4096KiB stack.

```bash
P48_NODE=/home/ai/.nvm/versions/node/v24.18.0/bin/node
P48_ATTEMPT=/home/ai/bend2/build/publish/bend/selfhost/build/phase48/checked-combined-rnfa04
P48_API=6f9d111aa68c19f3ce45b80785621d57c4d10efb12d50164f5cb0597bc952100
P48_RUNTIME=880bce50e3194b9ee9d99bd57c18ef88bcb8925d9d1668dec6765040a4d3219b
python3 selfhost/tools/performance/phase46/job.py --out selfhost/build/phase48/release04/run-install --seconds 180 -- "$P48_NODE" --stack-size=4096 --max-old-space-size=1024 selfhost/tools/development/release.mjs --install-attempt "$P48_ATTEMPT"
python3 selfhost/tools/performance/phase46/job.py --out selfhost/build/phase48/release04/run-verify --seconds 120 -- "$P48_NODE" --stack-size=4096 --max-old-space-size=1024 selfhost/tools/development/release.mjs --verify
python3 selfhost/tools/performance/phase46/job.py --out selfhost/build/phase48/release04/run-smoke --seconds 900 -- "$P48_NODE" --stack-size=4096 --max-old-space-size=1024 selfhost/build/phase43/integration01/final-plan/tools/release-smoke-launch.mjs /home/ai/bend2/build/publish/bend/selfhost selfhost/build/phase48/release04/release-smoke "$P48_API"
python3 selfhost/tools/performance/phase42/validation/check-protected-v1.py selfhost/build/phase45/protected-start.json selfhost/build/phase48/release04/protected.json
```

Stop after any failed process or mismatched identity. The launcher must report
all 42 ordinary/relocated checks passing, with the expected API, unchanged inputs
and no upstream checkout created during relocation. A release verifier alone
is not this CLI smoke gate. Installation preserves prior release artifacts and
checked/equality lineage; it does not perform a bootstrap.

The protected audit must report exactly 103 unchanged files, no protected staged
path and original start-manifest SHA-256
`c5e803405d3c8267bd2f3741a638c77b4ce58c561cc5c829d0abac2ac8d67288`.
Use the same audit before source reconciliation as well, with a distinct fresh
output path; the command above is the final audit for this receipt.

## Data-only installed receipt

The existing Phase47 receipt tool is compatible with this attempt and unchanged
maintained8 report schema. Its historical `phase47-installed-release-receipt`
kind is intentional; do not relabel it or modify the tool. It independently
joins selected lineage, installed images, maintained8, install/verify logs,
42 checks and protected 103. It does not attest runtime performance or backend81;
retain those receipts separately.

```bash
python3 selfhost/tools/performance/phase47/installed-release-receipt-v2.py --attempt "$P48_ATTEMPT" --maintained selfhost/build/phase48/final-qualification04/maintained8/report.json --install-run selfhost/build/phase48/release04/run-install/process.json --verify-run selfhost/build/phase48/release04/run-verify/process.json --smoke-run selfhost/build/phase48/release04/run-smoke/process.json --smoke-launcher selfhost/build/phase48/release04/release-smoke/launcher.json --protected selfhost/build/phase48/release04/protected.json --expected-api "$P48_API" --expected-runtime "$P48_RUNTIME" --out selfhost/build/phase48/release04/installed-release.json
```

Omit `--publication`: the unchanged tool accepts only the Phase47 portable
publication schema. A later Phase48 publication needs its own compatible
identity join; do not weaken the existing schema check. Claims about a usable
installed version begin only after these receipts actually pass.
