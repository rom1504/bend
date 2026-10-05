# Generated-program execution

Status: **measured**; 3/3 selected cases complete.

Times include export invocation, exact result validation and checksum work; import and first calls are separate.
The budget is a maximum wall time, not a request to pad a short run. Short warmups are screens, not steady-state evidence.

| Case | Paired rounds | Baseline ms | Candidate ms | TypeScript ms | Candidate / TS (or baseline / TS) |
|---|---:|---:|---:|---:|---:|
| test-rle-roundtrip | 3/3 | 0.0517203 | 0.000604869 | 0.000607208 | 0.996× |
| lexer | 3/3 | 3.23579 | 1.99359 | 1.90845 | 1.045× |
| coverage-expression-128 | 3/3 | 0.0657327 | 0.0097077 | 0.00923112 | 1.052× |

Missing, failed and partial samples remain in report.json; incomplete cases have no comparison ratio.
Output agreement on these fixed inputs is not a full conformance gate. No historical timing is used as a denominator.
