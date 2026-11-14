# Phase194 runtime summary

Ratios are ratios of role medians from this runtime report. Frozen baseline means authenticated executable identities, freshly timed in the same report. All eligible cases remain included, including dispersion flags. Fixed-equivalent sums use original catalog repetitions, never adaptive calibration counts; zero-work cases remain correctness-only. Partial development/heldout coverage is explicit; no unseen results, significance or promotion claim. Equal-family and positive fixed-catalog excess diagnostics use the Phase193 formulas. QBE executable identity is also authenticated against the reference manifest. Candidate role names do not establish B1/native generation or qualification.

Runtime receipt: `/home/ai/bend2/build/publish/bend/selfhost/build/phase194/runtime02/report.json`
Validated observations: {"pilots": 610, "samples": 720}.

Warning: Dispersion exceeds threshold: lexer, symreg, test-morning-program, test-evening-program, local-fold, variation-lexer-6-17, variation-tree-bitonic-6-17, coverage-closures-64, coverage-list-pipeline-128, coverage-expression-32, coverage-map-churn-32, coverage-map-churn-128

## all

45/45 cases observed; 44 ratio eligible.

| Role | Versus | Geomean | Mean positive log slowdown | >1.1× | >2× | Fixed-equivalent ms | Reference ms |
|---|---|---:|---:|---:|---:|---:|---:|
| c | overC | 1 | 0 | 0 | 0 | 10166.3 | 10166.3 |
| c | overBaseline | 0.475565 | 0.117443 | 4 | 2 | 10166.3 | 25888.6 |
| qbe | overC | 1.34855 | 0.527728 | 32 | 22 | 16513.1 | 10166.3 |
| qbe | overBaseline | 0.641325 | 0 | 0 | 0 | 16513.1 | 25888.6 |
| baseline | overC | 2.10276 | 0.860694 | 39 | 32 | 25888.6 | 10166.3 |
| baseline | overBaseline | 1 | 0 | 0 | 0 | 25888.6 | 25888.6 |
| candidate | overC | 1.97103 | 0.808492 | 36 | 32 | 24463.3 | 10166.3 |
| candidate | overBaseline | 0.937355 | 0.00178163 | 0 | 0 | 24463.3 | 25888.6 |

## development

10/10 cases observed; 10 ratio eligible.

| Role | Versus | Geomean | Mean positive log slowdown | >1.1× | >2× | Fixed-equivalent ms | Reference ms |
|---|---|---:|---:|---:|---:|---:|---:|
| c | overC | 1 | 0 | 0 | 0 | 2602.22 | 2602.22 |
| c | overBaseline | 0.39747 | 0 | 0 | 0 | 2602.22 | 6672.33 |
| qbe | overC | 1.60133 | 0.512918 | 8 | 5 | 4003.34 | 2602.22 |
| qbe | overBaseline | 0.636482 | 0 | 0 | 0 | 4003.34 | 6672.33 |
| baseline | overC | 2.51591 | 0.922635 | 10 | 8 | 6672.33 | 2602.22 |
| baseline | overBaseline | 1 | 0 | 0 | 0 | 6672.33 | 6672.33 |
| candidate | overC | 2.3801 | 0.867142 | 10 | 8 | 6365.02 | 2602.22 |
| candidate | overBaseline | 0.946018 | 0.00178839 | 0 | 0 | 6365.02 | 6672.33 |

## heldout

35/35 cases observed; 34 ratio eligible.

| Role | Versus | Geomean | Mean positive log slowdown | >1.1× | >2× | Fixed-equivalent ms | Reference ms |
|---|---|---:|---:|---:|---:|---:|---:|
| c | overC | 1 | 0 | 0 | 0 | 7564.04 | 7564.04 |
| c | overBaseline | 0.50133 | 0.151984 | 4 | 2 | 7564.04 | 19216.3 |
| qbe | overC | 1.2821 | 0.532083 | 24 | 17 | 12509.7 | 7564.04 |
| qbe | overBaseline | 0.642756 | 0 | 0 | 0 | 12509.7 | 19216.3 |
| baseline | overC | 1.9947 | 0.842476 | 29 | 24 | 19216.3 | 7564.04 |
| baseline | overBaseline | 1 | 0 | 0 | 0 | 19216.3 | 19216.3 |
| candidate | overC | 1.86469 | 0.791242 | 26 | 24 | 18098.3 | 7564.04 |
| candidate | overBaseline | 0.934823 | 0.00177965 | 0 | 0 | 18098.3 | 19216.3 |

## Per-case ratios

