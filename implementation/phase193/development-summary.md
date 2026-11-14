# Phase193 runtime summary

Ratios are ratios of role medians from this runtime report. Frozen baseline means authenticated executable identities, freshly timed in the same report. All eligible cases remain included, including dispersion flags. Fixed-equivalent sums use original catalog repetitions, never adaptive calibration counts; zero-work cases remain correctness-only. Partial development/heldout coverage is explicit; no unseen results, significance or promotion claim. Family diagnostics give each observed eligible family equal weight; positive excess sums only positive per-case fixed-catalog time differences. Baseline, C and QBE executable identities are authenticated against the supplied reference manifest and freshly timed in this report. Candidate role names do not establish native generation or qualification.

Runtime receipt: `/home/ai/bend2/build/publish/bend/selfhost/build/phase193/dev-runtime01/report.json`
Validated observations: {"pilots": 51, "samples": 64}.


## all

4/45 cases observed; 4 ratio eligible.

| Role | Versus | Geomean | Mean positive log slowdown | >1.1× | >2× | Fixed-equivalent ms | Reference ms |
|---|---|---:|---:|---:|---:|---:|---:|
| c | overC | 1 | 0 | 0 | 0 | 917.647 | 917.647 |
| c | overBaseline | 0.380144 | 0 | 0 | 0 | 917.647 | 2381.21 |
| qbe | overC | 1.75653 | 0.65322 | 3 | 3 | 1627.55 | 917.647 |
| qbe | overBaseline | 0.667732 | 0 | 0 | 0 | 1627.55 | 2381.21 |
| baseline | overC | 2.63058 | 0.967205 | 4 | 3 | 2381.21 | 917.647 |
| baseline | overBaseline | 1 | 0 | 0 | 0 | 2381.21 | 2381.21 |
| candidate | overC | 2.42985 | 0.887831 | 4 | 3 | 2215.51 | 917.647 |
| candidate | overBaseline | 0.923694 | 0 | 0 | 0 | 2215.51 | 2381.21 |

Unmeasured: complete-generic-row32, coverage-bst-32, coverage-bst-64, coverage-closures-256, coverage-closures-64, coverage-expression-128, coverage-list-pipeline-128, coverage-list-pipeline-512, coverage-map-churn-128, coverage-numeric-recurrence-1024, coverage-numeric-recurrence-256, coverage-record-aggregation-256, coverage-record-aggregation-64, coverage-unicode-text-16, coverage-unicode-text-64, editdist, local-fold, local-pair, mandelbrot, raytrace, scalar-region-0, scalar-region-8192, symreg, test-evening-program, test-map-set-ops, test-morning-program, test-rle-roundtrip, variation-editdist-0-17, variation-editdist-3-123, variation-lexer-10-123, variation-lexer-6-17, variation-local-fold-128-0, variation-local-fold-8192-123, variation-mandelbrot-grid-4-7, variation-mandelbrot-grid-5-31, variation-ray-active-256-2240, variation-ray-active-64-2440, variation-symreg-4-17, variation-symreg-7-123, variation-tree-bitonic-6-17, variation-tree-bitonic-9-123.

## development

4/10 cases observed; 4 ratio eligible.

| Role | Versus | Geomean | Mean positive log slowdown | >1.1× | >2× | Fixed-equivalent ms | Reference ms |
|---|---|---:|---:|---:|---:|---:|---:|
| c | overC | 1 | 0 | 0 | 0 | 917.647 | 917.647 |
| c | overBaseline | 0.380144 | 0 | 0 | 0 | 917.647 | 2381.21 |
| qbe | overC | 1.75653 | 0.65322 | 3 | 3 | 1627.55 | 917.647 |
| qbe | overBaseline | 0.667732 | 0 | 0 | 0 | 1627.55 | 2381.21 |
| baseline | overC | 2.63058 | 0.967205 | 4 | 3 | 2381.21 | 917.647 |
| baseline | overBaseline | 1 | 0 | 0 | 0 | 2381.21 | 2381.21 |
| candidate | overC | 2.42985 | 0.887831 | 4 | 3 | 2215.51 | 917.647 |
| candidate | overBaseline | 0.923694 | 0 | 0 | 0 | 2215.51 | 2381.21 |

