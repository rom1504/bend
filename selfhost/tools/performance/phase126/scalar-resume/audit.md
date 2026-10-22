# Scalar conditional preparation before local recursive resume

Source-only prototype; root owns checked API, real plan selection, ordinary
outputs and timing. No target or compiler was executed by this author.

## Concrete missed region

In the exact typed05 ordinary-ray QBE, segment610 is `$direct.colf`. It descends
with six captured words into continuation611 (`$p111.k.83416`). That continuation
pushes its one-word combine frame, then computes `U32.shln(1,p)` before the second
own descent. The shift has a lawful scalar conditional: if p<32 calculate the
masked shift, otherwise zero. The final six stores and own jump are unchanged.

`p114h_scan_frame` authenticates the capture frame and tests
`p114r_arguments(tail,owner,arity)`. That predicate permits only a linear prefix
of `p112t_scalar_safe` statements before the exact terminal stores/jump. The
scalar-safe predicate rejects N111If. Hence the shift diamond causes refusal
before the second own descent; it is not evidence of an unsupported parallel
semantics or excessive continuation count. This is an explicit source-level
refusal that must still be confirmed by root's real candidate selection.

## Minimal extension and exact scope

`model.bend` overrides only `p114h_scan_frame`. Its own-descent arm uses new
`p126r_arguments`; the old R/G predicates and P124 non-self helper discovery and
admission remain unchanged. The old `p112t_tail` still independently checks the
exact contiguous final stores, offsets, arity, owner target, runtime jump and
machine return. Prefix eligibility adds only N111If whose two arms recursively
contain existing scalar-safe statements. Empty arms are allowed. Terminals,
frames, scheduler operations, unknown calls, register-bank operations and
arbitrary pointer operations remain refused by that original predicate.

The emitted plan is the identical P114RDescend operation. The original frame
prefix executes once, then the complete argument-preparation body including the
conditional executes unchanged; `p114r_without_transition` removes only the
already authenticated final jump and return. All argument words are snapshotted
before any formal is rebound. The existing case renamer recursively handles
N111If. Original IR verification remains required, including valid conditions,
widths and definite assignment; the predicate itself does not replace that gate.

No branch-created value is speculated or hoisted. Ownership operations permitted
by the old scalar whitelist remain in their original branch and order. Each
branch must fall through, so the existing explicit depth/unwind count is still
one per actual descent. No native recursion is added. Existing function, case,
capture and closure budgets are unchanged.

The first experiment should target colf selection. Rowf also has conditional
argument preparation but its base calls colf; an H worker is not automatically a
P112/P113 complete callable in the immutable view. Publishing H workers into a
new callable catalogue would be a separate dependency/ABI proof and is not part
of this overlay.

## Evidence and controls

`controls.bend:p126rc_controls` returns13 literal PASS/FAIL rows for old
admissions, new shift/nested-If admission, unchanged terminal tail retention,
wrong owner/arity and forbidden return/call/bank/frame/state/pointer cases.
These are pure predicate inputs, never executable fabricated runtime programs.

`shift-tree.bend` is an ordinary bounded recursive source. It computes the sum
of all leaves of a binary tree, with a checked shift before each second descent.
The independent oracle is
`2^depth*x + depth*2^(depth-1)*(step<32 ? 2^step : 0)` modulo2^32, with depth0
returning x. Shifts0,7,31,32,40 cover both branch outcomes without huge recursion;
maximum depth10. `shift-tree.json` pins the source and full expected stdout.

The production compiler and selection are untouched. A useful result requires
actual ordinary colf/shift-tree local-worker selection, complete exact outputs,
unchanged unrelated fallback, and a paired runtime measurement. No predicted
speedup is claimed from the million-leaf source count alone.
