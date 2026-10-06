# P58-003 — Carry exact scalar provenance through residual Word patterns

- Owner / independent reviewer: scalar owner; independent phase44_review.
- Evidence cutoff: installed `checked-last01`; final B1/B2, measurements and release gates pass; archive closed and verified.
- Objective: reduce compiler allocation/code-generation cost while retaining source semantics, direct ABI and stack safety.
- Correctness: Three-image scalar-controls02 passes independent arithmetic, boundary values, mixed origins, alias/mutation/throw/partial controls and F32 fallback; AST and untimed activation counters establish the actual selected/refused routes.
- Measurement: Static module/helper-site reductions are observed. No isolated dynamic-allocation or runtime speed claim is inferred; refused rows may require an extra compiler rendering attempt.
- Decision: promote the selected qualified scope; installed and verified; archive closed and verified.

This record is **retrospectively indexed**. The linked designs and source plans existed and were committed before their target runs; this file was written afterwards. It is not a preregistered experiment artifact. Canonical results and identities remain in the [implementation report](../../implementation/phase58/scalar-residual.md) and [Phase58 status](../../implementation/phase58/README.md).

## Claim and cheapest disproof

**Hypothesis:** A checked native U32 row can reconstruct its scalar directly when residual Word fragments cover all 32 bit positions from one held scalar origin.

**Invariant:** Private residual metadata records origin and exact positions. Moved/mixed fragments, ordinary residual uses, escaping aliases/callback mutation and unproved shapes refuse the whole row rewrite. F32 rows and existing inverse paths retain their original lowering. The matcher holds its scalar once.

**Falsification / stop condition:** Wrong bit width, replacement-prefix/default-arm result, demand, capture sharing, callback mutation or F32 bits rejects the change. Fewer conversion sites alone cannot prove a speed gain.

## Controlled setup

The [design](../../design/phase58/compiler-allocation-and-code-generation.md) and [preserved tool/command recipe](../../selfhost/tools/performance/phase58/scalar/README.md) bind source overlays, checked attempts, fixtures, runtime/Base/driver, pinned TypeScript and Node. Starting release is Phase56 string01; upstream is `018751270e800bc222a93dad7f257083ee53a5f7`. Diagnostic derivatives and genuine source images are separate lanes. Root runs resource-guarded jobs serially; first/import, later request, instrumented phase and generated-program times are separate boundaries. Exact commands and limits are retained in those recipes and raw process receipts rather than reconstructed here.

## Gates and observations

The [focused evidence](../../selfhost/build/phase58/scalar-controls02/report.json) and [related attempt](../../selfhost/build/phase58/scalar-fixtures01/manifest.json) retain actual pass/refusal status and input joins. The canonical report lists completed observations, failed predecessors and limitations; counts are not recopied into a competing table here. Historical [shared01 checked validation](../../selfhost/build/phase58/checked-shared01/validation-001/report.json) is a separate completed gate. Its completed gates do not qualify last01 by inheritance. The [last01 checked validation](../../selfhost/build/phase58/checked-last01/validation-001/report.json), final B2 gates and measurements now pass in their own scope; installed release execution is complete/pass.

## Independent audit

Independent source/controller review challenged the invariant and its negative boundaries. Read the canonical report for corrections and exact reviewed producer identities; review clearance is not a target-execution result or a universal proof.

## Decision and next discriminating test

Keep in selected last01 after completed final qualification. Observe actual request allocation and generated-program comparisons before claiming benefit beyond eliminated syntax.

## Preservation

The six-change shared01 predecessor is checkpointed at `67be31f`; the [last-field selection](../../selfhost/build/phase58/last-source-selection.json) records the subsequent general source policy. Tracked isolated patches, fixtures, recipes and reports retain regeneration prerequisites; raw artifacts under `selfhost/build/phase58` remain local evidence, not automatically durable merely because a hash exists. The [evidence inventory](../../implementation/phase58/evidence/) and linked reports identify actual preserved manifests and failures. No historical receipt, ledger or steering entry is rewritten by this indexing step.

## Final selected closure

Checked-last01's final scoped qualification, B2 fixed point and fresh 23-source/45-point program campaign pass. The [final compiler measurements](../../implementation/phase58/final-measurements.md), [full45 aggregate](../../selfhost/build/phase58/final-performance-last01/aggregate/report.json) and [release execution](../../selfhost/build/phase58/final-last01/release-execution/report.json) bind their own actual selected inputs. All five release steps pass, including legacy42/default24 and integrity before/after; last01 is installed. These combined-source outcomes do not isolate this mechanism's individual contribution. Earlier negative/null diagnostics remain unchanged. All raw writers are closed and every archive member is verified; the Phase58 publication index binds the final evidence.
