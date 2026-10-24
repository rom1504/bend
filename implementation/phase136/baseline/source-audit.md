# Cold compilation: structural opportunities before another cache

Audit at `286fe99`, using qualified Phase134 source
`a00019246b5181b288ab4d3e09e616bd41415fe6381e89a96185c05efa19fb57`.
Line numbers refer to its frozen `verify-selected-source01/compiler.bend`.
This note introduces no compiler override. The appended source02 query proxy
now passes source checking,14 controls and30 exact observations; it remains
diagnostic infrastructure, not a qualified optimization. See [query results](query-results.md).

## What exists already

`lookup` (5954) dispatches directly through the first `BookCache`; `index_find`
(6409) is a hash Patricia walk, and `index_build` (6598) already constructs a
first-list-entry-wins index. Phase131 made insertion follow one path and composed
borrowed index readers. A generic request to “add hash maps” misses this work.
The distinction to measure is **which actual caller still receives a raw list**,
not the existence of a lookup helper in a profile.

`driver_report_data` (37710) already shares its dependency result between report
fields, caches completed safe traversals, and uses a zero bound where no binder
allocation needs the maximum. `driver_emit_owned` (37826) already filters eligible
rows once before its fixed reserved-name checks. Reintroducing a whole-book bound
scan or adding a new global wrapper here could lose prior gains.

`p86_plan` includes checking, ownership/admission, dependency/report traversal,
reachability, annotation and `nr_prepare_annotated`. The latter (36339) merges
annotated definitions, traverses the merged book for its bound, builds a new
mirror index, and runs native preparation. Consequently Phase135's175-second
“frontend” interval is broader than parsing or type checking. The new Phase136 diagnostic split now records parse/import44.745s, checking
53.149s, erasure30.326s, annotation13.546s and annotation-check5.110s on the
full compiler input (`staged-full01/report.json`). These are one diagnostic
image's wall intervals, not exclusive CPU times or a speed comparison with the
qualified baseline. They support separate checker and representation investigations
rather than calling the entire frontend “parsing.” Phase135's late cache begins after62.7% of observed B
wall time; caching more of that same late stage is a weak cold-build strategy.

## Three concrete query seams

**Parser prior lookup.** `f_find` (12879) compares names down a raw list. It is
used in `f_context_family_input` (12054), `f_context_mark_input` (12160), and twice
in the ADT branch of `f_do_header_resolved` (13812). These are actual semantic
consumers, not static name-count guesses. A local single-result binding in the
last case can remove one identical lookup without a new cache or IR.

The parser already carries `FParseScope.index`. Local declaration misses are
filtered by that index before `f_find` (`f_decl_local`,13404); this optimization
is already present. Moreover, `f_body` constructs one scope index using
`index_build(List.reverse(prior))` (15733), while `f_find` chooses the first row
of unreversed `prior`. Context publication (11864) pushes a mapped header and
updates the index, not the original definition body. Therefore blindly replacing
a raw prior scan with the existing scope index can change duplicate/law ordering,
name qualification, or returned payload. An exact prior-only view needs its own
proved first-event invariant, or a bounded admission and unchanged fallback.

**Constructor ownership.** `nc_ctor_owned` (31097) scans top-level rows, then
calls `lookup` on each ADT's direct children. It stops on the first ADT whose
first matching child is a constructor, returning that ADT's ownership—even
False. A nonconstructor child shadows a later same-name constructor within that
ADT, but permits searching subsequent ADTs. Cached child books have real lookup
semantics and cannot be flattened arbitrarily. `nc_ctor_identity` (31089) is a
small actual consumer whose complete String result can be checked.

Phase135 already implemented a sufficient ownership fact with these rules.
Its late-only wrapper passed29 controls and18 exact outputs but had mixed hosted
performance. Earlier annotation/erasure callers remain uncovered, and every
unindexed call pays wrapper overhead. The next useful experiment is explicit
once-per-immutable-book preparation at one measured hot caller, including the
preparation and reclamation cost. Repeating the same global wrapper is not a
new idea.

**Index versus owning query cost.** A cached lookup may still allocate, clone,
reclaim, hash a String or reconstruct a return record. Zero list visits is not
zero work. Phase131's borrowed records and selector composition already target
part of this, while its dead-field masking removed instructions without changing
runtime. Logical counters should select a transformation; native samples and
paired timing must establish its value.

## Cheapest decisive experiments, in order

