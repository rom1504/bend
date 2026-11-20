# Phase198 broad runtime summary

Ratios are ratios of role medians from this runtime report. Frozen baseline means authenticated executable identities, freshly timed in the same report. All eligible cases remain included, including dispersion flags. Fixed-equivalent sums use original catalog repetitions, never adaptive calibration counts; zero-work cases remain correctness-only. Partial development/heldout coverage is explicit; no unseen results, significance or promotion claim. All45 cases and44 nonzero timed cases retained. Candidate and baseline are QBE-produced nativeN1 images; exact hosted and later native-generation comparisons establish transfer separately. The conservative heldout partition excludes all six Phase197 study cases.

Runtime receipt: `/home/ai/bend2/build/publish/bend/selfhost/build/phase198/broad-runtime01/report.json`
Validated observations: {"pilots": 448, "samples": 405}.

Warning: Dispersion exceeds threshold: tree-bitonic, lexer, test-rle-roundtrip, raytrace, variation-tree-bitonic-9-123, variation-local-fold-8192-123, variation-ray-active-64-2440, coverage-closures-256, coverage-list-pipeline-128, coverage-list-pipeline-512, coverage-bst-32, coverage-expression-32, coverage-map-churn-32, coverage-numeric-recurrence-1024, coverage-record-aggregation-64

## all

45/45 cases observed; 44 ratio eligible.

| Role | Versus | Geomean | Mean positive log slowdown | >1.1× | >2× | Fixed-equivalent ms | Reference ms |
|---|---|---:|---:|---:|---:|---:|---:|
| c | overC | 1 | 0 | 0 | 0 | 10514.2 | 10514.2 |
| c | overBaseline | 0.526986 | 0.130187 | 4 | 2 | 10514.2 | 23819.5 |
| baseline | overC | 1.89758 | 0.770768 | 36 | 26 | 23819.5 | 10514.2 |
| baseline | overBaseline | 1 | 0 | 0 | 0 | 23819.5 | 23819.5 |
| candidate | overC | 1.87145 | 0.754466 | 36 | 26 | 23531.2 | 10514.2 |
| candidate | overBaseline | 0.986228 | 0.010658 | 1 | 0 | 23531.2 | 23819.5 |

## development

14/14 cases observed; 14 ratio eligible.

| Role | Versus | Geomean | Mean positive log slowdown | >1.1× | >2× | Fixed-equivalent ms | Reference ms |
|---|---|---:|---:|---:|---:|---:|---:|
| c | overC | 1 | 0 | 0 | 0 | 3723.25 | 3723.25 |
| c | overBaseline | 0.416865 | 0 | 0 | 0 | 3723.25 | 9080.32 |
| baseline | overC | 2.39886 | 0.874992 | 14 | 8 | 9080.32 | 3723.25 |
| baseline | overBaseline | 1 | 0 | 0 | 0 | 9080.32 | 9080.32 |
| candidate | overC | 2.32023 | 0.841668 | 14 | 8 | 8904.02 | 3723.25 |
| candidate | overBaseline | 0.967225 | 0.00311998 | 0 | 0 | 8904.02 | 9080.32 |

## heldout

31/31 cases observed; 30 ratio eligible.

| Role | Versus | Geomean | Mean positive log slowdown | >1.1× | >2× | Fixed-equivalent ms | Reference ms |
|---|---|---:|---:|---:|---:|---:|---:|
| c | overC | 1 | 0 | 0 | 0 | 6790.97 | 6790.97 |
| c | overBaseline | 0.587905 | 0.19094 | 4 | 2 | 6790.97 | 14739.2 |
| baseline | overC | 1.70095 | 0.722129 | 22 | 18 | 14739.2 | 6790.97 |
| baseline | overBaseline | 1 | 0 | 0 | 0 | 14739.2 | 14739.2 |
| candidate | overC | 1.69283 | 0.713772 | 22 | 18 | 14627.2 | 6790.97 |
| candidate | overBaseline | 0.995223 | 0.0141758 | 1 | 0 | 14627.2 | 14739.2 |

## Per-case ratios

