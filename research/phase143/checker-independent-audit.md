# Phase143 private checker publication: independent semantic audit

**Disposition:** no concrete semantic mismatch found for the narrow,
privately-seeded entry in the reviewed source. This is a source audit, not a
proof, test result, production admission or prepared-Base integration review.
Do not widen the change to global `book_put` or arbitrary `dg_check_events`
callers on this evidence.

Audit starts at repository HEAD `4fd100d5cac64e168d0288cde0db04922e858107`.
Parent compiler is Phase142 `indexed-source02`, SHA256
`15f5cada2710119cce19a0cfe961c21f61edc5f0b048f90359090a0c1817dac1`.
Reviewed candidate snapshots:

| File | SHA256 |
|---|---|
| `schedule-v01.bend` | `8543fbea64c12b90ff4204e6955dcdd2cc384998cdf18bc46854d44d23ef08ad` |
| `publication-v01.bend` | `a7f5daa2e6d16884a027cee0c256c6d74d3ae399e90d97ef3d7934152c928026` |
| `controls-v01.bend` | `ec1325f73d815147ae1de11fbca08648467d7f3157b455c2e0bd7d4792e9ef8e` |

These files are under
[`selfhost/tools/performance/phase143/checker`](../../selfhost/tools/performance/phase143/checker/README.md).
Controls may be extended after this snapshot. No compiler/target was executed
by this reviewer, and no candidate source was changed.

## The contract that makes the proposal plausible

Let `C(book)` retain the original cache header/index and keep only the first
raw-tail definition per name, in original first-visible order. The proposal
requires all of the following, not merely equivalent name lookup:

1. The private loop starts from the original canonical `check_declarations`
   result, with the original `kw_seed` bound and independent `seen` event book.
2. Its cache header and exact index representation equal the original loop's
   header and index after the same updates. `p143cp_logged` uses the same
   `index_set` sequence and same header fields as `book_put`; it does not
   rebuild the index in a different order.
3. Applying `C` to the private raw book yields the original raw book. The only
   additional obsolete rows are childless `Def` rows; ADT rows and their relative
   order remain unchanged.
4. Every in-loop observer sees only facts invariant under `C`, including error
   construction and freshness. Every outward result applies `C` while retaining
   all other result/world fields unchanged.

The proposed functions satisfy the local update algebra under these premises:
logging prepends a replacement and updates the same cache entry; canonicalizing
later removes exactly the old rows that ordinary publication removed earlier.
For all other publications, the candidate canonicalizes before ordinary
`book_put`. The reversal in `book_final_fast(reverse(tail),[])` is essential:
that helper implements sequential last-publication wins, whereas the raw book
has newest rows first. Keeping the cache index unchanged also preserves exact
hash-collision bucket order.

This is a restricted representation equivalence, not a general permission to
leave obsolete records in every compiler book.

## Independent caller inspection

A lexical named-call traversal from the original `dg_check_events` reached435
compiler definitions, agreeing with the implementer's independent count. It is
not a formal callgraph/effect proof: indirect calls or future source changes
still require review. Relevant bodies were inspected in the exact combined
parent source; line numbers below identify that source.

