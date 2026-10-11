# Phase69 controlled native iteration

This directory reuses frozen methods; it does not introduce a new benchmark or
compiler adapter. `prepare.py` is data-only and materializes seven exact,
recorded successors under a fresh Phase69 directory. Their source is parsed by
Python before it is written. Parents and every literal edit are hash-pinned in
`methods.json`. No Phase68 raw or consumed method is edited.

The prepared instance is `selfhost/build/phase69/methods01`. To prepare another:

```sh
taskset -c 0 python3 -B selfhost/tools/performance/phase69/methods/prepare.py \
  --out selfhost/build/phase69/methods02
```

Only root runs target commands, serially. The compiler/native methods already
own a guard. Never wrap an already guarded command in another guard. Node heap
is 1 GiB, stack 4 MiB, process-tree RSS ceiling 2 GiB, available-memory floor
4 GiB. Source/data work belongs on CPU0. Keep failed attempts and choose new
paths for retries. The examples below use `candidate01` as a placeholder; never
execute them against a path already consumed by another candidate.

## Checked B1: first checkpoint

Use the maintained development workflow, not unchecked assembly. The small
configuration fixes the project and upstream paths, equality profile,
strictExact, jobs1, CPU3 and heap1024. Its ordinary selected gate contains36
frontend witnesses and must report complete/pass with zero exact differences.

```sh
python3 -B selfhost/tools/performance/phase32/bounded-run.py \
  --seconds 300 --rss-mib 2048 --available-mib 4096 \
  selfhost/build/phase69/candidate01-supervisor -- \
  taskset -c 3 /home/ai/.nvm/versions/node/v24.18.0/bin/node \
  --stack-size=4096 --max-old-space-size=1024 \
  selfhost/tools/development/workflow.mjs run \
  selfhost/build/phase69/methods01/development.json \
  selfhost/build/phase69/candidate01
```

Read the resulting `attempt.json.api.file` for the actual equality API. The
expected layout is `candidate01/equality/api.mjs`; the raw checked API remains
separately identified. The latest Phase68 checked build occupied the guard
31.50s and peaked at1.51GiB. These are historical planning observations, not a
promise for a changed compiler.

## Acquire once, time saved programs repeatedly

Freeze after the intended compiler edits. A recipe pins the actual API,
compiler manifest, runtime/providers, wrappers, Node, Clang22, headers/libraries
and execution method. It records relevant compiler environment variables.

```sh
taskset -c 0 python3 -B selfhost/tools/performance/phase67/benchmark/freeze.py \
  --api selfhost/build/phase69/candidate01/equality/api.mjs \
  --out selfhost/build/phase69/candidate01-recipe.json
python3 -B selfhost/tools/performance/phase67/benchmark/run.py acquire \
  --recipe selfhost/build/phase69/candidate01-recipe.json \
  --out selfhost/build/phase69/candidate01-acquire \
  --cases numeric,array,closures,tree,map,lexer --roles selfhost
```

For the first discriminator acquire only the affected families, e.g.
`--cases tree,lexer,closures`. Acquire remaining families later into a separate
fresh directory with the **same recipe** while its pins still hold. Do not
rebuild upstream or compiler23 on every iteration. Both already have correct
saved C/native binaries and original emission receipts. Acquisition separates
compiler request time from Clang build time and checks an independent checksum.
Native builds use `-isystem` with Lean's Clang headers, `-std=c11 -O3`, and
`-lpthread -lm`; GPU is off and execution uses one native thread.

The comparison successor changes only the saved Bend baseline20→23 and fresh
output boundary. It retains existing exact-source, toolchain, independent
oracle, common-work and clock-resolution checks. It uses baseline acquisitions
`phase68/native-facts23-{lexer,rest}` and upstream acquisitions
`phase67/native-{baseline02,heldout-baseline02}`. Original provenance remains
attributed to those producers.

```sh
python3 -B selfhost/build/phase69/methods01/compare-native-v2.py \
  --candidate selfhost/build/phase69/candidate01-acquire \
  --cases numeric,array,closures,tree,map,lexer --rounds 3 \
  --out selfhost/build/phase69/candidate01-runtime
```

Multiple acquisition paths are accepted after `--candidate`. Three rotations
balance the three roles: compiler23, candidate and upstream. Six families give
54 observations; a three-family discriminator gives27. Each native process has
a45s deadline. Every interval must reach100ms, and all three independent digest
values must agree. Current fixed counts are numeric77504, array61440,
closures57888, tree1280, Map1152 and lexer448, with rounded one-eighth warmups.
If a candidate becomes too fast for the clock floor, make a **new reviewed
method/plan with larger common counts** and rerun all compared roles. Do not
publish sub-resolution ratios or pool different plans. This is finite six-family
coverage, not a universal program-speed score.

The initial derivative retained the old aggregate JSON label
`geomeanBaseline20OverCandidate` although its role and input really are23. Its
bytes remain frozen. `upgrade-comparison.py --parent ORIGINAL --out SUCCESSOR`
derives the v2 label correction with an exact receipt; all timing and admission
logic is unchanged. The existing methods01/v2 is ready for root execution.

