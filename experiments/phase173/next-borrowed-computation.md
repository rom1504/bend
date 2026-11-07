# Beyond terminal updates: keep ownership through an allocating computation

Read-only architecture audit, 2026-11-07. Borrow04 and the installed Phase170
compiler remain unchanged. The AST digest driver is a separate experiment;
this document does not authorize a full compiler acquisition on its own.

## What the evidence actually establishes

Borrow04 removes a real category of work, but at a narrow boundary. The actual
compiler driver reduced runtime allocations180→177 and constructor takes57→54
with complete upstream-oracle equality. The two-million-call `k_with_span`
loop improved54.91→41.20ms. Neither is a whole-compiler result.

The complete8,223-node `f_span_created`→`g_share_head` computation also passed
the full native/upstream value comparison. Its diagnostic event pair removed
3,600 of145,197 allocation calls (2.48%),28,793 of333,733 requested words (8.63%),
and3,599 of20,059 constructor takes. Scheduler, frame and dispatch events did
not change. Four process pairs measured18.35→18.44ms; both are below the30ms
resolution gate and include printing the complete value. The bounded digest
driver tests the same canonical transformations eight times with varied seeds
and visits every result field, while the full-value gate remains independent.
Receipts are `borrow-ast-event-base-run01/report.json` and
`borrow-ast-event-cand-run01/report.json` under `selfhost/build/phase173`.

The observed limit has a concrete source explanation. In
[`f_span_created`](../../selfhost/src/front/parser.bend:759), internal nodes
recurse before construction; only literal leaves call the already admitted
terminal setter. A smaller number of parent allocations does not imply that
the full traversal, its child lists or its reference-count work disappeared.

## Why the present planner misses the important computations

[`p173b_plan`](../../selfhost/tests/phase173/borrow-record.bend:173) only accepts
a closed take/load/copy/drop/store/constructor/return region. It rejects calls,
control flow inside that region, and values without preserved-field provenance.

* [`subst_node`](../../selfhost/src/core/term.bend:451) calls `subst_terms` and
  then `core_rebuild` between destruction of the old record and production of
  its result. This is a complete computation; it is not a setter region.
* [`nc_erase`](../../selfhost/src/back/native/erase.bend:91),
  [`nc_compact_plain`](../../selfhost/src/back/native/bridge.bend:699), and
  [`nq_layout_subst`](../../selfhost/src/back/native/product-layout.bend:135)
  call `k_rebuild`. That helper receives seven replacement arguments for its
  eight-field KTerm case. Borrow04 sees only one unchanged field and rejects
  its profitability, even when several caller arguments came from getters on
  the same record. Value provenance was lost at the call boundary.
* `nc_uses_term/list`, catalogue scans and verifier/renderer classifications
  often inspect input and build a different output. Same-constructor parent
  reuse does not remove those traversals or their allocations.

The independent direct verifier authenticates parameter/result counts, live
values, call readiness and control flow. Its `P113Direct` signature does **not**
establish borrowing, child ownership transfer, nonescape, effects, or heap
invariance across a call. See
[`p113e_signature` and `p113e_call`](../../selfhost/src/back/qbe/verify-direct.bend:4).
Extending the scanner to simply skip `P113DCall` would therefore be unsound.

## The smallest next capability: an owned record with temporarily moved fields

**Priority revision after the source experiment:** test ordinary early consuming
decomposition before introducing the private-parent token below. The latter is
a stronger optional optimization, not the minimum required architecture.

| Approach | What lives across child work | Work removed / retained | New obligations |
| --- | --- | --- | --- |
| Existing getter plus setter |Original parent plus separately owned child view|Retains parent and duplicate child credits|Existing contracts|
| Early consuming decomposition |Ordinary owned field locals; child credit moved|Removes retained parent/getter ownership overhead; still allocates final parent|Checked accessor/setter identity and safe movement of ordinary take|
| Private parent with moved field |Private storage token and temporary hole|Also avoids parent allocation/free|Hole states, nonescape, call/frame lifetime and restoration|
| Whole-computation borrowed entry |One input graph owner plus borrowed views|Can remove ownership churn even for shared input|Borrowed-call summaries and owned escape/publication barriers|

