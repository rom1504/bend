# Generated-program execution

Status: **measured**; 15/15 selected cases complete.

Times include export invocation, exact result validation and checksum work; import and first calls are separate.
The budget is a maximum wall time, not a request to pad a short run. Short warmups are screens, not steady-state evidence.

| Case | Paired rounds | Baseline ms | Candidate ms | TypeScript ms | Candidate / TS (or baseline / TS) |
|---|---:|---:|---:|---:|---:|
| local-pair | 5/5 | 1.49491 | 1.62293 | 1.23597 | 1.313× |
| local-fold | 5/5 | 0.0605183 | 0.0407549 | 0.0389489 | 1.046× |
| scalar-region-0 | 5/5 | 0.00423637 | 6.81127e-05 | 6.69629e-05 | 1.017× |
| scalar-region-8192 | 5/5 | 0.115373 | 0.1112 | 0.0992819 | 1.120× |
| complete-generic-row32 | 5/5 | 0.0278064 | 0.00680909 | 0.00675722 | 1.008× |
| mandelbrot | 5/5 | 0.126018 | 0.0780906 | 0.045528 | 1.715× |
| editdist | 5/5 | 5.657 | 6.4813 | 4.9296 | 1.315× |
| tree-bitonic | 5/5 | 0.349917 | 0.279689 | 0.281317 | 0.994× |
| lexer | 5/5 | 2.46768 | 1.74781 | 1.66915 | 1.047× |
| symreg | 5/5 | 1.49834 | 1.32396 | 1.11267 | 1.190× |
| test-morning-program | 5/5 | 0.160201 | 0.0028992 | 0.00334318 | 0.867× |
| test-evening-program | 5/5 | 0.12323 | 0.00260675 | 0.00259859 | 1.003× |
| test-rle-roundtrip | 5/5 | 0.0315508 | 0.000579788 | 0.000549391 | 1.055× |
| test-map-set-ops | 5/5 | 1.01207 | 0.0186846 | 0.0204822 | 0.912× |
| raytrace | 3/3 | 60.1475 | 57.4047 | 34.2053 | 1.678× |

Missing, failed and partial samples remain in report.json; incomplete cases have no comparison ratio.
Output agreement on these fixed inputs is not a full conformance gate. No historical timing is used as a denominator.
