# Frozen compiler02 comparison of the six additions

The complete executable command queue is
`selfhost/build/phase70/compiler02-coverage-final-plan01/queue.json`.
Its SHA-256 is `bffa673d866d07c2c5e61a499ea4d0492e50d00ecd0c0058551a0dfa46906169`.
This file describes a source/data-only preparation; root executes target steps
serially using the existing guarded methods. A prepared queue is not a result.

Membership is fixed by [cases-v2.json](cases-v2.json): list-pipeline, Array-map,
Tape observer, String ordering, BST and expression evaluation. The two latter
cases are native holdouts, frozen before acquisition in
`compiler02-coverage-final-plan01/holdouts.json`. That receipt binds the source,
wrapper, size, seed, independent oracle and checked compiler02 API
`f326862f5163fce83e47642c9b8dcfdb6596683bafe36054b7fb6d5430376f2f`.
Their source and previous JavaScript benchmark history are known; they are not
unseen-language examples. Do not tune compiler02 after observing these results
and still call the same measurements holdouts.

The original six-family denominator and these six additions remain separate.
Report every family, identify the two holdouts, then compute each six-family
geomean independently. Do not combine the historical 1.0332× result with new
calibration observations or turn Array-map's 2.468× checkpoint into a suite
metric.

## Run sequence

Use the exact argument arrays in `queue.json`; run the Python controller on
CPU0. Each existing method places its target on CPU3, serializes execution,
uses a 2GiB process-tree RSS bound and a 4GiB available-memory floor, and retains
child deadlines, source hashes, emitted C, executables and oracle receipts.
Do not run these target steps concurrently.

1. **Acquire five missing compiler02 cases** with `coverage-methods02/run.py
   acquire`. Reuse `compiler02-array-map` for the sixth. All six must use the
   exact `compiler02-coverage-recipe.json` identity.
2. **Acquire BST/expression for Phase69 B1 and upstream** using the newly frozen
   `compiler02-coverage-final-plan01/baseline-holdout-recipe.json`. This uses the
   immutable Phase69 API with the currently pinned host; it does not mutate the
   historical baseline recipe. Reuse `coverage-baseline01` for the four existing
   baseline/upstream cases.
3. **Calibrate the four compiler02 development cases**, then the two holdouts
   separately for candidate and baseline/upstream. `seed-work.json` supplies
   provisional identical work counts with short warmups. Prior four-family
   baseline calibration is reused from `coverage-baseline-calibration02`;
   all eight observations are correct and at least 10ms.
4. **If a calibration is below 10ms**, retain it and repeat that calibration
   group in a fresh directory using its generated `plan.json`. Substitute the
   successful retry path in the next command. Calibration does not establish
   a final ratio. Unknown holdout cost is the reason for this bounded two-step
   choice, rather than guessing an expensive workload in advance.
5. **Derive common work** with [merge-plans.py](merge-plans.py), combining one
   Phase69, one compiler02 and one upstream observation per case. Aim for 300ms
   in the fastest role and no more than 3s predicted in the slowest. Every final
   role receives identical repetitions and warmups. A spread outside those
   bounds must produce an explicit new plan, not omission of the slow case.
6. **Compare saved binaries** with `coverage-methods02/compare.py`, all six
   names and three rotated rounds. This gives 54 intervals. Require every
   independent checksum, clean exit and at least 100ms per interval. Any
   incorrect or short interval blocks a qualified suite result and remains in
   its original receipt.

The queue includes absolute paths for all seven commands and pins the methods,
recipes, acquisition reports and calibration inputs. It was prepared after
verifying every current compiler02 recipe input. Subsequent drift is a refusal,
not permission to modify old receipts. Use a documented successor if a harmless
host-only change must be distinguished from execution inputs.

## Current checkpoint and remaining cost

Already measured before this final queue: Array-map's three-role medians are
Phase69 1022ms, compiler02 738ms, upstream 299ms on fixed common work. All nine
intervals passed. The one-line Bool admission restores packed/direct array
paths, but emitted map loops retain their per-element Tuple allocation sites.
See the [source and measured checkpoint](../../../../../implementation/phase70/native-array-map-opportunity.md).
The other compiler02 coverage and native holdout results remain pending until
their acquisition/calibration/comparison receipts complete.
