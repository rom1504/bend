# Phase191 runtime summary

Ratios are ratios of role medians from this runtime report. Frozen baseline means authenticated executable identities, freshly timed in the same report. All eligible cases remain included, including dispersion flags. Fixed-equivalent sums use original catalog repetitions, never adaptive calibration counts; zero-work cases remain correctness-only. Partial development/heldout coverage is explicit; no unseen results, significance or promotion claim.

Runtime receipt: `/home/ai/bend2/build/publish/bend/selfhost/build/phase191/runtime01/report.json`
Validated observations: {"pilots": 445, "samples": 810}.

Warning: Dispersion exceeds threshold: variation-ray-active-64-2440, tree-bitonic, symreg, test-morning-program, variation-lexer-10-123, variation-tree-bitonic-9-123, coverage-closures-256, coverage-bst-32, coverage-bst-64, coverage-unicode-text-64, coverage-record-aggregation-256

## all

45/45 cases observed; 44 ratio eligible.

| Role | Versus | Geomean | Mean positive log slowdown | >1.1× | >2× | Fixed-equivalent ms | Reference ms |
|---|---|---:|---:|---:|---:|---:|---:|
| c | overC | 1 | 0 | 0 | 0 | 10243.9 | 10243.9 |
| c | overBaseline | 0.325067 | 0.123018 | 4 | 2 | 10243.9 | 38940.2 |
| baseline | overC | 3.07629 | 1.24674 | 40 | 37 | 38940.2 | 10243.9 |
| baseline | overBaseline | 1 | 0 | 0 | 0 | 38940.2 | 38940.2 |
| candidate | overC | 2.73657 | 1.13153 | 40 | 37 | 34100.2 | 10243.9 |
| candidate | overBaseline | 0.889567 | 0.00767941 | 0 | 0 | 34100.2 | 38940.2 |

## development

8/8 cases observed; 8 ratio eligible.

| Role | Versus | Geomean | Mean positive log slowdown | >1.1× | >2× | Fixed-equivalent ms | Reference ms |
|---|---|---:|---:|---:|---:|---:|---:|
| c | overC | 1 | 0 | 0 | 0 | 2186.45 | 2186.45 |
| c | overBaseline | 0.23939 | 0 | 0 | 0 | 2186.45 | 9055.34 |
| baseline | overC | 4.17728 | 1.42966 | 8 | 8 | 9055.34 | 2186.45 |
| baseline | overBaseline | 1 | 0 | 0 | 0 | 9055.34 | 9055.34 |
| candidate | overC | 3.16885 | 1.15337 | 8 | 8 | 6846.36 | 2186.45 |
| candidate | overBaseline | 0.758592 | 0.010671 | 0 | 0 | 6846.36 | 9055.34 |

## heldout

37/37 cases observed; 36 ratio eligible.

| Role | Versus | Geomean | Mean positive log slowdown | >1.1× | >2× | Fixed-equivalent ms | Reference ms |
|---|---|---:|---:|---:|---:|---:|---:|
| c | overC | 1 | 0 | 0 | 0 | 8057.48 | 8057.48 |
| c | overBaseline | 0.347935 | 0.150356 | 4 | 2 | 8057.48 | 29884.8 |
| baseline | overC | 2.8741 | 1.2061 | 32 | 29 | 29884.8 | 8057.48 |
| baseline | overBaseline | 1 | 0 | 0 | 0 | 29884.8 | 29884.8 |
| candidate | overC | 2.64882 | 1.12668 | 32 | 29 | 27253.8 | 8057.48 |
| candidate | overBaseline | 0.921616 | 0.00701461 | 0 | 0 | 27253.8 | 29884.8 |

## Per-case ratios

