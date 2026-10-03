# Selected execution evidence

42 reused checked05 rotations and 3 fresh checked06 rotations; no pooled timing.

Measurement APIs remain explicit per row. Original rejected ray measurements remain in report.json.

| Point | Evidence | Baseline / candidate | Candidate / TS |
|---|---|---:|---:|
| mandelbrot | exact-byte-reuse | 0.912 | 4.333 |
| editdist | exact-byte-reuse | 1.005 | 2.991 |
| tree-bitonic | exact-byte-reuse | 2.176 | 17.153 |
| lexer | exact-byte-reuse | 1.016 | 89.071 |
| symreg | exact-byte-reuse | 1.069 | 2.040 |
| test-morning-program | exact-byte-reuse | 0.991 | 62.231 |
| test-evening-program | exact-byte-reuse | 0.973 | 76.493 |
| test-rle-roundtrip | exact-byte-reuse | 0.992 | 77.046 |
| test-map-set-ops | exact-byte-reuse | 1.029 | 70.394 |
| raytrace | fresh-replacement | 1.010 | 20.370 |
| local-pair | exact-byte-reuse | 0.993 | 3.076 |
| local-fold | exact-byte-reuse | 1.054 | 3.427 |
| scalar-region-0 | exact-byte-reuse | 1.002 | 51.354 |
| scalar-region-8192 | exact-byte-reuse | 0.982 | 1.186 |
| complete-generic-row32 | exact-byte-reuse | 1.060 | 54.111 |
| variation-editdist-0-17 | exact-byte-reuse | 1.001 | 3.056 |
| variation-editdist-3-123 | exact-byte-reuse | 0.991 | 3.027 |
| variation-lexer-6-17 | exact-byte-reuse | 0.994 | 88.179 |
| variation-lexer-10-123 | exact-byte-reuse | 1.012 | 84.615 |
| variation-tree-bitonic-6-17 | exact-byte-reuse | 2.031 | 21.540 |
| variation-tree-bitonic-9-123 | exact-byte-reuse | 1.829 | 17.332 |
| variation-symreg-4-17 | exact-byte-reuse | 1.038 | 2.055 |
| variation-symreg-7-123 | exact-byte-reuse | 1.088 | 1.984 |
| variation-local-fold-128-0 | exact-byte-reuse | 0.933 | 5.874 |
| variation-local-fold-8192-123 | exact-byte-reuse | 0.929 | 2.438 |
| variation-mandelbrot-grid-4-7 | exact-byte-reuse | 1.004 | 2.987 |
| variation-mandelbrot-grid-5-31 | exact-byte-reuse | 1.004 | 1.877 |
| variation-ray-active-64-2440 | fresh-replacement | 0.994 | 27.837 |
| variation-ray-active-256-2240 | fresh-replacement | 1.025 | 27.010 |
| coverage-closures-64 | exact-byte-reuse | 1.012 | 8.207 |
| coverage-closures-256 | exact-byte-reuse | 1.002 | 8.534 |
| coverage-list-pipeline-128 | exact-byte-reuse | 9.973 | 6.516 |
| coverage-list-pipeline-512 | exact-byte-reuse | 13.113 | 4.512 |
| coverage-bst-32 | exact-byte-reuse | 1.043 | 184.387 |
| coverage-bst-64 | exact-byte-reuse | 1.007 | 226.822 |
| coverage-unicode-text-16 | exact-byte-reuse | 1.034 | 21.744 |
| coverage-unicode-text-64 | exact-byte-reuse | 0.995 | 21.408 |
| coverage-expression-32 | exact-byte-reuse | 1.005 | 9.838 |
| coverage-expression-128 | exact-byte-reuse | 1.000 | 5.192 |
| coverage-map-churn-32 | exact-byte-reuse | 0.995 | 102.216 |
| coverage-map-churn-128 | exact-byte-reuse | 1.010 | 94.786 |
| coverage-numeric-recurrence-256 | exact-byte-reuse | 1.005 | 7.468 |
| coverage-numeric-recurrence-1024 | exact-byte-reuse | 1.007 | 2.802 |
| coverage-record-aggregation-64 | exact-byte-reuse | 1.025 | 64.203 |
| coverage-record-aggregation-256 | exact-byte-reuse | 1.001 | 58.963 |
