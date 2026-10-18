# Effect-preserving leaf inlining

The optional `nx_inline_leaf(program,budget)` fills a deliberate gap in the first
scalar inliner: a small pointer-reading/writing helper can be inlined while
preserving every effect. It does not need to be pure. This is the implementation
for [P107-003](../../experiments/phase107/P107-003-effectful-inline.md); performance
and promotion remain gated on the parent campaign's measurements.

Admission requires a verified closed IR graph and a call-free, loop-free helper
with U32/U64/Ptr parameters, locals and result. Bounds are16 parameters,32 locals,
256 body nodes,256 program functions,65536 program nodes and4096 global expansion
budget. A callee may contain root loads/allocation, stores/free, pointer offsets
and function-address values. Return-free branches followed by a terminal return,
or terminal nested branches, are supported. A return mixed with a later reachable
continuation is refused. Indirect calls and recursion cannot be admitted because
all calls are excluded from this policy.

The pass uses the existing entry-first expander, fresh parameter snapshots,
per-call local initialization, terminal-result assignment and continuation helper.
The only shared transformation change adds renaming for memory expressions and
store/free statements. The old scalar eligibility and outputs should remain
identical; this requires comparison against a frozen previous API, not just tests
of the new policy. The new API verifies its result and returns the input on a
verification failure.

Aliasing is preserved by keeping pointers as values and retaining statement
order. No read/write is moved or deleted. Local pointer zero initialization is
performed inside the inlined call site, so a caller loop cannot inherit an old
pointer from a previous iteration. The synthetic reference-count loads/stores in
`shared` are all retained; any subsequent machine-backend simplification is a
separate compiler effect. No ownership, borrowing, escape or lifetime claim is made.

Eight constructed control families freeze64 input/results: aliased and distinct
pointer parameters, a returned interior pointer, stored pointer plus parameter
mutation, explicit allocation/free, allocated pointer return, pointer-local reset
in a caller loop and conditional memory updates. The aliasing and reset cases
have specified output-mutation witnesses. Source probes and production compiler
programs remain separate from these finite memory controls.

Source acquisition must concatenate `inline/leaf.bend` after `entry.bend` and
`inline/leaf-fixtures.bend` after the core fixture helpers, then export
`nx_inline_leaf` and `nx_l_fixture`. The frozen inputs are in
`inline/leaf-controls.json`. Check budgets0,1,32,4096, complete native results,
growth bounds, invalid/refusal identity and unchanged original scalar policies.
Allocation safety and termination of arbitrary IR memory programs are outside the
structural verifier and are not proved by this experiment.

Status at preparation: static checks only. No compiler build, backend run,
performance result or default change was performed by this implementation agent.

## Remaining alias barrier and the next worthwhile pass

The parent campaign reports a useful borrowed-observer gain after leaf inlining,
but the owned observer remains about3.3× the raw Clang runtime. Inspection of
`artifacts03/ir-shared-4096.json` identifies the exact obstacle. Its loop increments
`parent[0]`, loads a child pointer from `parent[8]`, increments `child[0]`, then
decrements each counter. Those two pointer values must be treated as potentially
aliased without additional information. A same-base field forwarder would have
to invalidate parent facts at a child write and vice versa. Variable names do not
prove disjointness. Consequently, a small local forwarder is not implemented just
to add another pass without an expected material benefit.

The promising next pass combines allocation provenance with exact memory ranges
and checked loop invariants. Its first scope should be a sequential, closed entry
function with fresh, nonzero fixed-size allocations outside the optimized loop,
no calls/free/allocation inside that loop, and no nested loops. Unknown parameter
pointers receive no disjointness fact. This is ordinary memory optimization, not
recognition of reference counts or a borrowed replacement for ownership code.

Represent a known pointer as `(allocation identity, byte offset)`, attaching an
identity to a specific live allocation instance rather than a variable spelling.
Track copies and constant pointer offsets through local value versions. Distinct
live allocation identities are disjoint; equal identities require explicit byte
range overlap checks. A memory fact records root, offset, width, type and the
stored value version. U32 accesses occupy4 bytes and U64/Ptr accesses8 bytes in
this pinned64-bit ABI. Bounds must establish `width <= extent` and
`offset <= extent-width`, avoiding overflow in `offset+width`. Pointer equality
alone supplies no inequality or ownership fact.

An assignment invalidates facts depending on the overwritten local version.
Known stores invalidate overlapping ranges only; partial overlap and different
access widths matter. Unknown pointer stores, unknown calls, frees, unsupported
arithmetic and incompatible control-flow merges discard affected facts; the first
version should discard all memory facts rather than attempt delicate recovery.
No fact survives a free or storage reuse. Track function-address values separately
from allocation roots; neither can be guessed from raw integer-like addresses.

For the observer, the essential induction candidate is the preheader-established
fact `parent[8] = child`, plus stable, distinct parent/child allocation identities.
Assume those candidate invariants while analyzing one loop iteration, then require
every path to preserve them: no writes to overlapping bytes, no reassignment of
their stable roots, no lifetime changes and no unresolved effects. Accept only
the invariants that pass this preservation check; refuse the whole proposed loop
rewrite if its alias reasoning depends on a rejected assumption. Initial truth
plus preservation supplies the inductive justification. This is stronger than
blindly carrying a preheader cache through a loop.

Transform only operations already executed in the original control flow. Do not
hoist a load, allocation or check into the preheader: a zero-trip loop must remain
zero-trip, and no new potentially trapping access may occur. First forward
proven cell values at their original use sites. A later dead-store step may remove
an overwritten private-cell store only after showing no intervening observation,
unknown alias, escape, lifetime change or out-of-bounds access. Retain final cell
values observed after the loop. Balanced ownership updates may disappear as a
consequence of these general facts; the pass must not assume they are harmless.

