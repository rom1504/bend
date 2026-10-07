# Compiler requests: prepared state and structured emission

The installed baseline is **Phase61 state08**. The
[state08 results](../../implementation/phase61/state08-results.md) bind the checked
B1 package, genuine B2/B3 images, source and completed release gates separately.
Release integrity and all 42 legacy plus 24 default ordinary/relocated CLI checks
pass. The original failed attempts retain their own receipts and scope. These
changes accelerate compiler work; they do not establish faster generated programs.

The [Phase63 candidate](#phase63-candidate-ready-world-and-one-lowering-plan)
extends this architecture with ready worlds, shared graph transport and one
library lowering plan. Its [phase report](../../implementation/phase63/README.md)
records qualification and selection separately; implementation in the source
tree does not itself mean that the installed package has changed.

The compiler owns parsing, checking, specialization and emission in Bend. The
host owns files, cache transport, identity checks and processes. There is no
TypeScript compilation fallback, program-name selector or new general pass
framework. Public core values, quantities, source spans and diagnostic results
remain the contracts. The [backend boundaries](backend-boundaries.md) describe
the existing direct JavaScript, legacy JavaScript and native C separation.

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
reusing emission across different pruned contexts. No such cache was selected.

## Phase63 candidate: ready world and one lowering plan

This section describes State06's candidate mechanisms. Later experiments and
their live source changes are not included here. The phase report is the
authority for selected source, complete gates and measured gains.

| Boundary | Retained value | Request work |
|---|---|---|
| Parser | `FReadyPrefixState`: name and constructor indexes, event count | Extend indexes with new source events and validate the actual suffix. |
| Checker | `KBasePreparedWorld`: raw world/index, checked output, event history and original prefix state | Install suffix headers, rebase fresh counters and check suffix events. |
| Library backend | `JDPlan`: one annotation context, call/SCC facts, reached definitions and rendered bodies | Discover dependencies while lowering each reached definition once; emit saved bodies in source order. |
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

State06's B1 and B2 use **named-layout APIs**. Their measured requests do not
perform positional ABI encoding. The proposed owned-ABI adapter optimization is
therefore not part of this candidate. Frame3 is data transport, and its decoder
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

**One field conversion plan.** In
[`host.bend`](../../selfhost/src/back/js/direct/host.bend), each constructor's
live field converter is computed once. The same immutable `JDHostFields` supplies
tail selection and emitted field conversions. Erased fields remain erased; the
last directly self-recursive field remains the iterative continuation. Field
conversion order, marshalling depth/fuel and the exhausted-telescope refusal
fragment are preserved. This reduces compiler work while retaining emitted
wrapper behavior. It does not eliminate required host value conversion.

## Host transport and evidence boundaries

Frame2 records separately hashed book/checker/freshening JSON segments. Admission
can reuse the verified raw segment digest rather than serialize the parsed state
again. Only newly `JSON.parse`-owned trees use the narrower span walker; generic
public object validation retains its alias/cycle/getter treatment. Required
identity, shape, span, freezing and invalidation checks remain. The binary-codec
alternative passed value checks but was rejected because its required validation
made it slower in the recorded diagnostic.

Compiler measurements distinguish host import, API load and first compilation.
Genuine B2 runs in fresh processes using prepared persistent Base caches;
preparation precedes the clean clock and output validation follows it. This does
not imply cold operating-system/page caches or installed checked-B1 CLI timing. A smaller compiler-request time is
not a generated-program speed result. Likewise, checked B1, an emitted B2, fresh
own-source type acceptance, unsafe proof-trust refusal, B2/B3 byte equality and
installation are distinct gates. The [results matrix](../../implementation/phase61/state08-results.md)
records which actually passed. The [source footprint](../../implementation/phase61/source-footprint.md)
keeps Bend modules, runtime support, host helpers and research/tests separate.
