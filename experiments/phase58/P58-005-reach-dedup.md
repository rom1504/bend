# P58-005 — Deduplicate validated edges within each emitted definition

- Owner / independent reviewer: reach owner; independent phase44_review.
- Evidence cutoff: selected `checked-shared01`, before final broad qualification and installation.
- Objective: reduce compiler allocation/code-generation cost while retaining source semantics, direct ABI and stack safety.
- Correctness: reach-controls01 passes scanner and graph boundary cases in both genuine images. Fresh reach01 full emission and its own ordinary source check pass; choice01 original edge-budget refusal stays preserved.
- Measurement: The private diagnostic and stage times have instrumentation overhead. The genuine reach B2 lexer pilot is a single pair over changed source, not a repeated or isolated speed estimate.
- Decision: retain in integration candidate; release promotion pending.

This record is **retrospectively indexed**. The linked designs and source plans existed and were committed before their target runs; this file was written afterwards. It is not a preregistered experiment artifact. Canonical results and identities remain in the [implementation report](../../implementation/phase58/validation.md#completed-choice-reach-and-shared-checkpoints) and [Phase58 status](../../implementation/phase58/README.md).

## Claim and cheapest disproof

**Hypothesis:** Repeated JD_REF occurrences within a rendered definition need only enqueue one edge to each target, avoiding exhaustion by duplicate work.

**Invariant:** Every metadata occurrence is still parsed and validated. Encounter order, supplied output, selected definition order and cross-definition edges are preserved. Character, definition and queue limits retain their constants; the queue now charges distinct per-definition edges, intentionally admitting some formerly refused graphs.

**Falsification / stop condition:** Invalid duplicate metadata accepted, changed root/definition order, missing name/cycle behavior or a budget bypass rejects the change. Raising limits or fake checked receipts is not this experiment.

## Controlled setup

The [design](../../design/phase58/reachability-deduplication.md) and [preserved tool/command recipe](../../selfhost/tools/performance/phase58/qualification/reach-controls.mjs) bind source overlays, checked attempts, fixtures, runtime/Base/driver, pinned TypeScript and Node. Starting release is Phase56 string01; upstream is `018751270e800bc222a93dad7f257083ee53a5f7`. Diagnostic derivatives and genuine source images are separate lanes. Root runs resource-guarded jobs serially; first/import, later request, instrumented phase and generated-program times are separate boundaries. Exact commands and limits are retained in those recipes and raw process receipts rather than reconstructed here.

## Gates and observations

The [focused evidence](../../selfhost/build/phase58/reach-controls01/report.json) and [related attempt](../../selfhost/build/phase58/final-reach01/bootstrap/full/report.json) retain actual pass/refusal status and input joins. The canonical report lists completed observations, failed predecessors and limitations; counts are not recopied into a competing table here. Selected [shared01 checked validation](../../selfhost/build/phase58/checked-shared01/validation-001/report.json) is a separate completed gate. Its ongoing broad qualification is not credited before completion.

## Independent audit

Independent source/controller review challenged the invariant and its negative boundaries. Read the canonical report for corrections and exact reviewed producer identities; review clearance is not a target-execution result or a universal proof.

## Decision and next discriminating test

Keep in selected shared01 pending final selected-image gates. Do not transfer the earlier reach image self-check to shared01 without a fresh run.

## Preservation

Source changes are checkpointed at `67be31f`. Tracked isolated patches, fixtures, recipes and reports retain regeneration prerequisites; raw artifacts under `selfhost/build/phase58` remain local evidence, not automatically durable merely because a hash exists. The [evidence inventory](../../implementation/phase58/evidence/) and linked reports identify actual preserved manifests and failures. No historical receipt, ledger or steering entry is rewritten by this indexing step.
