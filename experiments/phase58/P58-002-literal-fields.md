# P58-002 — Use ordinary literal keys while preserving special-key semantics

- Owner / independent reviewer: field owner; independent phase44_review.
- Evidence cutoff: selected `checked-last01`; checked build and 14 B1 integration jobs pass, final bootstrap/B2 and measurement pending.
- Objective: reduce compiler allocation/code-generation cost while retaining source semantics, direct ABI and stack safety.
- Correctness: Genuine checked-source acquisition and fields-controls03 pass own values/prototypes, key order, once-only effects, reentry, aliases and exact AST activation at all three emission routes.
- Measurement: An independent fixed-source saved-image confirmation supports reduced lexer request latency. It is an unchecked syntax derivative; it does not establish fewer allocated bytes, general program speed or final selected-image performance.
- Decision: supersede the all-literal constructor rule with last-live-field computed policy; retain preceding literal keys and literal host-clone keys. Final promotion pending.

This record is **retrospectively indexed**. The linked designs and source plans existed and were committed before their target runs; this file was written afterwards. It is not a preregistered experiment artifact. Canonical results and identities remain in the [implementation report](../../implementation/phase58/literal-fields.md) and [Phase58 status](../../implementation/phase58/README.md).

## Claim and cheapest disproof

**Hypothesis:** Ordinary key placement has a general compiler/program tradeoff. Keep preceding live constructor fields literal and the last live field computed; exact __proto__ is always computed, and ordinary host-clone fields stay literal. This supersedes the original all-literal constructor hypothesis without discarding its evidence.

**Invariant:** Only field syntax changes. Exact __proto__ remains computed to preserve own data-property/prototype behavior. Field order, values, ordered prefixes, erased fields, getter accesses and host marshalling remain unchanged.

**Falsification / stop condition:** Any own-key, prototype, descriptor, alias, getter/error trace or partial-application difference rejects the change; a syntax-only derivative cannot qualify maintained source.

## Controlled setup

The [design](../../design/phase58/compiler-allocation-and-code-generation.md) and [preserved tool/command recipe](../../selfhost/tools/performance/phase58/fields/README-v3.md) bind source overlays, checked attempts, fixtures, runtime/Base/driver, pinned TypeScript and Node. Starting release is Phase56 string01; upstream is `018751270e800bc222a93dad7f257083ee53a5f7`. Diagnostic derivatives and genuine source images are separate lanes. Root runs resource-guarded jobs serially; first/import, later request, instrumented phase and generated-program times are separate boundaries. Exact commands and limits are retained in those recipes and raw process receipts rather than reconstructed here.

## Gates and observations

The [focused evidence](../../selfhost/build/phase58/fields-controls03/report.json) and [related attempt](../../selfhost/build/phase58/fields-latency-confirm01/report.json) retain actual pass/refusal status and input joins. The canonical report lists completed observations, failed predecessors and limitations; counts are not recopied into a competing table here. Historical [shared01 checked validation](../../selfhost/build/phase58/checked-shared01/validation-001/report.json) is a separate completed gate. Its completed gates do not qualify last01 by inheritance. The [last01 checked validation](../../selfhost/build/phase58/checked-last01/validation-001/report.json) and completed 14-job B1 integration are current; final last01 bootstrap/B2 and measurements are pending.

## Independent audit

Independent source/controller review challenged the invariant and its negative boundaries. Read the canonical report for corrections and exact reviewed producer identities; review clearance is not a target-execution result or a universal proof.

## Decision and next discriminating test

Keep the revised last-live-key policy in selected last01 pending its final gates. Final combined request/allocation comparison must distinguish source-image effects from the saved syntax ablation.

## Preservation

The six-change shared01 predecessor is checkpointed at `67be31f`; the [last-field selection](../../selfhost/build/phase58/last-source-selection.json) records the subsequent general source policy. Tracked isolated patches, fixtures, recipes and reports retain regeneration prerequisites; raw artifacts under `selfhost/build/phase58` remain local evidence, not automatically durable merely because a hash exists. The [evidence inventory](../../implementation/phase58/evidence/) and linked reports identify actual preserved manifests and failures. No historical receipt, ledger or steering entry is rewritten by this indexing step.

## Superseding last-field selection

The [source policy](../../selfhost/tools/performance/phase58/fields/last-source01/README.md) and [selection receipt](../../selfhost/build/phase58/last-source-selection.json) retain the general final-live-field rule, including trailing erased telescope fields. There is no field-count or program-name selector. Host marshalling remains literal except __proto__.

Whole computed rollback restores the three regressing program points but substantially hurts compiler requests. The [last-key saved diagnostic](../../selfhost/tools/performance/phase58/fields/last-key-v1.md) restores those points near their earlier baseline with a smaller 13–17% request-cost tradeoff versus all-literal. The [program comparison](../../selfhost/build/phase58/last-key-program-analysis01/report.json) and [compiler analysis](../../selfhost/build/phase58/fields-last-latency-analysis01/) remain diagnostic evidence; no final checked-source performance is inferred. The width grid is held/unexecuted and establishes no mechanism or cutoff.

New genuine [controls-v5 execution](../../selfhost/build/phase58/last-fields-controls01/report.json) retains all 17 semantic groups per role and checks each actual last emitted field. The [independent supplement](../../selfhost/build/phase58/last-live-controls01/report.json) covers zero/single/all-erased constructors, trailing erased fields, last-position __proto__, and final-field effects/errors/partial calls. Its first invalid computed-match fixture is preserved; v2 uses a named scrutinee. Existing consumed controllers/receipts and earlier measurements are unchanged.

Checked-last01 passes its checked build and all 14 B1 integration jobs. Its bootstrap/B2, final compiler/program measurements, release and archive remain pending at this cutoff.
