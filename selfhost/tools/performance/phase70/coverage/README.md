# Phase70 additive native coverage

For the frozen compiler02 validation campaign, use the
[practical acquisition/calibration/comparison queue](final-compiler02.md).
It preserves the six-family membership, freezes the two native holdouts before
execution, and keeps this denominator separate from the original six families.

Six preselected families broaden the old six-native loop. Read the
[design](../../../../../design/phase70/native-coverage.md) for scope, independent
oracles and holdout policy. These are source/method proposals; target acquisition
is performed by root and its results belong in the Phase70 report.

The current proposal is **v2**: `cases-v2.json`, `oracle-v2.py` and
`selection-check-v2.json`. V1 remains unchanged. Its Tape workload destructured
a computed call, which current Bend forbids; v2 moves that destructuring into
a helper parameter. The algorithm, oracle and selected families are unchanged.
A checked-source gate must pass before C acquisition.

`cases-v2.json` pins each kernel and the Array-map import dependency. Three kernels
reuse the Phase37 JS catalog unchanged. Three small files in `fixtures/` adapt
an upstream array test or independently exercise root preservation and String
ordering. The six original batch wrappers were produced by `make-batch.py`, which
imports the unchanged Phase46 wrapper generator. Regeneration refuses existing
outputs; use `--out FRESH_DIRECTORY` to inspect an identical v1 successor. V2
adds `tape-observer-batch-v2.bend` using that same generator and its new catalog
source identity; the other five wrappers remain unchanged.

## Prepare without targets

```sh
taskset -c 0 python3 -B selfhost/tools/performance/phase70/coverage/prepare.py \
  --out selfhost/build/phase70/coverage-methods-parent-NEW
taskset -c 0 python3 -B selfhost/tools/performance/phase70/coverage/prepare-v2.py \
  --parent selfhost/build/phase70/coverage-methods-parent-NEW \
  --out selfhost/build/phase70/coverage-methods-NEW
taskset -c 0 python3 -B selfhost/tools/performance/phase70/coverage/oracle-v2.py \
  --out selfhost/build/phase70/coverage-oracles-NEW.json
```

Preparation records exact parent hashes and every source replacement. Four
derivatives keep the old execution guard, C toolchain, clocks and observations:
`freeze.py`, `emit.mjs`, `run.py`, `compare.py`. The comparison parent is the
sealed `selfhost/build/phase69/methods01/compare-native-v2.py`; a clone lacking
that path must restore its verified Phase69 evidence capsule first. No old
source or result is modified. Source-only `coverage-methods01` and
`coverage-oracles01.json` preserve v1; `coverage-methods02` and
`coverage-oracles02.json` select v2. None qualifies a generated program.

Use absolute API paths or repository-relative paths from the repository root.
For each independently frozen compiler API, first freeze a new recipe:

```sh
taskset -c 0 python3 -B selfhost/build/phase70/coverage-methods-NEW/freeze.py \
  --api selfhost/build/phase69/typed-build10/equality/api.mjs \
  --out selfhost/build/phase70/coverage-baseline-recipe-NEW.json
```

The candidate recipe uses its checked API instead. Freeze recipes only after
method and corpus bytes are final. Current upstream remains commit
`059266225b77c8ca256ac6b25ee5c21449bab151`; use the same Clang22 recipe for all roles.

## Root-owned acquisition and calibration

These commands execute targets and belong only to root's serial guarded lane.
The wrappers own the execution guard; do not wrap them in a second guard using
the same lock. Existing environment-specific approval requirements still apply.

```sh
python3 -B selfhost/build/phase70/coverage-methods-NEW/run.py acquire \
  --recipe selfhost/build/phase70/coverage-baseline-recipe-NEW.json \
  --out selfhost/build/phase70/coverage-baseline-NEW \
  --roles upstream,selfhost --cases list-pipeline,array-map,tape-observer,string-order
```

Acquire candidate with its own recipe and `--roles selfhost`. Acquire BST and
expression after the candidate freezes. Every acquire operation checks sources,
emits C once, invokes Clang once and runs a one-repetition smoke observation.
All three expected output values must match before any timing is eligible.

```sh
python3 -B selfhost/build/phase70/coverage-methods-NEW/run.py calibrate \
  --recipe selfhost/build/phase70/coverage-baseline-recipe-NEW.json \
  --acquired selfhost/build/phase70/coverage-baseline-NEW \
  --out selfhost/build/phase70/coverage-baseline-calibration-NEW \
  --roles upstream,selfhost --cases list-pipeline,array-map,tape-observer,string-order \
  --target-ms 300 --max-slow-ms 3000
```

Repeat for candidate with its recipe/acquisition and `--roles selfhost`. If any
calibration observation is below 10 ms, repeat that calibration in a fresh output
with `--plan PREVIOUS_CALIBRATION/plan.json`. Then create common final work:

```sh
taskset -c 0 python3 -B selfhost/tools/performance/phase70/coverage/merge-plans.py \
  --calibration selfhost/build/phase70/coverage-baseline-calibration-NEW \
                selfhost/build/phase70/coverage-candidate-calibration-NEW \
  --out selfhost/build/phase70/coverage-common-plan-NEW.json
```

The merger rejects coarse observations and a role spread that cannot fit both
bounds. Review its predictions; it produces no timing result. Counts are a
multiple of16, warmups about1/8 of measured work. Freeze the plan before final
timing; all roles run the same count and the same16-input cycle.

## Compare saved binaries

```sh
python3 -B selfhost/build/phase70/coverage-methods-NEW/compare.py \
  --baseline selfhost/build/phase70/coverage-baseline-NEW \
  --upstream selfhost/build/phase70/coverage-baseline-NEW \
  --candidate selfhost/build/phase70/coverage-candidate-NEW \
  --plan selfhost/build/phase70/coverage-common-plan-NEW.json \
  --cases tape-observer,array-map --rounds 3 \
  --out selfhost/build/phase70/coverage-fast-NEW
```

Use `list-pipeline,array-map,tape-observer,string-order` for a development screen,
then all six names for the frozen-candidate transfer check. Multiple acquisition
directories are accepted under each role, allowing the heldouts to be acquired
later. They must contain no duplicate case/role. A common plan can contain more
cases than the timing selection.

There is no hard wall-budget flag: the initial goal is roughly20seconds for two
families or60seconds for four, after acquisition. The actual elapsed time is
reported and each process is bounded. Broader three-round timing is54 intervals
for the six additions. Repeatedly spending300/600seconds without a new question
is not required. Failed correctness or sub100ms timing blocks qualification;
retain the failure and use a new plan/run if needed. Keep this addition's ratios
separate from the original six-family Phase69 result.

## Saved binaries after host edits

The acquisition recipe remains immutable. The original calibration method also
rechecks compiler assembly inputs, although calibration only executes saved
binaries. `prepare-saved.py` creates a narrow successor when the only live drift
is `selfhost/src/compiler.json` and/or `selfhost/tools/typed-driver.mjs`. It records
their exact old/new hashes, disables acquisition and keeps every other recipe,
binary, generated-C, emission-receipt, oracle and guard check. Further changes
to either file still refuse; this is not a general bypass for stale inputs.

Root's four-family baseline plan is
`selfhost/build/phase70/coverage-saved-methods01/plan.json`. It retains the original
`coverage-baseline-recipe01.json` and acquisition, targets300ms with a3second
predicted slow bound, and has not been executed by the source-only author.
The ordinary comparison method already treats the baseline recipe as historical
emission provenance; it still checks live candidate recipe inputs. No comparator
change was needed for this baseline-only drift.