Unmeasured: coverage-numeric-recurrence-256, editdist, local-fold, local-pair, test-map-set-ops, variation-ray-active-64-2440.

## heldout

0/35 cases observed; 0 ratio eligible.

| Role | Versus | Geomean | Mean positive log slowdown | >1.1× | >2× | Fixed-equivalent ms | Reference ms |
|---|---|---:|---:|---:|---:|---:|---:|

Unmeasured: complete-generic-row32, coverage-bst-32, coverage-bst-64, coverage-closures-256, coverage-closures-64, coverage-expression-128, coverage-list-pipeline-128, coverage-list-pipeline-512, coverage-map-churn-128, coverage-numeric-recurrence-1024, coverage-record-aggregation-256, coverage-record-aggregation-64, coverage-unicode-text-16, coverage-unicode-text-64, mandelbrot, raytrace, scalar-region-0, scalar-region-8192, symreg, test-evening-program, test-morning-program, test-rle-roundtrip, variation-editdist-0-17, variation-editdist-3-123, variation-lexer-10-123, variation-lexer-6-17, variation-local-fold-128-0, variation-local-fold-8192-123, variation-mandelbrot-grid-4-7, variation-mandelbrot-grid-5-31, variation-ray-active-256-2240, variation-symreg-4-17, variation-symreg-7-123, variation-tree-bitonic-6-17, variation-tree-bitonic-9-123.

## Per-case ratios

| Case | Partition | Role | / C | / baseline | Dispersion flag |
|---|---|---|---:|---:|---|
| coverage-map-churn-32 | development | c | 1 | 0.220578 | False |
| coverage-map-churn-32 | development | qbe | 2.77914 | 0.613016 | False |
| coverage-map-churn-32 | development | baseline | 4.53355 | 1 | False |
| coverage-map-churn-32 | development | candidate | 3.63531 | 0.801869 | False |
| coverage-expression-32 | development | c | 1 | 0.863848 | False |
| coverage-expression-32 | development | qbe | 0.698005 | 0.60297 | False |
| coverage-expression-32 | development | baseline | 1.15761 | 1 | False |
| coverage-expression-32 | development | candidate | 1.1003 | 0.950492 | False |
| tree-bitonic | development | c | 1 | 0.31047 | False |
| tree-bitonic | development | qbe | 2.37133 | 0.736228 | False |
| tree-bitonic | development | baseline | 3.22092 | 1 | False |
| tree-bitonic | development | candidate | 3.16336 | 0.982128 | False |
| lexer | development | c | 1 | 0.353 | False |
| lexer | development | qbe | 2.06945 | 0.730516 | False |
| lexer | development | baseline | 2.83286 | 1 | False |
| lexer | development | candidate | 2.75498 | 0.972507 | False |

## Worst regressions against frozen baseline

c: none.
qbe: none.
baseline: none.
candidate: none.

## Separate compiler API costs

No emission receipts supplied; compiler costs unmeasured here.

## Family and positive-excess diagnostics

| Subset | Role | Versus | Eligible families | Equal-family geomean | Positive fixed-catalog excess ms |
|---|---|---|---:|---:|---:|
| all | c | overC | 4 | 1 | 0 |
| all | c | overBaseline | 4 | 0.380144 | 0 |
| all | qbe | overC | 4 | 1.75653 | 807.748 |
| all | qbe | overBaseline | 4 | 0.667732 | 0 |
| all | baseline | overC | 4 | 2.63058 | 1463.56 |
| all | baseline | overBaseline | 4 | 1 | 0 |
| all | candidate | overC | 4 | 2.42985 | 1297.86 |
| all | candidate | overBaseline | 4 | 0.923694 | 0 |
| development | c | overC | 4 | 1 | 0 |
| development | c | overBaseline | 4 | 0.380144 | 0 |
| development | qbe | overC | 4 | 1.75653 | 807.748 |
| development | qbe | overBaseline | 4 | 0.667732 | 0 |
| development | baseline | overC | 4 | 2.63058 | 1463.56 |
| development | baseline | overBaseline | 4 | 1 | 0 |
| development | candidate | overC | 4 | 2.42985 | 1297.86 |
| development | candidate | overBaseline | 4 | 0.923694 | 0 |
