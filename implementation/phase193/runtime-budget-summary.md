# Phase193 runtime summary

Ratios are ratios of role medians from this runtime report. Frozen baseline means authenticated executable identities, freshly timed in the same report. All eligible cases remain included, including dispersion flags. Fixed-equivalent sums use original catalog repetitions, never adaptive calibration counts; zero-work cases remain correctness-only. Partial development/heldout coverage is explicit; no unseen results, significance or promotion claim. Family diagnostics give each observed eligible family equal weight; positive excess sums only positive per-case fixed-catalog time differences. Baseline, C and QBE executable identities are authenticated against the supplied reference manifest and freshly timed in this report. Candidate role names do not establish native generation or qualification.

Runtime receipt: `/home/ai/bend2/build/publish/bend/selfhost/build/phase193/budget-runtime01/report.json`
Validated observations: {"pilots": 591, "samples": 720}.

Warning: Dispersion exceeds threshold: mandelbrot, raytrace, scalar-region-8192, variation-lexer-10-123, variation-local-fold-128-0, variation-mandelbrot-grid-4-7, variation-ray-active-64-2440, coverage-bst-64, coverage-expression-32, coverage-numeric-recurrence-256, coverage-numeric-recurrence-1024

## all

45/45 cases observed; 44 ratio eligible.

| Role | Versus | Geomean | Mean positive log slowdown | >1.1× | >2× | Fixed-equivalent ms | Reference ms |
|---|---|---:|---:|---:|---:|---:|---:|
| c | overC | 1 | 0 | 0 | 0 | 10226.4 | 10226.4 |
| c | overBaseline | 0.45251 | 0.115729 | 4 | 2 | 10226.4 | 27539.1 |
| qbe | overC | 1.34963 | 0.5289 | 32 | 23 | 16642.6 | 10226.4 |
| qbe | overBaseline | 0.61072 | 0 | 0 | 0 | 16642.6 | 27539.1 |
| baseline | overC | 2.20989 | 0.908674 | 36 | 32 | 27539.1 | 10226.4 |
| baseline | overBaseline | 1 | 0 | 0 | 0 | 27539.1 | 27539.1 |
| candidate | overC | 2.11789 | 0.866163 | 37 | 32 | 26197.6 | 10226.4 |
| candidate | overBaseline | 0.958367 | 0.00218024 | 0 | 0 | 26197.6 | 27539.1 |

## development

10/10 cases observed; 10 ratio eligible.

| Role | Versus | Geomean | Mean positive log slowdown | >1.1× | >2× | Fixed-equivalent ms | Reference ms |
|---|---|---:|---:|---:|---:|---:|---:|
| c | overC | 1 | 0 | 0 | 0 | 2648.24 | 2648.24 |
| c | overBaseline | 0.380962 | 0 | 0 | 0 | 2648.24 | 7033.41 |
| qbe | overC | 1.58955 | 0.509165 | 8 | 5 | 4049.55 | 2648.24 |
| qbe | overBaseline | 0.605558 | 0 | 0 | 0 | 4049.55 | 7033.41 |
| baseline | overC | 2.62493 | 0.965056 | 10 | 8 | 7033.41 | 2648.24 |
| baseline | overBaseline | 1 | 0 | 0 | 0 | 7033.41 | 7033.41 |
| candidate | overC | 2.52251 | 0.925253 | 10 | 8 | 6770.95 | 2648.24 |
| candidate | overBaseline | 0.96098 | 0.00269837 | 0 | 0 | 6770.95 | 7033.41 |

## heldout

35/35 cases observed; 34 ratio eligible.

| Role | Versus | Geomean | Mean positive log slowdown | >1.1× | >2× | Fixed-equivalent ms | Reference ms |
|---|---|---:|---:|---:|---:|---:|---:|
| c | overC | 1 | 0 | 0 | 0 | 7578.16 | 7578.16 |
| c | overBaseline | 0.476006 | 0.149767 | 4 | 2 | 7578.16 | 20505.7 |
| qbe | overC | 1.28621 | 0.534704 | 24 | 18 | 12593.1 | 7578.16 |
| qbe | overBaseline | 0.612246 | 0 | 0 | 0 | 12593.1 | 20505.7 |
| baseline | overC | 2.10081 | 0.892091 | 26 | 24 | 20505.7 | 7578.16 |
| baseline | overBaseline | 1 | 0 | 0 | 0 | 20505.7 | 20505.7 |
| candidate | overC | 2.01174 | 0.848783 | 27 | 24 | 19426.7 | 7578.16 |
| candidate | overBaseline | 0.9576 | 0.00202785 | 0 | 0 | 19426.7 | 20505.7 |

