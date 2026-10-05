# Phase48 validation and fast iteration

Start from installed Phase47 array06, not worker23. Root alone runs compiler,
generated-program and timing jobs. Agents author source, independent controls and
reviewed tools. No Phase45/46/47 raw directory or consumed tool is writable scratch.
This plan reuses the maintained checked workflow, benchmark protocol and eight
semantic suites; it does not introduce a new qualification framework.

| Starting identity | SHA-256 |
| --- | --- |
| array06 API | `28f9eb983b2ba3603a9af703d832d4a301efe32182b468e090db6b728a47d12f` |
| array06 runtime | `880bce50e3194b9ee9d99bd57c18ef88bcb8925d9d1668dec6765040a4d3219b` |
| Phase47 current manifest | `c608b2259502e2a151a8a5286b0761f6c9836110eafd918f8b8344266ceb3483` |
| Phase47 baseline/reference manifest | `56288e187fca3bb2bb3beabaae06a28aae3143a51ffe439a3b3f20ba97e1f0ed` |
| Unchanged 45-point catalog | `33e353f51d1c90d27ff05dd2051dfccbefb23e29cfd73d7839b4cb1d42690b1c` |

Upstream remains `018751270e800bc222a93dad7f257083ee53a5f7`. Both API and runtime
are required: equal API bytes do not establish equal generated code when the
runtime changes. Old ratios are context; every candidate timing uses freshly
paired array06 and TypeScript samples.

## Baseline without recompilation

The [small factory](../../selfhost/tools/performance/phase48/baseline-method.py)
preserves the reviewed [Phase47 packer](../../selfhost/tools/performance/phase47/freeze-baseline.py)
and derives only current labels, parent attribution and its import-directory
anchor. Archive construction, checked bundle loading, all 45 module checks and
reopening remain unchanged. Keep the derivation directory with the campaign.
Root may execute these data-only commands on CPU0 while no timing is active:

```sh
taskset -c 0 python3 selfhost/tools/performance/phase48/baseline-method.py \
  --out selfhost/build/phase48/baseline-method01
taskset -c 0 python3 selfhost/build/phase48/baseline-method01/freeze-baseline.py \
  --current selfhost/tools/performance/phase47/current/manifest.json \
  --reference selfhost/tools/performance/phase47/baseline/manifest.json \
  --catalog selfhost/tools/performance/phase37/catalog.json \
  --out selfhost/build/phase48/baseline \
  --expected-api 28f9eb983b2ba3603a9af703d832d4a301efe32182b468e090db6b728a47d12f \
  --expected-runtime 880bce50e3194b9ee9d99bd57c18ef88bcb8925d9d1668dec6765040a4d3219b
```

This relabels array06's candidate role as baseline, retaining exact TypeScript
modules from the Phase47 reference. It does not compile or execute a program.
The predecessor manifest, archives and provenance remain byte-identical.
New output directories are mandatory.

For an optional baseline-only smoke, omit the candidate argument:

```sh
python3 selfhost/tools/performance/programs/run.py \
  --catalog selfhost/tools/performance/phase37/catalog.json \
  --baseline selfhost/build/phase48/baseline/manifest.json \
  --node /home/ai/.nvm/versions/node/v24.18.0/bin/node \
  --cpu 3 --rss-mib 2048 --available-mib 4096 \
  --budget 20 --cases local-fold,scalar-region-0,complete-generic-row32 \
  --out selfhost/build/phase48/baseline-smoke01
```

This requires 18 samples if complete, not 27: only baseline and TypeScript run.
Use `--plan` without `--out` for a data-only input/protocol check. Skip the extra
timed smoke when a candidate is ready: its paired screen already remeasures both
reference roles, so another baseline run adds no denominator evidence.

## Isolate each candidate before building

The [snapshot factory](../../selfhost/tools/performance/phase48/snapshot-candidate.py)
copies only `src`, `tools` and `tests` from a frozen checked attempt. Apply an
explicit file list; never sweep an actively edited live source tree. New modules
require an explicitly authored `src/compiler.json` overlay in the intended order.
The factory records parent and overlay hashes, validates copied files and writes
a strict checked configuration. Root can use this pattern after owner review:

