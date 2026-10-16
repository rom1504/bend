# Phase102 runtime regression: source-level exclusions

The final03 broad runtime screen raised raytrace and local-fold slowdowns
relative to Phase98, while the cold-list correction improved list-pipeline.
The timing attribution remains with the paired experiments; this note records
what the retained generated C can and cannot explain without running targets.

For `09-raytrace`, `11-local-fold` and
`28-variation-ray-active-256-2240`, the complete native-chain02 versus
native-chain03 C diff contains only:

- A new direct observer-projection body for `String.order`.
- `INLINE` to `NF_INLINE` on the declarations and definitions of
  `String.order` and `String.is_le`—four hint tokens per file.

Each C file shrinks by exactly 142 bytes. There is no TRMC state, constructor,
scheduler or other worker-body change in these products. The new fifth state
slot therefore cannot directly explain their changed runtime through an added
load, branch or register lifetime. A general claim that TRMC register pressure
caused these particular regressions would contradict the retained C.

The stable eligibility filter also preserves the original hint calculation
for an unchanged worker list. Let `E(w)` be immutable ready-name membership
and the 8,192-byte code-size bound, and let `D(w,P)` test that all dependencies
are in the previous round. The old pass selects `E(w) && D(w,P)` from the
original list; the new pass selects `D(w,P)` from the stable `E`-filtered list.
Both produce the same ordered names, including duplicates. Applying this
identity to each of the same three immutable rounds preserves the result.
Projection changes worker code and dependencies before this calculation;
those changes can legitimately make additional workers receive forced hints.

The concrete remaining hypothesis is a Clang inlining/code-layout effect from
these changed helpers. Possible mechanisms include larger inlined callers,
register allocation, or alignment changes elsewhere in the translation unit.
These are hypotheses, not measured causal findings. Restoring exactly the four
old hint tokens while retaining the new projection body isolates the hint
change. Pairing that ablation with the retained02 and03 binaries under the
same inputs and balanced order also separates it from drift between historical
full-suite measurements. Restoring the body separately is the next test only
if the hint ablation is inconclusive.

The completed broad03 comparisons cover **44 timed points from 23 source
programs**, with three samples per role. Both comparisons have 264/264 correct
observations, for 528 total. The separate zero-work control has no defined
runtime ratio and is excluded from the geometric means. Compilation and
process startup are not included in these warmed program-runtime ratios.

| Final03 runtime / comparator runtime | Versus Phase98 | Versus upstream-generated C |
|---|---:|---:|
| Equal-point geometric mean | 0.9553 | 1.0628 |
| Equal-source geometric mean | 0.9608 | 1.0822 |
| Historical raytrace point | 1.4507 | 1.4821 |
| Local fold, original point | 1.1937 | 1.0033 |
| Local fold, 128 | 1.1008 | 1.0751 |
| Local fold, 8192 | 1.1928 | 1.0067 |
| List pipeline, 128 | 0.6466 | 0.6880 |
| List pipeline, 512 | 0.6679 | 0.7103 |

A ratio below one means final03 is faster. The aggregate improves on Phase98,
but that does not erase the separated fold regressions. Its original point
measures 3.296–3.318 microseconds versus Phase98's 2.780–2.791; the 8192-point
ranges are 6.598–6.643 versus 5.510–5.532 microseconds. Neither comparison alone
identifies the compiler mechanism responsible.

The historical-raytrace 1.4507 ratio is especially unstable: final03's samples
span 28.692–42.000 milliseconds and Phase98's span 28.692–41.846 milliseconds.
Those ranges substantially overlap. The same final03 binary then measures
28.538–29.077 milliseconds in the upstream comparison. It would be misleading
to call the 45% median gap a demonstrated compiler regression without the
balanced diagnostic. The two active-ray points are approximately 0.985 times
Phase98, although they retain a larger 3.43–3.45 times upstream gap.

These are finite corpus results, not an estimate for every Bend program. The
closed summary receipts are:

- `selfhost/build/phase99/phase102-runtime-phase98-03/summary.json`, SHA256
  `a5c85ddd8087b3ee6e77a4d36373d69b3d81d2e16652f793b6c76994f57578be`.
- `selfhost/build/phase99/phase102-runtime-upstream-03/summary.json`, SHA256
  `b7839c3ef1d17968e4c2f2014da6a23fc5ae4de2085f5cd96c9cb0aa95579d49`.

The underlying immutable C paths are
`selfhost/build/phase102/native-chain02/runtime-continuity/` and the corresponding
`native-chain03/runtime-continuity/` paths. No compiler, generated program,
Clang or timing target was executed for this source-level review. The final03
source and products remain unchanged.

## Balanced runtime diagnosis

`hint-ablation-run01/report.json` completes eight balanced rounds for four
products, with all 128 observations correct. Each of Phase98, candidate02,
candidate03 and the saved-C prior-hint variant occupies every order position
equally. All samples pass the unchanged 100 ms minimum.

| Point | Candidate03 / Phase98 | Prior hints / Phase98 |
|---|---:|---:|
| Raytrace | 0.9920 | 0.9907 |
| Local fold | 1.1913 | 0.9980 |
| Fold 128 | 1.1046 | 1.0181 |
| Fold 8192 | 1.1912 | 0.9920 |

Raytrace's original slowdown does not reproduce. Fold's does, and reverting
only four hint tokens removes it. This establishes the forced-hint change as
the causal intervention; it does not yet identify the precise machine-code
alignment, register-allocation or cache mechanism. These results supplement
the original samples without rewriting their aggregate.

The small source successor preserves the original dependency cost after
projection. Its checked Bend emission and separate application screen are
recorded in [projection integration](projection-integration.md). Candidate03
remains semantically qualified but opt-in; candidate04 has no native-chain
qualification. A cost-policy correction and its source checking cannot inherit
a previous compiler image's admission.