## Per-case ratios

| Case | Partition | Role | / C | / baseline | Dispersion flag |
|---|---|---|---:|---:|---|
| mandelbrot | heldout | c | 1 | 0.204672 | True |
| mandelbrot | heldout | qbe | 2.44743 | 0.500921 | True |
| mandelbrot | heldout | baseline | 4.88587 | 1 | True |
| mandelbrot | heldout | candidate | 4.2963 | 0.879332 | True |
| editdist | development | c | 1 | 0.355125 | False |
| editdist | development | qbe | 1.25693 | 0.446366 | False |
| editdist | development | baseline | 2.81591 | 1 | False |
| editdist | development | candidate | 2.8103 | 0.998008 | False |
| tree-bitonic | development | c | 1 | 0.309689 | False |
| tree-bitonic | development | qbe | 2.374 | 0.735202 | False |
| tree-bitonic | development | baseline | 3.22904 | 1 | False |
| tree-bitonic | development | candidate | 3.16101 | 0.978932 | False |
| lexer | development | c | 1 | 0.352452 | False |
| lexer | development | qbe | 2.07791 | 0.732362 | False |
| lexer | development | baseline | 2.83727 | 1 | False |
| lexer | development | candidate | 2.73829 | 0.965116 | False |
| symreg | heldout | c | 1 | 0.918592 | False |
| symreg | heldout | qbe | 0.725749 | 0.666667 | False |
| symreg | heldout | baseline | 1.08862 | 1 | False |
| symreg | heldout | candidate | 1.09509 | 1.00594 | False |
| test-morning-program | heldout | c | 1 | 0.257285 | False |
| test-morning-program | heldout | qbe | 2.80803 | 0.722464 | False |
| test-morning-program | heldout | baseline | 3.88674 | 1 | False |
| test-morning-program | heldout | candidate | 3.4206 | 0.880068 | False |
| test-evening-program | heldout | c | 1 | 0.202596 | False |
| test-evening-program | heldout | qbe | 2.99908 | 0.607601 | False |
| test-evening-program | heldout | baseline | 4.93593 | 1 | False |
| test-evening-program | heldout | candidate | 3.93867 | 0.797959 | False |
| test-rle-roundtrip | heldout | c | 1 | 0.363095 | False |
| test-rle-roundtrip | heldout | qbe | 2.27191 | 0.824918 | False |
| test-rle-roundtrip | heldout | baseline | 2.7541 | 1 | False |
| test-rle-roundtrip | heldout | candidate | 2.4291 | 0.881994 | False |
| test-map-set-ops | development | c | 1 | 0.294571 | False |
| test-map-set-ops | development | qbe | 2.41994 | 0.712844 | False |
| test-map-set-ops | development | baseline | 3.39477 | 1 | False |
| test-map-set-ops | development | candidate | 2.94123 | 0.866402 | False |
| raytrace | heldout | c | 1 | 0.505208 | True |
| raytrace | heldout | qbe | 1.02504 | 0.517857 | True |
| raytrace | heldout | baseline | 1.97938 | 1 | True |
| raytrace | heldout | candidate | 1.97938 | 1 | True |
| local-pair | development | c | 1 | 0.348982 | False |
| local-pair | development | qbe | 1.25301 | 0.437277 | False |
| local-pair | development | baseline | 2.86548 | 1 | False |
| local-pair | development | candidate | 2.86548 | 1 | False |
| local-fold | development | c | 1 | 0.413297 | False |
| local-fold | development | qbe | 2.01929 | 0.834569 | False |
| local-fold | development | baseline | 2.41957 | 1 | False |
| local-fold | development | candidate | 2.42866 | 1.00376 | False |
| scalar-region-0 | heldout | c | ineligible | ineligible | False |
| scalar-region-0 | heldout | qbe | ineligible | ineligible | False |
| scalar-region-0 | heldout | baseline | ineligible | ineligible | False |
| scalar-region-0 | heldout | candidate | ineligible | ineligible | False |
| scalar-region-8192 | heldout | c | 1 | 0.315047 | True |
| scalar-region-8192 | heldout | qbe | 1.6668 | 0.525122 | True |
| scalar-region-8192 | heldout | baseline | 3.17413 | 1 | True |
| scalar-region-8192 | heldout | candidate | 3.13847 | 0.988765 | True |
| complete-generic-row32 | heldout | c | 1 | 0.305449 | False |
| complete-generic-row32 | heldout | qbe | 2.99303 | 0.91422 | False |
| complete-generic-row32 | heldout | baseline | 3.27387 | 1 | False |
| complete-generic-row32 | heldout | candidate | 3.26135 | 0.996176 | False |
| variation-editdist-0-17 | heldout | c | 1 | 0.353132 | False |
| variation-editdist-0-17 | heldout | qbe | 1.26143 | 0.445451 | False |
| variation-editdist-0-17 | heldout | baseline | 2.83181 | 1 | False |
| variation-editdist-0-17 | heldout | candidate | 2.82645 | 0.99811 | False |
| variation-editdist-3-123 | heldout | c | 1 | 0.354288 | False |
| variation-editdist-3-123 | heldout | qbe | 1.25514 | 0.444679 | False |
| variation-editdist-3-123 | heldout | baseline | 2.82257 | 1 | False |
| variation-editdist-3-123 | heldout | candidate | 2.82257 | 1 | False |
| variation-lexer-6-17 | heldout | c | 1 | 0.35175 | False |
| variation-lexer-6-17 | heldout | qbe | 2.08796 | 0.734439 | False |
| variation-lexer-6-17 | heldout | baseline | 2.84293 | 1 | False |
| variation-lexer-6-17 | heldout | candidate | 2.76139 | 0.971319 | False |
| variation-lexer-10-123 | heldout | c | 1 | 0.352269 | True |
| variation-lexer-10-123 | heldout | qbe | 2.07185 | 0.72985 | True |
| variation-lexer-10-123 | heldout | baseline | 2.83874 | 1 | True |
| variation-lexer-10-123 | heldout | candidate | 2.73872 | 0.964768 | True |
| variation-tree-bitonic-6-17 | heldout | c | 1 | 0.285946 | False |
| variation-tree-bitonic-6-17 | heldout | qbe | 2.56616 | 0.733784 | False |
| variation-tree-bitonic-6-17 | heldout | baseline | 3.49716 | 1 | False |
| variation-tree-bitonic-6-17 | heldout | candidate | 3.37612 | 0.965389 | False |
| variation-tree-bitonic-9-123 | heldout | c | 1 | 0.319762 | False |
| variation-tree-bitonic-9-123 | heldout | qbe | 2.27394 | 0.727118 | False |
| variation-tree-bitonic-9-123 | heldout | baseline | 3.12733 | 1 | False |
| variation-tree-bitonic-9-123 | heldout | candidate | 3.07235 | 0.982422 | False |
| variation-symreg-4-17 | heldout | c | 1 | 0.909317 | False |
| variation-symreg-4-17 | heldout | qbe | 0.731696 | 0.665344 | False |
| variation-symreg-4-17 | heldout | baseline | 1.09973 | 1 | False |
| variation-symreg-4-17 | heldout | candidate | 1.10845 | 1.00794 | False |
| variation-symreg-7-123 | heldout | c | 1 | 0.916306 | False |
| variation-symreg-7-123 | heldout | qbe | 0.727559 | 0.666667 | False |
| variation-symreg-7-123 | heldout | baseline | 1.09134 | 1 | False |
| variation-symreg-7-123 | heldout | candidate | 1.09783 | 1.00595 | False |
| variation-local-fold-128-0 | heldout | c | 1 | 0.333384 | True |
| variation-local-fold-128-0 | heldout | qbe | 2.4513 | 0.817223 | True |
| variation-local-fold-128-0 | heldout | baseline | 2.99954 | 1 | True |
| variation-local-fold-128-0 | heldout | candidate | 2.91821 | 0.972885 | True |
| variation-local-fold-8192-123 | heldout | c | 1 | 0.415515 | False |
| variation-local-fold-8192-123 | heldout | qbe | 2.00823 | 0.834449 | False |
| variation-local-fold-8192-123 | heldout | baseline | 2.40665 | 1 | False |
| variation-local-fold-8192-123 | heldout | candidate | 2.40665 | 1 | False |
| variation-mandelbrot-grid-4-7 | heldout | c | 1 | 0.260244 | True |
| variation-mandelbrot-grid-4-7 | heldout | qbe | 1.58064 | 0.411351 | True |
| variation-mandelbrot-grid-4-7 | heldout | baseline | 3.84255 | 1 | True |
| variation-mandelbrot-grid-4-7 | heldout | candidate | 3.88425 | 1.01085 | True |
| variation-mandelbrot-grid-5-31 | heldout | c | 1 | 0.28655 | False |
| variation-mandelbrot-grid-5-31 | heldout | qbe | 1.54481 | 0.442666 | False |
| variation-mandelbrot-grid-5-31 | heldout | baseline | 3.48979 | 1 | False |
| variation-mandelbrot-grid-5-31 | heldout | candidate | 3.47798 | 0.996615 | False |
| variation-ray-active-64-2440 | development | c | 1 | 0.37358 | True |
| variation-ray-active-64-2440 | development | qbe | 0.935173 | 0.349362 | True |
| variation-ray-active-64-2440 | development | baseline | 2.6768 | 1 | True |
| variation-ray-active-64-2440 | development | candidate | 2.67111 | 0.997872 | True |
| variation-ray-active-256-2240 | heldout | c | 1 | 0.370322 | False |
| variation-ray-active-256-2240 | heldout | qbe | 0.963035 | 0.356633 | False |
| variation-ray-active-256-2240 | heldout | baseline | 2.70035 | 1 | False |
| variation-ray-active-256-2240 | heldout | candidate | 2.69508 | 0.998047 | False |
| coverage-closures-64 | heldout | c | 1 | 10 | False |
| coverage-closures-64 | heldout | qbe | 0.0758958 | 0.758958 | False |
| coverage-closures-64 | heldout | baseline | 0.1 | 1 | False |
| coverage-closures-64 | heldout | candidate | 0.0998736 | 0.998736 | False |
| coverage-closures-256 | heldout | c | 1 | 10.4844 | False |
| coverage-closures-256 | heldout | qbe | 0.071822 | 0.753012 | False |
| coverage-closures-256 | heldout | baseline | 0.0953796 | 1 | False |
| coverage-closures-256 | heldout | candidate | 0.0955932 | 1.00224 | False |
| coverage-list-pipeline-128 | heldout | c | 1 | 1.25354 | False |
| coverage-list-pipeline-128 | heldout | qbe | 0.226316 | 0.283696 | False |
| coverage-list-pipeline-128 | heldout | baseline | 0.79774 | 1 | False |
| coverage-list-pipeline-128 | heldout | candidate | 0.796489 | 0.998431 | False |
| coverage-list-pipeline-512 | heldout | c | 1 | 1.23817 | False |
| coverage-list-pipeline-512 | heldout | qbe | 0.217446 | 0.269235 | False |
| coverage-list-pipeline-512 | heldout | baseline | 0.807643 | 1 | False |
| coverage-list-pipeline-512 | heldout | candidate | 0.807655 | 1.00001 | False |
| coverage-bst-32 | heldout | c | 1 | 0.233285 | False |
| coverage-bst-32 | heldout | qbe | 2.79306 | 0.651579 | False |
| coverage-bst-32 | heldout | baseline | 4.28661 | 1 | False |
| coverage-bst-32 | heldout | candidate | 4.29204 | 1.00127 | False |
| coverage-bst-64 | heldout | c | 1 | 0.261525 | True |
| coverage-bst-64 | heldout | qbe | 2.49124 | 0.651523 | True |
| coverage-bst-64 | heldout | baseline | 3.82372 | 1 | True |
| coverage-bst-64 | heldout | candidate | 3.82373 | 1 | True |
| coverage-unicode-text-16 | heldout | c | 1 | 0.378243 | False |
| coverage-unicode-text-16 | heldout | qbe | 2.17002 | 0.820793 | False |
| coverage-unicode-text-16 | heldout | baseline | 2.6438 | 1 | False |
| coverage-unicode-text-16 | heldout | candidate | 2.58368 | 0.977258 | False |
| coverage-unicode-text-64 | heldout | c | 1 | 0.398648 | False |
| coverage-unicode-text-64 | heldout | qbe | 2.07792 | 0.828358 | False |
| coverage-unicode-text-64 | heldout | baseline | 2.50848 | 1 | False |
| coverage-unicode-text-64 | heldout | candidate | 2.4804 | 0.988806 | False |
| coverage-expression-32 | development | c | 1 | 0.892521 | True |
| coverage-expression-32 | development | qbe | 0.676981 | 0.60422 | True |
| coverage-expression-32 | development | baseline | 1.12042 | 1 | True |
| coverage-expression-32 | development | candidate | 1.14676 | 1.0235 | True |
| coverage-expression-128 | heldout | c | 1 | 0.92163 | False |
| coverage-expression-128 | heldout | qbe | 0.6638 | 0.611778 | False |
| coverage-expression-128 | heldout | baseline | 1.08503 | 1 | False |
| coverage-expression-128 | heldout | candidate | 1.05386 | 0.971273 | False |
| coverage-map-churn-32 | development | c | 1 | 0.223183 | False |
| coverage-map-churn-32 | development | qbe | 2.68916 | 0.600175 | False |
| coverage-map-churn-32 | development | baseline | 4.48063 | 1 | False |
| coverage-map-churn-32 | development | candidate | 3.60651 | 0.804911 | False |
| coverage-map-churn-128 | heldout | c | 1 | 0.221634 | False |
| coverage-map-churn-128 | heldout | qbe | 2.67861 | 0.593671 | False |
| coverage-map-churn-128 | heldout | baseline | 4.51195 | 1 | False |
| coverage-map-churn-128 | heldout | candidate | 3.58503 | 0.794563 | False |
| coverage-numeric-recurrence-256 | development | c | 1 | 0.525401 | True |
| coverage-numeric-recurrence-256 | development | qbe | 1.59325 | 0.837095 | True |
| coverage-numeric-recurrence-256 | development | baseline | 1.90331 | 1 | True |
| coverage-numeric-recurrence-256 | development | candidate | 1.89637 | 0.996354 | True |
| coverage-numeric-recurrence-1024 | heldout | c | 1 | 0.597736 | True |
| coverage-numeric-recurrence-1024 | heldout | qbe | 1.53816 | 0.919414 | True |
| coverage-numeric-recurrence-1024 | heldout | baseline | 1.67298 | 1 | True |
| coverage-numeric-recurrence-1024 | heldout | candidate | 1.73235 | 1.03549 | True |
| coverage-record-aggregation-64 | heldout | c | 1 | 0.276326 | False |
| coverage-record-aggregation-64 | heldout | qbe | 2.3164 | 0.640083 | False |
| coverage-record-aggregation-64 | heldout | baseline | 3.61891 | 1 | False |
| coverage-record-aggregation-64 | heldout | candidate | 2.88326 | 0.796721 | False |
| coverage-record-aggregation-256 | heldout | c | 1 | 0.277009 | False |
| coverage-record-aggregation-256 | heldout | qbe | 2.28187 | 0.632099 | False |
| coverage-record-aggregation-256 | heldout | baseline | 3.60999 | 1 | False |
| coverage-record-aggregation-256 | heldout | candidate | 2.83077 | 0.784149 | False |

