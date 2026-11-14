# Phase195 ownership boundary: retained-root readers with an owned result

Read-only investigation against baseline `5c67ac5`, Phase194 selected-source02
and native45-02. No target, compiler, timing or sampler was run, and no maintained
source or experimental compiler module was changed. [Exact machine inventory](machine.json)
and [bounded extraction](derive.py) authenticate the current products and the C/QBE
references selected by Phase194's runtime report. Compressed disassemblies are
individual functions, not complete compiler dumps.

The strongest whole-work hypothesis found is **extend checked borrowed observers
to a retained-root read whose result contains an owned projection**, with an
explicit ownership acquisition at the escape. `Map.seek.go` is a real ordinary
workload witness: its source searches the map, returns the same map/key, and
optionally returns a stored key. The current scalar-only observer contract does
not express the `Maybe<String>` result. Its fallback therefore takes and
reconstructs tree nodes along a read-only search. This deserves a bounded
admission/representation experiment, but the present evidence does not justify
implementation or a whole-suite speed prediction yet.

## Exact repeated work

The current upstream Base source at `bend2/base.bend:3045` defines `Map.seek.go`.
Its recursive MNode arms call `Map.bit`, recursively seek a child, then use
`Map.lo`/`Map.hi` to reconstruct the unchanged parent. Leaf arms reconstruct the
same MNode/MLeaf and return `Some{k}`. `Map.set` uses this search before its
comparison and eventual insertion/replacement, so this preserved-tree work is
repeated during ordinary map churn and record aggregation, not just a synthetic
shared-product diagnostic. The necessary final insertion/update remains.

| Actual Map-churn `Map.seek.go` | Direct x86 | QBE | Mature C |
| --- | ---: | ---: | ---: |
| Whole function bytes | 20,824 | 16,100 | 19,995 |
| Whole function instructions | 4,194 | 3,591 | 4,539 |
| Static take3 / take2 sites | 5 / 14 | 5 / 14 | inlined representation-dependent paths |
| Static ctor3 / ctor2 / ctor1 sites | 24 / 38 / 6 | 24 / 38 / 6 | 61 heap_alloc_miss sites, 38 heap_hand sites |

These counts include duplicated match/error paths and are **not** per-call or
dynamic allocation counts. C inlines ownership paths, so its static instructions
and calls cannot be interpreted as an equivalent amount of work. Nevertheless,
the source-connected selected x86/QBE sequence retains exactly the same classes
of tree destruction/reconstruction and escaping-key retention. This is a shared
lowering opportunity; replacing x86 selection alone cannot eliminate it.

Phase194 measured current Map128 at 3.544× C and record256 at 2.843× C. Those
are complete-program gaps, not this mechanism's ceiling. There is no current
dynamic profile or owner-call count for seek, so no numeric share is claimed.
The structural ceiling is removal of all tree take/reconstruction/recursive
return transport in the *read-only search*, while preserving its traversal,
bit computation, owned result acquisition and later mutation. That is a larger
work category than saving metadata checks inside a take helper.

## An attractive direction already falsified

`Map.bit.go` appears in source to consume and rebuild the unchanged String
prefix. It is **already optimized**. Current `$product.Map.bit.go` calls
`$p118borrow.read.Map.bit.go` and writes the original input key plus the scalar
Boolean to its result buffer. The actual borrowed worker loops over fields;
it does not call take/constructor per traversed character. Old `.go.rec` and
`.go.chr` functions still contain constructors, but citing those symbols as the
active recursive path would be wrong. QBE has the same borrowed route.

This negative witness should be a regression control for any new observer
work. Do not add a new identity-preserving scalar-observer recognizer, and do
not infer surviving reconstruction from names or source syntax alone.

## Existing admission boundary and the smallest falsifier

`back/native/observer-layout.bend:nol_wrap` admits one scalar observation plus
preserved roots inside at most two fixed constructor shells. `nol_wrap_shell`
requires a single constructor; `nol_finish` requires every root once and one
scalar. `Maybe<String>` is neither that scalar nor a fixed single-constructor
shell. The analysis additionally tracks origins and held roots; merely relaxing
the layout check is unsound.

First investigate a general two-outcome observer summary: no result, or one
field originating beneath a held immutable root. Its borrowed worker can return
a tag plus borrowed word through the existing flat multi-result ABI. The adapter
must acquire exactly one owned reference to the selected field while the root
is held, then return the original roots and the owned result using the original
wrapper layout. It must not expose a borrowed pointer after releasing its root,
duplicate an affine field, keep twice, or treat a reconstructed unequal node as
the original. Effects, mutation, arbitrary closures, unknown escapes and failed
origin proofs retain the exact original implementation. Recursive reading must
stay a local loop or use the existing stack-safe plan.

The cheapest decisive falsifier is a checked finite tree reader returning
`(original_tree, Maybe<selected_payload>)`, with both unique and shared parents,
empty/miss/deep-hit paths, an independently observed old alias, and a returned
payload that survives destruction of the original root. Include a superficially
similar mutating/rebuilding reader as a required refusal. Before runtime timing,
the successful selected machine chain must have no tree take/ctor operations
and exactly the required owned projection acquisition. Then require the same
admission in actual `Map.seek.go`; stop if the generalized layout/origin proof
still cannot reach that owner without broad analysis changes. A source-only
handwritten Map replacement is not a general compiler optimization.

Existing shared-product diagnostics remain useful secondary controls: preserving
scalar fields through multiple nonescaping observations would eliminate their
ctor/keep boundary, but this audit found no evidence that this distinct pattern
dominates current ordinary workloads. Do not substitute that tiny win for seek
coverage.

## Transfer and limits

Map churn and record aggregation are direct prospective transfer cases. The
compiler's `index_find`/`index_bucket` return a selected KDef beneath retained
tree/list inputs, which makes owned projection a plausible compiler family;
their heterogeneous KDef shapes and existing reader mechanisms require a
separate exact-machine/admission audit before claiming coverage. No compiler
benefit is established here.

Tree bitonic's actual `warp_zip` still takes two nodes and creates three nodes;
`p114r warp` retains its explicit continuation machinery. That operation changes
the tree, so the proposed preserved-root observer does not apply. Lexer consumes
its input and constructs output state; it likewise is not an automatic transfer
claim. The earlier Phase192 constructor/take profile shares were 29.85% tree and
16.21% lexer, but contain necessary work and predate this baseline. Neither is a
removable-time estimate. Blanket take inlining remains rejected by Phase186's
regressions, and ABI argument-move removal by earlier Phase191 evidence.

Recommendation: one bounded owned-projection admission study, with the finite
tree reader and actual Map.seek as early stop gates. Do not implement a large
observer rewrite solely from this static evidence. If the campaign requires a
small x86-only change with established compiler-wide transfer now, this audit
does not supply one; its honest result is a larger shared semantic boundary and
one falsified duplicate idea.
