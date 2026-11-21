# Composed portfolio and live constructor runtime

All 45 cases are executed. Reference baselines are authenticated C and Phase197. Live/portfolio compares the same emitted N1 objects. The development partition describes the seven runtime-study families and does not establish an independent compiler holdout.

Runtime receipt: `/home/ai/bend2/build/publish/bend/selfhost/build/phase198/orbit-live-broad01/report.json`
Validated observations: {"pilots": 624, "samples": 720}.

Warning: Dispersion exceeds threshold: mandelbrot, lexer, test-morning-program, test-evening-program, scalar-region-8192, complete-generic-row32, variation-editdist-0-17, variation-editdist-3-123, variation-tree-bitonic-9-123, variation-symreg-4-17, variation-symreg-7-123, variation-local-fold-8192-123, variation-mandelbrot-grid-5-31, variation-ray-active-64-2440, variation-ray-active-256-2240, coverage-list-pipeline-128, coverage-list-pipeline-512, coverage-bst-32, coverage-unicode-text-16, coverage-map-churn-32, coverage-map-churn-128, coverage-numeric-recurrence-1024, coverage-record-aggregation-64

## all

45/45 cases observed; 44 ratio eligible.

| Role | Versus | Geomean | Mean positive log slowdown | >1.1× | >2× | Fixed-equivalent ms | Reference ms |
|---|---|---:|---:|---:|---:|---:|---:|
| c | overC | 1 | 0 | 0 | 0 | 10321.4 | 10321.4 |
| c | overBaseline | 0.542701 | 0.127831 | 4 | 2 | 10321.4 | 22586.1 |
| phase197 | overC | 1.84264 | 0.739029 | 37 | 26 | 22586.1 | 10321.4 |
| phase197 | overBaseline | 1 | 0 | 0 | 0 | 22586.1 | 22586.1 |
| candidate | overC | 1.28731 | 0.640213 | 35 | 22 | 19546.1 | 10321.4 |
| candidate | overBaseline | 0.698623 | 0.00709249 | 1 | 0 | 19546.1 | 22586.1 |
| live | overC | 1.27813 | 0.631827 | 34 | 21 | 19312.8 | 10321.4 |
| live | overBaseline | 0.693641 | 0.0146527 | 2 | 0 | 19312.8 | 22586.1 |

## development

16/16 cases observed; 16 ratio eligible.

| Role | Versus | Geomean | Mean positive log slowdown | >1.1× | >2× | Fixed-equivalent ms | Reference ms |
|---|---|---:|---:|---:|---:|---:|---:|
| c | overC | 1 | 0 | 0 | 0 | 3758.27 | 3758.27 |
| c | overBaseline | 0.390094 | 0 | 0 | 0 | 3758.27 | 9809.75 |
| phase197 | overC | 2.56349 | 0.941368 | 15 | 14 | 9809.75 | 3758.27 |
| phase197 | overBaseline | 1 | 0 | 0 | 0 | 9809.75 | 9809.75 |
| candidate | overC | 1.7392 | 0.792527 | 14 | 12 | 7792.9 | 3758.27 |
| candidate | overBaseline | 0.678452 | 0.000524295 | 0 | 0 | 7792.9 | 9809.75 |
| live | overC | 1.70293 | 0.773657 | 14 | 11 | 7595.29 | 3758.27 |
| live | overBaseline | 0.664303 | 0.00352897 | 0 | 0 | 7595.29 | 9809.75 |

## heldout

29/29 cases observed; 28 ratio eligible.