| Case | Partition | Role | / C | / baseline | Dispersion flag |
|---|---|---|---:|---:|---|
| mandelbrot | development | c | 1 | 0.287528 | False |
| mandelbrot | development | baseline | 3.47792 | 1 | False |
| mandelbrot | development | candidate | 3.48725 | 1.00268 | False |
| editdist | development | c | 1 | 0.526916 | False |
| editdist | development | baseline | 1.89784 | 1 | False |
| editdist | development | candidate | 1.62942 | 0.858565 | False |
| tree-bitonic | development | c | 1 | 0.312391 | True |
| tree-bitonic | development | baseline | 3.20112 | 1 | True |
| tree-bitonic | development | candidate | 3.12864 | 0.977358 | True |
| lexer | development | c | 1 | 0.375004 | True |
| lexer | development | baseline | 2.66664 | 1 | True |
| lexer | development | candidate | 2.73028 | 1.02387 | True |
| symreg | heldout | c | 1 | 0.983057 | False |
| symreg | heldout | baseline | 1.01723 | 1 | False |
| symreg | heldout | candidate | 1.06043 | 1.04246 | False |
| test-morning-program | heldout | c | 1 | 0.294304 | False |
| test-morning-program | heldout | baseline | 3.39785 | 1 | False |
| test-morning-program | heldout | candidate | 3.36318 | 0.989796 | False |
| test-evening-program | heldout | c | 1 | 0.249557 | False |
| test-evening-program | heldout | baseline | 4.0071 | 1 | False |
| test-evening-program | heldout | candidate | 4.04796 | 1.0102 | False |
| test-rle-roundtrip | heldout | c | 1 | 0.402065 | True |
| test-rle-roundtrip | heldout | baseline | 2.48716 | 1 | True |
| test-rle-roundtrip | heldout | candidate | 2.43928 | 0.980748 | True |
| test-map-set-ops | development | c | 1 | 0.344481 | False |
| test-map-set-ops | development | baseline | 2.90292 | 1 | False |
| test-map-set-ops | development | candidate | 2.88525 | 0.993913 | False |
| raytrace | heldout | c | 1 | 0.583904 | True |
| raytrace | heldout | baseline | 1.71261 | 1 | True |
| raytrace | heldout | candidate | 1.70088 | 0.993151 | True |
| local-pair | development | c | 1 | 0.524738 | False |
| local-pair | development | baseline | 1.90571 | 1 | False |
| local-pair | development | candidate | 1.64425 | 0.862801 | False |
| local-fold | development | c | 1 | 0.491148 | False |
| local-fold | development | baseline | 2.03605 | 1 | False |
| local-fold | development | candidate | 2.04152 | 1.00269 | False |
| scalar-region-0 | heldout | c | ineligible | ineligible | False |
| scalar-region-0 | heldout | baseline | ineligible | ineligible | False |
| scalar-region-0 | heldout | candidate | ineligible | ineligible | False |
| scalar-region-8192 | heldout | c | 1 | 0.465952 | False |
| scalar-region-8192 | heldout | baseline | 2.14614 | 1 | False |
| scalar-region-8192 | heldout | candidate | 2.16798 | 1.01017 | False |
| complete-generic-row32 | heldout | c | 1 | 0.307572 | False |
| complete-generic-row32 | heldout | baseline | 3.25127 | 1 | False |
| complete-generic-row32 | heldout | candidate | 3.26826 | 1.00522 | False |
| variation-editdist-0-17 | heldout | c | 1 | 0.533333 | False |
| variation-editdist-0-17 | heldout | baseline | 1.875 | 1 | False |
| variation-editdist-0-17 | heldout | candidate | 1.60608 | 0.856578 | False |
| variation-editdist-3-123 | development | c | 1 | 0.523964 | False |
| variation-editdist-3-123 | development | baseline | 1.90853 | 1 | False |
| variation-editdist-3-123 | development | candidate | 1.63087 | 0.854514 | False |
| variation-lexer-6-17 | heldout | c | 1 | 0.375977 | False |
| variation-lexer-6-17 | heldout | baseline | 2.65974 | 1 | False |
| variation-lexer-6-17 | heldout | candidate | 2.85205 | 1.0723 | False |
| variation-lexer-10-123 | heldout | c | 1 | 0.378871 | False |
| variation-lexer-10-123 | heldout | baseline | 2.63942 | 1 | False |
| variation-lexer-10-123 | heldout | candidate | 2.62903 | 0.996063 | False |
| variation-tree-bitonic-6-17 | heldout | c | 1 | 0.300713 | False |
| variation-tree-bitonic-6-17 | heldout | baseline | 3.32543 | 1 | False |
| variation-tree-bitonic-6-17 | heldout | candidate | 3.30972 | 0.995274 | False |
| variation-tree-bitonic-9-123 | heldout | c | 1 | 0.262895 | True |
| variation-tree-bitonic-9-123 | heldout | baseline | 3.8038 | 1 | True |
| variation-tree-bitonic-9-123 | heldout | candidate | 3.79961 | 0.998897 | True |
| variation-symreg-4-17 | heldout | c | 1 | 0.955688 | False |
| variation-symreg-4-17 | heldout | baseline | 1.04637 | 1 | False |
| variation-symreg-4-17 | heldout | candidate | 1.08458 | 1.03652 | False |
| variation-symreg-7-123 | heldout | c | 1 | 0.961538 | False |
| variation-symreg-7-123 | heldout | baseline | 1.04 | 1 | False |
| variation-symreg-7-123 | heldout | candidate | 1.07966 | 1.03814 | False |
| variation-local-fold-128-0 | heldout | c | 1 | 0.374944 | False |
| variation-local-fold-128-0 | heldout | baseline | 2.66706 | 1 | False |
| variation-local-fold-128-0 | heldout | candidate | 2.82151 | 1.05791 | False |
| variation-local-fold-8192-123 | heldout | c | 1 | 0.495466 | True |
| variation-local-fold-8192-123 | heldout | baseline | 2.0183 | 1 | True |
| variation-local-fold-8192-123 | heldout | candidate | 2.03317 | 1.00737 | True |
| variation-mandelbrot-grid-4-7 | heldout | c | 1 | 0.35642 | False |
| variation-mandelbrot-grid-4-7 | heldout | baseline | 2.80568 | 1 | False |
| variation-mandelbrot-grid-4-7 | heldout | candidate | 2.78356 | 0.992118 | False |
| variation-mandelbrot-grid-5-31 | heldout | c | 1 | 0.37257 | False |
| variation-mandelbrot-grid-5-31 | heldout | baseline | 2.68406 | 1 | False |
| variation-mandelbrot-grid-5-31 | heldout | candidate | 2.63966 | 0.983459 | False |
| variation-ray-active-64-2440 | development | c | 1 | 0.536769 | True |
| variation-ray-active-64-2440 | development | baseline | 1.863 | 1 | True |
| variation-ray-active-64-2440 | development | candidate | 1.8652 | 1.00118 | True |
| variation-ray-active-256-2240 | heldout | c | 1 | 0.600201 | False |
| variation-ray-active-256-2240 | heldout | baseline | 1.66611 | 1 | False |
| variation-ray-active-256-2240 | heldout | candidate | 1.66611 | 1 | False |
| coverage-closures-64 | heldout | c | 1 | 12.8984 | False |
| coverage-closures-64 | heldout | baseline | 0.0775292 | 1 | False |
| coverage-closures-64 | heldout | candidate | 0.0775435 | 1.00018 | False |
| coverage-closures-256 | heldout | c | 1 | 13.8943 | True |
| coverage-closures-256 | heldout | baseline | 0.0719719 | 1 | True |
| coverage-closures-256 | heldout | candidate | 0.071985 | 1.00018 | True |
| coverage-list-pipeline-128 | heldout | c | 1 | 1.48766 | True |
| coverage-list-pipeline-128 | heldout | baseline | 0.672197 | 1 | True |
| coverage-list-pipeline-128 | heldout | candidate | 0.764231 | 1.13692 | True |
| coverage-list-pipeline-512 | heldout | c | 1 | 1.15307 | True |
| coverage-list-pipeline-512 | heldout | baseline | 0.867253 | 1 | True |
| coverage-list-pipeline-512 | heldout | candidate | 0.848718 | 0.978627 | True |
| coverage-bst-32 | development | c | 1 | 0.237514 | True |
| coverage-bst-32 | development | baseline | 4.21027 | 1 | True |
| coverage-bst-32 | development | candidate | 4.2124 | 1.00051 | True |
| coverage-bst-64 | development | c | 1 | 0.264638 | False |
| coverage-bst-64 | development | baseline | 3.77875 | 1 | False |
| coverage-bst-64 | development | candidate | 3.73438 | 0.988258 | False |
| coverage-unicode-text-16 | heldout | c | 1 | 0.374876 | False |
| coverage-unicode-text-16 | heldout | baseline | 2.66755 | 1 | False |
| coverage-unicode-text-16 | heldout | candidate | 2.65692 | 0.996016 | False |
| coverage-unicode-text-64 | heldout | c | 1 | 0.39067 | False |
| coverage-unicode-text-64 | heldout | baseline | 2.5597 | 1 | False |
| coverage-unicode-text-64 | heldout | candidate | 2.56466 | 1.00194 | False |
| coverage-expression-32 | development | c | 1 | 0.88715 | True |
| coverage-expression-32 | development | baseline | 1.12721 | 1 | True |
| coverage-expression-32 | development | candidate | 1.11363 | 0.987961 | True |
| coverage-expression-128 | heldout | c | 1 | 0.927059 | False |
| coverage-expression-128 | heldout | baseline | 1.07868 | 1 | False |
| coverage-expression-128 | heldout | candidate | 1.04687 | 0.970509 | False |
| coverage-map-churn-32 | development | c | 1 | 0.286177 | True |
| coverage-map-churn-32 | development | baseline | 3.49434 | 1 | True |
| coverage-map-churn-32 | development | candidate | 3.5254 | 1.00889 | True |
| coverage-map-churn-128 | heldout | c | 1 | 0.281215 | False |
| coverage-map-churn-128 | heldout | baseline | 3.556 | 1 | False |
| coverage-map-churn-128 | heldout | candidate | 3.59098 | 1.00984 | False |
| coverage-numeric-recurrence-256 | development | c | 1 | 0.676711 | False |
| coverage-numeric-recurrence-256 | development | baseline | 1.47774 | 1 | False |
| coverage-numeric-recurrence-256 | development | candidate | 1.48394 | 1.0042 | False |
| coverage-numeric-recurrence-1024 | heldout | c | 1 | 0.532629 | True |
| coverage-numeric-recurrence-1024 | heldout | baseline | 1.87748 | 1 | True |
| coverage-numeric-recurrence-1024 | heldout | candidate | 1.88899 | 1.00613 | True |
| coverage-record-aggregation-64 | heldout | c | 1 | 0.272609 | True |
| coverage-record-aggregation-64 | heldout | baseline | 3.66826 | 1 | True |
| coverage-record-aggregation-64 | heldout | candidate | 2.75132 | 0.750035 | True |
| coverage-record-aggregation-256 | heldout | c | 1 | 0.354733 | False |
| coverage-record-aggregation-256 | heldout | baseline | 2.81902 | 1 | False |
| coverage-record-aggregation-256 | heldout | candidate | 2.83301 | 1.00496 | False |

