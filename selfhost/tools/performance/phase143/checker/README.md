# Private cold-checker discriminator

Status: source-only, **not source-checked, measured, qualified or installed**.
No original declaration is replaced. Parent is Phase142 indexed-source02
`15f5cada…817dac1`. Compose in this order:

1. `schedule-v01.bend`
2. `publication-v01.bend`
3. unchanged `phase140/checker/equality-v02.bend` (test observer; absent from parent)
4. `controls-v01.bend`

Exports: `p143cc_controls`, `p143cc_book`, `p143cc_schedule`, `p143cs_plan`,
`p143cp_check`, `p143cp_seed`, `p143cp_replay`, plus the original
`dg_check_world`, `dg_check_seed`, `check_declarations`, `book_cached` as needed
by the test harness. Internal log-loop helpers are not a new public checker API.
There are20 finite rows. Independent source review and actual checking remain
required; the finite tests are proposed controls, not results.

## Two independent costs

`p143cp_check(book,False{})` prepares the exact next same-name declaration once,
then uses the original publication operation. `True{}` additionally defers
deletion of obsolete childless Def rows. Both call unchanged ordinary checking,
inference, normalization, event diagnostics and specialization. Both return the
ordinary complete `DChecking`; no cached verdict or unchecked term enters it.

The schedule is a right-to-left immutable fold. It preserves first subsequent
occurrence, full-name hash collision semantics, and the BookCache lookup barrier
by resetting the suffix lookup index to that cache's actual index. The private
checker entry refuses implementation cache/index records as source events and
falls back to `dg_check_seed`; the standalone schedule observer tests the barrier
separately. No persistent index root is retained for every suffix: each record
holds only its definition and next-result KDef.

## Narrow publication invariant

The public experimental entry creates its own canonical cached initial world
with the original `check_declarations` and `kw_seed`. For a cached world, only a
childless Def replacing a lookup-visible childless Def may use append-only
publication. The authoritative cache index receives exactly the original
`index_set` update and the cache header is rebuilt exactly like `book_put`.
Only obsolete childless Def entries remain in the ordered tail. Other
publications first canonicalize the tail and then call original `book_put`.

Canonicalization keeps the first visible raw-tail row per name, preserving its
order. It uses `book_final_fast(reverse(tail),[])`; the reversal is essential
because that existing operation implements sequential last-publication wins.
The existing cache index/header is retained, not rebuilt in a different order.
Before returning success **or failure**, the complete result world is
canonicalized while preserving memo, fresh state, checked bodies, term, type,
uses, error, consumed count and diagnostic object.

The premise is an internally constructed cached world, not an arbitrary forged
BookCache plus inconsistent tail. Calling private workers with such states is
outside the experiment. No source-module privacy or cryptographic sealing is
claimed.

## Actual observer audit and remaining obligations

The source-level call-graph walk from `dg_check_events` reached435 named compiler
definitions. It is a syntactic audit, not a formal effect/alias proof. Relevant
book observations in the exact parent are:

| Observer | Source line | Why obsolete childless Def rows might be unobservable |
| --- | ---: | --- |
| `lookup` |5772|First BookCache routes through the updated index; tail not searched.|
| `norm_book_bound` |6943|Reads the retained cached bound; `norm_max_defs` raw traversal is the noncached fallback.|
| `kw_bound_book` |9383|Updates the cached bound/header while retaining the tail and lookup map.|
| `dg_family` |15840|Scans ADTs in order, ignoring childless Def rows; the ADT projection is unchanged.|
| `constructor_exists` |8925|Event duplicate checking uses the separate original `seen` book, which is never logged; childless Def duplicates would expose no children anyway.|
| `book_put` |6454|Internal specialization/template updates retain their original operation; filtering a logged tail remains first-visible-map equivalent.|
| `kw_restore_definition` |9199|Restores the captured world book on successful template checking; canonicalization must commute with this rollback.|
| Result/diagnostic transport |16025,16038|Every outward DChecking is canonicalized after preserving actual original failure/result fields.|

Constructor diagnostics call `dg_family` before the result returns, so an
unrestricted log of replaced ADTs would be unsound. Restricting the retained
obsolete rows to childless Def avoids that specific counterexample. A generic
world-overlay design is neither implemented nor justified here. The source
audit must still be challenged with specialization, template rollback, failed
checking, law fills, foreign definitions and unusual headers before integration.
All raw-book consumers and construction invariants need independent review;
20 small rows are not sufficient evidence for promotion.

## Cheap actual-work experiments for the coordinator

1. Acquire the appended checked API and run the finite controls. Keep the exact
   original functions in the same API; do not wire old names through the new
   path before differential testing.
2. Obtain actual post-freshening source declarations from a current frontend
   load. For500 and1000 real ordinary childless Def declarations, construct the
   original canonical declaration world once. Compare
   `p143cp_replay(book,updates,False{})` versus `True{}` for complete KDef-list
   equality. Time index updates, final materialization and destruction; this is
   only a publication ceiling, not checking throughput.
3. Compare schedule construction plus every exact suffix query on the *full*
   source event sequence. Truncating events changes the future-law relationship;
   do not accidentally compare a fabricated shorter suffix to real checking.
4. Run complete checker streams on independently valid500/1000-declaration
   sources with their required Base context; compare `dg_check_seed` and both
   experimental modes using the same supplied bound. If using prepared Base,
   do not claim this fresh-seed wrapper reuses Base: a separate source-bound
   entry for a genuine admitted prepared world is still required.
5. Only after state/error equivalence and a useful native proxy gain, integrate
   at the actual ordinary prepared-Base event boundary and compare a full cold
   request. Keep original final verification and the qualified compiler intact.

Negative controls must retain exact first later occurrence (not last), both
hash-colliding names, law/body duplicate diagnostics, empty names, cached suffix
barriers, malformed source-event fallback, non-Def publication, ADT family order,
template memo/freshness/rollback and complete failed KWorld. Diagnostic full
comparison is outside timing; no deep equality is added to the candidate loop.
