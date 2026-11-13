# Phase190 runtime summary

Ratios are ratios of role medians from this runtime report. Frozen baseline means authenticated executable identities, freshly timed in the same report. All eligible cases remain included, including dispersion flags. Fixed-equivalent sums use original catalog repetitions, never adaptive calibration counts; zero-work cases remain correctness-only. Partial development/heldout coverage is explicit; no unseen results, significance or promotion claim.

Runtime receipt: `/home/ai/bend2/build/publish/bend/selfhost/build/phase190/broad-runtime02/report.json`
Validated observations: {"pilots": 461, "samples": 405}.

Warning: Dispersion exceeds threshold: raytrace, scalar-region-8192, variation-tree-bitonic-6-17, coverage-closures-64

## all

45/45 cases observed; 44 ratio eligible.

| Role | Versus | Geomean | Mean positive log slowdown | >1.1× | >2× | Fixed-equivalent ms | Reference ms |
|---|---|---:|---:|---:|---:|---:|---:|
| c | overC | 1 | 0 | 0 | 0 | 10181.8 | 10181.8 |
| c | overBaseline | 0.251229 | 0.0687147 | 2 | 2 | 10181.8 | 48173.8 |
| baseline | overC | 3.98043 | 1.4501 | 40 | 40 | 48173.8 | 10181.8 |
| baseline | overBaseline | 1 | 0 | 0 | 0 | 48173.8 | 48173.8 |
| candidate | overC | 3.08379 | 1.25003 | 40 | 37 | 38882 | 10181.8 |
| candidate | overBaseline | 0.774739 | 0.00307626 | 1 | 0 | 38882 | 48173.8 |

## development

6/6 cases observed; 6 ratio eligible.

| Role | Versus | Geomean | Mean positive log slowdown | >1.1× | >2× | Fixed-equivalent ms | Reference ms |
|---|---|---:|---:|---:|---:|---:|---:|
| c | overC | 1 | 0 | 0 | 0 | 1796.91 | 1796.91 |
| c | overBaseline | 0.224773 | 0 | 0 | 0 | 1796.91 | 7440.99 |
| baseline | overC | 4.44893 | 1.49266 | 6 | 6 | 7440.99 | 1796.91 |
| baseline | overBaseline | 1 | 0 | 0 | 0 | 7440.99 | 7440.99 |
| candidate | overC | 3.35355 | 1.21002 | 6 | 6 | 5797.28 | 1796.91 |
| candidate | overBaseline | 0.753788 | 0 | 0 | 0 | 5797.28 | 7440.99 |

## heldout

39/39 cases observed; 38 ratio eligible.

| Role | Versus | Geomean | Mean positive log slowdown | >1.1× | >2× | Fixed-equivalent ms | Reference ms |
|---|---|---:|---:|---:|---:|---:|---:|
| c | overC | 1 | 0 | 0 | 0 | 8384.94 | 8384.94 |
| c | overBaseline | 0.255682 | 0.0795644 | 2 | 2 | 8384.94 | 40732.8 |
| baseline | overC | 3.9111 | 1.44338 | 34 | 34 | 40732.8 | 8384.94 |
| baseline | overBaseline | 1 | 0 | 0 | 0 | 40732.8 | 40732.8 |
| candidate | overC | 3.04323 | 1.25634 | 34 | 31 | 33084.7 | 8384.94 |
| candidate | overBaseline | 0.7781 | 0.00356198 | 1 | 0 | 33084.7 | 40732.8 |

## Per-case ratios

