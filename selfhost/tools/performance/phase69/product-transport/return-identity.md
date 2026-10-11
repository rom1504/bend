# Return identity and borrowed observation: bounded proof strategy

[P69-009](../../../../../experiments/phase69/P69-009-root-preserving-traversal.md)
tests a more substantial mechanism than product transport. A function which
returns unchanged input data alongside an observation can retain its owned input
root, read through borrowed cursors, and return the original root. Removing
reconstruction can also make a formerly non-tail traversal tail recursive.

This is a compiler feature proposal, not permission to recognize Base function
names. The saved-C experiments use names only to select intervention sites and
are explicitly typed-value diagnostics. There is no production implementation.

## Why the product island did not give a large gain

Root-owned completed receipts:

| Diagnostic | Original ms | Changed ms | Same-campaign upstream ms |
| --- | ---: | ---: | ---: |
| Lexer loop only | 611 | 595 | 246 |
| Lexer static + mode | 611 | 482 | 246 |
| Lexer static + mode + loop | 611 | 432 | 246 |
| Map two-word product island | 722 | 677 | 430 |

The Map island removed 6.23% of elapsed time. The first failed attempt, caused
by forgetting that `WL_OPEN` shadows argument registers, remains separately
preserved. V2 passes its three controls and nine clean intervals. This does not
justify a large result-ABI extension as the next optimization by itself.

The 391,290 excess Map Tuple calls belong to many functions. The bit island
removes about 209,512 net shells after retaining one public boundary box per
top-level call, rather than the full excess. It still walks and rebuilds String
prefixes, allocates String nodes, seals their tails, and dispatches reconstruction
continuations. In particular, an RFC seal removed at a temporary Tuple boundary
can reappear at the next String-tail store. Allocation-call counts are not
allocation latency; the prior warm counter run had zero added allocation misses.

Exact receipts:
`selfhost/build/phase69/product-transport-diagnostic01/report.json`
(`b3ad24ac0cb73ea1c9a688339bc9509cde60572496089ee99118dbd15abf48ea`),
`selfhost/build/phase69/map-island-diagnostic01/report.json`
(`3a8a0b7e7a17c4d7ec8e2b63377613dbcc732ea5e900810b8c711762bcce2d1f`),
and `selfhost/build/phase69/map-island-diagnostic02/report.json`
(`6d7126d81cfa5f50c8923bfc4562334486aa27d44146e86cb7d422fd4f831ecc`).
These results were read from root-produced files; this lane ran no targets.

The existing-product bridge also has a limited *additional* ceiling on these
families. The source/counter cross-check in
[`product-coverage23.json`](product-coverage23.json), produced by the read-only
[`product-coverage.py`](product-coverage.py), finds:

| Family | Emitted product workers | Workers with no call site | Ordinary entries for those unused workers |
| --- | ---: | ---: | ---: |
| Map | 12 | 12 | 279,185 |
| Tree | 4 | 3 | 17 |
| Lexer | 4 | 2 | 1 |

These are frozen compiler23 17-minus-1 counter differences, not current timing.
The three Map helpers already exercised by the two-word island account for
254,664 of the 279,185 entries (91.2%). Merely wiring additional *already
admitted* product workers therefore does not expose a large new Map region;
admitting richer layouts or eliminating reconstruction is a different feature.
Static call-site counting subtracts the exact generated declaration and
definition; the producer verifies source identities against the counter receipt.

## A general, checkable origin summary

Associate evaluated symbolic values with argument origins and field paths.
Matching a constructor gives its fields origins such as
`Field(root0, Constructor, index)`. Rebuilding the same constructor from those
exact field origins, in order and without changing any field, has origin
`root0`. A matched nullary constructor similarly establishes that the literal
nullary result is the original root's value.

A function summary says which result projections equal which argument values.
For example, `result.field0 = argument0` is a value-identity statement, not a
claim that a heap pointer survives unchanged in the old implementation. A helper
that returns `(Constructor(head, tail), observation)` propagates origins through
its arguments. A recursive call can use a proposed identity summary while one
body unfolding proves that every returning branch preserves it. Commit the
summary only when the whole recursive dependency component passes this check.
This is induction on a finite returning execution; it does not assume termination.