The consuming `f_pattern_sub` source experiment is the second row. The ordinary
take already handles unique roots by moving fields and shared roots by making
the required field credits. Destroying the parent before child recursion leaves
no private parent pointer, no temporary heap hole, and no new calling convention.
Only immutable metadata and the existing owned child argument cross the call.
This is substantially simpler than the retained-storage proposal.

A future general pass could recognize the semantic composition of authenticated
field getters and a same-layout setter, recover preserved-field identities,
then move the existing take before the child computation and construct afterward.
It must prove the parent has no other use inside the rewritten region, retain
valid external aliases through the standard shared-root take, preserve existing
conditions/error order and child evaluation order, and exclude observable mutable
identity/effect boundaries. `U64` signatures or matching helper names do not
establish these facts. Source-checked getter/setter summaries can be small, but
the general pass is **not implemented** by the two source rewrites.

This is first an optimization of ownership lifetimes, not necessarily allocation
count. The measured pattern consumer improved103.032→82.282ms over four balanced
pairs, ratio0.798605, with independently exact complete values and digest output.
Diagnostic allocations were1,386,511→1,386,503 (almost unchanged), while keeps
296,024→213,792, sinks786,056→292,680, drop entries761,264→71,048, takes
1,275,799→1,152,455 and dispatches1,515,860→1,351,396. Frame pushes remained65,760.
These are complete consumer observations, not a20% whole-compiler claim or proof
that drop-entry counts measure all recursively reclaimed nodes. See
`consuming-pattern-digest-pair01/report.json` and
`consuming-pattern-event-{base,cand}-run01/report.json` under the Phase173 build
root. This is stronger evidence for early ownership decomposition than the
terminal setter loop or an allocation-only census.

Start with **one immutable Data record, one changed child field, one existing
verified synchronous call, and one same-layout reconstruction**. This is a
general field-origin pattern, not a named compiler-function rule. Keep the
current fallback and all runtime-layout guards. Initially refuse suspension,
unknown calls, foreign/effectful primitives, arbitrary arrays, multiple exits,
and branches that cannot be proved to restore or explicitly destroy the root.

Conceptual plan, independent of final QBE text:

```text
OwnedUpdatePlan {
  input, exactConstructor, fieldLayout,
  preservedFields,
  movedFields: [(slot, ownedCallArgument)],
  call: {checkedTarget, ownershipSummary, args, results},
  resultFields, exitConsumer,
  runtimePublicationPolicy, fallback
}
```

The fast arm performs these operations in order:

1. Prove the input is a private dynamic record: raw owned CTR, or RFCCTR with
   count1, exact constructor and width. Preserve authenticated hot/cold policy,
   immutable runtime identity, single mutator, and all retained-field guards.
   A caller-held shared alias causes the original fallback.
2. Keep the root's owned storage token live. Snapshot the field words needed
   by the original computation. Move the changed field's ownership credit out
   of the record and place a trivial hole in that slot before calling anyone.
   The moved word is now an ordinary owned argument to the original callee.
   Never pass a merely borrowed word to an ordinary consuming ABI.
3. Invoke the same verified call with the same value/effect order. Preserved
   fields stay owned by the private record; they receive no temporary keeps,
   sinks or republication. The old moved slot owns nothing during the call.
4. Install the call's owned result using the exact existing publication rule,
   restore all holes, and return the original root or pass it to the original
   final consumer. `core_rebuild`, for example, must still run after restoring
   a complete term; it may legitimately return a different constructor.

This is stronger than retaining `t` and passing `ks(t)` to the recursive call.
That source spelling normally creates a second child ownership credit while
the old parent still owns the first; it can force sharing and block recursive
reuse. Moving a field from an unobservable private parent preserves the
callee's original owned argument without keeping that redundant credit alive.

### The proof obligations across the call

* The checked immutable graph must be acyclic in this admitted representation.
  A moved descendant cannot reach the retained parent. No call argument may
  otherwise expose the parent, its raw address or a mutable reference to it.
* The removed credit is transferred exactly once. A shared child is legal:
  its independent aliases retain their existing credits. Two equal child words
  in different fields are also legal only when each slot has the ownership
  credit the original constructor required.
* A preserved field may alias a moved child. Its retained credit then remains
  visible to the callee, correctly preventing destructive child reuse. The
  transformation must not manufacture uniqueness from field inequality tests.
* The callee cannot inspect or mutate the private parent through global state,
  pointer identity, foreign callbacks or an unauthenticated runtime primitive.
  Existing whole-request observer permission admits audited IO providers and
  is **not** by itself the required call-level contract. First use a smaller
  closure of ordinary checked Data operations with known runtime behavior.