| Case | Partition | Role | / C | / baseline | Dispersion flag |
|---|---|---|---:|---:|---|
| mandelbrot | heldout | c | 1 | 0.232921 | False |
| mandelbrot | heldout | qbe | 2.42996 | 0.565988 | False |
| mandelbrot | heldout | baseline | 4.29331 | 1 | False |
| mandelbrot | heldout | candidate | 3.64758 | 0.849596 | False |
| editdist | development | c | 1 | 0.351724 | False |
| editdist | development | qbe | 1.25438 | 0.441195 | False |
| editdist | development | baseline | 2.84314 | 1 | False |
| editdist | development | candidate | 2.66964 | 0.938976 | False |
| tree-bitonic | development | c | 1 | 0.317438 | False |
| tree-bitonic | development | qbe | 2.39153 | 0.759161 | False |
| tree-bitonic | development | baseline | 3.15022 | 1 | False |
| tree-bitonic | development | candidate | 3.1444 | 0.99815 | False |
| lexer | development | c | 1 | 0.36595 | True |
| lexer | development | qbe | 2.08031 | 0.76129 | True |
| lexer | development | baseline | 2.73261 | 1 | True |
| lexer | development | candidate | 2.76016 | 1.01008 | True |
| symreg | heldout | c | 1 | 0.908384 | True |
| symreg | heldout | qbe | 0.743202 | 0.675112 | True |
| symreg | heldout | baseline | 1.10086 | 1 | True |
| symreg | heldout | candidate | 1.05083 | 0.954561 | True |
| test-morning-program | heldout | c | 1 | 0.295792 | True |
| test-morning-program | heldout | qbe | 2.8231 | 0.835052 | True |
| test-morning-program | heldout | baseline | 3.38075 | 1 | True |
| test-morning-program | heldout | candidate | 3.39818 | 1.00515 | True |
| test-evening-program | heldout | c | 1 | 0.252516 | True |
| test-evening-program | heldout | qbe | 3.00832 | 0.759648 | True |
| test-evening-program | heldout | baseline | 3.96015 | 1 | True |
| test-evening-program | heldout | candidate | 3.89882 | 0.984513 | True |
| test-rle-roundtrip | heldout | c | 1 | 0.420029 | False |
| test-rle-roundtrip | heldout | qbe | 2.21088 | 0.928635 | False |
| test-rle-roundtrip | heldout | baseline | 2.38079 | 1 | False |
| test-rle-roundtrip | heldout | candidate | 2.36666 | 0.994067 | False |
| test-map-set-ops | development | c | 1 | 0.33935 | False |
| test-map-set-ops | development | qbe | 2.42516 | 0.822979 | False |
| test-map-set-ops | development | baseline | 2.94681 | 1 | False |
| test-map-set-ops | development | candidate | 2.93464 | 0.995869 | False |
| raytrace | heldout | c | 1 | 0.507766 | False |
| raytrace | heldout | qbe | 1.02941 | 0.5227 | False |
| raytrace | heldout | baseline | 1.96941 | 1 | False |
| raytrace | heldout | candidate | 1.96235 | 0.996416 | False |
| local-pair | development | c | 1 | 0.34926 | False |
| local-pair | development | qbe | 1.25092 | 0.436897 | False |
| local-pair | development | baseline | 2.8632 | 1 | False |
| local-pair | development | candidate | 2.63566 | 0.92053 | False |
| local-fold | development | c | 1 | 0.407738 | True |
| local-fold | development | qbe | 2.1657 | 0.883039 | True |
| local-fold | development | baseline | 2.45256 | 1 | True |
| local-fold | development | candidate | 2.0414 | 0.832356 | True |
| scalar-region-0 | heldout | c | ineligible | ineligible | False |
| scalar-region-0 | heldout | qbe | ineligible | ineligible | False |
| scalar-region-0 | heldout | baseline | ineligible | ineligible | False |
| scalar-region-0 | heldout | candidate | ineligible | ineligible | False |
| scalar-region-8192 | heldout | c | 1 | 0.320353 | False |
| scalar-region-8192 | heldout | qbe | 1.6519 | 0.52919 | False |
| scalar-region-8192 | heldout | baseline | 3.12156 | 1 | False |
| scalar-region-8192 | heldout | candidate | 2.33828 | 0.749075 | False |
| complete-generic-row32 | heldout | c | 1 | 0.304598 | False |
| complete-generic-row32 | heldout | qbe | 2.9985 | 0.913336 | False |
| complete-generic-row32 | heldout | baseline | 3.28302 | 1 | False |
| complete-generic-row32 | heldout | candidate | 3.31447 | 1.00958 | False |
| variation-editdist-0-17 | heldout | c | 1 | 0.351424 | False |
| variation-editdist-0-17 | heldout | qbe | 1.26735 | 0.445378 | False |
| variation-editdist-0-17 | heldout | baseline | 2.84556 | 1 | False |
| variation-editdist-0-17 | heldout | candidate | 2.66062 | 0.935008 | False |
| variation-editdist-3-123 | heldout | c | 1 | 0.341707 | False |
| variation-editdist-3-123 | heldout | qbe | 1.31532 | 0.449455 | False |
| variation-editdist-3-123 | heldout | baseline | 2.92649 | 1 | False |
| variation-editdist-3-123 | heldout | candidate | 2.69418 | 0.92062 | False |
| variation-lexer-6-17 | heldout | c | 1 | 0.400172 | True |
| variation-lexer-6-17 | heldout | qbe | 1.89868 | 0.7598 | True |
| variation-lexer-6-17 | heldout | baseline | 2.49893 | 1 | True |
| variation-lexer-6-17 | heldout | candidate | 2.49714 | 0.999283 | True |
| variation-lexer-10-123 | heldout | c | 1 | 0.363834 | False |
| variation-lexer-10-123 | heldout | qbe | 2.06701 | 0.752048 | False |
| variation-lexer-10-123 | heldout | baseline | 2.7485 | 1 | False |
| variation-lexer-10-123 | heldout | candidate | 2.73772 | 0.996078 | False |
| variation-tree-bitonic-6-17 | heldout | c | 1 | 0.297488 | True |
| variation-tree-bitonic-6-17 | heldout | qbe | 2.5816 | 0.767994 | True |
| variation-tree-bitonic-6-17 | heldout | baseline | 3.36148 | 1 | True |
| variation-tree-bitonic-6-17 | heldout | candidate | 3.34726 | 0.995769 | True |
| variation-tree-bitonic-9-123 | heldout | c | 1 | 0.324243 | False |
| variation-tree-bitonic-9-123 | heldout | qbe | 2.29285 | 0.74344 | False |
| variation-tree-bitonic-9-123 | heldout | baseline | 3.08411 | 1 | False |
| variation-tree-bitonic-9-123 | heldout | candidate | 3.07187 | 0.996032 | False |
| variation-symreg-4-17 | heldout | c | 1 | 0.901209 | False |
| variation-symreg-4-17 | heldout | qbe | 0.731495 | 0.65923 | False |
| variation-symreg-4-17 | heldout | baseline | 1.10962 | 1 | False |
| variation-symreg-4-17 | heldout | candidate | 1.04971 | 0.946005 | False |
| variation-symreg-7-123 | heldout | c | 1 | 0.905498 | False |
| variation-symreg-7-123 | heldout | qbe | 0.728153 | 0.659341 | False |
| variation-symreg-7-123 | heldout | baseline | 1.10437 | 1 | False |
| variation-symreg-7-123 | heldout | candidate | 1.04762 | 0.948617 | False |
| variation-local-fold-128-0 | heldout | c | 1 | 0.33932 | False |
| variation-local-fold-128-0 | heldout | qbe | 2.48743 | 0.844034 | False |
| variation-local-fold-128-0 | heldout | baseline | 2.94707 | 1 | False |
| variation-local-fold-128-0 | heldout | candidate | 2.73871 | 0.929298 | False |
| variation-local-fold-8192-123 | heldout | c | 1 | 0.415698 | False |
| variation-local-fold-8192-123 | heldout | qbe | 2.01198 | 0.836377 | False |
| variation-local-fold-8192-123 | heldout | baseline | 2.40559 | 1 | False |
| variation-local-fold-8192-123 | heldout | candidate | 2.01716 | 0.83853 | False |
| variation-mandelbrot-grid-4-7 | heldout | c | 1 | 0.271643 | False |
| variation-mandelbrot-grid-4-7 | heldout | qbe | 1.63573 | 0.444335 | False |
| variation-mandelbrot-grid-4-7 | heldout | baseline | 3.6813 | 1 | False |
| variation-mandelbrot-grid-4-7 | heldout | candidate | 2.95123 | 0.801681 | False |
| variation-mandelbrot-grid-5-31 | heldout | c | 1 | 0.300518 | False |
| variation-mandelbrot-grid-5-31 | heldout | qbe | 1.52039 | 0.456906 | False |
| variation-mandelbrot-grid-5-31 | heldout | baseline | 3.32759 | 1 | False |
| variation-mandelbrot-grid-5-31 | heldout | candidate | 2.50015 | 0.751342 | False |
| variation-ray-active-64-2440 | development | c | 1 | 0.368454 | False |
| variation-ray-active-64-2440 | development | qbe | 0.950482 | 0.350209 | False |
| variation-ray-active-64-2440 | development | baseline | 2.71404 | 1 | False |
| variation-ray-active-64-2440 | development | candidate | 2.56584 | 0.945392 | False |
| variation-ray-active-256-2240 | heldout | c | 1 | 0.368422 | False |
| variation-ray-active-256-2240 | heldout | qbe | 0.967974 | 0.356623 | False |
| variation-ray-active-256-2240 | heldout | baseline | 2.71428 | 1 | False |
| variation-ray-active-256-2240 | heldout | candidate | 2.55823 | 0.942507 | False |
| coverage-closures-64 | heldout | c | 1 | 10.0437 | True |
| coverage-closures-64 | heldout | qbe | 0.0756243 | 0.759546 | True |
| coverage-closures-64 | heldout | baseline | 0.0995652 | 1 | True |
| coverage-closures-64 | heldout | candidate | 0.0801376 | 0.804876 | True |
| coverage-closures-256 | heldout | c | 1 | 10.4631 | False |
| coverage-closures-256 | heldout | qbe | 0.0720107 | 0.753456 | False |
| coverage-closures-256 | heldout | baseline | 0.0955739 | 1 | False |
| coverage-closures-256 | heldout | candidate | 0.0727325 | 0.761008 | False |
| coverage-list-pipeline-128 | heldout | c | 1 | 1.34941 | True |
| coverage-list-pipeline-128 | heldout | qbe | 0.22079 | 0.297937 | True |
| coverage-list-pipeline-128 | heldout | baseline | 0.741063 | 1 | True |
| coverage-list-pipeline-128 | heldout | candidate | 0.724374 | 0.97748 | True |
| coverage-list-pipeline-512 | heldout | c | 1 | 1.23739 | False |
| coverage-list-pipeline-512 | heldout | qbe | 0.217702 | 0.269382 | False |
| coverage-list-pipeline-512 | heldout | baseline | 0.808155 | 1 | False |
| coverage-list-pipeline-512 | heldout | candidate | 0.779063 | 0.964003 | False |
| coverage-bst-32 | heldout | c | 1 | 0.232002 | False |
| coverage-bst-32 | heldout | qbe | 2.75367 | 0.638856 | False |
| coverage-bst-32 | heldout | baseline | 4.31031 | 1 | False |
| coverage-bst-32 | heldout | candidate | 4.19359 | 0.972921 | False |
| coverage-bst-64 | heldout | c | 1 | 0.262359 | False |
| coverage-bst-64 | heldout | qbe | 2.48936 | 0.653106 | False |
| coverage-bst-64 | heldout | baseline | 3.81158 | 1 | False |
| coverage-bst-64 | heldout | candidate | 3.71875 | 0.975647 | False |
| coverage-unicode-text-16 | heldout | c | 1 | 0.390812 | False |
| coverage-unicode-text-16 | heldout | qbe | 2.14515 | 0.83835 | False |
| coverage-unicode-text-16 | heldout | baseline | 2.55878 | 1 | False |
| coverage-unicode-text-16 | heldout | candidate | 2.57994 | 1.00827 | False |
| coverage-unicode-text-64 | heldout | c | 1 | 0.402854 | False |
| coverage-unicode-text-64 | heldout | qbe | 2.07368 | 0.835391 | False |
| coverage-unicode-text-64 | heldout | baseline | 2.48229 | 1 | False |
| coverage-unicode-text-64 | heldout | candidate | 2.50121 | 1.00762 | False |
| coverage-expression-32 | development | c | 1 | 0.852755 | True |
| coverage-expression-32 | development | qbe | 0.690707 | 0.589004 | True |
| coverage-expression-32 | development | baseline | 1.17267 | 1 | True |
| coverage-expression-32 | development | candidate | 1.18192 | 1.00788 | True |
| coverage-expression-128 | heldout | c | 1 | 0.955505 | False |
| coverage-expression-128 | heldout | qbe | 0.647615 | 0.618799 | False |
| coverage-expression-128 | heldout | baseline | 1.04657 | 1 | False |
| coverage-expression-128 | heldout | candidate | 1.07692 | 1.02901 | False |
| coverage-map-churn-32 | development | c | 1 | 0.274171 | True |
| coverage-map-churn-32 | development | qbe | 2.72331 | 0.746652 | True |
| coverage-map-churn-32 | development | baseline | 3.64736 | 1 | True |
| coverage-map-churn-32 | development | candidate | 3.58508 | 0.982924 | True |
| coverage-map-churn-128 | heldout | c | 1 | 0.278872 | True |
| coverage-map-churn-128 | heldout | qbe | 2.67891 | 0.747073 | True |
| coverage-map-churn-128 | heldout | baseline | 3.58587 | 1 | True |
| coverage-map-churn-128 | heldout | candidate | 3.54368 | 0.988235 | True |
| coverage-numeric-recurrence-256 | development | c | 1 | 0.578573 | False |
| coverage-numeric-recurrence-256 | development | qbe | 1.51243 | 0.875053 | False |
| coverage-numeric-recurrence-256 | development | baseline | 1.72839 | 1 | False |
| coverage-numeric-recurrence-256 | development | candidate | 1.46669 | 0.848585 | False |
| coverage-numeric-recurrence-1024 | heldout | c | 1 | 0.606706 | False |
| coverage-numeric-recurrence-1024 | heldout | qbe | 1.50091 | 0.91061 | False |
| coverage-numeric-recurrence-1024 | heldout | baseline | 1.64824 | 1 | False |
| coverage-numeric-recurrence-1024 | heldout | candidate | 1.45406 | 0.882187 | False |
| coverage-record-aggregation-64 | heldout | c | 1 | 0.348075 | False |
| coverage-record-aggregation-64 | heldout | qbe | 2.29211 | 0.797827 | False |
| coverage-record-aggregation-64 | heldout | baseline | 2.87294 | 1 | False |
| coverage-record-aggregation-64 | heldout | candidate | 2.877 | 1.00141 | False |
| coverage-record-aggregation-256 | heldout | c | 1 | 0.350638 | False |
| coverage-record-aggregation-256 | heldout | qbe | 2.28181 | 0.800089 | False |
| coverage-record-aggregation-256 | heldout | baseline | 2.85194 | 1 | False |
| coverage-record-aggregation-256 | heldout | candidate | 2.84347 | 0.997028 | False |

