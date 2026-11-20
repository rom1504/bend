# Phase198 split runtime on 45 current programs

Current N1 program objects are identical in both runtime arms. Same-block mature Bend C reference. Development covers all members of seven families used to choose the split runtime. Timed execution uses the maintained complete-output and count protocol.

Runtime receipt: `/home/ai/bend2/build/publish/bend/selfhost/build/phase198/runtime-split-broad01/report.json`
Validated observations: {"pilots": 625, "samples": 720}.

Warning: Dispersion exceeds threshold: mandelbrot, editdist, tree-bitonic, test-morning-program, test-evening-program, raytrace, local-fold, complete-generic-row32, variation-symreg-4-17, variation-symreg-7-123, variation-local-fold-8192-123, variation-mandelbrot-grid-5-31, variation-ray-active-64-2440, variation-ray-active-256-2240, coverage-closures-64, coverage-list-pipeline-128, coverage-bst-32, coverage-unicode-text-16, coverage-expression-32, coverage-expression-128, coverage-map-churn-128, coverage-record-aggregation-64

## all

45/45 cases observed; 44 ratio eligible.

| Role | Versus | Geomean | Mean positive log slowdown | >1.1× | >2× | Fixed-equivalent ms | Reference ms |
|---|---|---:|---:|---:|---:|---:|---:|
| c | overC | 1 | 0 | 0 | 0 | 10490.3 | 10490.3 |
| c | overBaseline | 0.534834 | 0.128679 | 4 | 2 | 10490.3 | 23531.9 |
| baseline | overC | 1.86974 | 0.754479 | 38 | 25 | 23531.9 | 10490.3 |
| baseline | overBaseline | 1 | 0 | 0 | 0 | 23531.9 | 23531.9 |
| candidate | overC | 1.82435 | 0.730816 | 36 | 25 | 22684.9 | 10490.3 |
| candidate | overBaseline | 0.975725 | 0.0192037 | 2 | 0 | 22684.9 | 23531.9 |
| live | overC | 1.83586 | 0.734911 | 36 | 25 | 22802.4 | 10490.3 |
| live | overBaseline | 0.981882 | 0.0179702 | 2 | 0 | 22802.4 | 23531.9 |

## development

16/16 cases observed; 16 ratio eligible.

| Role | Versus | Geomean | Mean positive log slowdown | >1.1× | >2× | Fixed-equivalent ms | Reference ms |
|---|---|---:|---:|---:|---:|---:|---:|
| c | overC | 1 | 0 | 0 | 0 | 3877.82 | 3877.82 |
| c | overBaseline | 0.38279 | 0 | 0 | 0 | 3877.82 | 10382 |
| baseline | overC | 2.6124 | 0.960269 | 16 | 13 | 10382 | 3877.82 |
| baseline | overBaseline | 1 | 0 | 0 | 0 | 10382 | 10382 |
| candidate | overC | 2.53223 | 0.932534 | 14 | 13 | 9937.92 | 3877.82 |
| candidate | overBaseline | 0.969311 | 0.0330294 | 1 | 0 | 9937.92 | 10382 |
| live | overC | 2.55438 | 0.937809 | 14 | 13 | 9941.88 | 3877.82 |
| live | overBaseline | 0.97779 | 0.031391 | 1 | 0 | 9941.88 | 10382 |

## heldout

29/29 cases observed; 28 ratio eligible.

| Role | Versus | Geomean | Mean positive log slowdown | >1.1× | >2× | Fixed-equivalent ms | Reference ms |
|---|---|---:|---:|---:|---:|---:|---:|
| c | overC | 1 | 0 | 0 | 0 | 6612.5 | 6612.5 |
| c | overBaseline | 0.647476 | 0.202209 | 4 | 2 | 6612.5 | 13149.9 |
| baseline | overC | 1.54446 | 0.636884 | 22 | 12 | 13149.9 | 6612.5 |
| baseline | overBaseline | 1 | 0 | 0 | 0 | 13149.9 | 13149.9 |
| candidate | overC | 1.51266 | 0.615549 | 22 | 12 | 12747 | 6612.5 |
| candidate | overBaseline | 0.979409 | 0.0113034 | 1 | 0 | 12747 | 13149.9 |
| live | overC | 1.5201 | 0.618969 | 22 | 12 | 12860.5 | 6612.5 |
| live | overBaseline | 0.984227 | 0.0103012 | 1 | 0 | 12860.5 | 13149.9 |

## Per-case ratios

