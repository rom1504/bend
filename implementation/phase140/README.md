# Phase140: early incremental compiler sessions

Work in progress, 2026-10-25. The [three-hour design](../../design/phase140/README.md)
targets10× complete **warm rebuilds after compiler source edits**. It does not
claim10× cold compilation. Phase137 N3 remains the qualified installed compiler.

The full compiler edit is independently byte-exact. The latest completed
candidate17 reduces native warm compilation to105.228s, with a124.337s
available-binary subtotal versus346.960s fresh (2.79× before shared session
overhead). A final typed-comparison candidate is undergoing native measurement. **The
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

## Native checkpoint at20:34 UTC

Candidate17 (`session/modules-native-v17.json`, source SHA`fcef9aa6…6282de`)
passes236 finite controls, complete two-family hosted product/plan checks, and
four alternating native Lexer revisions. The matched full compiler A→B run is
`selfhost/build/phase140/full-product02/report.json`; both complete products
match independent qualified references. Compared with the initial product pair:

| Warm native stage | Initial | Candidate17 |
| --- | ---: | ---: |
| Frontend |51.394s|31.319s|
| Raw lowering |44.820s|14.161s|
| Optimization and verification |35.266s|40.652s|
| Registry |12.805s|11.389s|
| Rendering and close |9.266s|7.707s|
| Total |153.551s|105.228s|

The backend regresses even while the total improves. This is not a clean ablation
of any individual added cache. Native cold seed time is364.129s versus334.286s
initially (+8.93%), so the cold5% gate still fails. Peak process-tree RSS is2.305GB.
Transport costs5.293s; the exact unchanged machine build costs13.816s.
The native process also has3.407s outside revision, source-IO and preparation
clocks. Acquisition, initial seed and shared overhead are not part of the warm
subtotal and must not disappear from adoption/research-cost accounting.

The three-edit candidate15 batch (`full-batch01`) measured133.647/136.411/139.365s
native warm times for inline/continuation/product changes. It seeded before the
earliest edit, unlike the product-only pairs. Inline/continuation products do not
have independent full references and remain exploratory; spending another12min
on those reference builds was deferred because the5× gate was not approached.

The independently rebuilt product-policy compiler itself passed exact Lexer,
Map and closure compilation requests in5.815s (`product-compiler-smoke01`). This
is focused executable evidence, not complete N1/N2 qualification.

The [cost review](cost-review.md) records work, failures and source growth. The
[next reuse boundary](../../research/phase140/next-reuse-boundary.md) explains why
retained change evidence is more promising than another independent deep cache
comparison at each stage.

Active composition and final commands will be consolidated after native measurements.
This prototype is a bounded ordered batch/session, not a general persistent
incremental build service. Qualified native reproduction, broader independent
correctness and adoption gates remain separate.
