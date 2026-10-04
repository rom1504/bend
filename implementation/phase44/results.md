# Phase44 generated-program execution results

**Overall execution speed is effectively flat.** Across all 45 points, the fresh
Phase43 baseline is 6.1214× slower than pinned TypeScript and selected Phase44 is
6.0832× slower: a 1.0063× ratio of geometric means, or 0.62% less execution time.
This is not evidence of a broad speed breakthrough or TypeScript parity. All
**45 points, 23 source files and 669 samples passed**. Twenty point medians improved
and 25 regressed; 41 of 45 changes were within ±2%.

The baseline is Phase43 checked14; the candidate is Phase44 checked04. Both were
measured freshly against TypeScript pinned to
`018751270e800bc222a93dad7f257083ee53a5f7`. The rejected unchecked saved-JavaScript
known-call experiment is excluded. These results measure generated-program
execution; [compiler request costs](compiler-cost.md) are separate.

| Geometric weighting | Phase43 / TS | Phase44 / TS | Phase43 / Phase44 | Phase44 time change |
| --- | ---: | ---: | ---: | ---: |
| 45 points equally | 6.1214× | 6.0832× | 1.0063× | -0.62% |
| 23 sources equally | 8.3649× | 8.3015× | 1.0076× | -0.76% |
| 23 catalog families equally | 8.4746× | 8.4340× | 1.0048× | -0.48% |

Each point ratio divides the two roles’ median milliseconds per call. Point
weighting takes the geometric mean of those ratios. Source weighting first takes
the geometric mean within each identical source SHA-256, then weights the 23
sources equally; family weighting does the same with the catalog’s family labels.
These weightings are not total elapsed time or a distribution of typical programs.
The source/family partitions differ: Mandelbrot and raytrace each span two source
files, while local-row and scalar-region each span two family labels. Extra input
variations affect point weighting without giving their source extra source weight.

The largest observed reductions were Unicode text (8.32% and 9.75%) and two
raytrace points (5.68% and 8.92%). The third raytrace point improved 1.40%. These
are observations of the combined selected compiler; this run does not isolate
which IR transformation caused a change. Candidate medians beat TypeScript on
`coverage-closures-256` and `coverage-list-pipeline-512`; many other inputs still
have large deficits.

All 45 point medians follow, in **milliseconds per call**. A Phase44/TS ratio below
1 means faster than TypeScript; a Phase43/44 ratio above 1 means improvement over
the previous compiler. Percent change is `100 × (Phase44 / Phase43 − 1)`.
Ratios use full-precision medians, so recomputing from rounded table cells can differ.

