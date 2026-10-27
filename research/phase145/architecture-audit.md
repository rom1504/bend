# Phase145: what our native compiler does that upstream does differently

Read-only source/artifact investigation at `d283c10`, 2026-10-27. No compiler,
generated target, or benchmark was executed, and no production source changed.
The current qualified candidate is **final04**, source
`865cff6a02da261952cac824bed0fe91882e60f1c6e4062fbe57f5804745c4ed`, in
[`implementation/phase144/final04/candidate.json`](../../implementation/phase144/final04/candidate.json).
The source citations below refer to its frozen
`selfhost/build/phase144/final04-source01/compiler.bend`.

The strongest architectural opportunity is to stop turning private numeric
identities and typed facts into strings and generic records at every backend
boundary. However, **record shrinkage alone is not the experiment to repeat**:
the retained compact-verifier experiment demonstrates that generated execution
shape can erase most of its benefit. A second, cheaper investigation should
measure repeated validation of the same immutable raw program and repeated
construction of its metadata. Neither finding justifies deleting the independent
final verifier or rewriting the entire compiler.

## What is measured, and what is not

Final04's fixed-source native request takes231.682s; source-to-machine including
QBE/as/link takes247.000s. Those are individual controlled observations, not a
new upstream comparison. The available full residual capture is **final03**,
not final04:8,681 samples, no losses,99.497% coverage. Its disjoint diagnostic
intervals include43.436s admission/static/raw lowering,56.247s initial optimizer
and first verification,23.352s observer/final admission,17.651s registry, and
49.962s rendering/output/teardown. Its conditional10.081s final verification is
inside observer work; it must not be added again.

The final03 source-owner verifier family has1,222/8,681 samples (14.08%). Physical
drop/fade17.04%, take11.40%, constructor5.38%, and register transport7.17% are
overlapping source/physical attribution views, **not additive removable budgets**.
See [the exact profile and caveats](../phase144/final-profile.md). Final04 changed
range policy, append admission and prefix-disjoint checking after that capture.

No retained complete final04 checked-`KTerm` snapshot was found for this audit.
The trace below therefore identifies the source-to-`KTerm` representation from
the selected implementation, uses an actually retained accepted raw/direct IR
slice, and establishes an exact worker bridge to final04 QBE. It does not label
an older snapshot as a fresh final04 capture.

## One concrete trace: Lexer `slot.go`

The real function at `selfhost/build/phase88/broad-fixtures03/lexer.bend:106`
matches three Booleans and returns one of four nullary constructors. The same
declaration in the current timing wrapper,
`selfhost/build/phase93/fixtures01/lexer.bend:106`, is byte-identical after trimming
the declaration block; its SHA-256 is
`ee232a268729d67e9f4260266a2ab7e446cce5b1e52d63abe83c17f2d1e57f81`.

| Boundary | Actual representation and reconstruction |
| --- | --- |
| Checked/erased syntax | `KTerm` at source:41 retains a numeric `id`, textual tag/name, children, erasure and origin fields. `KDef` at47 is a nine-field definition record also used for index nodes/payloads. This representation is not itself low-level SSA. |
| Native binding | `nk_binding` at30671 and `nk_field_binding` at30683 retain the numeric ID **and** build `"v_" ++ U32.show(id)` in `NC_Binding`. Related producers independently spell synthetic local names. |
| Raw low-level body | `N111Local` at38826 contains only a `String`; statements at38836 also carry textual destinations/operators/import symbols. The numeric binder identity is no longer the lookup key. `N111Segment` holds a linked statement list. |
| Raw verifier | `p111v_segment` at39947 builds a complete schema, then flow-checks the body. `p111v_decl` looks up and writes each destination; `p111v_assign` at39715 looks up that schema again and copies its projected fields into the live map. |
| Optimized direct body | `P113DScalar` wraps the existing scalar statement. `P113DFunction` at43858 keeps typed parameter bindings but body references remain textual. Direct schema/flow checks reuse the raw verifier (`p113e_schema` at44427, `p113e_function` at44549). |
| Facts and optimization | `p113k_get/put` at47416/47424 pack range facts into generic `KDef` records plus `KTerm` metadata and recover them by string name. Renaming during inlining creates prefixed names; transformed bodies are reconstructed as persistent lists. |
| Emission | `p111q_local` at40072 prefixes the textual local again (`%v_`); `p111q_value` at40093 resolves textual function/constructor IDs against another index. Global emitter IDs are rebuilt in `p111q_ids` at40245. |