| Role | Versus | Geomean | Mean positive log slowdown | >1.1× | >2× | Fixed-equivalent ms | Reference ms |
|---|---|---:|---:|---:|---:|---:|---:|
| c | overC | 1 | 0 | 0 | 0 | 6563.14 | 6563.14 |
| c | overBaseline | 0.655387 | 0.200878 | 4 | 2 | 6563.14 | 12776.4 |
| phase197 | overC | 1.52582 | 0.623406 | 22 | 12 | 12776.4 | 6563.14 |
| phase197 | overBaseline | 1 | 0 | 0 | 0 | 12776.4 | 12776.4 |
| candidate | overC | 1.08397 | 0.553176 | 21 | 10 | 11753.2 | 6563.14 |
| candidate | overBaseline | 0.710418 | 0.0108457 | 1 | 0 | 11753.2 | 12776.4 |
| live | overC | 1.08483 | 0.550782 | 20 | 10 | 11717.5 | 6563.14 |
| live | overBaseline | 0.710984 | 0.0210092 | 2 | 0 | 11717.5 | 12776.4 |

## Per-case ratios

| Case | Partition | Role | / C | / baseline | Dispersion flag |
|---|---|---|---:|---:|---|
| mandelbrot | heldout | c | 1 | 0.262554 | True |
| mandelbrot | heldout | phase197 | 3.80874 | 1 | True |
| mandelbrot | heldout | candidate | 2.82804 | 0.742514 | True |
| mandelbrot | heldout | live | 2.85829 | 0.750456 | True |
| editdist | heldout | c | 1 | 0.612139 | False |
| editdist | heldout | phase197 | 1.63361 | 1 | False |
| editdist | heldout | candidate | 1.65712 | 1.01439 | False |
| editdist | heldout | live | 1.63361 | 1 | False |
| tree-bitonic | development | c | 1 | 0.320816 | False |
| tree-bitonic | development | phase197 | 3.11705 | 1 | False |
| tree-bitonic | development | candidate | 1.68351 | 0.540096 | False |
| tree-bitonic | development | live | 1.68563 | 0.540777 | False |
| lexer | development | c | 1 | 0.377905 | True |
| lexer | development | phase197 | 2.64617 | 1 | True |
| lexer | development | candidate | 2.64929 | 1.00118 | True |
| lexer | development | live | 2.6869 | 1.01539 | True |
| symreg | heldout | c | 1 | 0.912127 | False |
| symreg | heldout | phase197 | 1.09634 | 1 | False |
| symreg | heldout | candidate | 1.09649 | 1.00014 | False |
| symreg | heldout | live | 1.04985 | 0.9576 | False |
| test-morning-program | heldout | c | 1 | 0.299181 | True |
| test-morning-program | heldout | phase197 | 3.34246 | 1 | True |
| test-morning-program | heldout | candidate | 3.35082 | 1.0025 | True |
| test-morning-program | heldout | live | 3.39719 | 1.01638 | True |
| test-evening-program | heldout | c | 1 | 0.295896 | True |
| test-evening-program | heldout | phase197 | 3.37957 | 1 | True |
| test-evening-program | heldout | candidate | 3.34217 | 0.988935 | True |
| test-evening-program | heldout | live | 3.36768 | 0.996485 | True |
| test-rle-roundtrip | development | c | 1 | 0.419199 | False |
| test-rle-roundtrip | development | phase197 | 2.3855 | 1 | False |
| test-rle-roundtrip | development | candidate | 2.37945 | 0.997466 | False |
| test-rle-roundtrip | development | live | 2.42604 | 1.01699 | False |
| test-map-set-ops | heldout | c | 1 | 0.350615 | False |
| test-map-set-ops | heldout | phase197 | 2.85213 | 1 | False |
| test-map-set-ops | heldout | candidate | 2.97296 | 1.04237 | False |
| test-map-set-ops | heldout | live | 3.01058 | 1.05555 | False |
| raytrace | heldout | c | 1 | 0.597623 | False |
| raytrace | heldout | phase197 | 1.6733 | 1 | False |
| raytrace | heldout | candidate | 1.69886 | 1.01528 | False |
| raytrace | heldout | live | 1.65909 | 0.991511 | False |
| local-pair | heldout | c | 1 | 0.581153 | False |
| local-pair | heldout | phase197 | 1.72072 | 1 | False |
| local-pair | heldout | candidate | 1.63793 | 0.95189 | False |
| local-pair | heldout | live | 1.63773 | 0.951772 | False |
| local-fold | development | c | 1 | 0.495088 | False |
| local-fold | development | phase197 | 2.01984 | 1 | False |
| local-fold | development | candidate | 2.02516 | 1.00263 | False |
| local-fold | development | live | 2.0162 | 0.998195 | False |
| scalar-region-0 | heldout | c | ineligible | ineligible | False |
| scalar-region-0 | heldout | phase197 | ineligible | ineligible | False |
| scalar-region-0 | heldout | candidate | ineligible | ineligible | False |
| scalar-region-0 | heldout | live | ineligible | ineligible | False |
| scalar-region-8192 | heldout | c | 1 | 0.465764 | True |
| scalar-region-8192 | heldout | phase197 | 2.14701 | 1 | True |
| scalar-region-8192 | heldout | candidate | 0.000487138 | 0.000226891 | True |
| scalar-region-8192 | heldout | live | 0.000503512 | 0.000234518 | True |
| complete-generic-row32 | heldout | c | 1 | 0.311185 | True |
| complete-generic-row32 | heldout | phase197 | 3.21352 | 1 | True |
| complete-generic-row32 | heldout | candidate | 3.6682 | 1.14149 | True |
| complete-generic-row32 | heldout | live | 3.79109 | 1.17973 | True |
| variation-editdist-0-17 | heldout | c | 1 | 0.61286 | True |
| variation-editdist-0-17 | heldout | phase197 | 1.63169 | 1 | True |
| variation-editdist-0-17 | heldout | candidate | 1.61879 | 0.992092 | True |
| variation-editdist-0-17 | heldout | live | 1.63509 | 1.00208 | True |
| variation-editdist-3-123 | heldout | c | 1 | 0.588745 | True |
| variation-editdist-3-123 | heldout | phase197 | 1.69853 | 1 | True |
| variation-editdist-3-123 | heldout | candidate | 1.62061 | 0.954126 | True |
| variation-editdist-3-123 | heldout | live | 1.62214 | 0.955025 | True |
| variation-lexer-6-17 | development | c | 1 | 0.379798 | False |
| variation-lexer-6-17 | development | phase197 | 2.63298 | 1 | False |
| variation-lexer-6-17 | development | candidate | 2.63814 | 1.00196 | False |
| variation-lexer-6-17 | development | live | 2.68567 | 1.02001 | False |
| variation-lexer-10-123 | development | c | 1 | 0.386288 | False |
| variation-lexer-10-123 | development | phase197 | 2.58874 | 1 | False |
| variation-lexer-10-123 | development | candidate | 2.53838 | 0.980545 | False |
| variation-lexer-10-123 | development | live | 2.60046 | 1.00453 | False |
| variation-tree-bitonic-6-17 | development | c | 1 | 0.300847 | False |
| variation-tree-bitonic-6-17 | development | phase197 | 3.32394 | 1 | False |
| variation-tree-bitonic-6-17 | development | candidate | 2.06105 | 0.620061 | False |
| variation-tree-bitonic-6-17 | development | live | 1.95406 | 0.587872 | False |
| variation-tree-bitonic-9-123 | development | c | 1 | 0.347594 | True |
| variation-tree-bitonic-9-123 | development | phase197 | 2.87692 | 1 | True |
| variation-tree-bitonic-9-123 | development | candidate | 1.46295 | 0.508511 | True |
| variation-tree-bitonic-9-123 | development | live | 1.40609 | 0.488747 | True |
| variation-symreg-4-17 | heldout | c | 1 | 0.918343 | True |
| variation-symreg-4-17 | heldout | phase197 | 1.08892 | 1 | True |
| variation-symreg-4-17 | heldout | candidate | 1.10848 | 1.01796 | True |
| variation-symreg-4-17 | heldout | live | 1.05388 | 0.96782 | True |
| variation-symreg-7-123 | heldout | c | 1 | 0.805343 | True |
| variation-symreg-7-123 | heldout | phase197 | 1.24171 | 1 | True |
| variation-symreg-7-123 | heldout | candidate | 1.07984 | 0.86964 | True |
| variation-symreg-7-123 | heldout | live | 1.05174 | 0.847015 | True |
| variation-local-fold-128-0 | development | c | 1 | 0.352772 | False |
| variation-local-fold-128-0 | development | phase197 | 2.83469 | 1 | False |
| variation-local-fold-128-0 | development | candidate | 2.84037 | 1.002 | False |
| variation-local-fold-128-0 | development | live | 2.68134 | 0.945903 | False |
| variation-local-fold-8192-123 | development | c | 1 | 0.493939 | True |
| variation-local-fold-8192-123 | development | phase197 | 2.02454 | 1 | True |
| variation-local-fold-8192-123 | development | candidate | 2.02579 | 1.00062 | True |
| variation-local-fold-8192-123 | development | live | 2.02142 | 0.998456 | True |
| variation-mandelbrot-grid-4-7 | heldout | c | 1 | 0.356674 | False |
| variation-mandelbrot-grid-4-7 | heldout | phase197 | 2.80368 | 1 | False |
| variation-mandelbrot-grid-4-7 | heldout | candidate | 2.46793 | 0.880246 | False |
| variation-mandelbrot-grid-4-7 | heldout | live | 2.4362 | 0.868928 | False |
| variation-mandelbrot-grid-5-31 | heldout | c | 1 | 0.401992 | True |
| variation-mandelbrot-grid-5-31 | heldout | phase197 | 2.48761 | 1 | True |
| variation-mandelbrot-grid-5-31 | heldout | candidate | 1.14118 | 0.458747 | True |
| variation-mandelbrot-grid-5-31 | heldout | live | 1.13032 | 0.454378 | True |
| variation-ray-active-64-2440 | heldout | c | 1 | 0.599032 | True |
| variation-ray-active-64-2440 | heldout | phase197 | 1.66936 | 1 | True |
| variation-ray-active-64-2440 | heldout | candidate | 1.67211 | 1.00165 | True |
| variation-ray-active-64-2440 | heldout | live | 1.6794 | 1.00602 | True |
| variation-ray-active-256-2240 | heldout | c | 1 | 0.593112 | True |
| variation-ray-active-256-2240 | heldout | phase197 | 1.68602 | 1 | True |
| variation-ray-active-256-2240 | heldout | candidate | 1.74908 | 1.0374 | True |
| variation-ray-active-256-2240 | heldout | live | 1.69598 | 1.00591 | True |
| coverage-closures-64 | heldout | c | 1 | 12.919 | False |
| coverage-closures-64 | heldout | phase197 | 0.0774052 | 1 | False |
| coverage-closures-64 | heldout | candidate | 0.0769426 | 0.994024 | False |
| coverage-closures-64 | heldout | live | 0.0924194 | 1.19397 | False |
| coverage-closures-256 | heldout | c | 1 | 13.683 | False |
| coverage-closures-256 | heldout | phase197 | 0.0730834 | 1 | False |
| coverage-closures-256 | heldout | candidate | 0.0729403 | 0.998041 | False |
| coverage-closures-256 | heldout | live | 0.0764354 | 1.04586 | False |
| coverage-list-pipeline-128 | heldout | c | 1 | 1.26964 | True |
| coverage-list-pipeline-128 | heldout | phase197 | 0.787626 | 1 | True |
| coverage-list-pipeline-128 | heldout | candidate | 0.787992 | 1.00046 | True |
| coverage-list-pipeline-128 | heldout | live | 0.741989 | 0.942057 | True |
| coverage-list-pipeline-512 | heldout | c | 1 | 1.2349 | True |
| coverage-list-pipeline-512 | heldout | phase197 | 0.809784 | 1 | True |
| coverage-list-pipeline-512 | heldout | candidate | 0.832493 | 1.02804 | True |
| coverage-list-pipeline-512 | heldout | live | 0.743044 | 0.917582 | True |
| coverage-bst-32 | development | c | 1 | 0.234055 | True |
| coverage-bst-32 | development | phase197 | 4.27249 | 1 | True |
| coverage-bst-32 | development | candidate | 4.1179 | 0.963817 | True |
| coverage-bst-32 | development | live | 3.50319 | 0.819941 | True |
| coverage-bst-64 | development | c | 1 | 0.277688 | False |
| coverage-bst-64 | development | phase197 | 3.60116 | 1 | False |
| coverage-bst-64 | development | candidate | 2.82767 | 0.785213 | False |
| coverage-bst-64 | development | live | 2.44102 | 0.677842 | False |
| coverage-unicode-text-16 | heldout | c | 1 | 0.373069 | True |
| coverage-unicode-text-16 | heldout | phase197 | 2.68047 | 1 | True |
| coverage-unicode-text-16 | heldout | candidate | 2.67656 | 0.998542 | True |
| coverage-unicode-text-16 | heldout | live | 2.65999 | 0.992357 | True |
| coverage-unicode-text-64 | heldout | c | 1 | 0.384754 | False |
| coverage-unicode-text-64 | heldout | phase197 | 2.59907 | 1 | False |
| coverage-unicode-text-64 | heldout | candidate | 2.55542 | 0.983206 | False |
| coverage-unicode-text-64 | heldout | live | 2.45651 | 0.945152 | False |
| coverage-expression-32 | development | c | 1 | 0.887748 | False |
| coverage-expression-32 | development | phase197 | 1.12645 | 1 | False |
| coverage-expression-32 | development | candidate | 0.145682 | 0.129329 | False |
| coverage-expression-32 | development | live | 0.145105 | 0.128817 | False |
| coverage-expression-128 | development | c | 1 | 0.958365 | False |
| coverage-expression-128 | development | phase197 | 1.04344 | 1 | False |
| coverage-expression-128 | development | candidate | 0.149676 | 0.143444 | False |
| coverage-expression-128 | development | live | 0.145062 | 0.139022 | False |
| coverage-map-churn-32 | development | c | 1 | 0.271827 | True |
| coverage-map-churn-32 | development | phase197 | 3.67881 | 1 | True |
| coverage-map-churn-32 | development | candidate | 3.61122 | 0.981627 | True |
| coverage-map-churn-32 | development | live | 3.55157 | 0.965412 | True |
| coverage-map-churn-128 | development | c | 1 | 0.284395 | True |
| coverage-map-churn-128 | development | phase197 | 3.51623 | 1 | True |
| coverage-map-churn-128 | development | candidate | 3.06098 | 0.870528 | True |
| coverage-map-churn-128 | development | live | 3.39591 | 0.965779 | True |
| coverage-numeric-recurrence-256 | heldout | c | 1 | 0.680608 | False |
| coverage-numeric-recurrence-256 | heldout | phase197 | 1.46927 | 1 | False |
| coverage-numeric-recurrence-256 | heldout | candidate | 1.47756 | 1.00564 | False |
| coverage-numeric-recurrence-256 | heldout | live | 1.48319 | 1.00947 | False |
| coverage-numeric-recurrence-1024 | heldout | c | 1 | 0.692012 | True |
| coverage-numeric-recurrence-1024 | heldout | phase197 | 1.44506 | 1 | True |
| coverage-numeric-recurrence-1024 | heldout | candidate | 1.44699 | 1.00133 | True |
| coverage-numeric-recurrence-1024 | heldout | live | 1.43714 | 0.994522 | True |
| coverage-record-aggregation-64 | heldout | c | 1 | 0.349756 | True |
| coverage-record-aggregation-64 | heldout | phase197 | 2.85914 | 1 | True |
| coverage-record-aggregation-64 | heldout | candidate | 2.86499 | 1.00205 | True |
| coverage-record-aggregation-64 | heldout | live | 3.07134 | 1.07422 | True |
| coverage-record-aggregation-256 | heldout | c | 1 | 0.356612 | False |
| coverage-record-aggregation-256 | heldout | phase197 | 2.80417 | 1 | False |
| coverage-record-aggregation-256 | heldout | candidate | 2.81674 | 1.00448 | False |
| coverage-record-aggregation-256 | heldout | live | 2.90563 | 1.03618 | False |

