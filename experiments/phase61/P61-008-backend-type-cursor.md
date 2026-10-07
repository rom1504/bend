# P61-008 — Private backend telescope specialization

Preregistered 2026-10-07 before root applies or executes the proposed source.
Owner products; independent reviewer phase44_review; root owns builds/targets.
Decision: test the narrow specialization first. This frozen plan is not an outcome.

**Hypothesis:** A direct-only beta-stable telescope adapter can fuse consecutive
constructor-parameter substitutions into one realization, reducing transient
KTerm/List reconstruction without changing emitted output or refusal behavior.
The initial `j_specialize`-only scope plausibly affects about **1–3%** of whole
requests; this is an expectation, not a measured result or guaranteed saving.
The larger Map substitution allocation share includes unrelated work and must
not be assigned wholesale to this helper.

**Invariant:** Reuse the existing `env_tele_safe` grammar and `env_subst_apply`.
Admit only multiple arguments; validate each raw replacement before recording
it. Pending bindings remain newest-first and realize in the established ordinary
substitution order. Flush at a non-`All` head, unsafe argument, or 64-binding
limit, then execute the unchanged original `j_specialize` for all remaining
arguments. Empty input returns the original raw telescope. Preserve `Absent`,
not `env_tele_fill`'s `Error`, including the original later fallback traversal.
Dependent fields, quantities, binder IDs, spans, annotations and beta behavior
remain exact. No public KTerm ABI, primitive/runtime or native backend changes.

**Intervention:** Isolated 34-line private helper, four direct constructor/match/
calls sites and one manifest entry. Patch SHA
`9d35f466afa670cb20f279cfad75eb5a1bb9f6ad70647b3f414bf7d97a2192e5`.
Focused controller SHA
`8bcbec583455b67543a63ef3b151aee552751c2b391ff421d04cae171ad8d51c`.
Source was drafted and static parsing/apply checks completed before this record;
no live application, compiler build, target control or timing had occurred.

**Cheapest falsifier:** Genuine old/new checked-B1 differential controller with
24 explicit IR cases and an ordinary parametric constructor bridge. Require
complete old/new/retained-legacy/independent expected values; unchanged inputs;
empty identity; correct cursor activation/fallback; erasure, dependent bindings,
beta, alias/annotation, spans and 63/64/65/129 boundaries. Any discrepancy stops
this source variant; preserve the failed attempt and repair by a new successor.

**Measurement after correctness:** Construct genuine B2, retain image/source/
driver provenance and qualified full emitted-output equality. Root runs clean
fresh-request comparisons on Numeric, MapSet and lexer with the existing method,
with instrumentation in separate runs. Compare request and import/API/first
windows separately. Inspect allocation and admitted specialization widths to
attribute a small result; do not infer clean savings from inspector shares or
one noisy favorable round. A build/control success alone is not promotion.

**Disproof/decision:** Reject a semantic/refusal/quantity/output change or a
repeatable whole-request regression. Stop if admitted work is negligible or
proof-scanning cost consumes the saved reconstruction. A small coherent win can
justify testing a broader private cursor across calls and field emission under
a separate plan; it does not justify immediate cross-stage type/text caching.
Keep the present scope bounded rather than enlarging it to reach a desired gain.

[Design](../../design/phase61/backend-type-cursor.md) ·
[Source evidence and architectural follow-up](../../implementation/phase61/backend-types-next.md) ·
[Patch/controller and root commands](../../selfhost/tools/performance/phase61/backend-telescope/README.md).
