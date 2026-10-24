# Three architectural opportunities grounded in the current Bend compiler

Source audit at `d6367525de6935f0615e3fd1528a853d1dd4b17e`, 2026-10-24.
No compiler builds, target executions or production changes. The selected
Phase131 source remains `1bc5930edcf80cda6c3572645df3c846fa631a83c2b936f20c83b05e0a6728f9`;
the Phase132 spelling edit is an experiment, not a promoted successor.
[Input identities](bend-opportunities-inputs.json) pin the source and reused evidence.
Source line references below identify the reconstructed qualified `compiler.bend`.

The highest-leverage change is **reusable semantic queries and owner units before
global binding**, supported by compact per-unit storage and bounded rendering.
These are three concrete changes to existing boundaries, not a request for a
universal IR rewrite. A different machine backend does not remove the work
observed before QBE starts.

## What the Zig comparison contributes

The [existing Zig0.15.2 source study](../compilers_architecture_and_techniques/zig.md)
identifies immutable syntax lowering, per-function typed AIR, indexed canonical
values, separate operand liveness and an explicit codegen boundary. Its evidence
is pinned to that release; it does not establish current Zig behavior or a Bend
speed forecast. The important transfer is controlled representation lifetime and
consumed semantic information, rather than copying Zig's language or backend.

The coordinator-provided Phase1330.17 source adds a useful counterexample to the
idea that every IR must be tiny. `src/Zcu.zig:5358`, `CodegenTaskPool`, documents
MIR commonly around20× AIR and an observed worst case around50×. Its10MiB AIR
in-flight budget is intended to bound AIR/MIR around500MiB under that assumption.
The mechanism is bounded in-flight work and release, not a claim of10MiB total
compiler RSS. The exact inspected file hash is in the input receipt; the parallel
Zig research supplies its release/commit provenance.

Bend should similarly separate persistent compact facts, transient lowering
state and expandable emitted/machine forms. More concurrency without a byte
budget can multiply the current2.9GB peak instead of reducing latency safely.
Start with one producer/consumer lane and explicit ownership; parallel scheduling
can follow once the memory and dependency contracts exist.

## 1. Semantic-query interfaces and immutable owner units

### Current barrier

`p111_compile_defs` at40048 processes a whole name list and carries `fresh` across
definitions through `p111_compile_step` at40040. Anonymous continuation names
`$p111.k.<n>` come from that global state (`p111_name`,39791). Final FIDs and CIDs
are assigned by list position (`p111q_function_ids`,40737;
`p111q_constructor_ids`,40744). Static constructors are interned in encounter
order (`p112s_intern`,42160), then embedded as numeric tagged words
(`p112s_word`,42103).

There are already named IR references: `N111FuncId` and `N111CtorId` contain
semantic names until final rendering (`N111Value`,39335). Preserve that useful
boundary. Bind persistent literal references symbolically too; do not make an
owner's reusable result depend on the global static pool's current offset.

The Phase132 real edit demonstrates the cost of current identity choices: one
source helper with two equal-length local spelling changes altered476 function
bodies and two data declarations.377 functions changed only recognized decimal
copy operands, all observed deltas+12. This supports a pool-position hypothesis,
not proven decoded literal equivalence. The prototype correctly invalidated
exact bytes rather than normalizing unverified numbers.
[Actual edit results](../../implementation/phase132/incremental.md).

Optimization is also global today. `p128raw_prepared` at56427 produces both
ordinary segments and private candidates. `p128raw_plan_finish` at56421 retains
the raw candidates; `p128raw_session_finish` at56517 keeps them through further
passes. `p131p_closed` at57631 retries candidates against the *actual* merged
helper signatures. Refusal/absence is therefore a dependency, not just a lack
of information that can be ignored.

### Coherent change

Introduce a small immutable **owner unit**, normally a source definition or
dependency SCC plus its generated closures/continuations/private alternatives.
Give generated names owner-local identities. Keep these identities separate from
content hashes and final numeric ABI IDs. A final binding step resolves the
current FID/CID/literal map and verifies cross-unit consistency.

Cache the precise semantic queries consumed by a unit, not merely “function
hash and public type.” Useful query classes are:

- Definition type, reducible value/body and specialization inputs.
- Constructor layout, quantities, ownership and exact constructor identity.
- Effect/escape and checked borrowing contracts.
- Inlineable body/use summaries and local calling convention.
- Private-worker readiness, refusal reason and negative lookups.
- Literal content/graph identity, separate from placement in an image.

Changing a body can invalidate dependent typing even if the public type spelling
is identical. Conversely, an implementation change that leaves a particular
consumed layout or ownership summary identical need not invalidate every user
of that summary. Keep producer/checker/policy/runtime epochs explicit.