The accepted raw slice is
`selfhost/build/phase144/verifier-screen01/lexer-raw.json`, SHA
`a563dd69b68d6aef0094c25b57297bcf8d6f361276bc59f05a4b2da7f197af66`.
Its `$direct.slot.go` segment contains88 statements:42 binary operations,
11 calls,11 sets,8 stores,8 returns,7 conditional nodes and one allocation.
An offline complete-tree count gives65 destination occurrences (21 distinct)
and102 `N111Local` occurrences (22 distinct). Their textual contents total733
and1,025 characters respectively. These are syntax counts, **not allocated bytes
or dynamic hash calls**: sharing, short circuiting and compiler optimization
matter. Nonetheless, every actual local lookup reaches `p111v_get`, which
recomputes `index_hash(name,2166136261)`; the producer's numeric ID is unavailable
at that interface.

The direct product retained in
`selfhost/build/phase144/range-second-pass02/lexer-range-products.graph.json`
has79 direct nodes,64 scalar nodes,7 conditionals and no direct calls for this
function. Its complete before/after outer-range bodies are equal. The graph
preserves aliases, including shared parameter lists. The underlying source for
this capture is pinned in that run's report; it is not silently replaced with
final04. The14 audited representation/verifier declarations (`N111Value`,
`N111Stmt`, `P113DFunction`, get/put/assign/schema/schema_stmt/value/memory/join/
segment, `p113e_function`, `p134v_commit`) match final04 exactly.

Finally, the complete99-line QBE worker for `$direct.slot.go` is byte-identical
in both `phase144/range-skip-baseline-emit01/lexer.ssa:1642` and actual final04
`phase130/p144-final04-wrapper-lexer/program.ssa:1649`. Worker SHA-256:
`6da5ff497243804b908dd90107999ae8bf6cbe11ae098de5e88a466599a5bc7a`.
It retains the public full-word parameters, local copies, and raw/packed Boolean
admission checks. This is an exact local bridge across differing whole requests,
not whole-IR identity. The final04 program-quality receipt also establishes the
whole Lexer object's equality to its retained selected product.

This trace concerns the compiler work needed to produce/check that worker. It
does not show that the worker dominates Lexer execution or compiler execution.

## Repeated work versus necessary independent checks

There are three distinct categories; conflating them leads to weak proposals.

**Extra algorithmic work.** `p114s_open` at48271 calls `p112s_verify`, which calls
the complete raw verifier and static-image checker. It then checks all direct
functions and constructs their ready table. Ordinary `p128raw_session_finish`
at55986 retains that immutable original through the optimizer. Later
`p128raw_lowered` at55977 calls `p113a_verify`; through `p114t_original_verify`
at49707 and `p113e_verify` at44584 it checks the raw/static original again and
rebuilds original-function/constructor metadata and direct schemas.

This is a real repeated traversal in the selected source. Its precise repeated
cost is not separately timed. The observer closure may subsequently validate
the assembled direct functions again via `p126bp_complete` at54119, but that
path calls `p118b_verify_functions` and must not be described as another full
raw-image check. Emission's `p134e_prepare` at57361 constructs IDs, fusion/region
indices and tables; it is not another independent verifier.

`p134v_commit` at57808 **already avoids** rechecking unchanged direct bodies.
It first compares headers, then `p134v_check` deep-compares bodies and verifies
only changed functions while rebuilding the ready-signature prefix. Therefore
"cache unchanged verification" is not a new plan. An exact identity/provenance
channel could replace some structural equality work, but it must outperform
the current equality walk and preserve dependency/order identity. Phase134's
rejected memo/equality approaches are relevant negative evidence.

