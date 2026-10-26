# Phase143: cold frontend opportunities

Read-only investigation at `4fd100d`. The highest-value direction is to remove
repeated work *within one compilation*: suffix-name searches, publication-time
list filtering, parser prior-name searches and constructor-ownership scans.
The compiler already has a collision-safe Patricia index. The problem is which
views use it, and how much ordered data is rebuilt around each indexed update.
No compiler edits, target executions or new performance claims accompany this
note.

## Keep the denominators separate

The strongest ordinary-cold evidence is the
[Phase138 exact-object profile](../../implementation/phase138/profile.json):
qualified Phase137 N3 compiling the fixed Phase131 source, with no previous
source revision or semantic-result reuse. It has10,785 samples, zero loss,
99.66% main-thread CPU coverage and an exact complete105.9MB QBE oracle.
Its346.535s diagnostic wall time is not a clean timing ratio. The separate
[Phase137 clean comparison](../../implementation/phase137/metrics.json) measured
346.391s source-to-executable, using prepared Base and runtime but no semantic
or machine-result reuse; OS page caches were not flushed.

The [Phase136 diagnostic stage split](../../implementation/phase136/metrics.json)
is older: parsing44.745s, checking53.149s, erasure30.326s, annotation13.546s,
annotation validation5.110s and other frontend work, totaling152.111s excluding
Base acquisition. Lowering59.411s, optimization/verification77.734s and
rendering64.760s are distinct large costs. These are not current Phase142 stage
measurements and cannot be added to the clean clock as independent intervals.

The [Phase142 context capture](../../selfhost/build/phase142/native-context-plan01/analysis/summary.json)
instead profiles **incremental cold seeding plus a warm edit**, using Phase141
N2 and additional cache construction. Its cold frontend interior has6,431
samples: lookup11.54%, index_remove10.48%, f_find9.91%, constructor ownership
4.66%. This corroborates the mechanisms; it does not justify applying those
percentages to ordinary compilation. The later Phase142 indexed-layout/reach
gain is measured on that incremental route, not a new ordinary-cold campaign.

Active owners include synchronous private-call work. They are not inclusive
source stacks or exact exclusive phase costs; physical reclamation samples
overlap them. Approximate CPU windows are not phase timestamps. All estimates
below retain these uncertainties.

## What the ordinary profile actually exposes

| Active owner | All ordinary-profile samples | CPU-time equivalent at346.426s, for scale only |
| --- | ---: | ---: |
| `lookup` |5.64%|19.53s|
| `index_remove` + `index_remove_step` |4.92%|17.06s|
| `f_find` |3.22%|11.15s|
| `nc_ctor_owned` |4.92%|17.06s|
| `nb_contains` |3.08%|10.66s|
| `constructor_exists` |1.48%|5.14s|

These distinct owner buckets total23.26%, but are neither wholly frontend-only
nor wholly removable. They are a useful **profile-visible opportunity budget**,
not an80.6s forecast or a strict bound on all executions of those functions.
Dispatch attribution can leave some invocations under other owners.

The [timeline](../../implementation/phase138/timeline.md) strengthens three
specific hypotheses: f_find27.3% in the first30s; lookup/index_remove dominate
parts of30–90s; nb_contains34.3% and nc_ctor_owned30.0% in120–150s. The current
source still contains the relevant algorithms. Phase137 already removed much
of the owning field-projection overhead in these queries; do not forecast that
same gain again.

Source references below use
[`phase142/indexed-source02/compiler.bend`](../../selfhost/build/phase142/indexed-source02/compiler.bend),
SHA256 `15f5cada2710119cce19a0cfe961c21f61edc5f0b048f90359090a0c1817dac1`.
This is source-checked and experimentally acquired, not the installed qualified
compiler. The ordinary profile's producer/source identities remain separate.

## Ranked experiments

### 1. Prepare the checker's future-event information once

`dg_event_publish`(16038) calls `lookup(rest,dn(d))` on the raw remaining
declaration list for every successfully checked event. `signature_mode`(8880)
asks the same query for an unfilled law. The results decide whether a body can
be published and which later declaration supplies a law's checking mode. This
is semantic work, but repeatedly rediscovering the same suffix relationship is
not necessary. Ordinary `lookup`(5772) already takes an index when supplied a
BookCache; this caller supplies a raw suffix.

