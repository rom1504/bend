# Phase59: discriminate remaining compiler work

2026-10-06. This is a source audit and diagnostic-counter proposal, not an
optimization or a new performance result. No compiler or generated program was
executed for this report. Phase58 last01 remains selected. Its
[publication](../../selfhost/tools/performance/phase58/publication.json) binds
source `85454aab…`, checked B1 `641381f6…`, and direct B2 `a73daccf…`.
The eleven source modules inspected below match their checked-last01 snapshot
bytes. The complete saved B2 was independently rehashed to
`a73daccf86a807092a334d5f3121745e0b91c3054164c25462f1658644b7b081`.

The [selected measurements](../phase58/final-measurements.md) give the motivation:
ordinary B2 requests take 2.4–2.7 times the handwritten TS time on two inputs;
selected lexer sampled allocation is 231.946 MB/request versus TS 59.667 MB.
These are bounded, still-warming windows. Profile weights identify work, not an
amount of time an optimization can remove. Phase57's source comparison remains
useful, but its old allocation totals and now-replaced SCC/lookup behavior must
not be relabeled as selected last01 evidence.

## First discriminator: primitive lookup versus table construction

[primitive.bend](../../selfhost/src/back/js/direct/primitive.bend:14) calls
`jd_primitive_find(name, jd_primitive_table())` from both candidate emission and
native admission. The selected table has **90**, not the historical 89, entries.
The saved B2 contains one literal `JDPrimitive` and one `Con` construction per
entry, plus one terminal `Nil`, each time this function executes. That is a
static construction-site fact, not proof of 181 physical heap allocations.
The selected CPU profile attributes 4.51% exclusive weight to the table printer.

Count table entries, candidate/admission entries, lookup-row comparisons, and
telescope steps. Divide row comparisons by table calls to distinguish a mostly
early-hit search from repeated full-list walks. Multiply table calls by the
AST-proved 90 records/90 links only to report executed literal sites. If table
calls are rare in actual requests, the proposed table replacement loses priority.
Do not infer that all native admission or its type checks can disappear.

## Second discriminator: emitted use searches and dependency scans

The five demanded-use seams are `jd_body_bound`/`jd_let_bindings` in
[core.bend](../../selfhost/src/back/js/direct/core.bend:197),
`jd_ordered_lets` in [ordered.bend](../../selfhost/src/back/js/direct/ordered.bend:193),
`jd_ordered_bindings` in [ordered-values.bend](../../selfhost/src/back/js/direct/ordered-values.bend:118),
and `jd_word_bind_used` in [pattern.bend](../../selfhost/src/back/js/direct/pattern.bend:302).
They search already-rendered bodies for physical-newline `JD_USE` markers.
The Base `String.contains` implementation repeatedly tests a prefix and advances
one Unicode code point; its shared worker includes both `contains` and `.if`.

Count search starts separately from internal suffix steps. Classify needles
beginning with the exact `\n/*JD_USE:` prefix versus all other searches. Record
input UTF-16 lengths at starts, not at every suffix. Prefix-test successes and
aggregate `starts_with` entries give a second work view; the latter includes
other callers and must not be attributed wholly to use-marker search.

[reach.bend](../../selfhost/src/back/js/direct/reach.bend:44) still renders each
visited definition and scans its String for validated `JD_REF` metadata. It now
deduplicates outgoing dependencies per definition. Count incoming UTF-16 units,
ordinary scanner entries, marker entries, validated unique edges and duplicate
markers. This separates string traversal from useful graph edges without
reintroducing an extra recursive census. UTF-16 units, Unicode code-point steps,
marker occurrences and budget fuel are different quantities.

Count `jd_definition` and `jd_component_case` entries alongside stage labels.
The selected own-source observation spends 8.016 s in emitted reach and 8.466 s
in unsplit emission, but neither figure isolates printing or scans. Reuse across
those stages is not automatically sound: the pruned book changes call facts,
SCC membership, layout and wrapper context. A future structured `(text, uses,
refs)` result must retain erased/dead-expression demand, foreign reachability,
scalar fallback and complete shared-component dependencies.

## Third discriminator: existing substitution reuse and reconstruction

