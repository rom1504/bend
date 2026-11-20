# Composed portfolio and live constructor runtime

All 45 cases are executed. Reference baselines are authenticated C and Phase197. Live/portfolio compares the same emitted N1 objects. The development partition describes the seven runtime-study families and does not establish an independent compiler holdout.

Runtime receipt: `/home/ai/bend2/build/publish/bend/selfhost/build/phase198/portfolio-live-broad01/report.json`
Validated observations: {"pilots": 616, "samples": 720}.

Warning: Dispersion exceeds threshold: mandelbrot, tree-bitonic, lexer, test-rle-roundtrip, test-map-set-ops, raytrace, local-pair, local-fold, variation-editdist-0-17, variation-symreg-7-123, coverage-closures-64, coverage-unicode-text-16, coverage-expression-32, coverage-map-churn-32, coverage-numeric-recurrence-256

## all

45/45 cases observed; 44 ratio eligible.

| Role | Versus | Geomean | Mean positive log slowdown | >1.1× | >2× | Fixed-equivalent ms | Reference ms |
|---|---|---:|---:|---:|---:|---:|---:|
| c | overC | 1 | 0 | 0 | 0 | 10306.6 | 10306.6 |
| c | overBaseline | 0.533348 | 0.121738 | 4 | 2 | 10306.6 | 22900.3 |
| phase197 | overC | 1.87495 | 0.75032 | 36 | 25 | 22900.3 | 10306.6 |
| phase197 | overBaseline | 1 | 0 | 0 | 0 | 22900.3 | 22900.3 |
| candidate | overC | 1.57487 | 0.664225 | 34 | 22 | 20107.1 | 10306.6 |
| candidate | overBaseline | 0.839953 | 0.00537631 | 1 | 0 | 20107.1 | 22900.3 |
| live | overC | 1.54663 | 0.646596 | 34 | 21 | 19721.4 | 10306.6 |
| live | overBaseline | 0.824891 | 0.00900111 | 1 | 0 | 19721.4 | 22900.3 |

## development

16/16 cases observed; 16 ratio eligible.

| Role | Versus | Geomean | Mean positive log slowdown | >1.1× | >2× | Fixed-equivalent ms | Reference ms |
|---|---|---:|---:|---:|---:|---:|---:|
| c | overC | 1 | 0 | 0 | 0 | 3820.31 | 3820.31 |
| c | overBaseline | 0.387304 | 0 | 0 | 0 | 3820.31 | 10115.5 |
| phase197 | overC | 2.58195 | 0.948546 | 15 | 13 | 10115.5 | 3820.31 |
| phase197 | overBaseline | 1 | 0 | 0 | 0 | 10115.5 | 10115.5 |
| candidate | overC | 1.75946 | 0.804224 | 14 | 11 | 8039.34 | 3820.31 |
| candidate | overBaseline | 0.681444 | 0.00296714 | 0 | 0 | 8039.34 | 10115.5 |
| live | overC | 1.6992 | 0.771334 | 14 | 10 | 7713.93 | 3820.31 |
| live | overBaseline | 0.658108 | 0.00398693 | 0 | 0 | 7713.93 | 10115.5 |

## heldout

29/29 cases observed; 28 ratio eligible.

| Role | Versus | Geomean | Mean positive log slowdown | >1.1× | >2× | Fixed-equivalent ms | Reference ms |
|---|---|---:|---:|---:|---:|---:|---:|
| c | overC | 1 | 0 | 0 | 0 | 6486.27 | 6486.27 |
| c | overBaseline | 0.640347 | 0.191302 | 4 | 2 | 6486.27 | 12784.8 |
| phase197 | overC | 1.56165 | 0.637048 | 21 | 12 | 12784.8 | 6486.27 |
| phase197 | overBaseline | 1 | 0 | 0 | 0 | 12784.8 | 12784.8 |
| candidate | overC | 1.47822 | 0.584226 | 20 | 11 | 12067.7 | 6486.27 |
| candidate | overBaseline | 0.946574 | 0.00675298 | 1 | 0 | 12067.7 | 12784.8 |
| live | overC | 1.46568 | 0.575316 | 20 | 11 | 12007.4 | 6486.27 |
| live | overBaseline | 0.938541 | 0.0118664 | 1 | 0 | 12007.4 | 12784.8 |

## Per-case ratios

