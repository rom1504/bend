# Phase175: retain the private publication log across ordinary ADT updates

Status: experimental Bend override and controls prepared; no target was run by
this author. No selected compiler, public Book operation, independent verifier,
or production build selection is changed. Source audit supports a bounded
experiment, not a correctness theorem or performance claim.

## Why investigate this next

`profile.json` retains a Phase171 diagnostic capture: parsing/loading takes
29.545s and checking/publication takes **19.027s** on that input. The latter has
593 samples; active-owner attribution includes `index_remove` (32),
`book_final_fast` (11), and `book_final_scan` (8), while 338 samples have no
recovered active owner. Physical leaves include destruction, reclamation,
String equality, and allocation. These are overlapping contextual samples,
not additive CPU times. The capture is not a clean Phase174 timing.

The 19.027s interval is the absolute ceiling for this intervention on that
capture. A >3s saving is plausible enough to test because every dirty ADT
boundary currently repeats whole-book reversal, name validity checking,
deduplication and membership-index construction. It is **not established** by
the sample counts. This cannot independently explain the remaining gap from
~188s to 100s. The cheapest falsifier is a clean, identical-input full checking
comparison, before rebuilding a complete native compiler.

The source audit identifies a category of avoidable work rather than a faster
helper: `selfhost/src/check/publication-reuse.bend:p156cp_put` canonicalizes its
dirty childless-definition log before every ordinary fallback publication.
The subsequent `book_put` already removes all old rows for the updated owner.
The canonicalization need not remove unrelated, observer-invisible childless
rows at that point.

## What changes, and what does not

`selfhost/tests/phase175/parser-publication.bend` replaces only `p156cp_put`.
Its original childless logging branch is unchanged. At a cached dirty fallback
with an ordinary non-BookCache definition, it calls unchanged
`book_put(book, definition)` and retains `dirty=True`. All other fallback cases
use the original path. The existing outward `p143cp_result` remains mandatory.

This does **not** log an obsolete ADT. Ordinary `book_put` removes every prior
row for that owner before prepending its replacement. The rejected Phase155
blanket-ADT log retained A{Old} after replacing it by A{New}, exposing Old to
constructor lookup. That exact counterexample is covered by a literal control.

This also differs from selected Phase171 event-history pruning: Phase171
changes the separate private `seen` history, whereas this experiment changes
only the checking world's already-private publication representation.

## Restricted representation argument

Let C be the actual `p143cp_canon`: retain the cache header/index, reverse the
raw tail and call unchanged `book_final_fast`. Its effect is to keep the first
(latest) raw owner row, **in first-visible raw order**. It is not simply a
reversal and it must preserve exact collision-bucket/index representation.

The existing private producer establishes:

1. A coherent, authoritative leading BookCache with the same exact index,
   bound, and header as the ordinary checker after the same updates.
2. C(private book) equals the ordinary ordered book.
3. Extra obsolete rows are childless Defs only. Both the new definition and
   the indexed previous definition must satisfy `p143cp_childless` before the
   unchanged logging branch can create an obsolete row.
4. ADT and other constructor-bearing rows remain current, unique by owner,
   and in the same relative order as the canonical reference.

For an ordinary definition d under that producer invariant:

    C(book_put(private_book, d)) = book_put(C(private_book), d)

Both sides run the same `index_set`, including its collision-bucket order,
and reset the same cache fields. `index_put_rest` either removes **all** rows
for d's name or skips the removal only on an authoritative nonempty-name miss.
The latter cannot hide an old row under the producer invariant. Empty names
retain the original filtering path. After owner removal, prepending d commutes
with first-visible canonical selection and preserves relative order of every
other live owner. Extra rows for unrelated names remain childless Defs.

This is a source argument about a private representation relation. The
experiment does not admit arbitrary inconsistent cached API worlds or change
public `book_put`, `dg_check_events`, source checking, or checker semantics.

## Observer and failure audit

