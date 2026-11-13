# Phase191: typed x86 selection and measured optimization experiments

Compiler algorithms live in Bend under `selfhost/src/back/x86/`. These scripts
transport checked outputs, run independent observers, authenticate immutable
artifacts, and calculate statistics. They do not implement compiler passes.

Use one guarded CPU3 execution lane through `job.py`. Freeze source, export
roots, Base binding **and the bootstrap manifest** before acquiring an API:

```sh
# Run from repository root; use fresh destinations for every experiment.
cp selfhost/src/compiler.json selfhost/build/phase191/replay-toolchain.json
python3 -B selfhost/tests/phase190/prepare-api.py \
  --parent-source SNAPSHOT/compiler.bend \
  --assets selfhost/build/phase191/assets.json \
  --set x191_address_enabled=true \
  --out selfhost/build/phase191/replay-source
python3 -B selfhost/tests/phase191/job.py --rss-mib 3072 replay-api 180 96 \
  selfhost/.assets/bin/bun selfhost/tools/build/hosted.mjs acquire \
  --manifest selfhost/build/phase191/replay-toolchain.json \
  --source selfhost/build/phase191/replay-source/compiler.bend \
  --exports selfhost/build/phase191/replay-source/exports.json \
  --out selfhost/build/phase191/replay-api \
  --engine selfhost/.assets/bin/bun \
  --upstream selfhost/.bootstrap/upstream-phase182
```

The explicit manifest prevents subsequent development edits from invalidating
an already checked acquisition. Earlier failures are retained as evidence;
never edit a receipt to hide an input change.

## Ladder

1. Inspect exact ELF instructions and checked IR. `frame-transitions.py` extends
   the retained Phase190 machine audit with conservative frame store/load
   witnesses. These are static mechanisms, not cache misses or speed estimates.
2. Acquire a checked API with fixture modules and exports. `controls.mjs`
   covers indexed encoding, loop priority, and address selection;
   `controls-extra.mjs` adds CMOV, frame forwarding, and conditional selection.
   Direct objects and rendered assembly execute independent C observers;
   indexed and CMOV encoding also have separately authored assembly oracles.
3. Emit the eight frozen development cases using `emit-programs.mjs`; link
   with the unchanged Phase190 `build-programs.py`, which checks exact output.
4. Merge the same C, frozen Phase190 native baseline, and candidate products
   using Phase185 `runtime-loop.py`. Use balanced role rotations and preserve
   failed runs, dispersion, individual regressions, and negative results.
5. Freeze before the remaining37 cases. Report all44 timed cases, positive
   log-slowdown, threshold counts and fixed-work time alongside geometric means.
6. Qualify a selected native image only after useful transfer evidence. Keep
   installed Phase189 and independently qualified Phase190 available.

`cases.json` records the eight/37 split. These programs have historical
measurements; held-out here means withheld from this campaign's tuning, not
previously unknown algorithms. `references.py` freezes C/QBE/prior x86 and the
actual qualified Phase190 N2 products.

The maintained profiler's `plan-runtime.py` consumes authenticated runtime
manifests and timing receipts. It assigns each case/role its own calibrated
workload identity and records repetition denominators. Different repetition
counts must not be pooled as identical work. See the profiler README for the
capture, coverage, comparison and normalization boundaries.

`campaign-cost.py --out FRESH.json` is an offline as-of snapshot of Phase191
outer guard costs, including failures, and frozen Phase190/191 selected-source
size/declaration growth. It reuses the unchanged Phase190 receipt reader;
unfinished jobs are listed but excluded from duration totals. It runs no target
programs and does not attribute mutable worktree edits to this campaign. Use a
fresh output at campaign close; see the snapshot's explicit measurement scope.
