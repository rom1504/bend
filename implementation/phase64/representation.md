# Phase64: bounded compact-annotation experiment

Status: **source/data investigation and isolated source patch; no compiler target or speed result**.
The one proposed representation pilot is a compact canonical annotation node,
created at the existing post-check `ka_wrap` boundary. Do not start a global
arena, symbol-ID or token-storage migration to perform this experiment.
The prepared-world, parser-index, direct suffix-carry, fast DAG decoder and
lower-once work already selected in Phase63 are not new opportunities here.

## Why this boundary

[`ka_wrap`](../../selfhost/src/check/annotate.bend#L123) currently constructs
`kt("Ann", "", 0, 0, Con{term, Con{type, Nil{}}})` for each recursively annotated
expression. The wrapper has a generic string-tagged, eight-field `KTerm` payload
plus two list cells, even though its shape and six metadata values are fixed.
[`annotate`](../../selfhost/src/check/annotate.bend#L166) produces this after type
checking/specialization and before direct lowering. Annotation therefore provides
a useful existing ownership boundary; no parse/check conversion pass is needed.

The proposed internal constructor is `KAnnotation{term, typ}`.
`ka_wrap` constructs it directly. `tg`, `nm`, `ix`, `qt`, `rm`, `kb`, `ke` expose
exactly the old canonical values. `kid(t,0)` and `kid(t,1)` project the fields
without constructing lists; out-of-range access still returns `Absent`.
A generic `ks` request must materialize the old two-child list unless its caller
is converted to direct projections. This last cost can defeat the proposal.

This applies to every annotated expression, independently of program names or
benchmark patterns. It does not reuse semantic facts across unrelated books.
It preserves the **original** annotation type: `annotate` currently gives a
normalized head to `ka_node` but stores the original type in `ka_wrap`. Keeping a
normalized type for subsequent passes is a separate proposal whose book/context
validity needs proof; it is intentionally not bundled here.

The pinned [Zig study](../../research/compilers_architecture_and_techniques/zig.md)
provides the relevant idea: specialize common node storage and separate variable
payloads, with explicit ownership. Its mutable `MultiArrayList` and arena cannot
be copied directly into Bend's affine/persistent graph. The earlier
[Phase4 projection experiment](../../experiments/phase4/P4-004-projection-layout.md)
found that large projection counts alone did not establish dominant elapsed
cost. This pilot needs current allocation evidence and a fresh-request gain.

## Static operation and migration boundary

The executed [source-only census](evidence/representation-static01.json) records
individual input hashes. It finds 23 explicit `case KTerm` arms across five
modules, including 19 in `core/term.bend`. The other four are frontend syntax
preservation and the two prefix variant classifiers. There are 1,535 `kid`, 667
`ks`, 305 `kt` and three `ka_wrap` syntactic occurrences, including definitions;
these are **not** dynamic counts. A repository-wide constructor replacement would
be disproportionate before a bounded pilot proves value.

For each newly produced canonical annotation, the old representation has three
objects (wrapper plus two `Con`) and the proposed one has one. Ignoring headers,
shared strings and `Nil`, the payload count falls from twelve slots (eight plus
four) to two. This is a structural count, not a measured V8 byte estimate.

Let `A` be dynamic compact wrapper creations and `G` be dynamic generic `ks`
materializations on them. Before promotions/rebuilds, the object saving is
`2*A - 2*G`. If `G >= A`, this pilot has no object-count advantage. Retained graph
counts only bound a subset of `A`; neither API graph census nor sampled function
entries reliably recovers all allocations/inlined accesses. Inspect generated
code and allocation ancestry before inferring `G` from a function counter.

Migration must cover these contracts:

- Old `KTerm`/`Ann` remains accepted, with arbitrary metadata and child lengths.
  Only the exact `ka_wrap` producer chooses the new constructor.
- A metadata-changing rebuild of a compact node falls back to ordinary `KTerm`
  when necessary. Span changes, children of unexpected lengths, removed fields
  and quantity/name changes cannot disappear. Read-only observers retain the
  canonical values.
- Substitution and stable-term checks recurse through **both** fields and preserve
  the old result. Original annotation types can contain dependent variables.
- Loader/checker freshness and source-origin paths must either support the new
  variant with its logical children or reject its private admission. They cannot
  silently treat it as a leaf. The normal loader never produces it.
- Named and positional ABI schemas, cache validators/decoders, structural equality
  controls and compiler term ABI versioning need an explicit compatibility
  decision. The selected images use named layout, but that does not authorize
  breaking public positional inputs or old cache records.

A prototype can confine creation to post-check annotation, but a new constructor
still expands `KTerm`. It is **not** a two-line production change and should not
be described as a simpler overall compiler until old cases are removed safely.

## Cheap discriminator and exact oracle

The unrun [census controller](../../selfhost/tools/performance/phase64/representation/census.mjs)
accepts a verified checked-B1 attempt and real source paths. It executes ordinary
compilation, observes actual `annotate_selected`/`annotate_book` return graphs,
and repeats the request. The owning API object is retained, so the host's private
ready-world path is not disabled by passing a different API. It requires exact
equality of the full driver result and generated bytes. It records canonical and
noncanonical annotation counts, other constructor counts and the maximal
removable child-cell count. Only source/data analysis has run so far.

Recommended order, with explicit stop conditions:

1. Read the current State09 Numeric/Map/Lexer CPU and allocation profiles. If
   annotation wrappers plus their list cells do not form a material allocation
   share, stop this lane and prefer the whole-work-removal candidates. Earlier
   State05 profiles are not a current cost budget.
2. Root runs the census on Numeric and Map, adding Lexer if relevant. Budget
   approximately 10–20 seconds under the normal resource guard; this is an
   estimate, not a measured controller runtime. The instrumented clocks are not
   performance results. Preserve any failed run in its new output directory.
3. If both support the hypothesis, create a derivative source patch confined to
   `ka_wrap`, the term access/preservation boundary and required schema updates.
   No global smart constructor, interning pool or conversion pass. Time-box the
   checked-B1 ablation to 1–2 hours; otherwise defer the representation migration.
4. Compare accessor/rewriter observations on canonical, malformed legacy, nested
   dependent, nonzero-span and substituted annotation fixtures after expansion
   back to the old representation. Compare complete emitted modules on the two
   real sources. Existing source/diagnostic controls must retain outcomes.
5. Run the clean fresh-request screen. Continue only if it gives at least a 3%
   geometric-mean reduction without a material regression on either source and
   allocation evidence shows the intended change. Confirm on held-out Lexer and
   a constructor/dependent-type source, then use the normal genuine-B2 campaign.
   Exact bytes are the runtime-performance nonregression oracle when they match.

The 3% screen threshold is a triage rule, not statistical proof. Compilation,
import-plus-compilation and later-request clocks stay separate. Any B1 screening
gain requires genuine B2 confirmation before updating the headline comparison.

## Priority and expected value

This is the smallest plausible **representation** pilot found, not the highest
priority Phase64 optimization overall. A conditional **0–8% whole-compilation
reduction** is a reasonable experimental range; zero or regression is credible
because generic walkers can rematerialize children and a new variant adds
branches. Stronger claims require current allocation evidence. A qualified
implementation would likely take 0.5–1.5 days including compatibility and
self-hosting gates after a useful pilot. Global dense IDs/arenas remain a larger
multi-day follow-up, not a prerequisite.

Source/token views are narrower in source size but broader in semantic detail:
UTF16 origins versus codepoint columns, escaped/multiline strings, unterminated
input, previous-token boundaries and public lexer results all need preservation.
The historical Map profile put lexing at approximately 22% of frontend samples,
not 22% of whole compilation, and Phase63 already removed repeated Base frontend
passes. There is currently no evidence to rank a lexer storage rewrite above
retaining already-computed typed facts or a proven whole-Base summary.

## Independent challenge of the Base TODO summary

A sibling's separate TODO-only proposal is structurally sound **if** the existing
admission proves disjoint final top-level names between exact Base and the actual
suffix. Then `final(Base ++ suffix)` partitions into the two final books; nested
constructors remain with their final owner; counting is additive modulo U32.
The saved count must come from final **original** declarations, not rewritten or
specialized checked output, and may be nonzero (`Hol` can survive checking).
Compute/use it only in the same successful-check branch. A suffix filling a Base
law must fail the disjoint guard and use the ordinary path. This assessment is
source reasoning; the sibling owns its implementation and focused controls.


## Prepared source ablation and subsequent profile evidence

At root's request, the isolated
[`compact-annotation-v1/candidate.patch`](../../selfhost/tools/performance/phase64/representation/compact-annotation-v1/candidate.patch)
now implements the proposed source change. Its
[manifest](../../selfhost/tools/performance/phase64/representation/compact-annotation-v1/manifest.json)
records all six before/after source hashes, all 23 preservation arms and the
**+59 physical-line** delta. Complete before/after files are retained beside it.
The generator reads production and writes only the isolated directory; it checks
that source bytes did not change while making the patch. No source patch has
been applied and no compiler target has been run by this lane. Constructor ABI
and cache policy remain explicit promotion blockers, owned by the host agent.

The subsequently available current State09 profiles lower the priority of this
pilot. [CPU attribution](evidence/baseline-state09-cpu.json) and
[allocation attribution](evidence/baseline-state09-allocation.json) report:

| Source | Annotation CPU, profiled ms | Annotation share of sampled allocation |
| --- | ---: | ---: |
| Numeric | 3.81 | 0.81% |
| Lexer | 17.62 | 2.43% |
| Map | 111.22 | 4.10% |

These are whole-stage costs, not costs solely of `ka_wrap`; allocation sampling
uses a 128 KiB interval and retains documented node-accounting discrepancies.
CPU percentages include the profiled import/request envelope and must not be
substituted for clean compilation-clock shares. The compact wrapper can affect
downstream access/rebuilding, but **allocation removal in the annotation stage
alone cannot justify a large broad gain**. Map lowering accounts for 30.47% of
sampled allocations, layout validation 14.09%, and inclusive substitution ancestry
20.89% (the latter overlaps stages). The whole-work-removal/typed-fact proposals
therefore rank above this representation patch until census/access evidence
establishes a larger applicable cost budget.
