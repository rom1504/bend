# Frozen final measurement handoff

Queue everything here serially at root. No command was executed by the validation agent; only Python AST/schema inspection was performed on CPU5. Identity checking hashes all45 candidate modules and imports no Node module; do not run it alongside timing.

Runtime baseline is `selfhost/tools/performance/phase42/baseline/manifest.json`: its baseline role is exact Phase41 checked01 API `9900abf49719575db7f7bbee32c6b16e10bcd554f9de22cde0799eb859cc6f0b`; its TypeScript role retains the pinned upstream reference. `phase41/baseline/manifest.json` is Phase40 checked06 API6308 and would measure the wrong transition. The final candidate is the full45 manifest acquired by the frozen final recipe.

The readonly new check binds every candidate emission receipt to the recipe's exact attempt SHA/API/runtime/Base/driver. It also checks the full45 selection and baseline API. The old program runner independently validates sources, catalog, archive/provenance, modules and the copied measurement inputs before and after timing. Both checks are needed: the historical runner alone does not know which attempt root intends to release. No baseline producer or report is relabeled.

Use absolute RECIPE and OUT variables already chosen by root. NODE is pinned24.18.0. Each receipt and output directory must be fresh.

```sh
NODE=/home/ai/.nvm/versions/node/v24.18.0/bin/node
python3 selfhost/tools/performance/phase42/validation/run-final-v1.py "$RECIPE" \
  --stage cost-prepare --ledger "$LEDGER" --jobs "$JOBS" --prefix final-cost-prepare
python3 selfhost/tools/performance/phase42/validation/check-measurement-bindings-v1.py \
  "$RECIPE" --cost --receipt "$OUT/measurement-bindings.json"
python3 selfhost/tools/performance/programs/run.py \
  --catalog selfhost/tools/performance/phase37/catalog.json \
  --baseline selfhost/tools/performance/phase42/baseline/manifest.json \
  --candidate "$OUT/full-preparation/manifest.json" --node "$NODE" \
  --cpu 3 --rss-mib 2048 --available-mib 2048 --budget 600 --set full --plan
python3 selfhost/tools/performance/programs/run.py \
  --catalog selfhost/tools/performance/phase37/catalog.json \
  --baseline selfhost/tools/performance/phase42/baseline/manifest.json \
  --candidate "$OUT/full-preparation/manifest.json" --node "$NODE" \
  --cpu 3 --rss-mib 2048 --available-mib 2048 --budget 600 --set full \
  --out "$OUT/runtime-full45"
python3 selfhost/tools/performance/phase35/compiler-cost-run.py \
  "$OUT/cost-plan/config.json" "$OUT/compiler-cost"
python3 selfhost/tools/performance/programs/diagnose.py \
  --catalog selfhost/tools/performance/phase37/catalog.json \
  --from-run "$OUT/runtime-full45" \
  --cases tree-bitonic,coverage-list-pipeline-512 --mode all --budget 60 \
  --out "$OUT/generated-diagnostics" --node "$NODE" \
  --cpu 3 --rss-mib 2048 --available-mib 2048
```

Record measurement/cost/profile commands through the existing root job/campaign ledger, as with other enclosing jobs. These tools already own ExecutionGuard; do not nest bounded-run or parallel timing. Diagnostics are after timing and use exact copied successful runtime modules. The two listed profile cases cover the actual tree/layout and list/fusion mechanisms; root can add other profiles using versioned fresh outputs.

Cost preparation deliberately uses direct fresh Phase41 checked01 baseline acquisition and direct pinned TypeScript preparation; the historical Phase39 cost planner's archive branch only accepts a Phase39 retained archive and is not suitable for the Phase42 portable baseline. Cost plan bindings dynamically verify both selected checked attempts, compare each compiler API/runtime/Base/driver and receipt attempt/output identities. The old scope strings mention earlier phases but are historical labels: exact dynamic variants and identities determine this run. Four exact cases are local-pair, tree-bitonic, coverage-numeric-recurrence-1024 and coverage-list-pipeline-512. Three rotations across three roles produce36 fresh process requests; unchanged worker SHA `f0dea569bdb02df60ed1156b0cead389e197291f1c3a3c6775102c7a03790f42`, CPU3, heap1024MiB, RSS/floor2GiB, request cap180s. The runner separates request/import/process wall costs and requires independently acquired exact output.

Budget600/full is the existing unchanged program preset, not a new protocol. It requests five balanced rounds per45point (raytrace three), three warmup calls and1000ms warmup floor,50ms calibration and300ms target; a complete run has669 samples across three roles. Deadline includes preflight. Root must inspect complete status, full45 coverage, balanced rotations, zero failures/stops and frozen identities before admitting; a partial run has no substitute final ratios. Identity receipt states performanceAdmitted=false.

## Critical path evidence

Phase41 campaign ledger enclosing successful integration02/integration03 semantic intervals total1400.718s (23.35min), excluding compiler cost preparation/measurement. Major components: full45 prepare122.833s, two frontend scopes437.141s, inherited preinstall nonfrontend452.612s, remaining Phase35 owners132.044s, Phase36 controls65.606s, Phase37 controls43.116s. Cost prepare28.374s, four-case cost253.324s, postinstall plus audit60.700s. These are historical observed intervals, not final estimates or additive nested child time. Phase41 runtime107.984s covered only six selected points and therefore does not predict the requested full45 run.

Plan approximately35–40min serial final campaign after the checked image is frozen: inherited semantic ~23min, new42 acquisitions/controls and composite checks, ~0.5min cost preparation, ~4min historical cost, up to10min selected full runtime budget, profiles and ~1min installation. Changed images can vary materially; this is scheduling guidance, not a timeout promise. Checked build (~45s historically) and recipe verification/materialization precede that. Layout currently fails actual marker admission on checked08, so final broad execution should wait for the resolved frozen image and passing focused positive/negative controls.
