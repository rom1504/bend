# Generated-program execution

Status: **measured**; 15/15 selected cases complete.

Times include export invocation, exact result validation and checksum work; import and first calls are separate.
The budget is a maximum wall time, not a request to pad a short run. Short warmups are screens, not steady-state evidence.

| Case | Paired rounds | Baseline ms | Candidate ms | TypeScript ms | Candidate / TS (or baseline / TS) |
|---|---:|---:|---:|---:|---:|
| coverage-closures-256 | 5/5 | 0.00987767 | 0.0218999 | 0.0210987 | 1.038× |
| coverage-list-pipeline-128 | 5/5 | 0.0126929 | 0.00643953 | 0.00642448 | 1.002× |
| coverage-list-pipeline-512 | 5/5 | 0.0157883 | 0.028122 | 0.0275637 | 1.020× |
| coverage-unicode-text-16 | 5/5 | 0.0602852 | 0.0198134 | 0.0213485 | 0.928× |
| coverage-unicode-text-64 | 5/5 | 0.141955 | 0.0848491 | 0.0846403 | 1.002× |
| coverage-map-churn-32 | 5/5 | 0.251628 | 0.136495 | 0.142551 | 0.958× |
| coverage-map-churn-128 | 5/5 | 1.05677 | 0.744417 | 0.760513 | 0.979× |
| coverage-numeric-recurrence-256 | 5/5 | 0.0129433 | 0.00198198 | 0.00203735 | 0.973× |
| coverage-numeric-recurrence-1024 | 5/5 | 0.0192989 | 0.0076294 | 0.00762096 | 1.001× |
| coverage-bst-32 | 5/5 | 0.0602149 | 0.0233118 | 0.0222194 | 1.049× |
| coverage-bst-64 | 5/5 | 0.102492 | 0.0558869 | 0.0514087 | 1.087× |
| coverage-expression-32 | 5/5 | 0.019173 | 0.00221298 | 0.00209773 | 1.055× |
| coverage-expression-128 | 5/5 | 0.0404427 | 0.00912347 | 0.00879511 | 1.037× |
| coverage-record-aggregation-64 | 5/5 | 0.441754 | 0.284601 | 0.298278 | 0.954× |
| coverage-record-aggregation-256 | 5/5 | 1.71051 | 1.29292 | 1.24643 | 1.037× |

Missing, failed and partial samples remain in report.json; incomplete cases have no comparison ratio.
Output agreement on these fixed inputs is not a full conformance gate. No historical timing is used as a denominator.
