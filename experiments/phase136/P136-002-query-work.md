# P136-002 — Repeated rows and owning projections

Status: mechanism observed; automatic optimization not implemented or promoted.
[Mechanics](../../implementation/phase136/profiling/query-mechanics.md) ·
[Profile](../../implementation/phase136/profiling/README.md) ·
[Query controls](../../implementation/phase136/baseline/query-results.md).

Hypothesis: raw definition queries pay both unnecessary list traversal and
ownership transfer for fields that their immediate scalar consumer never uses.

The exact qualified native object yields11,569 usable samples at32ms, zero loss
and99.68% main-thread CPU coverage; complete compiler QBE matches the independent
oracle. nc_ctor_owned/lookup/f_find label18.16% of active-context samples; their
drop/fade intersections occupy9.21% of all samples. Physical drop/fade total29.74%
overlaps these contexts and must not be added. Contexts are not complete stacks.

Exact generated loops keep a row, take nine fields, and sink eight unrequested
fields for dk/dn. An ordinary non-BookCache lookup performs two such projections.
The held original forces reference-transfer churn on these specific paths;
other cleanup can still destroy graphs. These loops already avoid generic
scheduler recursion. Fourteen checked controls and thirty logical-query rows
confirm first-match/cache/shadow semantics and quadratic raw prefix visits.
Shared Base prefixes are not independent benchmark transfer; no dynamic query
frequency or event count was measured by that census.

Decision: reuse Phase131's already positive wider-record/scalar-consumer
experiment on a real current hot caller before building a new optimizer pass.
Compare reduction in row count separately from cost per visited row. Source '+',
a single width-bound change, and fewer field loads alone are insufficient.
Require held-root lifetime, exact layouts, ownership/fallback gates and unrelated
transfer. No whole-compiler saving is demonstrated yet.
