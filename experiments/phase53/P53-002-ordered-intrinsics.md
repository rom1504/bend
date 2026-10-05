# P53-002: statement-prefix lowering of computed intrinsic operands

Hypothesis: materializing computed operands in ordered statement temporaries
allows direct intrinsic expansion without the IIFE cost observed in P52-003.
The improvement should follow ordinary arithmetic/call structure, not benchmark
identity. Compare a checked correction/default-only baseline with the candidate.

Owner: lowering agent; independent semantic and review agents challenge order,
scope, partial calls, lazy views and dependency metadata. Root owns measurements.
Falsifiers: changed source semantics, earlier/later observable getter/coercion,
lost or duplicated evaluation, work escaping its demand scope, or no useful gain
on the unchanged rejection screen. Retain losing artifacts and restore baseline.

Plan: [Phase53 design](../../design/phase53/default-direct-and-ordered-expressions.md).
No optimization result is established by this plan.

## Initial proposal, superseded before execution

The first source proposal is retained under
`selfhost/build/phase53/ordered-prefix01/`. It contains a copied `core.bend`, a
new `ordered.bend`, a manifest overlay, an exact patch and `source.json` hashes.
The live compiler was unchanged while the correction/default baseline was frozen.
This proposal was not compiled or executed. A subsequent independent ordering
witness disproved its presumed left-to-right policy for the pinned JS contract;
the following description records that rejected proposal, not the successor.

`JDOrdered` carries a statement prefix, one pending value expression and the
next temporary ordinal. `JDOrderedArgs` carries a prefix and already evaluated
argument values. The source walker descends only through exact-saturated
checked named calls, including ordinary calls surrounding intrinsic work. It
does not unfold function bodies. A64-level syntax-depth cap retains the old
expression emitter at the boundary; partial/overapplied/unknown calls,
constructors and closures are also opaque leaves.

For each live actual, emit its own prefix, then hold its pending computation
before processing the next actual. Only the existing exact inert atom grammar
may avoid a hold. This includes opaque computed children: otherwise a later
child's prefix could execute before an earlier getter, call or throw. Erased
actuals are omitted using the same checked telescope. Exact native templates
receive the held values, so even their conditional or repeated parameter uses
cannot suppress or duplicate evaluation. Ordinary child calls remain non-tail
and retain the existing bounce forcing and reference metadata.

Three existing statement positions consume the representation:

- A demanded `let` RHS, after the original `JD_USE` gate; parallel RHS expressions
  all use the old environment, and share an increasing temporary ordinal.
- A return expression, inside its original selected branch and invocation.
- A self/mutual-tail transfer, followed by the existing all-arguments-before-
  stores and PC/continue emitter. An erased-only incomplete source suffix keeps
  the old transfer values.

Fresh `$ordN` locals occupy lexical blocks separate from source `$xN` bindings,
parameters, match views and loop-transfer temporaries. Empty prefixes retain the
old return/transfer spelling. Prefixes retain operand `JD_USE`/`JD_REF` markers;
intrinsic expansion omits only the eliminated native callee reference.

This first slice deliberately materializes computed arguments of admitted
ordinary call trees too. That is a conservative ordering policy, not a claim
that every such temporary is necessary. Inspect code size, compiler acquisition
cost and clean runtime results before broadening it. No IIFE is added per
expansion, no host permission is cached, and no numeric folding/table pass is
included. Existing source-created IIFEs outside this slice remain unchanged.

## Two-stage successor and composition

The retained `ordered-prefix02` proposal follows pinned `js_call` at
`bend2/comp.ts:3060`: first lower all child expressions and emit their statement
prefixes, retaining one pending expression per child. For an intrinsic, only
then hold its non-atomic pending operands in argument order and expand the
existing exact native template. Ordinary named calls and closure application
retain their pending expressions after the accumulated prefixes. This policy
is observably different from eagerly holding each child before lowering the
next: the independent nested arithmetic witness requires `g` before `f`.

The implementation propagates this representation through exact-saturated
named calls, unknown unary closure application, constructors and expression
Lets. Erased actuals and fields remain absent. Native constructor literal and
inverse-view simplifications run before field lowering, retaining their demand
behavior. Constructors collect prefixes from their live fields but leave field
values pending. Closure bodies retain their own statement scopes; work is not
lifted out of a closure. Partial named applications defer the supplied argument prefixes into the
final eta closure, then expand the call only when fully applied. Allocating a
partial closure never evaluates those supplied expressions; an erased-only
missing suffix creates no closure. Overapplication propagates prefixes through
its outer closure-application chain.

Expression Lets require a further distinction: pinned `js_open` holds each
demanded RHS, then leaves the body's final expression pending. A proposed
result-slot adapter would have evaluated that body too early and was rejected
during source review. The successor uses unique held-local aliases, preserving
parallel RHS environments, `JD_USE` demand checks and captured closure values
without forcing the final body expression into the prefix. Held source aliases
use source-binder IDs plus reserved ordinals in a namespace distinct from
transient expression holds, avoiding both reused sibling-term collisions and
shadowing of captured aliases by a nested closure's fresh temporaries.

Return and tail-transfer consumers retain their existing branch/invocation
scopes. Tail transfers collect all child prefixes before the existing parallel
argument holds and stores. `JD_USE` and `JD_REF` markers remain in both parts.
The independent gates must include nested computed intrinsics under an unknown
call, a constructor, a source Let and a returned closure; clean scalar values
alone cannot establish observable ordering. All proposal sources and failed
assumptions are retained; no performance or execution result is claimed here.

The final successor removes the prototype's arbitrary depth64 fallback. Every
recursive path descends a genuine term child, a remaining constructor/call
field list, or a finite missing-formal telescope; no function body is unfolded.
Returning to the old expression emitter at depth64 would silently restore the
known ordering mismatch, while refusing there would create an unnecessary
acceptance regression. Existing compiler process/time limits remain in force.
The complete pre-removal source is retained separately. The final isolated
receipt is `selfhost/build/phase53/ordered-prefix02/source.json`; its patch SHA
is `ab0aed1060b4220170b3cd986b54ea594b0c2df3db06b4b0f95fb1c9af3c2200`.
Static review is separate from the still-required checked build and execution
gates.

A final review removed the obsolete exact-source-arity tail fallback. The
existing SCC caller already proves complete live saturation and no surplus
actuals, so omitted erased-only suffixes also receive ordered argument lowering.
