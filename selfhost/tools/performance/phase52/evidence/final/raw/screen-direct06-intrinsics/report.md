# Generated-program execution

Status: **measured**; 8/8 selected cases complete.

Times include export invocation, exact result validation and checksum work; import and first calls are separate.
The budget is a maximum wall time, not a request to pad a short run. Short warmups are screens, not steady-state evidence.

| Case | Paired rounds | Baseline ms | Candidate ms | TypeScript ms | Candidate / TS (or baseline / TS) |
|---|---:|---:|---:|---:|---:|
| mandelbrot | 3/3 | 0.0832401 | 0.0809981 | 0.0506393 | 1.600× |
| local-pair | 3/3 | 1.75363 | 1.62969 | 1.23479 | 1.320× |
| editdist | 3/3 | 7.08304 | 6.51609 | 5.03308 | 1.295× |
| variation-ray-active-64-2440 | 3/3 | 0.613465 | 0.465985 | 0.302753 | 1.539× |
| variation-local-fold-8192-123 | 3/3 | 0.149423 | 0.137119 | 0.124628 | 1.100× |
| test-morning-program | 3/3 | 0.0030682 | 0.00288419 | 0.00319539 | 0.903× |
| coverage-expression-128 | 3/3 | 0.00935153 | 0.00971355 | 0.00920059 | 1.056× |
| coverage-closures-64 | 3/3 | 0.00643985 | 0.00641272 | 0.00608862 | 1.053× |

Missing, failed and partial samples remain in report.json; incomplete cases have no comparison ratio.
Output agreement on these fixed inputs is not a full conformance gate. No historical timing is used as a denominator.
