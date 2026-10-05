# Phase 47 complete generated-program execution comparison

All **669 fresh samples passed across 45 points and 23 source files**. Equal-point execution time changes from **3.0851×** pinned TypeScript for Phase 45 worker23 to **2.9194×** for array06: a **1.0568×** geometric improvement. The equal-source result is **3.9958× TypeScript**. This is a modest corpus improvement with clear array wins and a substantial short-loop regression; TypeScript parity remains unmet.

These are generated-program execution results. Compiler request latency, correctness qualification and release installation are separate decisions in the [phase report](README.md).

## Protocol and weighting

Three complete 600-second-preset batches took 1135.36 s combined. Every ordinary point has five fresh rounds per role; raytrace has three. All three roles use Node 24.18.0 on CPU 3, a 1,024 MiB heap, 2,048 MiB process-tree RSS cap and 4,096 MiB available-memory floor. The Node stack is 4,096 KiB. Warmup is at least 1,000 ms and three calls (one call for raytrace), calibration 50 ms, and the target measurement window 300 ms. These are warmed repeated-execution windows, not a proof of stationarity. Compilation, import and first-call time are excluded from the table.

| Weighting | Worker23 / TypeScript | Array06 / TypeScript | Worker23 / array06 |
| --- | ---: | ---: | ---: |
| Equal point | 3.0851× | 2.9194× | 1.0568× |
| Equal source | 4.1699× | 3.9958× | 1.0436× |
| Equal family | 4.7316× | 4.4996× | 1.0516× |

Equal-point weighting gives each of the 45 same-point median ratios one geometric weight. Equal-source weighting first combines points with the same source SHA-256, then weights the 23 source groups equally. Equal-family weighting uses the catalog’s 23 family groups; it is a different partition. These are ratios of medians, not summed-work throughput or a distribution of all Bend programs.

## All 45 point medians

Times are milliseconds per call. Improvement above 1× means array06 takes less time than worker23; candidate / TS below 1× means it takes less time than TypeScript.