## Worst regressions against frozen baseline

c: coverage-closures-256 13.8943×, coverage-closures-64 12.8984×, coverage-list-pipeline-128 1.48766×, coverage-list-pipeline-512 1.15307×.
baseline: none.
candidate: coverage-list-pipeline-128 1.13692×, variation-lexer-6-17 1.0723×, variation-local-fold-128-0 1.05791×, symreg 1.04246×, variation-symreg-7-123 1.03814×, variation-symreg-4-17 1.03652×, lexer 1.02387×, test-evening-program 1.0102×, scalar-region-8192 1.01017×, coverage-map-churn-128 1.00984×.

## Separate compiler API costs

No emission receipts supplied; compiler costs unmeasured here.

## Family and positive-excess diagnostics

| Subset | Role | Versus | Eligible families | Equal-family geomean | Positive fixed-catalog excess ms |
|---|---|---|---:|---:|---:|
| all | c | overC | 22 | 1 | 0 |
| all | c | overBaseline | 22 | 0.505294 | 187.609 |
| all | baseline | overC | 22 | 1.97905 | 13492.9 |
| all | baseline | overBaseline | 22 | 1 | 0 |
| all | candidate | overC | 22 | 1.94849 | 13190.3 |
| all | candidate | overBaseline | 22 | 0.98456 | 183.071 |
| development | c | overC | 12 | 1 | 0 |
| development | c | overBaseline | 12 | 0.4266 | 0 |
| development | baseline | overC | 12 | 2.34412 | 5357.06 |
| development | baseline | overBaseline | 12 | 1 | 0 |
| development | candidate | overC | 12 | 2.28509 | 5180.77 |
| development | candidate | overBaseline | 12 | 0.97482 | 24.0796 |
| heldout | c | overC | 19 | 1 | 0 |
| heldout | c | overBaseline | 19 | 0.532175 | 187.609 |
| heldout | baseline | overC | 19 | 1.87908 | 8135.86 |
| heldout | baseline | overBaseline | 19 | 1 | 0 |
| heldout | candidate | overC | 19 | 1.86161 | 8009.54 |
| heldout | candidate | overBaseline | 19 | 0.990701 | 158.992 |
