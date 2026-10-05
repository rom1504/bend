# Phase48 complete generated-program execution comparison

All **669 fresh samples passed across 45 points and 23 source files**. Equal-point execution time changes from **2.9024×** pinned TypeScript for array06 to **2.6789×** for RNFA04. The baseline/candidate geometric ratio is **1.0834×**; above 1 means the candidate takes less time.

Generated-program execution, compiler request latency, semantic qualification and installation are separate results. This file asserts only the recorded runtime comparison.

## Protocol and weighting

The three 600-second-preset batches take 1132.24 s combined. Ordinary points use five fresh rotated rounds per role; raytrace uses three. Node 24.18.0 runs serially on CPU 3 with a 1,024 MiB heap, 2,048 MiB process-tree RSS ceiling, 4,096 MiB available-memory floor and 4,096 KiB stack. Warmup is at least 1,000 ms, calibration targets 50 ms and measurement targets 300 ms. These are warmed repeated-execution windows, not a stationarity proof. Compilation, import and first-call times are excluded from these medians.

| Weighting | Array06 / TS | Candidate / TS | Array06 / candidate |
| --- | ---: | ---: | ---: |
| Equal point | 2.9024× | 2.6789× | 1.0834× |
| Equal source | 3.9789× | 3.6793× | 1.0814× |
| Equal family | 4.4797× | 3.9121× | 1.1451× |

Each of 45 point median ratios has one geometric weight in the first row. The second first combines points sharing a source hash and then weights the 23 sources equally. The third uses the catalog family partition. These are not summed-work throughput or a distribution of every Bend program.

## All 45 point medians

Times are milliseconds per call. Candidate / TS below 1 means less time than TypeScript; improvement above 1 means less time than array06.