| Point | TypeScript ms | Worker23 ms | Array06 ms | Worker23 / TS | Array06 / TS | Improvement |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| `mandelbrot` | 0.045560 | 0.126358 | 0.125483 | 2.773× | 2.754× | 1.007× |
| `editdist` | 4.941182 | 10.500939 | 5.637582 | 2.125× | 1.141× | 1.863× |
| `tree-bitonic` | 0.272460 | 0.339185 | 0.353324 | 1.245× | 1.297× | 0.960× |
| `lexer` | 1.658648 | 2.469088 | 2.472347 | 1.489× | 1.491× | 0.999× |
| `symreg` | 1.099520 | 1.466241 | 1.467098 | 1.334× | 1.334× | 0.999× |
| `test-morning-program` | 0.003241 | 0.196932 | 0.198594 | 60.760× | 61.273× | 0.992× |
| `test-evening-program` | 0.002610 | 0.128495 | 0.130042 | 49.232× | 49.824× | 0.988× |
| `test-rle-roundtrip` | 0.000563 | 0.031429 | 0.031974 | 55.834× | 56.802× | 0.983× |
| `test-map-set-ops` | 0.020274 | 1.152702 | 1.166234 | 56.855× | 57.523× | 0.988× |
| `raytrace` | 34.186465 | 68.491400 | 59.534107 | 2.003× | 1.741× | 1.150× |
| `local-pair` | 1.231593 | 2.628979 | 1.501171 | 2.135× | 1.219× | 1.751× |
| `local-fold` | 0.039463 | 0.089617 | 0.060505 | 2.271× | 1.533× | 1.481× |
| `scalar-region-0` | 0.000067 | 0.004088 | 0.004081 | 60.911× | 60.795× | 1.002× |
| `scalar-region-8192` | 0.099363 | 0.114969 | 0.115224 | 1.157× | 1.160× | 0.998× |
| `complete-generic-row32` | 0.006791 | 0.376468 | 0.380003 | 55.439× | 55.959× | 0.991× |
| `variation-editdist-0-17` | 1.235935 | 2.642197 | 1.497513 | 2.138× | 1.212× | 1.764× |
| `variation-editdist-3-123` | 9.886487 | 20.899447 | 11.296469 | 2.114× | 1.143× | 1.850× |
| `variation-lexer-6-17` | 0.408099 | 0.633042 | 0.653415 | 1.551× | 1.601× | 0.969× |
| `variation-lexer-10-123` | 6.610104 | 9.886532 | 9.914223 | 1.496× | 1.500× | 0.997× |
| `variation-tree-bitonic-6-17` | 0.037135 | 0.071564 | 0.071935 | 1.927× | 1.937× | 0.995× |
| `variation-tree-bitonic-9-123` | 0.695665 | 0.843408 | 0.888601 | 1.212× | 1.277× | 0.949× |
| `variation-symreg-4-17` | 0.553826 | 0.777797 | 0.778061 | 1.404× | 1.405× | 1.000× |
| `variation-symreg-7-123` | 1.861053 | 2.491989 | 2.494584 | 1.339× | 1.340× | 0.999× |
| `variation-local-fold-128-0` | 0.001439 | 0.007603 | 0.014671 | 5.282× | 10.192× | 0.518× |
| `variation-local-fold-8192-123` | 0.114228 | 0.172845 | 0.109171 | 1.513× | 0.956× | 1.583× |
| `variation-mandelbrot-grid-4-7` | 0.015660 | 0.042602 | 0.042393 | 2.720× | 2.707× | 1.005× |
| `variation-mandelbrot-grid-5-31` | 0.231992 | 0.422423 | 0.418028 | 1.821× | 1.802× | 1.011× |
| `variation-ray-active-64-2440` | 0.300653 | 0.558707 | 0.560280 | 1.858× | 1.864× | 0.997× |
| `variation-ray-active-256-2240` | 1.245827 | 2.195739 | 2.200000 | 1.762× | 1.766× | 0.998× |
| `coverage-closures-64` | 0.005659 | 0.009670 | 0.009536 | 1.709× | 1.685× | 1.014× |
| `coverage-closures-256` | 0.021155 | 0.009989 | 0.009845 | 0.472× | 0.465× | 1.015× |
| `coverage-list-pipeline-128` | 0.006453 | 0.012244 | 0.012748 | 1.897× | 1.976× | 0.960× |
| `coverage-list-pipeline-512` | 0.027748 | 0.015517 | 0.015842 | 0.559× | 0.571× | 0.979× |
| `coverage-bst-32` | 0.022245 | 0.060121 | 0.060307 | 2.703× | 2.711× | 0.997× |
| `coverage-bst-64` | 0.050569 | 0.103336 | 0.104402 | 2.043× | 2.065× | 0.990× |
| `coverage-unicode-text-16` | 0.021311 | 0.091703 | 0.092738 | 4.303× | 4.352× | 0.989× |
| `coverage-unicode-text-64` | 0.086575 | 0.225445 | 0.228220 | 2.604× | 2.636× | 0.988× |
| `coverage-expression-32` | 0.002115 | 0.019018 | 0.019225 | 8.993× | 9.091× | 0.989× |
| `coverage-expression-128` | 0.008952 | 0.040664 | 0.041295 | 4.543× | 4.613× | 0.985× |
| `coverage-map-churn-32` | 0.141073 | 0.278569 | 0.278829 | 1.975× | 1.976× | 0.999× |
| `coverage-map-churn-128` | 0.758602 | 1.215499 | 1.163087 | 1.602× | 1.533× | 1.045× |
| `coverage-numeric-recurrence-256` | 0.002038 | 0.013744 | 0.013865 | 6.743× | 6.802× | 0.991× |
| `coverage-numeric-recurrence-1024` | 0.007623 | 0.020489 | 0.020687 | 2.688× | 2.714× | 0.990× |
| `coverage-record-aggregation-64` | 0.296484 | 0.491761 | 0.482445 | 1.659× | 1.627× | 1.019× |
| `coverage-record-aggregation-256` | 1.213782 | 1.957553 | 1.931930 | 1.613× | 1.592× | 1.013× |

## Improvements, regressions and remaining gap

Array06 has lower medians on **16 points**, higher medians on **29**, and beats TypeScript on **3**: `variation-local-fold-8192-123`, `coverage-closures-256`, `coverage-list-pipeline-512`. These sign counts are descriptive, not statistical tests.

The largest median improvements are:

- `editdist`: 1.863× improvement; 1.141× TypeScript time.
- `variation-editdist-3-123`: 1.850× improvement; 1.143× TypeScript time.
- `variation-editdist-0-17`: 1.764× improvement; 1.212× TypeScript time.
- `local-pair`: 1.751× improvement; 1.219× TypeScript time.
- `variation-local-fold-8192-123`: 1.583× improvement; 0.956× TypeScript time.
- `local-fold`: 1.481× improvement; 1.533× TypeScript time.

