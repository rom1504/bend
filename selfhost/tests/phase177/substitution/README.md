# Phase177 substitution single-owner candidate

Status: source-only candidate and semantic audit. No compiler, source check,
benchmark, profiler or qualification was run by this subtask. Root owns those
lanes and the promotion decision. Maintained modules are unchanged.

## Hypothesis

`subst` is called directly by annotation, telescope application, weak-head and
graph normalization, binder rebinding and conversion. Its current implementation
recurses through `subst` / `subst_node` / `subst_terms`, then calls `core_rebuild`.
For an App this constructs a completed KTerm and immediately dismantles it to
call `core_apply_span`; beta reduction returns to `subst` again. This makes it a
useful wider transfer experiment than parser-only pattern substitution.

The candidate puts all those recursive transitions, including nested beta
substitution, in one `p177s_loop`. App completion passes the transformed children
directly to the apply states, avoiding the completed App shell before its
immediate decomposition. Non-App leaves retain the original value. It keeps an
empty shell only for a composite parent while its children are traversed.

This follows Phase176's *observed private-worker admission*, not an assumption
that explicit frames are automatically faster. Its mutually recursive frame
candidate was slower. This candidate still allocates frames and reverses child
lists. A beta adds a small restore frame; if direct admission fails or overhead
dominates, reject it before full frontend acquisition.

Historical Phase62 substitution counts differ widely by stage and workload.
Phase171's `subst_node` owner samples establish visibility, not an inclusive
cost bound. Neither sample count nor removed constructor count is a forecast of
whole-frontend savings. Full frontend timing on unchanged inputs is necessary.

## Exact assembly boundary

Use the existing Phase176 preparation transport against the pinned maintained
Phase175 source. These are the only overrides:

```
--prelude selfhost/tests/phase177/substitution/single-prelude.bend
--module selfhost/tests/phase177/substitution/single.bend
--replace subst --replace subst_node
```

The original `subst_node` law remains unchanged. The added two entry laws permit
the original lexical positions to refer to helpers defined later; they declare
quantities and types, and are not equivalence proofs. Their implementations are
untyped as required by this Bend syntax. No public term type or core operation
is replaced. `subst_terms` remains original and reaches the override through
`subst`; `core_rebuild` / `core_apply_span` remain original for external callers.
The loop itself never calls those operations, so beta does not introduce a
second recursive owner.

For the complete-value API, add `controls.bend` and export `subst`, `subst_node`,
`p177sv_cases`, `p177sv_value`, `p177sv_actual`, `p177sv_expected`,
`p177sv_node_actual`, and `p177sv_node_expected`. Prepare the baseline with the
same controls and exports but no overrides. `values.mjs` takes checked baseline
and candidate reports plus a fresh `--out`; it compares every field, retained
aliases, four literal expectation pairs, 240 parameter variations and 20 direct
`subst_node` comparisons. This is a proposed finite gate, not a claimed pass.

For a native micro screen, add `workload.bend` plus the existing
`selfhost/tests/phase175/frontend-digest.bend` and extract `main`. Export
`p177sw_run` as well if an independently checked hosted observation is desired.
The workload includes setup, transformed values, surviving original aliases,
replacement aliases, all-field observation and process teardown. It alternates
hit and miss IDs over mixed Ctr/App/KLambda/All trees. It does not claim to model
the real distribution of beta reductions. Use actual frontend requests as the
transfer gate; a local digest is supplementary to the complete-value oracle.

## Semantic audit

The loop invariant is that states 0/2 represent ordinary `subst`/`subst_node`
respectively under the current `(id,value)`, while a Node frame holds the already
transformed children in reverse order and the untouched remaining siblings.
State 4 returns one completed value. Finishing a node restores original child
order and performs exactly the original post-child rebuild.

At an App, both operands are transformed before deciding beta. Every extra child
is traversed before it is discarded, and missing positions use the original
`terms_at` Absent fallback. A non-Lam function creates exactly the canonical App:
empty name, zero id/quantity, exactly two children, empty removed list, and the
original App span. A Lam function starts substitution on its first body child
under its own id and transformed argument. A Beta frame then restores the outer
substitution before any subsequent sibling. Nested beta uses the same owner.

The root Var hit returns the replacement unchanged, including its spans and any
latent App. The miss returns the original Var unchanged, even if it has stored
children. In contrast, direct `subst_node` intentionally does not test the root
Var: its children are traversed. Binder IDs do not stop traversal, matching the
original globally unique identifier contract. KLiteral payloads remain opaque.
Legacy KTerm/Lam and KLambda both beta-reduce; KLambda quantity-presence survives
ordinary reconstruction. Ann is not forced during App rebuilding.

The literal cases explicitly cover:

- Hit/miss Vars with stored children; opaque replacement and self-id replacement.
- All three public term variants, both quantity-presence values, retained notes,
  unusual quantities/ids/spans and the maximum U32 id.
- App arity 0, 1, 2 and 3; metadata canonicalization with no variable occurrence.
- Legacy and explicit lambdas, absent arguments, replacement-created beta and
  outer-sibling context restoration after beta.
- Literal functions and annotated functions that must remain stuck Apps.
- Direct `subst_node` on an internal and a leaf Var.

The finite gate should be supplemented with real frontend complete values and
normalization/checking cases before integration. A no-occurrence shortcut is
deliberately absent: Phase62 already records that App rebuilding can beta-reduce
even when the substituted variable does not occur.
