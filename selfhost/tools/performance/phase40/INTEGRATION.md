# Phase40 final integration recipe

Installed checked06 passes42 ordinary/relocated CLI checks, all15 postinstall
audit gate groups and canonical identity of227 sources. The selected API is
`630879d8f030241a1d2c56e97f18f88b5be2070ac45dd02304afd06b3e3c5c0a`.
The portable [current bundle](current/manifest.json) contains all45 points,176
archive members and1,336,751compressed bytes.
[Postinstall audit](../../../build/phase40/postinstall-audit06/gates.json),
[semantic integration record](../../../../implementation/phase40/integration.md)
and [performance admission](../../../../implementation/phase40/performance-admission.md)
are separate evidence. The portable fast smoke passes five points/45samples with
a20second preset in20.36seconds including overhead; it is not a hard wall ceiling
or another full-catalog admission.

[integration-recipe.json](integration-recipe.json) preserves the initial data-only
checklist. The corrections and reviewed successors below supersede its original
control/closer selections; do not blindly replay obsolete assertions. Root owns
serial execution. Builds, source acquisition, semantic controls, unprofiled
execution, profiling, compiler-request cost and installation remain distinct.
For a fresh replay bind the selected checked attempt, its full45-point preparation,
its separate historical owner preparation and a new output prefix:

```sh
PHASE40_ATTEMPT=selfhost/build/phase40/checked06
PHASE40_PREPARATION=selfhost/build/phase40/final-candidate02/manifest.json
PHASE40_PREPARATIONDIR=selfhost/build/phase40/final-candidate02
PHASE40_OWNER_PREPARATION=selfhost/build/phase40/owner-preparation01/manifest.json
PHASE40_OUT=selfhost/build/phase40-replay/integration-NEW
PHASE40_NODE=/absolute/path/to/node
```

Use a new checked attempt/preparation after any source edit; the defaults above
identify the installed campaign. Historical build artifacts are required for
these integration/cost commands, unlike portable generated-program timing.

Prepare all45points/23sources once from the final checked source. Freeze the
three existing plans with the same API. The maintained final planner needs all
four existing added-module flags even though this campaign adds no new module:

```sh
python3 selfhost/tools/performance/phase37/final-integration-plan.py \
  "$PHASE40_ATTEMPT" "$PHASE40_OUT/final-plan" --prepared "$PHASE40_OWNER_PREPARATION" \
  --added-module src/back/js/jpure.bend --added-module src/back/js/fold.bend \
  --added-module src/back/js/producer.bend --added-module src/back/js/finite.bend
python3 selfhost/tools/performance/phase37/phase36-owner-plan.py \
  "$PHASE40_ATTEMPT" "$PHASE40_PREPARATION" "$PHASE40_OUT/phase36-owners"
python3 selfhost/tools/performance/phase39/phase37-owner-plan.py \
  "$PHASE40_ATTEMPT" "$PHASE40_PREPARATIONDIR" "$PHASE40_OUT/phase37-owners"
```

Run final-plan owner commands in order using each `supervisedCommand`, excluding
`owner-counters` and `owner-close`. Run the reviewed Phase39 counter successor
on that freshly emitted counters cohort with the bounded supervisor and exact
stack4096/heap1024 flags. Copy owner/reports.json to a fresh mapping; replace
cases.counters with the successful successor report and cases.recursive-folds
with both reviewed fold reports described below. Use the unchanged
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
Reacquire all four inherited Phase39 owners using their pinned historical
baselines and the reviewed current diagnostic successors below. The old V4
closer/spec remain unchanged; use inherited-owner-close-v2.py with its pinned
successor specification and fresh mapping, including the mandatory tail report.
New retained Phase40 behavior needs independent Bend fixtures and actual checked
emission controls in addition to these inherited groups.

