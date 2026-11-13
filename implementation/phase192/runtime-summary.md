# Phase192 runtime summary

Ratios are ratios of role medians from this runtime report. Frozen baseline means authenticated executable identities, freshly timed in the same report. All eligible cases remain included, including dispersion flags. Fixed-equivalent sums use original catalog repetitions, never adaptive calibration counts; zero-work cases remain correctness-only. Partial development/heldout coverage is explicit; no unseen results, significance or promotion claim.

Runtime receipt: `/home/ai/bend2/build/publish/bend/selfhost/build/phase192/runtime-combined01/report.json`
Validated observations: {"pilots": 582, "samples": 720}.

Warning: Dispersion exceeds threshold: test-rle-roundtrip, test-map-set-ops, variation-local-fold-128-0, variation-mandelbrot-grid-5-31, variation-ray-active-64-2440, coverage-bst-64, coverage-unicode-text-64, coverage-expression-128, coverage-record-aggregation-64

## all

45/45 cases observed; 44 ratio eligible.

| Role | Versus | Geomean | Mean positive log slowdown | >1.1× | >2× | Fixed-equivalent ms | Reference ms |
|---|---|---:|---:|---:|---:|---:|---:|
| c | overC | 1 | 0 | 0 | 0 | 10255 | 10255 |
| c | overBaseline | 0.363681 | 0.122618 | 4 | 2 | 10255 | 34255.2 |
| qbe | overC | 1.35014 | 0.526671 | 32 | 23 | 16647.7 | 10255 |
| qbe | overBaseline | 0.49102 | 0 | 0 | 0 | 16647.7 | 34255.2 |
| baseline | overC | 2.74966 | 1.1341 | 40 | 37 | 34255.2 | 10255 |
| baseline | overBaseline | 1 | 0 | 0 | 0 | 34255.2 | 34255.2 |
| candidate | overC | 2.20872 | 0.907716 | 36 | 32 | 27570.1 | 10255 |
| candidate | overBaseline | 0.80327 | 0.00978699 | 1 | 0 | 27570.1 | 34255.2 |

## development

9/9 cases observed; 9 ratio eligible.

| Role | Versus | Geomean | Mean positive log slowdown | >1.1× | >2× | Fixed-equivalent ms | Reference ms |
|---|---|---:|---:|---:|---:|---:|---:|
| c | overC | 1 | 0 | 0 | 0 | 2427.68 | 2427.68 |
| c | overBaseline | 0.298572 | 0 | 0 | 0 | 2427.68 | 8031.16 |
| qbe | overC | 1.518 | 0.462451 | 7 | 4 | 3483.04 | 2427.68 |
| qbe | overBaseline | 0.453233 | 0 | 0 | 0 | 3483.04 | 8031.16 |
| baseline | overC | 3.34927 | 1.20874 | 9 | 9 | 8031.16 | 2427.68 |
| baseline | overBaseline | 1 | 0 | 0 | 0 | 8031.16 | 8031.16 |
| candidate | overC | 2.55338 | 0.937417 | 9 | 7 | 6348.6 | 2427.68 |
| candidate | overBaseline | 0.762368 | 0.00388986 | 0 | 0 | 6348.6 | 8031.16 |

## heldout

36/36 cases observed; 35 ratio eligible.

| Role | Versus | Geomean | Mean positive log slowdown | >1.1× | >2× | Fixed-equivalent ms | Reference ms |
|---|---|---:|---:|---:|---:|---:|---:|
| c | overC | 1 | 0 | 0 | 0 | 7827.27 | 7827.27 |
| c | overBaseline | 0.382604 | 0.154148 | 4 | 2 | 7827.27 | 26224 |
| qbe | overC | 1.31006 | 0.543185 | 25 | 19 | 13164.7 | 7827.27 |
| qbe | overBaseline | 0.501236 | 0 | 0 | 0 | 13164.7 | 26224 |
| baseline | overC | 2.61367 | 1.1149 | 31 | 28 | 26224 | 7827.27 |
| baseline | overBaseline | 1 | 0 | 0 | 0 | 26224 | 26224 |
| candidate | overC | 2.12788 | 0.900078 | 27 | 25 | 21221.5 | 7827.27 |
| candidate | overBaseline | 0.814138 | 0.0113034 | 1 | 0 | 21221.5 | 26224 |

