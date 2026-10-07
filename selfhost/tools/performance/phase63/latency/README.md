# Phase63 controlled compiler latency

The frozen Phase61 method06 is retained. `make-method.py` records exact textual
derivation into a fresh Phase63 boundary. Target commands belong to root alone;
this directory's Python factories only read/hash/write data on CPU0.

Method02 is the current materialized method at
`selfhost/build/phase63/latency-method02`. Method01 remains preserved after a
failed preparation detected a concurrent workflow edit. Its original changes
are writable-path relocation, exact historical State08 workflow audit mapping,
and explicit `frame3` filename recognition. Its frozen snapshot driver still
decodes and validates each cache; admitted logical cache versions remain 4/6.
The historical mapping requires exact emission and attempt hashes plus the
checked attempt's original/frozen byte-identical source row. Current execution
tools remain independently pinned. Source/API/runtime oracles are not relocated.
Method02 additionally stages and verifies the new graph helper from each actual
checked snapshot when present, and pins the current workflow's driver/helper
import dependencies separately. Historical State08 uses its original snapshot
without this new helper. Neither cache codec nor timing logic is substituted.

```sh
taskset -c 0 python3 -B selfhost/tools/performance/phase63/latency/make-method.py \
  selfhost/build/phase63/latency-method01 --frame-version 3
```

That destination already exists: reuse it; choose a new name for a successor.
Do not overwrite a consumed method, factory, binding, preparation or receipt.
To reproduce method02 at a fresh destination, use `make-method-v2.py NEW_METHOD`.

## Checked build at the root's explicit freeze

After source owners stop editing, materialize a build recipe. These paths are
examples; every actual attempt and output must be fresh.

```sh
taskset -c 0 python3 -B selfhost/tools/performance/phase63/latency/make-build.py \
  selfhost/build/phase63/state01-build-plan \
  --attempt selfhost/build/phase63/checked-state01
```

The factory records the same source/helper tree the maintained development
workflow freezes, strict equality-profile configuration and exact executable,
Base and guard identities. It prints the single guarded root build command.
Use `make-build.py PLAN --verify` before execution if intervening work occurred.
The workflow's actual snapshot and checked bootstrap receipt, rather than the
recipe, establish the candidate. Do not fabricate checked metadata for B2.

## Image bindings and recipes

For checked B1, compare to the frozen State08 checked B1 by default:

```sh
taskset -c 0 python3 -B selfhost/tools/performance/phase63/latency/make-bindings.py \
  selfhost/build/phase63/state01-b1-latency \
  --method selfhost/build/phase63/latency-method02 --image b1 \
  --candidate-attempt selfhost/build/phase63/checked-state01/attempt.json \
  --without-typescript
```

After actual B2 emission, bind the complete checked generator and emission:

```sh
taskset -c 0 python3 -B selfhost/tools/performance/phase63/latency/make-bindings.py \
  selfhost/build/phase63/state01-b2-latency \
  --method selfhost/build/phase63/latency-method02 --image b2 \
  --candidate-attempt selfhost/build/phase63/checked-state01/attempt.json \
  --candidate-emission selfhost/build/phase63/state01-bootstrap/full/report.json
```

If roots change, pass the independently reviewed `--candidate-admission` and
`--candidate-roots-reference` files. If emitted bytes change, default oracles
fail: first qualify new outputs and supply the existing reviewed
`--candidate-oracles` packet schema. Do not weaken byte equality to pass timing.

`--baseline-image b2` permits a preliminary checked-B1/genuine-B2 comparison,
explicitly labelled cross-generation. It cannot attribute a source speedup.
`--include-baseline-b1` adds the actual old B1 to a separate generation recipe.

The factory writes machine-readable argv in `recipe.json` and shell-quoted
`commands.txt`. Each role stages its own frozen driver/helpers/API and private
API-keyed cache. Baseline State08's snapshot remains untouched. Run `prepare`
once, then reuse it for that exact binding. Preparation is not timed as a clean
request. The runner itself owns the execution guard: **no outer/double guard**.

| Recipe | Sources | Rounds | Later requests | Purpose |
|---|---|---:|---:|---|
| screen | Numeric, MapSet | 1 | 0 | Cheap rejection; not position-balanced |
| screen-balanced | Numeric, MapSet | role count | 0 | One full role-position rotation |
| confirm | Numeric, MapSet, raytrace | 2 | 0 | Short confirmation; 3 roles are not fully balanced |
| heldout | Lexer, Evening | role count | 0 | Held-out full position rotation |
| broad | all 23 | 3 | 0 | Balanced 207-worker gate with 3 roles |
| later | Numeric, MapSet, raytrace | role count | 3 | Separate repeated-request metric |
| cpu / allocation | Numeric, MapSet | 1 | 0 | Separate diagnostic runs |