## Correctness: short controls before the broader selected gate

The successor integration preparer points at the unchanged37-source catalog
and golden selections. It retains all generated C and paired observations.
Use `--set product-fast` for six product witnesses or
`--set product-branch-drop` for the single1831 witness when relevant; use
`--set integration` for the37-source integration gate.

```sh
taskset -c 0 python3 -B selfhost/build/phase69/methods01/prepare-integration.py \
  --attempt selfhost/build/phase69/candidate01 \
  --toolchain-recipe selfhost/build/phase69/candidate01-recipe.json \
  --set integration --out selfhost/build/phase69/candidate01-integration
taskset -c 0 python3 -B selfhost/build/phase69/methods01/prepare-raw.py \
  --baseline selfhost/build/phase68/facts-build23 \
  --candidate selfhost/build/phase69/candidate01 \
  --toolchain-recipe selfhost/build/phase69/candidate01-recipe.json \
  --out selfhost/build/phase69/candidate01-raw
taskset -c 0 python3 -B selfhost/build/phase69/methods01/prepare-threads.py \
  --attempt selfhost/build/phase69/candidate01 \
  --toolchain-recipe selfhost/build/phase69/candidate01-recipe.json \
  --out selfhost/build/phase69/candidate01-threads
```

Each produces a `plan.json` containing the exact guarded `command` argument
array. Execute that array from the repository root with normal orchestrator
affinity (not CPU0); the workers themselves own CPU3. For example:

```sh
python3 - <<'PY'
import json, subprocess
p = 'selfhost/build/phase69/candidate01-integration/plan.json'
subprocess.run(json.load(open(p))['command'], check=True)
PY
```

Repeat for raw and thread plans, serially. Raw controls preserve all12 malformed
core/first-error/unused-product/polling observations for both image roles.
Thread controls run four existing fixtures with threads1 and4, GPUoff. The
raw preparer deliberately refuses changed runtime bytes between the two images;
a runtime edit needs a separately reviewed successor, not a bypass. These gates
do not cover newly introduced semantics by themselves: add independent source
witnesses and raw controls for the particular optimization. Profile/allocation
diagnostics and sanitizer witnesses have their own correctness scope and earn
no clean timing credit.

For newly authored witnesses, `prepare-custom.py` retains this same machinery
while accepting repeated `--selection PATH` arguments and a required
`--expected-cases N`. Each row must name a canonical absolute `.bend` file,
the native lane and explicit source `#|` goldens. Identical duplicate IDs are
listed and merged; conflicts or a different unique case count refuse. Its
`derive-custom.py` producer and adjacent exact-edit receipt preserve the
methods01 integration parent unchanged. Run the resulting plan's `command`
exactly as above. For example, combine reachability and closure-factory
`selection-v1.json` with `--expected-cases 17`. Preparation verifies files and
goldens; it does not establish that a new fixture typechecks or executes.

New raw witnesses use the separate additive successor
`prepare-custom-raw-v2.py`. Pass the same `--baseline`, `--candidate`,
`--toolchain-recipe` and fresh `--out` as the inherited raw preparer, plus
repeated `--case-module PATH` and required `--expected-added-cases N`.
Reachability contributes5 and static review3; closure-combinator V4 contributes6.
The inherited12 observations still run unchanged before custom cases.
`raw-controls-custom-v2.mjs` accepts module-exported `rawCases` or
`rawStaticCases`, and normalizes JS-array versus Con/Nil books. Root must run
Node's `--check` preflight before first execution; method preparation executes
no Node or target.

Custom cases retain complete emitted C, structured compilation errors and
one/four-thread runs, with explicit stdout/stderr/exit oracles. Named
`expectedError` is exact. `expectedCompileRejection` instead requires nonempty
errors and no emitted C in both roles, retaining potentially different messages.
`expectedByRole` requires explicit baseline/candidate expectations and a
`behaviorChange` explanation; it never grants a generic baseline-failure
exception. All first-generation and successor methods and their exact-edit
derivations remain preserved. Resource/runtime checks and the180s guard are
unchanged. Split independent modules into fresh plans if the added controls
exceed that existing bounded scope.

The first custom raw attempt exposed missing runtime List constructors in the
new tiny books, after all12 inherited observations passed. Module successors
`reachability/controls/raw-cases-v2.mjs`,
`static-data/raw-review-cases-v2.mjs` and
`closure-factory/raw-combinator-cases-v5.mjs` append the inherited minimal native
List ADT. Original declaration positions, cache payloads/indexes and oracles are
preserved; exact derivations accompany each. This is fixture packaging repair,
not a compiler regression or changed expected result. Keep the failed attempt.

