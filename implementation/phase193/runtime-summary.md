# Phase193 runtime summary

Ratios are ratios of role medians from this runtime report. Frozen baseline means authenticated executable identities, freshly timed in the same report. All eligible cases remain included, including dispersion flags. Fixed-equivalent sums use original catalog repetitions, never adaptive calibration counts; zero-work cases remain correctness-only. Partial development/heldout coverage is explicit; no unseen results, significance or promotion claim. Family diagnostics give each observed eligible family equal weight; positive excess sums only positive per-case fixed-catalog time differences. Baseline, C and QBE executable identities are authenticated against the supplied reference manifest and freshly timed in this report. Candidate role names do not establish native generation or qualification.

Runtime receipt: `/home/ai/bend2/build/publish/bend/selfhost/build/phase193/runtime-combined01/report.json`
Validated observations: {"pilots": 610, "samples": 720}.

Warning: Dispersion exceeds threshold: test-morning-program, test-rle-roundtrip, test-map-set-ops, raytrace, variation-lexer-10-123, variation-tree-bitonic-9-123, variation-local-fold-128-0, variation-local-fold-8192-123, variation-ray-active-64-2440, coverage-unicode-text-16, coverage-unicode-text-64, coverage-record-aggregation-256

## all

45/45 cases observed; 44 ratio eligible.

| Role | Versus | Geomean | Mean positive log slowdown | >1.1× | >2× | Fixed-equivalent ms | Reference ms |
|---|---|---:|---:|---:|---:|---:|---:|
| c | overC | 1 | 0 | 0 | 0 | 10254.3 | 10254.3 |
| c | overBaseline | 0.453415 | 0.116355 | 4 | 2 | 10254.3 | 27587.1 |
| qbe | overC | 1.35449 | 0.531821 | 32 | 22 | 16771.8 | 10254.3 |
| qbe | overBaseline | 0.614146 | 0 | 0 | 0 | 16771.8 | 27587.1 |
| baseline | overC | 2.20549 | 0.907303 | 36 | 33 | 27587.1 | 10254.3 |
| baseline | overBaseline | 1 | 0 | 0 | 0 | 27587.1 | 27587.1 |
| candidate | overC | 2.10259 | 0.860214 | 36 | 33 | 26149.7 | 10254.3 |
| candidate | overBaseline | 0.953347 | 0.0024249 | 0 | 0 | 26149.7 | 27587.1 |

## development

10/10 cases observed; 10 ratio eligible.

| Role | Versus | Geomean | Mean positive log slowdown | >1.1× | >2× | Fixed-equivalent ms | Reference ms |
|---|---|---:|---:|---:|---:|---:|---:|
| c | overC | 1 | 0 | 0 | 0 | 2636.62 | 2636.62 |
| c | overBaseline | 0.383731 | 0 | 0 | 0 | 2636.62 | 6998.29 |
| qbe | overC | 1.59611 | 0.505673 | 8 | 5 | 4077.47 | 2636.62 |
| qbe | overBaseline | 0.612476 | 0 | 0 | 0 | 4077.47 | 6998.29 |
| baseline | overC | 2.60599 | 0.957814 | 10 | 8 | 6998.29 | 2636.62 |
| baseline | overBaseline | 1 | 0 | 0 | 0 | 6998.29 | 6998.29 |
| candidate | overC | 2.50156 | 0.916916 | 10 | 8 | 6735.34 | 2636.62 |
| candidate | overBaseline | 0.959927 | 0.00437082 | 0 | 0 | 6735.34 | 6998.29 |

## heldout

35/35 cases observed; 34 ratio eligible.

| Role | Versus | Geomean | Mean positive log slowdown | >1.1× | >2× | Fixed-equivalent ms | Reference ms |
|---|---|---:|---:|---:|---:|---:|---:|
| c | overC | 1 | 0 | 0 | 0 | 7617.67 | 7617.67 |
| c | overBaseline | 0.476222 | 0.150577 | 4 | 2 | 7617.67 | 20588.8 |
| qbe | overC | 1.29065 | 0.539512 | 24 | 17 | 12694.3 | 7617.67 |
| qbe | overBaseline | 0.614638 | 0 | 0 | 0 | 12694.3 | 20588.8 |
| baseline | overC | 2.09986 | 0.892447 | 26 | 25 | 20588.8 | 7617.67 |
| baseline | overBaseline | 1 | 0 | 0 | 0 | 20588.8 | 20588.8 |
| candidate | overC | 1.99785 | 0.843537 | 26 | 25 | 19414.4 | 7617.67 |
| candidate | overBaseline | 0.95142 | 0.00185258 | 0 | 0 | 19414.4 | 20588.8 |

