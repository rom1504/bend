# Phase46 four-way backend diagnostic

This is a bounded investigation, not a replacement for the maintained
[Phase45 fast iteration benchmark](../phase45/README.md).
See the [design](../../../../design/phase46/backend-comparison.md),
[report](../../../../implementation/phase46/README.md),
[protocol](../../../../implementation/phase46/protocol.md) and
[raw capsule](../../../../implementation/phase46/evidence/capsule.json).
The production compiler was unchanged.

## Inputs and commands

`cases.json` binds six maintained source hashes and independent base results.
The pure wrappers provide bounded mains; never execute the original benchmark
mains, several of which request huge runs. `*-batch.bend` adds a shared16-input
cycle and checked observer. `make-batch.py` records its derivation and refuses to
replace existing outputs. All programs use the exact same source in all four roles.

Recorded host: Linux x86_64, CPU3, Node24.18.0 and Lean-distributed Clang22.1.4.
The scripts record the absolute installed Node/Clang paths; a different host must
select its own paths and collect fresh results rather than combine timings.
`job.py`, `pilot.py`, `measure.py`, `cold.py` and `diagnose.py` use the maintained
exclusive ExecutionGuard, serial process trees and explicit memory/time limits.

Run from the repository root, with fresh output directories. The commands below
reproduce the final input layout on a clean clone with the selected compiler
installed and the pinned upstream checkout at `.bootstrap/upstream-phase23`:

```sh
python3 selfhost/tools/performance/phase46/pilot.py \
  --out selfhost/build/phase46/pilot02 --cases numeric,closures
python3 selfhost/tools/performance/phase46/pilot.py \
  --out selfhost/build/phase46/expansion01 --cases tree,array,map,lexer
python3 selfhost/tools/performance/phase46/oracle.py \
  --out selfhost/build/phase46/oracles.json
python3 selfhost/tools/performance/phase46/pilot.py \
  --out selfhost/build/phase46/batch03 --batch \
  --cases numeric,closures,tree,array,map,lexer
python3 selfhost/tools/performance/phase46/measure.py \
  --out selfhost/build/phase46/calibration01 \
  --acquired selfhost/build/phase46/batch03
```

Do not launch commands concurrently. Source/API/runtime/Base changes invalidate
old acquisitions and oracles. Current scripts verify installed release identity,
upstream pin, fixture hashes, wrapper and output identities. Historical corrected
attempts in the capsule retain their earlier, narrower checks.

Calibration writes a plan; inspect all clock intervals and predicted bounds.
Zero milliseconds is an unresolved measurement, not free execution. The retained
`timing-plan01.json` records the exact final counts, increased200ms target and
array exception used in this report. Restore that small JSON from the capsule to
repeat its workload, or freeze a separately named plan after fresh calibration.
Then run:

```sh
python3 selfhost/tools/performance/phase46/measure.py \
  --out selfhost/build/phase46/timing01 \
  --acquired selfhost/build/phase46/batch03 \
  --plan selfhost/build/phase46/timing-plan01.json --rounds 3
python3 selfhost/tools/performance/phase46/cold.py \
  --out selfhost/build/phase46/cold01
python3 selfhost/tools/performance/phase46/diagnose.py \
  --out selfhost/build/phase46/diagnostics01
```

These outputs already exist in the original workspace and restoration; choose
fresh names for a replay. The diagnostic/cold scripts refer explicitly to the
recorded acquisition/plan layout. They must not consume mixed snapshots.
Profiles/counters run after clean timing. `native-counts.py` creates checked
saved-C derivatives with CPU-only counters; their timings are invalid for speed
comparisons. The retained perf probe failed because its executable was missing.

`summarize.py` derives the published tables from these named receipts and asserts
complete correctness/timing coverage. Its initial preservation/accounting inputs
include the historical attempts; a clean replay will have a different job count.
The summary never replaces failed records or substitutes incomplete samples.

## Boundaries and known result

The four batch stdout lines are base result, warm digest, measured digest and
integer milliseconds. The same repetitions/warmups apply to every role. Clock
stops after printing the measured digest. Cold turnaround includes process launch,
one pure workload and readback; it is not isolated startup latency.

The last two CLI arguments are used because the retained native runtime omits the
program name from IO.args; this known mismatch remains unfixed. C runtimes differ
between the products. Neither the wrapper workaround nor matching batch outputs
establish broad native conformance. The new call context and input cycle also
prevent comparing these ratios directly with the original JS-library score.

All72 timing samples passed. Our C roughly ties our JS on closures and is1.28–5.03×
slower on the other cases. Upstream C is2.19–19.73× faster than upstream JS here.
The preserved allocation/dispatch evidence points to high-level lowering work,
so the report recommends continuing JS optimization and deferring a target switch.
