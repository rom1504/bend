# Query scaling and the already existing index

The append-only source02 passes the ordinary source checker and all14 finite
controls. All30 observations on actual checked KDef books return the same
selected values as the unchanged original queries. Source checking took8.979s
internally/9.620s guarded; the census took5.617s internally/6.542s guarded and
peaked at291,745,792 bytes. These are diagnostic costs, not speed improvements.

[Derived summary and identities](evidence01/summary.json) ·
[Complete census](evidence01/selfhost/build/phase136/query-census02/report.json) ·
[Independent source check](evidence01/selfhost/build/phase111/p136-query-api02/report.json) ·
[Resource guard](evidence01/selfhost/build/phase136/query-census-guard02/process.json) ·
[Original refused check](evidence01/selfhost/build/phase111/p136-query-api01/report.json).

## Prefix schedule

For each actual raw prefix, query every declaration name against that prefix:

| Prefix rows/queries | `f_find` row visits | Raw `lookup` row visits | Ownership top-level visits | Ownership child visits |
|---:|---:|---:|---:|---:|
| 16 | 136 | 136 | 241 | 345 |
| 64 | 2,080 | 2,080 | 3,903 | 2,608 |
| 256 | 32,896 | 32,896 | 64,575 | 10,672 |

The first two columns are exactly `n(n+1)/2`: the chosen query schedule exposes
quadratic repeated linear search. **All three programs and both book views share
these same Base prefixes.** They do not provide six independent generalization
results, nor prove that the real compiler executes this query schedule.

## Fixed16 constructor queries

The names are the first16 actual direct constructor names, identical across these
three fixtures: `Unit`, `False`, `True`, `LT`, `EQ`, `GT`, `Inl`, `Inr`, `Tuple`,
`Zero`, `Succ`, `None`, `Some`, `Fail`, `Done`, `Ready`.

| Context | Raw `lookup` visits | Actual prepared `lookup` visits | Index delegations | Actual `f_find` visits |
|---|---:|---:|---:|---:|
| Lexer | 7,622 | 16 | 16 | 7,638 |
| Closures | 7,262 | 16 | 16 | 7,278 |
| Map | 7,247 | 16 | 16 | 7,263 |

The normal prepared book **already routes lookup through its index**. The16
remaining visits are to its BookCache header; hash/Patricia/bucket work inside
the delegated operation is opaque to these counters, not zero. `f_find` ignores
that header and still performs roughly7,000 row visits for this schedule. Raw
and actual books preserve their respective original-query outputs, not an
invented equivalence between different lookup APIs or sentinel values.

Ownership visits94 top-level rows plus136 child rows on the raw book; the actual
book adds one ignored BookCache row per query, giving110 plus136. This particular
common-constructor schedule does not expose late-ADT or missing-constructor cost.
All14 controls separately exercise empty/missing/duplicates, first-False owner,
nonconstructor child shadow, cached children and Unicode.

## What follows—and what does not

The counts support investigating a known raw-list caller or its cost per visited
row. They do not measure actual compilation call frequency, native allocation,
reference-count operations, exclusive CPU share or elapsed time saved. The
separate [qualified QBE audit](../profiling/query-mechanics.md) identifies owning
KDef projections and reference transfers in these loops; it must not be converted
into dynamic allocation counts by multiplying every source visit by every static
callsite.

A useful next experiment separates two factors: exact indexing reduces visited
rows; a verified scalar observer over a held row reduces ownership work per
visit. Keep whole-query semantics, first-match/absence, return ownership and
BookCache fallbacks fixed, and inspect emitted code before claiming borrowing.
The existing parser scope index has a first-event/qualification invariant that
must be proved at the chosen caller. No broad global IR rewrite follows from
this census.