| Case | Partition | Role | / C | / baseline | Dispersion flag |
|---|---|---|---:|---:|---|
| mandelbrot | heldout | c | 1 | 0.293733 | True |
| mandelbrot | heldout | phase197 | 3.40445 | 1 | True |
| mandelbrot | heldout | candidate | 2.56713 | 0.754052 | True |
| mandelbrot | heldout | live | 2.55219 | 0.749664 | True |
| editdist | heldout | c | 1 | 0.611226 | False |
| editdist | heldout | phase197 | 1.63606 | 1 | False |
| editdist | heldout | candidate | 1.62937 | 0.99591 | False |
| editdist | heldout | live | 1.63509 | 0.999411 | False |
| tree-bitonic | development | c | 1 | 0.29994 | True |
| tree-bitonic | development | phase197 | 3.334 | 1 | True |
| tree-bitonic | development | candidate | 1.77054 | 0.531056 | True |
| tree-bitonic | development | live | 1.70891 | 0.512569 | True |
| lexer | development | c | 1 | 0.374619 | True |
| lexer | development | phase197 | 2.66938 | 1 | True |
| lexer | development | candidate | 2.6691 | 0.999895 | True |
| lexer | development | live | 2.69173 | 1.00837 | True |
| symreg | heldout | c | 1 | 0.932088 | False |
| symreg | heldout | phase197 | 1.07286 | 1 | False |
| symreg | heldout | candidate | 1.07066 | 0.997949 | False |
| symreg | heldout | live | 1.04568 | 0.974665 | False |
| test-morning-program | heldout | c | 1 | 0.293708 | False |
| test-morning-program | heldout | phase197 | 3.40474 | 1 | False |
| test-morning-program | heldout | candidate | 3.40912 | 1.00129 | False |
| test-morning-program | heldout | live | 3.44352 | 1.01139 | False |
| test-evening-program | heldout | c | 1 | 0.24875 | False |
| test-evening-program | heldout | phase197 | 4.02011 | 1 | False |
| test-evening-program | heldout | candidate | 3.96558 | 0.986437 | False |
| test-evening-program | heldout | live | 4.01768 | 0.999395 | False |
| test-rle-roundtrip | development | c | 1 | 0.417065 | True |
| test-rle-roundtrip | development | phase197 | 2.39771 | 1 | True |
| test-rle-roundtrip | development | candidate | 2.41229 | 1.00608 | True |
| test-rle-roundtrip | development | live | 2.44323 | 1.01898 | True |
| test-map-set-ops | heldout | c | 1 | 0.33771 | True |
| test-map-set-ops | heldout | phase197 | 2.96112 | 1 | True |
| test-map-set-ops | heldout | candidate | 2.88996 | 0.975967 | True |
| test-map-set-ops | heldout | live | 2.94094 | 0.993183 | True |
| raytrace | heldout | c | 1 | 0.506541 | True |
| raytrace | heldout | phase197 | 1.97418 | 1 | True |
| raytrace | heldout | candidate | 1.74175 | 0.882267 | True |
| raytrace | heldout | live | 1.69871 | 0.860465 | True |
| local-pair | heldout | c | 1 | 0.601974 | True |
| local-pair | heldout | phase197 | 1.6612 | 1 | True |
| local-pair | heldout | candidate | 1.625 | 0.978206 | True |
| local-pair | heldout | live | 1.62822 | 0.980147 | True |
| local-fold | development | c | 1 | 0.505985 | True |
| local-fold | development | phase197 | 1.97635 | 1 | True |
| local-fold | development | candidate | 1.79313 | 0.907298 | True |
| local-fold | development | live | 1.75243 | 0.886703 | True |
| scalar-region-0 | heldout | c | ineligible | ineligible | False |
| scalar-region-0 | heldout | phase197 | ineligible | ineligible | False |
| scalar-region-0 | heldout | candidate | ineligible | ineligible | False |
| scalar-region-0 | heldout | live | ineligible | ineligible | False |
| scalar-region-8192 | heldout | c | 1 | 0.469089 | False |
| scalar-region-8192 | heldout | phase197 | 2.13179 | 1 | False |
| scalar-region-8192 | heldout | candidate | 2.41203 | 1.13146 | False |
| scalar-region-8192 | heldout | live | 2.39763 | 1.1247 | False |
| complete-generic-row32 | heldout | c | 1 | 0.301581 | False |
| complete-generic-row32 | heldout | phase197 | 3.31586 | 1 | False |
| complete-generic-row32 | heldout | candidate | 3.22205 | 0.97171 | False |
| complete-generic-row32 | heldout | live | 3.21593 | 0.969863 | False |
| variation-editdist-0-17 | heldout | c | 1 | 0.611588 | True |
| variation-editdist-0-17 | heldout | phase197 | 1.63509 | 1 | True |
| variation-editdist-0-17 | heldout | candidate | 1.63504 | 0.999971 | True |
| variation-editdist-0-17 | heldout | live | 1.63953 | 1.00272 | True |
| variation-editdist-3-123 | heldout | c | 1 | 0.597643 | False |
| variation-editdist-3-123 | heldout | phase197 | 1.67324 | 1 | False |
| variation-editdist-3-123 | heldout | candidate | 1.64538 | 0.983346 | False |
| variation-editdist-3-123 | heldout | live | 1.63879 | 0.979408 | False |
| variation-lexer-6-17 | development | c | 1 | 0.378298 | False |
| variation-lexer-6-17 | development | phase197 | 2.64342 | 1 | False |
| variation-lexer-6-17 | development | candidate | 2.6632 | 1.00748 | False |
| variation-lexer-6-17 | development | live | 2.69441 | 1.01929 | False |
| variation-lexer-10-123 | development | c | 1 | 0.379722 | False |
| variation-lexer-10-123 | development | phase197 | 2.63351 | 1 | False |
| variation-lexer-10-123 | development | candidate | 2.64295 | 1.00359 | False |
| variation-lexer-10-123 | development | live | 2.67203 | 1.01463 | False |
| variation-tree-bitonic-6-17 | development | c | 1 | 0.304 | False |
| variation-tree-bitonic-6-17 | development | phase197 | 3.28947 | 1 | False |
| variation-tree-bitonic-6-17 | development | candidate | 2.01583 | 0.612811 | False |
| variation-tree-bitonic-6-17 | development | live | 1.95425 | 0.594091 | False |
| variation-tree-bitonic-9-123 | development | c | 1 | 0.319685 | False |
| variation-tree-bitonic-9-123 | development | phase197 | 3.12808 | 1 | False |
| variation-tree-bitonic-9-123 | development | candidate | 1.55697 | 0.497738 | False |
| variation-tree-bitonic-9-123 | development | live | 1.51023 | 0.482796 | False |
| variation-symreg-4-17 | heldout | c | 1 | 0.935891 | False |
| variation-symreg-4-17 | heldout | phase197 | 1.0685 | 1 | False |
| variation-symreg-4-17 | heldout | candidate | 1.07388 | 1.00504 | False |
| variation-symreg-4-17 | heldout | live | 1.0386 | 0.972016 | False |
| variation-symreg-7-123 | heldout | c | 1 | 0.923636 | True |
| variation-symreg-7-123 | heldout | phase197 | 1.08268 | 1 | True |
| variation-symreg-7-123 | heldout | candidate | 1.09901 | 1.01508 | True |
| variation-symreg-7-123 | heldout | live | 1.04985 | 0.969677 | True |
| variation-local-fold-128-0 | development | c | 1 | 0.35535 | False |
| variation-local-fold-128-0 | development | phase197 | 2.81413 | 1 | False |
| variation-local-fold-128-0 | development | candidate | 2.83553 | 1.0076 | False |
| variation-local-fold-128-0 | development | live | 2.75366 | 0.978512 | False |
| variation-local-fold-8192-123 | development | c | 1 | 0.49477 | False |
| variation-local-fold-8192-123 | development | phase197 | 2.02114 | 1 | False |
| variation-local-fold-8192-123 | development | candidate | 2.05206 | 1.0153 | False |
| variation-local-fold-8192-123 | development | live | 2.02725 | 1.00302 | False |
| variation-mandelbrot-grid-4-7 | heldout | c | 1 | 0.355975 | False |
| variation-mandelbrot-grid-4-7 | heldout | phase197 | 2.80919 | 1 | False |
| variation-mandelbrot-grid-4-7 | heldout | candidate | 2.3619 | 0.840778 | False |
| variation-mandelbrot-grid-4-7 | heldout | live | 2.3497 | 0.836435 | False |
| variation-mandelbrot-grid-5-31 | heldout | c | 1 | 0.421544 | False |
| variation-mandelbrot-grid-5-31 | heldout | phase197 | 2.37223 | 1 | False |
| variation-mandelbrot-grid-5-31 | heldout | candidate | 1.00684 | 0.424426 | False |
| variation-mandelbrot-grid-5-31 | heldout | live | 0.991453 | 0.417941 | False |
| variation-ray-active-64-2440 | heldout | c | 1 | 0.589368 | False |
| variation-ray-active-64-2440 | heldout | phase197 | 1.69673 | 1 | False |
| variation-ray-active-64-2440 | heldout | candidate | 1.66428 | 0.980876 | False |
| variation-ray-active-64-2440 | heldout | live | 1.66775 | 0.982921 | False |
| variation-ray-active-256-2240 | heldout | c | 1 | 0.586184 | False |
| variation-ray-active-256-2240 | heldout | phase197 | 1.70595 | 1 | False |
| variation-ray-active-256-2240 | heldout | candidate | 1.68607 | 0.98835 | False |
| variation-ray-active-256-2240 | heldout | live | 1.68607 | 0.98835 | False |
| coverage-closures-64 | heldout | c | 1 | 10.8299 | True |
| coverage-closures-64 | heldout | phase197 | 0.092337 | 1 | True |
| coverage-closures-64 | heldout | candidate | 0.0895898 | 0.970248 | True |
| coverage-closures-64 | heldout | live | 0.101113 | 1.09504 | True |
| coverage-closures-256 | heldout | c | 1 | 13.7276 | False |
| coverage-closures-256 | heldout | phase197 | 0.072846 | 1 | False |
| coverage-closures-256 | heldout | candidate | 0.0727138 | 0.998185 | False |
| coverage-closures-256 | heldout | live | 0.0758782 | 1.04163 | False |
| coverage-list-pipeline-128 | heldout | c | 1 | 1.21519 | False |
| coverage-list-pipeline-128 | heldout | phase197 | 0.82292 | 1 | False |
| coverage-list-pipeline-128 | heldout | candidate | 0.80862 | 0.982623 | False |
| coverage-list-pipeline-128 | heldout | live | 0.755841 | 0.918487 | False |
| coverage-list-pipeline-512 | heldout | c | 1 | 1.17333 | False |
| coverage-list-pipeline-512 | heldout | phase197 | 0.852272 | 1 | False |
| coverage-list-pipeline-512 | heldout | candidate | 0.844801 | 0.991234 | False |
| coverage-list-pipeline-512 | heldout | live | 0.782443 | 0.918067 | False |
| coverage-bst-32 | development | c | 1 | 0.23663 | False |
| coverage-bst-32 | development | phase197 | 4.22601 | 1 | False |
| coverage-bst-32 | development | candidate | 4.04097 | 0.956214 | False |
| coverage-bst-32 | development | live | 3.41146 | 0.807253 | False |
| coverage-bst-64 | development | c | 1 | 0.276654 | False |
| coverage-bst-64 | development | phase197 | 3.61462 | 1 | False |
| coverage-bst-64 | development | candidate | 2.85041 | 0.788576 | False |
| coverage-bst-64 | development | live | 2.46563 | 0.682127 | False |
| coverage-unicode-text-16 | heldout | c | 1 | 0.327051 | True |
| coverage-unicode-text-16 | heldout | phase197 | 3.05763 | 1 | True |
| coverage-unicode-text-16 | heldout | candidate | 2.97417 | 0.972704 | True |
| coverage-unicode-text-16 | heldout | live | 2.53671 | 0.829633 | True |
| coverage-unicode-text-64 | heldout | c | 1 | 0.388448 | False |
| coverage-unicode-text-64 | heldout | phase197 | 2.57435 | 1 | False |
| coverage-unicode-text-64 | heldout | candidate | 2.56854 | 0.997743 | False |
| coverage-unicode-text-64 | heldout | live | 2.44947 | 0.951493 | False |
| coverage-expression-32 | development | c | 1 | 0.897134 | True |
| coverage-expression-32 | development | phase197 | 1.11466 | 1 | True |
| coverage-expression-32 | development | candidate | 0.146714 | 0.131622 | True |
| coverage-expression-32 | development | live | 0.14473 | 0.129842 | True |
| coverage-expression-128 | development | c | 1 | 0.956767 | False |
| coverage-expression-128 | development | phase197 | 1.04519 | 1 | False |
| coverage-expression-128 | development | candidate | 0.148341 | 0.141927 | False |
| coverage-expression-128 | development | live | 0.145743 | 0.139442 | False |
| coverage-map-churn-32 | development | c | 1 | 0.280935 | True |
| coverage-map-churn-32 | development | phase197 | 3.55954 | 1 | True |
| coverage-map-churn-32 | development | candidate | 3.58675 | 1.00765 | True |
| coverage-map-churn-32 | development | live | 3.42075 | 0.96101 | True |
| coverage-map-churn-128 | development | c | 1 | 0.279018 | False |
| coverage-map-churn-128 | development | phase197 | 3.584 | 1 | False |
| coverage-map-churn-128 | development | candidate | 3.57 | 0.996094 | False |
| coverage-map-churn-128 | development | live | 3.40634 | 0.950431 | False |
| coverage-numeric-recurrence-256 | heldout | c | 1 | 0.595451 | True |
| coverage-numeric-recurrence-256 | heldout | phase197 | 1.6794 | 1 | True |
| coverage-numeric-recurrence-256 | heldout | candidate | 1.75407 | 1.04446 | True |
| coverage-numeric-recurrence-256 | heldout | live | 1.7205 | 1.02447 | True |
| coverage-numeric-recurrence-1024 | heldout | c | 1 | 0.686531 | False |
| coverage-numeric-recurrence-1024 | heldout | phase197 | 1.4566 | 1 | False |
| coverage-numeric-recurrence-1024 | heldout | candidate | 1.45473 | 0.998714 | False |
| coverage-numeric-recurrence-1024 | heldout | live | 1.47782 | 1.01457 | False |
| coverage-record-aggregation-64 | heldout | c | 1 | 0.34758 | False |
| coverage-record-aggregation-64 | heldout | phase197 | 2.87703 | 1 | False |
| coverage-record-aggregation-64 | heldout | candidate | 2.87933 | 1.0008 | False |
| coverage-record-aggregation-64 | heldout | live | 2.96608 | 1.03095 | False |
| coverage-record-aggregation-256 | heldout | c | 1 | 0.340284 | False |
| coverage-record-aggregation-256 | heldout | phase197 | 2.93872 | 1 | False |
| coverage-record-aggregation-256 | heldout | candidate | 2.77822 | 0.945386 | False |
| coverage-record-aggregation-256 | heldout | live | 2.88477 | 0.981641 | False |