The first implementation can conservatively key the entire relevant environment
and refine one query family after evidence. Do not claim fine-grained reuse while
quietly depending on a whole-book hash; record the misses honestly. The final
independent verifier remains mandatory at this stage.

### The assembled source is a separate invalidation boundary

The selected compiler arrives as one2,667,581-byte input. Its source preparation
already has module provenance: [compiler.json](../../selfhost/src/compiler.json)
lists ordered authoring modules, and the selected Phase131 source manifest records
302 explicit declaration overrides and34 pinned inputs. These are not checked
module interfaces. The overlay tool's declaration regex and `checked:false`
manifest explicitly establish composition only, not parsing or semantic reuse.

A file/fragment syntax cache can reuse the **existing parser**, keyed by exact
content, parser version, relevant parse context and source-origin information.
Keep the same namespace, declaration order and forward declarations as the
assembled input initially. Replacing concatenation with ordinary imports is not
automatically equivalent: imports can change names, order, scope and diagnostics.
Parse cached authoring fragments through the current frontend and assemble their
results in the same order; compare complete freshened graphs and error/origin
behavior with parsing the original giant file before adding semantic reuse.

There is already bounded reuse machinery to learn from:
`f_fresh_prefix_prepare/result` at15853/15891 admits only an exact canonical
leading prefix and otherwise uses the original freshener.
`base_prefix_admitted_bound/resume` at10476/10494 checks bounds, names and
disjointness before resuming checked prefix state, with full-check fallback.
These are useful real contracts, but do not permit arbitrary cached middle
definitions whose bodies, freshness or dependent consumers changed.

The cheapest lowering-unit experiment can retain full independent source checking:
Phase132's full-book check plus minimal helper API took5.48s, not a measured pure
checker duration. Native checking and the final whole-IR verifier have separate
unisolated costs. This can still be a useful first10–30s warm loop; it cannot
support a subsecond claim. Near-second iterations ultimately require correctly
bounded parsing, dependent checking and verification, not only fewer objects.

The current direct-QBE route does not establish that Bend parallel-call syntax
will run these tasks concurrently. First test frozen independent units in bounded
separate processes with immutable inputs, a byte budget and one coordinator. That
has explicit acquisition/serialization costs and is distinct from implementing
multicore semantics in the generated compiler.

### Smallest falsifiers and bounds

First retain the actual checked compiler book and trace `nc_ctor_owned` queries.
Build a once-per-book exact ownership summary; compare construction+all lookups
against the existing scan, preserving first match, missing names and raw
fallback. Its7.48% full-source active-context share is a local ceiling, not an
expected gain. Removing half that context's work suggests about3.7% request
time, not an order of magnitude. This tests one reusable semantic result without
first implementing a persistent compiler cache.

Then reuse one actual unchanged named lowering unit under a fixed producer and
compare the final program with an independent full rebuild. Challenge body,
type, layout, refusal/admission and literal dependencies independently. This
must skip real lowering work; serializing all QBE and finding identical bytes
afterward is the already-tested backend cache.

The large ambition is warm-edit speed. Phase132's object reuse saved13.87s in
its partitioned backend but still paid368.98s emission and22.84s partitioning.
The retained monolithic machine stage is only3.5% of the complete historical
request+build sum. Reaching10s from350s requires avoiding over97% of work and a
small fixed verification/link floor. No measured reuse rate currently establishes
that. One owner hit is a4–8h bounded prototype estimate; broad dependable reuse
requires further staged work.

Generated-program speed should remain unchanged if selected IR and decisions
match. The dangerous shortcut is replacing interprocedural optimization with a
smaller fixed interface that omits profitable facts; cache the consumed facts
instead. Dependency errors can affect correctness, so ordinary benchmark output
alone is insufficient to validate this architecture.

## 2. Compact identifiers and storage within existing native IR

### Current barrier

`N111Value` stores locals, global symbols, function and constructor references as
Strings. `N111Stmt` at39345 adds String destinations and operation names, nested
lists and argument records. `P113DStmt` at44342 repeats String call targets and
destination lists. Final ID lookup hashes these names again (`p111q_id`,40594).
The verifier independently validates/hashes identifiers into general nine-field
`KDef` entries (`p111v_get`,40131; `p111v_put`,40135).

This is a precise place to apply indexed representation: the compiler already
has structured native operations. A universal new optimizer IR is unnecessary.
The checked frontend's arbitrary `KTerm` tree need not change in the first step.

### Coherent change

Intern names once within an explicitly identified checked request/owner domain.
Use distinct `LocalId`, `SymbolId`, `ConstructorId` and `LiteralId` types at the
semantic level, with retained text/debug maps. Exact collision resolution is
required; a hash value alone is not identity. Replace textual opcode strings
with a finite operation code where the existing verifier already recognizes a
closed set.