The largest regressions must remain visible:

- `variation-local-fold-128-0`: **92.97% more time**, 7.603 → 14.671 µs per call (1.930×).
- `variation-tree-bitonic-9-123`: **5.36% more time**, 843.408 → 888.601 µs per call (1.054×).
- `tree-bitonic`: **4.17% more time**, 339.185 → 353.324 µs per call (1.042×).
- `coverage-list-pipeline-128`: **4.12% more time**, 12.244 → 12.748 µs per call (1.041×).
- `variation-lexer-6-17`: **3.22% more time**, 633.042 → 653.415 µs per call (1.032×).

The 128-iteration fold regresses by about 1.93× while the longer fold cases improve. That is a measured size-dependent tradeoff, not a reason to hide the short case. The main tree-bitonic point regresses by 4.17%, and its larger variant by 5.36%. This run does not isolate an added per-call body or another cause for those tree regressions. The 29 higher medians cannot collectively be dismissed as noise; they require scope-aware follow-up, even though many differences are small.

The five largest remaining TypeScript ratios are:

- `test-morning-program`: 61.273× TypeScript time; 0.198594 ms per call.
- `scalar-region-0`: 60.795× TypeScript time; 0.004081 ms per call.
- `test-map-set-ops`: 57.523× TypeScript time; 1.166234 ms per call.
- `test-rle-roundtrip`: 56.802× TypeScript time; 0.031974 ms per call.
- `complete-generic-row32`: 55.959× TypeScript time; 0.380003 ms per call.

Maximum absolute half-window drift is 27.1% for worker23, 26.9% for array06 and 29.6% for TypeScript. Undefined one-call drift is excluded rather than treated as zero. No confidence interval or significance claim is supplied. Small absolute durations, JIT behavior and allocation can affect these observations; this complete run does not establish the cause of every change.

## Scope and evidence

This finite maintained corpus informed implementation and is not an untouched holdout. It covers the recorded sources and inputs, including scalar, array, higher-order and library cases; it does not cover every Bend program. Independent renamed correctness witnesses validate narrower mechanisms, not representative speed. The array04 corpus run is an earlier, separate comparison with separately measured baselines. No array04 or Phase 45 samples are pooled into these results, and successive aggregate ratios are not divided to invent a causal gain.

The [machine-readable evidence](evidence/runtime-summary.json) retains all per-point sample statistics, ratios, source/family groups and role identities. The [data-only renderer](evidence/render-runtime-results.py) rehashed every authoritative summary input and compiler identity, compared all 669 leaf receipts to their parent reports, recomputed 135 medians and all three weighting schemes, and verified serial sample intervals. It ran no compiler or emitted program.

Authoritative summary: `selfhost/build/phase47/corpus-array06/summary.json`, SHA-256 `c2ca577301584aa09893ce34aadac2c7b4d658a82e55f83d68bf9e090f0c2fae`. All raw paths below are evidence references, not GitHub links to ignored files:

- `selfhost/build/phase47/corpus-array06/runtime-0/report.json`: `500eb32e2111263acea64d56c2f5b472721cb3db59ac2b03a732c9f587d4852a`.
- `selfhost/build/phase47/corpus-array06/runtime-1/report.json`: `de08b6ce82a01a0197e3699355be9671ddabc764820b821ccf7984daaaa3d3d3`.
- `selfhost/build/phase47/corpus-array06/runtime-2/report.json`: `75b3f355f5e94517d0e679d667b4278c687c1443d857e10b789ab92b43118fc7`.

| Role | API SHA-256 | Runtime SHA-256 |
| --- | --- | --- |
| Phase 45 worker23 | `e77c504a9c91d9ae9d43e52f4f4899711eb7a8ebe707ee565348df2708488b4c` | `4f057842e476d01be5cfa06ad7984fea55ad2537b2fe6e861965a782e8b94c26` |
| Array06 | `28f9eb983b2ba3603a9af703d832d4a301efe32182b468e090db6b728a47d12f` | `880bce50e3194b9ee9d99bd57c18ef88bcb8925d9d1668dec6765040a4d3219b` |

All roles bind upstream `018751270e800bc222a93dad7f257083ee53a5f7` and the same Base source. Final installation and preservation status belongs to the [phase report](README.md).
