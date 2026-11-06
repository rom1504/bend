# Frontend choice: delay row-body materialization, not another indexed cache

Read-only audit at `fbdf8a0`, 2026-11-06. No compiler target, benchmark, native
build, production edit or new qualification was performed. The goal remains a
100s complete cold build of the same full Phase170 source; the current clean
experimental observation is180.677s. This document does not claim a new gain.

**Pick a private deferred pattern-row representation for the bounded frontend
experiment.** Keep a row's original body plus ordered substitutions while the
pattern matrix selects branches, then materialize that body's final form once.
This removes intermediate whole-body products, rather than changing the speed of
an accessor or adding another index. Retain the original final freshener,
checker, annotation and backend initially.

This is a credible experiment, not a frontend-only route to100s. The current
whole frontend envelope is only about68.27 diagnostic seconds, containing
necessary work. The measured cold gap is80.677s. A large overall result requires
this to compose with backend work elimination or faster generated execution.

## Evidence and alternatives

The latest [full caller capture](../phase171/runtime-callers.json) supplies these
disjoint wall-clock intervals. They are diagnostic compiler-only intervals, not
the clean source-to-executable time, and smaller windows have fewer than500
samples, so their physical-owner distributions are not quantitatively admitted.

| Responsibility | Diagnostic seconds | Actual remaining representation work |
|---|---:|---|
| Parse/load |30.522|Pattern-row body substitutions, flattening, qualification, final freshening and all other loader work.|
| Check/publication |19.339|Actual checking plus declaration/event bookkeeping; earlier publication improvements are already selected.|
| Proof report/ownership/entry |3.501|Necessary independent report and entry obligations; not optional frontend work.|
| Annotation/reach |6.421|Annotated terms and demand discovery; source checking does not make it redundant.|
| Checked layout |2.562|Consumes annotation facts under existing source-derived conditions.|
| Merge/ownership/erasure request |5.923|Annotated merge/index/bound, ownership view and erased-body facts.|

The largest first experiment with a manageable semantic boundary is the parse
row transformation. A fused annotation/layout/erasure producer is a more invasive
second choice whose *entire three-stage* ceiling is14.906s. A new semantic Book
would affect at most the19.339s check region before accounting for necessary type
checking, and Phase171 already narrowed publication history. It is not an
80-second opportunity on current evidence.