Store the existing native statement tags and scalar operands in a compact
per-owner slab with side ranges for arguments/branches. Mutable construction
must have one affine owner; freeze a completed slab for readers, and release the
whole transient slab once its verified result is consumed. Request-global
canonical facts may outlive a function's temporary instructions; keep their
lifetimes distinct.

**A Bend `Array<ADT>` does not automatically become a packed C/Zig record array.**
Under the current runtime it may hold boxed Terms and retain per-field ownership
work. A claimed compact representation needs actual generated/runtime layout:
for example typed scalar `Array<U32>` columns or byte/word chunks with checked
indices, explicit width/sentinel rules and a frozen backing owner. Do not claim
Zig's record sizes for Bend without verifying storage and access code. Array
copy-on-write, bounds checks and builder growth can erase the expected benefit.

### Smallest falsifiers and bounds

Start with one real verifier-name operation: validate/intern names once, use a
compact width/capacity entry, and independently compare the unchanged final
verifier's success/refusal results. Unknown, duplicate, malformed and missing
names must still fail correctly. Next convert one complete N111 function into
the compact representation and back, requiring structural equality and emitted
byte equality before modifying optimizer consumers. Include pool/epoch confusion
and out-of-range controls.

Measure physical bytes per instruction/name, allocation/drop events, construction
cost and repeated consumer cost. A compact table that rebuilds a linked String
for every access has moved the work rather than removed it.

The full physical profile attributes10.02% to borrowed String equality and29.38%
to `term_drop`/`span_fade`. Removing *all* equality would cap an isolated win near
1.11×; removing *all* that reclamation would cap one near1.42×. Neither is realistic
for this scoped change, and active-context percentages cannot be added to these
physical shares. A verified IR/name representation may remove both comparisons
and reference traffic, but the relevant fraction needs measurement. On the short
lexer request verifier active contexts occupy23.81%; on the full source
`p111v_get` is4.43%. These workloads have different ceilings.
[Profiles](../phase131/final-profiles.md),
[full contexts](../../implementation/phase131/full-context-results.md).

A2–6h single-domain prototype is plausible; converting all frontend terms is a
different, much larger project. Program code quality can remain identical because
this changes compiler storage rather than the optimization policy. Keep exact
fallback, ownership and verifier contracts; do not merge constructors or values
merely because their spelling or arity matches.

## 3. A final emission plan with bounded output lifetime

### Current barrier

After selection, `p113e_registered` at45273 and `p113a_registered` at47802 still
append every registry entry via `p113e_old_private_chunks` at45266. This preserves
needed legacy fallback callers but also emits unused private workers. The final
inventory finds12,048 private functions outside the conservative graph rooted
at every export and all data references:9.07MB/8.48% of QBE. All48,911 dispatch
entries remain roots; absence of direct textual calls cannot justify deleting
them. [Reachability audit](../phase132/incremental-boundaries.md).

The output path then expands instruction pieces into Strings:
`p111q_line` at40631 accumulates a list, `p111q_body_text` at40715 joins it,
and `P111Emission` at40910 retains all rendered chunks before
`p111_print_chunks` at40948 starts IO. `p112c_attach` at44047 additionally joins
private definitions into the first public chunk. Merely keeping an outer chunk
list does not bound the largest live String. `nt_text_finish` at30959 is already
linear in the characters it prepends; this is not evidence of a quadratic suffix
copy bug.

### Coherent change

After current semantic admission and independent verification, seal one
**SelectedEmissionPlan** containing the selected function bodies and their exact
references, stable symbol/literal maps, required dispatch/fallback roots and
global metadata. Renderer choices should consume this sealed plan without
reopening whole-book semantic queries. Omit only private definitions justified
by a complete conservative final-reference closure; do not drop generic runtime
or unknown-target fallbacks.

Render one owner or bounded packet at a time, using compact local identifiers
directly, then release its temporary text. Keep QBE as the output format. An
initial implementation may emit small ordinary String chunks through existing
IO rather than add a new runtime buffer ABI. A packed scalar output buffer is
another option, but its physical layout and traversal must be verified. Use a
temporary sink/atomic completion when later refusal or IO error can occur; never
publish a partial executable as a successful artifact. Cross-unit checks and
deterministic table ordering remain required.

The plan should carry weights: estimated instruction words, literal bytes and
rendered bytes. Enforce a bounded in-flight budget before adding parallel codegen.
This is the direct transfer from Zig's AIR/MIR task budget, without pretending
Bend's own expansions have the same ratio.

### Smallest falsifiers and bounds

