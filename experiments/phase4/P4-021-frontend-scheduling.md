# P4-021: Schedule persistent frontend validation across four cores

- Owner: direct-calls agent; resource coordination and final review: root.
- Recorded before launch, 2026-09-22.
- Correctness: focused parity and all four full inventories passed exact comparison; both full replay-history audits passed.
- Measurement: idle serial 1,036.017 seconds; four-core brackets 299.376 / 297.699 seconds. Loaded-host serial retained separately.
- Decision: **Use existing four-worker scheduling** for the full frontend gate when four cores are available; no compiler/source change.

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
report. The first serial run finished at 18:26:50.982 UTC: 1,920 pass, 459 observed,
377 fail, exactly matching the completed B1 reference. All 44 worker lifetimes
closed with zero worker failures/timeouts; input hashes remained unchanged.
These counts preserve existing conformance failures.

The first serial run overlapped independent compiler work on the other three
cores. The idle serial bracket was 9.04% faster and is the primary reference.
The two four-core runs give 3.47× throughput / 71.18% less wall using increased
CPU resources. Both preserve all known failures; no conformance pass is implied.
See the [completed report](../../implementation/phase4/frontend-scheduling.md)
and its durable archive for all raw observations, worker histories and hashes.
