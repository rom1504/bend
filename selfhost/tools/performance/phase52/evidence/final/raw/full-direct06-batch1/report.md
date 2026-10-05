# Generated-program execution

Status: **measured**; 15/15 selected cases complete.

Times include export invocation, exact result validation and checksum work; import and first calls are separate.
The budget is a maximum wall time, not a request to pad a short run. Short warmups are screens, not steady-state evidence.

| Case | Paired rounds | Baseline ms | Candidate ms | TypeScript ms | Candidate / TS (or baseline / TS) |
|---|---:|---:|---:|---:|---:|
| variation-editdist-0-17 | 5/5 | 1.5008 | 1.61037 | 1.2341 | 1.305× |
| variation-editdist-3-123 | 5/5 | 11.2781 | 12.9684 | 9.84576 | 1.317× |
| variation-lexer-6-17 | 5/5 | 0.625495 | 0.429614 | 0.409394 | 1.049× |
| variation-lexer-10-123 | 5/5 | 9.83819 | 7.02361 | 6.69106 | 1.050× |
| variation-tree-bitonic-6-17 | 5/5 | 0.0709216 | 0.0373473 | 0.0370039 | 1.009× |
| variation-tree-bitonic-9-123 | 5/5 | 0.79874 | 0.672126 | 0.694815 | 0.967× |
| variation-symreg-4-17 | 5/5 | 0.775269 | 0.637862 | 0.550758 | 1.158× |
| variation-symreg-7-123 | 5/5 | 2.49253 | 2.22336 | 1.86783 | 1.190× |
| variation-local-fold-128-0 | 5/5 | 0.0140638 | 0.00146171 | 0.00142833 | 1.023× |
| variation-local-fold-8192-123 | 5/5 | 0.109435 | 0.134007 | 0.115681 | 1.158× |
| variation-mandelbrot-grid-4-7 | 5/5 | 0.042933 | 0.0293934 | 0.0147382 | 1.994× |
| variation-mandelbrot-grid-5-31 | 5/5 | 0.420241 | 0.412521 | 0.233009 | 1.770× |
| variation-ray-active-64-2440 | 5/5 | 0.539626 | 0.467711 | 0.300409 | 1.557× |
| variation-ray-active-256-2240 | 5/5 | 2.18392 | 2.01278 | 1.24658 | 1.615× |
| coverage-closures-64 | 5/5 | 0.00970097 | 0.00579591 | 0.00561217 | 1.033× |

Missing, failed and partial samples remain in report.json; incomplete cases have no comparison ratio.
Output agreement on these fixed inputs is not a full conformance gate. No historical timing is used as a denominator.