```sh
python3 selfhost/tools/performance/phase48/snapshot-candidate.py \
  --baseline-attempt selfhost/build/phase47/checked-array06 \
  --out selfhost/build/phase48/source-CANDIDATE01 \
  --config selfhost/build/phase48/config-CANDIDATE01.json \
  --overlay src/back/js/CHANGED.bend=PATH_TO_REVIEWED_FILE
python3 selfhost/tools/performance/phase46/job.py \
  --out selfhost/build/phase48/job-build-CANDIDATE01 --seconds 180 \
  -- /home/ai/.nvm/versions/node/v24.18.0/bin/node \
  --stack-size=4096 --max-old-space-size=1024 \
  selfhost/tools/development/workflow.mjs run \
  selfhost/build/phase48/config-CANDIDATE01.json \
  selfhost/build/phase48/checked-CANDIDATE01
```

Replace the illustrative overlay with actual files; repeat `--overlay` for each
reviewed source/runtime/manifest change. The baseline can be a later fully frozen
checked attempt when testing a composed candidate. A new source change requires
a new attempt. A fixture-only change may reuse the verified attempt through a
fresh acquisition or `workflow.mjs validate` output. An incomplete checked build
cannot serve as a candidate.

The unchanged [Phase46 job wrapper](../../selfhost/tools/performance/phase46/job.py)
is the sole process-tree guard for a raw build or individual Node controller.
It adds CPU3 and enforces 2 GiB RSS and 4 GiB available-memory floor; the command
supplies the 1 GiB Node heap. Its polling ceiling is not a cgroup hard limit.
The workflow adds checked-source/typed/equality provenance and the focused strict
gate. Preserve failure logs; do not retry the same failure without a concrete
correction or an external cause.

## Acquire once, then screen the emitted code

For a candidate affecting the core paths and large outliers, acquire the union
of core8 and the three additional outliers once. This avoids redundant source
compilation across timing profiles:

```sh
python3 selfhost/tools/performance/programs/prepare.py \
  --catalog selfhost/tools/performance/phase37/catalog.json \
  --attempt selfhost/build/phase48/checked-CANDIDATE01 \
  --cases local-pair,local-fold,scalar-region-0,scalar-region-8192,complete-generic-row32,mandelbrot,editdist,test-rle-roundtrip,test-morning-program,test-map-set-ops,test-evening-program \
  --node /home/ai/.nvm/versions/node/v24.18.0/bin/node \
  --cpu 3 --heap-mib 1024 --rss-mib 2048 --available-mib 4096 --timeout 180 \
  --out selfhost/build/phase48/acquired-CANDIDATE01
```

For the first discriminating hypothesis, a smaller affected selection is fine.
Do not repeatedly acquire all 23 sources before there is a checked semantic and
mechanism signal. Compilation is excluded from execution timing.

The [profile selections](../../selfhost/tools/performance/phase48/profiles.json)
refer to the unchanged catalog, not a rewritten benchmark suite:

| Profile | Preset | Cases | Use |
| --- | ---: | ---: | --- |
| reject3 | 20s | 3 | First rejection on fold, scalar-zero and complete public row. |
| fast5 | 60s | 5 | Existing canaries; insufficient by itself for private composition. |
| core8 | 60s | 8 | Default useful-candidate screen, including positive private-tree edit distance. |
| worst6 | 60s | 6 | Morning, scalar-zero, MapSet, RLE, generic-row, evening. |
| worst-extra3 | 60s | 3 | After core8, run only morning, MapSet and evening; the other three already ran. |

The worst six measured approximately 49.8–61.3× TypeScript in the final Phase47
run. They are targeted development cases, not a representative average or an
untouched holdout. RLE already uses workers; a high ratio does not prove fallback.
The three extra cases avoid repeating overlapping core8 points.