| Case | Partition | Role | / C | / baseline | Dispersion flag |
|---|---|---|---:|---:|---|
| mandelbrot | heldout | c | 1 | 0.290496 | True |
| mandelbrot | heldout | baseline | 3.44239 | 1 | True |
| mandelbrot | heldout | candidate | 3.44658 | 1.00122 | True |
| mandelbrot | heldout | live | 3.46416 | 1.00632 | True |
| editdist | heldout | c | 1 | 0.584976 | True |
| editdist | heldout | baseline | 1.70947 | 1 | True |
| editdist | heldout | candidate | 1.71541 | 1.00347 | True |
| editdist | heldout | live | 1.51123 | 0.884032 | True |
| tree-bitonic | development | c | 1 | 0.276296 | True |
| tree-bitonic | development | baseline | 3.6193 | 1 | True |
| tree-bitonic | development | candidate | 3.31485 | 0.915881 | True |
| tree-bitonic | development | live | 2.98843 | 0.825691 | True |
| lexer | development | c | 1 | 0.377017 | False |
| lexer | development | baseline | 2.6524 | 1 | False |
| lexer | development | candidate | 2.62639 | 0.990196 | False |
| lexer | development | live | 2.70441 | 1.01961 | False |
| symreg | heldout | c | 1 | 0.930297 | False |
| symreg | heldout | baseline | 1.07493 | 1 | False |
| symreg | heldout | candidate | 1.06055 | 0.98663 | False |
| symreg | heldout | live | 1.04985 | 0.976676 | False |
| test-morning-program | heldout | c | 1 | 0.295695 | True |
| test-morning-program | heldout | baseline | 3.38186 | 1 | True |
| test-morning-program | heldout | candidate | 3.49751 | 1.0342 | True |
| test-morning-program | heldout | live | 3.49101 | 1.03227 | True |
| test-evening-program | heldout | c | 1 | 0.245996 | True |
| test-evening-program | heldout | baseline | 4.0651 | 1 | True |
| test-evening-program | heldout | candidate | 3.88704 | 0.956197 | True |
| test-evening-program | heldout | live | 4.01747 | 0.988283 | True |
| test-rle-roundtrip | development | c | 1 | 0.405732 | False |
| test-rle-roundtrip | development | baseline | 2.46468 | 1 | False |
| test-rle-roundtrip | development | candidate | 2.42373 | 0.983383 | False |
| test-rle-roundtrip | development | live | 2.47864 | 1.00567 | False |
| test-map-set-ops | heldout | c | 1 | 0.33017 | False |
| test-map-set-ops | heldout | baseline | 3.02874 | 1 | False |
| test-map-set-ops | heldout | candidate | 3.0439 | 1.005 | False |
| test-map-set-ops | heldout | live | 2.96147 | 0.977789 | False |
| raytrace | heldout | c | 1 | 0.548905 | True |
| raytrace | heldout | baseline | 1.82181 | 1 | True |
| raytrace | heldout | candidate | 1.55851 | 0.855474 | True |
| raytrace | heldout | live | 1.57181 | 0.862774 | True |
| local-pair | heldout | c | 1 | 0.611608 | False |
| local-pair | heldout | baseline | 1.63504 | 1 | False |
| local-pair | heldout | candidate | 1.64549 | 1.00639 | False |
| local-pair | heldout | live | 1.63809 | 1.00187 | False |
| local-fold | development | c | 1 | 0.493432 | True |
| local-fold | development | baseline | 2.02662 | 1 | True |
| local-fold | development | candidate | 3.15691 | 1.55772 | True |
| local-fold | development | live | 2.88774 | 1.42491 | True |
| scalar-region-0 | heldout | c | ineligible | ineligible | False |
| scalar-region-0 | heldout | baseline | ineligible | ineligible | False |
| scalar-region-0 | heldout | candidate | ineligible | ineligible | False |
| scalar-region-0 | heldout | live | ineligible | ineligible | False |
| scalar-region-8192 | heldout | c | 1 | 0.463837 | False |
| scalar-region-8192 | heldout | baseline | 2.15593 | 1 | False |
| scalar-region-8192 | heldout | candidate | 2.144 | 0.994466 | False |
| scalar-region-8192 | heldout | live | 2.14735 | 0.99602 | False |
| complete-generic-row32 | heldout | c | 1 | 0.285009 | True |
| complete-generic-row32 | heldout | baseline | 3.50866 | 1 | True |
| complete-generic-row32 | heldout | candidate | 3.47153 | 0.989418 | True |
| complete-generic-row32 | heldout | live | 3.2797 | 0.934744 | True |
| variation-editdist-0-17 | heldout | c | 1 | 0.613598 | False |
| variation-editdist-0-17 | heldout | baseline | 1.62973 | 1 | False |
| variation-editdist-0-17 | heldout | candidate | 1.63811 | 1.00514 | False |
| variation-editdist-0-17 | heldout | live | 1.62973 | 1 | False |
| variation-editdist-3-123 | heldout | c | 1 | 0.614403 | False |
| variation-editdist-3-123 | heldout | baseline | 1.6276 | 1 | False |
| variation-editdist-3-123 | heldout | candidate | 1.63736 | 1.006 | False |
| variation-editdist-3-123 | heldout | live | 1.62922 | 1.001 | False |
| variation-lexer-6-17 | development | c | 1 | 0.374511 | False |
| variation-lexer-6-17 | development | baseline | 2.67015 | 1 | False |
| variation-lexer-6-17 | development | candidate | 2.62843 | 0.984375 | False |
| variation-lexer-6-17 | development | live | 2.69623 | 1.00977 | False |
| variation-lexer-10-123 | development | c | 1 | 0.378934 | False |
| variation-lexer-10-123 | development | baseline | 2.63898 | 1 | False |
| variation-lexer-10-123 | development | candidate | 2.6129 | 0.990119 | False |
| variation-lexer-10-123 | development | live | 2.7 | 1.02312 | False |
| variation-tree-bitonic-6-17 | development | c | 1 | 0.307418 | False |
| variation-tree-bitonic-6-17 | development | baseline | 3.2529 | 1 | False |
| variation-tree-bitonic-6-17 | development | candidate | 3.00891 | 0.924994 | False |
| variation-tree-bitonic-6-17 | development | live | 2.98015 | 0.916154 | False |
| variation-tree-bitonic-9-123 | development | c | 1 | 0.32648 | False |
| variation-tree-bitonic-9-123 | development | baseline | 3.06297 | 1 | False |
| variation-tree-bitonic-9-123 | development | candidate | 2.7608 | 0.901345 | False |
| variation-tree-bitonic-9-123 | development | live | 2.76774 | 0.903613 | False |
| variation-symreg-4-17 | heldout | c | 1 | 0.922947 | True |
| variation-symreg-4-17 | heldout | baseline | 1.08349 | 1 | True |
| variation-symreg-4-17 | heldout | candidate | 1.04964 | 0.968762 | True |
| variation-symreg-4-17 | heldout | live | 1.08672 | 1.00298 | True |
| variation-symreg-7-123 | heldout | c | 1 | 0.825394 | True |
| variation-symreg-7-123 | heldout | baseline | 1.21154 | 1 | True |
| variation-symreg-7-123 | heldout | candidate | 1.19731 | 0.988252 | True |
| variation-symreg-7-123 | heldout | live | 1.20337 | 0.993252 | True |
| variation-local-fold-128-0 | development | c | 1 | 0.350675 | False |
| variation-local-fold-128-0 | development | baseline | 2.85164 | 1 | False |
| variation-local-fold-128-0 | development | candidate | 2.94591 | 1.03306 | False |
| variation-local-fold-128-0 | development | live | 2.67606 | 0.938427 | False |
| variation-local-fold-8192-123 | development | c | 1 | 0.516276 | True |
| variation-local-fold-8192-123 | development | baseline | 1.93695 | 1 | True |
| variation-local-fold-8192-123 | development | candidate | 1.93565 | 0.999331 | True |
| variation-local-fold-8192-123 | development | live | 1.93271 | 0.997812 | True |
| variation-mandelbrot-grid-4-7 | heldout | c | 1 | 0.352064 | False |
| variation-mandelbrot-grid-4-7 | heldout | baseline | 2.84039 | 1 | False |
| variation-mandelbrot-grid-4-7 | heldout | candidate | 2.78015 | 0.978791 | False |
| variation-mandelbrot-grid-4-7 | heldout | live | 2.79663 | 0.984592 | False |
| variation-mandelbrot-grid-5-31 | heldout | c | 1 | 0.388289 | True |
| variation-mandelbrot-grid-5-31 | heldout | baseline | 2.5754 | 1 | True |
| variation-mandelbrot-grid-5-31 | heldout | candidate | 2.14707 | 0.833683 | True |
| variation-mandelbrot-grid-5-31 | heldout | live | 2.51685 | 0.977266 | True |
| variation-ray-active-64-2440 | heldout | c | 1 | 0.545199 | True |
| variation-ray-active-64-2440 | heldout | baseline | 1.83419 | 1 | True |
| variation-ray-active-64-2440 | heldout | candidate | 1.65721 | 0.903508 | True |
| variation-ray-active-64-2440 | heldout | live | 1.71726 | 0.936248 | True |
| variation-ray-active-256-2240 | heldout | c | 1 | 0.59443 | True |
| variation-ray-active-256-2240 | heldout | baseline | 1.68228 | 1 | True |
| variation-ray-active-256-2240 | heldout | candidate | 1.67354 | 0.994801 | True |
| variation-ray-active-256-2240 | heldout | live | 1.68348 | 1.00071 | True |
| coverage-closures-64 | heldout | c | 1 | 12.9973 | True |
| coverage-closures-64 | heldout | baseline | 0.076939 | 1 | True |
| coverage-closures-64 | heldout | candidate | 0.0909587 | 1.18222 | True |
| coverage-closures-64 | heldout | live | 0.0885811 | 1.15132 | True |
| coverage-closures-256 | heldout | c | 1 | 13.7901 | False |
| coverage-closures-256 | heldout | baseline | 0.0725156 | 1 | False |
| coverage-closures-256 | heldout | candidate | 0.0757867 | 1.04511 | False |
| coverage-closures-256 | heldout | live | 0.0760126 | 1.04823 | False |
| coverage-list-pipeline-128 | heldout | c | 1 | 1.35569 | True |
| coverage-list-pipeline-128 | heldout | baseline | 0.73763 | 1 | True |
| coverage-list-pipeline-128 | heldout | candidate | 0.677372 | 0.918309 | True |
| coverage-list-pipeline-128 | heldout | live | 0.698633 | 0.947132 | True |
| coverage-list-pipeline-512 | heldout | c | 1 | 1.18395 | False |
| coverage-list-pipeline-512 | heldout | baseline | 0.844631 | 1 | False |
| coverage-list-pipeline-512 | heldout | candidate | 0.755515 | 0.894491 | False |
| coverage-list-pipeline-512 | heldout | live | 0.781865 | 0.925688 | False |
| coverage-bst-32 | development | c | 1 | 0.238115 | True |
| coverage-bst-32 | development | baseline | 4.19964 | 1 | True |
| coverage-bst-32 | development | candidate | 3.30123 | 0.786075 | True |
| coverage-bst-32 | development | live | 3.47243 | 0.82684 | True |
| coverage-bst-64 | development | c | 1 | 0.278867 | False |
| coverage-bst-64 | development | baseline | 3.58594 | 1 | False |
| coverage-bst-64 | development | candidate | 3.09078 | 0.861917 | False |
| coverage-bst-64 | development | live | 3.2241 | 0.899097 | False |
| coverage-unicode-text-16 | heldout | c | 1 | 0.375549 | True |
| coverage-unicode-text-16 | heldout | baseline | 2.66277 | 1 | True |
| coverage-unicode-text-16 | heldout | candidate | 2.50028 | 0.938978 | True |
| coverage-unicode-text-16 | heldout | live | 2.53557 | 0.952229 | True |
| coverage-unicode-text-64 | heldout | c | 1 | 0.390207 | False |
| coverage-unicode-text-64 | heldout | baseline | 2.56274 | 1 | False |
| coverage-unicode-text-64 | heldout | candidate | 2.42982 | 0.948134 | False |
| coverage-unicode-text-64 | heldout | live | 2.46404 | 0.961488 | False |
| coverage-expression-32 | development | c | 1 | 0.875781 | True |
| coverage-expression-32 | development | baseline | 1.14184 | 1 | True |
| coverage-expression-32 | development | candidate | 1.06169 | 0.929808 | True |
| coverage-expression-32 | development | live | 1.08109 | 0.946794 | True |
| coverage-expression-128 | development | c | 1 | 0.888139 | True |
| coverage-expression-128 | development | baseline | 1.12595 | 1 | True |
| coverage-expression-128 | development | candidate | 0.946538 | 0.840658 | True |
| coverage-expression-128 | development | live | 1.09615 | 0.973532 | True |
| coverage-map-churn-32 | development | c | 1 | 0.277727 | False |
| coverage-map-churn-32 | development | baseline | 3.60066 | 1 | False |
| coverage-map-churn-32 | development | candidate | 3.36102 | 0.933447 | False |
| coverage-map-churn-32 | development | live | 3.46844 | 0.96328 | False |
| coverage-map-churn-128 | development | c | 1 | 0.275474 | True |
| coverage-map-churn-128 | development | baseline | 3.63011 | 1 | True |
| coverage-map-churn-128 | development | candidate | 3.82663 | 1.05413 | True |
| coverage-map-churn-128 | development | live | 3.97398 | 1.09473 | True |
| coverage-numeric-recurrence-256 | heldout | c | 1 | 0.679606 | False |
| coverage-numeric-recurrence-256 | heldout | baseline | 1.47144 | 1 | False |
| coverage-numeric-recurrence-256 | heldout | candidate | 1.46847 | 0.997984 | False |
| coverage-numeric-recurrence-256 | heldout | live | 1.48055 | 1.00619 | False |
| coverage-numeric-recurrence-1024 | heldout | c | 1 | 0.688721 | False |
| coverage-numeric-recurrence-1024 | heldout | baseline | 1.45197 | 1 | False |
| coverage-numeric-recurrence-1024 | heldout | candidate | 1.45589 | 1.0027 | False |
| coverage-numeric-recurrence-1024 | heldout | live | 1.44837 | 0.997524 | False |
| coverage-record-aggregation-64 | heldout | c | 1 | 0.348326 | True |
| coverage-record-aggregation-64 | heldout | baseline | 2.87087 | 1 | True |
| coverage-record-aggregation-64 | heldout | candidate | 2.91084 | 1.01392 | True |
| coverage-record-aggregation-64 | heldout | live | 2.95157 | 1.02811 | True |
| coverage-record-aggregation-256 | heldout | c | 1 | 0.351462 | False |
| coverage-record-aggregation-256 | heldout | baseline | 2.84526 | 1 | False |
| coverage-record-aggregation-256 | heldout | candidate | 2.92511 | 1.02806 | False |
| coverage-record-aggregation-256 | heldout | live | 2.9083 | 1.02216 | False |

