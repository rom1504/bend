# Phase42 checked16 results

**Universal TypeScript parity was not achieved.** Checked16 substantially improves the selected tree, list and numeric BST traversals, but only **one of45 measured points** is faster than pinned TS: list pipeline512, at0.605× TS time. None reaches half TS time. Lexer, Map, text, raytrace and record programs retain large gaps. These results describe the selected canonical checked16 candidate; this account makes no installation or release-admission claim.

The [closed full 45 report](../../selfhost/build/phase42/final-results02/report.json) passes45 points across23 exact source paths and23 catalog families, with669 fresh role samples. The [full results table](full-results-table.md) contains every median, min/max, paired-round range and available half drift; [runtime ratios](runtime-ratios.svg) shows the per-point comparison. The closed measurement uses Phase41 checked01 versus checked16 versus pinned TS commit `018751270e800bc222a93dad7f257083ee53a5f7`. It validates original checksums/results for each sample; deeper complete-value, alias, descriptor, reentry and bounded-stack obligations are covered by separately bound semantic controls.

## Where execution improved and where it did not

The following are exact quotients of same-run role medians. Baseline/candidate above1 means improvement; candidate/TS below1 means faster than TS. Times are milliseconds per call. This table deliberately preserves individual input points rather than treating their sizes as independent application families.

| Point (size, seed) | Phase41 ms | Checked16 ms | TS ms | Phase41/checked16 | Checked16/TS |
| --- | ---: | ---: | ---: | ---: | ---: |
| tree-bitonic (8,0) | 2.684228 | 0.348165 | 0.284768 | 7.709654× | 1.222623× |
| variation-tree-bitonic-6-17 (6,17) | 0.453590 | 0.072350 | 0.037244 | 6.269355× | 1.942618× |
| variation-tree-bitonic-9-123 (9,123) | 6.396230 | 0.798078 | 0.696189 | 8.014539× | 1.146353× |
| coverage-list-pipeline-128 (128,17) | 0.038539 | 0.014147 | 0.006346 | 2.724161× | 2.229313× |
| coverage-list-pipeline-512 (512,123) | 0.110247 | 0.016590 | 0.027438 | 6.645372× | 0.604645× |
| coverage-bst-32 (32,0) | 4.378545 | 0.185090 | 0.022130 | 23.656284× | 8.363864× |
| coverage-bst-64 (64,17) | 9.243239 | 0.342850 | 0.051551 | 26.959986× | 6.650717× |
| lexer (8,0) | 154.534104 | 151.764635 | 1.671261 | 1.018248× | 90.808454× |
| variation-lexer-6-17 (6,17) | 35.927011 | 36.199750 | 0.410260 | 0.992466× | 88.236102× |
| variation-lexer-10-123 (10,123) | 543.997391 | 557.078028 | 6.613096 | 0.976519× | 84.238609× |
| coverage-map-churn-32 (32,17) | 13.635742 | 13.520159 | 0.143436 | 1.008549× | 94.259080× |
| coverage-map-churn-128 (128,123) | 70.722199 | 69.945997 | 0.765352 | 1.011097× | 91.390619× |
| coverage-unicode-text-16 (16,17) | 0.473325 | 0.466291 | 0.021311 | 1.015084× | 21.880295× |
| coverage-unicode-text-64 (64,123) | 1.957018 | 1.994142 | 0.085691 | 0.981383× | 23.271238× |
| raytrace (80,0) | 701.411405 | 676.190620 | 34.214569 | 1.037298× | 19.763237× |
| variation-ray-active-64-2440 (64,2440) | 8.383568 | 8.441848 | 0.304508 | 0.993096× | 27.722935× |
| variation-ray-active-256-2240 (256,2240) | 33.890778 | 32.769099 | 1.246353 | 1.034230× | 26.291989× |
| coverage-record-aggregation-64 (64,17) | 20.607158 | 20.703736 | 0.298428 | 0.995335× | 69.375989× |
| coverage-record-aggregation-256 (256,123) | 80.958445 | 80.912525 | 1.212277 | 1.000568× | 66.744261× |

Tree gains6.27–8.01× over Phase41, yet remains1.15–1.94× slower than TS. List gains2.72×/6.65×; size128 remains2.23× slower than TS while size512 wins. BST gains23.66×/26.96×, reducing179–198× TS deficits to6.65–8.36×. Its baseline32 half-drift reaches56.64%; these are observed median quotients with reported variability, not variance-free speed guarantees.

