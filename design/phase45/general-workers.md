# General first-order workers after the Phase44 IR

Status: implemented candidate, awaiting qualification and performance results.

## The opportunity

The existing `JPure` graph proof is more general than the worker lowering that
consumes it. `j_pure_graph` verifies complete, closed, saturated first-order
call graphs. In contrast, `j_component_plan`, `j_component_prefix`, and
`j_component_leaf` select particular argument positions and structural
recursion forms. `j_component_finish` sends ordinary leaf expressions back to
`j_expr`. Consequently, a successfully proved private computation can still
allocate ordinary function descriptors, matcher closures, argument arrays, and
tail messages in its residual expressions.

This is an architectural gap between proof and lowering. Adding another source
shape recognizer does not close it. The next backend should consume the same
proof and lower arbitrary supported expression composition once.

Phase44's profiles support prioritizing this gap: `apply`, `force`, and
`invokeExact` account for substantial CPU samples in records and Map, and
sampled allocation per application is much greater than upstream. Those
profiles do not establish the speedup from removing any particular operation.
The known-call dispatch experiment only rearranged the existing invocation
protocol and showed no broad improvement. This proposal removes protocols
inside an already proved private region.

## Preserve the current trust boundary

Keep the current public `G` definitions and their `code`, `env`, `bound`, arity,
partial application, and zero-argument initialization behavior. Keep the
existing complete dependency, host-hook, exact-entry, and input guards at
private entry. A failed guard executes the existing public implementation.

Do not infer purity or ownership from `scalarCapture`, a function name, or an
output comment. Do not broaden admitted result or argument representations as
part of this change. Consume the actual successful `JPure` result and the
existing instance provenance facts before JavaScript is printed.

For polymorphic definitions, use the current checked instance view. Its
private signatures already omit erased prefix arguments, while its provenance
rows identify the original public definitions that entry guards must cover.
Do not obtain a live signature by deleting JavaScript `null` arguments.

## Selected vertical slice

The initial proposal was acyclic helper lowering followed by SCC support.
Source inspection changed that choice: `String.cmp`/`String.cmp.fin` and
`Map.diff`/`Map.diff.fin` have non-tail mutual calls followed by reconstruction
or arithmetic. Tail-only SCC loops would leave these important paths generic.
The implemented first slice therefore supports arbitrary first-order cycles
with an explicit continuation machine.

1. Consume the successful raw-instance `JPure` proof before the old
   shape-specific capability selection.
2. Lower every raw instance with its live typed signature. Refuse the whole
   machine if any definition has an unsupported operation or layout.
3. Partition the explicit private-call graph into strongly connected components.
   Acyclic singleton functions use positional parameters and scalar JavaScript
   locals. Recursive components use separate small PC loops; wrappers retain the
   existing `$tree` names.
4. Calls within one recursive component save a return PC and current registers
   when non-tail; an exact call-followed-by-return transfers without a frame.
   Calls between components are ordinary positional JavaScript calls. Their
   native stack depth is bounded by the acyclic condensation graph.
5. Enter through the unchanged shared root guard/public wrapper. Failed lowering
   retains the earlier backend; failed runtime guards retain the generic ABI.

The graph pass validates every call target and computes exact transitive
closure for at most 96 functions using bounded bitset rows. It does not
reinterpret the old cycle detector's fuel-exhaustion result as an actual
cycle. No native call stack grows with recursive source input. Arithmetic,
native operations, and construction execute as straight-line JavaScript
within basic blocks; they do not each incur a PC dispatch.

## Explicit private IR

Keep public `JIRMatch` as a function value. Add a separate, typed private
function representation; converting a function-valued matcher into a case
requires a known supplied argument and a verified signature.

The necessary operations are:

| Operation | Required information |
| --- | --- |
| `PrivateFunction` | Worker ID, live parameters, result representation, covered dependency set |
| `Case` | Evaluated scrutinee ID, exact constructor/layout identity, ordered alternatives |
| `Project` | Scrutinee ID, proven layout, field index and erasure information |
| `DirectCall` | Worker ID, ordered argument IDs, result representation, tail flag |
| `Bind` / `Return` | Explicit evaluation order and value IDs |
| `Construct` | Proven layout and ordered field computations |
| `Primitive` | Existing proved primitive operation and ordered operands |
| `ResidualCall` | Existing generic boundary; no new inference by the printer |

Use the existing JIR literals, arithmetic, shifts, and branch expressions where
their semantics fit. Do not encode the new operations as invented `KTerm`
tags that later require another pattern recognizer. Maintain a typed lowering
context from the original checked terms while producing this IR.

