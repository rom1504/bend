# Phase144: one ownership summary before erasure

Source-only prototype at `63dd41d`, against
`selfhost/build/phase143/integrated-source03/compiler.bend`. No target or benchmark
was executed by this lane, and no selected compiler/source snapshot was edited.
The coordinator owns checking and measurement. The first combined source check
exposed a missing explicit type on a renamed oracle declaration; `oracle-v02`
retains the original body and supplies the original law's signature. A second
check exposed a missing shared annotation in the optional workload helper;
`workload-v02` changes only that binding. Preserve both failed receipts and v01.
The coordinator reports the combined API03 and all35 ownership controls passed;
real-consumer and integrated measurements remain separate gates.

## Actual opportunity and evidence

The Phase143 **pre-optimization ordinary** diagnostic attributes4.63% of all
samples to `nc_ctor_owned`. Its timeline places ownership work in the middle of
the build. This is not a residual profile of the newly qualified Phase143
compiler, an inclusive ownership cost, or a guaranteed4.63% saving. Physical
reclamation overlaps these observations. The early linear scan is still present
in the selected source, so an exact shared fact is a plausible2–5% whole-request
hypothesis, including additional catalogue sharing, pending actual costs.

The important earlier negative result is Phase135's late ownership attachment.
It retained a complete row/field shape, attached after static preparation, missed
erasure and initial catalogue construction, and had mixed hosted request costs.
Phase137's `wide/ownership-alternative.md` already identified those shortcomings.
This prototype removes them rather than claiming the old sidecar was a new idea.

Current selected-source anchors:

| Mechanism | Source lines | Concrete issue |
|---|---:|---|
| `nc_ctor_identity` / `nc_ctor_owned` |30576/30585|Every identity query repeats an ordered whole-book ADT scan.|
| `nc_ctor_specs` / `nc_constructors` |35174/35187|Every emitted constructor asks ownership again.|
| `nc_definition_plain` |35086|Erasure queries happen before static preparation.|
| `nr_prepare_annotated` |35820|Provides the earliest narrow immutable checked/annotated book boundary.|
| `nr_prepared` |35781|Original source and prepared internal book are already separate fields.|
| `p128raw_lower_request` |55921|Initial catalogue uses original source, so a late fact alone cannot help.|
| `p128raw_prepared` |55911|Computes identical bang information twice.|
| `p111_finish` |39561|Reconstructs the same original-source constructor catalogue.|
| `p140or_finish` |60255 onward|Already implements the exact finish with an explicitly supplied catalogue.|

## Smallest representation and exact predicate

`P144OFacts{names,valid}` retains only names whose **first qualifying parent**
ownership is true. It does not retain the whole input shape, child records,
negative result rows, full ADT objects or per-query result records. Strings are
shared with original names; their list cells still allocate. This is not an
unboxed or allocation-free representation, nor a claim that lists are universally
better than indexes.

One pass builds it with two existing collision-safe name sets:

1. A per-ADT `seen` set records every direct child name, including nonconstructors
   and the empty-name projection of internal index records. Thus only the first
   lookup-visible child can classify that name in this ADT.
2. A request-local `claimed` set records names whose first visible child in an
   encountered ADT was actually `Ctr`, including parents with a false flag.
3. A newly claimed true name is added to the positive list. A newly claimed false
   name blocks later true parents but is absent from the final query list.
4. A child `BookCache` refuses preparation and retains the exact original query.
   Invalid scalar names likewise refuse before new hash work. Non-ADT top-level
   rows and nested constructors are ignored, matching the original traversal.
5. Temporary sets are discarded when construction finishes. Every query is
   positive-name membership, or the untouched original predicate on refusal.

Inductive argument: after each direct child, local `seen` equals the already
visited lookup-name projection; after each ADT, global `claimed` equals names
for which the original search would have terminated in the visited ADT prefix.
The positive list contains exactly those terminating names with true ownership.
Full-name bucket comparisons preserve 32-bit hash collisions. Therefore positive
membership equals the original predicate for every query when admitted. Refusal
uses the original predicate. This is a source argument plus proposed controls,
not a new kernel-checked theorem.

The ordinary `NativeCtorIndex` cannot replace this construction: it stores the
first depth-first constructor itself, including nested/cache children, whereas
ownership selects a qualifying top-level parent's flag. The two first-match
relations are different.

## Early integration and carrier audit

The optional three-entry overlay is separate from the append-only prototype:
`nc_ctor_owned`, `nr_prepare_annotated`, and `p128raw_lower_request`.

At the annotated boundary, the exact original merge, bound and cached source are
constructed first. A distinct prepared view carries ownership facts into the
existing `nr_walk`/erasure. The resulting `NR_Request.source`, paths, scope and
bound still use the original source. Erased bodies and names must be compared
against the original; internal metadata intentionally differs.

The carrier uses one tagged `KTerm` in the previously-Absent **type field of
NativeCtorIndex**, storing positive names in its existing List<String> field.
The first constructor-index child and all normal source indexes stay unchanged.
This uses an existing local representation; it adds no per-name KTerm/KDef
payload rows or array-of-boxed-records. The hot carrier query returns Bool
without allocating an intermediate P144OFacts result.

