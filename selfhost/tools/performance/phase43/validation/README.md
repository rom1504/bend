# Phase43 validation

The selected image is `selfhost/build/phase43/checked14`. The reviewed owner
configuration is `final-owner-config-v6-reviewed.json`: 49 acquisition/control
steps and 18 new owners, alongside all 16 inherited owners. The final semantic recipe
successor is `selfhost/build/phase43/recipe06.json`; its campaign remains
`selfhost/build/phase43/integration01`.

Root schedules every target, compiler-cost and timing command serially through
the campaign ledger. Existing output directories are immutable. Resume only
unfinished named steps; retain original failures, recipes and successful reports.
The helpers in this directory do not modify compiler source.

## Build and provenance

For a future fresh checked attempt, assemble the runtime before building:

```sh
PHASE43_NODE=/home/ai/.nvm/versions/node/v24.18.0/bin/node
"$PHASE43_NODE" selfhost/src/runtime/js/build.mjs
python3 selfhost/tools/performance/phase32/bounded-run.py --seconds 900 \
  --rss-mib 2048 --available-mib 2048 FRESH_BUILD_SUPERVISOR -- \
  taskset -c 3 "$PHASE43_NODE" --stack-size=4096 --max-old-space-size=1024 \
  selfhost/tools/development/workflow.mjs run \
  selfhost/tools/performance/phase43/validation/checked-config-v1.json FRESH_ATTEMPT
```

The configuration retains the checked equality derivative, strict exact checks,
one worker, CPU3 and 1GiB heap. `runtime-agreement-v1.py` checks the exact generated
bundle against the five consumed fragments and builder before semantic,
cost-preparation and postinstallation stages. Do not rebuild the frozen checked14
attempt or import earlier PASS reports as fresh qualification.

The initial reviewed acquisition uses `build-extension-v6.py` with the reviewed
v6 configuration, followed by `prepare-recipe-v1.py` with the extension, selected14
scalar contract/review and native-proof57 review. These artifacts are already
materialized for integration01. Source, API, runtime, Base, Node, controller,
checked-emission receipt and raw execution identities remain mandatory. Manual
JavaScript, diagnostic overlays and favorable earlier attempts cannot qualify an
actual-source owner.

## Current qualification and continuation

Recipe04 is derived from recipe03 by `prepare-qualification-successor-v1.py`
and the six explicit review receipts. It preserves all raw controls and the 17
successful v6 owner closures. Only the failed noncommutative closure uses v7,
which resolves the two declared auxiliary-catalog identity slots at that
catalog's directory and retains every hash and semantic check.

The inherited wrapper successor preserves its original 84 oracles, two boundaries
and six activation keys, and separately requires 12 ordinary scalar/Nat helper
activations, 30 dependency fallback controls and eight public-input/alias controls.
Fusion and hybrid successors bind the selected runtime/guard policy without
changing their semantic inventories. Layout permits only five exact outer
`,false` capability metadata edits and requires byte-identical executable public
bindings. The native constructor assay reports `wholeProgramIsolation:false`:
three retained worker owners coexist with a seven-worker selected inventory and
new pair destinations. Role-specific fingerprints, exact constructor removal,
positive literal/pair evidence and four fresh behavioral/alias/deep reports remain
required. Historical single-change isolation is retained as historical evidence.

Recipe05 changes only two reviewed BST aggregation expectations: the exact selected
worker inventory grows from three to six, and the nondependency Array.isArray
activity observation changes from 92 to 30. All semantic, alias, deep, guard and
zero-entry refusal checks remain intact. A read-only pass checked 472 assertions,
bindings and relations across 45 reports and found only those two mismatches.
The failed prior closure remains immutable; the successor uses a fresh closure
output. Runtime measurement continues to bind recipe04 and the same checked14
image; semantic aggregation uses recipe06. Neither requires a target rerun.