## Per-case ratios

| Case | Partition | Role | / C | / baseline | Dispersion flag |
|---|---|---|---:|---:|---|
| mandelbrot | heldout | c | 1 | 0.215484 | False |
| mandelbrot | heldout | qbe | 2.41981 | 0.521431 | False |
| mandelbrot | heldout | baseline | 4.64071 | 1 | False |
| mandelbrot | heldout | candidate | 4.6497 | 1.00194 | False |
| editdist | development | c | 1 | 0.354741 | False |
| editdist | development | qbe | 1.253 | 0.444491 | False |
| editdist | development | baseline | 2.81896 | 1 | False |
| editdist | development | candidate | 2.81334 | 0.998008 | False |
| tree-bitonic | development | c | 1 | 0.20966 | False |
| tree-bitonic | development | qbe | 2.38383 | 0.499792 | False |
| tree-bitonic | development | baseline | 4.76963 | 1 | False |
| tree-bitonic | development | candidate | 3.20598 | 0.672164 | False |
| lexer | development | c | 1 | 0.196258 | False |
| lexer | development | qbe | 2.08417 | 0.409035 | False |
| lexer | development | baseline | 5.09534 | 1 | False |
| lexer | development | candidate | 2.83523 | 0.556436 | False |
| symreg | heldout | c | 1 | 0.512722 | False |
| symreg | heldout | qbe | 0.727172 | 0.372837 | False |
| symreg | heldout | baseline | 1.95037 | 1 | False |
| symreg | heldout | candidate | 1.09009 | 0.558913 | False |
| test-morning-program | heldout | c | 1 | 0.254883 | False |
| test-morning-program | heldout | qbe | 2.81895 | 0.718503 | False |
| test-morning-program | heldout | baseline | 3.92336 | 1 | False |
| test-morning-program | heldout | candidate | 3.8995 | 0.993918 | False |
| test-evening-program | heldout | c | 1 | 0.195535 | False |
| test-evening-program | heldout | qbe | 2.98315 | 0.583311 | False |
| test-evening-program | heldout | baseline | 5.11417 | 1 | False |
| test-evening-program | heldout | candidate | 4.91513 | 0.961081 | False |
| test-rle-roundtrip | heldout | c | 1 | 0.286438 | True |
| test-rle-roundtrip | heldout | qbe | 2.26781 | 0.649588 | True |
| test-rle-roundtrip | heldout | baseline | 3.49115 | 1 | True |
| test-rle-roundtrip | heldout | candidate | 2.87794 | 0.824353 | True |
| test-map-set-ops | heldout | c | 1 | 0.290703 | True |
| test-map-set-ops | heldout | qbe | 2.36847 | 0.688524 | True |
| test-map-set-ops | heldout | baseline | 3.43993 | 1 | True |
| test-map-set-ops | heldout | candidate | 3.32388 | 0.966264 | True |
| raytrace | heldout | c | 1 | 0.248538 | False |
| raytrace | heldout | qbe | 1.02353 | 0.254386 | False |
| raytrace | heldout | baseline | 4.02353 | 1 | False |
| raytrace | heldout | candidate | 1.98706 | 0.49386 | False |
| local-pair | development | c | 1 | 0.353075 | False |
| local-pair | development | qbe | 1.25664 | 0.443689 | False |
| local-pair | development | baseline | 2.83226 | 1 | False |
| local-pair | development | candidate | 2.8744 | 1.01488 | False |
| local-fold | development | c | 1 | 0.410126 | False |
| local-fold | development | qbe | 2.02026 | 0.828562 | False |
| local-fold | development | baseline | 2.43827 | 1 | False |
| local-fold | development | candidate | 2.48813 | 1.02045 | False |
| scalar-region-0 | heldout | c | ineligible | ineligible | False |
| scalar-region-0 | heldout | qbe | ineligible | ineligible | False |
| scalar-region-0 | heldout | baseline | ineligible | ineligible | False |
| scalar-region-0 | heldout | candidate | ineligible | ineligible | False |
| scalar-region-8192 | heldout | c | 1 | 0.320135 | False |
| scalar-region-8192 | heldout | qbe | 1.65189 | 0.528828 | False |
| scalar-region-8192 | heldout | baseline | 3.12369 | 1 | False |
| scalar-region-8192 | heldout | candidate | 3.10908 | 0.995326 | False |
| complete-generic-row32 | heldout | c | 1 | 0.233333 | False |
| complete-generic-row32 | heldout | qbe | 2.9912 | 0.697946 | False |
| complete-generic-row32 | heldout | baseline | 4.28571 | 1 | False |
| complete-generic-row32 | heldout | candidate | 3.25832 | 0.760276 | False |
| variation-editdist-0-17 | heldout | c | 1 | 0.352055 | False |
| variation-editdist-0-17 | heldout | qbe | 1.25539 | 0.441966 | False |
| variation-editdist-0-17 | heldout | baseline | 2.84046 | 1 | False |
| variation-editdist-0-17 | heldout | candidate | 2.82244 | 0.993656 | False |
| variation-editdist-3-123 | heldout | c | 1 | 0.353583 | False |
| variation-editdist-3-123 | heldout | qbe | 1.25514 | 0.443795 | False |
| variation-editdist-3-123 | heldout | baseline | 2.82819 | 1 | False |
| variation-editdist-3-123 | heldout | candidate | 2.82257 | 0.998012 | False |
| variation-lexer-6-17 | heldout | c | 1 | 0.19428 | False |
| variation-lexer-6-17 | heldout | qbe | 2.09699 | 0.407403 | False |
| variation-lexer-6-17 | heldout | baseline | 5.14722 | 1 | False |
| variation-lexer-6-17 | heldout | candidate | 2.8536 | 0.554397 | False |
| variation-lexer-10-123 | heldout | c | 1 | 0.196457 | False |
| variation-lexer-10-123 | heldout | qbe | 2.1034 | 0.413229 | False |
| variation-lexer-10-123 | heldout | baseline | 5.09016 | 1 | False |
| variation-lexer-10-123 | heldout | candidate | 2.84907 | 0.55972 | False |
| variation-tree-bitonic-6-17 | heldout | c | 1 | 0.213796 | False |
| variation-tree-bitonic-6-17 | heldout | qbe | 2.46255 | 0.526483 | False |
| variation-tree-bitonic-6-17 | heldout | baseline | 4.67736 | 1 | False |
| variation-tree-bitonic-6-17 | heldout | candidate | 3.33194 | 0.712356 | False |
| variation-tree-bitonic-9-123 | heldout | c | 1 | 0.212444 | False |
| variation-tree-bitonic-9-123 | heldout | qbe | 2.28269 | 0.484944 | False |
| variation-tree-bitonic-9-123 | heldout | baseline | 4.70713 | 1 | False |
| variation-tree-bitonic-9-123 | heldout | candidate | 3.13306 | 0.6656 | False |
| variation-symreg-4-17 | heldout | c | 1 | 0.511938 | False |
| variation-symreg-4-17 | heldout | qbe | 0.728002 | 0.372692 | False |
| variation-symreg-4-17 | heldout | baseline | 1.95336 | 1 | False |
| variation-symreg-4-17 | heldout | candidate | 1.09935 | 0.562801 | False |
| variation-symreg-7-123 | heldout | c | 1 | 0.51381 | False |
| variation-symreg-7-123 | heldout | qbe | 0.72367 | 0.371829 | False |
| variation-symreg-7-123 | heldout | baseline | 1.94625 | 1 | False |
| variation-symreg-7-123 | heldout | candidate | 1.09202 | 0.561089 | False |
| variation-local-fold-128-0 | heldout | c | 1 | 0.284002 | True |
| variation-local-fold-128-0 | heldout | qbe | 2.4827 | 0.70509 | True |
| variation-local-fold-128-0 | heldout | baseline | 3.5211 | 1 | True |
| variation-local-fold-128-0 | heldout | candidate | 3.03826 | 0.86287 | True |
| variation-local-fold-8192-123 | heldout | c | 1 | 0.413187 | False |
| variation-local-fold-8192-123 | heldout | qbe | 2.01319 | 0.831822 | False |
| variation-local-fold-8192-123 | heldout | baseline | 2.42021 | 1 | False |
| variation-local-fold-8192-123 | heldout | candidate | 2.41564 | 0.998113 | False |
| variation-mandelbrot-grid-4-7 | heldout | c | 1 | 0.273303 | False |
| variation-mandelbrot-grid-4-7 | heldout | qbe | 1.6279 | 0.444911 | False |
| variation-mandelbrot-grid-4-7 | heldout | baseline | 3.65894 | 1 | False |
| variation-mandelbrot-grid-4-7 | heldout | candidate | 3.66674 | 1.00213 | False |
| variation-mandelbrot-grid-5-31 | heldout | c | 1 | 0.305306 | True |
| variation-mandelbrot-grid-5-31 | heldout | qbe | 1.47176 | 0.449338 | True |
| variation-mandelbrot-grid-5-31 | heldout | baseline | 3.2754 | 1 | True |
| variation-mandelbrot-grid-5-31 | heldout | candidate | 3.43147 | 1.04765 | True |
| variation-ray-active-64-2440 | development | c | 1 | 0.353415 | True |
| variation-ray-active-64-2440 | development | qbe | 0.963427 | 0.34049 | True |
| variation-ray-active-64-2440 | development | baseline | 2.82953 | 1 | True |
| variation-ray-active-64-2440 | development | candidate | 2.79601 | 0.988152 | True |
| variation-ray-active-256-2240 | heldout | c | 1 | 0.367219 | False |
| variation-ray-active-256-2240 | heldout | qbe | 0.965592 | 0.354583 | False |
| variation-ray-active-256-2240 | heldout | baseline | 2.72317 | 1 | False |
| variation-ray-active-256-2240 | heldout | candidate | 2.70048 | 0.991668 | False |
| coverage-closures-64 | heldout | c | 1 | 10.9286 | False |
| coverage-closures-64 | heldout | qbe | 0.0761438 | 0.832143 | False |
| coverage-closures-64 | heldout | baseline | 0.0915033 | 1 | False |
| coverage-closures-64 | heldout | candidate | 0.100327 | 1.09643 | False |
| coverage-closures-256 | heldout | c | 1 | 12.9729 | False |
| coverage-closures-256 | heldout | qbe | 0.073135 | 0.948776 | False |
| coverage-closures-256 | heldout | baseline | 0.0770835 | 1 | False |
| coverage-closures-256 | heldout | candidate | 0.0974081 | 1.26367 | False |
| coverage-list-pipeline-128 | heldout | c | 1 | 1.26133 | False |
| coverage-list-pipeline-128 | heldout | qbe | 0.225371 | 0.284266 | False |
| coverage-list-pipeline-128 | heldout | baseline | 0.792817 | 1 | False |
| coverage-list-pipeline-128 | heldout | candidate | 0.794221 | 1.00177 | False |
| coverage-list-pipeline-512 | heldout | c | 1 | 1.23218 | False |
| coverage-list-pipeline-512 | heldout | qbe | 0.216686 | 0.266997 | False |
| coverage-list-pipeline-512 | heldout | baseline | 0.811569 | 1 | False |
| coverage-list-pipeline-512 | heldout | candidate | 0.806785 | 0.994106 | False |
| coverage-bst-32 | heldout | c | 1 | 0.225939 | False |
| coverage-bst-32 | heldout | qbe | 2.77344 | 0.62663 | False |
| coverage-bst-32 | heldout | baseline | 4.42597 | 1 | False |
| coverage-bst-32 | heldout | candidate | 4.27587 | 0.966087 | False |
| coverage-bst-64 | heldout | c | 1 | 0.244234 | True |
| coverage-bst-64 | heldout | qbe | 2.52216 | 0.615998 | True |
| coverage-bst-64 | heldout | baseline | 4.09443 | 1 | True |
| coverage-bst-64 | heldout | candidate | 3.82712 | 0.934713 | True |
| coverage-unicode-text-16 | heldout | c | 1 | 0.245087 | False |
| coverage-unicode-text-16 | heldout | qbe | 2.15464 | 0.528076 | False |
| coverage-unicode-text-16 | heldout | baseline | 4.08018 | 1 | False |
| coverage-unicode-text-16 | heldout | candidate | 2.61435 | 0.640745 | False |
| coverage-unicode-text-64 | heldout | c | 1 | 0.253351 | True |
| coverage-unicode-text-64 | heldout | qbe | 2.09202 | 0.530016 | True |
| coverage-unicode-text-64 | heldout | baseline | 3.94709 | 1 | True |
| coverage-unicode-text-64 | heldout | candidate | 2.5714 | 0.651468 | True |
| coverage-expression-32 | development | c | 1 | 0.372404 | False |
| coverage-expression-32 | development | qbe | 0.691939 | 0.257681 | False |
| coverage-expression-32 | development | baseline | 2.68526 | 1 | False |
| coverage-expression-32 | development | candidate | 1.15561 | 0.430353 | False |
| coverage-expression-128 | heldout | c | 1 | 0.382537 | True |
| coverage-expression-128 | heldout | qbe | 0.701568 | 0.268375 | True |
| coverage-expression-128 | heldout | baseline | 2.61413 | 1 | True |
| coverage-expression-128 | heldout | candidate | 1.08238 | 0.414048 | True |
| coverage-map-churn-32 | development | c | 1 | 0.220699 | False |
| coverage-map-churn-32 | development | qbe | 2.68762 | 0.593154 | False |
| coverage-map-churn-32 | development | baseline | 4.53107 | 1 | False |
| coverage-map-churn-32 | development | candidate | 4.48252 | 0.989286 | False |
| coverage-map-churn-128 | heldout | c | 1 | 0.219664 | False |
| coverage-map-churn-128 | heldout | qbe | 2.68874 | 0.590619 | False |
| coverage-map-churn-128 | heldout | baseline | 4.55242 | 1 | False |
| coverage-map-churn-128 | heldout | candidate | 4.49757 | 0.987952 | False |
| coverage-numeric-recurrence-256 | development | c | 1 | 0.307121 | False |
| coverage-numeric-recurrence-256 | development | qbe | 1.51151 | 0.464218 | False |
| coverage-numeric-recurrence-256 | development | baseline | 3.25604 | 1 | False |
| coverage-numeric-recurrence-256 | development | candidate | 1.7417 | 0.534913 | False |
| coverage-numeric-recurrence-1024 | heldout | c | 1 | 0.296572 | False |
| coverage-numeric-recurrence-1024 | heldout | qbe | 1.57946 | 0.468423 | False |
| coverage-numeric-recurrence-1024 | heldout | baseline | 3.37186 | 1 | False |
| coverage-numeric-recurrence-1024 | heldout | candidate | 1.83007 | 0.542747 | False |
| coverage-record-aggregation-64 | heldout | c | 1 | 0.285359 | True |
| coverage-record-aggregation-64 | heldout | qbe | 2.27897 | 0.650325 | True |
| coverage-record-aggregation-64 | heldout | baseline | 3.50436 | 1 | True |
| coverage-record-aggregation-64 | heldout | candidate | 3.56501 | 1.01731 | True |
| coverage-record-aggregation-256 | heldout | c | 1 | 0.266972 | False |
| coverage-record-aggregation-256 | heldout | qbe | 2.28775 | 0.610764 | False |
| coverage-record-aggregation-256 | heldout | baseline | 3.74571 | 1 | False |
| coverage-record-aggregation-256 | heldout | candidate | 3.62993 | 0.969089 | False |

## Worst regressions against frozen baseline

c: coverage-closures-256 12.9729×, coverage-closures-64 10.9286×, coverage-list-pipeline-128 1.26133×, coverage-list-pipeline-512 1.23218×.
qbe: none.
baseline: none.
candidate: coverage-closures-256 1.26367×, coverage-closures-64 1.09643×, variation-mandelbrot-grid-5-31 1.04765×, local-fold 1.02045×, coverage-record-aggregation-64 1.01731×, local-pair 1.01488×, variation-mandelbrot-grid-4-7 1.00213×, mandelbrot 1.00194×, coverage-list-pipeline-128 1.00177×.

## Separate compiler API costs

candidate: Base 0.593453s; prepareSeconds=178.727s; selectSeconds=147.542s; renderSeconds=3.84075s; objectSeconds=48.382s.
Observed checked hosted API preparation/selection and emission costs, including host serialization and writes in render/object intervals. Single acquisition observations; not native compiler throughput or runtime. Labels do not assert executable identity.
Receipt pinned by runtime report: True.
