# Private array regions

Phase47 adds a narrowly proved representation choice to the existing typed
JavaScript region lowering. This chapter describes the source mechanism and
its research lessons. It makes no installed-release or qualified-performance
claim; selection and release evidence belong to the Phase47 qualification record.

## Ownership and admission

An eligible public root accepts and returns canonical scalars. Its complete
existing typed region plan must prove canonical `Array<U32>` allocation,
reads and writes, local value transport, structured control, known private
calls and approved scalar operations. Arrays originate inside that invocation;
no array, container holding one, closure or callback crosses the public boundary.
Internal aliases are allowed and retain the same backing storage.

[j_array_view_plan and its bounded audit](../../selfhost/src/back/js/array-view.bend)
check the selected root and all private helpers, using the existing region's
source dependencies and canonical type/layout proofs. Unknown executable syntax
or exhausted audit fuel refuses the extra representation. This is a structural
proof, not a benchmark-name match or an assertion that all source arrays are safe.

The audit refuses public array parameters/results, Array constructor or matching
operations, opaque callbacks, foreign/unknown calls, uncovered adapters and
native operations outside its whitelist. General first-class array values and
mutable host-owned storage remain on the existing path. Type annotations and
unpack metadata are retained without being mistaken for executable operations.

## Raw backing transport and ordered operations

Inside the admitted private body, an ordinary JavaScript array represents the
source `Array<U32>`. Source types and public runtime layouts are unchanged.
A request-local `JSArrayViewContext` marker in BookCache selects this emission;
it introduces no mutable global mode or ownership registry.

| Source operation | Private representation |
| --- | --- |
| `Array.new(U32, depth, value)` | Existing `arrayfill(value, depth, '^').array`, at the original allocation site. |
| `Array.get(U32, a, i)` | Transport `a` and read `a[Number(i) % a.length]`. |
| `Array.set(U32, a, i, v)` | Store at `Number(i) % a.length` and return the identical `a`. |
| Existing consumed-read bridge | Use the already raw array as its data view. |

The allocation wrapper is still created and its fresh own backing property is
unwrapped once. This removes repeated descriptor-to-backing conversion; it does
not remove every tuple, allocation or call in the region.

At existing statement destinations or returns, `j_array_view_statement` captures
all write arguments before assigning, then continues with the same array.
Block-local `$arraySetN` temporaries preserve array → index → value → Number
conversion → length read → store order. Sequential vector fields keep their
existing order. Expression-only contexts keep the prior IIFE.
Allocations and accesses do not move across branches or zero-trip checks;
Number conversions and length reads remain at their original demanded sites.

A region may contain saturated source Apps for canonical array natives as well
as `JNative` nodes. `j_array_view_native_app` reuses the existing exact native
owner, telescope, element and arity proof and requires the original dependency.
Only after complete admission does normalization convert those Apps in the
private root and helpers to `JNative`. Erased operands remain unexecuted and
type metadata remains intact. This ensures one coherent representation across
calls; converting only some helpers would mix raw arrays with descriptors.

## Host guard and fallback

The [runtime's arrayViewHostGuard](../../selfhost/src/runtime.mjs) runs before
ordinary input and dependency checks. It uses captured descriptor reflection to
check host intrinsics, Array/Object prototype relationships and hooks, plus
`Array.prototype.fill` and `Number.isSafeInteger`. Inspecting a replaced accessor
does not invoke it. It conservatively refuses an already active `regionProof`;
a permission established for a different region is insufficient.

The complete no-callback graph and fresh host checks make private array access
stable for the invocation: an external proxy/getter cannot supply backing storage,
and allocation/conversion cannot enter a replaced hook. The existing runtime
premise of standard host intrinsics at module initialization still applies.

[j_region_root_selected and j_region_root_array](../../selfhost/src/back/js/region.bend)
retain the original helper declarations, source dependency guards and wrapper
path. A separate lexical private body receives the normalized raw representation.
If static admission or the fresh runtime guard fails, execution follows the old
wrapper selection, including its original checks, rather than skipping directly
to a generic body. Selection precedes body evaluation, so allocation/access is
not performed speculatively and repeated on fallback.

Existing self-tail lowering remains responsible for loop-state transfers.
The representation choice and ordered store do not replace a tail loop with
native recursive calls, move a zero-trip read, or change which tuple field is
demanded first. Error construction may reenter, but the failing computation does
not resume its private body; a nested invocation must establish fresh permission.

## Research lessons and limits

The [diagnostic record](../../implementation/phase47/v8-analysis.md) distinguishes
saved batch experiments from fixed public-library calls. Backing reuse and write
shape had different effects in those contexts. Public calls also pay admission
checks repeatedly, while an enclosing proved batch can amortize them. These are
scoped observations, not transferable library or release speed claims.

V8 consumes the emitted JavaScript and may inline calls, propagate shapes and
remove redundant work. The actual traces show both tested raw loops reaching
TurboFan before measurement without measured deopts; the profiles suggest a GC
component to the write-shape difference. They do not identify an eliminated
allocation or establish that the write IIFE was inlined. See the
[pinned V8 source study](../../research/compilers_architecture_and_techniques/v8.md)
for its separate historical source revision and inference boundaries. Bend's AOT
guard choosing its ordinary path is distinct from V8 speculative deoptimization.

Invariant length caching is excluded from this implementation. It added no
observed benefit to the saved backing-view probe and would require additional
movement and stability proof; retaining length reads keeps the narrower demand
contract. A general JW array pass is also outside this slice: the
[worker model](../../selfhost/src/back/js/ir/worker-model.bend) has generic native
values but no dedicated array allocation/read/write effect model or shared
alias/movement analysis. This region-local proof supplies a bounded consumer,
not those missing general facts or permission for unrelated worker emission.

The duplicated private helper closure has emitted-size and compilation costs.
Host-mutation/refusal controls, independent alias-sensitive values, checked
emission, maintained canaries and broader qualification are separate obligations.
The [safety contract](../../implementation/phase47/array-safety-plan.md) records
them; diagnostic derivatives and passing output oracles alone do not satisfy them.
