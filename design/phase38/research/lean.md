# Lean: ownership information, reuse and representation boundaries

Research date: 2026-10-01. Source/documentation inspection only. No Lean or Bend
code was built, executed or benchmarked. The proposals and gains are original
hypotheses relative to installed Phase37, not Lean's published performance.

## Primary sources and inspected version

The implementation inspected is Lean **v4.30.0**, released 2026-05-26, tag commit
[`d024af099ca4bf2c86f649261ebf59565dc8c622`](https://github.com/leanprover/lean4/tree/d024af099ca4bf2c86f649261ebf59565dc8c622).
This choice fixes an implementation; it is not a claim about today's newest Lean.

- Ullrich and de Moura, [Counting Immutable Beans](https://arxiv.org/abs/1908.05647)
  (2019 preprint): reference counting, borrowing and reset/reuse for an eager
  functional language. Published benchmark gains are not imported here.
- [LCNF pass ordering](https://github.com/leanprover/lean4/blob/d024af099ca4bf2c86f649261ebf59565dc8c622/src/Lean/Compiler/LCNF/Passes.lean).
- [Reset/reuse insertion](https://github.com/leanprover/lean4/blob/d024af099ca4bf2c86f649261ebf59565dc8c622/src/Lean/Compiler/LCNF/ResetReuse.lean).
- [Propagated borrows](https://github.com/leanprover/lean4/blob/d024af099ca4bf2c86f649261ebf59565dc8c622/src/Lean/Compiler/LCNF/PropagateBorrow.lean)
  and [borrow inference](https://github.com/leanprover/lean4/blob/d024af099ca4bf2c86f649261ebf59565dc8c622/src/Lean/Compiler/LCNF/InferBorrow.lean).
- [Runtime layout and calling conventions](https://github.com/leanprover/lean4/blob/d024af099ca4bf2c86f649261ebf59565dc8c622/src/include/lean/lean.h).

These concrete sources extend [Phase35's ownership discussion](../../phase35/literature.md).
The paper's small IR and this release's LCNF implementation should not be treated
as byte-for-byte descriptions of the same pipeline.

## Mechanism and implementation details

The paper makes reference ownership explicit so that unique dying cells can be
reused while shared values retain functional behavior. Borrowed parameters avoid
some reference-count traffic. Crucially, a successful dynamic uniqueness test is
part of that runtime arrangement; a source-level single use alone is not the
same guarantee. [Paper](https://arxiv.org/abs/1908.05647).

The inspected pipeline first specializes/simplifies and moves through base and
monomorphic phases. In its impure phase, reset/reuse insertion precedes borrow
inference, explicit boxing, explicit RC and expansion of reset/reuse, followed
by RC coalescing. Analyses operate at specific representations rather than a
single optimization guessing both source meaning and machine ownership.
[Pass list](https://github.com/leanprover/lean4/blob/d024af099ca4bf2c86f649261ebf59565dc8c622/src/Lean/Compiler/LCNF/Passes.lean).

Reset/reuse searches for a dead value and a compatible later constructor
allocation. Compatibility checks separate object, machine-word and scalar sizes;
it first favors the same constructor family, then permits relaxed compatible
reuse. It tracks already-considered values to prevent double resets and supports
join points. This is controlled lifetime reasoning, not a blanket object pool.
[Insertion implementation](https://github.com/leanprover/lean4/blob/d024af099ca4bf2c86f649261ebf59565dc8c622/src/Lean/Compiler/LCNF/ResetReuse.lean).

User-requested borrows propagate through projections before reuse selection.
The later inference refines an initially borrowed parameter map toward ownership
where needed. Its correctness constraints preserve self-tail calls by avoiding
post-call decrements and ensure reused values have accurate ownership. Partial
applications and constructor storage affect the calling convention. This source
explicitly limits its self-call TCO rule; do not infer arbitrary mutual-TCO
support from the general idea.
[Borrow propagation](https://github.com/leanprover/lean4/blob/d024af099ca4bf2c86f649261ebf59565dc8c622/src/Lean/Compiler/LCNF/PropagateBorrow.lean),
[inference](https://github.com/leanprover/lean4/blob/d024af099ca4bf2c86f649261ebf59565dc8c622/src/Lean/Compiler/LCNF/InferBorrow.lean).

In the runtime, ordinary and borrowed object arguments document who consumes
the reference. Closures use the ordinary convention. `lean_is_exclusive` requires
a single-threaded object with reference count one. Array update ensures exclusivity
or copies first. Lean also distinguishes immediate scalar representations from
heap objects. These are runtime facilities available to its native code, not
JavaScript facilities Bend can invoke.
[Runtime implementation](https://github.com/leanprover/lean4/blob/d024af099ca4bf2c86f649261ebf59565dc8c622/src/include/lean/lean.h).

## What can transfer to Bend's JavaScript backend

Bend's runtime has no complete reference count for JavaScript aliases. Public
objects can be stored by host code, fields can invoke getters, and deferred
constructors can retain references. `WeakRef`, frozen objects and affine source
binders do not supply Lean's uniqueness counter. A new global RC subsystem
would need to account for public escape, host references, cycles and every
mutation; it would likely cost more complexity than this phase can justify.

The useful near-term transfer is compile-time *private lifetime evidence*.
A fresh object created, used and discarded inside one closed region can have
stronger provenance than an arbitrary public argument. First eliminate its
temporary shell or return fields directly. Reusing its allocation is a later
choice only when a scalar replacement or direct destination is unsuitable.
This applies Lean's ownership discipline without pretending JS has Lean's heap.

For example, conceptual `pair = step(a,b); use(pair.first,pair.second)` can
carry two locals to the consumer without allocating the pair. A private tree
builder may instead append newly owned nodes to per-invocation storage, then
materialize an ordinary result at the public boundary. These original proposals
need separate evidence: the latter changes representation and retention behavior.

## Current evidence and proposed experiments

[Phase37 profiles](../../../implementation/phase37/profile-findings.md) show
51.4 KB estimated allocation per numeric-1024 call, 2.78 MB for list-512,
23.08 MB for tree depth 8 and 86.96 MB for active-ray-256. These are sampled
allocation totals per call, not retained memory. The numeric private loop still
uses a BigInt countdown; list/tree still spend heavily in generic call/forcing
machinery. There is no evidence that RC traffic itself is a Bend bottleneck.

| Proposal | Additional selected-program gain hypothesis | Complexity / risk | First probe |
| --- | --- | --- | --- |
| L1: bounded private Nat representation | 1.05–1.8× on numeric recurrence | Low–medium; 1–3 days if existing proof extends | Replace only proved countdown state, retaining public Nat fallback |
| L2: remove one private transient aggregate | 1.05–1.5× on a newly identified allocating path | Medium; 2–5 days | Producer/consumer local-slot ablation with complete field output |
| L3: owned private builder storage | 1.1–2.5× on a qualifying allocation-heavy component | High; 2–4 weeks | One fresh builder, no imported/shared inputs, separate materialization cost |
| L4: add whole-runtime RC to JavaScript | No defensible positive estimate | Very high; months and ABI risk | Reject for this iteration objective |

These are low-confidence ranges, not promises; a non-admitted path gains zero.
L1 is motivated by representation reasoning, not reference counting. Phase35
already has some private numeric countdown lowering, so the first task is to
find why this remaining helper misses it, not add a competing numeric system.
Full Nat precision, zero behavior and negative/noncanonical public inputs must
retain the existing semantics; only bounded private state may use Number.

L2 must identify a remaining allocation before implementation. Phase35 already
removed pair/fold shells; repeating that transformation there cannot earn the
same gain again. L3 should follow direct-call work: replacing nodes while leaving
generic dispatch intact may create a large rewrite with little benefit.
It also overlaps fusion and worker/wrapper; estimates must not be multiplied.

## Obligations that replace Lean's runtime guarantees

For an owned builder, prove fresh allocation, complete escape paths, no retained
alias to an overwritten slot, and per-invocation lifetime. No global scratch
buffer is acceptable: recursion or a getter/native hook may reenter and overwrite
it. A public result must preserve the required alias graph, not merely a checksum.
Shared and frozen input trees, identical root arguments and retained intermediate
values are independent controls, not rare cases to omit.

Preserve Bend's demand order when removing or reusing an aggregate. A field
thunk that throws or calls a hook must run at its original point and exactly
once. Keep public constructors/descriptors mutable according to the current ABI;
do not freeze user-visible values to make the proof easier. `G` replacement,
bound-argument mutation and host prototype overrides still need refusal/fallback.

Tail-stack behavior is a correctness requirement. A reuse pass must not append
cleanup after a transfer that previously used the trampoline. Deep self/mutual
cycles and exception unwind must leave no proof or scratch state active.
Lean's source warning about ownership affecting tail calls is especially relevant
even though Bend would not be inserting reference-count decrements.

## Fast falsification and simplicity

Start with a saved-output ablation and one explicit ownership/representation
hypothesis. Use independent complete outputs and alias/event traces; separate
admission counters from timings. A 20-second screen plus 60-second paired
confirmation should precede any whole compiler build; engineering the controls
may take hours. Profile allocation separately and measure peak RSS as well:
an arena can reduce allocation events while retaining more memory.

Stop L1 if Number conversion or guards absorb the benefit, any precision case
changes, or the intended private counter never runs. Stop L2/L3 if aliases cannot
be proved, full materialization erases the gain, live memory grows materially,
or the first useful case requires a global ownership analysis. Only a survivor
gets normal checked-compilation cost, broad program checks and fresh holdouts.

The simplicity opportunity is one small shared lifetime/representation fact used
by existing plans. A general RC IR, allocator and alias model would add several
major concepts and should not be described as simplification. None of these
proposals fixes a frontend conformance gap. Their value is conditional on keeping
the present semantics and making ordinary optimization iterations faster.
