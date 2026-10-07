# P61-001 — Reuse complete checked frontend state

Registered 2026-10-07 before Phase61 outcomes. Owner: root-assigned frontend
investigator; root builds/runs, independent checker/provenance review required.
Status: correctness unchecked; measurement not run; decision investigate.
User authorizes major compiler-speed changes implemented in Bend. This proposal
is investigator-selected; it is not permission to omit checking without proof.

**Hypothesis:** Extending a verified immutable Base checking state can remove
repeated declaration checking/setup in ordinary first and later requests while
retaining the full-check result. Phase60 check/completion is largest on 22/23;
611–726 ms includes user work and is not a measured Base-only saving.

**Invariant:** The reusable state includes declaration visibility/order, checked
bodies/output, specialization memo and active-instance rules, fresh-ID/name state,
source ranges/origins and diagnostics. Binding includes exact API/source/runtime/
Base/options and seed provenance. Source-only `validated`/cache bytes are not this
state. Source-dependent fresh-ID maxima may change generated instance identities;
prove rebasing/reservation equivalence rather than copying a numeric counter.

**Cheapest disproof:** Compare full checking with state extension on one imported
Base positive and one rejected source, then changed Base/API/cache, duplicate or
law fill, dependent instance, callback/erasure and reordered declaration probes.
Compare accepted/completed books, diagnostics/first error and full emitted bytes,
not just verdict success. Reject contamination between requests or after failure.
Stop if the state needed for correctness erases the measured benefit.

**Prior work:** [Phase60 exact frontend audit](../../implementation/phase60/common-frontend.md)
traces `driver/api.bend::check_program_diagnostic → dg_check_world` and the unused
validated prefix. Phase5 persistent inspectors reuse decoded source cache only;
that memo is not a checked-state resume proof. TS also rechecks Base, so this is
not already an explanation of the relative gap. [Population evidence](../../implementation/phase60/measurements.md).

Freeze candidate/parent identities before the checked build. Root runs focused
semantic/refusal/cache-state gates first, then the registered fast screen and
held-out sources. Broad23 requests, source/B2/fixed-point and applicable legacy/
native/release gates follow only a selected candidate. First-request and repeated
windows remain separate. Record outcomes in implementation/phase61, not by
rewriting this pre-outcome plan. No source/target/raw write is part of registration.
