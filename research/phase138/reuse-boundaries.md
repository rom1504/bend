# The actual early-reuse boundary

Read-only audit of selected source
`selfhost/build/phase137/integrated-source03/compiler.bend`, SHA256
`2620d59a3a20fa5d5d27bbf3b12ceb7304439b27093fff1c0f383da03e4ecf38`.
Line numbers below refer to this frozen source, not the upstream TypeScript checker.

## Existing prefix interfaces are insufficient

`base_prefix_native`10419 requires `db(d)` for every definition.
`base_prefix_prepare_known`10436 also requires a closed prefix, empty
specialization memo and exact replayed world. An arbitrary compiler prefix does
not satisfy these conditions. `check_book_diagnostic_from_exact_prefix`16604
deliberately rechecks the whole book. A prepared-Base hit is not arbitrary
incremental checking.

There is nevertheless a concrete new checkpoint to test:

- `check_declarations`9081 exposes ordinary definitions through `declared(d)`;
  unpublished future bodies cannot unfold.
- `dg_check_events`16522 carries checker world and seen-event history.
- `dg_event_publish`16547 publishes completed bodies in source order.
- `signature_mode`9068 and later-fill metadata affect checking.

A body-only edit preserving headers, event order, source spans and fresh bound
may resume the exact state before that event. Capture complete `KWorld`, memo,
fresh state, checked outputs and `seen`; compare against a full fresh run.
Start with the retained equal-length `p111q_main` spelling edit, then a semantic
body change. Reject changed signatures, declaration insertion, law fills, foreign
flags, bounds or unrecorded dependencies. Parsing stays fresh in the first
experiment; a parser checkpoint requires its own parser/name/fresh-state contract.

## Reuse has to continue into later stages

| Current computation | Existing boundary | Work that might be skipped |
|---|---|---|
| `annotate_selected`10805 | Checked facts and complete consumed dependencies | Annotation of unaffected definitions |
| `nr_visit`36283 | `NativeErasedBody` retained before `nc_definition`35588 | Repeated erasure, then downstream work |
| `p111_compile_defs`40050 / `p128raw_prepared`56420 | Named owner result | Generic/private lowering |
| Verified emitted owner | Immutable IR, binding environment and verifier identity | Verification and rendering of unaffected units |

Annotation uses `wnf`, `lookup` and telescope substitution against the book.
Identical public type spelling is insufficient. Retaining `NativeErasedBody`
is a concrete existing product; a new universal IR is not needed to test it.

## Global binding is a real remaining obstacle

`p111_compile_defs` threads one fresh counter across owners.
`p111q_function_ids`40739 and `p111q_constructor_ids`40746 use positional IDs.
`p112s_intern`42164 assigns encounter-order static offsets; `p112s_word`42107
embeds them. `p131p_closed`57620 observes merged helper readiness/absence.
`p114s_open`48777 and `p134v_commit`58336 retain verification obligations.

The earlier real edit changed476 generated functions,377 through numeric-operand
shifts alone. Owner-local names and symbolic function/constructor/literal
references must survive until a defined binding step. Otherwise unchanged
semantic units still need rebinding/rendering. Do not obtain edit stability by
adding runtime indirection without measuring generated-program performance.

For the initial experiment, conservatively invalidate anything affected by
binding; report how much locality this loses. Then introduce only the stable
identities that evidence shows necessary. An environment-wide fingerprint is a
safe fallback but does not establish useful fine-grained reuse.

## Keep the builder fixed while iterating on a candidate compiler

Use qualified compiler A to incrementally build source revisions B1,B2,... .
Changes to B's optimizer do not automatically change A's producer identity.
Actual source dependencies and A's interprocedural optimization can still cause
large invalidation. Adopt a new qualified A only at deliberate integration
points, charging a new cache epoch and full qualification then. This separates
candidate development from testing self-reproduction; it does not remove either.

## A narrower policy experiment is also possible

Phase115 has immutable menus of legal alternatives. A frozen native host could
retain a checked `P114SBoundary` and accept a small Bend selector's choices among
host-admitted alternatives. That may avoid rebuilding the compiler for policy
research, but it is not arbitrary source incrementality. There is currently no
general native replacement-worker ABI. Start with two built-in selectors and
total trial timing, not a plugin framework. Existing policy diversity was weak,
so this is secondary to the actual source-edit experiment.