## Worst regressions against frozen baseline

c: coverage-closures-256 13.7276×, coverage-closures-64 10.8299×, coverage-list-pipeline-128 1.21519×, coverage-list-pipeline-512 1.17333×.
phase197: none.
candidate: scalar-region-8192 1.13146×, coverage-numeric-recurrence-256 1.04446×, variation-local-fold-8192-123 1.0153×, variation-symreg-7-123 1.01508×, coverage-map-churn-32 1.00765×, variation-local-fold-128-0 1.0076×, variation-lexer-6-17 1.00748×, test-rle-roundtrip 1.00608×, variation-symreg-4-17 1.00504×, variation-lexer-10-123 1.00359×.
live: scalar-region-8192 1.1247×, coverage-closures-64 1.09504×, coverage-closures-256 1.04163×, coverage-record-aggregation-64 1.03095×, coverage-numeric-recurrence-256 1.02447×, variation-lexer-6-17 1.01929×, test-rle-roundtrip 1.01898×, variation-lexer-10-123 1.01463×, coverage-numeric-recurrence-1024 1.01457×, test-morning-program 1.01139×.

## Separate compiler API costs

No emission receipts supplied; compiler costs unmeasured here.

## Family and positive-excess diagnostics

| Subset | Role | Versus | Eligible families | Equal-family geomean | Positive fixed-catalog excess ms |
|---|---|---|---:|---:|---:|
| all | c | overC | 22 | 1 | 0 |
| all | c | overBaseline | 22 | 0.510951 | 154.32 |
| all | phase197 | overC | 22 | 1.95713 | 12748 |
| all | phase197 | overBaseline | 22 | 1 | 0 |
| all | candidate | overC | 22 | 1.68784 | 10514.5 |
| all | candidate | overBaseline | 22 | 0.862406 | 107.708 |
| all | live | overC | 22 | 1.66289 | 10147.5 |
| all | live | overBaseline | 22 | 0.849657 | 133.203 |
| development | c | overC | 7 | 1 | 0 |
| development | c | overBaseline | 7 | 0.392524 | 0 |
| development | phase197 | overC | 7 | 2.54762 | 6295.16 |
| development | phase197 | overBaseline | 7 | 1 | 0 |
| development | candidate | overC | 7 | 1.71964 | 4775.45 |
| development | candidate | overBaseline | 7 | 0.674998 | 25.5328 |
| development | live | overC | 7 | 1.65914 | 4451.54 |
| development | live | overBaseline | 7 | 0.651254 | 43.5351 |
| heldout | c | overC | 15 | 1 | 0 |
| heldout | c | overBaseline | 15 | 0.577855 | 154.32 |
| heldout | phase197 | overC | 15 | 1.73054 | 6452.83 |
| heldout | phase197 | overBaseline | 15 | 1 | 0 |
| heldout | candidate | overC | 15 | 1.67321 | 5739.04 |
| heldout | candidate | overBaseline | 15 | 0.966874 | 82.1752 |
| heldout | live | overC | 15 | 1.66464 | 5695.98 |
| heldout | live | overBaseline | 15 | 0.961923 | 89.6679 |
