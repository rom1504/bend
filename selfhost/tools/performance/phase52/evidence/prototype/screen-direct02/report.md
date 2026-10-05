# Generated-program execution

Status: **measured**; 8/8 selected cases complete.

Times include export invocation, exact result validation and checksum work; import and first calls are separate.
The budget is a maximum wall time, not a request to pad a short run. Short warmups are screens, not steady-state evidence.

| Case | Paired rounds | Baseline ms | Candidate ms | TypeScript ms | Candidate / TS (or baseline / TS) |
|---|---:|---:|---:|---:|---:|
| test-rle-roundtrip | 3/3 | 0.0316942 | 0.00107773 | 0.000577389 | 1.867× |
| test-morning-program | 3/3 | 0.192175 | 0.0132696 | 0.00335601 | 3.954× |
| coverage-expression-128 | 3/3 | 0.0446823 | 0.0274071 | 0.00935893 | 2.928× |
| lexer | 3/3 | 2.59495 | 7.74708 | 1.67143 | 4.635× |
| coverage-numeric-recurrence-1024 | 3/3 | 0.0190761 | 0.0321625 | 0.00814946 | 3.947× |
| complete-generic-row32 | 3/3 | 0.0291594 | 0.0227372 | 0.00695399 | 3.270× |
| coverage-closures-64 | 3/3 | 0.00948123 | 0.0113346 | 0.00580926 | 1.951× |
| tree-bitonic | 3/3 | 0.387542 | 0.885533 | 0.283025 | 3.129× |

Missing, failed and partial samples remain in report.json; incomplete cases have no comparison ratio.
Output agreement on these fixed inputs is not a full conformance gate. No historical timing is used as a denominator.
