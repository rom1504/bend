# Phase144 guarded-work cost snapshot

As of 2026-10-26T12:14:48.009511+00:00: 137 closed receipts, 0 pending/unclosed, 0 unreadable.
Summed guarded wall: 80.37 min. Interval union: 80.37 min.
Unexpected failed-command wall: 8.30 min; expected negative checks: 0.310 s.

| Category | Closed/pending | Sum seconds | Union seconds | Failed seconds |
| --- | ---: | ---: | ---: | ---: |
| profile | 14/0 | 1037.15 | 1037.15 | 9.19 |
| acquisition | 62/0 | 2203.82 | 2203.82 | 472.58 |
| checks | 22/0 | 252.16 | 252.16 | 0.82 |
| measurement | 38/0 | 1308.47 | 1308.47 | 15.12 |
| nativeQualification | 1/0 | 20.84 | 20.84 | 0.00 |
| unknown | 0/0 | 0.00 | 0.00 | 0.00 |

Category sums include inclusive multi-action guards. Category unions may overlap and must not be added.

A pending receipt has unknown final duration; it is excluded from closed totals, never charged zero.
Guard wall includes supervised preparation, target work and validation. Its sum is not CPU compute or agent quota.
Time outside the guard union is unobserved by these receipts. It is not a measurement of agent reasoning, idle time or quota.
RSS-limit termination is recorded separately; it does not establish a kernel OOM.