## Worst regressions against frozen baseline

c: coverage-closures-256 10.4844×, coverage-closures-64 10×, coverage-list-pipeline-128 1.25354×, coverage-list-pipeline-512 1.23817×.
qbe: none.
baseline: none.
candidate: coverage-numeric-recurrence-1024 1.03549×, coverage-expression-32 1.0235×, variation-mandelbrot-grid-4-7 1.01085×, variation-symreg-4-17 1.00794×, variation-symreg-7-123 1.00595×, symreg 1.00594×, local-fold 1.00376×, coverage-closures-256 1.00224×, coverage-bst-32 1.00127×, coverage-list-pipeline-512 1.00001×.

## Separate compiler API costs

No emission receipts supplied; compiler costs unmeasured here.

## Family and positive-excess diagnostics

| Subset | Role | Versus | Eligible families | Equal-family geomean | Positive fixed-catalog excess ms |
|---|---|---|---:|---:|---:|
| all | c | overC | 22 | 1 | 0 |
| all | c | overBaseline | 22 | 0.432502 | 160.883 |
| all | qbe | overC | 22 | 1.43871 | 7303.41 |
| all | qbe | overBaseline | 22 | 0.622246 | 0 |
| all | baseline | overC | 22 | 2.31213 | 17473.6 |
| all | baseline | overBaseline | 22 | 1 | 0 |
| all | candidate | overC | 22 | 2.18909 | 16132.3 |
| all | candidate | overBaseline | 22 | 0.946786 | 40.3817 |
| development | c | overC | 10 | 1 | 0 |
| development | c | overBaseline | 10 | 0.380962 | 0 |
| development | qbe | overC | 10 | 1.58955 | 1554 |
| development | qbe | overBaseline | 10 | 0.605558 | 0 |
| development | baseline | overC | 10 | 2.62493 | 4385.17 |
| development | baseline | overBaseline | 10 | 1 | 0 |
| development | candidate | overC | 10 | 2.52251 | 4122.71 |
| development | candidate | overBaseline | 10 | 0.96098 | 10.297 |
| heldout | c | overC | 20 | 1 | 0 |
| heldout | c | overBaseline | 20 | 0.447458 | 160.883 |
| heldout | qbe | overC | 20 | 1.41353 | 5749.41 |
| heldout | qbe | overBaseline | 20 | 0.632496 | 0 |
| heldout | baseline | overC | 20 | 2.23485 | 13088.4 |
| heldout | baseline | overBaseline | 20 | 1 | 0 |
| heldout | candidate | overC | 20 | 2.11749 | 12009.6 |
| heldout | candidate | overBaseline | 20 | 0.947488 | 30.0847 |