* A result that aliases its argument must still carry a valid owned result
  credit. Ownership summaries must describe the ordinary ABI; the type `U64`
  and a passed arity verifier are not such a summary.
* All normal exits must close every hole. Errors/early returns require an
  explicit release of the private remainder or a refused plan. Resource
  exhaustion is outside the current allocation-identity contract, but ordinary
  error/effect behavior cannot silently change.
* The private parent must survive across the call with valid machine liveness.
  Initially retain existing synchronous call ordering. Do not turn a scheduler
  continuation or non-tail recursion into an ordinary native call. A recursive
  callee is admissible only when its **existing** implementation and dependency
  admission establish stack safety.

The source of these facts should be explicit, small ownership/effect summaries
bound to the exact checked function and policy. Do not infer them from an
optimization-ready bit. Shared roots still use the original body, so this first
capability does not solve the broader borrowed-context problem.

### Integration boundary and validation

Before implementing, inspect the actual final representation of one qualifying
recursive computation. If the required call/resume is outside `P113DStmt`, say
so: the closed direct-body prototype does not secretly cover it. Existing
[`helper-resume.bend`](../../selfhost/src/back/qbe/helper-resume.bend:76) preserves
explicit captured continuations and has separate admission. Crossing that
boundary needs a root token in the verified frame plus hole-state invariants;
it is a second experiment, not a permissive extra scanner case.

Prefer a verified semantic update plan produced before final emission. Retain
the original final verifier on the ordinary program and independently check
every new plan's ownership, call and exit obligations. If the small prototype
emits additional memory operations after that verifier, state explicitly that
it extends the trusted emitter; passing the old verifier does not prove them.
Do not add a fictitious generic body or relax a protected verifier to admit it.

Expected disappearing work: one parent allocation/free per successful region,
parent field transport, and temporary ownership operations on preserved fields.
Child computation and result allocation remain. A retained hole may also make
recursive child uniqueness possible where a parent-preserving copy could not.
No claimed saving includes traversal or scheduler work that the plan retains.

## Cheap falsifier and source-level screen

The next larger transfer should be unchanged `f_pattern_sub`, not another setter
loop. It rebuilds every nonreplacement node via `k_with_children` and appears in
the actual installed parse profile. Use real captured compiler bodies with
present and absent variable IDs, replacement trees with their own origins, and
one retained original alias. Compare complete output to independent upstream
execution, then consume all fields for a long enough clean measurement.

As a **source-level feasibility screen**, factor a rebuilding computation into
explicit preserved metadata plus recursive children and a final setter. This
can expose the existing terminal optimization; `nq_layout_subst` has exactly
such a getter-preservation identity. It must preserve KLiteral behavior and
constructor/quantity/span/removed metadata, and keep `core_rebuild` where the
original called it. Compare complete output and counters. It is **not a true
upper bound** on moved-field reuse: retaining the old root can introduce child
sharing. A neutral screen should not be misreported as disproving the stronger
ownership plan, but a positive result can justify the smallest new ABI slice.

A decisive moved-field prototype then needs only one admitted actual update
with a known synchronous allocating callee. Include unique/shared/static roots,
shared children, preserved/moved-child aliases, returned-input aliases, changed
constructor results in the final consumer, deep recursion and failure paths.
Count successful work removal on a complete consumer. Reject it early if
required semantic summaries or continuation transitions exceed the bounded
slice, or if full-consumer gain is neutral after charging admission/emission.

## The larger alternative: borrowed input, independently owned output

If roots are usually shared, uniqueness-based mutation cannot be the primary
architecture. Introduce a checked internal borrowed-entry contract instead:
hold one owner of the immutable input graph for the complete computation;
field views and recursive arguments are loans; new objects are owned; every
borrowed value returned or stored into an owned object obtains exactly one
ordinary ownership credit. Drop the input owner only after the output is
independently owned. This naturally applies to transformations whose output
differs structurally, not merely setters.

The existing observer path provides useful precedents but not this contract.
[`p128bs_leaf`](../../selfhost/src/back/qbe/borrowed-regions.bend:8) refuses calls,
and `p128bs_functions` holds roots while running a borrowed reader then drops
them. An allocating result needs escape/ownership tracking, call summaries,
publication and recursion rules that scalar observation does not establish.
This is the more general direction for persistent compiler books and contexts;
it should not be advertised as implemented by the current guarded update.

