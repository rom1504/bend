# Additional native coverage: preliminary baseline

The four additional development families expose a broader performance gap in
the installed Phase69 compiler: this calibration observes **1.46–3.87× upstream
execution time**, including large gaps in two nonobserver workloads. These are
**one-sample calibration ratios, not final benchmark results**. No Phase70
candidate improvement is measured here.

The [preselected corpus design](../../design/phase70/native-coverage.md) adds six
families. List pipeline, Array-map, Tape observer and String ordering have been
acquired; BST and expression remain pending native timing holdouts. All six v2
wrapped sources passed the earlier checked-source gate. The four acquired
families pass both compilers' smoke oracles and all calibration output checks.

## Observed calibration

These numbers come from root's
[second calibration](../../selfhost/build/phase70/coverage-baseline-calibration02/report.json).
Each row is one timed batch per role, with the **same repetitions and warmups**
on both sides. A repetition executes the family kernel on the unchanged 16-input
cycle and contributes to the digest. Times exclude emission and Clang; they
include the measured digest's formatting/print, as in the original protocol.

| Additional family | Repetitions / warmups | Upstream C, ms | Phase69 B1-produced C, ms | Preliminary ratio |
| --- | ---: | ---: | ---: | ---: |
| List pipeline | 76,800 / 76,800 | 140 | 300 | 2.14× |
| Array-map | 12,800 / 12,800 | 250 | 861 | 3.44× |
| Tape observer | 38,400 / 38,400 | 31 | 120 | 3.87× |
| String ordering | 38,400 / 38,400 | 315 | 461 | 1.46× |

All eight observations have valid positive clocks and exact base, warmup and
measured digests. Seven exceed the final 100 ms timing floor; upstream Tape is
only 31 ms and **does not qualify for final timing**. Every value exceeds 10 ms,
making this campaign useful for choosing larger common work. The first
calibration was deliberately retained: it produced 0–8 ms intervals and supplies
no performance evidence. Calibration02 took 7.33 seconds of controller wall time.
There are no repeated samples, balanced role rotations or dispersion estimates
in this table; upstream ran before selfhost in every pair.

The runtime gap is not restricted to the planned observer pass. List pipeline
generates, filters, maps and consumes lists; Array-map converts
U32→Bool→U32 and folds the result. They are explicit nonobserver controls.
Tape is an independent user ADT with a returned unchanged root and later alias
use; String ordering exercises prefix, Unicode, equality and early/late exit.
The measurements identify useful investigation targets but do not establish
whether allocation, worker admission, representation or another mechanism is
responsible. That requires generated-code inspection or counters.

The subsequent [Array-map source inspection](native-array-map-opportunity.md)
finds a whole-program packed-layout fallback at `Array<Bool>` and boxed map-loop
state. It records a concrete next experiment, with runtime attribution still
unmeasured.

## Keep the denominator separate

Phase69's **1.0332× upstream** geometric mean remains the qualified result for
its original six families. It is not a general-program parity result. These
new cases were selected for additional coverage, and their slower observations
show why that distinction matters.

Do not merge this table into the original six-family mean: the new campaign is
calibration-only, has one fixed-order pair per family, includes a sub-100 ms
interval, omits two selected holdouts and has no Phase70 candidate role. The
earlier result used a different campaign with balanced repeated observations.
Pooling would silently change both the workload denominator and the measurement
quality. After frozen-candidate acquisition, create common counts from both
calibrations and run the three rotated roles/rounds. Report the six additions
separately; any 12-family union must name its weighting and retain both component
results and their campaign identities.

## Identities and pending work

- Baseline checked B1: `674e7960c7e8957452ffb0bdc6cb1f69ddaf8c03814617277886d1551fe16553`.
- Pinned upstream: `059266225b77c8ca256ac6b25ee5c21449bab151`; both roles use the same recorded Clang 22 recipe.
- [Baseline acquisition](../../selfhost/build/phase70/coverage-baseline01/report.json): `739bdaacd4bd28a9e2e21e3e045d0db5798281eaeb56777bba09f3d7069dbc4f`.
- [Calibration02](../../selfhost/build/phase70/coverage-baseline-calibration02/report.json): `097086cb08b5e1eab498ec1a3c628ab761b166165416e87818fb12c641285071`.
- [Saved-binary method](../../selfhost/build/phase70/coverage-saved-methods01/run-saved.derivation.json) explicitly records changed compiler assembly/host hashes. The acquisition recipe, emitted C and executables remain unchanged; acquisition is disabled in this successor.

Candidate acquisition, candidate calibration, final common-work timing and the
BST/expression holdouts remain pending. This report was written from existing
receipts only; its author ran no compiler or generated program. No promotion,
compiled-program improvement or broader parity claim follows from calibration.