The source-grounded bendc lesson is useful but narrower than a speed promise:
its typed `Book` separates declarations, constructor map and event order
([pinned source](../../selfhost/build/phase158/current/check.bend#L273));
`book_set` changes the declaration map without our list/cache coherence update
([definition](../../selfhost/build/phase158/current/check.bend#L4765)). Its `Tm`
has typed fields rather than our generic tag/children encoding
([definition](../../selfhost/build/phase158/current/check.bend#L222)). But bendc
also parses again for emission: the checking driver and emission `P.file` are
separate. It does not demonstrate a single universal frontend representation.
Use [Phase161's audit](../phase161/frontend-architecture.md), not its few-second
self-build, as the matching architecture comparison.

## Where the selected row experiment removes work

[`ff_match`](../../selfhost/src/front/flatten.bend#L145) eventually selects only
the first row when its scrutinee list is empty. Before that selection:

- [`f_var_rows`](../../selfhost/src/front/elaborate.bend#L145) rebuilds each row
  and substitutes through its entire body at every consumed variable column.
- [`f_hit_row`](../../selfhost/src/front/elaborate.bend#L163) can substitute the
  original binder and then the scrutinized value, making two complete body
  traversals. Constructor rows can make one traversal.
- [`f_pattern_sub`](../../selfhost/src/front/elaborate.bend#L216) rebuilds generic
  children even when no variable matches. Its replacement helper recursively
  applies occurrence spans to the inserted value.
- [`ff_hit_done`](../../selfhost/src/front/flatten.bend#L198) preserves hit-before-
  miss evaluation/error ordering. Bodies in unselected rows or abandoned branches
  can already have paid substitution cost without becoming output.

The row's **patterns and quantity** drive constructor selection and marking;
none of `f_first_ctor`, `f_mark_rows`, `f_miss_rows` needs the substituted body.
That is the abstraction boundary. Updating pattern metadata can remain eager
while delaying body transformation. This is stronger than merely fusing the two
calls in one `f_hit_row`, and does not require changing KTerm for every compiler
pass.

## Minimal implementation shape

Add private checked Bend types, for example:

```bend
type P172Sub is Data:
  P172Sub{+id: U32, +value: KTerm}

type P172Row is Data:
  P172Row{+patterns: List<&2,KTerm>, +body: KTerm,
          +quantity: U32, +pendingReverse: List<&2,P172Sub>}
```

Exact types/signatures should follow the actual checker; the sketch is not a
checked implementation. It stores original body ownership, not pointers into
freed data. Persistent branch forks retain their own row/pending-list aliases.
No global mutable cache, hash-consing authority or runtime primitive is needed.

Replace the body of `ff_match` with conversion into a private row family. Add
private counterparts for `ff_match`, `ff_column`, `ff_split`, `ff_fields_done`
and `ff_hit_done`; retain `ff_fields`, `ff_lam`, `ff_miss_done`, `ff_flat`, the
checker and all external output representations. Calls back into `ff_flat` can
reenter the public `ff_match` wrapper for nested matches. Do not convert all rows
back into KTerm at each recursive step: that would retain the avoided work.

Private `var_rows`, `hit_rows`, `miss_rows`, first-constructor and quantity scans
operate directly on row fields. The pending operations must reproduce the old
order exactly. At the selected terminal row, reverse its small pending list and
apply a single composition walker. For a variable hit, apply only the *later*
operations to the replacement with the original occurrence-span semantics;
never reapply earlier substitutions to it. For an unaffected node, traverse its
original children once while retaining all non-child fields.

A useful first mechanism control can implement only composition of two
substitutions, using the original `f_pattern_sub` as reference. But do not spend a
full image acquisition on that narrow helper. The worthwhile source-to-output
prototype retains substitutions through the whole pattern-row decision, including
rows that disappear. Final freshening remains unchanged: it currently assigns
binder identities after pattern expansion, so moving its counter into parsing
without a separate equivalence argument is incorrect.

## Semantic contracts that cannot be approximated

1. Ordered substitution is not simultaneous substitution. Equal IDs and values
   referring to earlier/later substituted IDs must match the original chain.
2. `f_pattern_value` recursively propagates an occurrence's nonzero begin/end
   into the replacement; zero begin preserves existing origins. A later
   substitution must observe the spans produced by earlier ones.
3. Preserve `KTerm` removed-name lists, quantity, identity and spans; preserve
   `KLambda` presence metadata and literal fields. Replacing children must obey
   the exact `k_with_children` behavior, including malformed compiler-data tests.
4. Quantity-zero rows currently skip substitution. They must not allocate or
   force a pending replacement during terminal materialization.
5. Constructor/variable row ordering, quantity escalation, fresh field IDs,
   hit-before-miss ordering, first failure and the public complete result are
   unchanged. Delaying a pure body transformation must not delay an actual
   diagnostic-producing validation check.
6. All current supported source is checked. This changes when its pure
   elaboration products are constructed; it does not prune unchecked source.

For unsupported/malformed *public* row shapes, either preserve the exact generic
row information needed by the old behavior or retain the original public fallback.
Do not infer well-formedness from a private type constructor alone. The ordinary
parsed path and finite compiler-data API have different admission contracts.

## Cheap complete-path falsifier

Use the existing checked API assembly plus original and candidate actual
`f_load_graph_trace` exports. Adapt the iterative full-object comparator from
[`lexer-suffix-controls.mjs`](../../selfhost/tests/phase170/lexer-suffix-controls.mjs#L132),
which compares every field of `FLoadTrace`, rather than observing terms through
the candidate's own accessors. Include the full result book, origins, removed
names, trace/source ordering, errors and prefix admission flags where applicable.

Inputs:

- Retained39,333-byte real verifier source from Phase167, including its actual
  patterns, imports and Base policy.
- A pattern-rich actual compiler source module/closure, rather than generated
  arithmetic. Preserve logical paths and complete supplied-source identities.
- Existing constructor nesting, variable-column, quantity2, erased row,
  duplicate binder, template/law, local scrutinee error and source-span fixtures.
- Finite term controls for equal IDs, dependent replacements, zero/nonzero span
  precedence, Lambda/literal fields and irrelevant substitutions.

First require complete loader equality and direct finite substitution equality.
Then run the complete ordinary compiler request for verifier and Map through the
unchanged checking/backend path, requiring the exact existing QBE. Time cold
fresh-process requests with conversions, pending-list construction, selected-body
materialization and teardown charged. A local traversal count is supporting
mechanism evidence, not the speed score.

Reject before a native compiler acquisition if it eliminates few body traversals
or the complete load/request remains neutral. A meaningful complete-loader win
should transfer to a larger pattern-rich compiler closure before measuring full
S0. This avoids the Phase171 trap of repeatedly improving admission for a small
part of an otherwise unchanged complete consumer.

## Why not typed/indexed KTerm first

The Phase163 compact-App change reduced a local node's logical allocation model
from3 objects/15 words to2/8, yet native parse+check became4.7% slower on the real
645-declaration workload ([negative evidence](../../implementation/phase163/README.md#compact-terms-useful-negative-evidence)).
Adding variants and reconstructing compatibility children can introduce dispatch,
sharing and conversion costs. A typed representation is useful only if both its
producer and major consumers avoid legacy products.

A durable typed/indexed graph across parsing, checking, annotation and lowering
could remove much more work, but it would change many public structural contracts
and ownership lifetimes. A name/tag index alone cannot be assigned the whole
ownership sample share. Existing annotation indexing, cached erased bodies,
prepared Base and graph memoization already operate; adding another cache is not
that architecture. The deferred row type is the smaller test of the correct
principle: **preserve an operation's semantic intent until the consumer needs a
materialized term**, with exact legacy output at one boundary. If this cannot
pay for itself on actual patterns, use that negative result before attempting a
universal typed term migration.

## Experimental slice delivered

The implementation is in `selfhost/tests/phase172/deferred-pattern*.bend`.
Only the separate override replaces `ff_match`; common modules add private
`P172DPRow`/`P172DPSub`, a composed substitution walker and the five row-aware
continuations. The exact original `f_pattern_sub`, `ff_fields`, final freshener,
checker and backend are untouched. Baseline and candidate APIs include the same
common experiment/control code, with only the candidate applying the override.

`deferred-pattern-controls.mjs` compares20 full substitution observations against
the original sequential `f_pattern_sub`,24 full `FFlatten` observations between
the two independently checked APIs, and optionally the complete real-source
`FLoadTrace`. It contains transport/comparison only; the source algorithms remain
Bend. The controls include erased rows, metadata/literal/lambda preservation,
ordered dependent replacements, nested patterns/matches, early errors and a
fresh-ID wrap boundary. No native malformed input is executed.

The first two root-owned acquisitions caught law-fill syntax errors: explicit
types, then quantity markers, were repeated in the fill parameter lists. The
original files are frozen in `frontend-inputs01`/`frontend-inputs02`; the successor
uses bare-name fills as the existing `ff_match`/`ff_column` definitions do, with
quantities supplied by the forward laws. These are preparation failures, not
passing semantic gates. Root owns subsequent checks and timing, which must be
recorded separately before any success or gain is claimed.

The intended traversal change is from repeatedly materializing a body for each
substitution to visiting unaffected nodes once, scanning the pending chain at
variable occurrences and processing only the necessary later operations inside
inserted values. It cannot remove actual final pattern expansion. Pending-list
ownership and variable-chain scans may still erase the benefit; complete loader
and request measurements, not this complexity sketch, decide whether it pays.

The source05 pilot subsequently passed all20 substitution and24 flattening
controls and the complete actual-verifier loader comparison (682,767 values).
Single hosted loader timings were neutral (4.9673s baseline,5.0208s candidate).
These establish finite/output correctness evidence but no material speed gain.
The proposed retained Phase169 native checker falsifier was cancelled after
source audit found that its embedded fixture inputs contain no actual patterns;
its compiled implementation's own patterns do not confer input coverage. See
[the source audit and pending-scan analysis](frontend-checker-falsifier-audit.md).
No production change or native qualification is justified by this pilot yet.