The old direct users of `nc_ctor_context` are `nc_find_ctor` (kind + first index
child) and `nc_ctor_prepare` (returns the existing complete NativeCtorIndex).
Neither inspects its type. `ns_attach_book` and `p112s_attach_book` both carry
`nc_ctor_prepare` into the replacement context, so the fact survives both
reconstructions. `ns_source` deliberately strips context; such a path must fall
back and must not be reported as a hit. Current ordinary annotated preparation
does not strip the new view before erasure.

Early attachment also builds the existing general constructor index earlier.
That can accelerate `nc_find_ctor`, but it is additional acquisition work and a
second semantic boundary to test: its previous plain traversal and existing
indexed implementation must agree for the actual source. It is not justified
by ownership-predicate controls alone.

The carrier validates its private kind/name/version/shape. This is **not an
unforgeable certificate**. The supported integration creates it from the exact
immutable source in the same request and preserves it through known producers.
Arbitrary user-supplied native metadata or cross-source copied carriers are not
admitted by this claim. No external cache import, source hash bypass, mutable
book, raw Term injection or cross-request reuse is introduced.

For raw preparation, `p144o_constructors` uses the fact only for constructor
identity. All arity/type normalization uses the **original source book**. The
ordered catalogue is passed to both `p112s_prepare` and existing `p140or_finish`;
it is no longer recomputed. Bang names are also evaluated once and shared by
the two existing consumers. Error branches, static preparation, source admission,
original emitters and final independent verifiers remain unchanged. Some source
queries, including final show construction, can still use the original fallback;
this prototype does not claim universal query coverage.

## Accounting and cheap falsifiers

Let D be source rows, C visible direct children, P positive names and Q queries.
The previous ownership work can scan O(Q·D) rows plus child lists. Preparation
scans O(D+C), builds collision-safe temporary indexes, then list queries cost
O(Q·P) string comparisons. P is **unmeasured** on the actual full source here.
Measure it before treating a small positive set as an established fact.

Construction creates temporary persistent index paths and markers, positive
list cells and a reversal; the carrier retains positive name strings/list cells
until the request dies. The original source already retains those strings.
Temporary index destruction belongs to acquisition, and final carrier/list
reclamation belongs to complete request cost. The early general constructor
index is carried forward, not intentionally rebuilt at each boundary. All these
costs must be included, especially on small requests.

`workload-v02.bend` supplies original/list/index complete-work kernels. Each call
discovers actual source catalogue query names and includes summary acquisition.
The index variant additionally constructs the existing collision-safe name index.
Start with one query round; larger rounds are a reuse sensitivity experiment,
not measured actual call counts. Its checksum is a performance result guard,
not the correctness oracle: compare the full Bool vector separately.

Recommended sequence:

1. Check append-only source and35 finite controls. Cases assert expected original
   results, admission, first false/true, child shadowing/reset, empty names,
   nested/non-ADT cases, child-cache refusal, real hash collisions, Unicode,
   malformed internal KDef variants, metadata refusal and both carrier stages.
2. On real prepared Lexer/Map/closures and the compiler, compare every actual
   catalogue query, exact ordered catalogue, names and erased bodies. Measure
   positive-set size and complete acquisition+query+destruction for list/index.
3. Wire the isolated three-entry overlay. Check original source/bounds/path/scope,
   erasure products, complete QBE and ordinary independent outputs. Include
   Foreign/effect/constructor-shadow controls and actual unsupported fallback.
4. Use a same-API comparison first, then one small native workload before another
   full compiler image. Escalate only if real erasure/preparation and complete
   requests save time, not because the isolated lookup or hit count looks good.

The optional integration is not selected or qualified. Whole-image acquisition,
N1/N2 reproduction, runtime quality and installed selection are root decisions.

## Files and frozen versions

`selfhost/tools/performance/phase144/ownership/composition-v02.json` pins the
append-only core, carrier, request adapter, exact-reference oracle and controls.
`composition-workload-v03.json` additionally pins the corrected complete-work kernels.
`overrides-v01.bend` is an optional integration overlay, not part of those
append-only module lists. `oracle-v02.json` records the exact selected-source
reference bodies and the required standalone type annotation. v01 remains as
source-check failure evidence; no target was executed by this implementation lane.

`screen-v01.mjs API_REPORT FRESH_PHASE144_OUT` is a root-run same-API observer
for the three real frozen requests. It verifies complete query vectors and
catalogues, counts positive names, compares the complete reconstructed request
after permitting only the exact ownership payload, and measures1/4/16 query-name
sweeps across three rotated orders. Construction is included in every kernel;
call and synchronous hosted-GC costs are reported separately and together.
Higher reuse is explicitly hypothetical, and the smallest tested crossover is
reported even when no tested point wins. Optional bounded graph snapshots retain
actual input data for a later native experiment. API03 does not install the
ownership override, so this screen does not replace integrated QBE checks.