| Point | TS ms | Phase43 ms | Phase44 ms | Phase43/TS | Phase44/TS | Phase43/44 | Time change |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| `local-pair` | 1.230539 | 2.634291 | 2.640704 | 2.1408× | 2.1460× | 0.9976× | +0.24% |
| `local-fold` | 0.038869 | 0.089520 | 0.089586 | 2.3031× | 2.3048× | 0.9993× | +0.07% |
| `scalar-region-0` | 0.000067 | 0.004121 | 0.004165 | 61.4287× | 62.0834× | 0.9895× | +1.07% |
| `scalar-region-8192` | 0.100222 | 0.115009 | 0.115022 | 1.1475× | 1.1477× | 0.9999× | +0.01% |
| `complete-generic-row32` | 0.006725 | 0.378108 | 0.378003 | 56.2259× | 56.2104× | 1.0003× | -0.03% |
| `mandelbrot` | 0.045352 | 0.168351 | 0.167978 | 3.7121× | 3.7038× | 1.0022× | -0.22% |
| `editdist` | 4.945415 | 10.473636 | 10.488216 | 2.1178× | 2.1208× | 0.9986× | +0.14% |
| `tree-bitonic` | 0.281926 | 0.346517 | 0.348798 | 1.2291× | 1.2372× | 0.9935× | +0.66% |
| `lexer` | 1.657418 | 11.848922 | 11.997808 | 7.1490× | 7.2389× | 0.9876× | +1.26% |
| `symreg` | 1.103740 | 1.948671 | 1.960093 | 1.7655× | 1.7759× | 0.9942× | +0.59% |
| `test-morning-program` | 0.003137 | 0.200268 | 0.197968 | 63.8310× | 63.0980× | 1.0116× | -1.15% |
| `test-evening-program` | 0.002615 | 0.128828 | 0.129871 | 49.2605× | 49.6592× | 0.9920× | +0.81% |
| `test-rle-roundtrip` | 0.000563 | 0.036243 | 0.036436 | 64.3980× | 64.7411× | 0.9947× | +0.53% |
| `test-map-set-ops` | 0.020871 | 1.470731 | 1.477993 | 70.4666× | 70.8146× | 0.9951× | +0.49% |
| `raytrace` | 34.147732 | 664.469247 | 626.741274 | 19.4587× | 18.3538× | 1.0602× | -5.68% |
| `variation-editdist-0-17` | 1.238011 | 2.633177 | 2.629193 | 2.1269× | 2.1237× | 1.0015× | -0.15% |
| `variation-editdist-3-123` | 9.902236 | 20.959306 | 20.864966 | 2.1166× | 2.1071× | 1.0045× | -0.45% |
| `variation-lexer-6-17` | 0.410997 | 3.027543 | 3.031774 | 7.3663× | 7.3766× | 0.9986× | +0.14% |
| `variation-lexer-10-123` | 6.640342 | 46.531547 | 46.100163 | 7.0074× | 6.9424× | 1.0094× | -0.93% |
| `variation-tree-bitonic-6-17` | 0.037610 | 0.072013 | 0.072898 | 1.9147× | 1.9382× | 0.9879× | +1.23% |
| `variation-tree-bitonic-9-123` | 0.692842 | 0.800026 | 0.801934 | 1.1547× | 1.1575× | 0.9976× | +0.24% |
| `variation-symreg-4-17` | 0.553474 | 0.984537 | 0.980793 | 1.7788× | 1.7721× | 1.0038× | -0.38% |
| `variation-symreg-7-123` | 1.860657 | 3.249865 | 3.271741 | 1.7466× | 1.7584× | 0.9933× | +0.67% |
| `variation-local-fold-128-0` | 0.001450 | 0.007426 | 0.007535 | 5.1222× | 5.1975× | 0.9855× | +1.47% |
| `variation-local-fold-8192-123` | 0.116240 | 0.173290 | 0.172869 | 1.4908× | 1.4872× | 1.0024× | -0.24% |
| `variation-mandelbrot-grid-4-7` | 0.015196 | 0.042706 | 0.042848 | 2.8103× | 2.8197× | 0.9967× | +0.33% |
| `variation-mandelbrot-grid-5-31` | 0.232327 | 0.423077 | 0.422696 | 1.8210× | 1.8194× | 1.0009× | -0.09% |
| `variation-ray-active-64-2440` | 0.300482 | 8.285673 | 7.546616 | 27.5746× | 25.1150× | 1.0979× | -8.92% |
| `variation-ray-active-256-2240` | 1.240228 | 32.637285 | 32.180625 | 26.3155× | 25.9473× | 1.0142× | -1.40% |
| `coverage-closures-64` | 0.005561 | 0.009469 | 0.009632 | 1.7029× | 1.7321× | 0.9831× | +1.72% |
| `coverage-closures-256` | 0.021231 | 0.009974 | 0.010043 | 0.4698× | 0.4730× | 0.9931× | +0.69% |
| `coverage-list-pipeline-128` | 0.006455 | 0.012615 | 0.012750 | 1.9542× | 1.9751× | 0.9894× | +1.07% |
| `coverage-list-pipeline-512` | 0.027419 | 0.015754 | 0.015603 | 0.5746× | 0.5691× | 1.0097× | -0.96% |
| `coverage-unicode-text-16` | 0.021584 | 0.500455 | 0.458809 | 23.1864× | 21.2569× | 1.0908× | -8.32% |
| `coverage-unicode-text-64` | 0.085973 | 2.096229 | 1.891892 | 24.3825× | 22.0058× | 1.1080× | -9.75% |
| `coverage-map-churn-32` | 0.141839 | 3.958518 | 3.975908 | 27.9085× | 28.0311× | 0.9956× | +0.44% |
| `coverage-map-churn-128` | 0.758616 | 17.713917 | 17.560122 | 23.3503× | 23.1476× | 1.0088× | -0.87% |
| `coverage-numeric-recurrence-256` | 0.002046 | 0.013660 | 0.013771 | 6.6758× | 6.7298× | 0.9920× | +0.81% |
| `coverage-numeric-recurrence-1024` | 0.007862 | 0.020250 | 0.020252 | 2.5757× | 2.5759× | 0.9999× | +0.01% |
| `coverage-bst-32` | 0.022042 | 0.077295 | 0.076733 | 3.5067× | 3.4813× | 1.0073× | -0.73% |
| `coverage-bst-64` | 0.050985 | 0.117500 | 0.119208 | 2.3046× | 2.3381× | 0.9857× | +1.45% |
| `coverage-expression-32` | 0.002034 | 0.019016 | 0.018951 | 9.3479× | 9.3162× | 1.0034× | -0.34% |
| `coverage-expression-128` | 0.008978 | 0.040264 | 0.040376 | 4.4845× | 4.4970× | 0.9972× | +0.28% |
| `coverage-record-aggregation-64` | 0.297507 | 21.148265 | 20.929213 | 71.0849× | 70.3486× | 1.0105× | -1.04% |
| `coverage-record-aggregation-256` | 1.340849 | 83.634103 | 82.492164 | 62.3740× | 61.5223× | 1.0138× | -1.37% |

