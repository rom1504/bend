# Phase128: fast-compiler techniques against the measured native bottleneck

Research date: 2026-10-23. Bend baseline: `selfhost/bootstrap`, `00f9e0e`
(Phase127). This is a bounded source/literature refresh, not a new benchmark or
an implemented optimization. The Phase128 experiments and their qualification
are reported separately. No target executable, compiler build, or external
compiler benchmark was run for this note.

The most useful transfer is **read-only compiler queries with an explicit owner
lifetime**, followed by avoiding repeated preparation and name resolution.
Zig's compact identities and Go's scoped work are useful next steps. Changing
machine backends would not remove ownership work already present in our input
to QBE.

## What changed since our previous research

The [Zig](zig.md), [Go](go.md), [Lean](lean.md),
[query-reuse](phase62-query-reuse.md), [term-processing](phase62-term-processing.md)
and [Phase83 representation](phase83/representation-replacement.md) surveys
already cover interning, summaries, borrow analysis and immutable request
state. [Phase104](../../design/phase104/recursive-improvement.md) separates
compiler acceleration from research acceleration;
[Phase107](../../design/phase107/native-ir-ambition-ladder.md) already proposes
borrow summaries and scoped reusable native units. Those are prior proposals,
not discoveries of this refresh.

The new selection evidence is [Phase127's actual native profile and code
trace](../../implementation/phase127/full-scale-opportunities.md):

- The exact compiler-derived name-search kernel takes 1.495706s versus 0.102076s
  for upstream C/Clang: 14.653× on this narrow workload. It performs tens of
  millions of drop/take/keep/sink operations despite only about 64,000
  allocations. The [proxy report](../../implementation/phase127/name-search-proxy.md)
  records independent outputs and retained measurement failures.
- Upstream emits borrowed field reads before Clang optimization. Our equality
  wrapper retains roots but sends each character through a consuming walker.
  Therefore there is a semantic-lowering opportunity, not merely a hope that a
  different instruction selector will improve the same operations.
- `has_name` and `f_find` already have local recursive loops. Generic scheduler
  elimination is not the missing capability inside those loops.
- `String.order` already invokes a borrowed `String.cmp` reader, but the product
  return and immediate projection still create and dispose transport structure.
- `term_drop` plus `span_fade` are about 40.03% of full-compiler physical CPU
  samples. This is a sampled CPU share, not an independently removable fraction
  of complete request wall time.

The existing [exact-name index](../../selfhost/src/core/index.bend) is a
compressed persistent binary hash trie with exact-string collision buckets.
The compiler also has a [prepared native request](../../selfhost/src/back/native/request.bend),
cached erased bodies, arity and static bodies. Proposing a hash table, an IR,
or a generic cache without identifying the remaining work would miss these.

## Primary-source refresh and version limits

| Project | Inspected source/version | What the fresh reading establishes |
| --- | --- | --- |
| Lean | `v4.30.0`, the release previously recorded at `d024af099ca4bf2c86f649261ebf59565dc8c622`; fresh tagged `InferBorrow.lean` and official release notes | Ownership requirements are inferred across an SCC and distinguish correctness requirements from profitability heuristics. |
| Zig | `0.15.2`, previously recorded at `e4cbd752c8c05f131051f8c873cff7823177d7d3`; fresh AIR, ZIR and InternPool pages; separate **0.15.1** release notes | Compact indexed storage has explicit phase/lifetime boundaries; the release's large debug-build gain is not an optimized-code parity claim. |
| Go | Existing pinned `go1.25.0` survey at `6e676ab2b809d46623acb5988248d95d1eb7939c`; fresh official `go.dev/src` SSA README, `compile.go`, `cache.go`, observed 2026-10-23 | Dense identities, per-function state reuse and pass-level cost reporting are concrete implementations. Fresh pages are moving source, **not a newly pinned Go release**. |

Several fresh immutable raw URLs and Go tag pages were unavailable through the
browser. The tagged Lean/Zig pages above were readable; Go's prior pin remains
historical evidence and its current official pages only corroborate mechanisms.
No claim below depends on an unavailable file, an unverified latest release, or
a published performance number being transferable to Bend.

### Lean: ownership is a call contract, not an emitter convenience