Clocks retain ordinary driver import, `loadApi`, and first ordinary checked
library compilation, reported separately and combined. Every sample starts a
fresh process; prepared persistent Base cache bytes are verified before/after.
Full raw module equality is after the measured window. There is no profiler in
clean runs, no claim of cold OS caches and no fresh user-program runtime claim.

Root runs serial CPU3 targets with 1 GiB Node heap, 4 MiB stack, 2 GiB process-tree
RSS cap and 4 GiB available-memory floor. Keep failures and incomplete queues;
create fresh retries. Report equal-source geometric means of per-source medians
for first request and combined first window separately. Broad runtime behavior
qualification, own-source checking, B2/B3 reproduction and release admission
remain separate integration gates.

## Export admission and genuine B2

At the root's source freeze, `export-admission.py admit NEW_DIRECTORY` verifies
the three exact source-backed bootstrap export additions, preserves State08's
86-root construction, and freezes the candidate driver, relevant source modules
and review diffs. The eight proposed exports are two prepared-world functions,
two frontend-ready-prefix functions and four JDPlan functions. The existing
Phase61 admission schema counts them together with the earlier five
supplementary roots; the four original Base-prefix additions remain separate.

After the actual checked B1 succeeds:

```sh
taskset -c 0 python3 -B selfhost/tools/performance/phase63/latency/export-admission.py \
  reference ADMISSION_JSON CHECKED_ATTEMPT NEW_REFERENCE_DIRECTORY
taskset -c 0 python3 -B selfhost/tools/performance/phase63/latency/prepare-bootstrap.py \
  plan CHECKED_ATTEMPT NEW_BOOTSTRAP_DIRECTORY --admission ADMISSION_JSON
```

The reference factory requires the exact checked snapshot, old86 plus new8
exports, and unchanged old-root order. Its root-only API validation command
verifies the checked attempt, exact default-export key set and every callable
adapted function. Factories do not execute that command.

The B2 factory derives existing split tools with an exact source-backed JDPlan
decomposition. Actual `jd_plan_selected` supplies the final context, selected
definitions and retained text. The split renders retained plan definitions plus
exports rather than lowering definitions again. Tiny output must equal both
ordinary `jd_plan_library(plan)` and compatibility
`jd_library_selected(context,selected)`. Only then may the full own-source
emission run. Both actual driver roles stage and pin the new graph helper, and
their eight-observation comparison precedes image pins. Inherited checked
source provenance is explicitly distinct from the later B2 fresh self-check.

The [final qualification factory](qualification/README.md) derives unchanged
semantic/native/program oracles, stages the selected cache helper and uses the
same ordinary JDPlan API for B3 reproduction. Its generated final orchestration
can reuse completed B2 image pins. Its release stage prepares commands only;
root separately admits installation after all relevant gates.

## Host-helper counterfactual loop

`host-variants.py` avoids rebuilding an unchanged compiler image merely to test
a reviewed private decoder helper. Its data-only `prepare PREPARATION NEW_OUT
--variant NAME=FROZEN_HELPER` command clones the actual candidate B2's recorded
staged files and prepared cache into fresh projects. Every API, driver, runtime,
Base and cache hash stays identical; only `tools/base-cache-graph.mjs` differs,
with both identities and an exact textual diff retained. No checked sidecar is
created and every result is labelled diagnostic, not production-qualified.

The emitted `commands.txt` runs Numeric and MapSet in fresh ordinary processes
under the existing root-only guard. Import, API loading and first compilation
are separate clocks; complete raw output equality and before/after identities
are checked afterward. No profiler, custom API argument, predecoded object or
hidden warm request is inserted. One round is a cheap fixed-order screen;
`--rounds 2` alternates a two-role comparison. Rebuild and requalify a selected
helper before production promotion. Failed outputs and processes remain stored.

The first literal-shape plan is `selfhost/build/phase63/state05-host-shapes01`.
Subsequent helper experiments need fresh destinations and frozen replacement
files. The data-only clone took 2.2 seconds; target run costs belong to the
resulting root-owned receipts, not this preparation statement.
