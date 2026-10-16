# Native borrowed-call optimization loop

[Design](../../../../design/phase99/native-scalar-and-borrowing.md) ·
[Report](../../../../implementation/phase99/README.md) ·
[Compiler contract](../../../../docs/self_hosted/NATIVE_PHASE99.md)

Run from the repository root, with the recorded Phase98/99 assets restored.
Methods refuse changed inputs and existing output paths. Root owns a serial
target queue; offline source review and report preparation can run concurrently.
Acquiring a testing API is distinct from building a native compiler image.

## Small controls and mechanism probes

The final combined recipe is `borrowed-calls-source04/changes.json` under the
Phase99 build root. Reproduce its small checks with fresh paths:

```sh
python3 -B selfhost/tools/performance/phase99/borrowed-call-tests/qualify-static.py \
  --recipe selfhost/build/phase99/borrowed-calls-source04/changes.json \
  --controls selfhost/build/phase99/borrowed-controls06.json \
  --out selfhost/build/phase99/replay-small-FRESH

python3 -B selfhost/tools/performance/phase99/borrowed-call-tests/micro-static.py \
  --qualification selfhost/build/phase99/replay-small-FRESH/report.json \
  --out selfhost/build/phase99/replay-static-FRESH

python3 -B selfhost/tools/performance/phase99/borrowed-call-tests/micro-long.py \
  --qualification selfhost/build/phase99/replay-small-FRESH/report.json \
  --out selfhost/build/phase99/replay-dynamic-FRESH
```

The small gate has 22 finite predicates and 13 complete native executions.
Each micro has four balanced pairs, original runtime inputs, complete result
and surviving-string output, and pinned single-worker execution. Do not substitute
short guard-wall runs for the longer confirmation or infer a compiler speedup
from these synthetic programs. Scalar-width trials in `scalars/` were rejected;
their passing controls and unchanged failures remain part of the evidence.

Two source04 proof packages are under `borrowed-calls/static-laws01/` and
`scalar-controls/borrowed-args-laws02/`. Each manifest identifies the exact
production helper, positive laws and three admitted helper mutations. Use
`check-laws.py` for a fresh independent-kernel check of a positive law file.
The [law assessment](../../../../implementation/phase99/law-usefulness.md)
explains what these statements constrain and what native properties they omit.

## Native integration and publication

`qualification/prepare.py` prepares individually reviewable build/request
commands. The completed source04 plan is
`selfhost/build/phase99/static-qualification-plan01/commands.json`.
Its methods are frozen once a run binds them: add a new version for a changed
method, never repair historical evidence in place.

Use six-source screens first, then same-source full-self requests and balanced
B1/B2 comparisons. `borrowed-calls/inspect-static-self-c.py` checks actual own C,
including combined root guards, borrowed calls, owning fallbacks and unchanged
runtime functions. B1/B2 full C agreement is a consistency check, not a proof.

Release gates live outside the qualification directory in `release/` and reuse
frozen Phase98 methods. They include source-bound backend controls, final-image
programs, native conformance, the original 45 programs, public CLI behavior and
restorable assets. The [release handoff](../../../../implementation/phase99/static-release-readiness.md)
contains the order and promotion conditions. Exact historical C supports runtime
evidence continuity; changed products require new execution measurements.

After all writers finish, `account.py` records actual guard occupancy,
`index.py` indexes successful and failed receipts, and `evidence.py` seals and
verifies the deduplicated archive. The evidence capsule and public compiler
capsule have different purposes. None of these tools posts a PR comment.