```sh
run48() {
  python3 selfhost/tools/performance/programs/run.py \
    --catalog selfhost/tools/performance/phase37/catalog.json \
    --baseline selfhost/build/phase48/baseline/manifest.json \
    --candidate selfhost/build/phase48/acquired-CANDIDATE01/manifest.json \
    --node /home/ai/.nvm/versions/node/v24.18.0/bin/node \
    --cpu 3 --rss-mib 2048 --available-mib 4096 "$@"
}
run48 --budget 20 --cases local-fold,scalar-region-0,complete-generic-row32 \
  --out selfhost/build/phase48/reject-CANDIDATE01
run48 --budget 60 --set core --out selfhost/build/phase48/core-CANDIDATE01
run48 --budget 60 --cases test-morning-program,test-map-set-ops,test-evening-program \
  --out selfhost/build/phase48/worst-extra-CANDIDATE01
```

These are selectable gates, not a requirement to run every profile for every
edit. A focused negative signal should stop that experiment early. When only the
outliers are affected, use the `worst6` list directly. The presets govern rounds,
warmup and target windows; neither core8 nor worst6 is guaranteed to finish within
60 seconds. Incomplete rounds provide no comparison. No profiles, compiler jobs
or compression run concurrently with timing.

`prepare.py`, `run.py` and `phase47/qualify.py` already own the shared guard:
**never wrap them in `job.py` or another ExecutionGuard**. Fresh output paths
remain mandatory even after failure. Use separate diagnostic budgets only after
an unexplained result merits them; instrumented derivatives are never timing inputs.

## Independent semantics and actual activation

The [review contract](../../design/phase48/review-contract.md) governs these
parallel authoring lanes. Fixture/controller owners provide frozen paths and
reviewed argument vectors before root acquires or executes them:

| Owner / mechanism | Required discriminators |
| --- | --- |
| Callbacks / finite functions | Independent renamed factories, captures and helper flow; selected private calls, mutation/refusal, argument order, partial/overapplication, delayed demand and reentry. |
| IR / aggregate transport | Actual changed call-return transport, not only entry selection; persistent tails read twice, alias identity, branch returns, ignored-field errors and order, recursion/reentry and independent Map/record shape. |
| Lowering / typed arrays | U32 and F32, get/set/swap/size, aliases and operand order; conversion count, rounding, signed zero/NaN where observable, full host guards and changed-hook refusal. |
| Tree / composite adapters | Aliased materialization, multiple containers, escaping storage and observations of every public field; private body activation and exact fallback. |
| Products / entry profitability | Independent short/long points, unchanged host-event/descriptor behavior and semantic results, selected admission plus refusal; distinguish costs from workload-name recognition. |

No duplicate fixtures are commissioned here: lowering owns its array-effects
fixture/catalog/controller, IR owns aggregate controls, and the other owners
coordinate their controls with review. Sources must mix unrelated names and
features. Compare the actual array06 baseline with the candidate on clean results
and public event sequences; use TypeScript only on compatible typed interfaces.
Independent iterative expected values protect against shared compiler mistakes.

Every positive mechanism needs a separately saved, parsed counter derivative
proving the intended private closure/call/return path executes. Negative public,
host-mutation or opaque cases must demonstrate refusal where the contract requires
it. Preserve errors, ignored effects, callback order, aliases, partial calls and
reentry. Presence of a source marker or output agreement alone is insufficient.

Historical controller compatibility must be checked before reuse. In particular,
Phase47 tree v4 requires a baseline *before* raw-tree composition; array06 cannot
satisfy that assertion. Either retain its exact historical array04 fixture as the
declared predecessor or author a reviewed versioned successor for array06. Never
weaken consumed assertions silently. A deliberate profitability change may also
require a new positive activation fixture rather than old constant entry counts.

## Final gates once, after candidate selection

Run the unchanged eight-suite gate against the integrated checked winner, with
current `selfhost/src/compiler.json` and host tools matching its frozen manifest:

```sh
python3 selfhost/tools/performance/phase47/qualify.py \
  selfhost/build/phase48/checked-SELECTED \
  selfhost/build/phase48/qualify-SELECTED
```

