# Phase48 validation and fast iteration

## Completed RNFA04 qualification

RNFA04 is the installed, qualified Phase48 compiler. The published
[selected qualification](../../selfhost/tools/performance/phase48/evidence/selected-qualification.json)
joins the completed semantic, execution, compiler-request, installation and
portable-replay evidence for one exact checked B1 derivative. It is not a new
self-hosted fixed point.

| Gate | Completed result and scope |
| --- | --- |
| [Semantic qualification](../../selfhost/tools/performance/phase48/evidence/semantic-qualification.json) | All 28 planned entries resolved. One entry explicitly reuses the earlier **same RNFA04 image** count-control execution: 43 value cases, 13 boundaries and 56 activation/refusal observations. It is not claimed as a second execution. The other 27 entries completed in the final queue, including acquisition and data-only preparation jobs. |
| Maintained suites | All eight passed on RNFA04 after source reconciliation. |
| Backend inventory | Exact agreement for all 81 historical outcomes: **69 execution passes, eight not applicable and four shared failures**. This does not mean 81 passing tests or full backend conformance. |
| [Source reconciliation](../../selfhost/tools/performance/phase48/evidence/source-reconciliation.json) | All 188 selected source files match the checked snapshot; 16 preimages were preserved before 13 replacements and three deferred H/V removals. The final compiler manifest has 92 modules. |
| Full generated-program comparison | All 45 points across 23 sources completed, with 669 samples across candidate, array06 baseline and pinned TypeScript, and passing output checks. |
| Compiler-request comparison | All 18 checked requests completed with output agreement. This separately measures compiler work; disk Base-cache priming is excluded. |
| [Installed release](../../selfhost/tools/performance/phase48/evidence/installed-release.json) | Installation and verification passed; all **42 ordinary/relocated CLI checks** passed on the exact installed image. |
| Portable replay | All three selected cases passed across all three roles, with 27 fresh samples. The nominal 20-second profile completed in 10.0622 seconds; the preset is not a hard deadline. |
| [Protected files](../../selfhost/tools/performance/phase48/evidence/protected-final.json) | All 103 starting files remain unchanged, with no protected path staged. |

The full comparison's point-weighted candidate/TypeScript geometric mean is
**2.67894×**, against **2.90244×** for the freshly measured array06 baseline.
The equal-source ratios are **3.67925×** and **3.97892×**, respectively. There
were 23 lower and 22 higher candidate medians, so aggregate improvement does
not imply every program improved. The [published selection receipt](../../selfhost/tools/performance/phase48/evidence/selected-qualification.json)
binds the underlying runtime, 18-request cost and portable-smoke reports;
these are distinct measurements, not extra semantic-test counts.

| Selected identity | SHA-256 |
| --- | --- |
| Checked RNFA04 attempt | `59dd57e733b27de66db5ef85181c1303ade7cbf6cb9f7430d49e283d00853764` |
| Assembled compiler source | `bb98f20f281b1a0cfa7171afd3e2f8d5977f0391a3edcc222add3d9d1c574283` |
| Installed equality API | `6f9d111aa68c19f3ce45b80785621d57c4d10efb12d50164f5cb0597bc952100` |
| Runtime | `880bce50e3194b9ee9d99bd57c18ef88bcb8925d9d1668dec6765040a4d3219b` |

Counts overlap and should not be summed into one conformance total. Frontend
3026/196 evidence remains historical; this phase makes no new proof-validity,
broad GPU or fixed-point claim, and native `IO.args` remains unresolved.
The earlier semantic receipt deliberately retains its then-unjoined release
slots; the later selected and installed receipts above establish completion.
Archive closure and campaign accounting are separate evidence.

The qualified source's trailing blank line was retained. The final whitespace
check passed with `git -c core.whitespace=-blank-at-eof diff --check`; source
formatting was not changed after qualification to satisfy a cosmetic check.

## Historical starting point and working plan

The remainder preserves the original plan, intermediate RNFA03 observations,
failed controls and diagnostic experiments. Its prospective commands and pending
statuses describe those earlier checkpoints, not unfinished RNFA04 release work.
Consumed outputs must remain intact; reruns require fresh output paths.

