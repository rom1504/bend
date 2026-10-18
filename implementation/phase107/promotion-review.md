# Phase107 scalar promotion: independent static review

No concrete transformation bug was found in the reviewed
`selfhost/tools/performance/phase107/inline/promotion.bend`: 13,041 bytes, SHA256
`feb91f19d56bebf02a0cf7af5a85391fd6e3e2306545f6fa2fd2f841175864a0`.
This is a static audit, not a proof or an independent benchmark run. Root-owned
`promotion-audit02` and `measure07` contain the reported execution evidence.

The pass first analyzes the complete function and publishes a rewrite only if
both analysis and rewriting succeed. Its scalar-only parameter/result boundary,
refusal of calls and pointer loads, and provenance checks on every pointer access
prevent an external observer or unresolved alias from observing a promoted scalar
field in this admitted slice. Pointer stores remain physical, and their ranges
participate in the same overlap check; any scalar access overlapping a pointer
field or a differently typed/partially overlapping field refuses the function.

Every admitted allocation is a fresh, constant-sized, nonzero allocation outside
loops. Root identifiers increase across allocation sites, including after free;
scalar fields receive distinct zero-initialized locals. Thus retained allocation
zeroing agrees with initial scalar state, and a later allocation cannot inherit
the promoted contents of an earlier freed allocation. Free removes all known
pointer aliases to its root; unresolved or interior free refuses. Original
allocation/free operations remain in their original positions.

Copies and constant offsets preserve alias identity, so two names for one field
share the same generated local. Mutable scalar stores become ordinary local
assignments with the same value expression. Whole-function preflight ensures no
overlapping memory observation was missed before any such store is removed.
Fresh local names are checked against parameters and existing locals; exhausting
the bounded namespace search refuses the rewrite.

Loops use only outer pointer bindings whose variables are never assigned in the
body. Body-local copies can be reconstructed in sequence from those stable roots,
but do not escape the loop analysis. Allocation/free inside a loop, nested loops,
branches and unknown offsets refuse. Promoted locals preserve loop-carried scalar
values naturally; no first-iteration assumption or nonzero-trip assumption is
needed. Multiple sequential loops see the same field locals. Retaining allocation
and pointer operations also preserves supported pointer identity observations.

The reviewed controls specifically cover alias writes, zero initialization and
zero trips, a colliding generated-local prefix, U64 width, retained pointer stores,
and refusal for dynamic offsets, loop allocation and mixed-width overlap. This
audit did not run those controls. Its conclusion assumes verified, well-defined
sequential IR with live allocations and valid alignment; it does not widen the
domain to concurrency, arbitrary unsafe pointers or pointer representation bytes.
The [memory review](memory-review.md) documents the separate C strict-aliasing
oracle boundary.