Its historical `phase47` receipt kind names the retained method. Exact attempt,
API, runtime, Base, driver and Node identities establish the actual Phase48
execution. Preserve all eight suites and their observations; do not duplicate
them for every oracle point. Rerun an earlier subset only for a material uncovered
risk or a new source change. Counts and contracts are in the
[retained gate guide](../phase47/qualification-plan.md).

Only then acquire all 45 selected points with `prepare.py --set full`, and run
three disjoint 15-point batches using the unchanged 600 preset. Reuse the full
commands in the [portable guide](../../selfhost/tools/performance/phase47/README.md#full45-comparison-and-diagnostics)
with Phase48 manifests and fresh output directories. Summarize them with unchanged
`phase44/summarize-runtime.py`. The complete protocol requires 669 fresh samples
across three roles; it cannot fit one 600-second campaign. Aim for one full run
of the selected release. If it finds a material regression, preserve that failure
and correct/requalify it; the one-run aim does not authorize hiding a failure.

Run compiler-request cost separately on affected and unaffected sources, once
the selected API is stable. No program runtime result establishes compiler speed.
Standard `release.mjs --install-attempt`, `--verify`, the retained 42-check CLI
runner and a portable replay follow selection, with exact runtime/source joins.
No new full frontend or fixed-point claim follows from these backend gates.

### Integrated mechanism mapping

Use the selected checked image for each fresh candidate acquisition. Reuse a
baseline only when its source/catalog bytes and actual array06 API **and runtime**
match the intended comparison. The exception is the deliberately older tree-v4
predecessor below. A prior isolated candidate's PASS does not qualify a changed
integrated emitter. Root selects the reviewed controller version before execution;
the table records interfaces and obligations, not unexecuted PASS claims.

| Change | Independent gate and interpretation |
| --- | --- |
| Aggregate argument/result transport (V) | [JW values control](../../selfhost/tools/performance/phase48/controls/jw-values-controls-v1.mjs), plus [aggregate source control](../../selfhost/tools/performance/phase48/controls/aggregate-transport-controls-v1.mjs). The first calls the actual checked `jw_values_functions` pass through one appended diagnostic export. It interprets `JWCallValues`/`JWReturnValues` independently, checks explicit values/events/aliases and counts logical tuple shells. The source gate separately checks real emission, recursive caller state, persistent children, field demand, errors, public mutation and reentry. Neither replaces the other. |
| Finite function flow (H) | Fresh selected acquisition of the reviewed `function-flow` catalog and its owner's final controller: factory/capture flow, callback demand/order, partial calls, identity and host refusal. Fixture v1/v2 are distinct identities; use the reviewed matching cohort. Do not infer general closure support from scalar output agreement. |
| Typed-array operations (A) | [Array effects](../../selfhost/tools/performance/phase48/controls/array-effects-controls-v1.mjs) and, if literal lowering is selected, [Array literals](../../selfhost/tools/performance/phase48/controls/array-literals-controls-v1.mjs). Include F32 rounding/NaN/signed zero, conversion counts, swaps, aliases, error identity and executed private-path witnesses. |
| Public composite results (R) | Reviewed [composite v3](../../selfhost/tools/performance/phase48/controls/composite-results-v3.mjs) against array06: every field/backing array, freshness, intentional aliases, mutations and actual materialization/fallback counters. Earlier v1/v2 results remain historical. |
| Native value lowering | [Native String controls](../../selfhost/tools/performance/phase48/controls/native-values-v1.mjs) only when that production change is selected. Its baseline deliberately has no private String-append sites. The saved numeric-constant ablation controller is a finite diagnostic experiment, **not** qualification of general native arithmetic or mutable Number/BigInt hooks. |
| Entry profitability | The owner's exact checked guard controls, including short-fold128 and zero-trip boundaries alongside a larger affected case. Saved-JS ablation timing does not qualify production guard changes. Preserve descriptor/raw-code/bounce demand and host/reflection reentry. |

The JW control has 26 synthetic graphs. Its positive examples require both a
changed IR mechanism and fewer logical source-tuple allocations where specified;
matching answers from an inactive pass cannot pass those activation assertions.
Its explicit effects/identity oracles do not assume that an unused tuple field is
pure. Public entry parameters/results remain materialized. Invalid-function and
97-function bounds are checked, but the pass trusts compiler-produced typed JW:
this is not a new universal malformed-IR verifier. Interpreter depth is bounded;
real native/machine depth and exception unwinding belong to source controls.
The branch-join case with instructions after `JWCase` is a deliberately
noncanonical conservative fact/refusal control; the production emitter's cases
are terminal, so that case supplies no production-emitter evidence.

Run a standalone controller through the existing supervisor, for example:

```sh
python3 selfhost/tools/performance/phase46/job.py \
  --out selfhost/build/phase48/job-jw-values-SELECTED --seconds 120 -- \
  /home/ai/.nvm/versions/node/v24.18.0/bin/node \
  --stack-size=4096 --max-old-space-size=1024 \
  selfhost/tools/performance/phase48/controls/jw-values-controls-v1.mjs \
  selfhost/build/phase48/checked-SELECTED \
  selfhost/build/phase48/jw-values-SELECTED
```

The aggregate, array-effects and composite controllers instead take
`BASELINE_MODULE CANDIDATE_MODULE FRESH_OUTPUT_DIRECTORY`. Their acquisition
receipts must match the exact source/catalog. Keep output equality from clean
modules separate from diagnostic activation counters. Check each controller's
actual `pass`/`passed` report field as well as process exit; do not rename report
schemas to fit an imagined common interface. This wrapper is for standalone
controllers only, never `prepare.py`, `run.py` or `qualify.py`.

The prior Array regression controls retain these exact predecessor choices:

| Retained controller | Baseline module under `selfhost/build/phase47/` | Why retain it |
| --- | --- | --- |
| `array-view-controls-v2.mjs` | `array-controls-baseline01/modules/array-view-v1.mjs` | Original 24-oracle/39-boundary private-layout contract. |
| `array-layout-controls-v3.mjs` | `layout-controls-baseline03/modules/array-layout-v3.mjs` | Original 77 scalar/56 public-state/7 order observations plus activation. |
| `array-tree-controls-v4.mjs` | `tree-controls-baseline04/modules/array-tree-v4.mjs` | Baseline must contain the old scalar-tree plan and **must not** contain raw-tree composition; array06 is incompatible with that assertion. |
| `array-integer-guard-controls-v5.mjs` | `integer-controls-baseline05/modules/array-integer-guard-v5.mjs` | Original integer/floating guard separation,153 oracles/46 boundaries and activation. |

These preserve earlier feature contracts; they are not four fresh array06 causal
comparisons. Acquire their candidate counterparts once from the integrated winner
if the changed paths overlap. Avoid rerunning unrelated source controls merely
because an old directory exists. If the new transformation intentionally replaces
an old mechanism, require a reviewed versioned control with the same observable
semantics and a positive witness for the replacement.

For integrated H/V or broad native emission changes, run the retained **81-outcome
backend census once** after focused controls and the eight suites. Rebind the
historical `phase43/integration01/final-plan/tools/backend-run.py` pilot to fresh
Phase48 outputs and the exact selected attempt/API/runtime; preserve its historical
row oracle. The Phase45 selected census took about269 seconds, so it is a final
gate, not an edit loop. Its expected classification is69 passing,8 not-applicable
and4 shared failures; describing that as81 passing would be incorrect. Unchanged
frontend checking does not require repeating3026+196 frontend cases here. Report
any remaining backend exclusions explicitly and keep the installed/42-CLI gates
as separate release checks.

Root checks the original 103-file inventory before work and before final staging
using `phase42/validation/check-protected-v1.py` and read-only
`selfhost/build/phase45/protected-start.json`; outputs belong under Phase48.
Keep the closed [Phase47 evidence](../../selfhost/tools/performance/phase47/evidence/README.md)
and Phase45/46 capsules unchanged. Record commands, source/API/runtime identities,
durations, failures and decisions as work completes; do not infer waiting time
from aggregate wall time. No target job or raw acquisition was run while authoring
this plan.
