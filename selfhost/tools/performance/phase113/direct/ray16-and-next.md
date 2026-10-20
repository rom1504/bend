# Source16 attribution and the next recursive boundary

This is an offline source/QBE audit. No compiler, target, or benchmark was run.
The parent reports inline15→shared16 ray timing of300→134ms; this note identifies
the exact emitted difference, not a fresh timing estimate.

## Ray: the emitted change is entirely Nat successor extraction

`inspect-ray16.py` compares the frozen inline15 and shared16 ray QBE products.
Inside `p113d_` functions only, it replaces each adjacent canonical
`p111_rt_special_take(state,4,word,scratch,1)` plus scratch load with
`sub word,1`. There are111 replacements in12 functions. **The resulting whole
QBE file is byte-identical to shared16**, including every retained generic
function and all descriptor data. The exact input/method pins and per-function
counts are in `ray16-static-delta.json`.

Thus the closure adapter contributes no QBE difference to this ray fixture.
The arithmetic primitive, closure, constructor, ordinary-call and ownership
sites are unchanged. Three generic fallback successor helper sites remain.
Both products have43 direct functions. This result is stronger than a
correlation between combined profile names; it is an exact source ablation.

The active source wrapper reaches `p113d $direct.p93.loop` →
`p113d $direct.coverage.active.loop` → `p113d $direct.pixel`. Pixel and subray
call the private flat `$product.nearest` and `$product.trace`; these also call
the ordinary sphere selector functions. The flat trace contains no runtime
frame/jump or constructor/take call. Both flat and boxed trace/nearest variants
receive the successor change, as do `sx`, `sy`, `sz`, `sr` and `skr`.

The selectors match a small Nat sphere index through repeated successor arms.
Replacing the opaque helper and scratch memory with arithmetic exposes the
whole comparison/subtraction chain to QBE, especially after the existing
inliner. This is the source-supported explanation for a large effect from a
small operation; no machine-level attribution between call removal, memory
promotion and later optimization is claimed.

## Unrelated list, tree and String work remains non-tail recursive

The frozen Phase112 facts broad table provides prioritization, not Source16
performance. Representative facts/upstream ratios were list-pipeline512
13.78×, BST64 23.51×, expression128 9.46×, Unicode64 4.84× and tree-bitonic
10.58×. These are established old-baseline rows in
`implementation/phase112/broad-runtime.csv`; a current broad run may change
them substantially.

The unchanged actual source fixtures expose a common structural refusal:

| Family | Concrete definitions | Work after recursive return |
|---|---|---|
| List pipeline | `dbl`, `keep_gt1`, list generator | Construct Con or choose whether to retain the head |
| BST | `inorder` | Traverse left, update accumulator, traverse right |
| Expression | `eval` | Obtain two recursive results, then arithmetic |
| Unicode/String | `stake`, `ssplit`, `sjoin.go` | Construct SCon/list nodes or append after recursive work |
| Lexer generation | `ident`, `num`, `gen` | Build String nodes/expansion after recursive return |
| Bitonic tree | `warp`, `flow`, `bsort`, `scan` | Recursive subtrees and reconstruction, including parallel forms |

Examples are in the unchanged Phase93 fixture sources. `coverage-list-pipeline-512`
has `dbl` at24 and `keep_gt1` at48; `coverage-bst-64` has `inorder` at96;
`coverage-expression-128` has `eval` at17; `coverage-unicode-text-64` has
`stake` at102 and `ssplit` at155. The frozen facts QBE still saves frames in
these functions; those counts include retained generic bodies and are not
current dynamic counts.

Both the new direct planner and mature `flat.bend:nf_call_local` refuse
non-tail self calls. Tail SCC support alone will not admit these examples.
Allowing ordinary native recursion would change the existing stack-safety
boundary and is not an acceptable shortcut.

The strongest next architectural step is a **stack-safe local continuation
machine for a closed first-order recursive component**. Reuse the current
checked evaluation order, owning live captures and explicit runtime stack;
make local recursive calls and their return destinations structured edges
inside one machine function. A bounded first milestone is unary non-tail
constructor recursion (`dbl` and `stake`), followed by a two-result traversal
(`eval`). Unknown callees, escaping closures, foreign effects, parallel forms
and unsupported recursive components retain the existing dispatcher.

The first falsifier should show a deep list/String input still uses bounded
native stack, exactly matches complete output and alias/release observations,
and no longer transfers each recursive return through the global register-bank
dispatcher. If the plan merely moves existing frame calls without eliminating
transport, it has not established the intended benefit. This is a larger new
structured control-flow capability, not a two-line admission relaxation.

## A cheaper independent probe: mature constructor-sharing certificates

`native/sharing.bend:nh_definitions` already computes a checked whole-program
constructor-sharing set. Unknown/open annotations conservatively heat `*`.
Mature `emit.bend:ne_ctor_node` uses that certificate to omit child sealing for
proven cold parents. In contrast, Phase111 `p111_finish` obtains constructor
metadata from `nc_constructors`/`nc_default_ctors`, which set every hot flag
true, and runtime04 `p111_rt_ctor` seals every child.

The certificate is a small reusable semantic plan, but changing descriptor
hot bits alone does not optimize the ordinary constructor helper: it currently
uses those bits only in IO construction. Before implementing any fast path,
query the unchanged mature certificate on the exact checked requests for the
list, BST and expression fixtures. If it returns `*`, this route has no value
for that fixture. If nonempty cold user constructors survive, a separate
certified constructor-store path could avoid RFC wrapper construction while
retaining all other runtime behavior. It needs exact constructor provenance,
all reachable consumers and effect boundaries, and static/shared-child tests.
No cold-constructor implementation or performance claim is made here.
