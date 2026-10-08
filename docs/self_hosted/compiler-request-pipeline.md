# Compiler requests: prepared state and structured emission

**Phase64 State09 is installed and verified.**

**Phase65 State10 is selected for integration; qualification is in progress.**
Its static host decoder transports the same eagerly validated frame4 values.
Its optional Base annotation artifact is produced, selected and admitted by Bend;
only a wanted/admitted request loads the heavy product graph. Public fallback,
current stops and exact source/API/parent-graph identity remain authoritative.
State10 gates both product preparation and sidecar reads on exact qualified Base
content; custom or updated Base uses ordinary annotation until qualified.
See the [artifact contract](prepared-base-artifacts.md#phase65-selected-integration-candidate)
and [Phase65 report](../../implementation/phase65/README.md).

The final [State10 broad comparison](../../implementation/phase65/evidence/state10-b2-broad.json)
passes **207 exact-output checks across 23 sources and three balanced rounds**.
Compilation alone improves **1.41737× → 1.28945× TS (9.025% less time)**; imports
plus compilation improve **1.04969× → 0.969256× (7.662% less time)**, using the
baseline measured in that same campaign. All 23 sources improve; 21 have
nonoverlapping baseline/candidate sample ranges. Four compile faster than TS,
ten are faster including imports. These are genuine-B2 fresh prepared-cache
requests, with preparation and output verification outside timing. Compilation-
only parity still requires about **22.45% less time**; no generated-program speed
gain is claimed. H2's incremental benefit over H6 alone remains under measurement.
Release qualification and installation remain pending.

## Installed Phase64 results

The completed Phase64 metrics and qualification below retain their original
campaign and installed image. Its balanced genuine-B2 campaign passes **207 exact-output workers across 23
sources, three roles and three rotated rounds**. Compared with Phase63 State09
in the same campaign, equal-source geometric means improve **1.64387× → 1.43894×
TypeScript for compilation alone** (12.47% less time), and **1.18920× → 1.06173×
for host/API import plus first compilation** (10.72% less time). Every source
improves on both clocks. Aggregate compilation parity remains unfinished.

These are fresh processes with prepared persistent Base caches. Preparation and
full output verification are outside the clocks; the measurements do not cover
cold OS caches, the installed checked-B1 CLI or generated-program execution.
The [Phase64 results](../../implementation/phase64/state09-results.md) bind the
completed comparison and qualification separately.

The installed package is equality-derived checked B1 (`a2f8b021…`); the measured
genuine B2 is `b09fe54a…`. Full checked and B2 semantic gates, native3 and runtime45
pass. The B2/B3 fixed point is **4,040,799 bytes**. Fresh own-source type acceptance
passes; the 3,254 unsafe definitions retain the expected proof-trust refusal.
Self-check and fixed-point gate durations are 11.90 and 33.42 seconds respectively,
separate from the clean compiler comparison.

[Release verification](../../implementation/phase64/evidence/state09-release.json)
records successful installation, verification before/after CLI testing, legacy42,
default24 including relocation and five helper-integrity controls. The
[qualification index](../../implementation/phase64/evidence/state09-qualification.json)
binds the preceding compiler gates. The
[Phase63 report](../../implementation/phase63/state09-results.md) retains the
historical release and its earlier campaign ratios.

The compiler owns parsing, checking, specialization and emission in Bend. The
host owns files, cache transport, identity checks and processes. There is no
TypeScript compilation fallback, program-name selector or new general pass
framework. Public core values, quantities, source spans and diagnostic results
remain the contracts. The [backend boundaries](backend-boundaries.md) describe
the existing direct JavaScript, legacy JavaScript and native C separation.

The [Phase64 State09 mechanisms](#phase64-state09-retained-facts-and-indexed-transport) extend
the Phase61–63 foundations described below.

## Where Phase61 reuses work

| Work | Implemented mechanism | Main source |
|---|---|---|
| Dependent argument telescopes | Bounded delayed substitutions, materialized under the original demand/order rules | [`env-telescope.bend`](../../selfhost/src/check/env-telescope.bend), [`env-substitution.bend`](../../selfhost/src/check/env-substitution.bend) |
| Exact-name book updates | Compact persistent index nodes and one batch event-list reconstruction | [`index.bend`](../../selfhost/src/core/index.bend), `book_put_many` |
| Base loading and checking | Independently prepared freshening/checker states, carried through actual leading seed injection | [`load/prefix.bend`](../../selfhost/src/load/prefix.bend), [`check/prefix-state.bend`](../../selfhost/src/check/prefix-state.bend) |
| Primitive metadata | Construct the selected canonical row, without building all 90 rows per lookup | [`direct/primitive.bend`](../../selfhost/src/back/js/direct/primitive.bend), `jd_primitive_select` |
| Host type classification | Prove native U32/F32 are Nat-free once per export context | [`host-native.bend`](../../selfhost/src/back/js/direct/host-native.bend) |
| Emission metadata | Compose statement documents with USE/REF summaries before rendering | [`transport.bend`](../../selfhost/src/back/js/direct/transport.bend), `JDText` |
| Cache bytes | Identity-bound JSON segments and validation restricted to newly decoded JSON trees | [`typed-driver.mjs`](../../selfhost/tools/typed-driver.mjs), maintained [`workflow.mjs`](../../selfhost/tools/development/workflow.mjs) |

## Dependent terms without repeated eager rebuilding

For a function with several dependent parameters, substituting the first actual
through the entire remaining telescope can copy terms that the next substitution
will immediately visit again. `env_tele_fill` and `env_tele_check` carry pending
`KTelescopeBinding` values through admitted telescope structure. Checking each
argument still materializes its required domain, applies quantity demand, threads
the resulting world and stops at the original first error.

`env_tele_safe` excludes cases where delaying substitution could skip eager beta
work. At a bound of 64 pending bindings, an exposed telescope boundary or an
unsupported argument, the cursor materializes and resumes the original path.
`env_subst_apply` realizes the admitted environment in order: a replacement may
be affected by later substitutions, never by earlier ones applied a second time.
This is not unrestricted lazy normalization or an unchecked substitution cache.

State08 also lets `subst_node` return an immutable childless `KTerm` unchanged
when its tag is not `App`. Variable replacement and literal/Lambda routes retain
their own rules. This reuses private leaf identity; it does not promise fresh
objects to arbitrary host callers. The separate backend telescope cursor tried
in state07 was reverted after mixed B1 timing and is absent from state08.

## Persistent books keep declaration order

`KIndexLeaf` and `KIndexNode` store trie payloads directly, without filling the
unrelated fields of an ordinary `KDef`. Existing accessors handle both compact
and older forms. Full-hash collisions still compare exact names, and declaration
events remain ordered independently of the lookup index.

`book_put_many` performs the existing trie updates while rebuilding the final
event sequence once. `jd_selected_context` uses it for annotated definitions.
Incoming cache sentinels, unsupported name shapes and detected stale-index cases
fall back to sequential `book_put`. This is a persistent source-level operation,
not mutation of a shared book or a cache keyed only by a definition name.

## A parsed Base book is not a checked checkpoint

Ordinary preparation first performs actual Bend work. `f_fresh_prefix_prepare`
runs the existing freshener and accepts only a prefix exactly equal to its
freshened output, saving the actual next identifier. Its two-field state is
separate from `base_prefix_prepare`, which runs the checker and derives checked
publication patches, fresh-counter advance and world stamp. Readiness requires
closed names, compatible declarations, empty specialization memo and exact
reconstruction of the checked/raw world components.

On a request, `FPrefixGraph` becomes ready only through successful leading,
global Base seed injection. `f_prefix_complete_source` retains the actual suffix through
ordinary source completion. `f_prefix_graph_trace` keeps whole-graph validation,
name/error checks and origin refinement, but freshens that suffix from the saved
counter. An error or ineligible carrier uses the ordinary full freshener.

`base_prefix_check_load` consumes this private loader result, not an independently
asserted suffix. It reestablishes the declaration context, checked publications
and fresh floor before checking suffix events. Disjoint-name/constructor and
state bounds still apply; unsupported state uses full checking. State08 computes
`max(max(prefix), max(suffix))` once and reuses the prefix bound for admission,
avoiding repeated scans without changing the identifier floor.

The host binds these optional states to the exact API, Base bytes, path, interval,
schema and payload; missing or invalid state selects the old path. Public raw
loader/checker calls do not acquire private permission just by supplying a book.
This is a trusted-local prepared-state contract, not cryptographic proof against
a caller forging both a payload and its digest. No second full Base book is
serialized merely to carry its freshening state.

The seed's name/path/full-text checks remain exact. `f_seed_text_equal` now uses
canonical primitive `String.eq`, including malformed UTF-16 code-unit equality;
it does not relax the seed to a prefix match or hash-only admission.

## Native facts stay local to the export context

`jd_host_native_context` asks the unchanged bounded Nat classifier whether the
actual native nullary U32/F32 owners are Nat-free. Only completed zero results
install facts in a reserved immutable analysis definition. Preparation overwrites
that definition, including failed facts; it is never emitted as a source export.

`jd_host_nat_known` can then treat an actual nullary proved owner as a leaf.
Unknown, positive, parameterized or unprepared cases retain the original query.
The internal 1,024-visit budget now counts proved native leaves rather than their
hidden Word graph, so some formerly budget-refused graphs can complete. This
intentional resource-policy change does not drop required Nat conversion. The
public classifier and marshalling depth bound of 64 remain unchanged.

Primitive selection is a separate optimization: `jd_primitive_select` constructs
only the matching metadata row. Native identity, arity, telescope and emission
admission stay authoritative; a user definition with the same spelling does not
become an intrinsic merely because the row exists.

## Statement documents preserve the emitted metadata contract

`JDText` contains raw expression leaves, append nodes, saturated code-point size,
USE/REF notes and a conservative safety bit. `jd_doc_*` functions compose lambda,
Let, match, choice, tail-transfer and shared-SCC statements without first joining
all text. `jd_text_used` answers demand questions from notes; `jd_text_refs`
collects ordered, validated dependency edges. Explicit worklists handle skewed
append trees. Final rendering retains the original text bytes.

This is a partial migration: `JDOrdered` expressions and native templates still
produce raw leaves, whose metadata is scanned. Expression/closure boundaries
may still render strings. Ambiguous cross-leaf marker boundaries or malformed
metadata fall back to the old whole-string query. The 2,097,152-code-point limit,
unknown-reference refusal and duplicate-edge policy remain. Internal fragment
boundaries must not split a UTF-16 surrogate pair; arbitrary rope fragments are
not a newly supported public API.

Demand remains defined by the emitted representation. An unused binding must
not cause its RHS, references or effects to be introduced; ordered operands,
branch scope, capture, aliasing and SCC member retention stay intact. A diagnostic
found equal retained text/facts on 23 inputs, but that is not a general proof for
reusing emission across different pruned contexts. Phase61 did not select such a
cache. State09 instead retains one complete context through library lowering and
emission, as described below.

## Phase63 State09: ready world and one lowering plan

This historical section describes the Phase63 State09 source measured in its
completed B2 campaign. That release passed its separate gates; the
[results report](../../implementation/phase63/state09-results.md) and
[qualification index](../../selfhost/build/phase63/final-state09/qualification.json)
are the authority for completed gates and release status. Rejected experiments
are not part of these mechanisms.

| Boundary | Retained value | Request work |
|---|---|---|
| Parser | `FReadyPrefixState`: name and constructor indexes, event count | Extend indexes with new source events and validate the actual suffix. |
| Checker | `KBasePreparedWorld`: raw world/index, checked output, event history and original prefix state | Install suffix headers, rebase fresh counters and check suffix events. |
| Library backend | `JDPlan`: one annotation context, call/SCC facts, reached definitions and rendered bodies | Discover dependencies while lowering each reached definition once; emit saved bodies in source order. |
| Call analysis | Arity already computed during the body scan, retained in the existing call-fact index | Reuse it for definitions of that immutable emission context; other inputs use the original query. |
| Export wrappers | `JDHostFields`: field names and their converters | Select the final self-recursive field and produce field output from the same plan. |

**Ready frontend and checker.** Preparation derives the parser indexes from the
same validated Base book and creates the checker snapshot through the existing
checked-prefix resume path. The raw unfolding book and elaborated checked output
remain separate. The prepared world retains actual indexes and term references;
it is more than a marker that says Base previously passed checking.

Only an authenticated leading global Base injection admits the ready loader
carrier. Parsing, qualification, fill ordering and origin refinement still run
for new modules. The loader maintains latest-event name lookup and first
depth-first constructor lookup, checks the suffix against the saved Base scope,
and freshens that suffix from the separately admitted counter. Old/raw carriers
keep whole-graph validation and freshening.

State09 also carries the actual newly completed module fragment through
`FIndexedCompletion`. The ready carrier appends that fragment to its existing
suffix and updates its indexes, avoiding two walks over the Base event spine to
rediscover the same boundary. Its private invariant is
`graph.book = prefix ++ suffix`: the prefix is the admitted seed and the suffix
consists of actual successful completion fragments in order. It is established
by the loader, not inferred from a caller's event count. Errors retain the whole
graph and select the original fallback. Raw carriers still rediscover their
suffix through the existing checked path. Manually constructed or modified
`FReadyPrefixGraph` values are outside the private producer contract: matching
counts alone do not authenticate their prefix, suffix or indexes. Public raw
entry points keep their permission or structural checks; supplying prepared
fields to `discoverSources` cannot grant the private path.

The checker extends the saved immutable index with suffix headers and retains
the historical declaration-list order. It reuses the prefix maximum, checked
output and event history. Name intersection queries now scan suffix names
against the saved index. Bounds, reserved names and constructor collisions still
control admission. A full 32-bit hash collision between a Base name and suffix
name selects old prefix replay, preserving exact index bucket order as well as
lookup results. Invalid admission uses the ordinary full checker.

**Shared prepared transport.** Frame3 in
[`base-cache-graph.mjs`](../../selfhost/tools/base-cache-graph.mjs) stores a
mandatory raw-book graph and optional prepared-state graph. Exact structural
interning includes source intervals and flags; state can refer to book nodes
without serializing each copy. References point backward, excluding cycles and
dangling edges. Specialized constructor decoding validates scalar values, child
categories, list element types, literal payloads and ranges as it constructs
named ADT objects. The 128 MiB segment and 1,048,576-node bounds remain explicit.

Both segments have digests. API/Base bytes, canonical path, interval, ABI and
producer metadata remain required. The admitted world's `prefix` must be the
decoded mandatory book root, and its `state` must be the admitted checked-state
root. The private driver couples that same seed to the loader carrier. Shape and
hash validation preserve a trusted-local producer relationship; they are not a
proof that an arbitrary supplied index or checked world is semantically valid.
Invalid optional state drops the accelerators. Invalid mandatory bytes fail
admission; an absent newer cache may fall back to frame2/frame1. Public object
validation and caller-supplied API paths retain their prior behavior.

The measured Phase63 B1 and B2 images use **named-layout APIs**. Their requests do not
perform positional ABI encoding. The proposed owned-ABI adapter optimization is
therefore not part of that Phase63 release. Frame3 is data transport, and its decoder
does not implement parsing, checking, lowering or compiler analysis in JavaScript.
The persistent inspector still supports parse/check modes only.

**One context for library lowering.** `jd_plan_selected` in
[`reach.bend`](../../selfhost/src/back/js/direct/reach.bend) owns the complete
annotation overlay and call/SCC facts until emission finishes. Runtime pruning
does not remove type information from that context. Reachability consumes each
definition's actual `JDText` references, validates metadata and saves the rendered
body in an exact-name index. `jd_plan_library` emits those saved bodies in
original definition order, then generates exports under the same context.

This deliberately replaces the former distinction between an all-annotation
reachability context and a pruned-annotation final context. It is not arbitrary
cross-context cache reuse. Context, alias, demand and refusal controls are
required alongside byte comparisons; the
[backend design](../../implementation/phase63/backend-plan.md) records those
obligations. The 4,096-definition, 65,536-worklist and document metadata bounds,
SCC member retention and unknown-reference failures remain. The driver selects
this plan for direct JavaScript **library mode** when its APIs exist. Program
mode, older images, legacy JavaScript and native C retain their existing paths.

State09 retains the arity that call analysis already computes for each ordinary
body. A `JDArity` marker travels through component construction into the existing
call-fact index; it requires neither a second index nor another body scan.
`jd_emitted_arity` consumes that fact only for definitions belonging to the
completed immutable emission context. Native/foreign rows without a saved fact
and contexts without call analysis use the original `jd_arity` computation.
The raw query remains unchanged for arbitrary public books and definitions;
the private fact is not a name-only cache valid after changing a context.

**One field conversion plan.** In
[`host.bend`](../../selfhost/src/back/js/direct/host.bend), each constructor's
live field converter is computed once. The same immutable `JDHostFields` supplies
tail selection and emitted field conversions. Erased fields remain erased; the
last directly self-recursive field remains the iterative continuation. Field
conversion order, marshalling depth/fuel and the exhausted-telescope refusal
fragment are preserved. This reduces compiler work while retaining emitted
wrapper behavior. It does not eliminate required host value conversion.
State09 removes the four unused legacy tail/field traversal helpers, retaining
the shared tail-selection helper used by the field plan. Together with the
suffix handoff and arity facts, State09 has 11 fewer Bend source lines than
State06; this small source reduction is separate from performance qualification.

## Phase64 State09: retained facts and indexed transport

These mechanisms are selected in the installed Phase64 State09 release. The
[Phase64 results](../../implementation/phase64/state09-results.md) keep local
experiments, completed compiler measurements and release gates separate.
The changes below preserve the existing Bend parser/checker and lowering plan;
they retain facts at existing demand points or remove work whose result was
unused. They do not introduce a general memo table or a replacement compiler IR.

| Boundary | Additional retained work or removal | Contract |
| --- | --- | --- |
| Successful checker completion | `KBasePreparedWorld.todos`, counted from final original Base events | Add the actual suffix count only after successful checking and admitted name/constructor separation. |
| Checked-output context | `KBasePreparedWorld.checkedBound`, the exact maximum in saved checked output | Combine with the actual assembled suffix maximum; preserve the full ordered context/index and ordinary public fallback. |
| Export signatures | `JDHostSignature`: final result plus instantiated telescope heads | Reuse only within that definition, context and arity; preserve result/input/copyback conversion order. |
| Recursive tail admission | `jd_argument_shape`: remaining actuals/type and missing formals | Omit expression strings discarded by admission; the selected ordered emitter still renders the arguments. |
| Small name queries | Exact native-layout and Array-operation equality classifiers | Keep tag/native ownership checks and the original substring fallback for delimiter-bearing names. |
| Owned-name policy | Filter native declarations before fixed-order ownership queries | Keep original order and full-book foreign/constructor collision checks. |
| Prepared transport | Frame4 indexed constructor/string tables | Fully validate and materialize the same ADTs; preserve shared roots and optional capability fallback. |

The [prepared Base artifact guide](prepared-base-artifacts.md) explains the
version-three world fields, actual checker-result coupling, frame4 tables,
frame3 compatibility and source/API invalidation. In particular, the raw prefix
maximum is not substituted for the exact checked-output maximum: checking may
introduce identifiers. The context optimization still constructs the complete
index; it avoids only rescanning the immutable checked prefix's terms.

In [`host.bend`](../../selfhost/src/back/js/direct/host.bend),
`jd_host_signature` retains the heads already normalized by the existing result
walk, after the same dependent `Absent` substitutions. Arguments and copybacks
reuse those heads rather than traversing the telescope independently. Terminal
normalization, erased argument indexing, malformed-telescope behavior and
marshalling refusal bounds remain. The raw host queries remain available; this
is not reuse across annotation books or export contexts.

In [`core.bend`](../../selfhost/src/back/js/direct/core.bend),
`jd_argument_shape` follows the same telescope normalization/substitution as the
old argument query but omits values that `jd_doc_return_self` never consumes.
The actual transfer or regular emitter preserves argument order, demand, effects
and emitted text. This differs from the rejected child-type prototype: that
prototype's extra annotation guards passed local comparisons but regressed its
clean screen, and it is not part of the selected source.

The name classifiers in
[`constructors.bend`](../../selfhost/src/back/js/direct/constructors.bend) and
[`validate.bend`](../../selfhost/src/back/js/validate.bend) preserve the old
substring behavior for names containing `|`; a plain set would change that raw
input contract. The policy filter in
[`api.bend`](../../selfhost/src/driver/api.bend) removes native declarations only
from owned-name checks, where they cannot violate the rule. Foreign-definition
and constructor collision checks still receive the full original book.

Compact annotation nodes, lazy Base-body materialization and general dense-ID
migration are not selected. Existing annotation representation and eager ADT
materialization remain. Local codec or B1 experiment results must not be used as
a replacement for the completed genuine-B2 comparison and release gates.

## Host transport and evidence boundaries

Frame2 records separately hashed book/checker/freshening JSON segments. Admission
can reuse the verified raw segment digest rather than serialize the parsed state
again. Only newly `JSON.parse`-owned trees use the narrower span walker; generic
public object validation retains its alias/cycle/getter treatment. Required
identity, shape, span, freezing and invalidation checks remain. The earlier Phase61 binary-codec
alternative passed value checks but was rejected because its required validation
made it slower in the recorded diagnostic. That rejected implementation is
distinct from the selected Phase64 indexed-table transport described above.

Compiler measurements distinguish host import, API load and first compilation.
Genuine B2 runs in fresh processes using prepared persistent Base caches;
preparation precedes the clean clock and output validation follows it. This does
not imply cold operating-system/page caches or installed checked-B1 CLI timing. A smaller compiler-request time is
not a generated-program speed result. Likewise, checked B1, an emitted B2, fresh
own-source type acceptance, unsafe proof-trust refusal, B2/B3 byte equality and
installation are distinct gates. The
[Phase64 results matrix](../../implementation/phase64/state09-results.md) and
[qualification index](../../implementation/phase64/evidence/state09-qualification.json)
record which actually passed. The historical
[Phase61 source footprint](../../implementation/phase61/source-footprint.md)
keeps Bend modules, runtime support, host helpers and research/tests separate;
its counts are not a new Phase64 census.