| Observer | Why the relation is preserved |
|---|---|
| `lookup` / `index_lookup` | Same authoritative index; no fallback to stale raw rows. |
| `dg_family` | Scans ADT rows and their children; extra childless Def rows are invisible, and ADT search order is unchanged. |
| `constructor_exists` | Extra rows have no children. The ordinary owner update still removes obsolete ADT constructors. |
| `event_error`, law/fill and duplicate-constructor checks | Use separate `seen` history, still updated through selected `p171s_put`; it is unchanged. |
| Fresh IDs / `norm_book_bound` | Read the same cached bound and world fresh state. No bound or memo policy changes. |
| Template-local `book_put` | Removes all matching owner rows; the same canonical algebra applies. |
| Successful template restoration | Restores the captured book; canonical projection commutes with restoring corresponding captured books. |
| Specialization / instance completion | Existing index updates, memo, fresh IDs and checked-body lists are untouched. |
| `kw_checked` / `sp_assembled` | These use the separate checked list, not the raw publication tail. |
| Success **and failure** | Existing `p143cp_result` canonicalizes the world book and preserves all other KChecking and diagnostic fields. |

`count_open` is a real non-invariant observer: stale Absent definitions could
change it. Current call sites are `check_open`, then external driver finishing
and prefix-state preparation. They must remain after canonicalization.
Similarly, `sp_public` may expose a failure book only after checker return.
Calling the private worker without its existing wrapper, or adding a new raw
book observer inside it, would invalidate this audit.

The retained Phase143 independent audit provides the original private-world
contract and template/failure analysis. A separate Phase175 reviewer also
checked the changed fallback algebra and found no source-level blocker. Neither
review is a formal BendTT proof or an executed control result.

## Prepared controls and decisive gates

`parser-publication-controls.bend` supplies:

- Frozen original and candidate transitions, comparing complete canonical
  books (including header/index/order) and raw family/constructor observations
  at **every** update prefix.
- Interleaved childless and ADT updates, owner replacement, constructor-family
  order, uncached/empty inputs, empty names, FNV-colliding names, and >257 rows.
- Literal stale-ADT expectations: Old absent, New present, Old family empty,
  New family A on both sides after replacing A{Old} with A{New}.
- Actual `p156cp_start` complete DChecking observations, not merely the copied
  transitions; >257-definition variants include success, duplicate constructor,
  duplicate fill, missing reference, constructor error, and exhausted bound.
- `p175pd_text` for complete parsed-error/checker observations of standalone
  source without imports; imported fixtures instead require the real prepared
  Base path described next.

`parser-publication-cases.json` inventories six actual source fixtures with
257 ordinary definitions, followed by ADT publication, success/error paths,
and template success/failure. They import Base and must run through the existing
authenticated prepared path. Assert actual compact-path admission and expected
success/failure; equality between two errors or two legacy fallbacks is not a
hit. Compare complete DChecking where available and full stage/request values,
not only accepted/rejected or a digest.

Recommended order:

1. Independently source-check baseline and isolated override with controls.
2. Compare complete finite transition/checker results, including exact raw
   canonical order/header and all failure-world fields. Confirm literal stale
   ADT answers and success statuses of positive controls.
3. Run large prepared fixtures through check/request boundaries with actual
   compact admission, keeping independent ordinary checker comparison.
4. Measure identical fixed compiler-source check requests using baseline and
   candidate. Include parse/preparation policy and final canonicalization on
   both sides; separate clean timings from diagnostic attribution.
5. Only on a material whole-request win, measure allocation/memory retention
   and transfer to the native frontend; then consider full cold qualification.

The main falsifier is that deferred rows make subsequent `index_remove` scans
and final canonicalization more expensive, offsetting removed intermediate
flushes. Maximum retained dirty rows also increase. Do not infer speed from
fewer canonicalizer calls or skip cleanup/destruction when timing. Reject the
candidate if exact state differs, memory grows unacceptably, or complete
checking cost does not materially improve.

No production promotion or successful performance result is recorded here.