For mechanism confirmation, `count-selected.py --candidate ACQUISITION...`
accepts `--cases closures,lexer,tree` and either `--check-only` or a fresh
`--out`. It imports the unchanged Phase68 instrumentation functions, reproduces
complete old diagnostic C before reusing23/upstream counters, and independently
checks their saved1/17-output/count logs. Only candidate diagnostic binaries are
rebuilt/run under the sole CPU3 guard. New and cached16-workload deltas remain
separately attributed. Allocation sites must sum exactly to aggregate calls;
instrumented clocks earn no runtime credit. Source-only combined08 admission
passed for all three families and six exact cached role rows.

## JS protection and actual B2

This phase's source-only JS check compares actual compiler23 and candidate
generated APIs. It requires identical runtime/public wrappers and the full
reachable function closure of every exported root not beginning `nc_`.
Unlike the prior20→23 comparison, it permits **zero changed functions**. It is
a strong finite continuity check; it is not fresh JS execution or B2 evidence.

```sh
taskset -c 0 python3 -B selfhost/build/phase69/methods01/verify-js.py \
  selfhost/build/phase68/facts-build23/equality/api.mjs \
  selfhost/build/phase69/candidate01/equality/api.mjs \
  selfhost/build/phase69/candidate01-js-closure
taskset -c 0 python3 -B selfhost/build/phase69/methods01/prepare-bootstrap.py \
  plan selfhost/build/phase69/candidate01 \
  selfhost/build/phase69/candidate01-b2 \
  --admission selfhost/build/phase68/scalar-export-admission20.json
bash selfhost/build/phase69/candidate01-b2/run.sh
```

Use that explicit reviewed export admission: it includes `nc_compile_checked`,
which the older Phase66 admission lacks. The producer verifies actual bootstrap
exports and the selected frozen driver against it. The tiny/full source
emission and eight ordinary-driver observations each have their own guard;
the final source/data join produces `image-pins.json`. This earns a genuine B2
image and driver checks; **full own-source checking, B3 reproduction and release
promotion remain separate gates**. Schedule those after final selection, not
for every native experiment.

## Compiler request time: B1 and B2 separate from program runtime

Prepare this only after new emitted C has qualified independently. Existing
request runner/worker/analyzer bytes stay unchanged. The selected producer only
relocates fresh raw output; original method and oracle provenance remain pinned.

```sh
taskset -c 0 python3 -B selfhost/build/phase69/methods01/prepare-compilation.py \
  --attempt selfhost/build/phase69/candidate01/attempt.json \
  --image-pins selfhost/build/phase69/candidate01-b2/image-pins.json \
  --acquired selfhost/build/phase69/candidate01-acquire/report.json \
  --reference-acquired selfhost/build/phase67/native-baseline02/report.json \
  --reference-acquired selfhost/build/phase67/native-heldout-baseline02/report.json \
  --rounds 3 --out selfhost/build/phase69/candidate01-compilation
python3 -B selfhost/tools/performance/phase68/compilation/run.py \
  --plan selfhost/build/phase69/candidate01-compilation/plan.json --group prepare
python3 -B selfhost/tools/performance/phase68/compilation/run.py \
  --plan selfhost/build/phase69/candidate01-compilation/plan.json --group clean
taskset -c 0 python3 -B selfhost/tools/performance/phase68/compilation/analyze.py \
  --plan selfhost/build/phase69/candidate01-compilation/plan.json \
  --out selfhost/build/phase69/candidate01-compilation-summary.json
```

Repeat `--acquired` for disjoint acquisition reports when necessary. Every
numeric/array/lexer B1/B2 request compares complete C against its qualified
oracle. Separate `--oracle-attempt EARLIER/attempt.json` may be used only for
byte-identical C actually acquired from that checked image. The plan explicitly
retains both selected and oracle producers. Request clocks include frontend,
annotation/validation and emission, exclude imports/API loading, Base
preparation and Clang; TypeScript performs its ordinary Base check inside its
request. `--rounds 1` is an exploratory screen;3 gives balanced final positions.
The optional `--group profile` uses separate instrumented requests and its
clocks must never replace clean samples.
The analyzer lists missing profile jobs and marks the full planned campaign
incomplete when those are intentionally deferred; completed clean rows remain
separately reported and must not be relabeled as a complete profile campaign.

## Time, resource and provenance account

`time-account.py --raw selfhost/build/phase69 --out FRESH.json` reads completed
guard receipts and reports both summed target wall and union occupancy, peak
tree RSS, failures and incomplete receipts. It does not claim billed model
quota or speedup. Keep source-data time, target occupancy and elapsed project
time distinct. A parallel review is useful while the serial target lane runs;
starting two targets concurrently invalidates this method's isolation.

Useful read-only checks from the repository root:

```sh
git rev-parse HEAD
git status --short
df -h .
free -m
ps -eo pid,ppid,psr,rss,etime,args --sort=-rss
```

Each checked `attempt.json` identifies exact snapshot/API/bootstrap files;
each native recipe/report binds wrapper/C/executable/toolchain; every method
derivative records its parent and exact edit list. Preserve fresh raw receipts
and source versions before any cleanup or final capsule. An unchanged emitted
C hash is evidence against crediting a timing movement as a compiler gain.