## Per-case ratios

| Case | Partition | Role | / C | / baseline | Dispersion flag |
|---|---|---|---:|---:|---|
| mandelbrot | heldout | c | 1 | 0.21464 | False |
| mandelbrot | heldout | qbe | 2.42441 | 0.520375 | False |
| mandelbrot | heldout | baseline | 4.65896 | 1 | False |
| mandelbrot | heldout | candidate | 4.26923 | 0.916348 | False |
| editdist | development | c | 1 | 0.354064 | False |
| editdist | development | qbe | 1.2607 | 0.446368 | False |
| editdist | development | baseline | 2.82435 | 1 | False |
| editdist | development | candidate | 2.82435 | 1 | False |
| tree-bitonic | development | c | 1 | 0.314672 | False |
| tree-bitonic | development | qbe | 2.40472 | 0.756697 | False |
| tree-bitonic | development | baseline | 3.17791 | 1 | False |
| tree-bitonic | development | candidate | 3.09714 | 0.974583 | False |
| lexer | development | c | 1 | 0.352232 | False |
| lexer | development | qbe | 2.09379 | 0.7375 | False |
| lexer | development | baseline | 2.83903 | 1 | False |
| lexer | development | candidate | 2.75586 | 0.970703 | False |
| symreg | heldout | c | 1 | 0.915611 | False |
| symreg | heldout | qbe | 0.727181 | 0.665814 | False |
| symreg | heldout | baseline | 1.09217 | 1 | False |
| symreg | heldout | candidate | 1.05825 | 0.968947 | False |
| test-morning-program | heldout | c | 1 | 0.254509 | True |
| test-morning-program | heldout | qbe | 2.85513 | 0.726656 | True |
| test-morning-program | heldout | baseline | 3.92914 | 1 | True |
| test-morning-program | heldout | candidate | 3.33172 | 0.847951 | True |
| test-evening-program | heldout | c | 1 | 0.202457 | False |
| test-evening-program | heldout | qbe | 3.00026 | 0.607423 | False |
| test-evening-program | heldout | baseline | 4.93933 | 1 | False |
| test-evening-program | heldout | candidate | 3.89316 | 0.788196 | False |
| test-rle-roundtrip | heldout | c | 1 | 0.35961 | True |
| test-rle-roundtrip | heldout | qbe | 2.29755 | 0.826221 | True |
| test-rle-roundtrip | heldout | baseline | 2.78079 | 1 | True |
| test-rle-roundtrip | heldout | candidate | 2.41822 | 0.869614 | True |
| test-map-set-ops | development | c | 1 | 0.300659 | True |
| test-map-set-ops | development | qbe | 2.36746 | 0.711798 | True |
| test-map-set-ops | development | baseline | 3.32603 | 1 | True |
| test-map-set-ops | development | candidate | 2.92554 | 0.879591 | True |
| raytrace | heldout | c | 1 | 0.482143 | True |
| raytrace | heldout | qbe | 1.05761 | 0.509921 | True |
| raytrace | heldout | baseline | 2.07407 | 1 | True |
| raytrace | heldout | candidate | 2.04444 | 0.985714 | True |
| local-pair | development | c | 1 | 0.349515 | False |
| local-pair | development | qbe | 1.2569 | 0.439306 | False |
| local-pair | development | baseline | 2.86111 | 1 | False |
| local-pair | development | candidate | 2.86618 | 1.00177 | False |
| local-fold | development | c | 1 | 0.412957 | False |
| local-fold | development | qbe | 2.00214 | 0.826798 | False |
| local-fold | development | baseline | 2.42156 | 1 | False |
| local-fold | development | candidate | 2.52528 | 1.04283 | False |
| scalar-region-0 | heldout | c | ineligible | ineligible | False |
| scalar-region-0 | heldout | qbe | ineligible | ineligible | False |
| scalar-region-0 | heldout | baseline | ineligible | ineligible | False |
| scalar-region-0 | heldout | candidate | ineligible | ineligible | False |
| scalar-region-8192 | heldout | c | 1 | 0.320852 | False |
| scalar-region-8192 | heldout | qbe | 1.653 | 0.53037 | False |
| scalar-region-8192 | heldout | baseline | 3.1167 | 1 | False |
| scalar-region-8192 | heldout | candidate | 3.12724 | 1.00338 | False |
| complete-generic-row32 | heldout | c | 1 | 0.306883 | False |
| complete-generic-row32 | heldout | qbe | 3.01782 | 0.926119 | False |
| complete-generic-row32 | heldout | baseline | 3.25857 | 1 | False |
| complete-generic-row32 | heldout | candidate | 3.23364 | 0.992352 | False |
| variation-editdist-0-17 | heldout | c | 1 | 0.352207 | False |
| variation-editdist-0-17 | heldout | qbe | 1.2626 | 0.444697 | False |
| variation-editdist-0-17 | heldout | baseline | 2.83924 | 1 | False |
| variation-editdist-0-17 | heldout | candidate | 2.82898 | 0.996385 | False |
| variation-editdist-3-123 | heldout | c | 1 | 0.351949 | False |
| variation-editdist-3-123 | heldout | qbe | 1.25769 | 0.442643 | False |
| variation-editdist-3-123 | heldout | baseline | 2.84132 | 1 | False |
| variation-editdist-3-123 | heldout | candidate | 2.8225 | 0.993376 | False |
| variation-lexer-6-17 | heldout | c | 1 | 0.349258 | False |
| variation-lexer-6-17 | heldout | qbe | 2.09935 | 0.733214 | False |
| variation-lexer-6-17 | heldout | baseline | 2.86321 | 1 | False |
| variation-lexer-6-17 | heldout | candidate | 2.76402 | 0.965357 | False |
| variation-lexer-10-123 | heldout | c | 1 | 0.357317 | True |
| variation-lexer-10-123 | heldout | qbe | 2.06688 | 0.73853 | True |
| variation-lexer-10-123 | heldout | baseline | 2.79863 | 1 | True |
| variation-lexer-10-123 | heldout | candidate | 2.73208 | 0.976219 | True |
| variation-tree-bitonic-6-17 | heldout | c | 1 | 0.291113 | False |
| variation-tree-bitonic-6-17 | heldout | qbe | 2.51987 | 0.733569 | False |
| variation-tree-bitonic-6-17 | heldout | baseline | 3.43509 | 1 | False |
| variation-tree-bitonic-6-17 | heldout | candidate | 3.2928 | 0.95858 | False |
| variation-tree-bitonic-9-123 | heldout | c | 1 | 0.320348 | True |
| variation-tree-bitonic-9-123 | heldout | qbe | 2.29875 | 0.7364 | True |
| variation-tree-bitonic-9-123 | heldout | baseline | 3.12161 | 1 | True |
| variation-tree-bitonic-9-123 | heldout | candidate | 3.06674 | 0.982422 | True |
| variation-symreg-4-17 | heldout | c | 1 | 0.912908 | False |
| variation-symreg-4-17 | heldout | qbe | 0.729682 | 0.666133 | False |
| variation-symreg-4-17 | heldout | baseline | 1.0954 | 1 | False |
| variation-symreg-4-17 | heldout | candidate | 1.06018 | 0.967851 | False |
| variation-symreg-7-123 | heldout | c | 1 | 0.911631 | False |
| variation-symreg-7-123 | heldout | qbe | 0.727536 | 0.663245 | False |
| variation-symreg-7-123 | heldout | baseline | 1.09694 | 1 | False |
| variation-symreg-7-123 | heldout | candidate | 1.06031 | 0.96661 | False |
| variation-local-fold-128-0 | heldout | c | 1 | 0.316362 | True |
| variation-local-fold-128-0 | heldout | qbe | 2.60361 | 0.823684 | True |
| variation-local-fold-128-0 | heldout | baseline | 3.16093 | 1 | True |
| variation-local-fold-128-0 | heldout | candidate | 2.95266 | 0.934111 | True |
| variation-local-fold-8192-123 | heldout | c | 1 | 0.415352 | True |
| variation-local-fold-8192-123 | heldout | qbe | 2.00617 | 0.833267 | True |
| variation-local-fold-8192-123 | heldout | baseline | 2.4076 | 1 | True |
| variation-local-fold-8192-123 | heldout | candidate | 2.41702 | 1.00391 | True |
| variation-mandelbrot-grid-4-7 | heldout | c | 1 | 0.265206 | False |
| variation-mandelbrot-grid-4-7 | heldout | qbe | 1.65137 | 0.437953 | False |
| variation-mandelbrot-grid-4-7 | heldout | baseline | 3.77065 | 1 | False |
| variation-mandelbrot-grid-4-7 | heldout | candidate | 3.75656 | 0.996262 | False |
| variation-mandelbrot-grid-5-31 | heldout | c | 1 | 0.28552 | False |
| variation-mandelbrot-grid-5-31 | heldout | qbe | 1.55556 | 0.444142 | False |
| variation-mandelbrot-grid-5-31 | heldout | baseline | 3.50239 | 1 | False |
| variation-mandelbrot-grid-5-31 | heldout | candidate | 3.48767 | 0.995798 | False |
| variation-ray-active-64-2440 | development | c | 1 | 0.368184 | True |
| variation-ray-active-64-2440 | development | qbe | 0.990615 | 0.364729 | True |
| variation-ray-active-64-2440 | development | baseline | 2.71603 | 1 | True |
| variation-ray-active-64-2440 | development | candidate | 2.70125 | 0.994555 | True |
| variation-ray-active-256-2240 | heldout | c | 1 | 0.367064 | False |
| variation-ray-active-256-2240 | heldout | qbe | 0.97028 | 0.356155 | False |
| variation-ray-active-256-2240 | heldout | baseline | 2.72432 | 1 | False |
| variation-ray-active-256-2240 | heldout | candidate | 2.71044 | 0.994905 | False |
| coverage-closures-64 | heldout | c | 1 | 10.0535 | False |
| coverage-closures-64 | heldout | qbe | 0.0759852 | 0.763915 | False |
| coverage-closures-64 | heldout | baseline | 0.0994681 | 1 | False |
| coverage-closures-64 | heldout | candidate | 0.0996304 | 1.00163 | False |
| coverage-closures-256 | heldout | c | 1 | 10.435 | False |
| coverage-closures-256 | heldout | qbe | 0.0726491 | 0.758096 | False |
| coverage-closures-256 | heldout | baseline | 0.0958311 | 1 | False |
| coverage-closures-256 | heldout | candidate | 0.0958095 | 0.999775 | False |
| coverage-list-pipeline-128 | heldout | c | 1 | 1.26351 | False |
| coverage-list-pipeline-128 | heldout | qbe | 0.225402 | 0.284797 | False |
| coverage-list-pipeline-128 | heldout | baseline | 0.791449 | 1 | False |
| coverage-list-pipeline-128 | heldout | candidate | 0.792319 | 1.0011 | False |
| coverage-list-pipeline-512 | heldout | c | 1 | 1.26191 | False |
| coverage-list-pipeline-512 | heldout | qbe | 0.208879 | 0.263587 | False |
| coverage-list-pipeline-512 | heldout | baseline | 0.792447 | 1 | False |
| coverage-list-pipeline-512 | heldout | candidate | 0.766906 | 0.96777 | False |
| coverage-bst-32 | heldout | c | 1 | 0.234875 | False |
| coverage-bst-32 | heldout | qbe | 2.76245 | 0.648831 | False |
| coverage-bst-32 | heldout | baseline | 4.25758 | 1 | False |
| coverage-bst-32 | heldout | candidate | 4.27153 | 1.00328 | False |
| coverage-bst-64 | heldout | c | 1 | 0.261446 | False |
| coverage-bst-64 | heldout | qbe | 2.48953 | 0.650878 | False |
| coverage-bst-64 | heldout | baseline | 3.82488 | 1 | False |
| coverage-bst-64 | heldout | candidate | 3.80315 | 0.99432 | False |
| coverage-unicode-text-16 | heldout | c | 1 | 0.378081 | True |
| coverage-unicode-text-16 | heldout | qbe | 2.35192 | 0.889215 | True |
| coverage-unicode-text-16 | heldout | baseline | 2.64494 | 1 | True |
| coverage-unicode-text-16 | heldout | candidate | 2.57985 | 0.975393 | True |
| coverage-unicode-text-64 | heldout | c | 1 | 0.404957 | True |
| coverage-unicode-text-64 | heldout | qbe | 1.96084 | 0.794056 | True |
| coverage-unicode-text-64 | heldout | baseline | 2.4694 | 1 | True |
| coverage-unicode-text-64 | heldout | candidate | 2.59434 | 1.0506 | True |
| coverage-expression-32 | development | c | 1 | 0.869473 | False |
| coverage-expression-32 | development | qbe | 0.689615 | 0.599602 | False |
| coverage-expression-32 | development | baseline | 1.15012 | 1 | False |
| coverage-expression-32 | development | candidate | 1.10487 | 0.960653 | False |
| coverage-expression-128 | heldout | c | 1 | 0.92391 | False |
| coverage-expression-128 | heldout | qbe | 0.64975 | 0.60031 | False |
| coverage-expression-128 | heldout | baseline | 1.08236 | 1 | False |
| coverage-expression-128 | heldout | candidate | 1.05072 | 0.970772 | False |
| coverage-map-churn-32 | development | c | 1 | 0.221984 | False |
| coverage-map-churn-32 | development | qbe | 2.72488 | 0.604878 | False |
| coverage-map-churn-32 | development | baseline | 4.50484 | 1 | False |
| coverage-map-churn-32 | development | candidate | 3.62592 | 0.804894 | False |
| coverage-map-churn-128 | heldout | c | 1 | 0.220285 | False |
| coverage-map-churn-128 | heldout | qbe | 2.68222 | 0.590853 | False |
| coverage-map-churn-128 | heldout | baseline | 4.53958 | 1 | False |
| coverage-map-churn-128 | heldout | candidate | 3.58855 | 0.790504 | False |
| coverage-numeric-recurrence-256 | development | c | 1 | 0.572023 | False |
| coverage-numeric-recurrence-256 | development | qbe | 1.52432 | 0.871946 | False |
| coverage-numeric-recurrence-256 | development | baseline | 1.74818 | 1 | False |
| coverage-numeric-recurrence-256 | development | candidate | 1.73727 | 0.993757 | False |
| coverage-numeric-recurrence-1024 | heldout | c | 1 | 0.59412 | False |
| coverage-numeric-recurrence-1024 | heldout | qbe | 1.49865 | 0.890377 | False |
| coverage-numeric-recurrence-1024 | heldout | baseline | 1.68316 | 1 | False |
| coverage-numeric-recurrence-1024 | heldout | candidate | 1.68374 | 1.00035 | False |
| coverage-record-aggregation-64 | heldout | c | 1 | 0.27738 | False |
| coverage-record-aggregation-64 | heldout | qbe | 2.34797 | 0.651279 | False |
| coverage-record-aggregation-64 | heldout | baseline | 3.60516 | 1 | False |
| coverage-record-aggregation-64 | heldout | candidate | 2.87401 | 0.797192 | False |
| coverage-record-aggregation-256 | heldout | c | 1 | 0.277734 | True |
| coverage-record-aggregation-256 | heldout | qbe | 2.29371 | 0.637042 | True |
| coverage-record-aggregation-256 | heldout | baseline | 3.60057 | 1 | True |
| coverage-record-aggregation-256 | heldout | candidate | 2.83212 | 0.786574 | True |

