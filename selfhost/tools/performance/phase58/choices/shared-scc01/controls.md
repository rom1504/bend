# Shared-dispatcher focused gates

Use the genuine `checked-reach01` baseline and `checked-shared01` candidate.
The sources and catalog for the existing literal-choice suite remain unchanged.
The v4 controller retains all 36 catalog oracles and nine host observations,
including the 100,000-step tests; its eight AST checks now resolve a mutual
entry into its one shared worker and require exact original loop bytes.
The existing `choices-typescript02` modules remain the pinned TS comparison.

Run each Node command below as a separate child under the root's resource
supervisor: CPU3, 1 GiB heap, 2 GiB tree RSS, 4 GiB available-memory floor.
Use a 120-second bound for acquisition and 60 seconds for a controller.
Controllers deliberately use Node's default stack; the acquisition compiler
retains its established larger stack. Every output path must be fresh.

```sh
/home/ai/.nvm/versions/node/v24.18.0/bin/node --stack-size=4096 --max-old-space-size=1024 \
  selfhost/tools/performance/phase58/qualification/paired-fixtures-v2.mjs \
  selfhost/build/phase58/checked-reach01 selfhost/build/phase58/checked-shared01 \
  selfhost/tools/performance/phase58/choices/catalog-v2.json \
  selfhost/build/phase58/shared-choice-fixtures01

/home/ai/.nvm/versions/node/v24.18.0/bin/node --max-old-space-size=1024 \
  selfhost/tools/performance/phase58/choices/controls-v4.mjs \
  selfhost/build/phase58/shared-choice-fixtures01/baseline/literal-choices.mjs \
  selfhost/build/phase58/shared-choice-fixtures01/candidate/literal-choices.mjs \
  selfhost/build/phase58/choices-typescript02/modules/literal-choices.mjs \
  selfhost/build/phase58/shared-choice-controls02

/home/ai/.nvm/versions/node/v24.18.0/bin/node --stack-size=4096 --max-old-space-size=1024 \
  selfhost/tools/performance/phase58/qualification/paired-fixtures-v2.mjs \
  selfhost/build/phase58/checked-reach01 selfhost/build/phase58/checked-shared01 \
  selfhost/tools/performance/phase58/choices/shared-scc-catalog-v1.json \
  selfhost/build/phase58/shared-scc-fixtures01
```

The unchanged TypeScript acquisition owns its resource guard; do not add another:

```sh
python3 -B selfhost/tools/performance/phase52/acquire-semantics-v2.py \
  --catalog selfhost/tools/performance/phase58/choices/shared-scc-catalog-v1.json \
  --selection upstream:selfhost/.bootstrap/upstream-phase23 --role typescript \
  --out selfhost/build/phase58/shared-scc-typescript01
```

After all four supplemental emissions and both TS emissions pass:

```sh
/home/ai/.nvm/versions/node/v24.18.0/bin/node --max-old-space-size=1024 \
  selfhost/tools/performance/phase58/choices/shared-scc-controls-v1.mjs \
  selfhost/build/phase58/shared-scc-fixtures01/baseline/shared-scc-library.mjs \
  selfhost/build/phase58/shared-scc-fixtures01/candidate/shared-scc-library.mjs \
  selfhost/build/phase58/shared-scc-typescript01/modules/shared-scc-library.mjs \
  selfhost/build/phase58/shared-scc-controls01
```

The supplemental source is compiled in library and program modes. It has nine
library oracles, 12 host observations per role, and one program oracle executed
for all three roles. Three component AST checks cover unequal live arities,
lexical captures/unknown closure tails, and a program whose sole root reaches
only the component leader. Callback reentry occurs while an outer dispatcher
still owns live state; sentinel identity, replay and partial application are
checked. Program mode must remove the unrelated capture component and preserve
both members of the reached component. These are focused controls, not a full
language-conformance or compiler-performance claim.

The consumed v3 controller and `shared-choice-controls01` failure are preserved.
All runtime checks passed there before a cross-realm Acorn-array comparison
failed. V4 normalizes only those compared AST arrays and retains their explicit
Identifier/type, PC, body and dependency checks.