For a new image, measure45points in the four disjoint groups with starting
Phase39 baseline, fresh finalcandidate and unchanged TS. For this selected image,
the completed evidence uses42 exact-byte checked05 comparisons plus three fresh
checked06 ray comparisons, not45 freshly timed checked06 points. The reviewed
select-execution.py rehashes every three-role module and recomputes each raw
case's stats/paired rounds/ranges/drift, preserving measurement API and protocol.
Rejected checked05 ray rows remain visible but excluded from selection. Identity
reuse never transfers semantic gates, compiler-cost or installation evidence. Compiler cost
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
  --attempt "$PHASE40_ATTEMPT" --cases local-pair,local-fold,raytrace \
  --out "$PHASE40_OUT/owner-preparation" --node "$PHASE40_NODE" --cpu 3 \
  --heap-mib 1024 --rss-mib 2048 --available-mib 2048
PHASE40_OWNER_PREPARATION="$PHASE40_OUT/owner-preparation/manifest.json"
```

PHASE40_OWNER_PREPARATION is that new manifest. Final integration --prepared uses it;
Phase36/37 plans, broad timing, portable candidate and request costs use the
full45preparation. Both preparations bind the exact same checked final API.
Do not relabel a45catalog manifest as the15catalog or rewrite its receipts.

## Reviewed semantic diagnostic successors

The original collector/auditor retains exact source/checked-emission/resource
provenance. Successors correct obsolete diagnostic ownership expectations, not
program results. Preserve original failed wrappers and consumed tools; map fresh
passing reports directly and keep all value, alias, demand/error, mutation/reentry
and deep-stack requirements.

- Counter: Phase39 vector-counter-fixture-controls-v1.mjs retains35 independent
  oracles, five structures and five boundaries, requiring the existing proved
  Number countdown while escaping/observed predecessors remain BigInt.
- Recursive fold: phase40/fold-controls-v3.mjs separates the actual fold counter
  from the newly admitted producer counter, requires one of each, verifies
  captured owners and exact shared child aliases. Its27 oracles/57 boundaries/
  three structures/four admissions pass. The unchanged phase35/fold-guards.mjs
  runs against a fresh selected-attempt/API config and passes24 recognizer
  observations. Map both reports under recursive-folds. The stock fold wrapper
  has no control override: its checked cohort survives its preserved obsolete
  control failure; use that exact cohort for V3 or separate checked acquisition
  from the old control stage in a new reviewed launcher.
- Guard: the reviewed Phase39 guard-checked-derive.mjs and guard-checked-controls.mjs
  still bind exact guarded source, public entry and injected error/reentry.
  The fold recognizer config must identify the current selected attempt/API;
  an old config cannot close a new image's guard gate.
- Component: phase40/component-inherited-derive-v1.mjs preserves the original
  fixture, three checked receipts, helper closure and all refusals except the now
  proved tail. It positively requires that worker/no-frame-push and instruments
  root admission after proof opening. Unchanged Phase39 component-actual-controls.mjs
  passes159 oracles/113 boundaries/three admissions. The additional
  component-inherited-tail-controls-v2.mjs passes13 oracles/19 live boundaries/one
  admission, including depth30000, terminal identity and real foreign-producer
  deferred field forcing. V1's inactive-boundary failure remains preserved.
- Unary: phase40/unary-compiled-controls-v1.mjs only fixes complete decimal helper
  name decoding so $tree suffixes are not mistaken for the ordinary unary helper.
  The original actual primary-worker, alias/order/admission/refusal assertions
  remain unchanged:83 oracles,56 structures,32 boundaries,three admissions,
  three order cases and three refusals pass.

[inherited-owner-close-v2.py](inherited-owner-close-v2.py) and its
[pinned specification](inherited-owner-spec-v2.json) require all four original
owner contracts plus the tail supplement, exact predecessor/tool hashes, fresh
selected-image cohorts, and successful bounded executions. The component mapping
adds tailReport/tailExecution; those are mandatory, not optional diagnostics.
The prospective V1 closer/spec and failed launches remain preserved.

These owner closures are separate from ordinary frontend/backend agreement,
expanded application checks, timing and postinstall CLI identity. Counts overlap
and do not imply full backend/GPU conformance, absence of shared failures or an
independent proof-kernel audit. For exact successful receipt paths read the
integration record; choose fresh directories for every replay.
