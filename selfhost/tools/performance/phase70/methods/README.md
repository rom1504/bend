# Phase70 inherited methods

`prepare.py` materializes ten hash-pinned, exact successors in
`selfhost/build/phase70/methods01`. The parent Phase69 methods, compiler images,
acquisitions and reports remain immutable. Each successor has an adjacent
`.derivation.json`; `methods.json` records the whole set. Source preparation
uses CPU0 and executes no compiler, Node, Clang or native program.

Root executes targets serially with approved escalation for the diagnosed
Node24 default-stdin PIPE/EPERM sandbox issue. Existing guards retain CPU3,
1 GiB Node heap, 4 MiB stack, 2 GiB process-tree RSS and a 4 GiB available-memory
floor. Do not nest guards. Keep failures and use fresh output paths.

## Immediate baseline compiler profiles

The ready plan is `selfhost/build/phase70/compiler69-profile02/plan.json`:
two private Base preparations, then numeric/array/lexer B2 profiles and a numeric
B1 profile. There are no clean timing jobs in this plan. B1 `674e7960…` is the
frozen Phase69 checked image, verified byte-identical to the installed image
during preparation; B2 is the actual self-emitted `c858dfa5…` image. Complete C
must reproduce `phase69/typed10-native` acquisitions. Private driver copies and
caches live only under Phase70.

```sh
# Root: first syntax-check the two-line instrumentation successor.
/home/ai/.nvm/versions/node/v24.18.0/bin/node --check \
  selfhost/tools/performance/phase70/methods/compilation/worker.mjs
python3 -B selfhost/tools/performance/phase70/methods/compilation/run.py \
  --plan selfhost/build/phase70/compiler69-profile02/plan.json --group prepare
python3 -B selfhost/tools/performance/phase70/methods/compilation/run.py \
  --plan selfhost/build/phase70/compiler69-profile02/plan.json --group profile
taskset -c 0 python3 -B selfhost/tools/performance/phase70/methods/compilation/analyze.py \
  --plan selfhost/build/phase70/compiler69-profile02/plan.json \
  --out selfhost/build/phase70/compiler69-profile02-summary.json
```

The first prepared `compiler69-profile01` remains unexecuted. Source review
found that the inherited profiler required `nc_compile`, whereas the selected
driver calls `nc_compile_checked`. `upgrade-profile-entry.py` records the exact
successor: observe both exports and require the selected entry. Compiler bytes,
output oracles, sampling and guards are unchanged. Every profile retains its
`.cpuprofile`, stage timings and exact emitted C. Profiles are diagnostics;
their clocks never become clean throughput samples. Unknown V8 samples remain
explicitly unattributed; inclusive source-function times overlap.

For a later balanced request comparison use `prepare-compilation-v2.py`, the
same flags below with a new checked attempt/image pair, `--rounds 3`, and a fresh
output. It prepares 2 Base jobs, 27 clean jobs and 4 optional profile jobs.
Run `--group clean` after preparation. If profiles are omitted, report the
completed clean group separately from the deliberately incomplete whole plan.

```sh
taskset -c 0 python3 -B selfhost/tools/performance/phase70/methods/prepare-compilation-v2.py \
  --attempt selfhost/build/phase69/typed-build10/attempt.json \
  --image-pins selfhost/build/phase69/typed10-b2-v2/image-pins.json \
  --oracle-attempt selfhost/build/phase69/typed-build10/attempt.json \
  --acquired selfhost/build/phase69/typed10-native/report.json \
  --reference-acquired selfhost/build/phase67/native-baseline02/report.json \
  --reference-acquired selfhost/build/phase67/native-heldout-baseline02/report.json \
  --rounds 3 --out selfhost/build/phase70/compiler69-clean01
```

Keep imports, explicit prepared Base, checked C emission, Clang build and native
execution as separate clocks. Bend prepares Base before requests; upstream
loads/checks Base within its request. Changed emitters need their own validated
C acquisitions; unchanged output may use the explicit prior oracle attempt.

