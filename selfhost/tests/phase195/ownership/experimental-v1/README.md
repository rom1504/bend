# Actual-source ownership diagnostic v1

Experimental diagnostic only; no installed or maintained source changes. All
outcomes retain the original implementation. The three compiler modules are
`layout.bend`, `evaluator.bend`, and `proof.bend`; `bst-fixture.bend` is an ordinary
source input, not a compiler module. Source checking, diagnostic legality,
physical lowering and runtime correctness are distinct gates.

The evaluator is an isolated namespaced copy of the selected observer symbolic
engine, retaining its 4096-step budget, effects/cycle refusals, match facts and
exact constructor reconstruction equality. The structural descriptor adds
bounded branching graphs, opaque non-ADT fields, fixed-product input expansion,
and one optional owned descendant. A matched constructor fact also records its
original symbolic atom, so exact rebuilt recursive arguments can be converted
back to the original descendant cursor. Each recursive continuation must return
both opaque result words intact and every root identically. No emitted code is
produced. Successful summaries become available to subsequent requested owners
in the same diagnostic call; caller arguments must remain below held roots.

Preparation and root-owned source acceptance (fresh output names):

```sh
python3 -B selfhost/tests/phase190/prepare-api.py \
  --parent-source selfhost/build/phase194/selected-source02/compiler.bend \
  --assets selfhost/build/phase194/assets.json \
  --out selfhost/build/phase195/owned-diagnostic-api-source01 \
  --module selfhost/tests/phase195/ownership/experimental-v1/layout.bend \
  --module selfhost/tests/phase195/ownership/experimental-v1/evaluator.bend \
  --module selfhost/tests/phase195/ownership/experimental-v1/proof.bend \
  --export p195od_checked
python3 -B selfhost/tests/phase195/job.py owned-diagnostic-api01 120 48 \
  selfhost/.assets/bin/bun selfhost/tools/build/hosted.mjs acquire \
  --source selfhost/build/phase195/owned-diagnostic-api-source01/compiler.bend \
  --exports selfhost/build/phase195/owned-diagnostic-api-source01/exports.json \
  --out selfhost/build/phase195/owned-diagnostic-api01 \
  --engine selfhost/.assets/bin/bun --upstream selfhost/.bootstrap/upstream-phase182
python3 -B selfhost/tests/phase195/job.py owned-diagnostic-map01 120 16 \
  selfhost/.assets/bin/bun selfhost/tests/phase195/ownership/experimental-v1/diagnostic.mjs \
  --api selfhost/build/phase195/owned-diagnostic-api01/report.json \
  --binding selfhost/build/phase195/owned-diagnostic-api-source01/base-binding.json \
  --out selfhost/build/phase195/owned-diagnostic-map01 \
  --source selfhost/tools/bench/catalogs/native45/fixtures/coverage-map-churn-32.bend \
  --owners Map.seek.go,Map.seek
python3 -B selfhost/tests/phase195/job.py owned-diagnostic-bst01 120 16 \
  selfhost/.assets/bin/bun selfhost/tests/phase195/ownership/experimental-v1/diagnostic.mjs \
  --api selfhost/build/phase195/owned-diagnostic-api01/report.json \
  --binding selfhost/build/phase195/owned-diagnostic-api-source01/base-binding.json \
  --out selfhost/build/phase195/owned-diagnostic-bst01 \
  --source selfhost/tests/phase195/ownership/experimental-v1/bst-fixture.bend \
  --owners od_find,od_mutate,od_fresh,od_discard
```

Expected stop gate: actual Map seek.go and seek plus unrelated od_find prove;
od_mutate, od_fresh and od_discard refuse. These are expectations, not results.
`complete:true` means the diagnostic finished and can include refused plans.
The driver writes all proof errors and residual symbolic trees; it never emits,
assembles, links or runs generated programs. A returned `legality=1` remains
experimental evidence, not an independently verified optimizer certificate.

Known v1 audit gap: the synthetic opaque type prefix `$p195.opaque.` does not yet
have a whole-book collision refusal. A fresh version must add that before any
optimizer authority is considered. Generic representation and input-product
schema limitations must be established on actual checked requests. All proposed
executable adapters additionally need checked runtime layout reads, original
root lifetime retention, RFC/trivial ownership acquisition only, raw selected
field fallback before ownership transfer, and exact external wrapper/ABI shape.