## Worst regressions against frozen baseline

c: coverage-closures-256 10.4631×, coverage-closures-64 10.0437×, coverage-list-pipeline-128 1.34941×, coverage-list-pipeline-512 1.23739×.
qbe: none.
baseline: none.
candidate: coverage-expression-128 1.02901×, lexer 1.01008×, complete-generic-row32 1.00958×, coverage-unicode-text-16 1.00827×, coverage-expression-32 1.00788×, coverage-unicode-text-64 1.00762×, test-morning-program 1.00515×, coverage-record-aggregation-64 1.00141×.

## Separate compiler API costs

No emission receipts supplied; compiler costs unmeasured here.

## Family and positive-excess diagnostics

| Subset | Role | Versus | Eligible families | Equal-family geomean | Positive fixed-catalog excess ms |
|---|---|---|---:|---:|---:|
| all | c | overC | 22 | 1 | 0 |
| all | c | overBaseline | 22 | 0.460011 | 169.986 |
| all | qbe | overC | 22 | 1.4354 | 7213.55 |
| all | qbe | overBaseline | 22 | 0.660301 | 0 |
| all | baseline | overC | 22 | 2.17386 | 15892.3 |
| all | baseline | overBaseline | 22 | 1 | 0 |
| all | candidate | overC | 22 | 2.04458 | 14476 |
| all | candidate | overBaseline | 22 | 0.940527 | 28.467 |
| development | c | overC | 10 | 1 | 0 |
| development | c | overBaseline | 10 | 0.39747 | 0 |
| development | qbe | overC | 10 | 1.60133 | 1535.2 |
| development | qbe | overBaseline | 10 | 0.636482 | 0 |
| development | baseline | overC | 10 | 2.51591 | 4070.1 |
| development | baseline | overBaseline | 10 | 1 | 0 |
| development | candidate | overC | 10 | 2.3801 | 3762.8 |
| development | candidate | overBaseline | 10 | 0.946018 | 8.42125 |
| heldout | c | overC | 20 | 1 | 0 |
| heldout | c | overBaseline | 20 | 0.476313 | 169.986 |
| heldout | qbe | overC | 20 | 1.40663 | 5678.35 |
| heldout | qbe | overBaseline | 20 | 0.669998 | 0 |
| heldout | baseline | overC | 20 | 2.09946 | 11822.2 |
| heldout | baseline | overBaseline | 20 | 1 | 0 |
| heldout | candidate | overC | 20 | 1.97616 | 10713.2 |
| heldout | candidate | overBaseline | 20 | 0.941269 | 20.0458 |