| Case | Partition | Role | / C | / baseline | Dispersion flag |
|---|---|---|---:|---:|---|
| local-fold | development | c | 1 | 0.3512 | False |
| local-fold | development | baseline | 2.84738 | 1 | False |
| local-fold | development | candidate | 2.42597 | 0.852 | False |
| coverage-numeric-recurrence-256 | development | c | 1 | 0.333992 | False |
| coverage-numeric-recurrence-256 | development | baseline | 2.99408 | 1 | False |
| coverage-numeric-recurrence-256 | development | candidate | 3.24877 | 1.08506 | False |
| variation-ray-active-64-2440 | development | c | 1 | 0.360541 | True |
| variation-ray-active-64-2440 | development | baseline | 2.77361 | 1 | True |
| variation-ray-active-64-2440 | development | candidate | 2.73687 | 0.986751 | True |
| coverage-map-churn-32 | development | c | 1 | 0.214526 | False |
| coverage-map-churn-32 | development | baseline | 4.66143 | 1 | False |
| coverage-map-churn-32 | development | candidate | 4.54965 | 0.976019 | False |
| coverage-expression-32 | development | c | 1 | 0.375275 | False |
| coverage-expression-32 | development | baseline | 2.66471 | 1 | False |
| coverage-expression-32 | development | candidate | 2.67467 | 1.00374 | False |
| tree-bitonic | development | c | 1 | 0.20954 | True |
| tree-bitonic | development | baseline | 4.77237 | 1 | True |
| tree-bitonic | development | candidate | 4.75203 | 0.995739 | True |
| local-pair | development | c | 1 | 0.117382 | False |
| local-pair | development | baseline | 8.51921 | 1 | False |
| local-pair | development | candidate | 2.83792 | 0.33312 | False |
| editdist | development | c | 1 | 0.128799 | False |
| editdist | development | baseline | 7.76403 | 1 | False |
| editdist | development | candidate | 2.87227 | 0.369946 | False |
| mandelbrot | heldout | c | 1 | 0.200208 | False |
| mandelbrot | heldout | baseline | 4.99481 | 1 | False |
| mandelbrot | heldout | candidate | 4.7029 | 0.941558 | False |
| lexer | heldout | c | 1 | 0.193375 | False |
| lexer | heldout | baseline | 5.17129 | 1 | False |
| lexer | heldout | candidate | 5.10951 | 0.988052 | False |
| symreg | heldout | c | 1 | 0.549319 | True |
| symreg | heldout | baseline | 1.82044 | 1 | True |
| symreg | heldout | candidate | 1.96956 | 1.08191 | True |
| test-morning-program | heldout | c | 1 | 0.251843 | True |
| test-morning-program | heldout | baseline | 3.97073 | 1 | True |
| test-morning-program | heldout | candidate | 3.93143 | 0.990105 | True |
| test-evening-program | heldout | c | 1 | 0.198842 | False |
| test-evening-program | heldout | baseline | 5.02912 | 1 | False |
| test-evening-program | heldout | candidate | 5.03799 | 1.00176 | False |
| test-rle-roundtrip | heldout | c | 1 | 0.303788 | False |
| test-rle-roundtrip | heldout | baseline | 3.29176 | 1 | False |
| test-rle-roundtrip | heldout | candidate | 3.34999 | 1.01769 | False |
| test-map-set-ops | heldout | c | 1 | 0.281046 | False |
| test-map-set-ops | heldout | baseline | 3.55814 | 1 | False |
| test-map-set-ops | heldout | candidate | 3.49814 | 0.983139 | False |
| raytrace | heldout | c | 1 | 0.24514 | False |
| raytrace | heldout | baseline | 4.0793 | 1 | False |
| raytrace | heldout | candidate | 4.01762 | 0.984881 | False |
| scalar-region-0 | heldout | c | ineligible | ineligible | False |
| scalar-region-0 | heldout | baseline | ineligible | ineligible | False |
| scalar-region-0 | heldout | candidate | ineligible | ineligible | False |
| scalar-region-8192 | heldout | c | 1 | 0.283231 | False |
| scalar-region-8192 | heldout | baseline | 3.53069 | 1 | False |
| scalar-region-8192 | heldout | candidate | 3.12488 | 0.885063 | False |
| complete-generic-row32 | heldout | c | 1 | 0.232363 | False |
| complete-generic-row32 | heldout | baseline | 4.30362 | 1 | False |
| complete-generic-row32 | heldout | candidate | 4.27182 | 0.992611 | False |
| variation-editdist-0-17 | heldout | c | 1 | 0.130598 | False |
| variation-editdist-0-17 | heldout | baseline | 7.65711 | 1 | False |
| variation-editdist-0-17 | heldout | candidate | 2.83728 | 0.370542 | False |
| variation-editdist-3-123 | heldout | c | 1 | 0.131057 | False |
| variation-editdist-3-123 | heldout | baseline | 7.63027 | 1 | False |
| variation-editdist-3-123 | heldout | candidate | 2.82878 | 0.370732 | False |
| variation-lexer-6-17 | heldout | c | 1 | 0.193296 | False |
| variation-lexer-6-17 | heldout | baseline | 5.1734 | 1 | False |
| variation-lexer-6-17 | heldout | candidate | 5.10931 | 0.987611 | False |
| variation-lexer-10-123 | heldout | c | 1 | 0.195256 | True |
| variation-lexer-10-123 | heldout | baseline | 5.12149 | 1 | True |
| variation-lexer-10-123 | heldout | candidate | 5.07189 | 0.990315 | True |
| variation-tree-bitonic-6-17 | heldout | c | 1 | 0.204785 | False |
| variation-tree-bitonic-6-17 | heldout | baseline | 4.88318 | 1 | False |
| variation-tree-bitonic-6-17 | heldout | candidate | 4.85735 | 0.99471 | False |
| variation-tree-bitonic-9-123 | heldout | c | 1 | 0.206392 | True |
| variation-tree-bitonic-9-123 | heldout | baseline | 4.84516 | 1 | True |
| variation-tree-bitonic-9-123 | heldout | candidate | 4.809 | 0.992537 | True |
| variation-symreg-4-17 | heldout | c | 1 | 0.516854 | False |
| variation-symreg-4-17 | heldout | baseline | 1.93478 | 1 | False |
| variation-symreg-4-17 | heldout | candidate | 1.97059 | 1.01851 | False |
| variation-symreg-7-123 | heldout | c | 1 | 0.519623 | False |
| variation-symreg-7-123 | heldout | baseline | 1.92447 | 1 | False |
| variation-symreg-7-123 | heldout | candidate | 1.94372 | 1.01 | False |
| variation-local-fold-128-0 | heldout | c | 1 | 0.301312 | False |
| variation-local-fold-128-0 | heldout | baseline | 3.31882 | 1 | False |
| variation-local-fold-128-0 | heldout | candidate | 3.07353 | 0.926091 | False |
| variation-local-fold-8192-123 | heldout | c | 1 | 0.349995 | False |
| variation-local-fold-8192-123 | heldout | baseline | 2.85719 | 1 | False |
| variation-local-fold-8192-123 | heldout | candidate | 2.41147 | 0.844 | False |
| variation-mandelbrot-grid-4-7 | heldout | c | 1 | 0.201814 | False |
| variation-mandelbrot-grid-4-7 | heldout | baseline | 4.95505 | 1 | False |
| variation-mandelbrot-grid-4-7 | heldout | candidate | 3.68255 | 0.743191 | False |
| variation-mandelbrot-grid-5-31 | heldout | c | 1 | 0.252494 | False |
| variation-mandelbrot-grid-5-31 | heldout | baseline | 3.96049 | 1 | False |
| variation-mandelbrot-grid-5-31 | heldout | candidate | 3.35009 | 0.845877 | False |
| variation-ray-active-256-2240 | heldout | c | 1 | 0.363415 | False |
| variation-ray-active-256-2240 | heldout | baseline | 2.75168 | 1 | False |
| variation-ray-active-256-2240 | heldout | candidate | 2.70752 | 0.983951 | False |
| coverage-closures-64 | heldout | c | 1 | 10.6034 | False |
| coverage-closures-64 | heldout | baseline | 0.0943091 | 1 | False |
| coverage-closures-64 | heldout | candidate | 0.091057 | 0.965517 | False |
| coverage-closures-256 | heldout | c | 1 | 12.7826 | True |
| coverage-closures-256 | heldout | baseline | 0.0782312 | 1 | True |
| coverage-closures-256 | heldout | candidate | 0.0739761 | 0.945608 | True |
| coverage-list-pipeline-128 | heldout | c | 1 | 1.28562 | False |
| coverage-list-pipeline-128 | heldout | baseline | 0.777835 | 1 | False |
| coverage-list-pipeline-128 | heldout | candidate | 0.754381 | 0.969847 | False |
| coverage-list-pipeline-512 | heldout | c | 1 | 1.28699 | False |
| coverage-list-pipeline-512 | heldout | baseline | 0.777007 | 1 | False |
| coverage-list-pipeline-512 | heldout | candidate | 0.810413 | 1.04299 | False |
| coverage-bst-32 | heldout | c | 1 | 0.225158 | True |
| coverage-bst-32 | heldout | baseline | 4.44132 | 1 | True |
| coverage-bst-32 | heldout | candidate | 4.60343 | 1.0365 | True |
| coverage-bst-64 | heldout | c | 1 | 0.249378 | True |
| coverage-bst-64 | heldout | baseline | 4.00998 | 1 | True |
| coverage-bst-64 | heldout | candidate | 4.09275 | 1.02064 | True |
| coverage-unicode-text-16 | heldout | c | 1 | 0.239094 | False |
| coverage-unicode-text-16 | heldout | baseline | 4.18246 | 1 | False |
| coverage-unicode-text-16 | heldout | candidate | 4.11954 | 0.984957 | False |
| coverage-unicode-text-64 | heldout | c | 1 | 0.253854 | True |
| coverage-unicode-text-64 | heldout | baseline | 3.93928 | 1 | True |
| coverage-unicode-text-64 | heldout | candidate | 3.91757 | 0.994488 | True |
| coverage-expression-128 | heldout | c | 1 | 0.38125 | False |
| coverage-expression-128 | heldout | baseline | 2.62295 | 1 | False |
| coverage-expression-128 | heldout | candidate | 2.61412 | 0.99663 | False |
| coverage-map-churn-128 | heldout | c | 1 | 0.212185 | False |
| coverage-map-churn-128 | heldout | baseline | 4.71287 | 1 | False |
| coverage-map-churn-128 | heldout | candidate | 4.59966 | 0.975979 | False |
| coverage-numeric-recurrence-1024 | heldout | c | 1 | 0.339125 | False |
| coverage-numeric-recurrence-1024 | heldout | baseline | 2.94876 | 1 | False |
| coverage-numeric-recurrence-1024 | heldout | candidate | 3.03199 | 1.02823 | False |
| coverage-record-aggregation-64 | heldout | c | 1 | 0.263283 | False |
| coverage-record-aggregation-64 | heldout | baseline | 3.79819 | 1 | False |
| coverage-record-aggregation-64 | heldout | candidate | 3.74937 | 0.987145 | False |
| coverage-record-aggregation-256 | heldout | c | 1 | 0.268909 | True |
| coverage-record-aggregation-256 | heldout | baseline | 3.71873 | 1 | True |
| coverage-record-aggregation-256 | heldout | candidate | 3.65459 | 0.982754 | True |

## Worst regressions against frozen baseline

c: coverage-closures-256 12.7826×, coverage-closures-64 10.6034×, coverage-list-pipeline-512 1.28699×, coverage-list-pipeline-128 1.28562×.
baseline: none.
candidate: coverage-numeric-recurrence-256 1.08506×, symreg 1.08191×, coverage-list-pipeline-512 1.04299×, coverage-bst-32 1.0365×, coverage-numeric-recurrence-1024 1.02823×, coverage-bst-64 1.02064×, variation-symreg-4-17 1.01851×, test-rle-roundtrip 1.01769×, variation-symreg-7-123 1.01×, coverage-expression-32 1.00374×.

## Separate compiler API costs

No emission receipts supplied; compiler costs unmeasured here.
