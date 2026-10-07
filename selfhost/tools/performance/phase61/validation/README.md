# Phase61 candidate validation

Root runs every compiler, generated program and benchmark serially on CPU3.
Planning, syntax inspection and report arithmetic may use CPU0. Each target has
one guard: 1 GiB Node heap, 2 GiB process-tree RSS, 4 GiB available-memory floor,
and a 4 MiB stack. Keep parent serial launchers unpinned and without another
guard; their children own the guard and affinity.

The installed baseline is genuine Phase58 `checked-last01`, API
`641381f638f1f4c1c8b349bef06502b42738c1c7feff0391f2e09b90f4ef282a`.
Its genuine B2 is `final-last01/bootstrap/full/compiler.mjs`, SHA256
`a73daccf86a807092a334d5f3121745e0b91c3054164c25462f1658644b7b081`.
All Phase58–60 raw inputs are closed. Private staging copies the ordinary
driver/runtime/API and creates fresh Phase61 caches. It never writes a checked
bootstrap sidecar for B2 or imports an old project's ordinary driver directly.

## Small candidate loop

From the repository root, materialize these reviewed methods once. This is data
transformation only; the factory records exact parent/output hashes and every
edit. Historical `phase55`, `phase56` and `phase58` report kinds identify inherited
methods. New outputs and caches are confined to Phase61.

```sh
taskset -c 0 python3 -B selfhost/tools/performance/phase61/validation/prepare-methods.py \
  --out selfhost/build/phase61/methods01
```

Once root applies the reviewed candidate source, use a fresh candidate name in
all paths below. This build retains the 36 strict workflow observations.

```sh
python3 -B selfhost/tools/performance/phase32/bounded-run.py \
  --seconds 180 --rss-mib 2048 --available-mib 4096 \
  selfhost/build/phase61/build-X-supervisor -- \
  taskset -c 3 /home/ai/.nvm/versions/node/v24.18.0/bin/node \
  --max-old-space-size=1024 --stack-size=4096 \
  selfhost/tools/development/workflow.mjs run \
  selfhost/tools/performance/phase61/validation/development-strict.json \
  selfhost/build/phase61/checked-X
```

Run the mechanism owner's independent controls next. The shared paired-fixture
emitter accepts `BASELINE_ATTEMPT CANDIDATE_ATTEMPT CATALOG FRESH_OUT`, where the
baseline is `selfhost/build/phase58/checked-last01` and the script is
`selfhost/build/phase61/methods01/qualification/paired-fixtures-v2.mjs`.
Wrap it once with the same bounded command above, usually a 180-second ceiling.
It emits checked modules only; the owner's controller separately executes
independent values/errors/order and proves the changed path activates.

The two-job generic composition gate supplements focused controls where useful:

```sh
taskset -c 0 python3 -B selfhost/build/phase61/methods01/qualification/plan.py \
  --attempt selfhost/build/phase61/checked-X --scope focused \
  --out selfhost/build/phase61/focused-X --plan selfhost/build/phase61/focused-X-plan.json
python3 -B selfhost/tools/performance/phase55/run-retention-plan.py \
  selfhost/build/phase61/focused-X-plan.json selfhost/build/phase61/focused-X-execution
```

For a candidate worth measuring as a compiler, generate its real own-source B2:

```sh
taskset -c 0 python3 -B selfhost/tools/performance/phase61/validation/prepare-candidate-v2.py \
  plan selfhost/build/phase61/checked-X selfhost/build/phase61/bootstrap-X
python3 -B selfhost/tools/performance/phase55/run-retention-plan.py \
  selfhost/build/phase61/bootstrap-X/plan.json selfhost/build/phase61/bootstrap-X-execution
```

This is six serial commands: tiny split/unsplit equality, full 77-export emission,
source/direct driver observations, data-only driver join and image pins. The
full emission alone was about 77 seconds on the prior source; the six-command
stage costs more. The prior final checked build took 57.46 seconds. These are
planning anchors, not deadlines or promises for changed source. Full emission
has a 180-second guard; each driver gate has 300 seconds. Source checking is
inherited at this point; a fresh B2 own-source check remains a separate gate.

The v2 bootstrap producer retains the exact library-decomposition and ordinary
driver checks. It additionally admits only the reviewed two-line
`jd_selected_context` body calling `book_put_many(book, defs)`, records both
bodies, and calls that actual candidate function in the split helper. The
original methods01 plan rejection is preserved. Any other interface change
still requires a specific reviewed successor.

## Selected integration only

After focused correctness and the precommitted performance decision, prepare one
final integration plan. Root reconciles the selected live source before the
maintained eight-suite gate; the existing manifest assertion stays enabled.

```sh
taskset -c 0 python3 -B selfhost/tools/performance/phase61/validation/final-plan.py \
  plan --methods selfhost/build/phase61/methods01 --attempt selfhost/build/phase61/checked-WINNER \
  --out selfhost/build/phase61/final-WINNER --plans selfhost/build/phase61/final-WINNER-plans
```