The lowering algorithm consumes a queue of supplied argument values. A lambda
binds the next value, preserving erased slots in the source context but not in
the private ABI. A matcher consumes the next scrutinee, emits a `Case`, and
prepends the selected constructor's live fields before the remaining values.
The default branch retains the original scrutinee. When the signature is
consumed, lower the result expression normally. A returned function or an
unsupported representation refuses this worker; it does not become an
implicitly trusted direct call.

Do not flatten ordinary source applications merely because their eventual
type has more arrows. This private slice relies on the stronger complete
`JPure` prefix proof: before the full live signature is consumed, a function
contains only binders and exhaustive typed matching on privately produced
values. There are no computed initializer effects or refutable cases between
the argument chunks. Arguments themselves still evaluate left-to-right and
finish before the next argument. This permission does not extend to ordinary
`JIRApply` nodes outside the proof.

Parallel-let right-hand sides remain outside all new bindings. Constructor
fields retain left-to-right demand and completion before the following field.
Only already admitted pure private fields can become eager direct values;
public `build` messages and opaque residual expressions retain their current
demand protocol. Match projections use the established layout facts, including
native strings, tuples, and tagged user constructors; do not assume every
constructor has `.a` fields.

## Current recursion implementation and further passes

`worker-model.bend`, `worker-lower.bend`, and `worker-emit.bend` implement the
typed lowering and printing. `worker-simplify.bend` removes the impossible
fallback of proved one-constructor tuple/character cases, and
`worker-graph.bend` computes components from the explicit calls. Typed cases
and field projections are explicit. Intermediate values have function-local
slots; calls are separate instructions. A shared printer renders those slots
as scalar locals for acyclic functions or array slots for recursive components.
The latter reserves function-entry labels first, then allocates disjoint
branch and return labels. A return restores parent registers before its
continuation stores the result.

The first executable candidate placed the whole graph in one dispatcher.
Actual Node CPU profiles then reported `Function is too big to be optimized`
for both representative machines. Each held 52 functions and roughly 71 KB of
source. Their graphs contained 47–48 components; the largest component was
about 16.6 KB, and the important mutual-recursion pairs were much smaller.
That evidence motivated partitioning before attempting elaborate register
allocation. This is a general graph transformation, not a program selector.

Recursive components initially save the whole current register array.
Liveness reduction, frame pooling, and fall-through branch blocks remain
future local optimizations. Same-component calls allocate their next argument
array; tail calls avoid a saved frame. Acyclic functions allocate neither
register arrays nor continuation stacks. An isolated in-place tail-vector
experiment did not improve its initial screen, so the partitioned candidate
restores the allocating form. These costs must be measured against the
descriptors, projections, closures, copied vectors, and bounce messages removed.

## Why a saved-output rewrite is insufficient here

The checked04 modules contain public `fn`/`matcher` trees and some private
workers, but do not serialize a complete per-definition typed proof and live
signature. `$guards` records runtime dependencies, not permission to convert
every definition it mentions into a worker. The same descriptor syntax also
appears in generic fallbacks, partially applied functions, and definitions
whose native layouts require different projections.

A saved-output prototype would therefore need a new proof sidecar exported
from checked lowering. Reconstructing the missing facts from JavaScript would
duplicate the proof system and risk silently widening admission. The initial
experiment should instead implement the small source-level slice above, or
first emit that sidecar and strictly consume it. An unsafe universal rewrite
would only measure an upper bound, not establish an implementable gain.

## Verification and stop conditions

Before any long rebuild, inspect a few emitted functions and require a receipt
listing selected proof members, original/live signatures, direct edges,
refused components, and remaining residual calls. A successful transformation
must demonstrably remove descriptors or generic applications from selected
private bodies. Merely adding wrappers does not test this hypothesis.

Use renamed/generated fixtures covering acyclic helper chains, nested ADT
matches, erased arguments, partial and returned-function rejection, parallel
lets, deferred fields, public descriptor mutation, prototype hooks, and
effectful/error-producing arguments between curried application chunks.
Retain the existing backend semantic suite and exact conformance comparison.
When SCC lowering lands, add deep self/mutual tail recursion and non-tail
reconstruction controls before timing.

Root-controlled timing should first use the existing short representative
screen, followed by the full set only after a material gain. Compare runtime
and allocation against the same checked04 parent. Report both selected static
coverage and measured dynamic cost; neither substitutes for the other.

The partitioned implementation is 683 lines across five modules, plus small
shared-entry integration and independent controls. It removes generic
invocation allocation on lowered private edges; acyclic functions additionally
avoid machine register and frame allocation. Whole-suite gains remain
unmeasured. A 6× gap cannot be promised away by this slice alone.