## Worst regressions against frozen baseline

c: coverage-closures-256 10.435×, coverage-closures-64 10.0535×, coverage-list-pipeline-128 1.26351×, coverage-list-pipeline-512 1.26191×.
qbe: none.
baseline: none.
candidate: coverage-unicode-text-64 1.0506×, local-fold 1.04283×, variation-local-fold-8192-123 1.00391×, scalar-region-8192 1.00338×, coverage-bst-32 1.00328×, local-pair 1.00177×, coverage-closures-64 1.00163×, coverage-list-pipeline-128 1.0011×, coverage-numeric-recurrence-1024 1.00035×.

## Separate compiler API costs

No emission receipts supplied; compiler costs unmeasured here.

## Family and positive-excess diagnostics

| Subset | Role | Versus | Eligible families | Equal-family geomean | Positive fixed-catalog excess ms |
|---|---|---|---:|---:|---:|
| all | c | overC | 22 | 1 | 0 |
| all | c | overBaseline | 22 | 0.433716 | 166.892 |
| all | qbe | overC | 22 | 1.44191 | 7371.46 |
| all | qbe | overBaseline | 22 | 0.625381 | 0 |
| all | baseline | overC | 22 | 2.30565 | 17499.7 |
| all | baseline | overBaseline | 22 | 1 | 0 |
| all | candidate | overC | 22 | 2.1717 | 16066.2 |
| all | candidate | overBaseline | 22 | 0.9419 | 36.4856 |
| development | c | overC | 10 | 1 | 0 |
| development | c | overBaseline | 10 | 0.383731 | 0 |
| development | qbe | overC | 10 | 1.59611 | 1547.91 |
| development | qbe | overBaseline | 10 | 0.612476 | 0 |
| development | baseline | overC | 10 | 2.60599 | 4361.67 |
| development | baseline | overBaseline | 10 | 1 | 0 |
| development | candidate | overC | 10 | 2.50156 | 4098.72 |
| development | candidate | overBaseline | 10 | 0.959927 | 18.4689 |
| heldout | c | overC | 20 | 1 | 0 |
| heldout | c | overBaseline | 20 | 0.447324 | 166.892 |
| heldout | qbe | overC | 20 | 1.41657 | 5823.55 |
| heldout | qbe | overBaseline | 20 | 0.633664 | 0 |
| heldout | baseline | overC | 20 | 2.23552 | 13138 |
| heldout | baseline | overBaseline | 20 | 1 | 0 |
| heldout | candidate | overC | 20 | 2.10323 | 11967.5 |
| heldout | candidate | overBaseline | 20 | 0.940822 | 18.0167 |