## Checked candidate and native speed

These are recipes with the placeholder `candidate01`; choose unused paths.
The existing development workflow produces a checked equality-derived B1 and
its maintained selected frontend validation. Read `attempt.json` for the API.

```sh
python3 -B selfhost/tools/performance/phase32/bounded-run.py \
  --seconds 300 --rss-mib 2048 --available-mib 4096 \
  selfhost/build/phase70/candidate01-supervisor -- \
  taskset -c 3 /home/ai/.nvm/versions/node/v24.18.0/bin/node \
  --stack-size=4096 --max-old-space-size=1024 \
  selfhost/tools/development/workflow.mjs run \
  selfhost/build/phase70/methods01/development.json selfhost/build/phase70/candidate01
taskset -c 0 python3 -B selfhost/tools/performance/phase67/benchmark/freeze.py \
  --api selfhost/build/phase70/candidate01/equality/api.mjs \
  --out selfhost/build/phase70/candidate01-recipe.json
python3 -B selfhost/tools/performance/phase67/benchmark/run.py acquire \
  --recipe selfhost/build/phase70/candidate01-recipe.json \
  --out selfhost/build/phase70/candidate01-native \
  --cases numeric,array,closures,tree,map,lexer --roles selfhost
python3 -B selfhost/build/phase70/methods01/compare-native.py \
  --candidate selfhost/build/phase70/candidate01-native --rounds 3 \
  --out selfhost/build/phase70/candidate01-comparison
```

Acquire only affected families first, then the remainder with the same recipe
in another fresh directory. The comparator accepts multiple candidate paths.
Its roles are `baseline69`, `candidate`, `upstream`: baseline69 means the actual
Phase69 typed10 acquisitions, not compiler23 or newly attributed old runs.
It retains 16 varying inputs, fixed common work/warmups, three balanced role
rotations, independent digests and the 100 ms floor. Six families give54 fresh
timing observations. New coverage has separate acquisition/calibration methods
and must not silently change this denominator.

## Controls and qualification

For new fixture source admission before any C build, `prepare-check.py
--attempt CHECKED_ATTEMPT --selection NATIVE_SELECTION --expected-cases N
--out FRESH70` copies the frozen source/host files into a private project and
prepares the maintained conformance runner's persistent check lane. Root runs
`plan.json.command`; `optionalUpstreamCommand` checks the same selection through
upstream's isolated adapter. The ready first observer plan is
`phase70/observer-source-check01/plan.json`. All selected files must have `main`;
the separate check selection uses positive type-acceptance oracles even when
the original native golden expects a runtime failure. Original source bytes,
imports and runtime goldens remain unchanged. The private caches prevent any
write into sealed Phase69 snapshots.

Use `methods01/prepare-custom.py --attempt CANDIDATE --toolchain-recipe RECIPE
--selection SELECTION --expected-cases N --out FRESH70`; repeated selections
merge identical IDs and refuse conflicts. All source fixtures need explicit
`#|` goldens and unique external IDs. The inherited 71-source selection is
`phase69/typed10-all-controls/selection.json`. Validation requires a fresh
Phase70 candidate snapshot because the workflow primes its private cache.

Use `methods01/prepare-custom-raw.py --baseline
selfhost/build/phase69/typed-build10 --candidate CANDIDATE --toolchain-recipe
RECIPE --case-module MODULE --expected-added-cases N --out FRESH70`. Repeat
`--case-module` as needed. The existing reachability5, static3, closure6 and
raw-scalar2 modules are the exact pins in
`phase69/typed10-raw/cases.json`; use the repaired List-ABI successors recorded
there. The12 inherited result rows remain before the16 added raw cases.
Both images must retain the same native runtime; a runtime change requires
an explicitly reviewed method successor. The frozen Phase69 raw runner and its
schema remain intentionally reused. Execute each prepared `plan.json.command`
with escalation and its existing guard.