## Worst regressions against frozen baseline

c: coverage-closures-256 13.683×, coverage-closures-64 12.919×, coverage-list-pipeline-128 1.26964×, coverage-list-pipeline-512 1.2349×.
phase197: none.
candidate: complete-generic-row32 1.14149×, test-map-set-ops 1.04237×, variation-ray-active-256-2240 1.0374×, coverage-list-pipeline-512 1.02804×, variation-symreg-4-17 1.01796×, raytrace 1.01528×, editdist 1.01439×, coverage-numeric-recurrence-256 1.00564×, coverage-record-aggregation-256 1.00448×, local-fold 1.00263×.
live: coverage-closures-64 1.19397×, complete-generic-row32 1.17973×, coverage-record-aggregation-64 1.07422×, test-map-set-ops 1.05555×, coverage-closures-256 1.04586×, coverage-record-aggregation-256 1.03618×, variation-lexer-6-17 1.02001×, test-rle-roundtrip 1.01699×, test-morning-program 1.01638×, lexer 1.01539×.

## Separate compiler API costs

No emission receipts supplied; compiler costs unmeasured here.

## Family and positive-excess diagnostics

| Subset | Role | Versus | Eligible families | Equal-family geomean | Positive fixed-catalog excess ms |
|---|---|---|---:|---:|---:|
| all | c | overC | 22 | 1 | 0 |
| all | c | overBaseline | 22 | 0.522616 | 167.367 |
| all | phase197 | overC | 22 | 1.91345 | 12432.1 |
| all | phase197 | overBaseline | 22 | 1 | 0 |
| all | candidate | overC | 22 | 1.13381 | 10151.1 |
| all | candidate | overBaseline | 22 | 0.592546 | 161.698 |
| all | live | overC | 22 | 1.13122 | 9938.33 |
| all | live | overBaseline | 22 | 0.591193 | 221.422 |
| development | c | overC | 7 | 1 | 0 |
| development | c | overBaseline | 7 | 0.394587 | 0 |
| development | phase197 | overC | 7 | 2.53429 | 6051.48 |
| development | phase197 | overBaseline | 7 | 1 | 0 |
| development | candidate | overC | 7 | 1.69687 | 4589.87 |
| development | candidate | overBaseline | 7 | 0.669565 | 3.98126 |
| development | live | overC | 7 | 1.66273 | 4393.96 |
| development | live | overBaseline | 7 | 0.656093 | 39.3352 |
| heldout | c | overC | 15 | 1 | 0 |
| heldout | c | overBaseline | 15 | 0.595846 | 167.367 |
| heldout | phase197 | overC | 15 | 1.67829 | 6380.58 |
| heldout | phase197 | overBaseline | 15 | 1 | 0 |
| heldout | candidate | overC | 15 | 0.939337 | 5561.21 |
| heldout | candidate | overBaseline | 15 | 0.559701 | 157.717 |
| heldout | live | overC | 15 | 0.945116 | 5544.36 |
| heldout | live | overBaseline | 15 | 0.563144 | 182.086 |
