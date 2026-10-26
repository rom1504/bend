# Phase144 guarded-work cost snapshot

As of 2026-10-26T14:32:14.873367+00:00: 199 closed receipts, 0 pending/unclosed, 0 unreadable.
Summed guarded wall: 162.77 min. Interval union: 162.77 min.
Unexpected failed-command wall: 15.34 min; expected negative checks: 0.310 s.

| Category | Closed/pending | Sum seconds | Union seconds | Failed seconds |
| --- | ---: | ---: | ---: | ---: |
| profile | 19/0 | 1340.09 | 1340.09 | 9.19 |
| acquisition | 81/0 | 3868.40 | 3868.40 | 472.58 |
| checks | 27/0 | 288.76 | 288.76 | 0.86 |
| measurement | 49/0 | 2364.26 | 2364.26 | 415.20 |
| nativeQualification | 12/0 | 860.53 | 860.53 | 22.57 |
| unknown | 11/0 | 1044.12 | 1044.12 | 0.00 |

Category sums include inclusive multi-action guards. Category unions may overlap and must not be added.

A pending receipt has unknown final duration; it is excluded from closed totals, never charged zero.
Guard wall includes supervised preparation, target work and validation. Its sum is not CPU compute or agent quota.
Time outside the guard union is unobserved by these receipts. It is not a measurement of agent reasoning, idle time or quota.
RSS-limit termination is recorded separately; it does not establish a kernel OOM.
