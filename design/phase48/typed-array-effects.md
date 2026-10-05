# Typed array effects through shared private representations

Status: implementation proposed; no Phase48 target execution or speed claim.

Phase47 proved a closed scalar region may replace fresh canonical `Array<U32>`
handles with backing arrays. The current proof hardcodes U32 in the allocation
argument, every native telescope, and the returned pair. Thus an unchanged
representation principle fails for F32 cells, `swap`, and `size`. Adding names to
the raw emitter would leave source calls, typed planning and handle fallbacks
inconsistent. This phase replaces that repeated assumption with one typed effect
contract, consumed by both representations.

## Scope and invariant

The initial family is canonical `Array<U32>` and `Array<F32>` with `new`, `get`,
`set`, `swap`, and `size`. Each native operation must retain its original native
definition, erased type kind, arity and fully specialized parameter/result
telescope. The array element must agree at every array/value position: a size
returns U32 independently of the element; a get/swap returns the element. Local
names resembling native types or operations do not establish these facts.

Raw arrays still require fresh local allocation, scalar public inputs/result,
the complete bounded first-order helper audit, original live dependency guards,
and a fresh host guard before any observable old guard. No host permission is
cached. Callback operations, public array inputs/results, explicit ALeaf/ANode
construction/matching, and unsupported residual calls remain outside raw
admission. A separate handle-preserving result adapter may consume the same
effect proof without changing observable handles into newly wrapped raw arrays.

## Semantics and source evidence

The pinned Base at `018751270e800bc222a93dad7f257083ee53a5f7` defines `new/get`
over erased Data and `set/swap/size` over erased Type. Its TypeScript compiler
uses raw JS arrays and native operation templates. This is representation
evidence, not permission to copy its observation order: the selfhost runtime's
`Array.swap` calls `arrayget` then `arrayset`, performing two Number conversions
and length reads. The new raw swap retains those two operations. All argument
values are evaluated left-to-right once before the first read/store. Size returns
the identical array alongside its length; set returns the identical array; swap
returns it alongside the old cell.

F32 remains a JavaScript Number. Arithmetic uses the existing `Math.fround`
primitive emitter; `F32.to_u32` uses the existing checked conversion helper.
Stores and reads introduce no rounding. NaN, signed zero and subnormal values
must survive exactly as before. Any F32 source/helper/type fact retains the full
fresh host guard, including rounding, conversion and input-validation hooks.
Modified Number, fill, arithmetic or reflection hooks select the complete old
wrapper; its effects and errors must remain visible in their existing order.

The old U32 new/get/set spellings remain unchanged where possible. Their ordered
statement-store lowering also applies to F32 because its captures follow the
checked telescope and do not interpret the cell. New swap/size expression
lowering is deliberately small; another store optimizer is not required.

## Modules and integration

`array-effects.bend` owns canonical element/layout facts, native signature proof,
pair facts and a common handle/raw expression emitter. `array-view.bend` retains
the closed graph and representation permission, admits already-proved F32 scalar
operations, normalizes all permitted source native calls, and delegates printing.
The root integrator replaces old local native/pair implementations with thin
delegates, permits canonical F32 at the existing erased element slot, and points
the region native printer at the common implementation. No runtime changes.

This removes the old parallel U32-only native proof rather than maintaining two
inconsistent native catalogs. Public constructor layout and ABI are unchanged.

## Evening diagnosis and limits

The maintained Evening fixture's `fpart` uses F32 `Array.swap`, but it allocates
an explicit `ANode{ALeaf{0.5},ALeaf{1.5}}` and is nullary. The raw contract still
requires `Array.new` and a positive scalar entry. Its enclosing `main` also
contains Map/Set/string operations outside this array-only proof. Therefore this
slice alone is not evidence that Evening's hot path becomes private. A future
literal-array producer proof must preserve constructor demand and lazy backing
materialization, or a separate handle-preserving adapter can keep the original
constructor representation. Nullary evaluation must remain repeated and demand
correct. We will report actual selected entry evidence, not infer activation
from the presence of a new operation name.

## Validation and decision

Add a renamed standalone fixture with F32 recurrence, swap/get/size transport,
U32 size and swaps, aliases and public-array refusal. Independent finite oracles
round at each source arithmetic step and distinguish signed zero/NaN. Separate
counter derivatives establish actual raw entries and full host-guard selection.
Host mutation controls compare clean baseline/candidate event sequences, with
two index conversions on a swap, thrown index/value/conversion behavior and
late fill mutations. Keep previous Phase47 controls and the core8 gate intact.

Only the root runs checked builds/acquisition/controls. Measure maintained
programs after activation and semantic gates. A proof extension with no corpus
activation is a capability result; it is not a runtime improvement or full
conformance gain. Unsupported boundaries and any failed attempts stay recorded.

## Full permission on newly admitted handle fallbacks

Review of the complete entry ladder exposed a second obligation: refusing a raw
entry must not pass a newly admitted F32/swap/size graph to the old weaker private
handle guard. `regionHostGuard` omits Array.fill and Number.isSafeInteger. A fill
callback could change a source helper after the dependency check, while a direct
private call would bypass the replacement. The correction therefore strengthens
both scalar/tree and flat-record handle entry guards for the new effect domain.

The initial 53-line proposal distinguished new F32/swap/size graphs from old U32
new/get/set graphs. Independent review confirmed the same late allocation
callback hole applies to the old domain. Preserving that admission would retain
the known unsoundness. The unused scoped proposal is preserved with its hash in
`selfhost/tools/performance/phase48/proposals/array-effect-guards-scoped.bend`.

The selected correction is eleven lines: every graph with a proved native Array
helper requires the existing fresh array host guard on its handle path. Both
ordinary/tree and flat-record entry selectors apply it before inputs/dependency
reads. No runtime cache or new hook snapshot is introduced. Controller v3 changes
Array.fill to replace `wash.step.code` with a throwing callback. A separate old
U32-domain fixture changes fill or isSafeInteger to replace `river.read.code`.
It compares the candidate against ordinary ungranted source execution in both
images, and records a historical public-path mismatch separately instead of
preserving the bug as an oracle. This remains a source-audit finding until the
root executes the retained old/new candidate controls.