| Point | TypeScript ms | Array06 ms | Candidate ms | Array06 / TS | Candidate / TS | Improvement |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| `mandelbrot` | 0.045404 | 0.124531 | 0.125096 | 2.743× | 2.755× | 0.995× |
| `editdist` | 4.937586 | 5.636177 | 5.660244 | 1.141× | 1.146× | 0.996× |
| `tree-bitonic` | 0.275292 | 0.347795 | 0.355828 | 1.263× | 1.293× | 0.977× |
| `lexer` | 1.653958 | 2.467503 | 2.455320 | 1.492× | 1.485× | 1.005× |
| `symreg` | 1.099614 | 1.472101 | 1.472408 | 1.339× | 1.339× | 1.000× |
| `test-morning-program` | 0.003227 | 0.198087 | 0.199190 | 61.385× | 61.727× | 0.994× |
| `test-evening-program` | 0.002610 | 0.128795 | 0.128715 | 49.349× | 49.318× | 1.001× |
| `test-rle-roundtrip` | 0.000546 | 0.031406 | 0.031695 | 57.549× | 58.079× | 0.991× |
| `test-map-set-ops` | 0.020341 | 1.160447 | 1.162945 | 57.048× | 57.171× | 0.998× |
| `raytrace` | 34.253678 | 60.268500 | 59.444192 | 1.759× | 1.735× | 1.014× |
| `local-pair` | 1.229202 | 1.508069 | 1.492897 | 1.227× | 1.215× | 1.010× |
| `local-fold` | 0.038687 | 0.060372 | 0.060438 | 1.560× | 1.562× | 0.999× |
| `scalar-region-0` | 0.000068 | 0.004137 | 0.003994 | 60.835× | 58.733× | 1.036× |
| `scalar-region-8192` | 0.099638 | 0.115180 | 0.115079 | 1.156× | 1.155× | 1.001× |
| `complete-generic-row32` | 0.006766 | 0.377077 | 0.028000 | 55.728× | 4.138× | 13.467× |
| `variation-editdist-0-17` | 1.245994 | 1.499504 | 1.493013 | 1.203× | 1.198× | 1.004× |
| `variation-editdist-3-123` | 9.939734 | 11.300968 | 11.274666 | 1.137× | 1.134× | 1.002× |
| `variation-lexer-6-17` | 0.409102 | 0.631963 | 0.635524 | 1.545× | 1.553× | 0.994× |
| `variation-lexer-10-123` | 6.610454 | 9.902808 | 9.859727 | 1.498× | 1.492× | 1.004× |
| `variation-tree-bitonic-6-17` | 0.036708 | 0.073881 | 0.071642 | 2.013× | 1.952× | 1.031× |
| `variation-tree-bitonic-9-123` | 0.732122 | 0.806223 | 0.808914 | 1.101× | 1.105× | 0.997× |
| `variation-symreg-4-17` | 0.551146 | 0.775288 | 0.776229 | 1.407× | 1.408× | 0.999× |
| `variation-symreg-7-123` | 1.866793 | 2.517128 | 2.494660 | 1.348× | 1.336× | 1.009× |
| `variation-local-fold-128-0` | 0.001441 | 0.014191 | 0.014491 | 9.848× | 10.056× | 0.979× |
| `variation-local-fold-8192-123` | 0.114862 | 0.109357 | 0.109928 | 0.952× | 0.957× | 0.995× |
| `variation-mandelbrot-grid-4-7` | 0.015665 | 0.042762 | 0.042789 | 2.730× | 2.731× | 0.999× |
| `variation-mandelbrot-grid-5-31` | 0.232426 | 0.422868 | 0.416235 | 1.819× | 1.791× | 1.016× |
| `variation-ray-active-64-2440` | 0.301941 | 0.556480 | 0.558517 | 1.843× | 1.850× | 0.996× |
| `variation-ray-active-256-2240` | 1.246003 | 2.195092 | 2.196457 | 1.762× | 1.763× | 0.999× |
| `coverage-closures-64` | 0.005575 | 0.009460 | 0.009768 | 1.697× | 1.752× | 0.968× |
| `coverage-closures-256` | 0.021252 | 0.009965 | 0.009969 | 0.469× | 0.469× | 1.000× |
| `coverage-list-pipeline-128` | 0.006516 | 0.012746 | 0.012545 | 1.956× | 1.925× | 1.016× |
| `coverage-list-pipeline-512` | 0.027739 | 0.015460 | 0.015845 | 0.557× | 0.571× | 0.976× |
| `coverage-bst-32` | 0.023379 | 0.060894 | 0.062125 | 2.605× | 2.657× | 0.980× |
| `coverage-bst-64` | 0.053631 | 0.112946 | 0.112546 | 2.106× | 2.099× | 1.004× |
| `coverage-unicode-text-16` | 0.021462 | 0.092268 | 0.073396 | 4.299× | 3.420× | 1.257× |
| `coverage-unicode-text-64` | 0.085711 | 0.227133 | 0.155334 | 2.650× | 1.812× | 1.462× |
| `coverage-expression-32` | 0.002055 | 0.018761 | 0.018978 | 9.131× | 9.236× | 0.989× |
| `coverage-expression-128` | 0.008943 | 0.041287 | 0.041339 | 4.617× | 4.623× | 0.999× |
| `coverage-map-churn-32` | 0.141616 | 0.278331 | 0.267517 | 1.965× | 1.889× | 1.040× |
| `coverage-map-churn-128` | 0.761407 | 1.164922 | 1.062997 | 1.530× | 1.396× | 1.096× |
| `coverage-numeric-recurrence-256` | 0.002043 | 0.013696 | 0.013020 | 6.705× | 6.374× | 1.052× |
| `coverage-numeric-recurrence-1024` | 0.007827 | 0.020240 | 0.019055 | 2.586× | 2.434× | 1.062× |
| `coverage-record-aggregation-64` | 0.300314 | 0.512559 | 0.467495 | 1.707× | 1.557× | 1.096× |
| `coverage-record-aggregation-256` | 1.244616 | 1.956829 | 1.784953 | 1.572× | 1.434× | 1.096× |

## Improvements, regressions and remaining gap

The candidate has lower medians on **23 points**, higher medians on **22**, and exact ties on **0**. It beats TypeScript on **3** points: `variation-local-fold-8192-123`, `coverage-closures-256`, `coverage-list-pipeline-512`. These sign counts are descriptive, not statistical tests.

Largest observed improvements:

- `complete-generic-row32`: 13.467× improvement; 4.138× TypeScript time.
- `coverage-unicode-text-64`: 1.462× improvement; 1.812× TypeScript time.
- `coverage-unicode-text-16`: 1.257× improvement; 3.420× TypeScript time.
- `coverage-record-aggregation-64`: 1.096× improvement; 1.557× TypeScript time.
- `coverage-record-aggregation-256`: 1.096× improvement; 1.434× TypeScript time.
- `coverage-map-churn-128`: 1.096× improvement; 1.396× TypeScript time.

Largest observed regressions:

- `coverage-closures-64`: **3.25% more time**, 9.460 → 9.768 µs/call.
- `coverage-list-pipeline-512`: **2.49% more time**, 15.460 → 15.845 µs/call.
- `tree-bitonic`: **2.31% more time**, 347.795 → 355.828 µs/call.
- `variation-local-fold-128-0`: **2.12% more time**, 14.191 → 14.491 µs/call.
- `coverage-bst-32`: **2.02% more time**, 60.894 → 62.125 µs/call.
- `coverage-expression-32`: **1.16% more time**, 18.761 → 18.978 µs/call.

Largest remaining TypeScript ratios:

- `test-morning-program`: 61.727× TypeScript time; 0.199190 ms/call.
- `scalar-region-0`: 58.733× TypeScript time; 0.003994 ms/call.
- `test-rle-roundtrip`: 58.079× TypeScript time; 0.031695 ms/call.
- `test-map-set-ops`: 57.171× TypeScript time; 1.162945 ms/call.
- `test-evening-program`: 49.318× TypeScript time; 0.128715 ms/call.
- `variation-local-fold-128-0`: 10.056× TypeScript time; 0.014491 ms/call.

Maximum absolute half-window drift is 36.15% for array06, 47.87% for the candidate and 14.25% for TypeScript. Undefined one-call drift is excluded. No confidence interval or significance claim is supplied; observed regressions are not collectively dismissed as noise, and this comparison does not isolate every cause.

## Scope and evidence

This finite maintained corpus informed implementation and is not an untouched holdout. Independent renamed controls qualify particular mechanisms, not representative speed. No earlier phase, screen, profile or counter-derivative samples are pooled here. Prior aggregate ratios are not divided to manufacture a causal improvement.

The [machine-readable evidence](evidence/runtime-summary.json) preserves every median, ratio, raw summary, paired round ratio and source/family grouping. The data-only renderer rehashes all authoritative inputs, agrees with all 669 leaf/process receipts, independently recomputes 135 medians and three geometric weighting schemes, and verifies serial sample intervals. It executes no compiler or generated program.

Authoritative summary: `selfhost/build/phase48/corpus-rnfa04/summary.json`, SHA-256 `9683ebbed241b110bd4eb59003a69985238b3bf6aca4df0cbb27e197405917c8`. Raw report references:

- `selfhost/build/phase48/corpus-rnfa04/runtime-0/report.json`: `99988c1ad1d40c87dec2bea0fd4ef403dc0336196c55b28a1140810bbc4667d4`.
- `selfhost/build/phase48/corpus-rnfa04/runtime-1/report.json`: `f4b7900e2ef7a36e765115822003127cde230b5bf8fe7af861a06d670370581a`.
- `selfhost/build/phase48/corpus-rnfa04/runtime-2/report.json`: `0e1e0b428b9eb9c55eca0cc2ae1992b09fb5246f3e02d3880439c9471e334e3f`.

| Role | API SHA-256 | Runtime SHA-256 |
| --- | --- | --- |
| Array06 | `28f9eb983b2ba3603a9af703d832d4a301efe32182b468e090db6b728a47d12f` | `880bce50e3194b9ee9d99bd57c18ef88bcb8925d9d1668dec6765040a4d3219b` |
| RNFA04 | `6f9d111aa68c19f3ce45b80785621d57c4d10efb12d50164f5cb0597bc952100` | `880bce50e3194b9ee9d99bd57c18ef88bcb8925d9d1668dec6765040a4d3219b` |

All roles bind upstream `018751270e800bc222a93dad7f257083ee53a5f7` and the recorded Base source. Installation, preservation and semantic qualification belong to the [phase report](README.md).