`InferBorrow` starts with potentially borrowed parameters and propagates owned
requirements through an SCC. A borrowed argument is not decremented by the
callee. Reset/reuse and preserving recursive tail calls impose correctness
requirements; construction and call-argument propagation also have profitability
heuristics. Its `OwnReason` diagnostics distinguish the two. This permits a
caller/callee tradeoff without treating every ownership decision as equally
mandatory. [Tagged source](https://github.com/leanprover/lean4/blob/v4.30.0/src/Lean/Compiler/LCNF/InferBorrow.lean)

Lean 4.30's release notes explicitly discuss user borrow annotations, preserving
tail calls over those annotations, and exported-function restrictions. Those
are useful reminders that a private borrowed ABI cannot silently become a
public or foreign ABI. [Official release notes](https://lean-lang.org/doc/reference/latest/releases/v4.30.0/)

**Bend inference:** start with the already extracted scalar-result observer:
keep its owner alive once, read fields without per-node ownership traffic, and
retain the existing consuming fallback. Prove known layouts, effect behavior,
aliases and bounded stack use. An unknown call, escaping field or unsupported
shape must refuse the optimization. A Boolean return makes escape reasoning
small enough to test now.

Do not immediately apply that contract to `f_find`: it returns an owned `KDef`.
A later borrowed search may retain the selected result before its root is
released, but that is a separate lifetime/alias proof. Likewise,
`String.order` may benefit by composing the borrowed reader with a scalar
consumer; that is not evidence that all product returns can be removed.

The useful modest abstraction is a private per-function fact:

```text
ReadSummary = {
  parameter ownership requirements,
  accepted layouts,
  result escape/ownership,
  allowed effects and callees,
  local tail-transfer obligations,
  refusal reason
}
```

This is a proposal, not a new required IR. Initially store only facts the
selected observer already proves. Add call/SCC propagation only after more than
one independently useful consumer needs it. Preserve the final verifier and
runtime-helper admission contracts; Phase127 shows that a correct helper whose
transport certificate is omitted can disable a global fast path.

### Zig: resolve once, consume a compact identity

Zig's AIR belongs to one function, is produced by Sema and consumed by codegen.
Its instructions use separate tag/data storage and variable payloads use a
`u32` array. This is a specific producer/consumer contract, not a single universal
IR. [AIR 0.15.2](https://github.com/ziglang/zig/blob/0.15.2/src/Air.zig)

ZIR separately represents a source file with immutable instruction storage,
string bytes and extra words. Its immutability permits concurrent analyses;
string storage itself does not mean every source spelling has been interned.
InternPool gives identities to typed values and analysis units
and tracks incremental dependencies; it is more than a string hash table.
[ZIR 0.15.2](https://github.com/ziglang/zig/blob/0.15.2/lib/std/zig/Zir.zig),
[InternPool 0.15.2](https://github.com/ziglang/zig/blob/0.15.2/src/InternPool.zig)

`MultiArrayList` documents two advantages: avoiding padding and reading only the
needed fields. These do not automatically apply to a list of boxed Bend records;
the storage primitive and ownership of the containing region matter.
[Official implementation](https://github.com/ziglang/zig/blob/master/lib/std/multi_array_list.zig)

**Bend inference:** give definitions an exact, request-local identity after
resolution, and let repeated native analyses use it. Preserve original strings
for diagnostics and public input. The first experiment should cover one
measured catalogue or seen set, not replace all `KTerm`/`KDef` structures.

There are three distinct costs to test separately:

1. Repeated list membership can remain quadratic even after its reader borrows.
2. Hashing a linked string and exact collision comparison still cost work even
   when an index exists. A resolved identifier can avoid both on subsequent
   consumers.
3. Querying an index can still consume/reconstruct its own boxed structure.
   Compact keys alone do not cure a consuming lookup implementation.

Identity is scoped to an immutable checked book/generation. Native provenance,
constructor identity and duplicate precedence must survive resolution. Hash
equality alone is not semantic equality. In particular, `nc_ctor_owned` wants
the **parent ADT's** provenance; enrich an existing constructor fact rather than
equating it to the constructor's own flag.

### Zig's debug backend is a useful boundary, not the next shortcut

The 0.15.1 release announces roughly fivefold faster debug compilation with its
native x86 backend. It also explicitly says emitted code can be slower than
LLVM's; default selection is scoped by target and Debug mode. This is evidence
for measuring development/release tradeoffs, not for promising fivefold faster
execution of Bend's N1 compiler. [Release notes, x86 backend](https://ziglang.org/download/0.15.1/release-notes.html)

**Bend inference:** QBE already addresses expensive machine-code construction.
Our fresh N1-to-QBE request metric excludes the later QBE assembler/linker build.
A different final backend cannot directly accelerate work outside that clock.
Its *generated N1* might run faster, but it must be compared as a separate
same-source experiment. First remove the consuming walks and redundant
preparation that every backend currently inherits.

### Go: reuse bounded work, and charge every pass

Go's SSA documentation states that values/blocks have sequential IDs, allowing
analyses to avoid maps. SSA passes operate per function. This is useful for
small dense compiler-side facts; it does not show that a global rewrite of
Bend's rich checked syntax would pay off. [Official SSA README](https://go.dev/src/cmd/compile/internal/ssa/README)

`Cache` holds reusable value/block storage and register-allocation scratch for
multiple functions. Reset clears the used prefix rather than indiscriminately
clearing all reserved capacity. This is storage reuse, not semantic-result
memoization. [Official cache source](https://go.dev/src/cmd/compile/internal/ssa/cache.go)

`Compile` can report pass time, allocated bytes and allocation counts, dump
intermediate forms, and check between passes. Its pass list has required passes
and ordering constraints. The practical lesson is to attribute both work and
results at an actual phase boundary. [Official compile source](https://go.dev/src/cmd/compile/internal/ssa/compile.go)

**Bend inference:** Phase127 already built substantial profiling machinery; do
not rebuild it under a Go-inspired name. Use it to charge the repeated
`p113pl_inspect_request` preparation and discarded candidates. First skip work
proved unused while demanding byte-identical QBE. Only then consider a retained
summary for an immutable request. Scratch reuse or an arena requires an ownership
boundary; a new process-global cache would create unrelated invalidation work.

## Ranked experiments and honest gain bounds

Times below are provisional engineering estimates for the first discriminator,
excluding native-image acquisition and full qualification. They are not promises
that an integrated version can be promoted within that time.

| Priority | Hypothesis and cheapest discriminator | Expected effect if the hypothesis holds | First discriminator / integration scope |
| --- | --- | --- | --- |
| 1 | Adapt existing scalar observer to the Phase127 name-search kernel; check the independent oracle and owned/shared/static/deep-tail controls; inspect hot loops and runtime counters | Removes per-character/per-cell ownership operations. A multi-fold proxy gain is plausible given its 14.65× gap, but complete compiler gain remains unmeasured | 30–90 min; integration/qualification potentially hours |
| 2 | Skip guaranteed-unused candidate preparation; exact generated QBE on short compiler requests | Recovers duplicated analysis without changing generated program behavior. Upper bound is measured omitted work, not the entire Phase126 regression | 30–60 min; small implementation if the dependency proof is local |
| 3 | Borrow a result-producing lookup or compose a borrowed product with its immediate scalar consumer | Transfers the observer capability beyond Bool membership and can remove result transport; separate owned-result and stack-safety proof | 1–3h prototype; proceed only after priority1 demonstrates transfer |
| 4 | Existing constructor index carries parent provenance; or replace one repeatedly scanned name set with resolved IDs | Removes scans or repeated string work, rather than making each scan cheaper. Wins depend on query count and one-time construction cost | 1–2h measurement/prototype; request-local scope |
| 5 | One compact immutable per-function preparation product replaces two producers/consumers | Removes representations/traversals instead of retaining another graph. Prior Phase79–83 results warn that local savings may disappear in total request cost | 2–4h narrow discriminator; larger architecture only after proof |

For a measured request fraction `f`, local acceleration `s` and new overhead
`h` expressed as a fraction of original request time, the conditional ratio is:

```text
new_time / old_time = (1 - f) + f / s + h
```

For example, if a transformation truly addresses 40% of request time and removes
75% of that work with zero overhead, it cuts total time 30% (1.43× faster).
It cannot alone make a roughly 2.3× request ratio reach parity. Removing 80%
of a genuine 70% request fraction would give about 2.27× acceleration. That
larger coverage has **not** been demonstrated by the current profile.

The drop/fade sample share is not a plug-in value for `f`; a borrowed walk also
changes other instructions, and some reclamation is mandatory. Likewise the
14.65× proxy gap is not a complete compiler forecast. Measure the changed
dynamic work first, then exact-output short requests, then one full-scale
request before paying for successor qualification.

## Ambition without changing the benchmark

- **1× scope:** a general scalar observer and one exact-QBE preparation skip.
  Show useful dynamic work disappearing and reduce complete request time.
- **10× scope:** use a common checked read-summary across a recursive query
  region, including a justified owned-result boundary. Combine it with a
  resolved-name or constructor-fact consumer so both ownership cost and repeated
  search disappear. This targets distinct costs; do not add their isolated
  speedup percentages.
- **100× scope:** a compiler-owned immutable checked database with stable IDs,
  borrowed query APIs and dependency-qualified analysis products. Optimize only
  affected work across research experiments and measure acquisition plus
  invalidation plus validation cost. This could greatly change edit-loop cost,
  but warm reuse is a different metric from today's fresh-process request and
  must never be presented as cold upstream parity.

The highest-value work now is the first two experiments. The research reinforces
their mechanism and contracts; it does not establish a need for another backend,
wholesale IR migration, universal interning pool or autonomous search framework.
If borrowing succeeds, the next architectural question is which compiler queries
can share its lifetime proof, not how many new optimization passes we can add.

## Follow-up: exact algorithmic boundaries, not blanket interning

A subsequent read-only trace of the complete Phase127 source identified a
semantic distinction that matters before replacing `f_find` with an index.
`f_find(name, prior)` returns the **first** matching list event. The ordinary
parser-scope initializer in `load/modules.bend:f_source_body` constructs
`index_build(reverse(prior))`, giving the existing scope index the **last**
prior-event winner. `f_context_declared` then prepends a new header and updates
that index. A direct substitution can therefore change duplicate/law behavior.

An exact first-event index can use `index_build(prior)` once at scope creation,
then `index_set(first, d, hash(dn(d)), 32)` whenever `d` is prepended. Four
consumer sites could use it: `f_context_family_input`, `f_context_mark_input`,
`f_do_header_resolved` (currently repeats its lookup) and `f_do_resolved`.
On misses, preserve the original `KDef{name,"Missing",...}` result rather than
the index's anonymous `Absent` value. Test duplicate events with different
signatures/provenance, namespace aliases, laws filled later, shadowed
constructors, Unicode and empty names. This would require an additional private
scope fact, not rebuilding the index for each query.

`f_decl_local` is a distinct boundary: it scans the raw **local** event book,
while the scope index contains mapped headers and imports. A separate local
index could be updated by `f_context_publish` when it prepends the raw event.
Predeclaration in `f_context_declare` must not publish a completed local event
early. The maintained invariant must name the exact list being indexed.
Neither parser-index change was implemented in this investigation.

Existing full-source active contexts put `f_find` at 1,765/36,220 samples
(4.873%), `kr_filter` at 942 (2.601%), `has_name` at 2,651 (7.319%),
`dr_own_names` at 362 (0.999%) and `nb_contains` at 1,258 (3.473%). The
37–55% early `f_find` windows therefore do not justify predicting a similarly
large complete-request gain. Short-request events also do not identify which
`f_find` callsite dominates: lexer has 289 `f_find` dispatches, while
`f_context_mark_input` has 20 and `f_decl_local` has 882, many of which bypass
the scan after an index miss. Caller attribution or a small ablation is still
needed before expanding parser changes.

The smallest selected algorithmic candidate is now the
[isolated `kr_filter` boundary overlay](../../selfhost/tools/performance/phase128/reachability/README.md).
It constructs one membership index from the immutable live list and retains
original book order and payloads. Existing diagnostic events show two filter
dispatches carrying 521,698 takes on lexer, 704,269 on Map and 210,564 on
closures. Private calls share the context, so these are work indicators rather
than list sizes. The 20 prepared finite controls include exact-hash collisions,
duplicates and nonordinary book nodes. The candidate is composed; checking,
target timing and qualification are pending with the coordinating agent.

If it succeeds, the ambitious extension is to maintain a membership index
alongside the existing ordered `seen` list in `kr_visit`, `dr_walk` and/or
`nr_walk`, selected by actual caller cost. Preserve name and resolved-parent
insertions, stop semantics, traversal order and unsafe early-exit behavior.
`dr_walk` already has a separate proven-safe index; an in-progress seen set
must not be mistaken for that proof. This can eliminate repeated searches
across several real compiler stages without changing symbol identity or
introducing a new backend. No combined gain is established by adding the
shared-context percentages.
