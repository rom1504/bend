# Same-process prepared emission prototype

This adapter prepares each selected source once with a frozen checked API and
passes that immutable result to up to four explicitly named checked emitters.
All source checking, admission, lowering, x86 selection, rendering and encoding
remain in Bend. It creates no persistent plan cache and changes no compiler
source, installed image, ordinary emission method or machine oracle.

## Measured opportunity

The original six-input receipts already separate preparation from emission:

| Phase195 receipt | Base + preparation | Recorded stage total | Preparation share |
| --- | ---: | ---: | ---: |
| `budget-dev-emit01/report.json` | 31.050 s | 61.627 s | 50.38% |
| `hybrid-dev-emit01/report.json` | 32.660 s | 71.249 s | 45.84% |
| `physical-dev-emit01/report.json` | 31.350 s | 61.768 s | 50.75% |
| `selection-dev-emit01/report.json` | 31.602 s | 61.976 s | 50.99% |
| `table-dev-emit01/report.json` | 32.314 s | 63.906 s | 50.57% |

These sums exclude API loading, metadata verification, report writing and process
startup. They establish an opportunity, not a measured speedup. Across two
similar emitters, removing one preparation projects roughly 25% less combined
stage work; sharing cannot eliminate the first preparation. The graph freeze,
multiple loaded APIs, repeated pin verification and extra RSS must be measured.
No benefit is claimed for one emitter, API acquisition or native qualification.

Phase115 retained request-local immutable emission alternatives within one API
(`design/phase115/reusable-plans-and-policy-search.md`). It was not a persistent
frontend cache. The closer existing transport is
`selfhost/tests/phase181/hosted-build.mjs`: one checked API's `p169np_plan` result
feeds a separate checked x86 emitter. This prototype reuses that boundary.

## Admission and limitations

