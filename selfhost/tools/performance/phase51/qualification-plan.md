# Phase51 bounded integration qualification

Plan only. Root executes targets serially; these instructions do not establish a
new PASS. Reuse the existing controls and resource guard, then run one backend
census for the selected integrated runtime/emitter. Do not repeat the 28-job
Phase48 campaign or the historical full frontend inventory for these changes.

Run from `/home/ai/bend2/build/publish/bend`. Every output below must be fresh;
preserve unsuccessful attempts and choose another suffix for a retry.

Root may run the serial queue instead of copying the individual commands:

```sh
python3 selfhost/tools/performance/phase51/qualify-selected.py \
  selfhost/build/phase51/checked-candidate01 \
  selfhost/build/phase51/qualification01
```

The launcher records progress and stops at the first failed process or report.
It has no outer resource guard: each existing target launcher owns exactly one.
Keep the queue parent unpinned: acquisition validates that CPU3 is available in
its inherited affinity. Pinning the queue itself to CPU0 causes setup refusal,
even though the child tools own their CPU3 pin. The first `qualification01`
attempt retained that setup failure before target execution; root's retry uses
the unchanged launcher with an unpinned parent and fresh `qualification02` output.
Its default attempt/output are the same paths above. An optional
`--baseline-preparation PATH` must pass the exact RNFA04/source/catalog checks;
otherwise it finds a compatible completed acquisition in Phase48/51 or makes one.
The eleven entries include four acquisitions, four focused controls, maintained8,
data-only backend planning and the backend census. Baseline reuse is explicitly
recorded as an earlier execution. This queue is not a timing or release gate.

## Inputs and boundaries

The installed baseline is Phase48 RNFA04, checked attempt
`selfhost/build/phase48/checked-combined-rnfa04`: API
`6f9d111aa68c19f3ce45b80785621d57c4d10efb12d50164f5cb0597bc952100`,
runtime `880bce50e3194b9ee9d99bd57c18ef88bcb8925d9d1668dec6765040a4d3219b`.
The new attempt must have its focused strict checked gate complete and passing.
Check both API and runtime identities; a runtime-only change may leave API bytes
unchanged. Use the new attempt's frozen runtime, never the installed old bundle.

The array controls deliberately retain older historical baseline modules. Their
ordinary-source oracles assert the exact old host-hook traces; substituting
RNFA04 as their first argument would invalidate the harness contract. These are
semantic boundary controls, not current-baseline performance comparisons.

| Control | Exact preserved input | Expected scope |
| --- | --- | --- |
| Exact-entry hooks | `phase45/nullary-demand21-catalog-v2.json`, SHA `d183c684839ffc59bb245589ab9008445e32e478407efd131f49f4f753204806` | Six post-import host-hook observations, anchored to ordinary ungranted source execution. |
| Nullary demand v3 | Same source/catalog; fresh RNFA04 and candidate, preserved pinned TS | Six values, 39 boundaries, nine metadata observations, six activation observations. Raw code, missing vectors, partial/overapplication, error and reentry remain included. |
| Array view v4 | `phase47/array-controls-baseline01/modules/array-view-v1.mjs`, SHA `0a1b9825d120d499b1d4b0ad2ce955042e8f3082c3505e4858b12f3499aff2f9` | 24 values and 39 boundaries, plus actual private activation/refusal. |
| Array tree v6 | `phase47/tree-controls-baseline04/modules/array-tree-v4.mjs`, SHA `c2bb3eb7e93c90586ba7ae002017237410402b013c3934b328de4fa47cf65a1d` | 159 values and 11 boundaries, plus actual composed-tree activation/refusal. |
| Maintained eight | Unchanged `phase47/qualify.py` | IR, backend, initializers, choice, arms, 1,129 primitive guards/25 observations, provenance and foreign suites. |
| Backend census | Unchanged Phase43 runner and seven inherited batches | Exact agreement on 81 historical outcomes: 69 execution passes, eight not applicable, four shared failures. |

The nullary source is `phase45/fixtures/nullary-demand21-v2.bend`, SHA
`5c33c573098ff3f5cfaa7b5692f0716f05e80dd1c53914e36a63df84565ea1a7`.
The preserved TS module below has SHA
`564f50e77ddc3d8ac16349e4b696a39b607c2560809de9f6e062f357feeb9a3c`;
its adjacent checked emission receipt matches this source/catalog and pinned
upstream `018751270e800bc222a93dad7f257083ee53a5f7`.

