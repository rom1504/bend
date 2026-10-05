# Ordered private array writes

Status: implementation authorized after the five-way saved-output experiment.
This is separate from raw-layout admission and host-guard reduction.

The [LLVM survey](../../research/compilers_architecture_and_techniques/llvm.md)
and [Go survey](../../research/compilers_architecture_and_techniques/go.md)
both point to making operations and their order visible before asking later
optimization passes to simplify them. Go's explicit memory dependencies and
LLVM's aggregate cleanup are relevant design lessons; neither licenses adopting
C undefined-behavior assumptions or moving observable JS conversions/errors.

The existing typed private-region plan already distinguishes canonical native
array operations. Its statement consumers should express a store as a store,
with a result destination, instead of rebuilding a tiny immediately invoked
function in every array-valued field. Full SSA or MemorySSA is unnecessary for
this local, order-preserving transformation.

## Rule

Inside the completely proved raw-array context, an exact four-argument
`JNative Array.set` in a supported statement-result position becomes:

```js
{
  const $arraySet0 = null; // original erased slot
  const $arraySet1 = arrayExpression;
  const $arraySet2 = indexExpression;
  const $arraySet3 = valueExpression;
  $arraySet1[Number($arraySet2) % $arraySet1.length] = $arraySet3;
  destination = $arraySet1; // or: return $arraySet1
}
```

All live arguments finish in source order before Number, length lookup, or the
write. Each runs once. The store remains at the same field/return demand point;
it is never hoisted, discarded, or moved across another field. The returned array
identity is unchanged. Fresh lexical temporaries prevent collision across fields.

One shared statement-result emitter serves existing region vector-field
destinations and direct private helper returns. A destination is an already
declared region result variable or a return continuation. Other expression-only
contexts retain their current emitter. This initial scope should be stated
explicitly; it is a general operation rule, not complete expression-to-statement
normalization.

Keep static raw-array admission, public fallback, dependency guards, runtime
guard, Number calls, dynamic length reads, and loop-carried aliases unchanged.
The independent invariant-alias diagnostic gave no useful gain, so do not add a
loop-invariance pass in this change.

## Qualification

First build the isolated write-only candidate. Verify generated hot-loop stores
are statements and fallback bytes/behavior remain unchanged. Retain independent
alias, host mutation, zero-trip, public-object, and demand controls. Add index
and value argument helpers that record/throw independently, proving their order
relative to the store. Re-run clean public-call timing and canaries before
combining this change with native source-App normalization.

No new general CSE, dead-store elimination, guard weakening, or speed guarantee
is implied. The next extension should have its own actual consumer and causal
measurement.
