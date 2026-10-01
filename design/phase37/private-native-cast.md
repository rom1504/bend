# Private F32 conversion without generic dispatch

Status: saved-output hypothesis; no canonical compiler change or result assumed.

The expanded numeric recurrence is already compiled into a private Nat loop,
but each iteration still applies the mutable public `F32.to_u32` descriptor
through `get`, `callOwned`, generic exact application and forcing. Its existing
entry guard already checks that descriptor and the relevant host hooks. The
hypothesis is that invoking the same native body directly inside that guarded
loop removes substantial dispatch overhead with a small compiler change.

## Semantic detail found during inspection

The runtime installs `F32.to_u32` twice. The earlier registration saturates; the
**final effective registration** returns zero for nonfinite input, negative
input or input at least2^32, and otherwise returns `Math.trunc(x) >>> 0`. Any
experiment or implementation must use that final behavior. In particular,
positive infinity and2^32 do not map to the maximum word.

Public `G['F32.to_u32']` must remain a normal mutable native descriptor. Adding
the name to global primitive emission would bypass mutation and is rejected.
Its input must be evaluated exactly once. Host `Number.isFinite` and
`Math.trunc` remain observable on generic calls; changes to those hooks must
refuse the private loop through the existing host guard.

## Smallest production route if the screen wins

Reuse the existing `JNative` path rather than introduce a new optimizer node:

1. Extend `j_region_local_native` only for a one-argument call whose checked
   definition passes the existing exact `j_pure_native` F32-to-U32 signature
   proof. Keep the original native kind, arity, erasure and foreign checks.
2. Reuse `j_region_native_dependency`, so the native remains in the complete
   descriptor guard even though private execution bypasses its public wrapper.
3. Emit a call to one module-private runtime helper from
   `j_region_native_emit`. The helper argument provides single evaluation.
4. Register the final public native using that same helper body, preserving
   the native descriptor and generic application path. No duplicate semantics,
   global intrinsic admission or new guard system is needed.

Inspection suggests roughly10–30 source lines, including comments and runtime
extraction, with no new IR node. This is an estimate; actual source growth and
normal compilation cost must be measured. The existing region path can include
arrays; direct conversion itself must not add a callback or widen the source
graph beyond existing admission. No independent purity shortcut is proposed.

## Saved-output experiment

`optimizer/native-cast-derive.mjs` requires the exact Phase36 numeric module and
replaces two known private calls: the guarded public Nat loop and the private
helper inside the guarded benchmark root. The original generic fallback call
and public native descriptor remain unchanged. Clean original/direct modules
are separate from diagnostic counter modules. The saved-output prototype copies
the final native body into a private helper; production should share its body
with registration to avoid semantic drift.

The comparison uses both frozen numeric points,256 and1024iterations. The
correctness worker checks independent recurrence outputs, cast boundary values,
private-entry counts, one argument evaluation, descriptor mutation, public/raw/
partial entry and host-hook changes. Invalidated guards must have live generic
witnesses; matching outputs without executing the changed hook is insufficient.

Root alone derives, validates and times the variants under the existing shared
resource supervisor. The separate tree experiment remains valuable, but a
material cast improvement at this small implementation cost should be evaluated
before accepting hundreds of lines of new finite/tree machinery.

## Revision after the saved-output experiment

The prospective status above records the original hypothesis. The first screen
found a large dispatch cost, but its original correctness controls missed an
observable host callback. It is not an acceptable implementation candidate.

F32 literals use `bitsFloat`, which calls `setUint32` and `getFloat32` on one
module-private `DataView`. A patched prototype method can replace the public
`F32.to_u32` descriptor after entry to the private region. The original generic
call observes that replacement; an unguarded direct native call skips it. The
checksum can remain identical while the sequence of observable callbacks
changes. This is a correctness failure even for an otherwise pure scalar body.

A prior generic invocation can also leak the shared view through a callback's
`this`, then restore the prototype. The attacker can subsequently install own
methods or a replacement prototype on that instance. Checking the public
prototype alone therefore does not close the proof.

The corrected guard checks the original `DataView` constructor and prototype,
the prototype's parent, the shared view's prototype, and absence of own
`setUint32`, `getFloat32`, `setFloat32` and `getUint32` properties. It also checks
the original four prototype method descriptors through the existing host-hook
guard. The latter two methods cover the corresponding `floatBits` path. The
checks execute at region entry; the existing proof scope covers nested private
calls that cannot run an intervening user callback. Generic fallback retains
all host and public descriptor observations.

The preserved adversarial worker has 22 observations: prototype and leaked
instance wrappers, getters, mutation, reentry and errors, plus replaced instance
prototypes. The vulnerable prototype failed 18; the corrected prototype passed
all 22. All 27 original oracle observations, 53 boundary controls and three
admission witnesses also passed on the corrected prototype. These are measured
results of the saved-output experiment, not certification of actual compiler
output; see the [prototype report](../../implementation/phase37/optimizer/native-cast-prototype.md).

The compiler patch reuses `JNative` with explicit `F32.to_u32` name and arity-one
admission in addition to `j_pure_native`. Admission by the latter predicate alone
would also admit `Bool.xor`, which does not belong to this emitter path. The
public descriptor and private call share the final helper body. No new optimizer
node, global primitive, or general-purpose native inlining is introduced.

The next gate is a fresh checked build and emission of
`optimizer/native-cast-fixture-v1.bend` by Phase36, the new candidate and the
pinned TypeScript compiler. The adapter for that gate instruments only actual
emitted call sites; it does not substitute the optimizer, runtime helper or
guards. Its manifest binds source, checked API, runtime, Base, frozen compiler
snapshot, producer and emission receipts. Dedicated controls cover native cast
boundaries, exact output oracles, demanded source calls, argument evaluation,
order, unused values, delayed partial closures and the adversarial host changes.
The guard's common entry cost must also be measured on short scalar programs.