The campaign started from installed Phase47 array06, not worker23. Root alone runs compiler,
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
| Aggregate argument/result transport (V) | [JW values v2](../../selfhost/tools/performance/phase48/controls/jw-values-controls-v2.mjs), plus the matching reviewed [aggregate source v3](../../selfhost/tools/performance/phase48/controls/aggregate-transport-controls-v3.mjs). The first calls the actual checked `jw_values_functions` pass through one appended diagnostic export. It interprets `JWCallValues`/`JWReturnValues` independently, checks explicit values/events/aliases and counts logical tuple shells. The source gate separately checks real emission, recursive caller state, persistent children, field demand, errors, public mutation and reentry. Neither replaces the actual-emission control below. |
| Finite function flow (H) | Fresh selected acquisition of the reviewed `function-flow` catalog and its owner's final controller: factory/capture flow, callback demand/order, partial calls, identity and host refusal. Fixture v1/v2 are distinct identities; use the reviewed matching cohort. Do not infer general closure support from scalar output agreement. |
| Typed-array operations (A) | [Array effects v3](../../selfhost/tools/performance/phase48/controls/array-effects-controls-v3.mjs), using source/catalog v2, and, if literal lowering is selected, [Array literals](../../selfhost/tools/performance/phase48/controls/array-literals-controls-v1.mjs). Include F32 rounding/NaN/signed zero, conversion counts, swaps, aliases, error identity and executed private-path witnesses. Effects v3 adds the late Array.fill helper-mutation contract; retain earlier versions and use this gate with the matching guard fix. |
| Public composite results (R) | Reviewed [composite v3](../../selfhost/tools/performance/phase48/controls/composite-results-v3.mjs) against array06: every field/backing array, freshness, intentional aliases, mutations and actual materialization/fallback counters. Earlier v1/v2 results remain historical. |
| Native value lowering | [Native String controls](../../selfhost/tools/performance/phase48/controls/native-values-v1.mjs) only when that production change is selected. Its baseline deliberately has no private String-append sites. The saved numeric-constant ablation controller is a finite diagnostic experiment, **not** qualification of general native arithmetic or mutable Number/BigInt hooks. |
| Finite F32 literals | [Production-source v2](../../selfhost/tools/performance/phase48/controls/private-float-controls-v2.mjs) plus [checked literal-bit control](../../selfhost/tools/performance/phase48/controls/private-float-ir-v1.mjs). The latter covers22 authentic payloads including signed zero, subnormals, largest finite values and exact Inf/NaN refusal, plus4 type/nonliteral refusals. Its DataView oracle checks numeric values and retained buffer bits; detached buffers must still throw. It supplies no public-guard claim, which remains the source controller's separate obligation. |
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

The first v1 run exposed precisely that conservative branch-join failure; retain
its unchanged controller and failed receipt. The separate
[`jw-values-controls-v2.mjs`](../../selfhost/tools/performance/phase48/controls/jw-values-controls-v2.mjs)
keeps all26 graphs and assertions and collects every case failure in one run,
returning a failing exit if any case fails. This avoids repeated whole-controller
invocations to uncover one failure at a time. It does not relax the failed case.

The additional [actual-emission control](../../selfhost/tools/performance/phase48/controls/jw-values-emission-v1.mjs)
takes the same `CHECKED_ATTEMPT NEW_OUT` arguments. It calls both real checked
passes and executes canonical same-SCC recursive producers returning two and four
scalar values. Independent arithmetic oracles cover depths0/1/31/32/40/513 and
both pair branches. A separately parsed derivative demonstrates native calls,
machine fallback, suspended caller frames, return-register commit/capture and
balanced budget restoration. Genuine emitted `JWImpossible` errors and a
controlled global-value callback exercise reentry at exhausted budget, followed
by a normal replay. If the emitter clears captured return registers, the control
also checks that none remains retained after return/error/replay. It preserves
the unmodified emitted text separately from diagnostic counters and exposes no
new production ABI. These injected private dependencies test protocol mechanics;
they do not establish public source admission or mutable-host equivalence.

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

The Array-effects source's initial acquisition exposed a parser restriction;
the reviewed matching successor is `array-effects-v2.bend`,
`array-effects-catalog-v2.json` and `array-effects-controls-v2.mjs`. Retain v1
as the failed preparation's exact historical input, not as a passing source gate.

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

The [backend-plan factory](../../selfhost/tools/performance/phase48/backend-plan.py)
is a data-only subset of the prior final-config preparation. It preserves and
rechecks the entire historical pilot input set and exact expected rows, binds the
selected checked attempt/runtime/snapshot and focused PASS, and changes only the
selected attempt and fresh batch destinations. It does not recreate frontend
layouts or execute the census. The runner and helper remain byte-identical to the
retained Phase43 methods. Root's commands are:

```sh
python3 selfhost/tools/performance/phase48/backend-plan.py \
  selfhost/build/phase48/checked-SELECTED \
  selfhost/build/phase48/backend-SELECTED
python3 selfhost/tools/performance/phase46/job.py \
  --out selfhost/build/phase48/job-backend-SELECTED --seconds 930 -- \
  python3 selfhost/build/phase43/integration01/final-plan/tools/backend-run.py \
  selfhost/build/phase48/backend-SELECTED/pilot.json
```

Here the outer job owns the single ExecutionGuard; the historical backend runner
does not acquire it. The campaign keeps its900-second internal deadline and
three-second termination grace; the outer930 seconds allow final receipt writes.
Seven one-worker batches use checked snapshot adapters and the pinned native
toolchain, with 1GiB per-worker heap and CPU3. The supervisor enforces the current
2GiB process-tree RSS ceiling and4GiB available-memory floor. Require outer
successful completion and inner `complete:true`, `agreementComplete:true`,81 exact
accepted outcomes with no unexecuted/incomplete rows. The original selected output
trees are packed and rehashed by the unchanged helper; that compression is inside
this semantic campaign and must not overlap any timing campaign.

The selected compiler request recipe is documented separately in
[compiler-cost-plan.md](compiler-cost-plan.md). Its planner/measurement own the
shared guard themselves, so the backend launch pattern must not be copied onto
those commands.

Root checks the original 103-file inventory before work and before final staging
using `phase42/validation/check-protected-v1.py` and read-only
`selfhost/build/phase45/protected-start.json`; outputs belong under Phase48.
Keep the closed [Phase47 evidence](../../selfhost/tools/performance/phase47/evidence/README.md)
and Phase45/46 capsules unchanged. Record commands, source/API/runtime identities,
durations, failures and decisions as work completes; do not infer waiting time
from aggregate wall time. No target job or raw acquisition was run while authoring
this plan.

## Recorded isolated outcomes

These are completed root-owned tests of specific experimental checked images,
not qualification or promotion of an integrated Phase48 release. The reports,
their recorded input hashes and their actual supervisor receipts were inspected
read-only. All16 recorded inputs for the JW-emission run and all9 for the float-IR
run still matched at this readback. Their shared runtime was unchanged array06
`880bce50e3194b9ee9d99bd57c18ef88bcb8925d9d1668dec6765040a4d3219b`.

| Test | Exact outcome and execution scope |
| --- | --- |
| [`jw-emission03`](../../selfhost/build/phase48/jw-emission03/report.json) | PASS,2 canonical graphs and30 observations on checked-values03. Actual checked tuple transport and emitter; original and transformed emitted code agree with independent arithmetic. Counter derivatives prove two/four result transport, native/machine transitions, throw/reentry and cleanup. |
| [`float-ir01`](../../selfhost/build/phase48/float-ir01/report.json) | PASS,22 explicit payloads and4 non-F32/nonliteral refusals on checked-float01. Finite expressions preserve numeric values, signed zero and exact buffer bits; Inf/NaN retain the original literal and decoder; detached writes still throw. |

At depth513, each ordinary pair branch recorded32 native entries and32 restorations,
one machine entry and481 saved continuation frames. Its514 extra-result commits,
captures and clears matched; the four-result graph recorded1542 of each. Both
normal branches, global-value reentry at exhausted budget, actual emitted errors,
error-time reentry and subsequent shallow replay passed. The checked emitter had
clear sites, so all three scratch result registers were explicitly required to
be `undefined` after the initial return/error and replay. These are protocol and
state observations, not measured heap allocations or a general GC claim.

The [JW supervisor](../../selfhost/build/phase48/job-jw-emission03/process.json)
completed in3.2465 seconds and the
[float supervisor](../../selfhost/build/phase48/job-float-ir01/process.json)
in3.1428 seconds, both exit0. Both used CPU3, Node24.18.0, stack4096 and1GiB heap
under the2GiB RSS/4GiB available-memory policy. Accordingly this is **not** a
default-stack result. It also supplies no generated-program timing, public-host
equivalence, source-frontend conformance or installation claim. The independently
acquired source and integrated-release gates remain separate obligations.

Exact SHA256 bindings:

| Artifact | SHA256 |
| --- | --- |
| JW result report | `1f4fed5b1344fb47bf465600c7357cae6d3eed1e8e8f55332f83d447c3731ece` |
| JW controller | `f59e140c9836d27cc4c83e9da104ee418131592adb4f319a554124bfd71f3e9e` |
| checked-values03 attempt | `0be2459189c6df32da956e4f01b0eb6e41429b216ab3001ceba9c2db670dd6d0` |
| checked-values03 API | `af34a35a2974998b4b82c1355799b512deeb043f10aa03dae2283c95c88dccea` |
| JW supervisor receipt | `cbf54f89e59473f046310319b0c32b5135dfb4b6c952c4dcae0edabb86845bc2` |
| Float result report | `834bd33c89116eea91ed3e87bf9d48917a7ae8b03a3f02b69bdf67238c4b24e8` |
| Float controller | `013add7d88c2ab6a4c72a0dff69e0acf3a074be539bf60a3ff559e683edc5c01` |
| checked-float01 attempt | `8223196968a5a7a5d6e21d6e7f9e4a315c266b6418c1d78293e8724884bb05e8` |
| checked-float01 API | `265fb79712bef04acba399478826f09f1fff51f69ea49f846e686fb72fcb7612` |
| Float supervisor receipt | `d0823f93ff4468edcc46f8ec7523f793dee80e855c9cbb1c41c27e464edcc556` |

## Time accounting preparation

The [data-only accounting tool](../../selfhost/tools/performance/phase48/time-use.py)
reuses Phase47's timestamp and process-record readers. It scans only finished
`process.json` intervals, collapses duplicate command/start/finish copies and
counts each enclosing supervisor interval once. Embedded copies in other reports
are not summed. Where a guarded compiler build encloses its own child receipts,
the outer build owns that wall interval. Unwrapped `prepare.py`/`run.py` record
their individual guarded acquisition/timing children, which remain separately
visible when there is no enclosing supervisor receipt.

Categories are build, acquisition, control, timing, compiler cost and
qualification, plus explicit preparation/profile/release/other buckets. Partially
overlapping top-level jobs of different categories go to an `overlap-mixed`
bucket rather than being charged twice. Temporal enclosure is declared as such;
it is not proof of a PID ancestry relationship. Failures and peak RSS remain
visible for all records, while nested durations never inflate elapsed totals.

Root may create a provisional snapshot after a timing campaign finishes:

```sh
python3 selfhost/tools/performance/phase48/time-use.py \
  --out selfhost/build/phase48/time-use-snapshot01.json
```

For final accounting, pass `--end EXACT_UTC_CUTOFF` and a fresh output path only
after the recorded target work ends. The campaign start comes from Phase48's
`start.json`; an explicit cutoff alone does not establish writer closure. If a
receipt changes during collection, the output is incomplete and exits nonzero.
Review `otherRecords` and, where the command needs human interpretation, use
`--categories PREFIX_MAP.json` with explicit relative receipt-path prefixes and
one of the documented categories. Preserve that map as another input.

Report the union of recorded wall intervals separately from total campaign time.
The remainder mixes analysis, coding, review, documentation, orchestration,
unrecorded operations and possible idle time. It is not a waiting-time estimate
or an agent CPU-utilization measurement. No accounting snapshot or target job
was executed while authoring this tool; the raw campaign remains open.

## Vector transport alternative: executed private-emitter controls

The separate [vector controller](../../selfhost/tools/performance/phase48/controls/jw-values-emission-vector-v1.mjs)
preserves the scalar transport controller's two graphs and 30 independent value,
error, reentry and replay observations. It changes the protocol checks to match
actual flat-vector returns: width two/four, every index owned, one capture per
return and a fresh vector identity on each capture. Shared return registers must
be absent. These are private-emitter checks; source admission remains a separate
gate and passing does not select the alternative for release.

Root's [jw-vector01 report](../../selfhost/build/phase48/jw-vector01/report.json)
passed all two graphs and 30 observations on checked-values-vector01. At depth
513, each ordinary pair branch recorded 32 native entries/restorations, one
machine entry, 481 saved frames, 32 native vectors, 482 machine vectors and 514
captures. Throw/reentry and subsequent shallow replay retained the same semantic
oracles. All 17 recorded input identities were independently rehashed after the
run. Report SHA256 is
`3537f62013398fb0ee2ed2e5615511d13df496e3b9505be2ae95568452b6d610`;
controller SHA256 is
`e7797c1f4497605167bd0676199cbe9ff743046e77a7ba2d92a74e58c5b3880e`.
The [supervisor](../../selfhost/build/phase48/job-jw-vector01/process.json)
completed in 3.2248 seconds with a 347,029,504-byte sampled process-tree peak.
It used stack4096 and the unchanged 1GiB heap/2GiB RSS/4GiB headroom policy;
this is not a default-stack or program-speed measurement.

## Final RNFA semantic command plan

The [data-only plan writer](../../selfhost/tools/performance/phase48/final-qualification-plan.py)
accepts the final chosen checked attempt; it does not assume the latest candidate
has been selected. It writes ordered commands and expected receipt fields, and
executes nothing:

```sh
python3 selfhost/tools/performance/phase48/final-qualification-plan.py \
  selfhost/build/phase48/CHOSEN_CHECKED_ATTEMPT \
  selfhost/build/phase48/final-semantics01 \
  --program-preparation selfhost/build/phase48/CHOSEN_FULL_PREPARATION/manifest.json \
  --prior-arrays
```

Without the optional flags there are 16 serial jobs: fresh selected emissions and
controllers for composite results, String.append, finite F32, typed-array effects,
loop-qualified literal arrays and late Array.fill mutation; the internal F32
payload controller; maintained eight suites; and backend81 plan preparation/run.
The six source baselines remain the exact array06 acquisitions. The optional
`--prior-arrays` adds eight acquisition/control jobs renewing Phase47 view, layout,
tree and integer-host controls against their original predecessors. In particular,
tree-v4 retains its pre-array04 baseline rather than silently replacing that
negative-control image with array06. Optional selected full preparation binds the
actual Evening ordinary-path witness without an extra acquisition.

Root must stop after the focused controls and integrate the chosen source into
the live tree before the plan's `after-live-integration` jobs. The unchanged
maintained runner checks compiler-manifest and host-tool equality with the checked
snapshot; the plan does not bypass those assertions. Acquisition and maintained
runners already own the shared guard. Standalone Node controllers and backend81
use the existing Phase46 guard once, never a nested guard. Check every command's
exit status, report contract and exact selected attempt/API/runtime/source binding;
the JSON plan itself is not a qualification result. H/V, frontend3026, compiler
request cost, generated-program timing, installation and publication remain
separate decisions or gates.

## Renewed historical array boundaries on RNFA03

The predecessor controls exposed differences in private-entry bookkeeping under
mutable host hooks. We retained each failed run and introduced named ordinary-source
oracles instead of accepting an unexplained predecessor/candidate mismatch.

| Control | Fresh result | Explicit historical difference |
| --- | --- | --- |
| [view v4](../../selfhost/build/phase48/final-qualification03/control-prior-view-v4/report.json) | PASS: 24 value cases, 39 boundaries, four positive entries, 39 hook refusals and three public-root refusals. | `Number-getter-closed`: historical public execution reads the getter 10 times; both ordinary executions and candidate public read it eight times, all returning 9. `reflection-self-restores`: historical public triggers its mutation and five replacement-helper calls; both ordinary executions and candidate public have no hook events or mutation, all returning `[16,16]`. |
| [tree v6](../../selfhost/build/phase48/final-qualification03/control-prior-tree-v6/report.json) | PASS: 159 value cases, 11 boundaries, 30 private tree/leaf observations, ten hook refusals and public-storage refusal. | `Number-getter`: historical public execution reads the getter 69 times; both ordinary graphs and candidate public read it 67 times, all returning 1245. |

View's ordinary oracle calls the ungranted raw `bench` code. Tree requires a
different mechanism: `canopy` begins with a unary matcher, so passing four arguments
directly to its raw code does not execute the whole source function. The v6 tree
controller instead saves two diagnostic modules, each with exactly one AST-verified
change: `enterExact` passes `false` to its inner body. Public currying and every
source-body byte remain unchanged, while private-entry permission is withheld
throughout each ordinary graph. Both graphs must agree before candidate public
behavior can pass. These derivatives are parsed, hashed and checked again after
use; they are excluded from performance measurements.

The original [view run](../../selfhost/build/phase48/final-qualification03/control-prior-view/report.json)
and [tree run](../../selfhost/build/phase48/final-qualification03/control-prior-tree/report.json)
retain the getter mismatches. [View v3](../../selfhost/build/phase48/final-qualification03/control-prior-view-v3/report.json)
confirmed the Number oracle, then failed its historical expectation that the
reflection hook must mutate a helper. [Tree v5](../../selfhost/build/phase48/final-qualification03/control-prior-tree-v5/report.json)
failed because its raw unary-matcher call was an invalid ordinary-source adapter.
That was a harness error, not a compiler execution result. The successors retain
the historical traces explicitly and keep all other differential and activation
checks. These RNFA03 results do not qualify a later image automatically.

Successful view-report SHA256:
`a426ee8b6b6746ada35afb06ad61632fb0f9ff2e26e48ba237a91cb11464e1af`.
Successful tree-report SHA256:
`81e3ec16a47a9caf751d47bce3acccbafb91d8f6defeb2cc9a9a4a996c2b4991`.