**Representation/execution expense.** Each local fact is a nine-field `KDef`
although only name/kind/width/capacity are used. Live assignments reconstruct
rows from the schema. Branches persistently fork live maps; nonterminal joins
look up every retained row in the other branch and reconstruct an intersection
(`p111v_intersection_bucket` at39738). These operations use strings, generic
Patricia indices, tagged values and generated ownership/transport paths. A
single required verification traversal can therefore still be expensive.

**Additional guarantees.** The independent backend verifier checks definite
assignment, width consistency, bounded/aligned pointer access, exact imported
runtime signatures and buffers, public ABI preservation, topological direct
call availability, terminal-edge rules, and reserved-template namespaces. The
schema pass deliberately has error precedence over flow checking. These are
structural/backend admission guarantees, not a theorem of source-to-machine
semantic equivalence. Source checking and the inherited11 proof declarations
do not prove this verifier or the complete compiler.

The final verifier should continue to derive its own facts from the actual
candidate. A producer's cached `valid=True` must not replace it. It is possible
to retain independent checking while changing local storage, checking one
immutable original once inside a sealed request lifetime, or carrying a
verified schema through unchanged private stages; each requires an explicit
freshness/identity contract and preserved public rejection behavior.

## What upstream actually does

Working-tree `bend2/comp.ts` is byte-identical to the active upstream pin
`selfhost/.bootstrap/upstream-phase66/bend2/comp.ts`, SHA
`2b13224ba09a9e39e37cccf06e449c1bdafe5e03a81641654f7d0e455507629c`.
The comparison is source-backed; this audit performs no new timing comparison.

Upstream's `Lay`, `Val`, `Bind`, `Seg`, `File` and `Scope` types at20–100 keep
layout, words, usage, parameter kinds, frame information, reference edges and
fact caches together. `Scope.uses` is keyed by opened variable objects;
`term_uses` at768 memoizes by `HTerm` identity and uses numeric variable IDs in
its persistent map. `name_id` at551 memoizes encoded output identities.
`file_push` at1494 appends generated source to a mutable `Seg.lines` array.
There is no separately materialized `N111`/`P113` instruction graph followed
by a separate raw/direct verifier in this emission path.

However, upstream does real analysis and reconstruction. `compile_book` at2768
re-emits until ownership/hot/static facts reach a fixed point, clearing output
and several caches between rounds. `seg_open` at1554 renames live words and
rebuilds scope bindings across continuations. `emit_body` at2470 performs ANF,
layout and call decisions; it is not a trivial single pass. C/Clang later
handles machine optimization and C validity, which is a different boundary
from our exact runtime-import/capacity/namespace verifier.

The useful difference is **which facts remain attached to the computation and
which data structures execute the analysis**, not merely the number of named
passes. Upstream's mutable host maps/arrays and typed records are also not a
free capability of the current generated Bend compiler. A Bend implementation
must retain affine/ownership semantics and measure its actual generated loops.

The older [Phase83 investigation](../../implementation/phase83/README.md) makes
this warning quantitative: one Numeric allocation sample recorded B2 allocating
100.80MB versus upstream145.45MB, while B2 remained slower. That JS-hosted sample
is not a native-final04 measurement, but it falsifies the general inference
"fewer allocated bytes implies parity." Phase144 supplies a current native
analogue: shrinking verifier records gave1.90% slice gain when it lost direct
workers; adding a genuine absent constructor restored direct workers and gave
11.06%. QBE grew between those variants while runtime improved.

## Three falsifiable architectural hypotheses

### 1. Dense private local identities plus separate immutable schema and flow state

**Claim to test:** retaining numeric local identity through producer, optimizer,
verifier and renderer removes more work than compacting generic rows. The
schema's width/name/allocation facts are immutable; definite assignment and
dynamic pointer capacity belong in flow state. Most assignments need not copy
the schema into a fresh generic row.

Small interface sketch: `LocalId`, a per-function dictionary of original names
and widths, and flow `{defined, capacity}` indexed by that identity. Preserve
the string dictionary for diagnostics and namespace admission; repeated writes
to one name retain one identity. Do not interpret existing large/wrapping
binder IDs as dense array indices. Synthetic temporaries require explicit
interning or a structured namespace. Branch state must preserve the exact
intersection/capacity-zero rule and original first-error order.

