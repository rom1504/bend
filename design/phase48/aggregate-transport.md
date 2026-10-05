# Private aggregate transport

Date: 2026-10-05. Baseline: installed array06, `ee54723`.
Status: implementation proposal; no correctness or performance claim yet.

## The allocation to remove

The selected RLE root has a private helper which returns
`(current, (count, encoded))`. Its recursive caller immediately projects those
fields and passes the state through its next iteration. Both branches allocate
two temporary tuple shells per step. The false branch also allocates the
persistent `(count, character)` pair and a list cell; these must remain.
The final encoded list has two consumers, length and expansion. This is not a
single-consumer list fusion opportunity.

The [Phase47 attempt](../../implementation/phase47/worker-outcome.md) removed
some private calls, but not the transported aggregates, and added 405 lines.
This experiment changes the private calling convention rather than repeating
that inliner. The related ideas are argument/return decomposition and scalar
replacement described in the [LLVM survey](../../research/compilers_architecture_and_techniques/llvm.md),
with bounded specialization and explicit calling conventions from the
[Lean survey](../../research/compilers_architecture_and_techniques/lean.md).

## Bounded first implementation

Add `worker-values.bend` after ordinary JW lowering and unconditional-case
simplification, before Number-Nat conversion and SCC emission. Its input is the
complete admitted private graph plus the exact public entry index. Original
source definitions remain the input to all dependency and host guards.

1. Decompose a private formal parameter only when every use is an exact tuple
   projection and all private callers provide an already evaluated slot.
   Replace its first field at the existing argument position and append its
   second field. Rename non-parameter slots to leave room. Exclude the public
   entry. Repeat with a fixed cut budget to handle nested state: at most four cuts per
   function, 32 across the graph, and at most 12 final parameters.
2. Decompose one private result field only when every successful return proves
   a canonical two-field tuple and every caller uses that result solely through
   tuple projections. Impossible branches do not invent a result shape.
   Introduce explicit `JWCallValues` and `JWReturnValues` instructions; retain
   function indices and names. Exclude the public result. Limit results to four
   fields and 32 graph-wide cuts; keep at most 64 dominated tuple-shape facts.
3. Remove a local tuple shell only after a complete remaining-use scan proves
   projection-only use. Evaluate both original fields once, in order, into
   fresh slots at the original construction point. Replace projections with
   those slots. Repeated bounded cleanup handles nested tuples.

Tuple decomposition preserves field references. It does not copy, mutate or
discard a persistent child. Tagged records remain materialized in this slice;
tuple results containing records can lose their transport shell.

The fact domain is deliberately small: projection-only slot use and dominated
canonical tuple construction. Unknown values, globals and native calls are not
pure facts. Facts fork at branches and never flow between sibling branches.
Parameter cuts check call arity and unknown uses retain the original
convention. The pass otherwise trusts compiler-produced, typed JW; its valid
flags do not constitute an independent validator for arbitrary malformed IR.
An exhausted budget stops further decomposition. No source names select programs or functions.

## Multiple private results without an allocated result vector

The first result uses the JavaScript return value. Additional results use private
lexical scalar return registers in the root closure. The producer evaluates all
result leaves into local temporaries before committing those registers; the
caller immediately captures them into its own local slots before another call
or host-visible operation. This is a register calling convention, not shared
mutable aggregate storage.

All recursive and continuation paths must implement the same protocol. A
non-tail caller captures values before resuming its continuation; a tail call
may forward the convention unchanged. No unbounded native recursion is added.
Error hooks may reenter before the commit: each invocation still computes in
its own frame, and the outer invocation commits its own completed results.
There must be no observable operation between commit and capture. Independent
review must challenge that claim, especially fallback and exception paths.

## Proof and validation obligations

- Public descriptor mutation, computed demand, result layout and entry arity
  remain unchanged. No aggregate crosses a new native or public boundary.
- Field evaluation and exceptions stay at their original point and order,
  including fields whose value is later unused.
- All call arguments are captured before tail-transfer destination stores.
- A reused numerical slot in another branch cannot inherit aggregate facts.
- Persistent children and repeated consumers preserve reference sharing.
- The same result protocol works in direct, recursive-budget and continuation
  emission, including reentrant Error construction.

Use an independent renamed state machine plus tuple/record helpers and existing
Map/record programs. Check large recursion, both producer branches, nested
returns, a throwing unused field, repeated field use, escaping aggregate refusal
and public mutation fallback. Inspect the actual selected producer to establish
that two transient RLE tuple allocations disappear while persistent pair/list
allocations remain. Counters must count executed constructors, not just source
markers; those counts do not alone establish physical heap allocation after
V8 optimization. Compare isolated candidate and baseline before combining other work.

The first falsifier is a semantic or activation failure. The next is unchanged
executed allocation count. A tiny timing gain with substantial compiler cost or
source growth is grounds to defer, as in Phase47. No parity estimate follows
from this one slice.
