# Phase40 final integration recipe

[integration-recipe.json](integration-recipe.json) is a data-only checklist;
root executes commands serially with fresh paths. It records selected plan
steps, existing successor controls/closers, resource policy and acquisition
inventory. Bind FINALATTEMPT, PREPARATION (manifest), PREPARATIONDIR (directory), OUT and NODE before use.

Prepare all45points/23sources once from the final checked source. Freeze the
three existing plans with the same API. The maintained final planner needs all
four existing added-module flags even though this campaign adds no new module:

```sh
python3 selfhost/tools/performance/phase37/final-integration-plan.py \
  FINALATTEMPT selfhost/build/phase40/final-plan02 --prepared HISTORICALPREPARATION \
  --added-module src/back/js/jpure.bend --added-module src/back/js/fold.bend \
  --added-module src/back/js/producer.bend --added-module src/back/js/finite.bend
python3 selfhost/tools/performance/phase37/phase36-owner-plan.py \
  FINALATTEMPT PREPARATION selfhost/build/phase40/phase36-owners01
python3 selfhost/tools/performance/phase39/phase37-owner-plan.py \
  FINALATTEMPT PREPARATIONDIR selfhost/build/phase40/phase37-owners02
```

Run final-plan owner commands in order using each `supervisedCommand`, excluding
`owner-counters` and `owner-close`. Run the reviewed Phase39 counter successor
on that freshly emitted counters cohort with the bounded supervisor and exact
stack4096/heap1024 flags. Copy owner/reports.json to a fresh mapping; replace only
cases.counters with the successful successor report. Use the unchanged
Phase35 final-owner-close.py collector, then the existing final auditor's
`--owner-controls` override. Preserve original mapping/plan.

The historical counter-owner-rebind-v2.py requires a failed launch and failed
counter report on the exact same plan. It cannot be used while avoiding the
known obsolete failure. Do not fabricate those inputs. This recipe instead
uses its unchanged reviewed semantic successor directly, with35oracles,
5structures,5live boundaries, successful supervised execution and final checked
emission provenance. Root reviews these same obligations before collecting.

Run final-plan preinstall commands directly after owner closure. The stock
preinstall launcher includes owner commands first and would replay the obsolete
counter failure. For the Phase36 plan run all steps except old `close`; use
Phase37 phase36-owner-close-v2.py with FINALATTEMPT PREPARATION COHORTS MAPPING
NEW_REPORT. For the Phase37 plan the unchanged serial owner launcher suffices.
Reacquire all four inherited Phase39 owners using the unchanged controls and
new-owner-close-v4.py mapping; historical baselines remain pinned separately.
New retained Phase40 behavior needs independent Bend fixtures and actual checked
emission controls in addition to these inherited groups.

Run the45points once in historical/variation/development/holdout groups with
startingPhase39 baseline, fresh finalcandidate and unchanged TS. Compiler cost
requires a baseline-role bundle: acquire only local-pair/tree-bitonic/numeric1024/list-pipeline512
from Phase39 checked05 with `programs/prepare.py --role baseline`, then reuse
Phase39 compiler-cost-plan.py with that preparation and finalcandidate. Do not
pass the candidate-only Phase39 preparation as baseline-role data.

Final auditor, reviewed performance/cost admission and new/inherited owner
closures precede installation. Execute planned postinstall steps with native
subprocess support, then repeat the existing auditor with `--post-install` and
fresh output. Phase39's historical smoke retry override is pinned to its old
image and must not be selected for Phase40. Counts retain selected-test scope;
a checked fixed point, broad GPU/backend or independent kernel claim does not
follow from these gates.

## Preparation argument correction

The initial phase37-owners01 invocation used a manifest where its planner
requires a directory and failed before producing a plan. Preserve that attempt.
Use phase37-owners02 with PREPARATIONDIR. Final integration --prepared and the
Phase36 planner/closer accept either directory or manifest; portable freezer
--from, normal execution --candidate and cost planner preparation require the
manifest file. Source counting takes checked attempt directories. These path
forms must stay distinct even when they identify the same prepared compiler.

## Historical owner catalog correction

Phase35 vector-cohort, region-ray-cohort and region-colf-cohort use the fixed
programs/catalog.json15point catalog and expose no catalog override. Passing
the45point final candidate preparation to them fails exact catalog identity.
Phase39's historical-final01 preparation used the15point catalog separately.
Preserve Phase40 final-plan01 and first owner failure; create final-plan02 with
a fresh three-source owner preparation using the same maintained compiler:

```sh
python3 selfhost/tools/performance/programs/prepare.py \
  --catalog selfhost/tools/performance/programs/catalog.json \
  --attempt FINALATTEMPT --cases local-pair,local-fold,raytrace \
  --out selfhost/build/phase40/owner-preparation01 --node NODE --cpu 3 \
  --heap-mib 1024 --rss-mib 2048 --available-mib 2048
```

HISTORICALPREPARATION is that manifest. Final integration --prepared uses it;
Phase36/37 plans, broad timing, portable candidate and request costs use the
full45preparation. Both preparations bind the exact same checked final API.
Do not relabel a45catalog manifest as the15catalog or rewrite its receipts.
