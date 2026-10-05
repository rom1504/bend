# Phase53 refinement: compose the pinned emitter's evaluation order

This refines the original ordered-expression plan before any optimization
candidate was compiled or timed. The first isolated patch remains preserved
and unexecuted under `ordered-prefix01`.

The expanded callback controls exposed a concrete existing direct-backend gap:

```text
U32.mul(f(n), U32.add(g(n + 1), 3))
```

Direct06/corrected01 call `f` then `g`; pinned TypeScript calls `g` then `f`.
The first control assumed universal left-to-right execution of pending argument
expressions and therefore failed on the reference. Its bytes and failure remain
recorded. The selected direct interface already requires upstream callback/error
observation order; changing that requirement is not the proposed resolution.

## The actual rule

Pinned `comp.ts` `js_call` first maps `js_expr` over all arguments. Recursive
expression lowering can append child statements during that traversal. Only
after all child prefixes have been emitted does an intrinsic call hold its
pending non-atomic argument expressions in temporaries. An ordinary call keeps
those expressions pending. In the example, the nested addition emits a hold for
`g` before the outer multiplication holds `f`.

The revised representation remains `(prefix, value, nextTemporary)`, but it
follows that two-stage rule. Prefixes concatenate in traversal order; pending
values are held only at the same intrinsic boundaries as the pinned emitter.
This is an observable target-interface rule, not a claim that every language
construct executes effects in textual left-to-right order. Explicit sequential
lets, erased work and branch/closure demand retain their own policies.

## Composition and new falsifiers

Apply the representation through named calls, unknown function applications,
constructor fields and expression lets. An opaque expression boundary can hide
child prefixes and reproduce the original bug, so fixing only the reported
outer intrinsic is insufficient. Preserve literal and inverse-view folding,
constructor field/erasure telescopes, lexical binding capture and parallel let
scope. Closure bodies keep their prefixes inside the closure. No per-operation
IIFE or benchmark-specific condition is introduced.

Independent controls cover the original nested multiplication, an unknown
callable around it, a constructor containing it, and a let expression as an
argument. Confirm the pinned reference before accepting revised event oracles.
Only the two original mistaken callback-order expectations are corrected in
their versioned successor; their values, errors, sources and all other controls
remain unchanged. The corrected baseline is expected to fail the newly exposed
interface tests. The selected successor must pass them; this is not a waiver.

Fresh NaN source oracles remain mandatory, including cold and repeated calls.
The premeasurement performance criteria in `optimization-decision-v1.json`
remain unchanged. Broader traversal adds risk and must earn its place through
the source/interface controls and the paired eight-point screen before full45.
