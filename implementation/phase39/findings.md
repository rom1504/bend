# What transferred from compiler research

The useful common idea in the [Phase38 studies](../../design/phase38/README.md)
was to retain known calls, arity, evaluation order and value shape across a
useful unit of work. Phase39 tests that idea through small compiler rules before
introducing another intermediate representation. The final measurements and
admission decision are recorded separately in [the phase report](README.md).

## Four retained mechanisms

1. **Private countdown representation.** The existing exact Number-countdown
   proof now applies to eligible scalar loops as well as vector loops. Public
   Nat values remain BigInt. The predecessor must be used once, immediately as
   the next countdown; observations or escaping values retain the generic
   representation. This removes repeated private BigInt decrement/conversion
   work without changing arbitrary Nat arithmetic.
2. **One proof scope for a complete scalar root.** Reuse the existing tree-scope
   mechanism when the complete typed body and helper graph satisfy the existing
   purity proof. Repeated ray helpers can share one successful entry check.
   Public mutation and callback reentry still invalidate or suspend the proof.
   Merely seeing a small finite selector is not enough to open a scope.
3. **Direct two-child structural recursion.** A private explicit-frame worker
   follows a proper field of its first argument. It preserves the typed prefix,
   computes two independent recursive children in order, and retains generic
   leaf/combine behavior and tagged values. Backedges through helpers,
   dependent recursive calls and unsupported shapes decline this lowering.
4. **Direct unary producers.** A proved immediate-predecessor recursive call
   inside a known saturated combiner uses explicit frames. Arguments before the
   child are evaluated during descent; arguments after it are evaluated during
   unwind. The existing producer proof admits bounded nested constructor
   terminals but refuses helper calls hidden inside their fields. Constructor
   tags, complete values and sharing remain observable.

The two recursion forms need different admission and evaluation-order rules.
They share existing machinery where justified; the result does not establish
that one general optimizer would be smaller or faster. There are no new compiler
modules, types, laws or runtime helpers, but the unary producer adds a case to
an existing flag. The compiler grows by 364 physical Bend lines and 42 definitions.
That is an explicit complexity cost, not a simplification result.

## Why the short experimental loop helped

Saved-output experiments tested the mechanism before another checked compiler
build. An independent structural fixture then tested whether the rule generalized
beyond the tuned tree program. Every retained optimization ultimately had to be
emitted by the same checked compiler and pass controls on that actual output.

This distinction caught a concrete integration bug: checked02 and checked03
emitted tree-worker calls without declarations. Successful compilation and a
successful handwritten prototype were insufficient. The final declaration and
callsite analyses use the same original book definition; the control requires
exactly one declaration for every emitted worker target.

The expression prototype showed that avoiding generic recursive calls and a
generic Nat selector could matter more than narrowing the counter alone. The
implemented rule keeps its BigInt counter. Its gain must not be attributed to
Number arithmetic or to eliminating the materialized expression tree.

## A rejected recommendation is also a result

The existing list-pipeline benchmark is already first-order and therefore did
not test known-callback specialization. A separate checked affine callback
fixture did. A saved-output direct-call prototype recovered about 4–5% against
its added proof scope, but the combined variant was 9.5–13.8% slower than the
original in the short paired screen. Adding an exact-code entry also enabled a
module-wide generic-call WeakSet check, so this was not solely a fixed entry
guard cost. No callback specialization, broader callback proof or fusion was
retained. See [the complete negative result](callbacks.md).

## What these experiments do not establish

The profiles estimate sampled allocation during a window, not exact object
counts or retained heap. Profile shares cannot assign all combined speed gains
to one source change. Short screens contain substantial warmup drift; the final
paired execution reports are the acceptance evidence. Each fixed point retains
its own ratio, distribution and scope; there is no claim about an average Bend
program or TypeScript parity.

Existing frontend/backend conformance and semantic owner groups must all run on
the selected image. The historical `coverage-holdout` name is retained for
catalog compatibility, but those families are now exposed. Independent fixtures
are useful transfer checks, not a new unseen performance distribution.