`methods01/verify-js.py BASELINE_API CANDIDATE_API FRESH70` requires identical
non-native generated closures. Compiler-speed changes affecting those closures
need reviewed behavioral/output protection rather than silently relaxing it.

Actual self-hosting is prepared by `methods01/prepare-bootstrap.py plan
CANDIDATE FRESH70-B2 --admission
selfhost/build/phase68/scalar-export-admission20.json`. Root runs the generated
`run.sh` after final selection. Eight driver observations and genuine B2
generation precede fresh own-source type acceptance and B3 byte reproduction.
`methods01/prepare-release-qualification.py` prepares these later two gates and
deferred release jobs using `--attempt`, `--b2`, `--native-recipe`, `--out`,
`--qualification-out`, and `--release-out` (all output directories fresh70).
It does not install anything. Expected unsafe proof-trust refusal remains
separate from type acceptance; no mathematical proof is claimed.

## Fast B1 compiler-work screen

Use `prepare-b1-pair-v2.py` with a new checked `attempt.json` and fresh Phase70
output directory. It reuses the frozen baseline profile plan's complete-C oracles
and exact driver/runtime bytes, then binds baseline69 and candidate B1 images.
No newly generated B2 is required. The first producer is retained: a source-only
preparation probe found that checked API identity objects contain extra provenance
keys; v2 checks their complete content hashes and byte sizes as existing methods do.
`b1-pair-method-check02` is an unexecuted baseline-versus-itself preparation probe,
not candidate evidence.

```sh
taskset -c 0 python3 -B selfhost/tools/performance/phase70/methods/prepare-b1-pair-v2.py \
  --attempt selfhost/build/phase70/NEW-CHECKED-ATTEMPT/attempt.json \
  --out selfhost/build/phase70/NEW-B1-PAIR
python3 -B selfhost/tools/performance/phase70/methods/compilation/run.py \
  --plan selfhost/build/phase70/NEW-B1-PAIR/plan.json --group prepare
python3 -B selfhost/tools/performance/phase70/methods/compilation/run.py \
  --plan selfhost/build/phase70/NEW-B1-PAIR/plan.json --group clean
python3 -B selfhost/tools/performance/phase70/methods/compilation/run.py \
  --plan selfhost/build/phase70/NEW-B1-PAIR/plan.json --group profile
taskset -c 0 python3 -B selfhost/tools/performance/phase70/methods/compilation/analyze-b1-pair.py \
  --plan selfhost/build/phase70/NEW-B1-PAIR/plan.json \
  --out selfhost/build/phase70/NEW-B1-PAIR-summary.json
```

Root runs target groups serially under the existing guard and required escalation.
There are two preparations, twelve clean requests (two alternating rounds over
numeric/array/lexer), and one candidate numeric profile. Two samples per cell are
a screen, not final precision. `profile-families.py --plan PLAN --out NEW.json`
provides data-only inclusive CPU-family unions; groups overlap and must not be
added. The corrected checked-entry instrumentation is inherited unchanged.

For batch wrappers with variable timing output, `prepare-check-v2.py` additionally
accepts `--oracle-catalog` and `--oracle-receipt` together. It verifies catalog,
source and wrapper hashes against the independent receipt before allowing absent
constant `#|` goldens. Its check lane still requires real positive type acceptance;
it does not run or validate the program's runtime output.

## Upstream-only source-check successor

The original optional upstream command from the private source-check project
failed during adapter artifact identity collection: the adapter's default
`.bootstrap` path is relative to that private project. Preserve that attempt.
`prepare-upstream-check.py --source-plan OLD/plan.json --out NEW` reuses the exact
frozen adapter and fixtures read-only, sets `BEND_UPSTREAM` to the actual pinned
reference root, pins its six reference artifacts, and changes only output and
supervisor directories. Root executes the new plan's `command` under escalation.
The first corrected plan is `observer-upstream-source-check01`; no target is run
by the preparer, and the source checker still uses its existing isolated mode.
