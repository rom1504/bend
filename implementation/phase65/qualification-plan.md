# Phase65 selected integration qualification

This is a plan, not a passing qualification receipt. Root owns all target runs.
The selected candidate is either H6 static tag readers alone, or H6 plus H2
prepared Base annotations. Rejected substitution, normalized-head, constructor
index and structured-output experiments are excluded unless separately selected.
Closed Phase64 evidence remains immutable.

## What needs fresh evidence

| Gate | H6 only | H6 + H2 |
| --- | --- | --- |
| Actual selected host helper and staged driver identity | Fresh | Fresh |
| Arena malformed-input/domain controls | Reuse exact selected 87-case H6 receipt; final host admission below | Same H6 receipt plus H2 sidecar controls |
| Full compiler source/B1/B2 semantics | Exact unchanged images permit inherited Phase64 claims | New checked B1 and genuine B2 required |
| Actual selected owned route and full output | Fresh host integration and corpus outputs | Fresh actual annotation consumption, fallback and corpus outputs |
| Self-check and B2/B3 reproduction | Not logically required for an unchanged compiler image | Required for new compiler image |
| Compiled program runtime regression | Byte-identical complete modules retain prior results for those artifacts | Same rule, after actual selected B2 byte equality |
| Final installed packaging / helper integrity | Fresh after installation | Fresh after installation |

Root selected the uniform existing checked/bootstrap/final workflow even for
H6-only. A fresh checked attempt is inexpensive and simplifies host snapshot and
release provenance. This intentionally exceeds the H6-only semantic minimum;
it avoids inventing a special release path. Generate the selected B2 once and
reuse its exact receipt for performance and final qualification.

Do not pass old Phase64 image pins as if produced by a new Phase65 attempt.
The final planner correctly requires the actual attempt, admission, producer,
source, API, roots and generation records to agree. Identical compiler bytes
alone do not justify rewriting that historical lineage.

## Frozen evidence available before integration

The selected H6 helper is
`selfhost/build/phase65/frame4-static-tags01/candidate-helper.mjs`, SHA-256
`737d1958f3e035c04a266e770a4512e37464adc559deb3dc7263bc0bc509bd46`.
Its exact 87-case domain control receipt is
`selfhost/build/phase65/frame4-static-tags01/execution/controls.json`
(`de5c9bf11e6151ec8fe44107792029556ab3aeca22ade69a3eaea184887e40ca`).
The eight-worker decoder probe and four-source/16-worker complete-output screen
are pinned by `evidence/decoder-static-tags.json` and
`evidence/host-static-tags-four.json`. These are preselection evidence; the final
snapshot helper must equal those bytes before these results transfer.

The H2 host sidecar controls passed 56 cases in
`selfhost/build/phase65/base-annotations-host-state08-01/report.json`.
They cover actual writer/reader transport with a mock semantic product. The
separate actual owned-driver controller is
`selfhost/tools/performance/phase65/base-products/annotation-controls-v2.mjs`.
It explicitly requires the qualified derived B1, compares whole annotations and
modules, requires seven real Map definition-object reuses, and checks current
stops, refusal and public fallback. Its v1 run selected the raw bootstrap API
and failed before any candidate consumption; preserve that failed run. Do not
count it as H2 semantic validation.

## Root commands and order

Run from the repository root. Set the selected state once; `state09` is the
planned H6-only integration and `state10` the optional combined integration.
Every output must be fresh. The commands below prepare data or invoke the
existing guarded launchers; do not wrap the parent launchers in another guard.

```sh
phase65_selected=state09
```

1. Freeze selected production inputs and run the checked build using the
   existing Phase65 build recipe. If H2 is selected, pass the already reviewed
   `export-additions-h2.json` to export admission; the required count becomes
   99 instead of 95. Never substitute raw `attempt.checkedApi` for qualified
   `attempt.api` / `equality/api.mjs` in semantic or timing work.

```sh
taskset -c 0 python3 -B selfhost/tools/performance/phase65/latency/build/export-admission.py admit "selfhost/build/phase65/export-${phase65_selected}"
# H2 alternative adds: --additions selfhost/build/phase65/export-additions-h2.json
taskset -c 0 python3 -B selfhost/tools/performance/phase65/latency/build/make-build.py "selfhost/build/phase65/build-${phase65_selected}" --attempt "selfhost/build/phase65/checked-${phase65_selected}"
```

Root executes that recipe's printed build command, then prepares and executes
its callable-export reference command exactly once:

```sh
taskset -c 0 python3 -B selfhost/tools/performance/phase65/latency/build/export-admission.py reference "selfhost/build/phase65/export-${phase65_selected}/admission.json" "selfhost/build/phase65/checked-${phase65_selected}" "selfhost/build/phase65/export-reference-${phase65_selected}"
```

2. Construct the selected genuine B2 once, with the existing producer. If the
   measurement owner has already constructed this exact attempt's B2, reuse
   those completed pins instead of issuing a second emission.

