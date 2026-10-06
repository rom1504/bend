# P58-006 — Share one private mutual-tail dispatcher per component

- Owner / independent reviewer: dispatch owner; independent phase44_review.
- Evidence cutoff: selected `checked-shared01`, before final broad qualification and installation.
- Objective: reduce compiler allocation/code-generation cost while retaining source semantics, direct ABI and stack safety.
- Correctness: Fresh shared choice and supplemental controllers pass actual shared AST shape, ordinary/program oracles, callbacks, replay, captures and terminal closure tails. Genuine shared01 full B2 emission passes. Cross-realm AST and sandbox child-launch failures remain preserved.
- Measurement: Exact saved-image census establishes code-size reduction. Its one-pair load observation improves while the later request is flat; genuine source stage durations are diagnostic, not a controlled throughput ratio.
- Decision: retain in integration candidate; release promotion pending.

This record is **retrospectively indexed**. The linked designs and source plans existed and were committed before their target runs; this file was written afterwards. It is not a preregistered experiment artifact. Canonical results and identities remain in the [implementation report](../../implementation/phase58/shared-scc.md) and [Phase58 status](../../implementation/phase58/README.md).

## Claim and cheapest disproof

**Hypothesis:** Printing one mutual-tail switch worker per component instead of per named entry removes replicated code while retaining each public entry.

**Invariant:** Entries retain maximum-width formals and fixed PCs; the worker retains case order, local bindings, parallel stores and loop transfers. Each invocation owns state, including nested calls/reentry. Leader metadata retains every real component member; synthetic names cannot collide with source names. Singleton/native/Foreign paths remain unchanged.

**Falsification / stop condition:** Wrong entry ABI/PC, partial-call demand, reentry state, capture/throw identity, tail stack behavior or lost dependency rejects the change. Smaller output alone is insufficient to assert faster execution.

## Controlled setup

The [design](../../design/phase58/shared-recursive-dispatch.md) and [preserved tool/command recipe](../../selfhost/tools/performance/phase58/choices/shared-scc01/controls.md) bind source overlays, checked attempts, fixtures, runtime/Base/driver, pinned TypeScript and Node. Starting release is Phase56 string01; upstream is `018751270e800bc222a93dad7f257083ee53a5f7`. Diagnostic derivatives and genuine source images are separate lanes. Root runs resource-guarded jobs serially; first/import, later request, instrumented phase and generated-program times are separate boundaries. Exact commands and limits are retained in those recipes and raw process receipts rather than reconstructed here.

## Gates and observations

The [focused evidence](../../selfhost/build/phase58/shared-scc-controls02/report.json) and [related attempt](../../selfhost/build/phase58/final-shared01/bootstrap/full/report.json) retain actual pass/refusal status and input joins. The canonical report lists completed observations, failed predecessors and limitations; counts are not recopied into a competing table here. Selected [shared01 checked validation](../../selfhost/build/phase58/checked-shared01/validation-001/report.json) is a separate completed gate. Its ongoing broad qualification is not credited before completion.

## Independent audit

Independent source/controller review challenged the invariant and its negative boundaries. Read the canonical report for corrections and exact reviewed producer identities; review clearance is not a target-execution result or a universal proof.

## Decision and next discriminating test

Keep in selected shared01, installation pending. Complete its own broad/B2, repeated request/allocation and full program gates before promotion.

## Preservation

Source changes are checkpointed at `67be31f`. Tracked isolated patches, fixtures, recipes and reports retain regeneration prerequisites; raw artifacts under `selfhost/build/phase58` remain local evidence, not automatically durable merely because a hash exists. The [evidence inventory](../../implementation/phase58/evidence/) and linked reports identify actual preserved manifests and failures. No historical receipt, ledger or steering entry is rewritten by this indexing step.
