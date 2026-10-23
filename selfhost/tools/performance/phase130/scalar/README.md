# Scalar comparison source ceiling

Current inputs: `cases-v05.json` (`scalar-order-baseline`,
`scalar-order-scalar`) and `semantic-controls-v05.cases.json`
(`scalar-order-semantics`). These are ordinary Bend programs; the production
compiler and its borrowing contracts are unchanged.

Pinned Base `String.order` projects `Pair.snd` from `String.cmp`. That comparison
returns the original roots and a scalar Cmp inside two nested products. The
selected compiler already borrows the traversal but still transports the
product. The candidate ordinary source computes just the scalar ordering using
safe structural recursion. `Char.cmp` uses `U32.cmp` on its codepoint fields, so
the scalar source retains the same comparison semantics.

The two benchmark sources differ only in `p130s_query`: Base `String.order`
versus `p130s_order`. Both include the same declarations, retained corpus and
timing loop. Ten comparison pairs cover equality, aliases, strict prefixes,
early/late mismatches, shared suffixes, NUL, astral Unicode and E000 versus10000
(distinguishes codepoint from UTF16-unit ordering). The timed inputs are held
outside the loop. Unique inputs and a retained shared suffix/alias are separate
ordinary controls.

Python preparation only composes source and freezes an independent Unicode
lexicographic oracle; it does not compile Bend or imitate a compiler pass.
Digests fold the full code vector modulo2^32. Separate semantic controls print
every comparison code for prefix lengths0/1/17, then exercise16K shared equal,
aliased and prefix roots and observe a retained root afterward. Expected output
is69 lines. The finite code vector is the semantic screen; timed checksums do
not replace it.

Use the existing Phase128 checked-B1 API and request emitter:

```sh
P118_CASE_MANIFEST=selfhost/tools/performance/phase130/scalar/cases-v05.json \
P118_RUNTIME_REPORT=selfhost/build/phase128/runtime-borrow01/report.json \
node selfhost/tools/performance/phase128/emit-entry.mjs \
  selfhost/build/phase111/p128-native-api02/report.json \
  selfhost/build/phase128/native-source02/manifest.json \
  selfhost/build/phase118/p130-scalar-ceiling-emit05 \
  scalar-order-baseline scalar-order-scalar
```

Only the coordinator runs emission/build/execution in its controlled lane. A
fresh output directory is required. Timed arguments are `-- repetitions warmups
prefix_size reserved`; prefix1 and64 separate short-query transport from a long
traversal. Expected timed checksum is repetitions×digest modulo2^32. Inspect
selected reader/adaptor callsites and actual machine code; a scalar source
fallback is not evidence that borrowing admitted the intended path.

This is a source-level opportunity discriminator, not proof of an automatic
transformation or a compiler-wide speedup. The Phase129 comparison exposure is
roughly7–9% in lexer/Map active contexts, and these contexts overlap other views.
Do not extrapolate kernel gains directly or add overlapping percentages.

## Preserved failed inputs

- v01 matched roots after matching a later accumulator binder; parser rejected
  the binder order.
- v02 moved the accumulator first; safe checking rejected the now nonstructural
  first recursive argument.
- v03 reused the safe Phase89 structural-first multi-match; its comparator passed
  those gates, but the corpus used `List<&2,String & String>`. Base `Pair` has
  quantity1/1 and Type kind, incompatible with that Data list.
- v04 uses `P130SCase is Data`; the retained constructor bindings then required
  explicit annotations. v05 annotates every retained local String/corpus value.
  The computation and independent expected results remain unchanged. Earlier
  sources, manifests and oracles are untouched.

These are fixture failures, not demonstrated production compiler regressions.
The coordinator's immutable emission reports retain exact rejection messages.

## Conditional next step

If this ceiling pays off, extend existing private-reader summaries with the
already-proved result wrapper and result binding ID. Seed only from actual
admitted emitted readers. A call would execute the scalar reader eagerly, then
instantiate its result wrapper as virtual NO constructors using original held
argument origins plus the fresh scalar result. The existing Pair projection can
then discard virtual fields without boxing or scheduling product transport.

The existing product observer admission already proves its root reconstruction
and bounded Ctr/Var wrapper. Preserve exact binding-ID substitution, disjoint
result/fresh IDs, held-root provenance, scalar result typing, helper DAG ordering,
unchanged owning fallback, source request identity and the final independent
verifier. Never materialize a virtual borrowed root as a newly owned value.
This is a small extension of the existing observer representation, not a new
general IR. No implementation has been made before the ceiling measurement.