Recipe06 adds only the missing `executionOutput:"file"` declaration for the
successful hybrid controller. It retains exact output-path matching and redirects
the failed aggregation to a fresh closure directory. Static preflight checked 643
closure invariants; every other check passed. The recipe06 closure now passes all
34 owners, the preinstall audit passes 14 gates and 227 source bindings, and the
preinstall composite passes 41 groups. Final runtime passes 45 points/669 samples;
root performance/cost admission is complete/pass. Postinstall install/verify/42-CLI smoke now completes with all commands returning
zero. The installed audit passes 15 gates and 227 source bindings with no
outstanding gates, and the postinstall composite passes 41 groups. Portable freeze/plan and the selected smoke replays now pass. Protected-file
verification and archive/writer closure also pass as separate release stages.

Run an explicitly selected unfinished list through the ledger, for example:

```sh
python3 selfhost/tools/performance/phase41/recipe-run.py \
  selfhost/build/phase43/recipe06.json COMMA_SEPARATED_UNFINISHED_NAMES \
  --ledger selfhost/build/phase43/campaign.jsonl \
  --jobs FRESH_JOBS_DIRECTORY --prefix FRESH_JOB_PREFIX
```

Full source/refusal/frontend checks, all 34 owner clauses and final composite
closure remain mandatory. The inherited frontend runs serially with two workers
on CPU3,4, 1GiB heap each, 3GiB combined RSS, a 5GiB available-memory preflight and
2GiB floor. This is an explicit bounded exception to the usual CPU3/2GiB campaign
protocol; no other heavy job overlaps it.

## Runtime, compiler cost and release

`check-measurement-bindings-v1.py` binds the compact preserved Phase42 baseline,
pinned TypeScript and fresh selected45 candidate acquisition. Then
`prepare-runtime-batches-v1.py RECIPE --binding BINDING --plan FRESH_PLAN`
creates three serial 15-point preset600 batches. `close-runtime-batches-v1.py`
requires all 45 points and 669 fresh samples with the unchanged warmup,
calibration, target, role ordering and module identities. Short screens are
reported separately and cannot replace the final runtime protocol.

The existing Phase39 compiler-cost planner and Phase35 runner measure three
rotated fresh samples for TypeScript, checked16 and checked14. Keep the inherited
four controls and four changed-family sources (`lexer`,
`coverage-map-churn-128`, `coverage-closures-256`, `coverage-bst-64`) as two separate
36-request reports. Report normal checked-library request time, host import,
process time, memory, output bytes and sample ranges; runtime ratios and compiler
costs are separate evidence.

After a complete preinstall composite and explicit root performance/cost
admission, the postinstallation command is:

```sh
python3 selfhost/tools/performance/phase43/validation/run-recipe-v1.py \
  selfhost/build/phase43/recipe06.json --stage postinstall \
  --admission selfhost/build/phase43/integration01/performance-admission.json \
  --ledger selfhost/build/phase43/campaign.jsonl \
  --jobs FRESH_POSTINSTALL_JOBS --prefix FRESH_POSTINSTALL_PREFIX
```

Admission must be complete/pass and bind the selected attempt and API; it records
runtime regressions, both cost reports, source-size growth and the accepted scope.
Postinstall launch, installed audit and composite reports live under integration01.
Portable freeze and plan pass for the current 45-point bundle. Compact20 replay
passes three cases in 11.6977 s; target60 BST/Map/numeric passes three in
25.8144 s; fast02 with budget60 passes five in 41.9259 s. These are separate smoke
receipts and do not add samples to the final 669. Fast01 with budget20 fails at
its budget after 21.2061 s with four of five cases completed; retain that failure
beside the later completed replay. Portable smoke precedes writer closure and
archive publication; final accounting/protected/archive stages now pass.
Use
[the release handoff](../products/portability/release-handoff-v1.md) for those
commands and the protected103-file check.

Detailed rationale and historical repairs are in
[design validation](../../../../../design/phase43/validation.md),
[implementation validation](../../../../../implementation/phase43/validation.md)
and the immutable [review receipts](../review/). No earlier failed raw evidence is
removed or relabeled as passing.