| Observation | Lines | Audit result |
|---|---:|---|
| `lookup` / `index_lookup` |5772,6427|A leading cache is authoritative. It does not fall through to obsolete tail rows on a miss. Same updates preserve definition/absence and first-match semantics.|
| Event history / `event_error` |8916,16011–16027|`seen` remains an ordinary separately updated book. Duplicate declaration, constructor and law-signature checks do not consume the publication log.|
| `dg_family` |15840|This diagnostic scans raw ADTs and constructor children. Keeping only stale childless Defs preserves its answer and ADT search order. Logging obsolete ADTs would invalidate this argument.|
| `constructor_exists` |8925|Used in event checks on `seen`; childless Def rows contain no constructor to expose. Constructor payloads are not discarded or overwritten by a deferred ADT update.|
| `norm_book_bound` |6943|Reads the leading cache bound directly. The raw `norm_max_defs` fallback is not used for an internally retained cached world.|
| Fresh ID operations |9359–9399|Known/deferred floors use the preserved world/cache bound and roots. `kw_bound_book` preserves the index/tail and updates the same bound field. Deferred/exhausted behavior still needs explicit controls.|
| Template-local insertion |9095|Uses original `book_put`, which removes every matching raw row and preserves the authoritative cache; it does not publish through the new shortcut.|
| Template restoration |9199|On successful template checking, `kw_restore_definition` restores the captured book. Canonical projection commutes with restoring that captured book; memo/fresh/checked retain original behavior. Failure retains its actual partially updated world.|
| Instance declaration/completion |9971–9979|Original `sp_live_body`/`sp_live_done` retain their index updates, memo transitions, generated names, fresh IDs and checked-body publication. They may carry stale unrelated Def rows until outer canonicalization.|
| Final checking result |candidate `p143cp_result`|Both success and failure preserve term/type/uses/error/consumed/diagnostic; only the world book is canonicalized. Memo, fresh state and checked bodies are untouched.|

### Raw-book escape through specialization

`sp_public`, `sp_assembled` and `sp_source_book` are **not reachable** from the
original `dg_check_events` named-call closure. In addition:

- `sp_assembled` (9915) reverses `kw_checked`, not the raw world book. That list
  is unchanged by the optimization.
- `sp_public` (9925) receives an already returned checker result. Its failure
  branch uses `sp_source_book(kw_book(...))`; the candidate must canonicalize
  before this boundary, as its public entry currently does.
- The driver success consumers at37376/37389 also use `sp_assembled` after
  checking has returned.

No in-loop specialization consumer was found that publishes the logged raw
book directly. Calling the private `p143cp_walk` or `p143cp_next` as a public
replacement without the canonicalizing wrapper would change this conclusion.

## Suffix schedule, laws and shadowing

The right-to-left schedule installs each earlier definition over the suffix
index only after saving that definition's suffix lookup. Therefore `next` is
the **first later** same-name declaration, exactly as raw `lookup(rest,name)`.
It is not the last definition with that name. Full-name comparison handles hash
collisions; resetting at a `BookCache` row preserves the standalone schedule's
lookup barrier.

`p143cs_mode` changes only absent Def signatures and delegates to unchanged
`signature_fill_mode`. Publication remains conditional on the same suffix
absence test. Law/body pairing, signature mismatch and duplicate diagnostics
continue through unchanged `event_error`, using the unlogged history.

The experimental fresh-seed entry rejects cache/index records as events and
falls back to the original `dg_check_seed`; it does not accept an arbitrary
caller-supplied sentinel whose index disagrees with its tail. Foreign Defs,
empty names and unusual KDef kinds still need full-state differential controls;
lookup-only agreement is insufficient.

## Important integration boundary: actual cold prepared-Base path

The normal compiler has a distinct hot entry:

`base_prefix_world_resume_state` (10425) → original
`dg_check_events(suffix,world,kw_bound_book(seen,bound))`.

It preserves prepared Base state, installs suffix declarations, restores the
historical prefix/suffix raw-list order, and carries adjusted fresh/check state.
`base_prefix_world_check_admitted` (10508) separately handles full hash
collisions by selecting the historical replay route, because exact bucket
order is observable.

The reviewed `p143cp_seed/check` creates a fresh canonical world from scratch.
It therefore does **not** establish that replacing only `dg_check_seed` improves
the prepared-Base cold workload, and does not by itself admit an arbitrary
existing world. A private prepared-world wrapper needs its own producer binding,
state/order/cache invariant and complete-result differential controls. Preserve
the existing collision fallback and original raw API path. This is the main
integration restriction; it is not a discovered mismatch in the present proxy.