First replace one selected owner renderer with the bounded path and require exact
output bytes, including a large private bundle and an error/empty case. Record
peak *live rendered bytes*, allocator requests, RSS and total time separately.
Then directly generate compact local names with an authenticated inverse map;
reuse Phase132's exact machine/symbol/relocation comparison.

Phase132 already reduces107.06MB→57.52MB with compact local/private global names
while preserving exports and machine computation. That is46.27% less text, not a
measured compiler speedup. The difference corresponds to roughly0.79GB fewer
two-word character-field payloads *if independently materialized*: sharing and
allocator retention prevent reading this as a guaranteed RSS saving. The actual
edited request gained1.90GB late before output, consistent with the full linked
String expansion. It had no phase/allocation-origin markers; this does not
promise34s of rendering time or1.90GB removable live heap.

The9.07MB private omission opportunity overlaps compact-name savings. Normalized
repeated bodies contribute another13.55MB candidate repeated text, including
7,978 identical-shape resume bodies, but duplication is not a reachability proof.
Do not add those ceilings. A later shared-continuation template can retain
distinct logical FIDs; it needs a separate runtime/address/profiling contract and
machine-layout tests before promotion.

Phase101 is a warning against a global String replacement: its packed representation
won complete rendering (0.585× baseline time, about one-third RSS) while indexing
remained slower and graph workloads regressed4–6%. Sparse512-byte chunks reached
about506MB and regressed1.46–1.80× before operation-aware packing fixed that case.
Those were host C prototypes, not current QBE compiler gains. Keep the next
packing change compiler-output-specific, coordinate operations with storage, and
retain exact all-U32/Unicode behavior at public String boundaries.
[Phase101 evidence](../../implementation/phase101/README.md).

A2–4h bounded output/name prototype can establish value before broader changes.
Pure compact naming has already preserved machine computation in the frozen
ceiling. Private omission/template sharing can alter layout and branch behavior;
the44-program speed baseline and exact compiler-request outputs remain separate
qualification gates. Smaller text or fewer functions alone cannot establish
faster generated programs.

## Recommended order and stopping rules

1. Establish one scoped immutable semantic query (`nc_ctor_owned`) and one compact
   name/entry consumer using actual retained compiler data. Reject if building
   the facts costs more than the saved queries.
2. Seal the existing selected emission boundary and stream one verified owner;
   compact its locals without changing program computation. Reject if old large
   Strings/IR remain retained behind the new wrapper or fragmentation dominates.
3. Reuse one named owner result before numeric binding, then deliberately break
   each consumed dependency. Only widen after actual earlier work is skipped and
   the full-reference result is correct.

These changes reinforce one another: unit identities enable reuse; compact
domain storage makes units cheap; a final sealed plan makes lifetimes, output and
memory scheduling explicit. They can be implemented incrementally around
`N111`/`P113` and the current verifier. No evidence here requires replacing QBE,
discarding proven optimizations, globally changing String semantics or first
building a new all-purpose IR. Cold compiler speed, warm edit latency, generated
program speed and peak working memory must remain distinct measurements.

## A particularly small semantic-interface experiment: primitive facts

A final bounded audit found actual QBE dependence on the C-template helper
`ni_template` (source31188), the largest attributed owner at2.13MB/145 generated
functions. The selected N2 QBE contains calls from `$direct.nd_scalar_known`
atQBE175091 and `$direct.nc_native_primitive` at275927 to its private implementation.
The former source helper (32818) asks only template nonemptiness and excludes
`f32_show/read`; the latter (32671) asks nonemptiness plus array-known and
`nat_divmod` cases. Emitted callers then perform generic empty-String equality
and ownership handling. This is a real selected-code dependency, not only an
unused C backend in the source tree.

`nc_primitive_arity` at32681 additionally infers arity from C-template `$1`
replacement/equality after explicit array/atomic/`nat_divmod` cases. Its complete
dynamic invocation path was not audited. QBE instruction lowering already has
its own finite `p111_op_id`/`p112_intrinsic` catalogue (39580/41216). A shared
backend-independent primitive fact query—membership, arity, scalar/effect
category—could therefore remove this C-text-valued dependency while leaving
target emission separate. Preserve all old unknown/empty-name arity behavior
and prove the accepted-name sets agree; replacing nonemptiness with an unchecked
numeric-ID predicate would be insufficient.

The actual3,082-line private `ni_template` body returns many static tagged
constants. **Fresh template allocation on every call is not established.** Its
static constructor-site count does not identify dynamic result allocations.
Measured query frequency, request-time savings and whether all2.13MB disappears
remain unknown; other C consumers/fallback roots can retain code. First compare
all finite catalogue cases and unknown-name controls, then complete emitted
products and the real classification query trace. This is a concrete small
falsifier for the semantic-query boundary without a new IR or parser.
[Detailed source/emitted evidence](primitive-catalogue.md).