The analysis must track effects/demand separately. Constructor reconstruction
is removable, but a call that may diverge, fail, mutate or perform effects cannot
be discarded merely because its data result has the same origin. The initial
domain should contain pure constructor matches/builds, admitted scalar
operations, structural self recursion, and inlined or separately proved helper
summaries. Foreign calls, escaping closures, arrays/mutation, unknown calls,
dependent layout and ambiguous origin joins decline.

Bound symbolic unfolding, substitution growth and specialization count. Use
structural equality of explicit origin terms; neither annotations nor a
particular identifier are evidence of identity. Prove one or two original
roots, one structural recursive child per path, and a fixed small observation
result initially. This includes many list/tree observers without requiring
general interprocedural alias analysis.

## Lowering and ownership

Keep each original owned root in the generic adapter. The observer receives a
borrowed cursor whose lifetime is nested inside that owner. Constructor tests
and `term_peek` read fields; they neither take/free the parent nor retain/drop
borrowed fields. Forwarding a borrowed child extends its origin path while its
owning root remains live. Both RFC and immutable static nodes are safe to read
through the existing helper under this lifetime condition.

Use result-origin summaries to omit only the reconstruction part of the private
result. Return observation words; the adapter returns the retained roots plus
those observations in the existing public representation. For the two witnessed
traversals, this removes the reconstruction continuation and yields a direct
tail loop. If the residual observer is not tail recursive, retain scheduler
stack semantics rather than introducing unbounded native C recursion.

Borrowing needs explicit provenance in compiler-owned lowering context. It is
not equivalent to suppressing `term_keep` globally or using false static tags.
Successful matching must bind borrowed fields as borrowed; ordinary environment
partitioning must not emit `term_sink` for them. A field escaping independently
requires an owned copy/retain at that escape point or candidate refusal. Opaque
uses and writes are not initially supported. Existing typed layout/origin
machinery should be reused instead of adding a separate emitter for each
observer.

## Raw fallback is a separate obligation

The prototype checks immediate Nat bounds, exact String tag/representation and
visited U32 character fields. Unsupported values decline to the unchanged old
body before ownership has changed. This improves diagnostic confidence, but is
not a universal raw/foreign heap proof. Poll frequency changes, foreign-built
malformed fields may violate ownership assumptions, and reusing a root can
change native representation identity which arbitrary foreign code might see.

A production route needs either a genuine checked/proven constructor-origin
permission or sufficient runtime shape/lifetime guards, with ordinary fallback
for raw inputs. The source type annotation alone is insufficient. Do not use an
unsafe book-controlled marker as the capability. Error/demand tests must prove
that no earlier failing or diverging computation has disappeared.

## Current diagnostic arms

All source producers preserve reverse-edit identity and refuse existing output
directories. None compiles or executes:

- `root-preserve.py`: Map bit traversal only, output
  `selfhost/build/phase69/map-root-preserve23-prep01/program.c`.
- `root-preserve-strings.py` on compiler23 Map: String comparison only, output
  `selfhost/build/phase69/map-root-strings23-prep01/program.c`.
- The String producer on the Map-bit derivative: combined arm, output
  `selfhost/build/phase69/map-root-both23-prep01/program.c`.

Use the three arms independently before combining their claimed effects.
Returning unchanged roots leaves the original boxed public result, so this
tests reconstruction/borrowing rather than a second scheduler result ABI.

If the measured benefit is large, first implement a source-only identity-summary
checker and challenge it with unrelated recursive records, changed/reordered
fields, shared/static roots, early exits, raw tags, discarded roots, escaping
subtrees, effectful calls and deliberate nontermination. Only then connect
borrowed lowering. A 100–200-line bounded recognizer may be possible by reusing
existing term queries, but this is not a reliable estimate for the complete
analysis, lowering and semantic qualification; expect at least several focused
hours and possibly a larger change if current ownership bindings need extension.
