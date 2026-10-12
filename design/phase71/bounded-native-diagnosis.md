# Phase71: bounded native diagnosis, one agent

Start: 2026-10-12 03:26 UTC, release b18a183; checked B1 386ae358…,
genuine B2 d069204f…, upstream0592662. User explicitly requests no agents.
Decision checkpoint within45–60minutes; no production optimizer or release
promotion in this cycle. Aim to identify a general mechanism with enough
measured value to justify a later implementation, not accumulate passes.

1. Reuse qualified Phase70 C/binaries and profiles. Inspect Array-map and at
   least one other existing workload against upstream. Record concrete work,
   ownership and loop-state differences, distinguishing sites from dynamic cost.
2. Try at most two documented, exact-match interventions on saved generated C.
   Preserve originals, patch/source/tool hashes, independent outputs, balanced
   timings and failures. These are diagnostic programs, not a compiler result.
3. Add a small balanced fork-join workload, compare actual final B1 output with
   pinned upstream at1/2/4physicalcores. Widen affinity explicitly to0–3; this
   supersedes the historical CPU3-only rule for scaling measurements. No SMT
   substitution. One guarded target tree,2GiBRSS/4GiBavailable, serial builds.
   Report1→p scaling separately from candidate/upstream at matching p. GPU
   remains untested. Inspect fork/join and allocation/cleanup coverage.
4. Keep compiler cost separate: use existing qualified profiles and a short
   final-image request baseline; no new compiler speed claim without a changed
   compiler and paired requests. Include Clang cost of diagnostic code changes.
5. Use existing usage.py before/after; an advisory20000output-token budget and
   about5quota-points warning bound this investigation. Tokens are not quota;
   unavailable or incomparable telemetry is explicit. No repeated polling turns.

Promotion requires a plausible general rule, measured benefit beyond one tuned
case, an ownership/effect argument, bounded implementation size and early B1/B2
cost checks. A negative experiment or scaling diagnosis is a valid stopping
result. Commit one concise report and reusable small methods; leave installed
compiler and earlier frozen evidence untouched. No PR comments.
