# Boolean constructor membership

**Status: isolated source candidate, not executed or promoted.** This tests a
smaller alternative to the rejected prepared-world constructor index. The
experiment is [P65-008](../../experiments/phase65/P65-008-boolean-lookup.md).

## Observed waste

The actual selected B2 image emits `lookup`'s empty-list branch as a call to
`missing()`. That function constructs a KDef, a Nil constructor list and two
`atom("Absent")` values. Each atom constructs a KTerm, Nil children and Nil
removed names: **eight object constructions in the generated source** for a
value whose caller immediately reads only its kind. This is a source-level
count, not a claim that V8 retains every allocation after optimization.

The [leaf census](evidence/constructor-misses.json) reads sampled allocation
under exact selected-image `constructor_exists` ancestry:

| Case | Sampled union | Direct missing/atom/kt leaves | Constructor self leaves |
| --- | ---: | ---: | ---: |
| Numeric | 2.23 MB | 1.97 MB | 0 MB |
| Lexer | 26.12 MB | 3.15 MB | 20.08 MB |
| Map | 25.73 MB | 4.46 MB | 21.28 MB |
| Active Ray | 18.63 MB | 7.61 MB | 9.98 MB |

The remaining samples are in the shared lookup worker. Large constructor-self
attribution is consistent with inlining but does not establish which allocation
survives there. This supports a cheap source experiment; it does not predict a
26 MB reduction or a corresponding speed percentage. The data-only producer is
[`constructor-misses.py`](../../selfhost/tools/performance/phase65/cache-contract/constructor-misses.py).

## Bounded change

[`boolean-lookup-v1.patch`](../../selfhost/tools/performance/phase65/cache-contract/boolean-lookup-v1.patch)
adds twelve lines to `core/term.bend` and changes one consumed lookup in
`check/kernel.bend`. The [manifest](../../selfhost/tools/performance/phase65/cache-contract/boolean-lookup-v1.json)
pins both complete source copies and exact before/after hashes.

`lookup_present` returns False for an empty list. At each nonempty position, a
BookCache delegates to the unchanged `index_lookup` and tests its returned kind.
Otherwise the first matching name returns whether that row is non-Absent; only
a name mismatch continues. In particular, an Absent row masks a later same-name
definition, and a cache miss never continues into later event rows. Existing
name/kind projections preserve raw index variants and empty-name behavior.

The constructor's outer strict Boolean expression and recursive traversal are
unchanged. The first experiment therefore isolates missing-value elimination
and the smaller Boolean lookup interface. It does not assume short-circuiting,
reuse the rejected prepared index or duplicate the index lookup algorithm.
There is no host change, new public permission, artifact field or world version.

## Validation boundary

The correctness reviewer independently agreed with the list/cached fallback
contract before implementation and is preparing raw differential cases beyond
the ready-prefix domain. Those include first-match Absent masking, caches in
the middle of a list, non-Ctr kinds, empty names and exact full-hash collisions.
The candidate must also preserve complete real output and win the clean request
screen. No target has been executed by this agent; no correctness, speed or
promotion result is claimed yet.
