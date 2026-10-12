# P70-004 + P70-005: first combined compiler-speed screen

The combined checked B1 candidate reduced the three-case geometric mean request
time by **3.58%** in a small alternating screen. Numeric improved 9.0%, lexer
3.3%, and array regressed 1.8%. Every one of the 12 clean requests emitted exactly
the previously validated Phase69 C. The result supports keeping this small
candidate for further integration; two samples per cell do not establish final
precision, a universal gain, or B2 performance.

This is the combination of the lazy product-demand gate and prepared compact-body
reuse. No ablation was run, so the clean gain belongs to the combination.

| Case | Baseline69 B1 median ms | Candidate B1 median ms | Candidate / baseline |
|---|---:|---:|---:|
| numeric | 2410.45 | 2193.31 | 0.9099× |
| array | 2359.91 | 2403.34 | 1.0184× |
| lexer | 2864.12 | 2770.67 | 0.9674× |
| Geometric mean ratio | | | **0.9642×** |

The six baseline and six candidate requests used two alternating fresh-process
rounds with separately owned prepared Base caches. Imports, preparation and the
additional instrumented profile are excluded from these medians. Array's
candidate observations were 2469.14 and 2337.54 ms against baseline 2385.35 and
2334.47 ms: its screen regression is small relative to this observed spread, but
is retained rather than averaged away. The numeric baseline also varied from
2294.79 to 2526.11 ms, making its exact 9% estimate imprecise.

## Evidence of the intended mechanism

The candidate numeric B1 profile sampled the product-use-count family for
**18.256 ms**, versus **89.934 ms** in the earlier baseline69 numeric B1 profile,
a roughly 80% reduction in this diagnostic family. This is consistent with the
explicit shape/max-use admission branches skipping unnecessary count traversals.
The diagnostic emitter stage declined from 1725.49 to 1627.40 ms. These were
separate single profiles, not paired clean timing samples; neither delta is an
independent measured causal gain.

| Inclusive sampled family, numeric B1 ms | Earlier baseline69 profile | Candidate profile |
|---|---:|---:|
| Occurrence membership | 395.500 | 370.574 |
| Product-use counts | 89.934 | 18.256 |
| Runtime template assembly | 71.813 | 74.938 |
| Erasure | 186.920 | 174.370 |
| Normalization | 143.355 | 141.431 |
| Index operations | 81.781 | 64.815 |
| Complete sampled profile | 2548.513 | 2435.939 |

Families overlap and must not be added. The remaining roughly 370 ms occurrence
family remains a larger investigation target than another compaction shortcut.
GC leaf samples were essentially flat, 270.683 versus 274.708 ms; this screen does
not establish an allocation improvement.

The independent compaction budget was also corrected: the saved B2 profiles show
only 17–20 ms in complete `nc_compact` stack unions, with roughly 5–6 ms under the
removable consumers. P70-005's estimated whole-request gain is **0–1%, likely below
0.5%** on those profiles. The earlier speculative 1–5% estimate was too broad;
[the baseline report](compilation-baseline.md) now uses the narrower evidence.

## Correctness, resources and limits

The checked candidate API is
`b546be56551d0c565f15616c06853baaff227779167bb405dc262dbdd2cdcb85`.
The baseline is
`674e7960c7e8957452ffb0bdc6cb1f69ddaf8c03814617277886d1551fe16553`.
The exact same host driver/runtime sources were required for both roles.

The compact-body controller passed **155 queries per role**, comparing actual
checked Bend helpers and full terms against the original expression. It covers
the fresh producer's fixed points, prepared and unprepared books, foreign and
intrinsic fallbacks, missing definitions, fresh IDs and stale facts. Append-only
diagnostic exports preserve the original checked API prefixes. These are focused
helper controls, not a claim of complete language conformance.

Clean-run peak RSS was approximately 392–413 MB across both roles. No clean
request approached the 2 GiB guard; the separate candidate profile peaked around
528 MB. Exact C identity preserves the previous runtime result for these three
specific emitted programs; there was no new native execution timing campaign in
this screen. Genuine candidate B2 generation and broader integration gates remain
separate work.

## Reproduction and identities

- Plan: `selfhost/build/phase70/compiler01-pair01/plan.json`, SHA256
  `a3572b5b86f4ee9da11a047f7710f3a4b5564d45ceb2f00ce1df5caf9a7bf1e3`.
- Complete clean/profile summary: `compiler01-pair01-summary.json`, SHA256
  `07ab41798c2196f17afae18f6726dc318288ea38472c85d75fbccb1cdb42e9e8`.
- Data-only candidate family reduction: `compiler01-pair01-families.json`, SHA256
  `095554512e0ec765dbbee5d93e94fe9be6558e2f72dc8b3fd345b1aee14ee00a`.
- Baseline family reduction: `compiler69-profile02-families.json`, SHA256
  `925fc546d8e3474397cdbe630c41af171c6cadeffa7385203717cd4f7df41248`.
- Paired helper report: `compiler01-compact-controls/report.json`, SHA256
  `19a8051e9d18f32669c963d820dc4a497738f8163fba90d01185aa1b15a99e2e`.

Paths without a prefix above are relative to `selfhost/build/phase70`. The methods
README records the serial guarded recipe. No targets were run to write this
report; it reduces retained root-owned executions.