Its `index.json` gives exact root launch commands and explicit barriers. The
checked matrix retains source96, numeric34, composition18, overapplication2,
direct census26, maintained8, 23 benchmark-source acquisitions/45 value smokes
and three native C/stdout pairs. Counts overlap; known pinned TS defects remain
explicit. The native command includes the existing pinned Clang environment.

The later B2 stage freshly checks its own exact source, reproduces B3 exactly,
runs the same four independent semantic families, and freshly emits all23 raw
benchmark modules to equal selected B1 (including the observer covering45 points).
The expected `@unsafe` proof-trust failure stays distinct from successful complete
type checking; declaration counts come from the actual selected source.

Do not repeat these full matrices for each prototype. A previously generated
candidate B2 can be reused only with its exact checked-attempt/source/image pins;
the generic final plan currently creates fresh outputs and never silently reuses
an earlier candidate. Root may execute selected final stages individually.
Release preparation yields separate install/verify/legacy42/default24/verify
commands; it does not authorize installation. Preservation and closure remain
separate from semantic qualification and sampled performance.

## Framed-cache / 81-export successor

The original methods01, bootstrap-v2, v3 and all original controls remain frozen.
The state02 driver omitted the four optional exports and produced only 77; its
focused failure is retained. The corrected driver is the immutable
`../cache/typed-driver-combined03.mjs`, SHA256
`30ec69e6677a6696ca6dd4f4779560968c48d93e583b8ebf5c2d6308f75e989b`.

For this driver, the root build uses `workflow-frame01.mjs` in place of the
maintained workflow. Only static path relocation and Base-cache frame decoding
change. The selected frozen snapshot supplies `decodeBaseCacheFrame`; API,
Base, source-path/span, validator and canonical book-hash checks remain intact.
This does not mutate the maintained workflow or admit arbitrary cache bytes.

After a genuine checked attempt exists, the data-only plan command is:

```sh
taskset -c 0 python3 -B selfhost/tools/performance/phase61/validation/prepare-candidate-v4.py   plan selfhost/build/phase61/checked-state03 selfhost/build/phase61/bootstrap-state03
```

Use a fresh output. The same six serial jobs perform tiny split/unsplit equality,
full emission and eight-driver agreement before creating image pins. The full
config is now `full-roots.json`; its list comes from actual checked
`bootstrap.exports`. Admission requires all historical 77 exports in order plus
exactly `base_prefix_prepare`, `check_program_diagnostic_seed`,
`f_fresh_prefix_prepare`, and `f_graph_trace_from_prefix`. The checked bootstrap
receipt and exact selected driver are pinned; no guessed or synthetic API image
is accepted.

`setup-frame02.mjs` consumes those genuine image pins, verifies actual 81 lineage
and stages fresh private cache paths. Final cache verification uses the actual
private driver decoder. Original setup remains for earlier 77-root images.
The original `final-plan.py` is still bound to the old bootstrap/setup and must
receive an explicit successor before final qualification of a framed 81 image.
These are prepared methods, not claims that state03 or later gates have passed.

## Prepared final framed method package

The unlaunched successors `prepare-methods-frame01.py` and
`final-plan-frame01.py` preserve the existing final gates: 14 checked-B1 jobs,
six bootstrap jobs, eight B2 semantic jobs, separate whole-source type check,
fixed point and raw23/45 equality, then five release commands (42 legacy and
24 default CLI observations). The method factory copies frozen methods01 and
changes only the reviewed setup, actual-export receipt assertions, framed-cache
verification and the fixed-point scope label. Semantic oracle bodies are exact.

After root selects a useful candidate, prepare a fresh package and plan:

```sh
taskset -c 0 python3 -B selfhost/tools/performance/phase61/validation/prepare-methods-frame01.py --out selfhost/build/phase61/methods-frame01
taskset -c 0 python3 -B selfhost/tools/performance/phase61/validation/final-plan-frame01.py plan --methods selfhost/build/phase61/methods-frame01 --attempt selfhost/build/phase61/checked-WINNER --out selfhost/build/phase61/final-WINNER --plans selfhost/build/phase61/final-WINNER-plans
```

These commands prepare data only. Root launches each stage separately after its
barrier, using the exact `rootLaunch` command in the resulting index. The parent
launcher stays unpinned and has no outer execution guard; each target child owns
its single guard and CPU3 restriction. Do not run the old copied bootstrap
planner or old copied final-orchestration: final-plan-frame01 explicitly selects
the reviewed v4 producer instead.

The new optional Base/loader API roots are admitted from the actual checked
bootstrap list. Driver observations and fresh ordinary B2 source acquisitions
retain their full output checks; the focused checked-Base/loader controls stay
separate evidence. No root-count assertion of 79 was found in the maintained
suite; only the real inherited 77 assertions are adapted. No preemptive change to
maintained tests is made. JDText reach instrumentation must target the actual
rendering hook if that optional focused diagnostic is selected; changing an
unused legacy hook would not prove activation.

### Exact existing-bootstrap reuse

