# Retain arity already computed during call analysis

This unapplied candidate adds 19 source lines. It keeps `jd_arity(book,d)`
unchanged and introduces no eager traversal, new index, mutable state or type.

The ordinary, non-native, non-foreign branch of `jd_calls_rows` already needs
the exact definition arity to initialize its body scan. The candidate evaluates
that query at the same point, uses the result for that scan, and retains it as a
tagged `JDArity` KTerm in the private JDCall row's type slot. Native/foreign rows
retain Absent and never gain a new arity query. Definition/edge/scan budgets,
source order and recursive evaluation order remain the original ones.

SCC construction carries this fact in a private `JDMember` node's children.
Final JDCall facts keep their existing component and bounce fields and retain
the arity child. Initial graph-row value children remain only Ref edges. No
source KDef, source type or declared arity is modified; the existing graph fact
index is reused. Internal graph facts deliberately have an additional child,
so they must be compared by their semantic fields plus the new arity oracle,
not claimed byte-for-byte identical internally. Generated modules must remain
fully byte identical.

Only emitter, ordered lowering and host-wrapper call sites use the new private
`jd_emitted_arity`. Call analysis still uses raw `jd_arity`, including recursive
named-call classification, so this candidate cannot save all 523 identity hits
seen in the Map diagnostic. A missing/native/foreign/manual graph fact falls
back to the raw query. Invalid graph contexts install an empty fact index.

The private helper's definition must belong to the completed context, as all
its normal callers obtain definitions by lookup or from that same selected
list. This is not a name-only memo for arbitrary public KDefs. Public jd_arity
continues to handle an arbitrary same-name definition independently. Normal
entry points rebuild calls facts after overlaying selected definitions; later
backend changes add only call/native analysis metadata, preserving source
lookup. Mutation of a returned private context through unrelated public book
operations is outside this helper's contract.

The checked-candidate controller is:

```sh
node --stack-size=4096 --max-old-space-size=1024 \
  selfhost/tools/performance/phase63/call-arity/compare.mjs \
  CHECKED_ATTEMPT NEW_PHASE63_OUTPUT [LATENCY_CATALOG_JSON [CASE...]]
```

It compares every actual private arity query with the unchanged raw query on
the exact same book/definition, counts admissions/fallbacks and lexical WNF
entries, then recompiles each complete module with reuse disabled. It also
checks invalid-context fallback and public raw arity with a changed same-name
definition. Default sources are Numeric and Map; the maintained 23-case catalog
can be supplied for broader coverage. This is a correctness diagnostic, not a
timing tool. Run normal fresh-worker B1/B2 timing only after it passes.

The existing SCC/arity/host tests and six real context controls remain useful.
Controls that compare full private call facts must account for the explicitly
added child; component leaders, order, width, bounce, emitted bytes, refusal
budgets and runtime results remain exact obligations. Keep the candidate only
if whole-request gain survives its extra fact lookup and retained metadata.