**Smallest useful transformation:** prepare one record per event containing its
exact first subsequent same-name definition (or exact missing value). Build the
records right-to-left with the existing full-name index, retaining only the
next-result records, not a separate complete index for every suffix. Feed the
same record to signature selection and publication. The checker, world updates,
event order, diagnostics and final verification remain unchanged. Noncanonical
API event lists containing BookCache sentinels need exact barrier semantics or
the unchanged fallback; a plain flattened index is not equivalent there.

**Cheapest falsifier:** extract the real post-freshening event list at128/512/2048
events, compare every result against original `lookup(tail,name)`, and time
preparation + all queries + destruction. Then compare complete `DChecking`,
KWorld/memo/fresh/checked outputs and first errors through the original checker
on ordinary programs, law/fill chains, duplicate definitions, interleaved ADTs,
missing names, empty names and full hash collisions. Use graph-aware comparison.
No compiler image is needed for this first test.

**Saving expectation:** roughly2–5% ordinary request time (7–17s on the historical
scale) if these suffix callers explain a substantial part of lookup's5.64%
bucket. Attribution does not establish that fraction. This is the best first
30–60min discriminator because it preserves the exact world representation.
Reject it if build/cleanup offsets the scans or actual event lookup is a minor
part of the bucket. Do not silently substitute last occurrence for first later
occurrence.

### 2. Remove ordinary erasure's linear visited-name work, then ownership scans

`nr_walk`(35766) still calls `nb_contains(done,name)` for every queued reference.
`nr_visit`(35775) erases the definition, appends its references and records the
visited name; missing definitions and duplicate references have existing exact
behavior. The incremental Phase140 owner implementation already maintains an
indexed membership set separately from the ordered `done` list. Its small
membership rule can transfer to the ordinary path without importing dirty-owner
analysis, previous revisions or the rest of the cache framework.

**First falsifier:** use exact ordinary `nr_walk` as oracle, preserving the
ordered names and complete erased facts on chains, cycles, missing names,
duplicate references and real hash collisions. Measure one actual compiler
prefix closure plus an unrelated program, including set construction and
reclamation. Reuse the independently authored
[`erasure-controls-v01.bend`](../../selfhost/tools/performance/phase140/owner/erasure-controls-v01.bend)
and source pattern in
[`products-v03.bend`](../../selfhost/tools/performance/phase140/owner/products-v03.bend).
Do not expose those controls to a wired-through candidate masquerading as the
independent original oracle.

Next, build an exact constructor-ownership view before `nr_walk`, once for the
immutable checked/annotated book. `nc_ctor_owned`(30585) scans ADTs and direct
children; it returns the *first qualifying parent's flag*, including False.
The existing NativeCtorIndex has different depth/precedence/payload semantics.
Reuse [the Phase137 contract and earlier negative result](../../selfhost/tools/performance/phase137/wide/ownership-alternative.md):
the Phase135 late-only wrapper missed erasure and had mixed results. Cover both
erasure and `p128raw_lower_request`(55927), which independently constructs its
catalogue from `request.source`. Keep source identity/admission unchanged.

**Saving expectation:** indexed ordinary visited names plausibly1–3% (3–10s);
early ownership facts2–4% (7–14s), each conditional and including preparation.
The visible buckets are3.08% and4.92%; these are not additive with historical
borrowed-query gains or overlapping physical destruction. The ownership view
needs first-False, child shadow, cached-child refusal, Unicode, collision and
exact constructor-table/erased-body/QBE gates. Price its construction on small
programs too. A bounded ordinary erasure discriminator is economical before a
full acquisition.

### 3. Replace raw parser-prior search with an exact prior view

`f_find`(12669) scans raw prior definitions. Actual consumers include
`f_context_family_input`(11845), `f_context_mark_input`(11941), local declaration
checking(12952), and `f_do_header_resolved`(13356), which repeats one successful
query. The scope already has an index, but using it blindly is incorrect:
initial construction(15222) indexes `reverse(prior)`, while f_find selects the
first row of unreversed prior. `f_context_header`(11658) also maps names and
replaces bodies with Absent; local declaration consumers can require original
payloads. A miss fast path already exists in `f_decl_local`.