```sh
taskset -c 0 python3 -B selfhost/tools/performance/phase65/latency/prepare-bootstrap.py plan "selfhost/build/phase65/checked-${phase65_selected}" "selfhost/build/phase65/bootstrap-${phase65_selected}" --admission "selfhost/build/phase65/export-${phase65_selected}/admission.json"
python3 -B selfhost/tools/performance/phase55/run-retention-plan.py "selfhost/build/phase65/bootstrap-${phase65_selected}/plan.json" "selfhost/build/phase65/bootstrap-${phase65_selected}-execution"
```

3. Materialize the reviewed Phase65 qualification successor, then prepare final
   plans using those actual completed bootstrap pins. The factory preserves the
   corrected canonicalPath/bytes checks, frame1–4 recognition, original semantic
   controllers, source-backed extra roots and exact producer lineage. Factory
   preparation does not execute a compiler or admit installation.

```sh
taskset -c 0 python3 -B selfhost/tools/performance/phase65/latency/qualification/make-method.py --out selfhost/build/phase65/qualification-method01
taskset -c 0 python3 -B selfhost/build/phase65/qualification-method01/qualification/final-plan.py plan --methods selfhost/build/phase65/qualification-method01 --attempt "selfhost/build/phase65/checked-${phase65_selected}" --admission "selfhost/build/phase65/export-${phase65_selected}/admission.json" --bootstrap-pins "selfhost/build/phase65/bootstrap-${phase65_selected}/image-pins.json" --out "selfhost/build/phase65/final-${phase65_selected}" --plans "selfhost/build/phase65/final-${phase65_selected}-plans"
```

If no B2 was generated in step 2, omit `--bootstrap-pins`; the generated bootstrap
stage will construct it. Never execute both paths for the same selected image.
Root runs the three generated stage launch commands serially:

```sh
python3 -B selfhost/tools/performance/phase55/run-retention-plan.py "selfhost/build/phase65/final-${phase65_selected}-plans/checked.json" "selfhost/build/phase65/final-${phase65_selected}/checked-stage-execution"
python3 -B selfhost/tools/performance/phase55/run-retention-plan.py "selfhost/build/phase65/final-${phase65_selected}-plans/bootstrap.json" "selfhost/build/phase65/final-${phase65_selected}/bootstrap-stage-execution"
python3 -B selfhost/tools/performance/phase55/run-retention-plan.py "selfhost/build/phase65/final-${phase65_selected}-plans/b2.json" "selfhost/build/phase65/final-${phase65_selected}/b2-stage-execution"
```

The checked stage retains source96/numeric34/composition18/overapplication2,
direct26, maintained8, program45 over 23 sources and native3. The B2 stage retains
fresh source type acceptance, expected unsafe trust refusal, exact B2/B3 bytes,
source/numeric/composition/overapplication controls and all 23 complete program
modules. Type acceptance is not a mathematical proof. Maintained8 requires live
source to equal the frozen selected snapshot.

4. Add one selected host-admission run using the unchanged frozen controller.
Its output argument is explicit and may safely point to Phase65; no historical
file is edited. `phase65_driver`, `phase65_frame` and `phase65_base` must be exact
files from the selected prepared project, verified in the measurement recipe.

```sh
python3 -B selfhost/tools/performance/phase32/bounded-run.py --seconds 30 --rss-mib 2048 --available-mib 4096 "selfhost/build/phase65/final-${phase65_selected}-host-supervisor" -- taskset -c 3 /home/ai/.nvm/versions/node/v24.18.0/bin/node --stack-size=4096 --max-old-space-size=1024 selfhost/tools/performance/phase64/controls/cache-arena-v4.mjs "$phase65_driver" "$phase65_frame" "$phase65_base" "selfhost/build/phase65/final-${phase65_selected}-host/report.json"
```

Require all 79 controls, including coupled roots, optional corruption, legacy
fallback ordering, memo replacement/deletion and immutability. The H6 arena
schema and prepared-world version remain unchanged.

If H2 is retained, run the source-reviewed host sidecar controller against this
same selected driver/frame and the owned semantic controller against selected
B1. Require an additional explicit genuine-B2 successor of the owned controller:
v2 is intentionally derived-B1-only and cannot accept a swapped B2 filename.
That successor must validate actual emission/image-pins lineage and retain every
semantic assertion. The ordinary inherited final controllers exercise baseline
fallback; they do not replace proof of positive owned product consumption.

5. Run one 23-source holdout of actual selected B2 compilation with complete
module oracles, using the measurement owner's method02 recipe. Preserve both
import-inclusive and compilation-only clocks. Use the established balanced
four-source repetitions for noise checks; repeat broad samples only if a
regression or ambiguity needs resolution. H2 requires exact product sidecar
presence/absence and parent-frame digests before and after each worker, including
misses. The helper-only `host-variants-v2.py` copier omits products and therefore
must not be used to qualify H2.

No new generated-program runtime campaign is needed when each final complete
module equals its already qualified artifact. This transfers results only for
those tested modules; it is not a universal performance theorem.

6. Join closed receipts without rewriting them. Release preparation, install,
legacy42/default24, installed-helper integrity and before/after verification
remain separate root stages after compiler/host/performance admission. Preserve
previous installed files and inherited/closed evidence inventories. Do not
promote an experimental passing receipt or the factory's `executed:false` plan
into a completed qualification.