`prepare.py` uses the existing Phase147 conservative declaration extractor with
roots `p88_cache_prepare`, `p86_plan`, and `p169np_plan`. It authenticates actual
source bytes, checks every selected declaration against its manifest (including
the extractor's one-newline framing), and requires exact complete closure bytes
across producer and emitters. It does not approximate dependencies by prefixes.

Inspected Phase194 final and Phase195 selection/table/hybrid/physical/budget/
branch/sqrt APIs share 4,081 declarations, 1,367,502 bytes, SHA-256
`de1d4a0358141e8f7ec8b49fb2808984a10190548f6e2d37d54156326197c6e4`.
The checked closure has no x18/x19 functions. The input filename and contents,
Base filename/bytes, carrier, stamp, engine, assets contents and runtime are
pinned; differing locations for byte-identical asset manifests are accepted.
Future frontend or shared-preparation changes fail this identity check.

`P169Prepared` is explicitly **not a checking certificate**. Its frontend and
whole-program admission gates execute once in the producer, whose preparation
closure must exactly match every emitter. Each emitter independently executes
its original `x181_prepared` path, including existing symbol/hygiene checks,
typed sequence consumers and object encoder. This does not introduce a new
independent frontend verifier or establish a backend proof.

Before reuse, a bounded iterative traversal rejects callable, accessor, symbol,
array and non-plain record values and freezes the graph. Thus an emitter cannot
silently mutate the shared input for the next emitter. The graph is request-local;
only one case's prepared graph is retained by the driver at a time. Target-side
representation compatibility and memory consumption still need validation.

`--compare-ordinary` additionally runs each emitter's own original Base/source/
lowering preparation and requires exact complete assembly and object bytes to
match its shared-preparation outputs. This is a correctness mode, not a timing
screen. No generated program executes in this adapter. The unchanged Phase190
machine-build adapter runs independent native45 value/count oracles afterward.

Each role writes a standard `phase190-checked-native-emission` report. Its sole
emitter authority is retained directly; the pinned batch plan retains producer
and other emitter receipts. All producer source/image/dependency pins remain
in each role's inputs. Shared preparation costs appear in the batch report;
per-role `prepareSeconds=0` must never be reported as an independent cold build.

## First controlled validation

Metadata preparation runs no target and needs no compiler guard:

```sh
python3 -B selfhost/tests/phase195/prepared-emission/prepare.py \
  --producer selfhost/build/phase194/final-api01/report.json \
  --emitter baseline=selfhost/build/phase194/final-api01/report.json \
  --emitter pool=selfhost/build/phase195/pool-machine-api02/report.json \
  --cases local-pair,editdist,tree-bitonic \
  --assets selfhost/build/phase194/assets.json \
  --compare-ordinary \
  --out selfhost/build/phase195/prepared-emission-plan01.json
```

The coordinator owns execution and the lane. A proposed guarded first job is:

```sh
python3 -B selfhost/tests/phase195/job.py --rss-mib 3072 \
  prepared-emission-check01 240 64 \
  selfhost/.assets/bin/bun selfhost/tests/phase195/prepared-emission/driver.mjs \
  --plan selfhost/build/phase195/prepared-emission-plan01.json \
  --out selfhost/build/phase195/prepared-emission-check01
```

For each role, feed `<out>/<role>/report.json` to the unchanged
`selfhost/tests/phase190/build-programs.py` under its ordinary outer guard and
the same `selfhost/build/phase194/assets.json`. Keep its independent oracles.
Only after exact-byte comparisons and machine oracles pass should a fresh plan
omit `--compare-ordinary` for a six-case multi-emitter cost screen. Retain API
load, shared preparation, graph-freeze, per-emitter costs and total guarded wall
time. Preserve the normal 5 GiB reserve and all failed receipts.

Metadata checks so far: exact Phase194 final / Phase195 selection and pool
closure and asset-content identity; source/manifest/API pins; driver syntax;
stack-safe freezing of a synthetic 20,003-object graph; refusal of functions,
accessors, arrays and non-plain objects. No checked API,
generated target, archive or cleanup job was executed by the prototype author.
The coordinator subsequently ran the comparison job documented below.

The three-case baseline/pool comparison plan above has been prepared already
(244,280 bytes, SHA-256
`1965dfd60929d3a7c8e75f41330564af751f90bbb6df7353071d8737a1cc8c94`).
Use that frozen plan for the proposed job, or a fresh filename when preparing
another plan; existing metadata is never overwritten.

## First comparison result

The coordinator's `prepared-emission-check01` completed successfully. Its
authenticated summary is [validation01.json](validation01.json), including exact
batch, guard, role-report and planned build-command hashes. All three cases for
both baseline and pool matched their independently prepared ordinary path:
six complete assembly pairs and six complete object pairs. The existing
`build-programs.py` metadata admission also accepts both role reports unchanged.

| Observed stage | Seconds |
| --- | ---: |
| Shared Base | 0.604 |
| Shared source preparation, three cases | 14.583 |
| Freeze 157,593 total records | 0.108 |
| Baseline ordinary Base / source preparation | 0.482 / 12.621 |
| Pool ordinary Base / source preparation | 0.630 / 14.952 |
| Baseline shared / ordinary selection + render + encoding | 17.511 / 14.978 |
| Pool shared / ordinary selection + render + encoding | 19.348 / 16.126 |

The full guarded comparison took 113.730 s and peaked at 1,318,297,600 bytes
(1.318 GB, 1.228 GiB) tree RSS. Shared emission ran before ordinary emission;
the latter had warmed compiler code and process state. These observations must
not be treated as a controlled speed ratio or a measured fast-mode improvement.
The comparison intentionally performs extra preparation and complete emission.

The separate independent machine builds and oracles now pass for all three
cases in both roles. [validation02.json](validation02.json) pins both complete
build receipts and `prepared-build-execution01.json`. The audit reauthenticated
all build inputs/products and replayed the metadata observation check against
the existing one-repetition, zero-warmup oracle captures; it ran no programs.
The original `validation01.json` retains its earlier pending status unchanged.
Two frozen argv files used
the unchanged builder, requested fresh roots, 60 s outer guards, 50 s inner
deadlines and 96 MiB disk budgets:

- `selfhost/build/phase195/prepared-baseline-build01-argv.json`
- `selfhost/build/phase195/prepared-pool-build01-argv.json`

No further compiler or machine job was executed by this audit.

## Frozen fast batch metadata

The six cases are `local-pair,editdist,coverage-numeric-recurrence-256,
variation-ray-active-64-2440,tree-bitonic,lexer`. Frozen `prepared-fast-plan01.json`
contains the checked `rcx-api01`, `call-api01`, and `table-compose-api03` roles.
It is retained unchanged. The coordinator subsequently added checked
`adaptive-api01`; `prepared-fast-plan02.json` contains all four and has SHA-256
`037d51fd4fbb0584e56064dcd57cdd5fc422b39871d76be30740ff52836ebf51`.
Every role passed the same exact 4,081-declaration preparation identity check.

`selfhost/build/phase195/prepared-fast-steps02.json` pins the plan and argv files:

- `prepared-fast01-argv-v2.json`: plan02, output `prepared-fast01`, 240 s / 96 MiB,
  3,072 MiB RSS, no ordinary re-preparation.
- `rcx-dev-build01-argv.json`, `call-dev-build01-argv.json`,
  `compose-dev-build01-argv.json`, `adaptive-dev-build01-argv.json`: unchanged
  independent builder/oracles, corresponding fresh role roots, each 60 s outer /
  50 s inner / 96 MiB / 3,072 MiB RSS.

Build steps require their role's complete emission receipt first. These are
resource limits and execution plans, not measured costs or completed runtime
results. The coordinator owns execution; all ordinary reserve checks remain.

No `--compare-products` feature was added. When a role has existing complete
ordinary products, a metadata audit can authenticate the same API/source/Base/
assets and compare full assembly/object hashes against those frozen receipts,
without repeating compiler preparation. New emitter variants still require
their independent machine oracles. The original three-case comparison does not
claim six-case equality or cover newly acquired APIs automatically.

## Fast batch stage accounting

The coordinator's four-role `prepared-fast01` passed complete emission for all
24 case/role pairs. [validation03.json](validation03.json) authenticates the
batch, guard and all assembly/object outputs. Actual measurements are:

| Stage | Seconds |
| --- | ---: |
| Shared Base + six-source preparation | 33.726 |
| Freeze 332,290 records | 0.199 |
| rcx selection + render + encoding | 33.937 |
| call selection + render + encoding | 29.491 |
| compose selection + render + encoding | 30.091 |
| adaptive selection + render + encoding | 32.827 |
| Recorded stage total | 160.271 |
| Whole guarded job | 163.615 |

Peak tree RSS was 1,395,519,488 bytes (1.396 GB). The 3.345 s difference between
wall and recorded stages includes unseparated load, validation, file/report IO
and guard overhead.

There is no matched ordinary timing run for these four APIs. An accounting
projection holding preparation and emitter costs fixed gives 261.249 stage
seconds for four separate preparations versus 160.271 observed shared stage
seconds: 100.978 s / 38.65% less under those assumptions. Different warm/cold
process states can change that denominator; this is not an observed speedup.

## Deferred runtime preparation and combined emission

`prepare-runtime.py` is a metadata-only adaptation of the second screen's
Phase185 merge method. It refuses absent or incomplete builds immediately,
authenticates all 24 candidate oracle captures at the builder's exact point,
and requires C/QBE/baseline products to match the prior screen. It prepares
seven roles (`c,qbe,baseline,rcx,call,compose,adaptive`) with seven rounds,
200 ms calibration, a 180 s inner deadline and 210 s / 96 MiB outer guard.
Seven rounds balance every role position. It neither polls nor runs programs.
The coordinator can invoke the frozen
`prepared-candidates-runtime-prepare01-argv.json` once builds are complete.

The separate `prepared-combined-plan01.json` uses the checked `combined-api01`
and the same six inputs. Exact preparation identity passed. Its frozen
`prepared-combined01-argv.json` uses 180 s / 96 MiB / 3,072 MiB RSS;
`combined-dev-build01-argv.json` performs the unchanged independent oracle
build afterward. A one-emitter batch provides no cross-emitter preparation
saving; it only reuses the validated transport method.