**Cheapest discriminator:** reuse the eight real Lexer verification bodies and
actual metadata catalogue from `verifier-lexer-slice01`. Measure a complete
convert/build/schema/flow/join/error/reclaim cycle, first with sparse numeric
keys, then only if useful with array/bitset state. Independently reconstruct the
original full states and errors. Keep the old final verifier unchanged. Include
conversion and original-name storage; a lookup-only test is insufficient.
Require the generated direct-worker/call shape to remain comparable. Reject if
the complete slice is flat, if conversion dominates, or if admission regresses.

Potential reach is verification, range facts, rename/rewrite tables and output
names. The11.06% prior slice gain is evidence of opportunity, not a predicted
whole-request gain. Only a measured full backend budget can support a2× claim.

### 2. One immutable backend context with independently checked acceptance boundaries

**Claim to test:** repeated reconstruction/verification of unchanged global and
raw facts is substantial enough that a request-local accepted context pays for
itself without a general cache. Keep raw/static identity, global signatures and
constructor layouts together; pass them through private stages instead of
reconstructing equivalent generic indices. A separate final check still inspects
the actual transformed functions and derives safety facts independently.

**Cheapest discriminator:** count `p112s_verify`, `p111_verify_program`,
`p111v_schema`, `p113e_schema`, `p113e_originals`, `ns_ctor_index`,
`p113e_signatures`, `p111q_function_ids`, plus deep equality in
`p134v_function/p134v_stmt`. Partition by open, commit, independent final check,
observer and rendering. Bind counts to exact input body identities; count
function/statement rows and hashed name characters, not only function entries.
The parallel profile investigation has been given these exact declarations.

The first candidate should remove one proven duplicate preparation inside the
private request, with the same final verifier and byte-exact products. Do not
introduce a persistent cache, hash-only acceptance, or a publicly forgeable
validation token. Mutating a body/header/layout, reordering a callee, changing
an import contract, and mixing request contexts must all invalidate reuse.
Reject if duplicate preparation is small or identity checking costs as much as
the avoided work. This is the cheapest high-information next measurement.

### 3. Optimize the execution of complete analysis computations, not isolated data types

**Claim to test:** generic boxed result/continuation transport, rather than
metadata size, is a large part of a required analysis traversal. A compact IR
will disappoint unless its complete queries, updates and consumers compile
into direct loops with coherent ownership.

The Phase144 compact verifier is already a useful counterexample: four-field
records lost ready direct lookup/value workers; a real absent sum restored
them. The later finite-product retry recovered7.51% on the compact complete
slice but added **zero** ready workers for the original hot verifier. Thus a
global retry pass is not established as a current compiler speed opportunity.

**Cheapest discriminator:** compare exact generated paths for one complete
`p111v_stmt → p111v_step → p111v_assign → map update` region, including branch
joins and reclamation. Count scheduler transitions, retained/captured words,
constructor/take calls and primitive name work by region. Test one source
spelling or narrowly admitted private region that preserves the same schema,
decisions and errors. Demand transfer to a range-fact or registry computation;
an isolated helper or absent hot worker is insufficient evidence.

This is a compiler capability experiment that can benefit unrelated programs,
not a second hand-written verifier. Reject a change that merely moves work
between helpers, suppresses a required check, or grows the optimizer without
reducing the complete computation. Preserve boxed fallbacks, stack bounds and
final verification.

## Recommendation

Run the identity-bound counters for hypothesis2 while implementing only a small
complete-computation discriminator for hypothesis1. Use hypothesis3 as a
mandatory code-generation audit of that discriminator. This ordering can reveal
whether the next major gain is fewer traversals, cheaper necessary traversals,
or better native execution of the same algorithm before committing to an IR
rewrite. Continue the separately owned output-boundary investigation; its
registry/render budget is another large category, not a reason to inflate the
verifier's attainable ceiling.

Stop counting record fields, static helper calls or removed source lines as
speed predictions. Do not add the historical slice gains, physical samples and
stage times together. The ambition is a coherent private backend computation
with fewer reconstructed facts; parity remains an experimental target.
