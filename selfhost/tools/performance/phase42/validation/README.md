# Phase42 checked iteration commands

Run from the repository root. Root owns campaign scheduling and the ledger;
these tools execute no compiler unless root selects a recipe command. Do not
commit historical raw files, change old tools, overwrite outputs or relabel
old candidate modules. Root may wrap each command in the existing Phase41
job.py or use its recipe-run.py with a fresh Phase42 ledger and job prefix.
Those wrappers record time and do not own the resource lock.

## Checked build

`checked-config-v1.json` uses the maintained checked B1 + equality derivative
and default36 focused frontend selection. Every compiler prototype needs a
fresh attempt. The 900s enclosing cap below is a resource deadline, not expected
build time. This focused frontend alone does not validate emitter changes.

```sh
NODE=/home/ai/.nvm/versions/node/v24.18.0/bin/node
ATTEMPT=$PWD/selfhost/build/phase42/checked01
OUT=$PWD/selfhost/build/phase42/integration01
RECIPE=$PWD/selfhost/build/phase42/integration01-recipe.json
python3 selfhost/tools/performance/phase32/bounded-run.py --seconds 900 \
  --rss-mib 2048 --available-mib 2048 selfhost/build/phase42/run-checked01 -- \
  taskset -c 3 "$NODE" --stack-size=4096 --max-old-space-size=1024 \
  selfhost/tools/development/workflow.mjs run \
  selfhost/tools/performance/phase42/validation/checked-config-v1.json "$ATTEMPT"
python3 selfhost/tools/performance/phase42/validation/bind-recipe-v1.py \
  --attempt "$ATTEMPT" --out "$OUT" --recipe "$RECIPE"
```

OUT must be absent when binding; RECIPE lies outside it. The binder runs
maintained verifyAttempt, verifies Node24.18 and the unchanged upstream git pin,
and captures exact attempt/API/runtime/Base/tool identities. It verifies frozen
sources and checked bootstrap/equality provenance. No source or compiler edits
occur. The successful recipe03 is pinned SHA
`62f2862307598580bd9f16e215da38d44e4b4d7e2e27cc6cdce05f3210ee2267`.
The new recipe records every candidate/output substitution and changes only
the compiler-cost baseline from Phase40 checked06 to Phase41 checked01.

## Focused iterations

Execute `focusedPreparation.argv` directly as an argv array. It prepares only
tree-bitonic and two list-pipeline points from the unchanged45-point catalog.
Preparation owns its supervisor: no outer bounded-run. Then execute
`focusedTreeSteps` in order for the actual Phase41 tree obligations using that
small preparation. Execute the named `focusedSteps` from the recipe in order
for inherited actual list, independent TS list, Nat, linear-order and wrapper
fixture controls. Each new Phase42 mechanism needs fresh actual emitted owner
controls. Run only the affected owner subset during a prototype screen; record
which gates remain pending. The final selected API must pass every named group.

All candidate-bearing modules must be freshly emitted by ATTEMPT. Reusing
historical baseline/TS identities is explicit in the recipe. Saved-JS
next-tuples ablation controls are diagnostic and do not substitute for actual
checked emission. Root sets a shared120s deadline if using the early admission
screen; it includes acquisition and controls, and retains incomplete evidence.
The recipe's individual120s bounds do not implement that shared deadline.

The inherited Phase41 actual tree gate requires124 oracles /17 boundaries,
positive ordinary wrapper entry and exact deep totals60002nodes/60003leaves;
fixture-v3 requires84 oracles /2 boundaries, two admitted wrappers and nine
refusals. The supplemental close command validates their selected attempt,
provenance, exact counters and successful enclosing receipts.

## One frozen release integration

Execute the retained recipe03 steps in order, honoring its manual mapping and
admission entries. A fresh final integration OUT avoids collisions with focused
iteration outputs. Existing Phase41 frontend and integration generators derive
the exact reviewed successors to fresh OUT locations; their old tools remain
immutable and their original Phase41 kind strings remain truthful lineage.

The full recipe retains counters+foldV3+guards+unary, owner15+7+3+4 closures,
component tailV2, actual list/Nat/TS/linear/scalar precedence, expanded154,
backend81 retained policy, two frontend workers with exact3026/196 agreement,
preinstall and postinstall auditors,42 CLI checks, full preparation and cost
admission. The added Phase41 obligations close separately at
OUT/phase41-close/report.json. The inherited fourteen/fifteen-gate auditor does
not itself collect those new groups; root must require this supplemental
closure and all Phase42 owner closures before promotion. No prototype broad
frontend run is needed when affected focused owner controls are sufficient.

The mapping entries remain instructions copied from the reviewed parent.
Resolve their uppercase bindings using recipe.bindings; do not overwrite
historical reports/mappings. Phase36 takes FULL manifest; Phase37 takes FULLDIR.
Frontend remains PHASE41_FRONTEND_CPU=3,4, initial available5GiB, aggregate
RSS3GiB /available floor2GiB /1200s and serial main/broader execution. CPU IDs
must be allowed. Four shared main failures remain observations; no comparator,
health, canonical-source or final installed checks are weakened.

## Freeze the starting portable baseline

```sh
python3 selfhost/tools/performance/phase42/validation/freeze-baseline-v1.py \
  --current selfhost/tools/performance/phase41/current/manifest.json \
  --reference selfhost/tools/performance/phase41/baseline/manifest.json \
  --catalog selfhost/tools/performance/phase37/catalog.json \
  --out selfhost/tools/performance/phase42/baseline \
  --expected-api 9900abf49719575db7f7bbee32c6b16e10bcd554f9de22cde0799eb859cc6f0b
```

The freezer performs no compilation or target execution. Its exact derivation
is adjacent. All bundle loading, selected API, provenance/input rehash and
archive reopen assertions remain. This reuses Phase41 current as baseline and
the Phase41 baseline's pinned independent TS role.