## Profile-grounded priorities and honest ceiling

The installed full-source diagnostic has5,584 samples, with53.58% unknown active
owners. Runtime caller attribution cannot recover source owners for the large
take/drop costs. Physical setter samples are sparse: zero `k_with_span`, two
`k_with_children`. These are neither inclusive timings nor a zero-cost finding.

| Actual region / source | Evidence | Relevance to the current or proposed plan |
| --- | --- | --- |
| `f_pattern_sub`, front/elaborate.bend:216 |39/896 parse active-context samples; candidate35/921|Existing setter composition; best complete traversal transfer. Counts are descriptive contexts, not inclusive costs.|
| `f_context_material_children`, front/literals_arrays.bend:299 |33/896 parse contexts; candidate54/921|Repeated complete child construction followed by a setter; useful independent second frontend consumer.|
| `subst_node`, core/term.bend:451 |65/5,584 known whole-capture contexts across stages|Requires the across-call lifetime plan; current borrow04 misses the interval.|
| `nq_layout_subst`, back/native/product-layout.bend:135 |26/795 raw-candidate contexts|Exact field provenance disappears through `k_rebuild`; useful general boundary test.|
| `nc_erase` / `nc_compact` |Request-preparation block5.83s contains erasure, normalization and other work|Current `k_rebuild` refusal; whole block is an envelope, not removable update time.|

Parse/load totals28.74 diagnostic seconds, checking21.24, raw candidates25.51,
and rendering/output32.45. These stage clocks cannot be assigned wholesale to
record updates. Current evidence supplies **no defensible whole-request gain
estimate** for the new plan. Even the entire parse block is only16.0% of the
diagnostic capture. A25% setter-only loop gain is not a25% compiler gain.

The best next question is whether complete hot traversals preserve field/owner
information across calls often enough to remove substantial real work. If not,
the useful architectural move is borrowed whole computations or a representation
that avoids rebuilding them, rather than another terminal-update recognizer.
This investigation should remain separate from claims of reaching100s or10×.

## Immediate cheaper ablation before new call contracts

Root correctly identified a smaller test before implementing the across-call
proposal: remove only the requirement to preserve at least half the fields.
`borrow-record05.bend` differs from the original record planner only in that
profitability expression and its comment. Every nonempty, structurally legal
update may be attempted; all original emitter04 code, runtime uniqueness,
publication, alias, sink, width, constructor and fallback rules are unchanged.
Eighteen additional finite controls are in `borrow-wide-controls05.bend`.

This is semantically justified because the half-fields condition was never an
ownership premise. With zero retained fields, all old fields must still be
explicitly disposed of or dynamically trivial, every replacement must already
have its own legitimate owned credit, all old values are snapshotted before
sinks, and raw static replacements still fall back. A replacement aliasing an
old child is valid only with the separate credit the original program required;
the template does not create such a credit by comparing words.

Actual `k_rebuild` admission remains an empirical question: its complete emitted
region must match the unchanged grammar. Width-eight/seven-replacement finite
controls establish that the profitability threshold is gone, not that every
source call now executes the fast arm. If successful, this can expose existing
recursive traversal sites without keeping a hidden parent across any call.
It still saves approximately one parent allocation/free/take per hit. Seven
changed fields retain their original drops and publication work while adding
seven replacement guards and possible sealing branches. Therefore it may be
slower even with more allocation removal. Measure both event counts and clean
complete-consumer runtime before introducing any call-summary machinery.

The new `borrow-compiler-pattern*.bend` drivers test unchanged `f_pattern_sub`
with complete present/absent substitution, metadata, variable origins, lambda
quantity presence, original/replacement aliases, and a bounded-output variant.
One important falsifier is genuine child sharing: while `f_pattern_subs(ks(t))`
runs, retained parent `t` still owns its old child list. A uniquely owned outer
root does not imply that every descendant update is unique. Sparse fast-arm
coverage there would support investigating moved-field or whole-computation
borrowing; it would not justify weakening the uniqueness guard.

Sources: [current installed profile](../phase171/current-profile.md),
[candidate profile](../phase171/candidate-profile.md), and
[caller attribution limits](../phase171/caller-attribution.md). No target,
profiler capture or production source was changed by this audit.
