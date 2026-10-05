# Entry guards from complete operation footprints

Status: rejected as a sufficient admission proof; no executable derivative or
source integration. A selected-worker footprint alone omits observable hooks
from the original checked program and its generic dispatch/forcing runtime.
The allocation-free raw-entry guard is deferred after its measured screen;
[the outcome](../../implementation/phase48/entry-profitability.md) includes
its adverse midpoint. A new specialization must remove repeated proof work,
not just the temporary vectors used to perform it.

## Proposed candidate and missing original-path proof

Qualify a complete closed raw-array component and derive its host dependency
footprint from the final selected worker IR, including every reachable helper.
Keep the original public entry and generic fallback. Emit a private guard only
for a root whose full component has no generic call, demand/force operation,
callback, public data input, String, F32, foreign/native fallback, or Error
operation. Initially retain scalar inputs and result, privately constructed
raw arrays, immediate private tuple destructures, and total U32/Nat arithmetic.
All other roots use the current guard.

This is a structural property of the selected component. Neither source names,
benchmark IDs, input sizes, nor measured timing choose a mode. Failed admission
retains the complete old path. No successful admission is cached across calls.
The existing owned-array and alias proof remains required; this proposal does
not grant ownership to host arrays or public Array data.

The footprint must cover the selected emitter implementation, rather than
only the source term. For example, U32 multiplication emits `Math.imul`; raw
indexing and allocation convert canonical numeric operands with `Number`;
`arrayfill` uses `Array(size).fill`, exponentiation and `Number.isSafeInteger`.
An erased source argument can still appear in an emitter IIFE. That argument
and its evaluation order must be included until it is actually erased.

## Initial mask and obligations

| Operation or guard behavior | Keep freshly checked | Can omit only when absent from the complete emitted closure |
| --- | --- | --- |
| Canonical input admission | Number identity and `Number.isInteger`; exact primitive admission order | Number.isNaN/isFinite and F32 hooks |
| Raw allocation | Array identity, captured fill identity, Number conversion and isSafeInteger | No allocation hook may be omitted merely because its output is owned |
| Integer multiplication/division | Math identity plus imul/floor when emitted | Other Math functions and DataView hooks |
| Pure lexical helper call | Every original G binding and original code/arity/env/bound descriptor/prototype proof | Reflect.apply and WeakSet has/add, only when no generic invocation/forcing occurs |
| Indexed private arrays/tuples | Array/Object prototype chain and numeric-setter exclusion | concat, slice, push, pop, includes, iterator/species/spread protocols if neither worker nor guard invokes them |
| Source/function metadata | Original source identity, call override, io/typeName, primitive protocol marker exclusions | No source mutation dependency is removed by the host mask |
| Guard implementation | Captured descriptor/prototype/own checks; original early snapshots | Array.every/iteration only after the guard itself has no such calls |

The existing integer host guard already excludes almost all floating-point
hooks. Therefore an F32 mask alone is unlikely to explain the short-fold gap.
The larger possible saving is removing the generic invocation/collection
protocol checks which a fully closed raw component and its allocation-free
admission no longer execute. This is an opportunity, not a measured gain.

## Numeric setters prevent an aggressive shortcut

`Array(size).fill(value)` writes to holes using Set. An inherited numeric setter
on Array.prototype or Object.prototype can run during that allocation. The
current full prototype-name inventories conservatively exclude added keys.
The footprint proposal retains these inventories and the relevant prototype
chains. A shorter check for only `request`, `bounce`, `build`, and `code` is
insufficient: a newly added `"0"` setter is independently observable.

Replacing fill with private defineProperty writes would bypass this observer
and would not preserve the current mutation contract without an equivalent
preflight. Moving to that allocation does not by itself justify removing the
prototype checks. No such replacement is proposed here.

The private primitive prototypes retain protocol marker exclusion even if the
worker uses only primitive operators: the old public application/forcing path
can observe inherited request/bounce/build/code markers. Likewise all original
G dependencies remain checked; a mutation to Array.get or a helper must still
select its generic behavior rather than silently execute an inlined copy.

## Implementation boundary

Add an immutable operation mask to the existing closed raw plan, derived only
after component qualification. Accumulate the mask through every admitted IR
node and helper occurrence. A missing/unknown node or residual disables the
specialization. The mask covers total selected closure emission, not a worker
which happens to be emitted but is dead from the ordinary root.

Use a separate fresh guard entry: `regionProof === null` is mandatory before
checking its mask. Preserve the existing route whenever a surrounding proof
is present. No broad regionProof capability shortcut is introduced. Pass the
mask as compiler-owned metadata, not a public argument or public mutable
object. Avoid creating a new vector on every entry.

The guard performs descriptor reads through the existing early-captured
reflection helpers. It adds no host captures after embedded foreign
initializers run. Reflection, global constructors and the remaining selected
hook descriptors must be validated freshly. The scalar/source checks must
also be emitted without Array iteration/every before those protocol rows can
be omitted. Reusing ordinary scalarGuard would invalidate that omission.

Leave the original regionHostGuard and scalarGuard unchanged. This isolates
the new admission from F32, String, callbacks, residual data and native graphs.
The runtime fragment is optional until a qualified plan selects it.

## Independent qualification before measurement

A derivative producer must parse the actual selected worker closure and reject
unexpected calls, members, captures, residual generic names and public array
inputs before any mask experiment. A term-level source claim alone is not a
safe diagnostic permission. Instrument the ordinary entry separately from
clean timed output and require executed worker activation.

For each retained source dependency, test binding/code/getters/arity/env/bound,
prototype and call override mutation plus original Error/reentry behavior.
For every omitted host hook, mutate binding and descriptors, then require full
original/candidate result and observable trace equality; a mutation which the
original actually reaches invalidates the proposed omission. Retained fill,
Number, BigInt, multiplication/division and reflection mutations must force
the original path. Added inherited numeric setters must remain refusal tests.

Also retain invalid/unused input evaluation order, raw/partial public ABI,
aliased data refusal, zero iterations, deep private loops and proof cleanup.
Measure short/mid/long points with the same fresh-process rotated protocol as
the deferred experiment. The admission-bypass variant remains an explicitly
unsafe upper bound and supplies no permission for the footprint guard.

No diagnostic producer is released yet: proving the emitted closure language
and its guard jointly closed is the next bounded go/no-go task. A hand-written
list of supposedly irrelevant protocols would be too weak for this contract.

## Independent challenge: reject optimized-only narrowing

The root review identifies a decisive gap: the original checked source executes
generic call/force machinery even when the optimized private closure does not.
Array concat/slice/iterators, Reflect invocation and WeakSet operations can
therefore be observable in the original path. Removing their identity checks
would admit optimization after a mutation which must select that original
behavior. Absence from the optimized body and specialized guard is insufficient.

The required footprint is the union of the original checked program, its
generic dispatch/forcing runtime, the proposed admission and the optimized
closure. An omitted hook needs a concrete proof that it cannot be observed by
that original route, including intermediate curried applications and forcing.
The existing source-identity proof does not establish that host protocol fact.
The suggested generic protocol omissions have no such proof and are rejected
for now. They must not be tested as a supposedly safe source candidate.

Any later narrowly justified numeric-operation mask would still need the same
original-route audit; the existing integer mask already removes most floating
hooks. There is currently no demonstrated material omission beyond it. Keep
all current source/host guard checks and defer broader fresh-region vector
removal. Unicode actual activation remains the next qualification priority.
