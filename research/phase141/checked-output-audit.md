# Phase141: ownership of checked output and annotation reconstruction

This is a source-only audit, not a performance or correctness qualification. No
compiler targets were executed and no compiler sources were changed.

**Recommendation:** do not make annotation elimination the first Phase141
simplification experiment. The selected compiler already retains much of the
checked output that Phase7 lacked. Its remaining annotator has only **170
implementation declaration lines**, plus 156 law lines and a two-line type.
Moving its remaining responsibilities into the checker might eliminate a pass,
but there is no demonstrated twofold reduction after counting the replacement,
output policy and preserved laws. Eliminating the duplicated normal/incremental
parser implementation has a larger and more directly identifiable deletion
budget.

## Exact source and accounting

The audited source is
`selfhost/build/phase137/integrated-source03/compiler.bend`, SHA256
`2620d59a3a20fa5d5d27bbf3b12ceb7304439b27093fff1c0f383da03e4ecf38`:
2,701,952 bytes and 58,569 physical lines. This is the selected assembled source,
including its actual overlays, rather than an assumption that current
`selfhost/src/` files are the selected implementation.

[The exact inventory](checked-output-inventory.json) records every declaration,
selected-source line, module provenance and annotation/erasure function caller.
Counts include an immediately preceding `@unsafe`; they exclude blank separators
and module/provenance comments. Identifier-reference discovery excludes string
literals and comments. It is a static reference inventory, not a runtime profile.

| Module | Functions | Function lines | Laws / law lines | Type lines | Total declaration lines |
| --- | ---: | ---: | ---: | ---: | ---: |
| `check/annotate.bend` | 34 | 170 | 26 / 156 | 2 | 328 |
| `back/native/erase.bend` | 9 | 56 | 3 / 13 | 0 | 69 |
| `check/specialize.bend` | 53 | 295 | 5 / 19 | 6 | 320 |
| `check/kernel.bend` | 157 | 759 | 60 / 427 | 9 | 1,195 |

Counting all 328 annotation lines as removable implementation would overstate
the opportunity: almost half are laws. The annotation and erasure implementation
together is 226 declaration lines. Neither specialization nor the kernel is
redundant annotation machinery.

## What the checker already owns

The live result is `KChecking{term,typ,uses,error,world,consumed}` (line 108), and
`KWorld{book,memo,fresh,checked}` (121) explicitly separates the semantic book,
specialization state and accumulated checked definitions.

| Phase7 missing contract | Actual selected Phase137 owner |
| --- | --- |
| Checked lambda/constructor children | `check_lam_done` (8841), `tele_check_done` (8789), `ki_args` (9455) rebuild using returned checked children. |
| Full Let output | `check_let_kind` (8874) accumulates checked bindings; `ki_let_finish` (9507) rebuilds the original Let site with bindings and checked body. |
| Matcher arms | `ki_match_arm` (9522), reached through `check_mat_filled` and `ki_match_bound`, combines checked branches through `ki_pair`, retaining branch-use semantics. |
| Rewrite output | `ki_rwt_done` (9534) rebuilds evidence, motive and body using checked terms. |
| Specialized checked instances | `sp_live_done` (10163) records the successful instance body `ct(r)` in `kw_checked`, while preserving the instance book, memo and fresh-name state. |
| Chronological publication | `dg_check_events` (16522) checks source events in order. `dg_event_publish` (16550) updates the semantic book separately from `dg_event_output` (16557), which publishes checked non-template live bodies. |

Consequently, Phase7's missing Let/Mat/Rwt and instance-output ownership are not
valid reasons to estimate a new large reconstruction subsystem today. Conversely,
their presence is not proof that the checked term is the backend-annotated term.

The existing native route is:

```
chronological successful checking
  -> checked definition output / admitted prepared Base
  -> book_context_world
  -> p86_plan_context
  -> annotate_selected(context, reachable definitions, stops)
  -> jl_checked_error
  -> nr_prepare_annotated
  -> erased/native facts and lowering
```

`book_context_world` (10732) is private to the successful check and admitted
prepared world. Its permission does not extend to an arbitrary raw book supplied
by a component API. `p86_plan_context` (38453) still performs annotation;
`p86_plan_annotated` (38459) preserves an independent `jl_checked_error` gate.

## Information still reconstructed by annotation

The checker knows many of these facts during checking but does not retain them
in the shape demanded by the backend:

- `annotate` (10833) and `ka_annotated` (10841) beta-reduce the term and retain
  the weak-head-normalized expected type in canonical `Ann` wrappers. Child
  type recovery in `ka_type`, `ka_type_node` and `ka_type_app` is real repeated
  work that checked typed output could remove.
- `ka_lam` (10882) records the effective lambda quantity and clears source
  quantity-presence/origin metadata. `check_lam_done` retains the source lambda
  metadata instead. Merely wrapping `ct(r)` is insufficient.
- `ka_field` (11028) marks constructor-field annotation with identifier 1 and
  the field quantity. Constructor telescope checking alone does not establish
  byte-identical metadata. `jl_checked_error` consumes these facts.
- `ka_args*` preserves dependent telescope substitution and erased quantities;
  its cached/static variants also avoid repeated normalization. Replacement
  must preserve this work avoidance, not just the mathematical result.