## Decisive controls still required before widening scope

The reviewed controls cover empty/duplicate/colliding schedules, publication
order, basic successful and failed books, constructor diagnostics and a law fill.
That is useful, but does not yet validate the dangerous interactions above.
Prioritize these bounded complete-`DChecking` comparisons:

1. Successful template instance creation after several logged publications,
   repeated same instance/memo reuse, and nested instantiation.
2. Template failure after local binder/instance creation, with exact retained
   failure world, memo, fresh IDs, checked list and diagnostics; separately test
   successful template rollback.
3. Supplied bound near `4294967295`, known/deferred fresh state and exact
   exhaustion errors. Include syntax IDs rather than only an empty book.
4. Law signature then fill with differing binder identities, mismatch and
   duplicate-fill errors, with logged definitions between the events.
5. Foreign definition, ADT/non-childless publication and constructor-family
   diagnostics after prior logs, ensuring fallback materialization is exercised.
6. At least257 retained rows with distinct and colliding/empty names, exercising
   the indexed `book_final_fast` branch rather than only its small-list path.
7. Cache/index-valued event refusal to the untouched legacy entry. An inconsistent
   arbitrary cached world must never be silently admitted to private workers.
8. For prepared-Base integration, exact whole-world comparison of normal,
   colliding-name, failed and template-bearing suffixes through the existing
   admitted/fallback paths.

The existing `p140ce_checked` observer is appropriate: it compares complete
KChecking fields, index trees, raw order, memo, fresh state, checked list and
all diagnostic fields. Keep these comparisons outside timed candidate work.
No claim is made here that any of these new controls has run or passed.

## Recommendation

Proceed with the bounded private proxy and its stronger controls. Keep schedule
and publication modes separate so either can be rejected independently. Only
integrate into the real prepared-Base boundary after equivalent complete-state
results and useful measured gain. The best simplification is the small invariant
above; a general mutable-world cache, global book override or broad checker
rewrite would add obligations without evidence of benefit.

## Follow-up: private prepared adapter and bounded hosted screen

`prepared-v02.bend` was reviewed separately after the initial audit; its SHA256
is `4b7b8f4f4d5ea1034921016f19906577742167f32bb1156d6c7c7c530b9c6b69`. `p143cb_resume_state` reproduces the original
prepared declaration installation, prefix/suffix ordering, adjusted bound, fresh
state, checked definitions and seen history, then wraps the private loop with
canonicalization. Original admission and hash-collision replay remain intact.
`p143cb_program` retains the original driver finalization, and the optional
`p143cb_plan_loaded` mirrors the existing planner's parse-error boundary. No
concrete mismatch was found in this extension. Its external producer binding
still requires the real authenticated seed/load pair.

The six proposed prepared controls compare complete states, but equality alone
cannot establish that their optimized branch ran or that a supposed valid case
succeeded: both sides could agree on fallback or error. Intended-hit fixtures
should assert admission/regularity/hash-disjointness and expected check status;
the forced-unready case should explicitly remain a fallback. This request was
sent to the implementation owner. No prepared control was run by this reviewer.

The host observer `checker-screen-v01.mjs` takes a checked API receipt and fresh
output directory; it never hardcodes a candidate API. It compares synthetic
100/500/1000-definition books using the original, scheduled-only, and scheduled
plus logged-publication modes in three balanced orders. Whole `DChecking` data
and input immutability are compared outside timed calls; the Bend full-state
observer is also used when exported. Early failures and partial measurements
are retained, and a25-second soft budget is checked between synchronous calls.
An outer guard must supply the hard deadline. These are hosted diagnostic
measurements, not native or actual compiler-stream speed claims.

Syntax checking and offline observer controls passed: iterative10000-node data
traversal, rejection of changes to error/fresh/memo/book/diagnostic fields, and
refusal of unsupported Map objects. These controls exercised host comparison
code only; no Bend compiler/API target was executed.
