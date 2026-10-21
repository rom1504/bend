# Phase121 offline semantic and IR review

Reviewed `fusion03.bend` and `callback02.bend` against the existing JS
`j_fusion_*`/`j_callback_*` predicates, native scalar lowering and direct-IR
verification. The composed source inspected is
`3edd22028a2c2601caa715d2dbbc3694b3fc0a402ad7eda588c438ce64d615d2`
(`fusion-source04`). This reviewer performed no target runs or compiler builds;
the independent expected-value models and ordinary control sources were prepared
offline. Root-owned measurements and execution results belong in the main report.

## Conclusions

No remaining concrete semantic mismatch was identified for the admitted **checked
source** subset. This is a finite code review, not a correctness proof or a claim
that arbitrary malformed API terms are admitted safely.

- List fusion admits a closed, nested scalar use of a structurally verified
  producer/filter/map/left-fold pipeline. Constructor owners, field layout and
  native primitive identities are checked. Intermediate lists cannot escape or
  be shared under this shape. U32 wrapping and fold order remain unchanged;
  interleaving previously separate traversals is justified by the admitted total,
  pure scalar operations. The native comparison lowerer produces canonical 0/1.
- Callback fusion admits an immediately applied, structurally known factory and
  exact `g(f(x))` composition. It preserves descending n-to-1 application order.
  Replacing `U32.from_nat(pred)` with the numeric predecessor is justified by the
  original `U32.to_nat` of a U32 count and the guarded decreasing countdown.
  Unknown calls, escaped functions and reversed composition are outside admission.
- Scalar expressions use the existing native lowerer; public wrappers and private
  loops retain ordinary dependency, ABI and IR verification. Generic program
  segments remain available. Output correctness alone is insufficient: successful
  transformation activation must be checked separately from fallback.

The initial review identified missing syntax bounds and fixed fresh-ID intervals.
The selected source now has a 2048-node/64-depth candidate worklist and threads
`p113d_fresh` between scalar snippets. These address the identified issues without
adding another scalar evaluator.

## Erased-prefix adapter

Native checked helper definitions carry erased `Lam q0`, while the reused JS
predicate expects source-view `Lam q1`. `p121c_source_prefix` changes only three
lambda quantities in a temporary analysis book after proving exact `All q0`,
`Type&1`, unary lambda structure and absence of each erased binder from runtime
syntax. The complete original composition/factory checker then validates live
types, exact application order, recursion and primitives. `book_put` updates cached
lookup correctly. Emission continues from the original book. A failed partial
prefix leaves `Absent`, which the complete composition shape rejects.

The recommended finite adapter controls—wrong universe quantity, non-erased
formal, erased-variable runtime use, incomplete prefix and mixed-prefix behavior—
were **not executed by this reviewer**. They remain explicit coverage limits;
mixed q0/q1 prefixes may conservatively refuse. The ordinary reversed-composition
source control is distinct from those metadata controls.

## Evidence inspected and limits

In `p121-fusion-emit04`, the private list worker contains scalar generation,
filtering and accumulation with no construction/take/runtime calls in its loop.
The private callback worker likewise contains arithmetic and a backedge, with no
closure construction/application. This establishes emitted structure, not timing.

Ordinary controls cover renamed helpers, noncommutative folds/callbacks, wrapping,
empty and larger counts, sharing, returned lists, native-looking user functions
and reversed composition. Their independent models retain complete values.
The whole JS root guard was not transplanted: native admission relies on the
checked book and these narrower structural/type/primitive proofs. It is not a
general effectful fusion or ownership theorem.

No new native N1/N2 image, self-reproduction, compiler-throughput improvement,
GPU/parallel qualification or production promotion follows from this review.
Two related input sizes do not constitute unrelated-family transfer, and source
ceiling substitutions remain separate from implemented compiler transformations.
