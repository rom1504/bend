# Phase186 first target screen

The first candidate lowers geometric-mean runtime by **6.93% for QBE** and **19.63% for assembly** versus the retained Phase185 final N2 products on the selected ten cases. Each target was measured with its own same-campaign C denominator, three serial rotated rounds, and adaptive repetitions. This is a screen, not a full45 conclusion or a paired significance claim.

| Case | QBE runtime reduction | Assembly runtime reduction | Candidate QBE / C | Candidate assembly / C |
|---|---:|---:|---:|---:|
| local-pair | -0.09% | +27.99% | 1.253 | 9.179 |
| local-fold | +0.24% | +33.45% | 2.014 | 9.789 |
| coverage-numeric-recurrence-256 | -0.41% | +6.72% | 1.519 | 4.625 |
| tree-bitonic | +19.72% | +22.61% | 2.356 | 5.410 |
| coverage-map-churn-128 | +20.34% | +15.36% | 2.696 | 5.418 |
| coverage-unicode-text-64 | +8.64% | +22.46% | 2.637 | 4.340 |
| coverage-record-aggregation-256 | +11.11% | +10.53% | 2.255 | 4.271 |
| complete-generic-row32 | +6.72% | +14.58% | 3.419 | 4.685 |
| variation-ray-active-256-2240 | -0.61% | +8.54% | 0.960 | 5.919 |
| coverage-closures-256 | +0.21% | +29.18% | 0.072 | 0.250 |

Positive percentages mean less runtime. Small differences under one percent in this short screen do not establish improvement or regression. QBE map and tree improve about 20%; assembly improves all ten selected cases. Broad deficits remain: QBE still has eight cases above 1.1× C and six above 2×, while assembly has nine above each threshold.

Every retained stdout/stderr pin and exact expected result, warmup count, repetition count, and elapsed suffix was revalidated: QBE 90 timed samples + 102 pilots; assembly 90 timed samples + 86 pilots. All recorded runtime inputs were authenticated, for 1,104 distinct verified file pins across this analysis. Per-case summaries and aggregate values were recomputed; original reports were preserved.

The actual assembly local-fold positive loop shrinks from 123 to 80 instructions and from 29 to 12 explicit frame references. All 17 scratch LEAs, six indirect scratch loads, and eleven indirect scratch stores disappear. Direct frame loads/stores remain 8/4, and the native array load/store remains 1/1 with no calls on this path. Two Boolean materializations/checks and many scalar copies remain. The counts cover the positive iteration only and are static instructions, not retirement measurements. This supports the scratch-elimination mechanism behind the 33.45% local-fold improvement without isolating its causal contribution.

Compiler emission observations are diagnostics: current QBE preparation/emission totals are 47.787/6.322 seconds; assembly 46.247/25.016 seconds for the ten cases. Historical same-case subsets are 41.855/4.756 and 37.528/15.239 seconds respectively. API/compiler sources, surrounding case counts and order differ, and each is one observation; the historical QBE report is an authenticated 44+1 merge after a partial deadline. These values do not establish a balanced compiler slowdown. Current emitted text totals are 7,463,861 QBE bytes and 9,121,106 assembly bytes, versus historical 6,946,758 and 8,070,664; text size is not native code size.

Exact report and assembly pins, per-case ratios, equal-family/equal-source metrics, positive log deficits, threshold counts, projected fixed-catalog totals and excess, compiler rows, and counted instruction lists are retained in [first-screen-analysis.json](first-screen-analysis.json). No target jobs were executed during this analysis.