When the chosen attempt already has a completed genuine B2 bootstrap, append
`--bootstrap-pins selfhost/build/phase61/bootstrap-state04/image-pins.json` to the
final-plan-frame01 command (and select that exact checked-state04 attempt).
The planner joins the original attempt, B1 API, exact assembly, direct runtime,
actual 81 roots, full/tiny output and eight-driver reports. Its bootstrap stage
then runs **one data-only v4 pins revalidation**, writing fresh pins inside the
plan directory. It does not re-emit B2 or repeat the driver targets. The index
records this as `bootstrapReuse`; the original receipts remain authoritative.
Any changed attempt/source/API fails this reuse admission.

Canonical workflow/cache integration is a separate owner task before promotion.
The private prototype workflow is not a permanent replacement for normal build
entry points. The maintained full-source-preflight and development tests call
`validatedCache` synchronously; the canonical owner is preserving that API.
Current B2 construction receipts pin the original global workflow path, so make
this transition only at root's chosen provenance boundary, before the selected
new bootstrap, or with an explicit preservation/rebinding receipt. Existing
historical methods and their observed failures remain unchanged.

## Explicit export/driver admissions and frame2

The additive `workflow-frame02.mjs` prefers the selected API's `-frame2.json`
cache, then `-frame1.json`, then the legacy name. Both framed formats use the
actual frozen snapshot driver's decoder. The 36-case strict build, cache
identity/span/book checks and resource policy are unchanged. It does not
modify the maintained global workflow.

`prepare-candidate-v5.py` accepts `--admission FILE`. The pinned admission
contains an exact driver identity and supplementary exports. These supplement
the historical 77 exports and the four already-admitted Base/loader exports;
all sets must be disjoint and exactly equal the actual checked bootstrap's
exports, with historical order retained. The driver must equal the selected
snapshot byte for byte. An admission is configuration, not a checked image or
semantic certificate. The current proposed carrier admission adds five roots
for 86 total; future explicit admissions avoid changing this producer merely
to pin another reviewed driver. Tiny split/unsplit equality and the eight-driver
gate still execute for every new image.

Root commands after the actual strict checked attempt exists (replace `WINNER`
and use fresh output names):

```sh
python3 -B selfhost/tools/performance/phase61/validation/prepare-candidate-v5.py plan \
  selfhost/build/phase61/checked-WINNER selfhost/build/phase61/bootstrap-WINNER \
  --admission selfhost/tools/performance/phase61/cache/carrier-admission01.json

python3 -B selfhost/tools/performance/phase61/validation/prepare-methods-frame02.py \
  --out selfhost/build/phase61/methods-frame02
python3 -B selfhost/tools/performance/phase61/validation/final-plan-frame02.py plan \
  --methods selfhost/build/phase61/methods-frame02 \
  --attempt selfhost/build/phase61/checked-WINNER \
  --admission selfhost/tools/performance/phase61/cache/carrier-admission01.json \
  --out selfhost/build/phase61/final-WINNER \
  --plans selfhost/build/phase61/final-WINNER-plans
```

When that *same selected attempt's* bootstrap and driver gates already passed,
add `--bootstrap-pins selfhost/build/phase61/bootstrap-WINNER/image-pins.json`
to the final planner. It revalidates those exact v5 pins, source/API/runtime
and admission without repeating generation. Fresh whole-source type checking,
B2→B3 fixed point, semantic controls and raw23/45 equality remain downstream.
The parent serial launcher stays unpinned; each target owns exactly one guard.
These are prepared commands; no final gate is claimed by their existence.

## Final canonical integration order

1. Complete the selected candidate's mechanism controls and useful latency
   screen. Pilot receipts keep their original helper pins.
2. Apply the reviewed synchronous framed-cache support to the maintained
   workflow, preserving existing synchronous consumers and the exact old helper
   bytes. Freeze the selected source/driver and canonical tool. This maintenance
   is required for normal compiler development; historical pins do not prohibit it.
3. Materialize the reviewed final plan **after** that change. If earlier B2
   receipts pin the old global workflow, omit `--bootstrap-pins` and use one
   new bootstrap generation. Do not relax input checks or rewrite old receipts.
4. Root runs checked, bootstrap, B2 and release-preparation stages at their
   explicit barriers. The final release still requires semantic, emitted-program,
   performance, preservation and installed CLI admission.

For a selected unchanged `checked-state06`, the no-reuse plan command is:

```sh
taskset -c 0 python3 -B selfhost/tools/performance/phase61/validation/final-plan-frame02.py plan \
  --methods selfhost/build/phase61/methods-frame02 \
  --attempt selfhost/build/phase61/checked-state06 \
  --admission selfhost/tools/performance/phase61/cache/carrier-admission01.json \
  --out selfhost/build/phase61/final-state06 \
  --plans selfhost/build/phase61/final-state06-plans
```

Use the `rootLaunch` arrays in the new index, without a parent CPU pin or outer
guard. If source or driver changes, bind the new genuine checked attempt and
matching explicit admission, using fresh output directories. No final-state06
plan or stage has been executed merely by documenting this command.
