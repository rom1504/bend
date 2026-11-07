# Frontend architecture audit after Phase177

Code reviewed at `709db8c`. This is a source audit and proposed direction, not
a new optimization experiment. Two bounded independent reviews examined the
parser and semantic preparation. No compiler, runtime or qualification campaign
was run for this audit; the maintained compiler was not changed.

## Assessment

A targeted refactor is justified. The most useful target is the boundary between
checked definitions and backend preparation, not reorganizing files or adding a
universal SSA representation. Several optimizations now recover facts that an
earlier stage knew, encode them inside generic terms, and later decode them again.
We should replace a complete producer/consumer path and remove its old work.

The canonical maintained QBE source has **68,499 physical lines**, 8,488 ordered
declarations and 3,174,925 bytes. This includes comments, forward signatures and
all manifest-selected modules; it is not executable statement count or reachable
QBE code. The source contains 46,721 backend lines (14,743 JS, 7,910 native,
21,982 QBE, 2,086 common). Core/check/front/load together contribute 16,244 lines.
Another 2,360 lines come from explicitly included control modules. Removing
those changes self-build input; it would not demonstrate a faster same-input
compiler. Unreachable output functions and unchecked input declarations are
different things.

## Concrete structural problems

1. **The same types represent too many stages and meanings.**
   [KTerm and KDef](../../selfhost/src/core/term.bend#L5) encode syntax tags and
   declaration kinds as strings. `KDef` also represents lookup tree nodes, and
   generated facts are ordinary KDefs with special names/kinds. A book is a list
   that may begin with a [BookCache sentinel](../../selfhost/src/core/index.bend#L321).
   Existing lookup is already indexed on this path; recommending a hash table
   would miss the current implementation.

   The especially revealing example is [constructor-facts.bend](../../selfhost/src/back/common/constructor-facts.bend#L101):
   a real `P144OFacts` value is encoded as a `KTerm` under a fake native constructor
   declaration, inserted into the book's cache carrier, then recovered by checking
   tags, names, versions, quantities and placeholder fields. This preserves public
   malformed-input behavior, but makes internal contracts implicit and expensive
   to compose. A private typed context could separate definitions, indexes and
   semantic facts without changing the public compatibility boundary.

2. **Checked information is reconstructed, then materialized for consumers that
   often need much less.** [native-plan.bend](../../selfhost/src/host/native-plan.bend#L143)
   checks the program, prepares its context, annotates reachable definitions,
   validates layout and constructs a native request. [annotate.bend](../../selfhost/src/check/annotate.bend#L267)
   performs normalization, substitution and type reconstruction, wrapping nodes
   in `Ann` terms. The ownership consumers in
   [ordered-index.bend](../../selfhost/src/core/ordered-index.bend#L99) use types at
   variable occurrences, particularly duplicated variables, while traversing the
   larger tree to find them. [sharing.bend](../../selfhost/src/back/native/sharing.bend#L63)
   combines that source tree with an erased/compact body. Layout separately walks
   the annotated body through [p142j_def](../../selfhost/src/core/indexed-reach.bend#L26).

   There is also an immediate producer/consumer pair in
   [p143nr_visit](../../selfhost/src/core/query-ownership.bend#L56): construct an
   erased body, then traverse it again for `nc_refs(body)`. These are concrete
   opportunities to remove traversals, not proof of their timing contribution.

3. **Local optimizations increasingly require parallel helper families.**
   The Phase177 parser carries one resolved declaration through six copied
   continuations in [compact-parser.bend](../../selfhost/src/front/compact-parser.bend).
   The normal entry now uses that path, so deleting the unused old chain alone
   would not remove executed parser work. The maintenance issue is duplicated
   semantics. An explicit declaration-parse state can carry the resolved local,
   resolved prior, scope and parsed signature through one implementation.

   Parser state must preserve raw local events versus bodyless headers and the
   distinct precedence of scope indexes. The existing indexes cannot simply be
   merged or substituted for the raw local declaration. Unknown direct API inputs
   must retain the original fallback; internally published coherent state can have
   a stronger contract.

   Concretely, [f_decl_local](../../selfhost/src/front/declarations.bend#L455)
   uses an index miss to skip searching, but an index hit still searches the raw
   book. [f_ctor_lookup](../../selfhost/src/front/validate.bend#L75) also walks raw
   definitions despite a maintained constructor index. A publication-owned parser
   environment could maintain those exact facts once. It must preserve the main
   index built from [reverse(prior)](../../selfhost/src/load/modules.bend#L256)
   versus the prior view built from [prior](../../selfhost/src/front/scope-lookups.bend#L21);
   they intentionally select different duplicate occurrences. Charge new index
   update and destruction costs against the searches actually removed. The old
   frozen source census models roughly one million remaining local-law row visits
   and 2.18 million constructor row visits, not a timing or a new measurement.

## Recommended refactor

Introduce a private **per-definition compilation product**, initially at final
semantic preparation, with only fields demanded by actual consumers:

```text
RuntimeDefinition
  erased body
  ordered runtime references
  ordered layout obligations / open-array markers
  sparse variable-type observations needed by ownership
  scalar eligibility facts
```

This is an interface sketch, not a proposed literal wide runtime record or a new
global node store. Reuse existing representations and ownership rules where they
work. A larger record that loses direct-worker admission could be slower.
Preserve semantic legality, independent final validation and backend profitability
as distinct concerns.

The end condition is that selected consumers no longer require the complete
annotated tree. Merely returning this product beside all existing trees and
running the old traversals would repeat the unsuccessful earlier architecture.
Full retirement requires handling the public `NR_Request.source` contract through
an explicit private route or compatibility adapter. Do not silently change it.

Start with **one consumer**: emit the exact ordered layout-dependency/marker
sequence while annotating and consume it in `p142j_def`, retiring its body walk.
Alternatively fuse erased-body production with ordered reference collection;
that has a smaller contract but likely a smaller ceiling. Charge all preparation,
allocation, retention, destruction and validation, not just the removed pass.

The first acceptance gates are complete old/new values and diagnostics, actual
native worker admission, then total producer-plus-consumer timing on the existing
small/medium compiler inputs. Only a substantial saving in the containing stage
justifies extending the product to ownership/scalar consumers. A useful research
threshold is about 20% of that combined stage, not a promised gain. Stop if the
summary costs as much as the walk or creates another retained graph. Full compiler
acquisition comes after this experiment, not before it.

## Why this is not an already-rejected proposal

- [Phase80](../../implementation/phase80/README.md) retained full checker types.
  Annotation improved greatly, but prepared Base grew from 1,182,240 to 2,160,193
  bytes and other work erased the gains. Earlier checker normal forms also cannot
  be reused blindly after later law fills and specialization.
- [Phase84](../../implementation/phase84/README.md) retained both annotated and
  erased products; its full request comparison was effectively neutral at
  1.0043×. The old representation was not fully retired.
- [Phase173](../../implementation/phase173/README.md) showed that an indexed
  representation can be slower even after execution repairs: the final matched
  complete-consumer comparison remained 1.155× slower. Do not start with a global
  arena, new node IDs or an import/export layer on architectural taste alone.

Already present: normalized annotation heads, field quantities, indexed book
lookup, body use summaries, erased-body reuse and prepared Base. Those are not
new proposals.

## Priority and honest headroom

1. Replace annotation consumers with exact narrow products, deleting their old
   traversals. Highest architectural value; correctness and integration risk are
   meaningful, so begin with one complete consumer.
2. Consolidate parser publication/resolution state. Useful for semantic coherence
   and avoiding future clones; remaining speed gain is unmeasured.
3. Consider dedicated term variants or interned identities only after a complete
   consumer shows generic-term representation is the dominant avoidable cost.
   Do not migrate the whole frontend first.

The accepted medium diagnostic places 33.94% of frontend time in annotation,
layout and erasure/request preparation; layout alone is 7.29%. These intervals
contain necessary work, so neither is a removable-cost estimate. A 20% saving
inside the former would be only about 6.8% of that frontend, not of the cold build.

The clean full-source frontend is about 54s while the full build is about 177s.
These come from different executable configurations, so subtraction is only an
order-of-magnitude model. Even halving a 54s frontend would save roughly 27s,
not bring the whole build below 100s. A path to that goal must also remove work
after the frontend. No credible 5–10× gain is established by this audit.

The change in method should be to demand deletion of a producer, representation
or consumer pass as the result of each refactor—not another set of wrappers and
cached facts surrounding the same old pipeline.
