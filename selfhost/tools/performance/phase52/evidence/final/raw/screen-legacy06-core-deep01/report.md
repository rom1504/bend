# Generated-program execution

Status: **measured**; 8/8 selected cases complete.

Times include export invocation, exact result validation and checksum work; import and first calls are separate.
The budget is a maximum wall time, not a request to pad a short run. Short warmups are screens, not steady-state evidence.

| Case | Paired rounds | Baseline ms | Candidate ms | TypeScript ms | Candidate / TS (or baseline / TS) |
|---|---:|---:|---:|---:|---:|
| local-pair | 5/5 | 1.42522 | 1.43311 | 1.23762 | 1.158× |
| local-fold | 5/5 | 0.0611447 | 0.0616578 | 0.0411656 | 1.498× |
| scalar-region-0 | 5/5 | 0.00411928 | 0.00404894 | 6.71492e-05 | 60.298× |
| scalar-region-8192 | 5/5 | 0.112058 | 0.111931 | 0.0995552 | 1.124× |
| complete-generic-row32 | 5/5 | 0.0284316 | 0.0281299 | 0.00683249 | 4.117× |
| mandelbrot | 5/5 | 0.121138 | 0.120967 | 0.0455266 | 2.657× |
| editdist | 5/5 | 5.65239 | 5.66985 | 4.97497 | 1.140× |
| test-rle-roundtrip | 5/5 | 0.0319082 | 0.0323407 | 0.000544427 | 59.403× |

Missing, failed and partial samples remain in report.json; incomplete cases have no comparison ratio.
Output agreement on these fixed inputs is not a full conformance gate. No historical timing is used as a denominator.