- `ka_mat*` derives arm and remaining-constructor types; `ka_let*` maintains
  parallel RHS scope and substitutes backend context values; `ka_rwt` preserves
  the rewrite evidence/motive/body layout.
- Backend consumers, including `ns_term` (35033), inspect annotation types for
  representation selection. Removing annotations entirely is a broader backend
  change than deleting the reconstruction pass.

The plausible simplification is therefore **checker-owned compile output with
the same annotation contract**, not generic removal of every typed term or a
new untyped core. A separate compile-output mode must preserve the semantic term
used in dependent substitution, normalization and diagnostic construction.
Injecting backend annotations into every existing `ct(r)` use without auditing
those consumers could change checking behavior or cost.

## Exact retirement and caller boundaries

These are the 34 annotation function declarations whose complete retirement
would constitute elimination of the reconstruction subsystem:

```
ka_wrap annotate_book annotate_except annotate_selected
ka_defs_except ka_defs ka_def annotate ka_annotated ka_node
ka_type ka_type_node ka_type_app ka_lam ka_app
ka_args ka_args_head ka_mat ka_mat_ctr ka_let ka_let_head ka_rwt
ka_spine_eligible ka_spine ka_spine_finish ka_spine_step
ka_app_spine ka_app_spine_finish ka_app_spine_root
ka_args_cached ka_args_cached_head ka_args_static ka_args_after_head ka_field
```

Their external implementation references in this snapshot are precisely:

| Callee | External definition |
| --- | --- |
| `annotate_selected` | `p86_plan_context` (38453) |
| `ka_def` | `base_annotation_collect` (11098), `base_annotation_def` (11138) |

The lack of another internal reference does not authorize deleting externally
exported component APIs. `annotate_book` and `annotate_except` are compatibility
entry points; their supported contract must be inventoried before removal. If
the old annotator remains to implement raw-book APIs or the prepared Base
fallback, it is retained code and earns no deletion credit. Base product
preparation also needs a real checked-output producer and version/identity bridge.

Do not attempt erasure retirement in the same first experiment. All nine
declarations are small, and several responsibilities are used elsewhere:

| Definition | External references |
| --- | --- |
| `nc_tele_fill` | `nc_show_arms`, `p111_show_arms` |
| `nc_live_count` | `nc_ctor_specs`, `p113n_field_kinds` |
| `nc_erase` | `nd_partial_selected`, `ns_unshared_definitions`, `nc_definition_plain`, `p113dc_definition`, `p121f_expr` |

The other six are `nc_live_count_head`, `nc_erase_args`, `nc_erase_mat`,
`nc_erase_annotated`, `nc_erase_list` and `nc_erase_app`. Erasure removes zero-use
arguments/lambdas and equality proofs, establishes constructor naming and match
field masks, and feeds several optimization paths. Direct checked-to-erased
output would still need those operations and their contracts. Specialization
likewise remains responsible for materializing, naming and checking instances;
its existing output ownership is not a reason to delete it.

## Replacement budget and cheapest decisive test

A genuine twofold implementation reduction in the annotation subsystem requires
at most **85 new implementation declaration lines** replacing its current 170.
Count every additional checker field/accessor, output-policy transition,
constructor helper, adapter and compatibility implementation. Retain or port
the 26 annotation laws: deleting those laws cannot supply the claimed reduction.
The independent output verifier also remains. An upper bound of 164 lines is
only half the mixed law-and-implementation count and is not the appropriate
implementation target.

The strongest evidence in favor is structural: the checker already owns the
child recursion, dependent goals and specialization output. Successful result
constructors could publish final typed children without a second traversal or
`ka_type` inference. The strongest evidence against a quick size win is that the
annotator is already compact, while compile/discard policy and exact metadata
have to be added across checking transitions. **No measured or inspected
candidate currently demonstrates that this can fit within 85 lines.**

If pursued later, make one bounded replacement, with the old implementation
kept only as an external experiment oracle:

1. Introduce a compile-output policy at the real chronological check entry;
   guard allocations before construction. Ordinary check-only requests retain
   their current output/cost contract.
2. Cover all executable forms, effective quantities, constructor field markers,
   dependent substitutions, failed-result ordering, template memo/freshness and
   prepared Base provenance. Compare complete annotated books, not just a few
   successful root terms.
3. Route the existing native plan through the checked producer while preserving
   `jl_checked_error`, erasure and subsequent validators. Use existing Lexer,
   Closures and Map request controls plus the historical unsupported witnesses.
   Require exact backend products before runtime timing.
4. Measure checking alone and complete compile requests separately. Reject a
   check-only regression caused by unconditional typed-output construction.
   Count the resulting implementation and actual retired declarations before
   undertaking a full native build.

[Phase7's experiment](../../implementation/phase7/architecture-evidence/checked-output/report.md)
already demonstrated why these are separate gates: on one bounded workload,
check-plus-annotation improved 16.85–17.67%, but checking alone became
25.39–25.45% slower and peak RSS rose 44.74–46.36%. It retired no production
module. Those figures are historical synthetic results, not estimates for the
current compiler.

This remains a worthwhile pass-elimination hypothesis if future evidence shows
annotation dominates an important request. It is a weak first bet for a large
source reduction: even deleting all 397 annotation/erasure declaration lines
without replacement would remove less than 0.7% of the selected source, and that
unrealistic count includes laws and externally required utilities.