| Experiment | Evidence obtained | Bounded engineering scope |
|---|---|---|
| Checked counters on actual KDef books at16/64/256 rows | First-match values, raw-list visits, ownership child visits and explicit index delegations | Append-only diagnostic;14 finite controls, then three existing small source requests. No native image. |
| Share the repeated `f_find` value in one parser consumer | Removes an actual duplicate scan while preserving returned definition | Small source change, exact parser/result controls; generalizes by repeated-query identity, not benchmark name. |
| Admit an exact prior-query index at one context boundary | Replaces repeated list walks while retaining first-event precedence and payload | Must establish current scope construction invariant; challenge duplicates/law fills/aliases/absence first. Reuse existing Patricia implementation. |
| Move the already sufficient ownership fact to one measured early caller | Removes scans before annotation/erasure without charging every unsupported call | Reuse Phase135 controls and unindexed fallback; first measure build+allqueries+cleanup. Avoid a new universal cache. |
| Reduce repeated preparation and own shorter-lived per-owner data | Potentially affects much more of the cold compiler than one query | Requires new substage/profile evidence; first extract one repeated preparation, then retain its exact facts. Do not start with a global indexed-IR rewrite. |

These are engineering estimates/order, not gain promises. Historical Phase131
active contexts attributed about5.20% to `f_find`,5.43% to `lookup` and7.48% to
`nc_ctor_owned`. They overlap runtime ownership/reclamation work and do not
establish today's exclusive CPU cost. Eliminating a whole5% context cannot by
itself turn a375-second compile into seconds. The fresh native profile and
substage measurements should decide whether a broader representation change is
justified.

## What to borrow from Zig and Go

Reuse the existing pinned [Zig source audit](../../../research/phase133/zig-ir.md)
and [incrementality audit](../../../research/phase133/zig-incremental.md).
Zig0.17.0 uses compact indexed instruction/value storage and short-lived
per-function AIR/MIR, with explicit work-in-flight accounting. Its own source
reports MIR commonly around20× AIR and a50× observed case; compact source IR
therefore does not mean tiny whole compiler memory. The cold-build lesson is to
avoid unnecessary object graphs and bound temporary lifetime **at one measured
boundary**, rather than switching every representation at once.
Primary pinned sources: [AIR](https://codeberg.org/ziglang/zig/src/tag/0.17.0/src/Air.zig),
[InternPool](https://codeberg.org/ziglang/zig/src/tag/0.17.0/src/InternPool.zig), and
[Zcu work scheduling](https://codeberg.org/ziglang/zig/src/tag/0.17.0/src/Zcu.zig).
Published millisecond Zig updates use a warm persistent process and selected
backend/linking modes; they are not a cold full-compiler build comparator.

The [Go research and isolated experiment](../../../research/phase132/go-build-reuse.md)
separate action identity, output content identity and exported semantic data.
Body edits can preserve some dependency-facing products, but package action reuse
does not make a fresh source compile free. For this cold baseline, the useful
transfer is explicit phase/product ownership and concise intermediate interfaces;
for a later warm loop, preserve consumed facts and negative dependencies before
reusing a product. Primary pinned released source:
[Go build identities](https://github.com/golang/go/blob/2aae1000ea1d4b28923b96db28acf4e3b99d6aff/src/cmd/go/internal/work/buildid.go).
Our local experiment usedGo1.22.2; the later source audit was pinned separately.
No cross-language speed prediction is inferred from either compiler.

## Updated interpretation after the bounded census

The checked observations expose quadratic list visits under an explicit prefix
query schedule, and show that ordinary prepared `lookup` already avoids that
linear walk. Shared Base prefixes account for identical16/64/256 results across
the three small programs; this is not independent transfer evidence. The
[complete result](query-results.md) preserves the actual caller/output controls
and the distinction between logical visits and observed runtime call frequency.

The independent [QBE mechanism audit](../profiling/query-mechanics.md) strengthens
a separate hypothesis: a kept ordinary KDef passed to `dn`/`dk` can take all nine
fields, transfer shared references and sink unused ones. Those operations do not
necessarily destroy their graphs. The loops already use local SCC backedges, so
another scheduler optimization would miss this case. Test a complete scalar
observer over the held row separately from fewer visits; the two effects must
not be conflated. Existing wider-record experiments and correct owning fallback
are more useful starting points than an unmeasured global representation rewrite.