Source groups below supply the equal-source aggregate. SHA-256 prefixes distinguish
exact source content; complete hashes remain in the summary and catalog.

| Source | SHA-256 prefix | Points | Phase43/TS | Phase44/TS | Phase43/44 |
| --- | --- | ---: | ---: | ---: | ---: |
| `bst.bend` | `db75d09ea4ee` | 2 | 2.8428× | 2.8530× | 0.9964× |
| `closures.bend` | `bc5fb44cba79` | 2 | 0.8944× | 0.9052× | 0.9881× |
| `editdist.bend` | `f9cc44d93829` | 3 | 2.1205× | 2.1172× | 1.0015× |
| `expression.bend` | `62f40333fa5e` | 2 | 6.4746× | 6.4726× | 1.0003× |
| `lexer.bend` | `6014af6bf7e9` | 3 | 7.1727× | 7.1837× | 0.9985× |
| `list-pipeline.bend` | `b4819808f26a` | 2 | 1.0596× | 1.0602× | 0.9995× |
| `local-fold.bend` | `d13b49747fbe` | 3 | 2.6005× | 2.6117× | 0.9957× |
| `local-row.bend` | `3987479425f7` | 2 | 10.9712× | 10.9830× | 0.9989× |
| `mandelbrot-grid.bend` | `f908b2daf26a` | 2 | 2.2622× | 2.2650× | 0.9988× |
| `mandelbrot.bend` | `cb2b9c30acee` | 1 | 3.7121× | 3.7038× | 1.0022× |
| `map-churn.bend` | `180fc1c2c966` | 2 | 25.5279× | 25.4726× | 1.0022× |
| `numeric-recurrence.bend` | `36f803ed8d88` | 2 | 4.1467× | 4.1636× | 0.9959× |
| `raytrace-active.bend` | `5ba03ffff01f` | 2 | 26.9377× | 25.5278× | 1.0552× |
| `raytrace.bend` | `4674b2580ace` | 1 | 19.4587× | 18.3538× | 1.0602× |
| `record-aggregation.bend` | `6b31a2cfc58f` | 2 | 66.5871× | 65.7876× | 1.0122× |
| `scalar-region.bend` | `5c1b7031be03` | 2 | 8.3960× | 8.4410× | 0.9947× |
| `symreg.bend` | `c25c8fb869ea` | 3 | 1.7636× | 1.7688× | 0.9971× |
| `test-evening-program.bend` | `b254a68ad020` | 1 | 49.2605× | 49.6592× | 0.9920× |
| `test-map-set-ops.bend` | `60966d2aa182` | 1 | 70.4666× | 70.8146× | 0.9951× |
| `test-morning-program.bend` | `903389771429` | 1 | 63.8310× | 63.0980× | 1.0116× |
| `test-rle-roundtrip.bend` | `ce4083dab9a8` | 1 | 64.3980× | 64.7411× | 0.9947× |
| `tree-bitonic.bend` | `ace0242c329b` | 3 | 1.3955× | 1.4053× | 0.9930× |
| `unicode-text.bend` | `e0dd8066deac` | 2 | 23.7769× | 21.6281× | 1.0994× |

Catalog-family groups below supply the equal-family aggregate.

