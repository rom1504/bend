# Phase65 time accounting

`account-time.py` is a data-only successor of the frozen Phase64 script.
`account-time.derivation.json` and `account-time.patch` pin its exact changes.
Closed `run.json`/`process.json` intervals are clipped to campaign start and an
explicit cutoff, then merged. Nested guards are never counted twice. Open
receipts have no invented finish, and receipts closing after cutoff stay listed
separately. The inherited elapsed, occupied union and uncovered totals are unchanged.

The script also reads and pins `implementation/phase65/evidence/interruption.json`.
Its root-declared 01:56–03:59 UTC interruption is approximate. A separate result
records the clipped approximate interval, actual closed-guard overlap within its
approximate boundaries, and elapsed/occupied/uncovered values outside it. Those
values are not precise active work, CPU utilization, waiting or agent effort.
The measured overall guard union remains intact even if it overlaps the note.

Run only after root's target-closure signal, supplying the actual UTC cutoff:

```sh
taskset -c 0 python3 -B selfhost/tools/performance/phase65/latency/account-time.py --cutoff ROOT_DECLARED_CUTOFF --out implementation/phase65/evidence/time-account-final.json
```

Preparation checked syntax and exact derivation; it did not invoke accounting,
scan current guard receipts or run targets. The final output must be a fresh path.
