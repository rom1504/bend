# Compiler-only factorial: discard occurrence update and observer skip

The bounded screen does **not** justify retaining P70-006's occurrence-table
update. With the current observer route, the occurrence update makes genuine
B2's Numeric compilation request slower in all four paired rounds: its median
is **2.22% above** the original update. The leader selected removal of its ten
added source lines and restoration of `index_set(..., 32)`. P70-008's ordinary
observer-plan skip is also not selected: its effect is small or inconsistent.
This is a source-simplicity decision supported by a failed prospective retention
gate, not a claim that every B1/B2 workload becomes faster.

The selected source successor must still receive its own checked build, genuine
B2, exact-C qualification, compiler timing and release checks. Edited diagnostic
JavaScript images are never installed as the compiler.

## Controlled method and correctness

Four arms were derived from the exact compiler02 B1 and genuine B2 images:
current compiler02, occurrence update removed, P008 observer skip, and both
edits. Each change has an exact reconstruction/reversal receipt; the two edits
commute. No source type-checking or release provenance is inferred for edited
images. All **32/32 full checked Numeric requests produced byte-identical C**
to compiler02's independently native-validated program. Consequently this
screen needed no repeated Clang build or native execution. A C difference would
have stopped qualification; no different-output timing was accepted.

There were **eight fresh private Base preparations** and **four complete arm
rotations per compiler stage**, with B1/B2 stage order alternating. Every arm
occupied each of four within-stage positions once. Preparations, imports and
request clocks were separate; these are fresh-process, prepared-Base request
times, not instrumented-profile timings. No observations were dropped.

The experiment ran serially on CPU3 using the existing request worker and RSS
guard. The screen consumed **36.50s in preparation processes** and **110.73s in
clean request processes**, a total **147.23s** of guarded child wall time. Peak
process-tree RSS was **417.20 MiB**, below the 2048 MiB limit. This excludes
source preparation and the surrounding orchestration. Only Numeric was tested;
there is no full-corpus compilation or generated-program speed claim here.

## All four arms

Lower request times are better. These medians retain all four observations.

| Diagnostic arm | B1 median, ms | B2 median, ms |
| --- | ---: | ---: |
| compiler02 | 2404.650 | 1562.592 |
| Occurrence update removed | 2523.401 | 1528.654 |
| P008 observer skip only | 2413.170 | 1559.271 |
| Both diagnostic edits | 2386.262 | 1529.702 |

With the existing observer route, the occurrence update's B1 median appears
4.71% lower, but it wins only **2/4 paired rounds**. Two occurrence-off samples
are about 2640–2652ms, while the other two are about 2388–2406ms. Current B1
also has a 2620ms sample. This spread prevents interpreting a four-sample
median as a stable 4.71% gain. B2 is clearer: current is slower in **4/4** rounds,
with an occurrence-on/off median ratio **1.02220** and paired-ratio geomean
**1.02084**. The prospective rule required at least 1% aggregate benefit,
no stage regression over 1%, and at least 3/4 favorable paired rounds in each
stage; occurrence retention fails independently of the noisy B1 median.

Under the diagnostic observer skip, occurrence-on/off median ratios are
**1.01128 B1** and **1.01933 B2**; occurrence wins only **1/4 rounds in each
stage**. This agrees with removing the extra update rather than keeping it on
the strength of a single profile or one favorable timing.

P008 by itself has median ratios **1.00354 B1** and **0.99787 B2** against
current compiler02. Without the occurrence update, skip/no-skip is **0.94565
B1** but **1.00069 B2**; the apparent B1 benefit includes the same uneven
slow-sample distribution. B2 paired wins are only 1/4 and 2/4 respectively.
There is no consistent cross-stage benefit supporting a new observer admission
condition. All P008 diagnostics and negative findings remain recorded.

The paired interaction geomean is **1.03471 B1** and **0.99770 B2**. This is
an observation about these samples, not evidence of a causal compiler-pass
interaction: process/host timing variability can produce the same pattern.
Neither a statistical confidence interval nor a uniform correction is claimed.

## All clean observations

Values are milliseconds in round order 0–3, regardless of execution position.

| Stage | Arm | Four request times, ms |
| --- | --- | --- |
| B1 | current | 2396.379 / 2409.444 / 2620.500 / 2399.856 |
| B1 | occurrence-off | 2651.940 / 2406.065 / 2640.738 / 2388.280 |
| B1 | ordinary-skip | 2651.125 / 2393.518 / 2432.822 / 2382.364 |
| B1 | both | 2631.311 / 2382.388 / 2373.233 / 2390.135 |
| B2 | current | 1564.254 / 1570.950 / 1560.931 / 1534.238 |
| B2 | occurrence-off | 1525.407 / 1532.256 / 1513.459 / 1531.901 |
| B2 | ordinary-skip | 1615.813 / 1571.967 / 1528.325 / 1546.576 |
| B2 | both | 1520.810 / 1567.857 / 1535.204 / 1524.199 |

## Decision and follow-through

Remove only P70-006's ten source lines and restore the original occurrence
update. Leave observer admission unchanged; do not apply P008. This restores a
simpler existing path, preserves the observer/runtime improvements already
measured, and avoids retaining a compiler-speed optimization that failed its
retention rule. The earlier helper equivalence tests establish correctness of
the experimental update, not a reason to keep its extra work.

The checked successor's emitted C will be compared in full for both B1 and B2
against all twelve validated compiler02 native programs. Only demonstrated
identities may inherit their runtime evidence. Final three-source compilation
latency receives a separate position-balanced TypeScript/B1/B2 campaign;
Numeric diagnostic times here are not substituted into that result. Native100,
raw31, JS closure protection, self-check/B3 and release checks remain distinct.

## Frozen evidence and reproduction

- Plan: `selfhost/build/phase70/compiler02-factorial01/plan.json`, SHA-256
  `747edf83b39f5a56ede3d717bcb62a587de06024a2866a3ee818aca1ca069070`.
- Complete analysis: `selfhost/build/phase70/compiler02-factorial01-summary.json`,
  SHA-256 `115c8381545f4e57e753e2f182b97c9332d9c32b2aa0dd642f2656416cf811c8`.
- Occurrence image receipts: `selfhost/build/phase70/occurrence-ablation-images01/derivation.json`.
- Observer image receipts: `selfhost/build/phase70/observer-ready-ablation-images01/derivation.json`,
  SHA-256 `193e692cf4b09abcee1ef3af7603afa6677591eff4e3dbe1375a9fa8356afb7d`.
- [Plan producer](../../selfhost/tools/performance/phase70/methods/prepare-factorial.py)
  and [data-only analyzer](../../selfhost/tools/performance/phase70/methods/analyze-factorial.py).

The analyzer checks all frozen inputs, forty completed worker/guard receipts,
every generated C hash and complete position coverage. All raw images, plans,
receipts and outputs remain in the Phase70 evidence capsule. This report was
prepared from retained data on CPU0 and ran no compiler or native target.
