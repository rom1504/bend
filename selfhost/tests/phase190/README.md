# x86 optimization discovery loop

The compiler algorithms are Bend modules under `src/back/x86/`. These adapters
only authenticate inputs, acquire checked compiler APIs, invoke maintained
builders, compare independent observations and summarize measurements.
Use one guarded CPU3 execution lane. Keep the installed compiler as a reference.

The frozen [cases.json](cases.json) separates six development programs from
39 held-out programs. An experiment records the work expected to disappear,
its legality conditions, a cheap rejecting test, and its exact source switches.
Do not use held-out results to tune that same candidate and still call them
held-out. Preserve failed acquisition and measurement receipts.

## Fast ladder

1. Inspect actual hot machine code using `machine-audit.py`. Use the maintained
   native profiler for dynamic attribution; static frame accesses are not cache
   misses. `profile-plan.py` and `profile-analyze-roles.py` record the Phase190
   profile procedure, including rejection of mismatched workload pooling.
2. Assemble an immutable source snapshot and acquire a checked hosted API.
   `prepare-api.py --set NAME=value` supports recorded literal Bool/U32 switch
   changes; it does not implement compiler transformations. Source edits and
   fixture modules are independently checked by the upstream compiler.
3. Run adversarial typed-machine fixtures through both assembly and objects,
   comparing with the independent C observers. `controls-final.mjs` is the
   final fixture transport; source-preparation receipts list its required
   exported functions and modules. Earlier numbered harnesses remain immutable
   provenance, including the rejected complement-label formatting contract.
4. Emit/build only `--cases development`, then compare fresh C, retained
   baseline and candidate runtime. Use a round count divisible by the number
   of roles. Selection, emission and runtime costs are separate measurements.
5. Freeze the candidate before `--cases heldout` or `--cases all`. Do native
   image acquisition, native64/runtime controls and reproduction only after a
   substantial transferable result. Never infer qualification from source
   checking or a benchmark score.

Example checked API setup, with fresh paths throughout:

```sh
python3 -B selfhost/tools/build/source.py assemble \
  --manifest selfhost/src/compiler.json --root selfhost --profile x86 \
  --out selfhost/build/phase190/replay-source/compiler.bend
python3 -B selfhost/tests/phase190/prepare-api.py \
  --parent-source selfhost/build/phase190/replay-source/compiler.bend \
  --assets selfhost/build/phase190/assets.json \
  --out selfhost/build/phase190/replay-api-source
python3 -B selfhost/tests/phase190/job.py --rss-mib 3072 replay-api 180 96 \
  selfhost/.assets/bin/bun selfhost/tools/build/hosted.mjs acquire \
  --source selfhost/build/phase190/replay-api-source/compiler.bend \
  --exports selfhost/build/phase190/replay-api-source/exports.json \
  --out selfhost/build/phase190/replay-api \
  --engine selfhost/.assets/bin/bun \
  --upstream selfhost/.bootstrap/upstream-phase182
```

Use the authenticated asset snapshot from the campaign, or create an explicitly
different campaign with its own pins. `emit-programs.mjs` consumes `--api` and
`--binding` receipts, accepts `--cases development|heldout|all|CSV`, and produces
objects. `build-programs.py` links those objects and validates complete output
and counts before creating `programs.manifest.json`. Run each under `job.py`
with a fresh output, whole-run deadline and disk budget.

For an existing native compiler, `native-programs.py` replaces API emission and
link orchestration. Supply explicit `--image`, `--image-receipt`, actual
`--stage N1|N2`, `--host native --target x86 --emit object --mode cache`,
`--role candidate --cases development --guarded`, inside the outer job guard.

`references.py` authenticates retained executable products. The maintained
`tests/phase185/runtime-loop.py merge` takes explicit role manifests and a CSV
of case IDs; `run` performs balanced rotations, independent exact observations
and adaptive batches. `summarize.py` verifies report inputs and outputs before
computing historical geometric ratios, positive log deficit, threshold counts,
fixed-work sums, regressions, dispersion and development/held-out subsets.
`family-diagnostics.py` adds explicitly diagnostic family-weighted scores.

## Promotion and evidence

`compare-products.py` authenticates hosted/native development products before
requiring exact object and linked-section identity. Equality is appropriate for
the same compiler source executing through two hosts; optimized output is not
required to equal the old baseline's machine code.

Source acceptance, structural allocation validation, finite independent machine
tests, whole-program oracle tests, native reproduction and mathematical proofs
establish different properties. These passes contain no new BendTT theorem.
Successful reproduction does not prove correctness or recursive acceleration.

`campaign-cost.py` inventories guarded target time and failures separately from
source growth. It cannot observe agent billing or infer research productivity.
The [report](../../../implementation/phase190/README.md) links compact portable
receipts; executable/source snapshots and failed products remain retained in
the local build tree. Earlier experimental snapshots are not reconstructed by
checking out the final implementation alone. Do not overwrite them.
