# Phase165 — complete backend replay before another representation experiment

Source-only proposal at `b78a8c4`; no target runs or compiler changes. **Compare
our mature C and QBE backends on one authenticated checked request first.** This
isolates a complete responsibility with useful outputs; it is not another
helper benchmark, streaming proposal, or forecast from IR size.

**Measured gap.** [Phase162 operation metrics](../../implementation/phase162/operation-metrics.json)
record 2,950,339,368 logical allocations, of which **2,132,313,622 are outside
parse/check/report**. That residual includes Base preparation, annotation/erasure,
backend and output/cleanup; it is not an attributed backend count. Phase161's
[disjoint profile](../../implementation/phase161/profile-metrics.json) separates
generic production 11.588s, private production 26.782s, initial optimization
23.673s, registry 16.190s and output/teardown 40.208s. None supplies allocation
counts for those responsibilities. The existing frontend census cannot decide
whether semantic production, analysis state, or rendering causes the residual.

**Runnable seam and cheapest gate.** Adapt
[`phase164/tools/lower.mjs`](../phase164/tools/lower.mjs): prepare Base once with
`p86_prepare`, obtain `P86PlanReady{request,verdict}` with `p86_plan`, and feed
that *same complete* `NR_Request` to both routes:

* QBE: `p134e_plan`, then fully drain `p134e_begin`/`p134e_next`.
* C: [`nr_compile_prepared`](../../selfhost/src/back/native/request.bend:52)
  with authenticated `NE_Runtime`, reachable effects and the ordinary checked
  policy. Reuse `p86_compile`'s effect preparation in
  [`host/native-plan.bend:256`](../../selfhost/src/host/native-plan.bend:256);
  do not fabricate an empty effect implementation or admission certificate.

Use the existing checked extraction method
[`phase163/tools/prepare.py`](../phase163/tools/prepare.py), adding those C roots.
First replay the unchanged `coverage-map-churn-128` catalog source (3,659 bytes;
expected `3714872484\n`) and one retained compiler slice. Save complete outputs,
require the QBE oracle unchanged, then compile/execute both generated programs
against their existing expected outputs. The first hosted replay is a feasibility
screen, not a native speed claim. Stop on unsupported C forms or excessive output
cost; do not start full self-emission. For timing, select C/QBE in **one** private
C02-policy executable, with identical frontend/runtime/GC/compiler flags. Existing
`phase160/request-c02/program.c` lacks `nr_compile_prepared`, so that acquisition
is real additional work, not a ready executable. Include output consumption and
whole-child teardown; report checked-request time separately from total process.

**Count what has not been measured.** Extend the exact-function C hooks in
[`phase162/tools/instrument-v2.py`](../phase162/tools/instrument-v2.py), retaining
its allocation/word/refill/collection counters. Snapshot Base, completed
`NR_Request`, preparation, generic production, private production/admission,
optimization/verification, registry and completed output. Port Phase161's
[validated boundary proposal](../phase161/lowering-stage-proposal.json), checking
actual C call order rather than copying QBE FIDs. Count executed nonempty owner
rows in `p111_compile_defs`, actual flat/boxed candidate constructions,
`p113d_pass` candidate visits, `p113k_get/put`, `p111v_stmt`/`p147d_stmt` visits,
and emitted cursor pieces/characters. These are operation counts, not static
function counts or additive inclusive timers. Authenticate hooks and require
complete unchanged outputs before interpreting them.

**Discrimination and comparison limit.** A large C/QBE gap with shared frontend
would locate work in our QBE-specific lowering/optimization/verification/registry
contract. Similar totals would leave shared preparation, ownership analysis and
text lifecycle as hypotheses; stage counts must distinguish them. Mature C builds scheduler
segments plus private workers: it does **not** reproduce bendc's architecture.
Only after this cheap gate add pinned bendc `Gen.program`→`COut` on the identical
source/Base, retaining whole C and execution outcomes. Its current seed has a
different representation policy from C02; match executor policy before calling
that a fixed-executor comparison. Shared compaction, output streaming and retained
original verification are already implemented; Phase163–164 also show why simply
deleting generic bodies or useful optimization is not this experiment.
