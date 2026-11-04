# Phase159 — explain fast bendc self-emission

Start at53e2371, on selfhost/bootstrap. Investigation only unless a small,
independently checked transformation has unusually strong evidence. Qualified
Phase152, maintained compiler and upstream language stay untouched.

Question: does bendc execute equivalent compiler work more cheaply, or perform
less internal work? Its4.50s historical self-emission is not comparable to our
full self-build: sources, checking, generated target and machine construction
all differ. Phase157's identical repeated compiler workload already rules out
a universal GC/direct-call advantage.

1. Reuse the general ELF profiler on the authenticated historical seed. Record
   clean and sampled unchecked emission, checked emission and checker-only
   observations. Preserve exact public-seed output and independent expected
   foreign/unsafe checking report. No full compiler image rebuild.
2. Reuse the exact Phase157 common workload and machine products. Restore only
   necessary authenticated artifacts. Profile one/four/sixteen batches where
   useful to separate fixed input preparation from repeated owner computations.
   Keep clean timings and diagnostic counters/samples distinct.
3. Audit actual pipeline transformations and source-to-machine work expansion.
   Count source/reachable/emitted definitions and selected representations; C
   text bytes and QBE text bytes are not interchangeable work units. Compare
   actual same-input boundaries, not differing self-sources.
4. Use observations to select one complete computation for a decisive follow-up.
   If needed, build a private diagnostic seed with stage/event counters; preserve
   exact output, generated source/method identity and an uninstrumented baseline.
   Do not claim a source optimization from a diagnostic C edit.

Initial decision budget about45–60min including analysis. Two bounded agents
own source/evidence audits; root owns one CPU3 target lane. Use explicit guarded
2GiB RSS /16GiB free-memory floor /5GiB disk reserve and whole-job disk budgets.
No hardware counters assumed; unmeasured inline/inclusive work remains unknown.
Retain negative results and close/archive all jobs. Commit and push the report,
replay methods and exact evidence. No PR comments or production promotion.

Outcome: profiles justified a small private runtime ablation beyond observation.
The captured computation's dominant GC reuse-search loop concealed a5.35× gain;
this revises the initial interpretation of Phase157, not its original measured
result. See implementation/phase159/README.md for exact scope and limits.
