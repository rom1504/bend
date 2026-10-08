# Phase66 time account

Through the final release-target boundary, this phase used **3 hours 30 minutes
7 seconds** of elapsed wall time. Closed supervised targets occupied **1 hour
50 minutes 31.63 seconds (52.60%)**. The remaining **1 hour 39 minutes 35.37
seconds** is unclassified. It includes source/data tools, design, editing,
review, coordination and any unrecorded activity; it cannot honestly be called
either model work or waiting. This measures wall occupancy, not CPU utilization,
agent effort or the speed of one compiler request.

| Boundary, 2026-10-08 UTC | Minutes |
| --- | ---: |
| Campaign start 05:02:20 through release-target closure 08:32:27 | 210.12 |
| Union of closed supervised target intervals | 110.53 |
| Uncovered elapsed time, unclassified | 99.59 |

The root declared all compiler/runtime targets closed at that cutoff after the
five release actions and helper verification passed. **Archival, documentation,
final reporting, commit and push work after 08:32:27 are excluded.** This is a
closed accounting boundary, not a claim that all phase administration was
finished then.

| Measured target work | Minutes |
| --- | ---: |
| Frontend and full JavaScript conformance | 45.40 |
| Generated-program timing | 17.70 |
| Compilation timing and preparation | 16.29 |
| Semantic qualification and reference cases | 9.69 |
| Compiler images and self-hosting | 7.49 |
| Backend/platform controls and diagnostics | 6.75 |
| Generated-program acquisition and equality | 4.23 |
| Host and frontend feature controls | 2.12 |
| Release installation and verification | 0.85 |

These additive categories group the top-level experiment directories recorded
in the receipt. Frontend/full-JavaScript conformance includes the old and new
TypeScript reference, old Bend baseline, and both candidate campaigns. The
full JavaScript campaigns alone took 12.09 minutes for the TypeScript reference,
9.24 minutes for checked04, and 8.99 minutes for repaired checked07. Those are
qualification costs, not clean compilation benchmarks. The runtime row includes
the complete final 45-point campaign and the earlier reference screen.

The [final receipt](evidence/time-account-final.json) binds **2,173 closed guard
receipts** by SHA-256 and records every merged and uncovered interval. There
are no unreadable, open or cutoff-crossing receipts. All failed and rejected
attempts remain included. Its 20 nonzero/incomplete guard statuses include
corpus negative cases and shared upstream/platform failures; that count is not
a count of compiler defects.

The [accounting method](../../selfhost/tools/performance/phase66/latency/account-time.py)
reads only Phase66 guard metadata. It clips to the campaign start, unions
overlaps so nested/reused observations cannot count twice, and partitions that
union by the top-level raw experiment directory. Any mixed-directory overlap
would receive an explicit category; this campaign had none. The independent
[method review](evidence/time-account-method-review.json) checked overlapping,
adjacent, zero-duration and empty intervals. The
[final data review](evidence/time-account-final-review.json) independently checks
the final receipt against its inputs.

The [08:10:47 provisional observation](evidence/time-account-interim01.json)
remains immutable. It is superseded for final totals, not rewritten. No target
execution or raw experiment writes were performed to produce this account.
