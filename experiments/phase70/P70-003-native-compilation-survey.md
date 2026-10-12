# P70-003: identify avoidable C compilation work

Registered before new profiling. Domain: checked B1 and actual self-emitted B2
native compilation requests, distinct from Clang and generated-program speed.
Baseline: Phase69 typed10; old three-source request means 3.231×/2.183× upstream.

Collect stage timings and V8 CPU/source-owner profiles using pinned existing
controllers in fresh Phase70 paths. Keep exact generated C checks outside timed
requests, prepared Base and imports separate, and unattributed samples visible.
Profile unchanged baseline first; profile a selected observer compiler separately
if it changes the relevant cost. No all-stage ratio from mixed images.

Hypothesis: repeated native planning/type/layout or text-construction work offers
a general compilation improvement without changing program output. This is a
survey hypothesis, not an assumed bottleneck. Register concrete edits separately
after attribution and verify with paired controlled B1/B2 requests.

Status: four exact-output baseline profiles complete; native planning/emission
dominates. See [the baseline report](../../implementation/phase70/compilation-baseline.md).
P70-004/005's combined checked B1 screen is complete; genuine B2 comparison remains
an integration gate. No compiled-program speed follows from these request clocks.