| Family | Points | Sources | Phase43/TS | Phase44/TS | Phase43/44 |
| --- | ---: | ---: | ---: | ---: | ---: |
| `bst` | 2 | 1 | 2.8428× | 2.8530× | 0.9964× |
| `closures` | 2 | 1 | 0.8944× | 0.9052× | 0.9881× |
| `complete-generic-row32` | 1 | 1 | 56.2259× | 56.2104× | 1.0003× |
| `editdist` | 3 | 1 | 2.1205× | 2.1172× | 1.0015× |
| `expression` | 2 | 1 | 6.4746× | 6.4726× | 1.0003× |
| `lexer` | 3 | 1 | 7.1727× | 7.1837× | 0.9985× |
| `list-pipeline` | 2 | 1 | 1.0596× | 1.0602× | 0.9995× |
| `local-fold` | 3 | 1 | 2.6005× | 2.6117× | 0.9957× |
| `local-pair` | 1 | 1 | 2.1408× | 2.1460× | 0.9976× |
| `mandelbrot` | 3 | 2 | 2.6683× | 2.6685× | 0.9999× |
| `map-churn` | 2 | 1 | 25.5279× | 25.4726× | 1.0022× |
| `numeric-recurrence` | 2 | 1 | 4.1467× | 4.1636× | 0.9959× |
| `raytrace` | 3 | 2 | 24.1701× | 22.8692× | 1.0569× |
| `record-aggregation` | 2 | 1 | 66.5871× | 65.7876× | 1.0122× |
| `scalar-region-0` | 1 | 1 | 61.4287× | 62.0834× | 0.9895× |
| `scalar-region-8192` | 1 | 1 | 1.1475× | 1.1477× | 0.9999× |
| `symreg` | 3 | 1 | 1.7636× | 1.7688× | 0.9971× |
| `test-evening-program` | 1 | 1 | 49.2605× | 49.6592× | 0.9920× |
| `test-map-set-ops` | 1 | 1 | 70.4666× | 70.8146× | 0.9951× |
| `test-morning-program` | 1 | 1 | 63.8310× | 63.0980× | 1.0116× |
| `test-rle-roundtrip` | 1 | 1 | 64.3980× | 64.7411× | 0.9947× |
| `tree-bitonic` | 3 | 1 | 1.3955× | 1.4053× | 0.9930× |
| `unicode-text` | 2 | 1 | 23.7769× | 21.6281× | 1.0994× |

Three serial batches each covered 15 points with the 600-second protocol. Every
role used fresh processes in rotating role order, five rounds per point except
`raytrace`, which used three. Other points used at least three warmup calls;
`raytrace` used one, and all samples also required at least 1,000 ms warmup.
Calibration targeted 50 ms and timed samples targeted 300 ms. Node 24.18.0 ran
on CPU 3 with a 1,024 MiB heap limit, 2,048 MiB process-tree RSS limit and
2,048 MiB available-memory floor. Compilation was completed before timing.
Import and first-call costs were retained separately from steady-state ratios.
The three runner wall times totaled **1149.60 seconds (19.16 minutes)**.

The verified summary binds the exact portable manifests, source/module/compiler
hashes, node/resource/protocol settings, all raw sample/process receipts, exact
role rotation and globally nonoverlapping sample intervals. This report also
independently recomputed all 135 role medians and all point/source/family ratios
from the three raw batch reports; no target programs were rerun to write it.

Five rounds (three for raytrace) support a regression comparison, not a claim of
statistical significance. Small input points can emphasize fixed dispatch or
readback costs. The corpus covers varied maintained cases and input variations,
but is not a random sample of Bend programs or an untouched holdout after guiding
optimization. The small aggregate movement and mixed signs are best treated as
effectively flat performance. These measurements establish neither universal
conformance nor speed for native/GPU backends. Historical Phase43 timings are not
mixed into the fresh ratios.

Raw summary: `selfhost/build/phase44/full-runtime-summary04.json`.
Summary SHA-256: `ece87fc2158b3d5079673bf71b1cfa5a95b179a7607f510f614d80b49f6fdb03`.
Raw batch reports and identities:

| Raw report under `selfhost/build/phase44/` | SHA-256 |
| --- | --- |
| `runtime-full04-1/report.json` | `68dee19691d5823fc3998acadda507dd40ac99c1e2d50da2f336b6daec92f954` |
| `runtime-full04-2/report.json` | `69160de78215cee627abfe310791f08523312dc791cd7efa7784718b7472415d` |
| `runtime-full04-3/report.json` | `1796026400396233822d5e7e73183fd4397ebb37ef3d9eb3d91b9a3c149b0ff4` |

The [closed raw archive index](../../selfhost/tools/performance/phase44/evidence/raw/archive.json)
binds every raw file; the [published summary](../../selfhost/tools/performance/phase44/evidence/runtime-summary.json)
is an exact copy of the verified raw summary.
See the [phase report](README.md), [compiler cost report](compiler-cost.md), and
[portable benchmark guide](../../selfhost/tools/performance/phase44/README.md).
