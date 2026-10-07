# P61-009 — Reuse empty-child non-App substitution nodes

Registered 2026-10-07 before source application or outcomes. Root authorized
the minimal allocation experiment; no count, speedup or promotion is claimed.

**Hypothesis:** Ordinary substitution needlessly allocates a KTerm for atomic
Ref/Qua/other nodes. When `kids=Nil` and `tag!=App`, its child substitution is
Nil and `core_rebuild` returns the copied value unchanged. Retaining the original
immutable term removes that copy without a result flag, second tree scan or new
list algorithm. Existing Var and KLiteral behavior remains unchanged.

**Invariant:** Every term field, variant, literal payload, quantity and source
interval stays structurally identical. App is explicitly excluded even when its
children are empty: old rebuilding/canonicalization and no-target beta work must
remain. This is immutable compiler-term semantics, not a promise of fresh JS
object identity; the original kernel already retains Vars and literals.

**Cheapest disproof:** `leaf-controls-v1.mjs` compares old/new actual checked APIs
on 14 independent structural cases: ordinary/unknown/malformed non-App leaves,
F32 payload, Var payload/replacement, ordinary Apps, malformed empty/extra Apps,
beta without the substituted target, explicit lambda quantity and nested metadata.
All inputs must remain unchanged. Then unchanged broader source/error/trust
controls and the registered clean compiler screen decide selection.

Patch: `selfhost/tools/performance/phase61/prefix-state/leaf-substitution-v1.patch`.
Root owns application/builds/targets. The backend telescope experiment is
independent; a combined candidate's latency must not be attributed solely here.
