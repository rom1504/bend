# P58-006 — Share one private mutual-tail dispatcher per component

- Owner / independent reviewer: dispatch owner; independent phase44_review.
- Evidence cutoff: installed `checked-last01`; final B1/B2, measurements and release gates pass; archive closed and verified.
- Objective: reduce compiler allocation/code-generation cost while retaining source semantics, direct ABI and stack safety.
- Correctness: Fresh shared choice and supplemental controllers pass actual shared AST shape, ordinary/program oracles, callbacks, replay, captures and terminal closure tails. Genuine shared01 full B2 emission passes. Cross-realm AST and sandbox child-launch failures remain preserved.
- Measurement: Exact saved-image census establishes code-size reduction. Its one-pair load observation improves while the later request is flat; genuine source stage durations are diagnostic, not a controlled throughput ratio.
- Decision: promote the selected qualified scope; installed and verified; archive closed and verified.

This record is **retrospectively indexed**. The linked designs and source plans existed and were committed before their target runs; this file was written afterwards. It is not a preregistered experiment artifact. Canonical results and identities remain in the [implementation report](../../implementation/phase58/shared-scc.md) and [Phase58 status](../../implementation/phase58/README.md).

## Claim and cheapest disproof

**Hypothesis:** Printing one mutual-tail switch worker per component instead of per named entry removes replicated code while retaining each public entry.

**Invariant:** Entries retain maximum-width formals and fixed PCs; the worker retains case order, local bindings, parallel stores and loop transfers. Each invocation owns state, including nested calls/reentry. Leader metadata retains every real component member; synthetic names cannot collide with source names. Singleton/native/Foreign paths remain unchanged.

**Falsification / stop condition:** Wrong entry ABI/PC, partial-call demand, reentry state, capture/throw identity, tail stack behavior or lost dependency rejects the change. Smaller output alone is insufficient to assert faster execution.

## Controlled setup

The [design](../../design/phase58/shared-recursive-dispatch.md) and [preserved tool/command recipe](../../selfhost/tools/performance/phase58/choices/shared-scc01/controls.md) bind source overlays, checked attempts, fixtures, runtime/Base/driver, pinned TypeScript and Node. Starting release is Phase56 string01; upstream is `018751270e800bc222a93dad7f257083ee53a5f7`. Diagnostic derivatives and genuine source images are separate lanes. Root runs resource-guarded jobs serially; first/import, later request, instrumented phase and generated-program times are separate boundaries. Exact commands and limits are retained in those recipes and raw process receipts rather than reconstructed here.

## Gates and observations

The [focused evidence](../../selfhost/build/phase58/shared-scc-controls02/report.json) and [related attempt](../../selfhost/build/phase58/final-shared01/bootstrap/full/report.json) retain actual pass/refusal status and input joins. The canonical report lists completed observations, failed predecessors and limitations; counts are not recopied into a competing table here. Historical [shared01 checked validation](../../selfhost/build/phase58/checked-shared01/validation-001/report.json) is a separate completed gate. Its completed gates do not qualify last01 by inheritance. The [last01 checked validation](../../selfhost/build/phase58/checked-last01/validation-001/report.json), final B2 gates and measurements now pass in their own scope; installed release execution is complete/pass.

## Independent audit

Independent source/controller review challenged the invariant and its negative boundaries. Read the canonical report for corrections and exact reviewed producer identities; review clearance is not a target-execution result or a universal proof.

## Decision and next discriminating test

Retained in installed last01 after its own broad/B2, request/allocation and full program gates. Individual dispatcher speed attribution remains limited to the preserved diagnostic; final combined gains do not isolate this mechanism.

## Preservation

The six-change shared01 predecessor is checkpointed at `67be31f`; the [last-field selection](../../selfhost/build/phase58/last-source-selection.json) records the subsequent general source policy. Tracked isolated patches, fixtures, recipes and reports retain regeneration prerequisites; raw artifacts under `selfhost/build/phase58` remain local evidence, not automatically durable merely because a hash exists. The [evidence inventory](../../implementation/phase58/evidence/) and linked reports identify actual preserved manifests and failures. No historical receipt, ledger or steering entry is rewritten by this indexing step.

## Final selected closure

Checked-last01's final scoped qualification, B2 fixed point and fresh 23-source/45-point program campaign pass. The [final compiler measurements](../../implementation/phase58/final-measurements.md), [full45 aggregate](../../selfhost/build/phase58/final-performance-last01/aggregate/report.json) and [release execution](../../selfhost/build/phase58/final-last01/release-execution/report.json) bind their own actual selected inputs. All five release steps pass, including legacy42/default24 and integrity before/after; last01 is installed. These combined-source outcomes do not isolate this mechanism's individual contribution. Earlier negative/null diagnostics remain unchanged. All raw writers are closed and every archive member is verified; the Phase58 publication index binds the final evidence.
