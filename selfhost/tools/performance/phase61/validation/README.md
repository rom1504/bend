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