Lexer retains84–91× TS deficits, Map91–94×, Unicode text22–23×, raytrace20–28× and records67–69×. Their small same-run changes do not demonstrate solved mechanisms or parity. The native String comparison ablation had little headroom and the Map dispatch proposal regressed; both stayed outside promoted source changes. The real scalar-island raytrace entry remains protected: its colf/rowf wrappers and private helpers are byte-identical to Phase39, while changed runtime/generic helper sections are explicitly recorded in the successor static gate. Remaining gaps require a new falsifiable mechanism rather than extrapolating tree/list wins.

## Corpus aggregates and limits

Across all 45 points,30 candidate medians are lower than baseline and7 show at least2× baseline improvement. One is faster than TS, and the same one is within10% of TS by the descriptive <=1.1 threshold. Strict median counts are not statistical significance or parity proofs.

| Geometric-mean weighting | Phase41/TS | Checked16/TS | Phase41/checked16 |
| --- | ---: | ---: | ---: |
| All 45 points, equal point weight | 12.569165× | 8.861833× | 1.418348× |
| 23 exact source paths, equal source weight | 15.395822× | 11.420699× | 1.348063× |
| 23 catalog family labels, equal family weight | 15.521582× | 11.555746× | 1.343192× |

The point-weighted geometric mean gives each catalog input point equal weight, so families with more sizes/seeds contribute more points. Source-weighted means first take the geometric mean within each of23 exact source paths, then weight those23 groups equally. Family weighting instead uses the catalog's23 family labels, whose grouping differs from source paths. All three use quotients of role medians, not elapsed-time totals. None is a “typical program” statistic, language-wide estimate or evidence that8.86× is the cost of an arbitrary workload.

Each point normally has five balanced fresh rounds; the expensive original raytrace point has three, producing669 role samples. Same-number round ratios and min/max are descriptive, not confidence intervals. Warmup/calibration and within-sample half drift remain recorded. Missing expensive-point half measurements are preserved as null/NA with known/missing counts; unavailable drift does not establish stability.

## Expression128 regression and separate confirmation

The original45-point measurement retains a **+10.98%** candidate median regression for expression128: baseline0.040384ms [0.040246–0.055068], candidate0.044820ms [0.040505–0.046471]. Their ranges overlap. Maximum absolute half drift is42.04% baseline and13.17% candidate, with signed raw values retained.

The separate [60-second expression confirmation](../../selfhost/build/phase42/integration03/expression-confirmation01/report.json) passes three fresh balanced rounds on the same image and includes expression32 and local-fold controls. Expression128 there has baseline0.043702ms [0.043388–0.043752] and candidate0.044799ms [0.043064–0.048668]: **+2.51%**, again with overlap. Half drift still reaches11.90% baseline and10.65% candidate. This follow-up reduces the observed median difference; it does not replace the original45-point result, prove a zero effect or establish that the regression is solely noise. Both receipts remain part of the evidence.

## Cost, complexity and qualification boundaries

The final [compiler-cost gate](compiler-cost.md) passes36 exact independently acquired outputs. Tree/numeric request medians improve6.17%/6.03%, pair/list regress5.79%/6.69%, and median RSS rises0.24–0.82%. No experiment isolates a cache-only causal gain. The frozen [complexity account](complexity.md) records+1158 compiler lines/+141 definitions/+66676bytes, with no new source modules/types/laws; runtime adds3 lines/251bytes for inert Nat.add metadata. These maintenance and compiler-cost increases are material tradeoffs.

All 45 selected emitted-module contents differ, across23 source paths, partly because runtime support changes. Independently deduplicating each role by module SHA gives24 unique contents and2731196→2915206 generated bytes. This generated-output volume is separate from source complexity and does not mean every program received a new optimization. Protected legacy regions and focused mutation/ownership controls prevent broad source proof from serving as blanket permission.

Checked16 API is `63ddb2dd35554aafafc26dbdff4aba86b5d3774cd0d99a9509ccf237d210ba54`; runtime is `6dbda18f176702557041530652690601c32b09261327ad49af7bf0cc8e7fb81c`. Phase41 baseline API is `9900abf49719575db7f7bbee32c6b16e10bcd554f9de22cde0799eb859cc6f0b`. The raw closure/render and semantic integration bind their exact sources, modules, tools and attempts. Publication, final independent review, installation and postinstall checks are separate obligations; this results account does not claim they have completed.
