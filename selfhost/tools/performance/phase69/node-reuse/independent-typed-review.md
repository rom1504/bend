# Independent review: typed private worker parameters, v2

Reviewed `typed-worker-candidate-v2/source.patch` and its retained before/after
sources. Patch SHA-256:
`b408251bc20f5afbfd1451d11297de3ac1a39f375b0914f07d4544b31eaf718f`.
This is source inspection, not an executed compiler or correctness result.
No concrete source blocker was found; checked build and controls remain needed.

## Representation boundary

Only canonical zero-argument ADT heads named `U32`, `F32`, `Char`, or `Bool`
whose looked-up owner is a trusted Base ADT receive the 32-bit kind. `F32` is
still its raw 32-bit representation; the proposal does not reinterpret it as a
C float. Checked Bool producers use canonical immediate 0/1 values. Tagged raw
Bools, user enums, Nat values, unknown type heads and all flattened product
fields remain full Terms at any boundary lacking the checked certificate.

`NATIVE_TYPED_SCALARS` is set only by `nc_compile_checked`, using the existing
packed-layout and trusted-effects permission. An ordinary raw `nc_compile`
leaves `NF_SCALAR` equal to `Term`, even when supplied raw annotations happen
to spell a trusted scalar type. This gate must remain part of the rule: type
spelling alone does not prove raw values or foreign returns fit 32 bits.

## Telescope and product alignment

The actual worker argument count must match `jd_live_arity` of the original
definition before kind extraction. Erased binders consume no argument slot.
Unresolved dependent domains or exhausted type-normalization fuel become
opaque. Product expansion replaces one original kind with exactly the shape's
field count, all opaque, so it cannot accidentally transfer a later scalar
kind onto an earlier product field. The expanded kind list must have exactly
the same length as the emitted bindings; otherwise every binding falls back
to `Term`.

The change to `NF_Worker.params` is rendering metadata. Ownership-bearing
`NC_Target.params`, lowering environments and self-tail moves retain their
existing `NC_Binding` values. All inspected stored-worker consumers either
render, count, or preserve the new list. Prototype and definition rendering
use the same list; generic adapters still take boxed Terms before C performs
the checked scalar conversion at a private call.

## Integer semantics and controls

Narrowing a C formal can change C expression promotion, even when its input
value fits 32 bits. The inspected `u32_to_nat` intrinsic explicitly casts to
`u64`, protecting the concrete widening path. Keep the separate
`fixtures/scalar-widening.bend` control: two UINT32_MAX inputs must sum to
8589934590n, 65536 squared must be 4294967296n, and actual U32 addition must
still wrap to 1. Its combined output is 12884901887n.

Additional meaningful checks are a Nat above 2^32, tagged user enums, F32 bit
round trips, Bool match/comparison results, an erased type binder before a
scalar argument, and a flattened product before a later scalar argument.
Raw controls should inspect generated signatures as well as output: the raw
macro must still select `Term`. Unknown foreign sources and certificate
refusal must disable narrowing. Test ordinary and tail calls under one and
four threads.

The inferred metadata adds compilation work to every considered private
worker. Runtime gains do not establish a compilation-speed gain; measure its
incremental checked B1/B2 cost before promoting a broad performance claim.