[term.bend](../../selfhost/src/core/term.bend:332) already has both generic
`subst` and `core_subst_stable`. The latter is used by
`ka_args_after_head` in [annotate.bend](../../selfhost/src/check/annotate.bend:386)
and `tele_check_after_head` in [kernel.bend](../../selfhost/src/check/kernel.bend:1192).
Successful stability skips substitution and advances through a static telescope.
It is stronger than absence of one target ID: Vars refuse, and App canonical
metadata and possible beta reduction matter. A second identical proof pass
would duplicate existing work.

Count generic substitution node entries, matching and nonmatching Var visits,
literal reuse, nonliteral rebuild entries and child-list nodes. Count stable
proof traversal entries and the existing true/false branches at its two outer
consumers. Those branches expose avoided work without re-running the proof.
Generic calls remain in normalization, beta application and freshening; the
first count run does not assign each recursive node to a caller or infer that a
no-match substitution can safely skip `core_rebuild`.

The selected `subst$scc` allocation frame covers substitution **and rebuilding
and application**, not a single helper. Counters must select actual worker PC
cases. Instrumenting only the named wrapper would miss internal tail transfers.
Low matching-Var counts with many rebuild visits justify a closer caller audit;
they do not justify replacing first-order substitution with delayed environments.

## Fourth discriminator: persistent indexes and quantity lists

[index.bend](../../selfhost/src/core/index.bend:118) has a compressed persistent
trie with collision buckets; it is not a universally linear book lookup.
`index_node` constructs path copies. `index_remove` also filters source event
lists and collision buckets, so its total is not exclusively trie work.
Count sets/inserts, node/leaf constructors, list visits, removed/retained entries,
and name-hash code-point steps. `book_put` and `index_put_rest` counts help relate
that work to book updates. They do not distinguish every update's origin.
Do not replace the event list with a last-value map: precedence, duplicate names,
checked context and metadata remain observable compiler contracts.

[quantity.bend](../../selfhost/src/check/quantity.bend:95) merges a left usage
list by searching and deleting each ID from the right list. Disjoint width m/n
can incur O(mn) visits and retained-list reconstruction. Count nonempty merge
entries, `uses_get`/`uses_del` visits and retained links, keeping branch joins
and sequential saturated additions separate. Large visit counts per merge entry
support a width experiment; tiny lists would demote this idea. No list-length
walk is added to the diagnostic, and no quantity representation is changed.

## Bounded diagnostic implementation

Root authorized the insertion-only producer
[derive-v1.mjs](../../selfhost/tools/performance/phase59/counters/derive-v1.mjs).
It parses the exact B2 without importing it; writes only a fresh Phase59 private
copy; retains the runtime prefix and every original byte; reparses the result;
and proves exact inversion. The receipt records selected provenance, parser/Node,
modified body hashes, semantic insertion sites and every counter name.
It does not fabricate a checked receipt for the derivative.

For shared SCCs, wrapper PC and parameter forwarding identify the original
semantic function; insertion occurs at that case's block entry. For self loops,
insertion occurs inside the loop. Two existing stable-proof branches and the
existing dependency dedup branch get outcome counters. O(1) increments use fixed
numeric arrays: no per-node logging, stack traces, compiler queries, recursive
size scans, replacement algorithms or return-value wrappers.

The worker contract is reset immediately before **one exact ordinary first
request**, stop after its complete output observation, and compare all emitted
bytes with the genuine uninstrumented role's prepared oracle. Optional stage
labels are set outside compiler calls; otherwise use one whole-request bucket.
Imports, cache priming and provenance checks stay outside counters. Counter
timings and allocations are diagnostic only. Failing requests retain their
partial counts and cannot establish successful workload counts.

The producer passed independent static review and data-only AST materialization:
76 metrics at 50 insertion sites; derivative `9f57bc4191…`, receipt `2227f484…`.
No compiler was imported. The standalone first-request worker and exact commands
are in the [counter guide](../../selfhost/tools/performance/phase59/counters/README.md).
The worker and guard runner passed independent static review. Root then completed
both ordinary first-request diagnostics with exact output bytes; the
[count findings](counter-findings.md) separate those results from this initial
source hypothesis. Whole-image counting remains unexecuted and is not a
prerequisite to learn whether these mechanisms occur frequently.