| Case | Partition | Role | / C | / baseline | Dispersion flag |
|---|---|---|---:|---:|---|
| mandelbrot | heldout | c | 1 | 0.130259 | False |
| mandelbrot | heldout | baseline | 7.67703 | 1 | False |
| mandelbrot | heldout | candidate | 4.88208 | 0.635933 | False |
| editdist | heldout | c | 1 | 0.13001 | False |
| editdist | heldout | baseline | 7.6917 | 1 | False |
| editdist | heldout | candidate | 7.72886 | 1.00483 | False |
| tree-bitonic | development | c | 1 | 0.190316 | False |
| tree-bitonic | development | baseline | 5.25442 | 1 | False |
| tree-bitonic | development | candidate | 4.80418 | 0.914312 | False |
| lexer | heldout | c | 1 | 0.161838 | False |
| lexer | heldout | baseline | 6.17901 | 1 | False |
| lexer | heldout | candidate | 5.18422 | 0.839004 | False |
| symreg | heldout | c | 1 | 0.461386 | False |
| symreg | heldout | baseline | 2.16738 | 1 | False |
| symreg | heldout | candidate | 1.92242 | 0.886978 | False |
| test-morning-program | heldout | c | 1 | 0.23442 | False |
| test-morning-program | heldout | baseline | 4.26585 | 1 | False |
| test-morning-program | heldout | candidate | 3.94732 | 0.925329 | False |
| test-evening-program | heldout | c | 1 | 0.179322 | False |
| test-evening-program | heldout | baseline | 5.57657 | 1 | False |
| test-evening-program | heldout | candidate | 5.08097 | 0.911128 | False |
| test-rle-roundtrip | heldout | c | 1 | 0.285163 | False |
| test-rle-roundtrip | heldout | baseline | 3.50676 | 1 | False |
| test-rle-roundtrip | heldout | candidate | 3.26958 | 0.932364 | False |
| test-map-set-ops | heldout | c | 1 | 0.254065 | False |
| test-map-set-ops | heldout | baseline | 3.93601 | 1 | False |
| test-map-set-ops | heldout | candidate | 3.56101 | 0.904727 | False |
| raytrace | heldout | c | 1 | 0.213659 | True |
| raytrace | heldout | baseline | 4.68035 | 1 | True |
| raytrace | heldout | candidate | 4.09971 | 0.87594 | True |
| local-pair | heldout | c | 1 | 0.130673 | False |
| local-pair | heldout | baseline | 7.65266 | 1 | False |
| local-pair | heldout | candidate | 8.67762 | 1.13393 | False |
| local-fold | development | c | 1 | 0.128736 | False |
| local-fold | development | baseline | 7.76782 | 1 | False |
| local-fold | development | candidate | 2.84459 | 0.366202 | False |
| scalar-region-0 | heldout | c | ineligible | ineligible | False |
| scalar-region-0 | heldout | baseline | ineligible | ineligible | False |
| scalar-region-0 | heldout | candidate | ineligible | ineligible | False |
| scalar-region-8192 | heldout | c | 1 | 0.14135 | True |
| scalar-region-8192 | heldout | baseline | 7.07465 | 1 | True |
| scalar-region-8192 | heldout | candidate | 3.5613 | 0.503389 | True |
| complete-generic-row32 | heldout | c | 1 | 0.220895 | False |
| complete-generic-row32 | heldout | baseline | 4.52703 | 1 | False |
| complete-generic-row32 | heldout | candidate | 4.22493 | 0.933268 | False |
| variation-editdist-0-17 | heldout | c | 1 | 0.128491 | False |
| variation-editdist-0-17 | heldout | baseline | 7.78265 | 1 | False |
| variation-editdist-0-17 | heldout | candidate | 7.71556 | 0.991379 | False |
| variation-editdist-3-123 | heldout | c | 1 | 0.129885 | False |
| variation-editdist-3-123 | heldout | baseline | 7.69912 | 1 | False |
| variation-editdist-3-123 | heldout | candidate | 7.73649 | 1.00485 | False |
| variation-lexer-6-17 | heldout | c | 1 | 0.162921 | False |
| variation-lexer-6-17 | heldout | baseline | 6.13796 | 1 | False |
| variation-lexer-6-17 | heldout | candidate | 5.13945 | 0.837322 | False |
| variation-lexer-10-123 | heldout | c | 1 | 0.164179 | False |
| variation-lexer-10-123 | heldout | baseline | 6.09091 | 1 | False |
| variation-lexer-10-123 | heldout | candidate | 5.2027 | 0.854174 | False |
| variation-tree-bitonic-6-17 | heldout | c | 1 | 0.181095 | True |
| variation-tree-bitonic-6-17 | heldout | baseline | 5.52197 | 1 | True |
| variation-tree-bitonic-6-17 | heldout | candidate | 4.88384 | 0.884437 | True |
| variation-tree-bitonic-9-123 | heldout | c | 1 | 0.190527 | False |
| variation-tree-bitonic-9-123 | heldout | baseline | 5.24859 | 1 | False |
| variation-tree-bitonic-9-123 | heldout | candidate | 4.78548 | 0.911765 | False |
| variation-symreg-4-17 | heldout | c | 1 | 0.458382 | False |
| variation-symreg-4-17 | heldout | baseline | 2.18159 | 1 | False |
| variation-symreg-4-17 | heldout | candidate | 1.9465 | 0.892242 | False |
| variation-symreg-7-123 | heldout | c | 1 | 0.462278 | False |
| variation-symreg-7-123 | heldout | baseline | 2.1632 | 1 | False |
| variation-symreg-7-123 | heldout | candidate | 1.92214 | 0.888565 | False |
| variation-local-fold-128-0 | heldout | c | 1 | 0.134702 | False |
| variation-local-fold-128-0 | heldout | baseline | 7.4238 | 1 | False |
| variation-local-fold-128-0 | heldout | candidate | 3.32903 | 0.448426 | False |
| variation-local-fold-8192-123 | heldout | c | 1 | 0.128194 | False |
| variation-local-fold-8192-123 | heldout | baseline | 7.80068 | 1 | False |
| variation-local-fold-8192-123 | heldout | candidate | 2.85903 | 0.366511 | False |
| variation-mandelbrot-grid-4-7 | heldout | c | 1 | 0.114011 | False |
| variation-mandelbrot-grid-4-7 | heldout | baseline | 8.77107 | 1 | False |
| variation-mandelbrot-grid-4-7 | heldout | candidate | 4.91357 | 0.560202 | False |
| variation-mandelbrot-grid-5-31 | heldout | c | 1 | 0.131928 | False |
| variation-mandelbrot-grid-5-31 | heldout | baseline | 7.57992 | 1 | False |
| variation-mandelbrot-grid-5-31 | heldout | candidate | 3.935 | 0.519134 | False |
| variation-ray-active-64-2440 | development | c | 1 | 0.300846 | False |
| variation-ray-active-64-2440 | development | baseline | 3.32396 | 1 | False |
| variation-ray-active-64-2440 | development | candidate | 2.75708 | 0.829457 | False |
| variation-ray-active-256-2240 | heldout | c | 1 | 0.301354 | False |
| variation-ray-active-256-2240 | heldout | baseline | 3.31836 | 1 | False |
| variation-ray-active-256-2240 | heldout | candidate | 2.74806 | 0.828137 | False |
| coverage-closures-64 | heldout | c | 1 | 4.24193 | True |
| coverage-closures-64 | heldout | baseline | 0.235742 | 1 | True |
| coverage-closures-64 | heldout | candidate | 0.0944839 | 0.400794 | True |
| coverage-closures-256 | heldout | c | 1 | 4.41239 | False |
| coverage-closures-256 | heldout | baseline | 0.226635 | 1 | False |
| coverage-closures-256 | heldout | candidate | 0.0765287 | 0.337674 | False |
| coverage-list-pipeline-128 | heldout | c | 1 | 1.0553 | False |
| coverage-list-pipeline-128 | heldout | baseline | 0.947598 | 1 | False |
| coverage-list-pipeline-128 | heldout | candidate | 0.766486 | 0.808872 | False |
| coverage-list-pipeline-512 | heldout | c | 1 | 1.04101 | False |
| coverage-list-pipeline-512 | heldout | baseline | 0.960608 | 1 | False |
| coverage-list-pipeline-512 | heldout | candidate | 0.775056 | 0.80684 | False |
| coverage-bst-32 | heldout | c | 1 | 0.180188 | False |
| coverage-bst-32 | heldout | baseline | 5.54976 | 1 | False |
| coverage-bst-32 | heldout | candidate | 4.42788 | 0.79785 | False |
| coverage-bst-64 | heldout | c | 1 | 0.167278 | False |
| coverage-bst-64 | heldout | baseline | 5.97807 | 1 | False |
| coverage-bst-64 | heldout | candidate | 4.16673 | 0.697002 | False |
| coverage-unicode-text-16 | heldout | c | 1 | 0.229531 | False |
| coverage-unicode-text-16 | heldout | baseline | 4.35671 | 1 | False |
| coverage-unicode-text-16 | heldout | candidate | 4.15823 | 0.954443 | False |
| coverage-unicode-text-64 | heldout | c | 1 | 0.241005 | False |
| coverage-unicode-text-64 | heldout | baseline | 4.14929 | 1 | False |
| coverage-unicode-text-64 | heldout | candidate | 3.95669 | 0.953583 | False |
| coverage-expression-32 | development | c | 1 | 0.328103 | False |
| coverage-expression-32 | development | baseline | 3.04783 | 1 | False |
| coverage-expression-32 | development | candidate | 2.69998 | 0.885869 | False |
| coverage-expression-128 | heldout | c | 1 | 0.329186 | False |
| coverage-expression-128 | heldout | baseline | 3.0378 | 1 | False |
| coverage-expression-128 | heldout | candidate | 2.71981 | 0.895322 | False |
| coverage-map-churn-32 | development | c | 1 | 0.193866 | False |
| coverage-map-churn-32 | development | baseline | 5.15821 | 1 | False |
| coverage-map-churn-32 | development | candidate | 4.69785 | 0.910753 | False |
| coverage-map-churn-128 | heldout | c | 1 | 0.192339 | False |
| coverage-map-churn-128 | heldout | baseline | 5.19915 | 1 | False |
| coverage-map-churn-128 | heldout | candidate | 4.74058 | 0.911799 | False |
| coverage-numeric-recurrence-256 | development | c | 1 | 0.275064 | False |
| coverage-numeric-recurrence-256 | development | baseline | 3.63552 | 1 | False |
| coverage-numeric-recurrence-256 | development | candidate | 2.97634 | 0.818684 | False |
| coverage-numeric-recurrence-1024 | heldout | c | 1 | 0.279984 | False |
| coverage-numeric-recurrence-1024 | heldout | baseline | 3.57163 | 1 | False |
| coverage-numeric-recurrence-1024 | heldout | candidate | 2.93955 | 0.823028 | False |
| coverage-record-aggregation-64 | heldout | c | 1 | 0.243939 | False |
| coverage-record-aggregation-64 | heldout | baseline | 4.09939 | 1 | False |
| coverage-record-aggregation-64 | heldout | candidate | 3.78464 | 0.923221 | False |
| coverage-record-aggregation-256 | heldout | c | 1 | 0.244512 | False |
| coverage-record-aggregation-256 | heldout | baseline | 4.08978 | 1 | False |
| coverage-record-aggregation-256 | heldout | candidate | 3.74934 | 0.916758 | False |

## Worst regressions against frozen baseline

c: coverage-closures-256 4.41239×, coverage-closures-64 4.24193×, coverage-list-pipeline-128 1.0553×, coverage-list-pipeline-512 1.04101×.
baseline: none.
candidate: local-pair 1.13393×, variation-editdist-3-123 1.00485×, editdist 1.00483×.

## Separate compiler API costs

No emission receipts supplied; compiler costs unmeasured here.
