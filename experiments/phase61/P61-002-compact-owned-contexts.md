# P61-002 — Reduce context and substitution reconstruction

Registered 2026-10-07 before Phase61 outcomes. Owner: root-assigned representation
investigator; root builds/runs; independent binder/ownership review required.
Status: correctness unchecked; measurement not run; decision investigate.

**Hypothesis:** A bounded compact representation or owned-context update can
reduce persistent index/list and first-order term reconstruction across ordinary
compiler requests. Phase60 index CPU/allocation families exceed 5% on 23/23 inputs;
substitution allocation on 22/23. These overlapping frame families are not counts
of avoidable copies or predicted gains.

**Invariant:** Binder IDs, quantities, dependent environments, law visibility,
source spans/origins and diagnostic order retain their contracts. Mutation is
limited to genuinely private owned state; public API terms, shared prefix state,
aliases and failed-request history must remain untouched. Boundary conversion,
if needed, is an explicit versioned ABI, not compiler logic moved into JavaScript.

**Cheapest disproof:** Count context width/visits and rebuilt versus retained
nodes before choosing a representation. Compare narrow real checker fixtures for
shadowing, dependent substitutions, erased/affine quantities, branch joins,
recursive specialization, origin spans and failures followed by reuse. Vary live
binder width separately from term depth. Require actual semantic/output parity;
an object-identity benchmark is insufficient.

**Prior constraints:** [Phase57 source comparison](../../implementation/phase57/implementation-comparison.md)
explains first-order substitution and parser first-event lookup. `core/term.bend`
`subst_node` calls `core_rebuild`, which can beta-reduce Apps even without a
replacement occurrence: returning an unchanged subtree needs a reduction/demand
proof. Original local declaration events differ from mapped scope headers.
[P58 local reuse](../phase58/P58-007-local-key-reuse.md) stays deferred and unrun;
its local String invariant does not justify a global identity cache. Phase58
constructor/query fixes already remove intermediate misses; avoid crediting them
again as a new representation result.

Start with one isolated changed factor and genuine checked B1; then test actual
emitted B2, allocation and clean windows on contrasting inputs. Retain full 23 and
held-out sources for selection. Abandon a compact route if conversion or ownership
proof cost outweighs it. No whole-compiler rewrite is presupposed, no host fallback,
and no source/target/raw changes are credited by this record.