## Worst regressions against frozen baseline

c: coverage-closures-256 13.7901×, coverage-closures-64 12.9973×, coverage-list-pipeline-128 1.35569×, coverage-list-pipeline-512 1.18395×.
baseline: none.
candidate: local-fold 1.55772×, coverage-closures-64 1.18222×, coverage-map-churn-128 1.05413×, coverage-closures-256 1.04511×, test-morning-program 1.0342×, variation-local-fold-128-0 1.03306×, coverage-record-aggregation-256 1.02806×, coverage-record-aggregation-64 1.01392×, local-pair 1.00639×, variation-editdist-3-123 1.006×.
live: local-fold 1.42491×, coverage-closures-64 1.15132×, coverage-map-churn-128 1.09473×, coverage-closures-256 1.04823×, test-morning-program 1.03227×, coverage-record-aggregation-64 1.02811×, variation-lexer-10-123 1.02312×, coverage-record-aggregation-256 1.02216×, lexer 1.01961×, variation-lexer-6-17 1.00977×.

## Separate compiler API costs

No emission receipts supplied; compiler costs unmeasured here.

## Family and positive-excess diagnostics

| Subset | Role | Versus | Eligible families | Equal-family geomean | Positive fixed-catalog excess ms |
|---|---|---|---:|---:|---:|
| all | c | overC | 22 | 1 | 0 |
| all | c | overBaseline | 22 | 0.512225 | 172.046 |
| all | baseline | overC | 22 | 1.95227 | 13213.6 |
| all | baseline | overBaseline | 22 | 1 | 0 |
| all | candidate | overC | 22 | 1.90833 | 12406.5 |
| all | candidate | overBaseline | 22 | 0.977495 | 322.506 |
| all | live | overC | 22 | 1.92032 | 12498.2 |
| all | live | overBaseline | 22 | 0.983634 | 301.718 |
| development | c | overC | 7 | 1 | 0 |
| development | c | overBaseline | 7 | 0.387012 | 0 |
| development | baseline | overC | 7 | 2.5839 | 6504.13 |
| development | baseline | overBaseline | 7 | 1 | 0 |
| development | candidate | overC | 7 | 2.48044 | 6078.94 |
| development | candidate | overBaseline | 7 | 0.959961 | 267.662 |
| development | live | overC | 7 | 2.52184 | 6064.05 |
| development | live | overBaseline | 7 | 0.975983 | 247.684 |
| heldout | c | overC | 15 | 1 | 0 |
| heldout | c | overBaseline | 15 | 0.583809 | 172.046 |
| heldout | baseline | overC | 15 | 1.71289 | 6709.48 |
| heldout | baseline | overBaseline | 15 | 1 | 0 |
| heldout | candidate | overC | 15 | 1.68854 | 6327.57 |
| heldout | candidate | overBaseline | 15 | 0.985787 | 54.8438 |
| heldout | live | overC | 15 | 1.69101 | 6434.12 |
| heldout | live | overBaseline | 15 | 0.987226 | 54.034 |