Controls audit their inputs and saved checked emission sidecars. Root must also
join each fresh candidate emission's compiler attempt, API and runtime to the
selected attempt. Counter derivatives are untimed evidence, never timing inputs.
The array-tree ordinary derivative expects the unique `return inner(a,entered);`
inside `enterExact`; the present dispatch/String-proof proposals preserve it.
If a later proposal changes that protocol, preserve the old controller and
review a narrow successor rather than silently relaxing its assertions.

## Acquire three candidate fixtures, one current baseline fixture

Set `P51_ATTEMPT` to the actual checked integration winner. `prepare.py` owns
its guard; do not wrap these commands in `job.py`.

```sh
P51_NODE=/home/ai/.nvm/versions/node/v24.18.0/bin/node
P51_ATTEMPT=/home/ai/bend2/build/publish/bend/selfhost/build/phase51/checked-selected01
P51_BASELINE=/home/ai/bend2/build/publish/bend/selfhost/build/phase48/checked-combined-rnfa04
P51_Q=/home/ai/bend2/build/publish/bend/selfhost/build/phase51/qualification01

acquire51() {
  python3 selfhost/tools/performance/programs/prepare.py \
    --catalog "$1" --set full --role "$2" --attempt "$3" \
    --node "$P51_NODE" --cpu 3 --heap-mib 1024 --rss-mib 2048 \
    --available-mib 4096 --timeout 180 --out "$4"
}
acquire51 selfhost/tools/performance/phase45/nullary-demand21-catalog-v2.json \
  baseline "$P51_BASELINE" "$P51_Q/nullary-baseline"
acquire51 selfhost/tools/performance/phase45/nullary-demand21-catalog-v2.json \
  candidate "$P51_ATTEMPT" "$P51_Q/nullary-candidate"
acquire51 selfhost/tools/performance/phase47/controls/array-view-catalog-v1.json \
  candidate "$P51_ATTEMPT" "$P51_Q/view-candidate"
acquire51 selfhost/tools/performance/phase47/controls/array-tree-catalog-v4.json \
  candidate "$P51_ATTEMPT" "$P51_Q/tree-candidate"
```

If root already acquired the exact fixture for this attempt, reuse that completed
acquisition after auditing its identities; do not duplicate the compilation.

## Focused runtime and guard controls

Each controller has one outer guard: CPU3, 1GiB Node heap, 2GiB tree RSS and
4GiB available-memory floor. Require both successful process exit and a complete,
passing child report with the expected counts above.

```sh
control51() {
  P51_NAME=$1
  shift
  python3 selfhost/tools/performance/phase46/job.py \
    --out "$P51_Q/job-$P51_NAME" --seconds 120 -- \
    "$P51_NODE" --stack-size=4096 --max-old-space-size=1024 "$@"
}
control51 exact-entry selfhost/tools/performance/phase45/exact-entry-host-hooks-controls-v1.mjs \
  "$P51_Q/nullary-baseline/modules/nullary-demand21-v2.mjs" \
  "$P51_Q/nullary-candidate/modules/nullary-demand21-v2.mjs" "$P51_Q/exact-entry"
control51 nullary selfhost/tools/performance/phase45/nullary-demand21-controls-v3.mjs \
  "$P51_Q/nullary-baseline/modules/nullary-demand21-v2.mjs" \
  "$P51_Q/nullary-candidate/modules/nullary-demand21-v2.mjs" \
  selfhost/build/phase45/nullary21v2-typescript/modules/nullary-demand21-v2.mjs \
  "$P51_Q/nullary"
control51 view selfhost/tools/performance/phase48/controls/array-view-controls-v4.mjs \
  selfhost/build/phase47/array-controls-baseline01/modules/array-view-v1.mjs \
  "$P51_Q/view-candidate/modules/array-view-v1.mjs" "$P51_Q/view"
control51 tree selfhost/tools/performance/phase48/controls/array-tree-controls-v6.mjs \
  selfhost/build/phase47/tree-controls-baseline04/modules/array-tree-v4.mjs \
  "$P51_Q/tree-candidate/modules/array-tree-v4.mjs" "$P51_Q/tree"
```

