# Generated-program execution

Status: **measured**; 8/8 selected cases complete.

Times include export invocation, exact result validation and checksum work; import and first calls are separate.
The budget is a maximum wall time, not a request to pad a short run. Short warmups are screens, not steady-state evidence.

| Case | Paired rounds | Baseline ms | Candidate ms | TypeScript ms | Candidate / TS (or baseline / TS) |
|---|---:|---:|---:|---:|---:|
| mandelbrot | 3/3 | 0.080907 | 0.288681 | 0.0475832 | 6.067× |
| local-pair | 3/3 | 1.62603 | 2.03968 | 1.24278 | 1.641× |
| editdist | 3/3 | 6.5343 | 8.16884 | 5.05327 | 1.617× |
| variation-ray-active-64-2440 | 3/3 | 0.46849 | 0.523859 | 0.30367 | 1.725× |
| variation-local-fold-8192-123 | 3/3 | 0.136856 | 0.132387 | 0.124134 | 1.066× |
| test-morning-program | 3/3 | 0.00290611 | 0.00297292 | 0.0031458 | 0.945× |
| coverage-expression-128 | 3/3 | 0.00971915 | 0.00942073 | 0.00928246 | 1.015× |
| coverage-closures-64 | 3/3 | 0.00610212 | 0.00635622 | 0.00569387 | 1.116× |

Missing, failed and partial samples remain in report.json; incomplete cases have no comparison ratio.
Output agreement on these fixed inputs is not a full conformance gate. No historical timing is used as a denominator.
