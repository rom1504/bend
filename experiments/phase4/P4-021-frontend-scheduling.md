# P4-021: Schedule persistent frontend validation across four cores

- Owner: direct-calls agent; resource coordination and final review: root.
- Recorded before launch, 2026-09-22.
- Correctness: pending focused one/four-worker parity and full inventories.
- Measurement: pending new serial and four-core workflow observations.
- Decision: **Investigate**, without compiler/source changes.

## Claim and cheapest disproof

The existing persistent harness should reduce full frontend validation wall time
when four independent workers receive four physical cores. Disprove cheaply with
a mixed-fixture parity smoke that exercises recycling and retained failures.
Any changed observation, history/provenance failure, concurrent cache corruption
or missing probe blocks the full measurement.

The [design](../../design/phase4/frontend_scheduling.md) fixes identities,
cache policy, resource limits, ordering comparison and timing scope. Use the
final checked B1 and the completed `frontend-combined` inventory as the exact
behavior reference. Record fresh worker histories rather than inferring parity
from earlier isolated calls. Full runs have 1,378 fixtures and 2,756 parse/check
observations; known upstream differences remain failures.

## Resource sequence and decision gate

The focused smoke may share CPU 0 among its workers and makes no speed claim.
The new serial sweep owns CPU 0 after root releases it. The four-core sweep
requires a separate explicit all-clear after active frontend/full-source/native
experiments finish. Record actual masks and other workload overlap.

Only exact, complete observation inventories permit a throughput comparison.
The ratio is a validation-scheduling benefit from increased CPU resources; it is
not a per-core compiler speedup. Stop if a worker/session or cache invariant
fails, preserving evidence before attempting a correction.

## Evidence

Preparation, focused gates and timed runs will be recorded under
`selfhost/build/phase4/frontend-scheduling/` and archived in a dedicated Phase 4
report. This record remains pending until those observations exist.
