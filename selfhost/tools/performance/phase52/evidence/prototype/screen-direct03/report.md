# Generated-program execution

Status: **measured**; 8/8 selected cases complete.

Times include export invocation, exact result validation and checksum work; import and first calls are separate.
The budget is a maximum wall time, not a request to pad a short run. Short warmups are screens, not steady-state evidence.

| Case | Paired rounds | Baseline ms | Candidate ms | TypeScript ms | Candidate / TS (or baseline / TS) |
|---|---:|---:|---:|---:|---:|
| test-rle-roundtrip | 3/3 | 0.0318147 | 0.000499258 | 0.000568814 | 0.878× |
| test-morning-program | 3/3 | 0.192104 | 0.00358117 | 0.00334235 | 1.071× |
| coverage-expression-128 | 3/3 | 0.0436304 | 0.00987814 | 0.00881851 | 1.120× |
| lexer | 3/3 | 2.57225 | 1.86858 | 1.67941 | 1.113× |
| coverage-numeric-recurrence-1024 | 3/3 | 0.0190236 | 0.00764825 | 0.00764834 | 1.000× |
| complete-generic-row32 | 3/3 | 0.0285114 | 0.00730275 | 0.00655363 | 1.114× |
| coverage-closures-64 | 3/3 | 0.00951315 | 0.00622056 | 0.00602865 | 1.032× |
| tree-bitonic | 3/3 | 0.384694 | 0.275572 | 0.281541 | 0.979× |

Missing, failed and partial samples remain in report.json; incomplete cases have no comparison ratio.
Output agreement on these fixed inputs is not a full conformance gate. No historical timing is used as a denominator.