These complement the Phase51-specific dispatch/String-proof prototype controls;
they do not replace those new mechanism and boundary observations. Repeat the
focused dispatch/token observations on actual checked-candidate modules, or
establish byte identity of the exact runtime/wrapper tested; an earlier saved-JS
prototype PASS alone does not qualify the integrated compiler. Direct
`runtime/js/test-apply.mjs` and `test.mjs` against `BEND_JS_RUNTIME` remain cheap
pre-build rejection controls. `test-phase8.mjs` does not accept that override,
so do not accidentally attribute its installed-runtime result to a prototype.

## Final maintained and backend gates

Reconcile selected source and host tools before maintained qualification.
`qualify.py` requires the live compiler manifest and named host tools to equal
the frozen selected snapshot; retain this assertion. It owns its guard.

```sh
python3 selfhost/tools/performance/phase47/qualify.py \
  "$P51_ATTEMPT" "$P51_Q/maintained8"
taskset -c 0 python3 selfhost/tools/performance/phase51/backend-plan.py \
  "$P51_ATTEMPT" "$P51_Q/backend"
python3 selfhost/tools/performance/phase46/job.py \
  --out "$P51_Q/job-backend81" --seconds 930 -- \
  python3 selfhost/build/phase43/integration01/final-plan/tools/backend-run.py \
  "$P51_Q/backend/pilot.json"
```

`backend-plan.py` changes only output confinement/receipt attribution to Phase51
and pins its frozen Phase48 method. It preserves all inherited historical inputs,
the seven batches, expected outcomes, runner, deadlines and selected-image audit.
The runner SHA is
`739a392b91dd2566169f8cdb516276610f9a75e6fb7afac212a19a8ef87fcc0d`;
the parent planner SHA is
`815f82b615d2350e1eceb1f34e1e011c415ead4ddb79a50df59ba3c950d542fa`.
No output is written into closed Phase43/45/48 raw directories.

Require backend `complete` and `agreementComplete`, 81 rows, no unexecuted or
incomplete-batch rows, and individual historical agreement. Four shared failures
are not successes. Maintained8 historically took about10s and backend81 about266s;
these are planning measurements, not new Phase51 results. The focused fixtures
add four acquisitions and four small controllers, not a whole Phase48 rerun.

Performance selection, one final full45 comparison, installation, all42 ordinary
and relocated CLI checks, portable replay and protected103 verification remain
separate release gates. Reuse the unchanged installer and parameterized Phase47
installed-receipt tool; no new frontend, fixed-point or general native/GPU claim
follows from these bounded JS qualifications.

## Executed qualification and isolated native recovery

`qualification02` passed all four acquisitions, four focused controllers and
maintained8. Its backend run retained 81 pairwise-exact rows, but the final native
batch had 17 matching `spawnSync .../clang-16 EPERM` compile failures. Pairwise
agreement was insufficient: those failures differed from the historical expected
outcomes, so both the original backend and queue receipts correctly remain failed.

Root reran only that final 21-case native batch with the same pinned census tool,
inputs and resource guard under the approved execution environment. The fresh
`native-retry01` batch passed. The reviewed [data-only join](join-backend-native.py)
recomputed the frozen runner's six-field historical comparison over the original
60 accepted outcomes plus the fresh 21 native outcomes. It did not execute tests,
repeat the first 60 cases, or overwrite either failed receipt.

`selfhost/build/phase51/semantic-qualification01.json` is complete with exact
historical agreement for **81 outcomes: 69 execution passes, eight not applicable
and four shared failures**. It resolves all 11 queue entries using ten previously
successful entries and this explicitly recovered backend result; it does not
describe 81 fresh executions. Its SHA-256 is
`ee1cb09a96e1bf43c6a47c426e7461ad40a9c017bd6c54652a651a1ff2e75389`.
All 2,453 pinned inputs were unchanged. Original affinity-setup and native sandbox
failures remain preserved. Performance and installation are still separate gates.

The consumed join invocation was:

```sh
taskset -c 0 python3 selfhost/tools/performance/phase51/join-backend-native.py \
  selfhost/build/phase51/qualification02/backend/pilot.json \
  selfhost/build/phase51/qualification02/backend/pilot/report.json \
  selfhost/build/phase51/native-retry01/report.json \
  selfhost/build/phase51/job-native-retry01/process.json \
  selfhost/build/phase51/semantic-qualification01.json
```

This is a historical reproduction command, not permission to overwrite its output.
The join's `compilerExecuted:false` describes the receipt producer only; the
original and retry execution receipts identify the actual prior target jobs.
