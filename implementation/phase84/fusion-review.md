# Independent static review of paired native annotation/erasure

Agent handoff notes; see the [final Phase84 report](README.md) for root-run
measurements, completed controls and rejection/deferral decisions.

Reviewed patch SHA256:
`c86ff6eeab32e28757b49ad7df2d193b92d84065bc77fc0c21fd21ef90ba1746`.
This review compares the patch with `check/annotate.bend`, native `erase.bend`,
`book.bend`, `request.bend`, `static.bend`, `identity.bend`, core term helpers and
`check/env-telescope.bend`. No compiler execution or production edit was performed.

**Conclusion:** no definite semantic mismatch was found in this bounded static
audit. Proceed to differential product controls, not promotion. Dependent fields
and the moved layout boundary remain mandatory validation gates; this is not a
proof that the paired result equals the old two-stage result.

## Paths that appear structurally aligned

- **Lambda quantities.** `nrf_lambda` copies `ka_lam`'s explicit quantity2/type1
  exception. Context binding still uses the goal quantity. It substitutes the
  source binder into the result goal, preserves annotated lambda construction,
  and strips only runtime quantity0 lambdas. Remaining runtime lambda metadata
  goes through the same `k_rebuild` conventions as `nc_erase`.
- **Erased arguments.** `nrf_argument` still annotates quantity0 arguments, so
  dependent type interpretation and layout checking see the same source. Only
  their otherwise discarded runtime subtree is omitted. `nrf_app_pair` drops
  the argument according to the normalized function quantity, as `nc_erase_app`
  does through the function annotation.
- **Equality proofs.** `nrf_term` retains the ordinary annotated source for an
  equality goal and produces `Rfl`; this matches `nc_erase_annotated`'s first
  branch. The fallback also uses that same eraser rule. Quantity0 proof fields
  remain omitted, while a live proof field retains its runtime `Rfl` placeholder.
- **Application spines.** Ref/Var roots remain source-identical until wrapped by
  their enclosing normalized function goal. Argument-dependent result types
  substitute the original source argument, matching `ka_spine_step`. Runtime
  root variables lose source alias payloads through `nc_erase`, as before.
- **Lets.** Binding values use `outer`, while the final term uses the extended
  `ctx`; this matches the subtle existing `ka_let` rule. The rest receives a Var
  carrying the original source value, rather than an annotated or erased value.
  Bind names, IDs and quantities remain intact; no new quantity0-let deletion
  has been introduced. Parallel let shape is retained.
- **Literal normalization.** The paired node checks `core_literal_type` with
  the normalized goal, preserves an admitted literal, and recursively expands
  with `core_literal_step` otherwise, exactly as `ka_node`. A preserved literal
  is also preserved by `nc_erase`; expanded constructor metadata is rebuilt by
  the same canonical `kt` construction.
- **Constructor identity.** Native ADT provenance keeps constructor names.
  Other names pass through `nc_ctor_identity`, matching annotated erasure.
  Constructor declarations and provenance are unchanged by annotation merging;
  the paired producer is not replacing this decision with a string-name test.
- **Matches.** Source hit/rest goals, excluded-constructor bookkeeping and
  `mat_rest` are copied from `ka_mat_ctr`. Runtime field count and mask still
  use `nc_live_count` and `nh_field_mask`. Runtime constructor identity follows
  the existing annotated match rule.
- **Fallback forms.** Explicit Ann, Rwt and unsupported node shapes go through
  `ka_node` and `nc_erase_annotated`. This is local ordinary work, not a claim that
  every node is fused. The outer wrapper uses the original normalized goal,
  preserving the baseline's handling of explicit inner annotations.

## Highest-priority unresolved equivalence obligations

1. **Dependent constructor fields use different substitution inputs.** Annotation
   and the paired field loop substitute original arguments; old `nc_erase_args`
   substitutes the annotated field node. Their normalized semantic value should
   agree for checked terms, but quantities and later field layouts can depend on
   earlier arguments. Compare exact annotated fields, erased bodies and final
   request products on dependent telescopes with erased type/proof parameters,
   a field controlling a later field type, an explicit annotation, and a let
   alias carrying a source payload. C equality alone is weaker than this gate.
2. **`tele_fill` replaces `nc_tele_fill` at shared constructor/match sites.** The
   former can delay safe substitutions and checks for an `All` head; the latter
   eagerly substitutes without that guard. The delayed implementation already
   serves annotation, but equality of runtime live-field counts/masks should be
   checked with dependent telescopes and nonliteral reducible type heads. Owned
   checked inputs justify a narrower domain than arbitrary malformed raw terms.
3. **Runtime interpretation now precedes layout rejection.** Previously layout
   checking completed before runtime erasure. The producer now computes runtime
   bodies and field masks during annotation. A checked-but-layout-rejected input
   must still return the same first public diagnostic and terminate within the
   bounded control deadline. Open arrays and custom/unsafe effect layouts are
   particularly relevant. This change can also waste work even when semantics
   match; it is a measurement issue as well as an error-order obligation.
4. **Normalization worlds differ.** Old erasure runs against the merged annotated
   context; paired work runs against annotation's original context. Constructor
   declarations and types stay unchanged, but references may normalize through
   definition bodies that acquire annotations. Test exact products where a type
   alias or dependent telescope reduces through user functions, not only Base
   primitives and closed scalar types.

## Request/cache boundary

The new `nr_visit` calls `nc_definition` so it can consume supplied private erased
bodies. Its callers matter: raw `nr_prepare` first strips native payloads through
`ns_source`; ordinary annotated preparation builds a fresh source cache; fused
preparation creates its own temporary body facts from the producer. The final
request again rebuilds facts from the runtime closure, including original arity.
I found no route by which this change alone grants checked layout/scalar permission
from a caller's arbitrary KDef tag.

Still require an ordinary cache-miss control and a forged raw native-payload
control. `ns_attach_book` also rebuilds a constructor index before the final
request attachment; measure that overhead rather than treating transport as free.
The new entry point is private owned-API transport. Calling it directly with a
fabricated `NR_FusedSelected` is outside the proven-producer domain and must not
be used to establish trusted checked permission.

## Recommended fast gate

First compare `fused.defs` with `annotate_selected`, then the complete
`nr_prepare_fused` result with ordinary `nr_prepare_annotated` for identical
checked specialized books. Include mixed live/erased dependent fields, proof
results, partial/multiargument spines, explicit affine lambdas, sequential and
parallel lets, user/native constructor collisions, and layout refusals. Then
compare complete C/report output on the small representative compilation set.

The patch retains the entire annotated graph and adds paired return objects plus
a temporary body index. It may save erasure traversal while losing to allocation
or type-only definition work. A successful static/differential review supplies
correctness evidence; it supplies no performance evidence and does not validate
the larger annotation-removal architecture.
