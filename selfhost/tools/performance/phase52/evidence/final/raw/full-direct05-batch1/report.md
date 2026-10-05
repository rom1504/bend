# Generated-program execution

Status: **measured**; 15/15 selected cases complete.

Times include export invocation, exact result validation and checksum work; import and first calls are separate.
The budget is a maximum wall time, not a request to pad a short run. Short warmups are screens, not steady-state evidence.

| Case | Paired rounds | Baseline ms | Candidate ms | TypeScript ms | Candidate / TS (or baseline / TS) |
|---|---:|---:|---:|---:|---:|
| variation-editdist-0-17 | 5/5 | 1.50086 | 1.75345 | 1.24458 | 1.409× |
| variation-editdist-3-123 | 5/5 | 11.2761 | 14.561 | 9.95813 | 1.462× |
| variation-lexer-6-17 | 5/5 | 0.619863 | 0.459947 | 0.403097 | 1.141× |
| variation-lexer-10-123 | 5/5 | 10.0812 | 7.43766 | 6.68791 | 1.112× |
| variation-tree-bitonic-6-17 | 5/5 | 0.071607 | 0.0374327 | 0.0367352 | 1.019× |
| variation-tree-bitonic-9-123 | 5/5 | 0.799677 | 0.674993 | 0.699166 | 0.965× |
| variation-symreg-4-17 | 5/5 | 0.782592 | 0.637361 | 0.552466 | 1.154× |
| variation-symreg-7-123 | 5/5 | 2.49278 | 2.24009 | 1.86332 | 1.202× |
| variation-local-fold-128-0 | 5/5 | 0.0147681 | 0.00153273 | 0.00144007 | 1.064× |
| variation-local-fold-8192-123 | 5/5 | 0.109419 | 0.149257 | 0.11855 | 1.259× |
| variation-mandelbrot-grid-4-7 | 5/5 | 0.0431315 | 0.0287293 | 0.0146689 | 1.959× |
| variation-mandelbrot-grid-5-31 | 5/5 | 0.420921 | 0.376999 | 0.232549 | 1.621× |
| variation-ray-active-64-2440 | 5/5 | 0.547602 | 0.609938 | 0.301604 | 2.022× |
| variation-ray-active-256-2240 | 5/5 | 2.18017 | 2.74289 | 1.24638 | 2.201× |
| coverage-closures-64 | 5/5 | 0.00970324 | 0.00576846 | 0.00568574 | 1.015× |

Missing, failed and partial samples remain in report.json; incomplete cases have no comparison ratio.
Output agreement on these fixed inputs is not a full conformance gate. No historical timing is used as a denominator.
