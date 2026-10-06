# P58-002 — Use ordinary literal keys while preserving special-key semantics

- Owner / independent reviewer: field owner; independent phase44_review.
- Evidence cutoff: selected `checked-shared01`, before final broad qualification and installation.
- Objective: reduce compiler allocation/code-generation cost while retaining source semantics, direct ABI and stack safety.
- Correctness: Genuine checked-source acquisition and fields-controls03 pass own values/prototypes, key order, once-only effects, reentry, aliases and exact AST activation at all three emission routes.
- Measurement: An independent fixed-source saved-image confirmation supports reduced lexer request latency. It is an unchecked syntax derivative; it does not establish fewer allocated bytes, general program speed or final selected-image performance.
- Decision: retain in integration candidate; release promotion pending.

This record is **retrospectively indexed**. The linked designs and source plans existed and were committed before their target runs; this file was written afterwards. It is not a preregistered experiment artifact. Canonical results and identities remain in the [implementation report](../../implementation/phase58/literal-fields.md) and [Phase58 status](../../implementation/phase58/README.md).

## Claim and cheapest disproof

**Hypothesis:** Quoted ordinary record keys avoid avoidable computed-property work in emitted constructors, ordered fields and host clones.

**Invariant:** Only field syntax changes. Exact __proto__ remains computed to preserve own data-property/prototype behavior. Field order, values, ordered prefixes, erased fields, getter accesses and host marshalling remain unchanged.

**Falsification / stop condition:** Any own-key, prototype, descriptor, alias, getter/error trace or partial-application difference rejects the change; a syntax-only derivative cannot qualify maintained source.

## Controlled setup

The [design](../../design/phase58/compiler-allocation-and-code-generation.md) and [preserved tool/command recipe](../../selfhost/tools/performance/phase58/fields/README-v3.md) bind source overlays, checked attempts, fixtures, runtime/Base/driver, pinned TypeScript and Node. Starting release is Phase56 string01; upstream is `018751270e800bc222a93dad7f257083ee53a5f7`. Diagnostic derivatives and genuine source images are separate lanes. Root runs resource-guarded jobs serially; first/import, later request, instrumented phase and generated-program times are separate boundaries. Exact commands and limits are retained in those recipes and raw process receipts rather than reconstructed here.

## Gates and observations

The [focused evidence](../../selfhost/build/phase58/fields-controls03/report.json) and [related attempt](../../selfhost/build/phase58/fields-latency-confirm01/report.json) retain actual pass/refusal status and input joins. The canonical report lists completed observations, failed predecessors and limitations; counts are not recopied into a competing table here. Selected [shared01 checked validation](../../selfhost/build/phase58/checked-shared01/validation-001/report.json) is a separate completed gate. Its ongoing broad qualification is not credited before completion.

## Independent audit

Independent source/controller review challenged the invariant and its negative boundaries. Read the canonical report for corrections and exact reviewed producer identities; review clearance is not a target-execution result or a universal proof.

## Decision and next discriminating test

Keep in selected shared01 pending its final gates. Final combined request/allocation comparison must distinguish source-image effects from the saved syntax ablation.

## Preservation

Source changes are checkpointed at `67be31f`. Tracked isolated patches, fixtures, recipes and reports retain regeneration prerequisites; raw artifacts under `selfhost/build/phase58` remain local evidence, not automatically durable merely because a hash exists. The [evidence inventory](../../implementation/phase58/evidence/) and linked reports identify actual preserved manifests and failures. No historical receipt, ledger or steering entry is rewritten by this indexing step.
