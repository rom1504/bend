# Consume checked call annotations

`candidate.json` binds the isolated +49-line prototype. Root owns source
application and qualification. It adds five helpers and no types, leaving the
partial, overapplied, choice, tail-transfer and constructor paths unchanged.

`ka_app_spine_root` already stores each instantiated normalized function type on
the callee of its App. `j_call_spine` discards these annotations; the emitter then
reconstructs argument telescopes with `wnf` and substitution. The prototype's
exact-saturated branch retains a list of those existing App nodes in argument
order, uses each stored `All` quantity to preserve erasure, and emits its original
annotated actual. No argument/type tree is copied or globally cached.

Admission requires the exact two-child App, callee Ann, actual Ann and stored All
shapes, the correct terminal Ref name, and the exact argument count. Other forms
fall back to the old argument walker. The private helper assumes `xs` came from
`j_call_spine(t)`, as its only caller supplies; count equality is not a defense
against an arbitrary forged argument list.

The annotator obtains telescopes by substituting raw source actuals. The old
backend walker substitutes annotated actuals. Their semantic relationship is
the main proof boundary: nested annotations, literal/beta representation and
bounded normalization work can differ even when types are convertible. We must
compare exact ordered prefixes, values and ordinal counters, plus whole modules,
rather than assuming that a correct final numeric answer is enough.

Root runs under the standard CPU3 guard:

```sh
node --max-old-space-size=1024 --stack-size=4096 \
  selfhost/tools/performance/phase63/typed-spine/compare.mjs \
  CHECKED_ATTEMPT NEW_PHASE63_OUTPUT [LATENCY_CATALOG_JSON [CASE ...]]
```

The default is Numeric and Map. A catalog accepts `.cases[].source.file` and
optional case IDs. The append-only B1 derivative checks every selected result
against the original walker; recursive oracle calls bypass the new branch. It
also compiles each complete module with the branch disabled and requires exact
bytes. Counts separate accepted/fallback calls and actual/oracle WNF, substitution
and application-type lexical entries. Internal recursive SCC visits may bypass
those lexical wrappers, so these are query counts, not reconstructed-node counts.
Diagnostic clocks must never be used as latency measurements.

Review found no local extraction, ordering or sequencing blocker. Qualification
must include dependent type selection, beta/alias actuals, erased computations,
explicit ascriptions, borrowed arguments, exact versus partial/overapplication,
and no-annotation fallback. A high hit rate alone is insufficient: the unchanged
short clean loop must show a worthwhile request-time gain before selection.