**First falsifier:** build an exact *prior-only*, first-row index on one real
parser context and compare complete returned KDefs for its actual query keys.
Challenge duplicate laws/fills, aliases, namespaces, missing values and payload
differences before timing. Price initial construction and each publication.
A smaller control shares the two identical f_find results in the do-header
consumer, but its unmeasured frequency makes it a weak main optimization.

**Saving expectation:**1–3% overall (3–10s) against a3.22% visible owner bucket;
likely less for one consumer. An index probe/semantic falsifier should take
30–60min; changing all parser scope consumers is a larger integration. Retain
the original public arbitrary-list f_find rather than pretending every list
already has the new invariant.

### 4. The larger checker change: separate publication from ordered materialization

`book_put`(6454) updates the Patricia lookup tree but also calls
`index_put_rest`(6444). A proven name miss reuses the tail; a hit invokes
`index_remove`(6297), scanning and reconstructing the ordered list. Each
successfully published definition already has a declared header in the checker
world, so these hits are expected. This is not a slow Patricia deletion:
`index_remove` is a **list filter**. Suffix indexing alone leaves it intact.

The architectural hypothesis is a private checking-world view with authoritative
lookup replacements and an ordered event stream, materialized only when an
actual consumer needs the canonical list. This can remove whole-list copy/drop
work per publication. It is the most ambitious source-connected frontend idea,
but is not a safe one-line `book_put` change: constructor uniqueness, template
specializations, source order, bound headers, snapshots, failure worlds and
public API results can observe list contents. `check_declarations`(8896) also
uses book_put, but the cached name-miss optimization already handles ordinary
new names; merely adding another batch there may save little. `book_put_many`
(6650) already supplies an exact bulk overlay for suitable immutable boundaries.

**Cheapest falsifier before a representation change:** count/check the actual
checker publication schedule and compare a replay with delayed materialization
at every existing observation boundary. The oracle is complete world/state and
errors, not just successful lookup answers. Inventory the raw-list consumers;
if one observes every intermediate list, the proposed delay cannot skip it.
First test within one successful isolated checking segment and restore the
canonical world on every exit. Do not import cross-revision trust.

**Saving expectation:**3–6% overall is a working hypothesis, with about4.92%
profile-visible list-removal work plus possible allocation costs elsewhere.
The checker suffix and materialization pair has a visible10.56% budget together
with lookup, much of which may remain needed. A2–4h contract/proxy investigation
is justified only after the cheaper event-schedule result. This is a foundation
for broader representation improvements, not evidence of a2× compiler.

## Other traversals and stopping rules

`constructor_exists`(8925) is a separate1.48% ordinary owner bucket. Its query
is not identical to ownership lookup; a first-match constructor summary could
share construction only after its own semantics are represented. The current
`nr_prepare_annotated`(35828) merges definitions, scans maximum binders, builds
a lookup mirror and erases the reachable graph. It is a plausible fusion target,
but the current data does not isolate duplicate materialization from required
checking/annotation. Do not claim the30.326s historical erasure interval is all
redundant. Similarly, `dr_walk`(37222) still has local membership, but Phase142
already fixed two other walkers and report-name deduplication; avoid counting
that paid-for saving again.

A combined10–20% cold request reduction is plausible **only if several of these
independent algorithms win and their construction costs stay small**. It is a
hypothesis, not a compounded forecast. The broadest listed profile budget is
about23%, and even removing the entire historical152s frontend leaves lowering,
verification and rendering far above a20–60s build. A multi-fold cold improvement
requires measured changes in those later stages as well. More CPUs, a late cache
or a new generic index do not address these serial traversals by themselves.

Start with the exact checker event schedule and ordinary erasure membership;
their semantic surfaces are narrow and their costs are visible. Escalate to
early ownership preparation and private world materialization only after those
small experiments identify their actual gain. Acquire one combined native
candidate after full product/control gates, and run an **ordinary cold** same-
source request. Keep incremental seed/warm measurements as separate transfer
observations. Final QBE/runtime identity protects generated-program speed for
the frozen cases; any changed products need their own semantic/runtime checks.
