# Generated-program execution

Status: **budget-exhausted**; 1/8 selected cases complete.

Times include export invocation, exact result validation and checksum work; import and first calls are separate.
The budget is a maximum wall time, not a request to pad a short run. Short warmups are screens, not steady-state evidence.

| Case | Paired rounds | Baseline ms | Candidate ms | TypeScript ms | Candidate / TS (or baseline / TS) |
|---|---:|---:|---:|---:|---:|
| local-pair | 3/3 | 1.44453 | 1.44724 | 1.23728 | 1.170× |
| local-fold | 2/3 | — | — | — | — |
| scalar-region-0 | 2/3 | — | — | — | — |
| scalar-region-8192 | 2/3 | — | — | — | — |
| complete-generic-row32 | 2/3 | — | — | — | — |
| mandelbrot | 2/3 | — | — | — | — |
| editdist | 2/3 | — | — | — | — |
| test-rle-roundtrip | 2/3 | — | — | — | — |

Missing, failed and partial samples remain in report.json; incomplete cases have no comparison ratio.
Output agreement on these fixed inputs is not a full conformance gate. No historical timing is used as a denominator.
