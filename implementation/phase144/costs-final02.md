# Phase144 guarded-work cost snapshot

As of 2026-10-26T14:34:19.576417+00:00: 199 closed receipts, 0 pending/unclosed, 0 unreadable.
Summed guarded wall: 162.77 min. Interval union: 162.77 min.
Unexpected failed-command wall: 15.34 min; expected negative checks: 0.310 s.

| Category | Closed/pending | Sum seconds | Union seconds | Failed seconds |
| --- | ---: | ---: | ---: | ---: |
| profile | 20/0 | 1340.25 | 1340.25 | 9.19 |
| acquisition | 82/0 | 3887.11 | 3887.11 | 472.58 |
| checks | 30/0 | 294.38 | 294.38 | 0.86 |
| measurement | 53/0 | 2889.73 | 2889.73 | 415.20 |
| nativeQualification | 14/0 | 1354.68 | 1354.68 | 22.57 |
| unknown | 0/0 | 0.00 | 0.00 | 0.00 |

Category sums include inclusive multi-action guards. Category unions may overlap and must not be added.

A pending receipt has unknown final duration; it is excluded from closed totals, never charged zero.
Guard wall includes supervised preparation, target work and validation. Its sum is not CPU compute or agent quota.
Time outside the guard union is unobserved by these receipts. It is not a measurement of agent reasoning, idle time or quota.
RSS-limit termination is recorded separately; it does not establish a kernel OOM.
