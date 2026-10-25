# Phase140: early incremental compiler sessions

Work in progress, 2026-10-25. The [three-hour design](../../design/phase140/README.md)
targets10× complete **warm rebuilds after compiler source edits**. It does not
claim10× cold compilation. Phase137 N3 remains the qualified installed compiler.

The first full compiler edit is independently byte-exact and approximately2×
faster through an available native executable. The next candidate composes
stronger reuse before lowering and is undergoing native measurement. **The
10× target and native promotion are not established.**

## What actually changed

All semantic reuse runs in checked Bend. Private, fixed-producer process state
retains parser and checker checkpoints, prepared/erased owner products, exact
successful verifier judgments, optimized workers, registry plans and rendering
inputs. A native adapter commits state only after successful emission and file
close; a byte transport reconstructs reused chunks and verifies source/runtime/
producer identities. The host does not decide compiler legality.

The second candidate adds a retained reverse dependency graph, indexed erasure
visitation, exact cached body-reference lists, same-request constructor-catalogue
sharing, exact static-preparation prefixes, initial observer plans, compact
structural comparisons and dispatch metadata reuse. It leaves original optimizer
policies, fallback behavior, closure and final verification in place.

Independent review found two omitted global read dependencies during development:
an alias can change a global scalar-layout catalogue, and constructor searches
can depend on a datatype through an alias. The active candidate explicitly gates
reuse on the catalogue and conservatively refuses owner reuse when a datatype is
dirty. Erased-body references are also explicit dependency edges. Earlier attempts
remain archived; a finite test suite is not an end-to-end correctness theorem.

## Initial real compiler edit

Frozen source A is Phase137 SHA`2620d59a…ecf38`. B changes the product-policy bound
in`p131rg_width` from16 to15. Both have2,701,952 bytes. This is an actual policy
edit, not a no-op. A single persistent candidate processes A then B under one
logical path. A separate qualified N3 compiles B from scratch.

| Boundary | Measured cost |
| --- | ---: |
| Independent N3 B request, complete child |331.943s|
| Independent request supervisor |333.144s|
| Candidate warm B native stage total |153.551s|
| Warm B transport/materialization |7.500s|
| QBE, assembly and link of exact B |13.816s|
| Available-binary warm subtotal, before smoke |174.867s|
| Independent fresh subtotal with the same machine build |346.960s|
| Complete subtotal ratio |1.984×|

Outer guarded reference time is334.544s. Comparing that with153.551s alone gives
2.18×, but omits warm transport and both machine builds. It is an emission-step
diagnostic, not the complete rebuild score. Do not rerun solely to cross a2×
threshold or substitute a no-op result for this edit.

The full106,285,793-byte B product matches the independently generated product,
SHA`a5149b2410d70546b7a28ff907aa312b6431cf8c5348107e7b675b9e9f54702e`.
The original session receipt deliberately has`independentProductsExact:false`
because that oracle did not yet exist. Its later independent match is recorded
in`selfhost/build/phase130/p140-reference-product01/report.json`; both receipts
must be considered together. Exact QBE, runtime and toolchain identity preserves
generated code for this same source edit; this is not a new broad runtime survey.

Warm native stages: frontend51.394s, raw44.820s, backend35.266s,
registry12.805s, rendering9.266s. Most owners hit their caches, yet substantial
whole-program work remains. This motivated the next candidate rather than more
policy search.

## Validation and limitations

[Component checkpoint03](components03-addendum.md) records checked candidate15,
167 passing controls, two-family complete-product equivalence, invalid-edit
recovery and all rejected source-check attempts. Hosted cold requests cost about
20–22% more in the ordered screen. That fails the planned5% cold screen and is
explicitly recorded in the [experiment decision](../../design/phase140/README.md).
No production promotion or cold non-regression claim follows from warm gains.

The native edit suite freezes three same-width late compiler policy edits before
measurement: inlining, continuation admission and product width. Early edits,
new binders, global declarations, import changes and changed literal/static
layout do not inherit their performance claim. Exact admission/fallback, not a
user-supplied changed-owner label, controls correctness.

Active composition and commands will be consolidated after native measurements.
This prototype is a bounded ordered batch/session, not a general persistent
incremental build service. Qualified native reproduction, broader independent
correctness and adoption gates remain separate.