Freeze adversarial controls before implementation:

- Two distinct allocations versus two aliases to one allocation, including a
  child pointer equal to its parent and a child pointer into the parent's storage.
- Same root/disjoint fields; partial overlap; U32 versus8-byte pointer stores;
  maximum offsets; offsets outside the known extent; zero-sized allocation.
- Pointer copies whose source or destination is later reassigned, pointer locals
  reset on the next iteration, and pointer fields overwritten conditionally.
- A pointer field unchanged in one branch but changed in another; an unknown
  call/store/free between observations; free followed by allocator address reuse.
- Zero-trip and one-trip loops, unknown/unallocated pointer only inside a skipped
  branch, and loop-carried pointer mutation. These must never acquire an extra
  load or a preheader access.
- Function addresses stored in cells, non-escaping private cells versus externally
  reachable cells, and final reference-count observations after the loop.
- Admitted mutants that assume differently named pointers are disjoint, ignore
  partial overlap, retain a freed root or carry an unvalidated pointer-field fact.
  Each must fail an unchanged full-result/refusal oracle.

Useful small laws concern interval disjointness, invalidation after overlapping
writes and preservation of one validated memory-cell fact. They should constrain
the actual helper used by the pass. They do not prove allocation freshness,
runtime memory safety, loop induction or the complete rewrite; those bridges need
explicit finite controls and later stronger proofs.

A credible bounded implementation and adversarial audit is approximately2–4 hours,
including30–45 minutes for straight-line provenance/range helpers,45–90 minutes
for loop-invariant validation and the remaining time for alias mutants and guarded
native comparisons. This is an implementation estimate, not a speed prediction.
First go/no-go: recover the exact parent/child disjointness and stable field fact
on the actual shared IR while rejecting the alias/overlap/loop-mutation variants.
Second: remove memory operations using those facts, preserve all final outputs,
then measure the complete optimization/build/runtime cost. A general escaping,
interprocedural or concurrent memory optimizer is outside that estimate.

The existing verifier rejects Ptr arithmetic in `NxBin` except equality: its
`eq` case accepts matching pointer types, while `ult` and arithmetic require
scalar types. `NxOffset` remains explicit pointer-plus-U32 offset, including
offsets from null in backend control fixtures. The type verifier alone therefore
does not prove pointer provenance, bounds, lifetime or prevent function-pointer
address manipulation through offsets. Reachability applies to the documented
closed, well-defined function-address model; this future memory pass must refuse
inventing allocation facts for those address-derived values.

## Bounded allocation-provenance prototype

After reviewing the above boundary, the parent authorized a narrower25-minute
prototype, [P107-006](../../experiments/phase107/P107-006-memory-forwarding.md).
`inline/memory.bend` implements `nx_memory_forward` without modifying the existing
IR or optimization APIs. Only loads can be replaced, and only by atomic cached
values, so IR node count cannot increase. Allocation, free, call and store nodes
remain in their original order and control-flow positions.

Fresh nonzero constant-size allocations produce abstract roots; pointer copies and
constant offsets retain them only within known bounds. Memory cells require exact
type/range matches, overlapping stores invalidate facts, and assigning a local
invalidates any cached value that referred to its previous contents. Pointer-valued
loads may recover provenance from a valid cached pointer value. Unknown effects
discard facts rather than guess. The structural verifier gates both input/output.

For each loop, the pass first strips every assigned-local dependency from incoming
facts. A first straight-line probe supplies candidate write ranges; filtering
removes overwritten cells. A second probe from the filtered facts must resolve all
writes and establish that every retained preheader cell remains unchanged. Only
those initial invariants survive the loop. Branches, nested loops, calls, frees or
allocations make that loop rewrite refuse. This intentionally excludes many cases
described in the longer-term design. Bounds are4096 nodes per processed body,
256 functions and65536 nodes per program; untouched larger bodies remain unchanged.

Ten initial fixture families freeze76 independent full-result cases. The first
matrix distinguishes distinct/aliased roots and stable/mutated loop payloads, plus
partial-width overlap, local-value dependency changes, pointer reassignment,
call/free barriers and a zero-trip loop containing an otherwise invalid null load.
Only even inputs execute that last witness; no invalid dereference is used as a
normal result. Four safe-helper contracts cover distinct roots and overlapping or
adjacent ranges, with explicit limits: these do not prove runtime provenance,
loop induction or the whole pass. Source acquisition/execution is scheduled by
the parent, and an independent agent reviews soundness before interpretation.

The next fixture revision adds pointer-valued self-assignment, a pointer-field
write that makes the second probe lose provenance, and an early return/free
inside the loop:13 families and100 frozen rows total. The second-probe fixture
must retain its entire original loop body, rather than rely on facts removed
after the first probe. These extra rows need their own acquisition snapshot.
Independent review also identified an oracle distinction: the overlapping U64/U32
fixture has explicit byte-memory semantics in the interpreter and native IR, but
the C emitter uses typed pointer accesses. Its C control therefore requires an
explicit `-fno-strict-aliasing` build (or byte-copy emission); ordinary strict-aliasing
C O2 is not a sound oracle for that particular witness.

The semantic contract assumes the original program's executed memory accesses
are well-defined under the current sequential runtime. Successful, live allocations
are distinct; a free invalidates all facts. No allocation is removed or moved, and
the pass does not establish new OOM behavior or turn null-pointer arithmetic into
known allocation provenance. It does not extend the structural verifier into a
memory-safety proof or rely on undefined native behavior as a successful test.
