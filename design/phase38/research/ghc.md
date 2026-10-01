# GHC: demand, shape and usage are different facts

Research date: 2026-10-01. Documentation only. The inspected implementation is
**GHC 9.12.2**, tag `ghc-9.12.2-release`, resolving to commit
[`383be28ffdddf65b57b7b111bfc89808b4229ebc`](https://github.com/ghc/ghc/commit/383be28ffdddf65b57b7b111bfc89808b4229ebc).
Its annotated release tag is dated 2025-03-14. This is an intentionally fixed
research version, not a claim about the newest GHC release. No GHC build was run.
Estimates follow the [common contract](../method.md).

## Papers and exact implementation sources

| Primary source | Relevant inspected mechanism |
| --- | --- |
| [WorkWrap.hs](https://github.com/ghc/ghc/blob/383be28ffdddf65b57b7b111bfc89808b4229ebc/compiler/GHC/Core/Opt/WorkWrap.hs) | `tryWW`, `splitFun`, wrapper activation, join-point CPR, invalidated usage information |
| [WorkWrap/Utils.hs](https://github.com/ghc/ghc/blob/383be28ffdddf65b57b7b111bfc89808b4229ebc/compiler/GHC/Core/Opt/WorkWrap/Utils.hs) | Argument/result unboxing, worker arity limits, thunk/float barriers |
| [DmdAnal.hs](https://github.com/ghc/ghc/blob/383be28ffdddf65b57b7b111bfc89808b4229ebc/compiler/GHC/Core/Opt/DmdAnal.hs) | Demand signatures, roots, recursive analysis and compiler space considerations |
| [SpecConstr.hs](https://github.com/ghc/ghc/blob/383be28ffdddf65b57b7b111bfc89808b4229ebc/compiler/GHC/Core/Opt/SpecConstr.hs) | Known constructor call patterns, reboxing, specialization size/count/recursion limits |
| [Peyton Jones, *Call-pattern Specialisation for Haskell Programs*, ICFP 2007](https://www.microsoft.com/en-us/research/wp-content/uploads/2016/07/spec-constr.pdf) | Why recursive shape knowledge removes repeated matching and allocation |
| [Sergey et al., *Modular, Higher-Order Cardinality Analysis in Theory and Practice*, 2016 manuscript](https://simon.peytonjones.org/assets/pdfs/modular-higher-order-cardinality-2016.pdf) | Demand/usage summaries through higher-order code |
| [Maurer et al., *Compiling without Continuations*, PLDI 2017](https://simon.peytonjones.org/assets/pdfs/compiling-without-continuations.pdf) | Local joins in a direct-style typed IR |

The additions over [Phase35](../../phase35/literature.md) are the concrete
specialization limits, proof invalidation behavior, and the distinction between
implemented constructor specialization and comments proposing further work.

## What each mechanism establishes

Demand analysis computes how evaluation of an expression uses its components.
Cardinality distinguishes absence, single use and potentially repeated use;
strictness concerns whether evaluation is required. Neither property is the same
as a value's constructor tag or the purity of its producer. GHC records summaries
and treats externally visible roots conservatively.
[Demand implementation](https://github.com/ghc/ghc/blob/383be28ffdddf65b57b7b111bfc89808b4229ebc/compiler/GHC/Core/Opt/DmdAnal.hs),
[cardinality paper](https://simon.peytonjones.org/assets/pdfs/modular-higher-order-cardinality-2016.pdf).

Worker/wrapper uses these facts and constructed-product-result information to
create a different private calling convention. The wrapper retains the original
interface. The implementation limits expanded worker arity and avoids some
unprofitable splits. It does not add a separate CPR worker to a join when pushing
its consumer into the join can accomplish the same result.
[WorkWrap](https://github.com/ghc/ghc/blob/383be28ffdddf65b57b7b111bfc89808b4229ebc/compiler/GHC/Core/Opt/WorkWrap.hs),
[construction utilities](https://github.com/ghc/ghc/blob/383be28ffdddf65b57b7b111bfc89808b4229ebc/compiler/GHC/Core/Opt/WorkWrap/Utils.hs).

SpecConstr specializes recursive call patterns whose constructor shape is known.
The gain can include both a redundant match and a constructor that exists only
to be immediately unpacked. Its reboxing note describes a counterexample: if a
boxed argument survives elsewhere, a worker taking only fields may reconstruct
another copy, losing the intended allocation benefit.
[Paper](https://www.microsoft.com/en-us/research/wp-content/uploads/2016/07/spec-constr.pdf),
[pinned pass](https://github.com/ghc/ghc/blob/383be28ffdddf65b57b7b111bfc89808b4229ebc/compiler/GHC/Core/Opt/SpecConstr.hs).

Join points are local destinations used by saturated tail transfers. They allow
case branches and loops to share a continuation without making it an escaping
function value. This is a useful representation for a consumer of several
scalar results; it does not mean arbitrary callbacks are stack jumps.
[Join-point paper](https://simon.peytonjones.org/assets/pdfs/compiling-without-continuations.pdf).

## The facts Bend should keep separate

For a private node `Node(left,right)`, five questions have different answers:
is its tag known; are its fields already forced; can another reference observe
its identity; is it used only by one match; and can evaluating either field call
the host? A `JPure` success does not establish all five. An affine source binder
also does not prove the corresponding JavaScript object has one reference.

The proposed minimal summary is therefore a small set of independent facts:
known callee/arity, known constructor, demanded fields, nonescaping private
origin, and permitted return destination. Unknown means fallback. Facts should
be attached only where a measured emission decision consumes them; this does
not justify porting GHC's full demand lattice into the Bend compiler.

Explanatory specialization of an immediately matched private product:

```text
before: next = make_state(a, b); continue(next)
after:  continue_fields(a, b)
```

The transformation is useful only if `make_state`'s required computations still
occur in the same order and the object itself need not survive. If another path
returns `next`, retaining the object and passing its known fields may be better
than allocating a replacement. Existing slot and producer lowering already
implements parts of this idea; the next rule must identify a remaining gap.

For a private recursive tree operation, specialize the repeated constructor
transition within one complete component, then emit a direct worker. Start with
the current tagged layout. A bounded summary of the next recursive argument's
shape is more useful than repeatedly inserting a guarded selector at its leaves.

## Guard scope is a boundary decision

The local worker/wrapper lesson is to validate a useful computation once and
keep its interior private. GHC's native runtime is not evidence that mutable JS
descriptors or intrinsics may be assumed fixed. Our wrapper must retain those
checks. Phase37's rejected candidate added 1,968 tiny active-ray scopes and
regressed substantially; smaller workers were not automatically faster.
[Ray investigation](../../../implementation/phase37/optimizer/ray-regression.md).

Installed profiles attribute about 42.02% of active-ray self CPU to
`regionHostGuard` plus `scalarGuard`; numeric has about 30.22%. Idealized complete
removal would bound guard-only speedup near 1.72× and 1.43×, before secondary
effects. Real scope extension has costs and may cover only a fraction.
[Final profiles](../../../implementation/phase37/profile-findings.md).

## Planning ranges and risks

| Candidate | Incremental target on eligible Phase37 code | Complexity and confidence |
| --- | --- | --- |
| Amortize guards across more closed work | **1.15–1.5× active ray**; numeric already has one outer loop guard | 2–4-hour saved-output discriminator; roughly 1–3 days for complete proof/control work; medium confidence |
| Bounded recursive constructor specialization/direct component | **1.5–2.5× tree**, unproved transfer to maps or lexer | 3–7 days for a reusable first subset after ablation; medium tree evidence, substantial engineering risk |
| Extend the existing private Number countdown rule | **1.1–1.5× numeric** | 1–3-hour ablation, roughly one day for a narrow rule; medium confidence, small conceptual cost |
| Consumer slots instead of a surviving product return | Unknown additional gain until the residual container is measured | Medium demand/alias risk; much lower scope than general CPR analysis |

These are alternatives with overlap, not multiplicative gains. In particular,
tree specialization and MLton-style direct workers describe much of the same
runtime work. Numeric's BigInt countdown remains visible, but its loop's sampled
allocation does not prove that all that allocation is caused by BigInt.

## Compiler-engineering lessons and counterexamples

The pinned SpecConstr pass caps specialization count, size and recursive growth:
a recursive argument can acquire another constructor on each specialization,
producing endlessly deeper patterns. Its section about specializing lambda
parameters is exploratory commentary, not proof that arbitrary evolving closure
arguments are handled. Do not advertise that case as an implemented precedent.
[SpecConstr](https://github.com/ghc/ghc/blob/383be28ffdddf65b57b7b111bfc89808b4229ebc/compiler/GHC/Core/Opt/SpecConstr.hs).

GHC also clears used-once information after worker/wrapper because later changes
can invalidate it. The transferable lesson is proof lifetime: a Bend summary
must be recomputed, weakened or tied to immutable input when cloning or rewriting
changes its meaning. Reusing a stale summary is not a compiler-speed optimization.
[WorkWrap](https://github.com/ghc/ghc/blob/383be28ffdddf65b57b7b111bfc89808b4229ebc/compiler/GHC/Core/Opt/WorkWrap.hs).

For Bend, constructor failure order, field forcing, native lookup, erased
arguments and public staged application all remain observations. A wrapper must
not force an argument merely to decide whether it can optimize it. A region that
can call a host hook must suspend proof appropriately; `try/finally` restoration
and deep mutual-tail behavior need controls. Float rounding placement and Nat
overflow/error timing are independent of constructor shape.

## Cheapest experiments and admission decision

First derive a single outer-proof variant of final active-ray output. Count
actual entries and descriptor checks without timing that instrumented module.
Use a separate clean variant for paired timing. Adversarial tests must include
the retained DataView instance, descriptor getters, native replacement, and
`Error` reentry; a passing checksum cannot discharge these obligations.

For shape specialization, compare direct calls with unchanged layout against
field-passing without temporary constructors. Complete tree outputs, sharing,
delayed fields and 30,000-step self/mutual cycles discriminate the mechanisms.
For countdowns, test zero and the full admitted bound, escaping predecessors and
multiple uses; reuse the existing vector-only rule instead of changing Nat ABI.

Stop a proposal if its proof needs more eager work, only tiny scopes are opened,
code/arity growth outruns gains, or it cannot beat the simpler direct-call control.
Keep checked compilation and memory under separate measurement. The intended
simplification is shared admission facts and fewer special emitters, not a new
optimizer beside every existing worker. These changes add no language features
and promise no reduction in the number of unresolved conformance observations.
