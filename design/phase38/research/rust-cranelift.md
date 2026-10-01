# Rust and Cranelift: bounded optimization without a pass explosion

Research date: 2026-10-01. Documentation only; no target code or benchmarks ran.
The key implementation inspected is Cranelift's extraction at commit
`dd2dd8d9f0a0a06c34e364716d58acf67236ba6a`. Other links explicitly use mutable
`main` as viewed on this date; they are not claimed to share that exact revision.
The [Phase35 literature](../../phase35/literature.md) and
[Phase37 evidence](../../../implementation/phase37/README.md) supply local context.

## Separate the objectives

Rust's alternative Cranelift backend emphasizes quick compilation, particularly
for development builds. That does not imply generated-program parity with LLVM,
nor that Rust normally uses Cranelift. It is an example of choosing an explicit
point on the compile-time/code-quality tradeoff. [Backend project](https://github.com/rust-lang/rustc_codegen_cranelift/blob/main/Readme.md),
[Rust compiler backend documentation](https://rustc-dev-guide.rust-lang.org/backend/codegen.html).

Our aim is different: remove Bend-specific descriptors, forcing and repeated
guard work so V8 receives simpler JS. V8 already performs native instruction
optimization. Replicating a machine-code optimizer in Bend would add compile cost
without necessarily addressing the largest measured execution overhead.

## What Cranelift changed

The accepted e-graph design addresses optimization ordering: a fact exposed by
one rewrite can make another analysis useful, and repeatedly cycling independent
passes costs time and engineering complexity. Its declarative rewrite approach
provides a shared place for alternatives and common reasoning.
[Accepted design](https://github.com/bytecodealliance/rfcs/blob/main/accepted/cranelift-egraph.md).

Chris Fallin's April 2026 implementation account describes an acyclic expression
graph with immutable nodes, eager bottom-up rewriting and control/effectful
instructions kept in the CFG. Rewriting can occur during construction rather
than repeatedly repairing users. Extraction uses a cheap cost model; experiments
with more elaborate cost strategies did not improve the desired compile/runtime
tradeoff. This is a bounded engineering choice, not unrestricted equality saturation.
[Maintainer account](https://cfallin.org/blog/2026/04/09/aegraph/).

In that account's Sightglass comparison, retaining multiple alternatives rather
than eagerly picking one improved execution by only about 0.1%, near measurement
noise; the mean e-class contained 1.13 nodes. The framework's useful effects need
not come from elaborate alternative search. This is external evidence for a
smaller first experiment, not a prediction of Bend performance.

The pinned [`elaborate.rs`](https://github.com/bytecodealliance/wasmtime/blob/dd2dd8d9f0a0a06c34e364716d58acf67236ba6a/cranelift/codegen/src/egraph/elaborate.rs)
visits values in topological order, computes costs after operands, and chooses a
minimum-cost union alternative with deterministic tie breaking. Effectful results
already fixed in the instruction layout incur no new expression cost. Comments
explicitly acknowledge overcounted sharing and avoid another rematerialization
fixpoint. The implemented cost model is deliberately approximate.

That last point matters for Bend: a cost model should be cheap and falsifiable.
Counting fewer AST nodes is insufficient if the new form executes more guards
or forces a value earlier. Even a correct static cost model cannot predict every
V8 tiering, code-size and object-shape effect.

## Rules are executable contracts

ISLE separates matching from rule construction. External helpers marked pure
make a programmer-supplied promise; the DSL does not prove arbitrary host code
pure. Failed matches and partial constructors have explicit control behavior.
[ISLE language reference, main](https://github.com/bytecodealliance/wasmtime/blob/main/cranelift/isle/docs/language-reference.md).

Cranelift's rule guide requires directional rewrites that do not worsen the
expression, warns against indiscriminate commutativity/associativity, and explains
why dropping value uses affects scope. It also records a real bug caused by
abstracting repeated e-class matches into a helper. Sometimes two explicit rules
are cheaper and clearer than one broad abstraction.
[Optimization rule guide, main](https://github.com/bytecodealliance/wasmtime/blob/main/cranelift/codegen/src/opts/README.md).

The actual [arithmetic rules](https://github.com/bytecodealliance/wasmtime/blob/main/cranelift/codegen/src/opts/arithmetic.isle)
include typed bitvector identities such as simplifying `(x + y) - (x + z)`.
This is an example of expressing exact typed rules, not a rule to copy verbatim:
wrapping integers, mathematical Nat and rounded floating-point arithmetic have
different identities, and JS evaluation may contain observable coercions.

## Transfer A: build one small plan and simplify it once

A useful Bend plan would preserve the original typed Lam/Mat prefix, bind actual
arguments once in order, and expose only operations already proved private.
While constructing it, perform small directional rewrites: resolve a known
constructor arm, reuse an already captured argument, or combine a saturated call
with its proved direct entry. Preserve unsupported operations as explicit exits.

For example, after a private constructor is proved `Pair(a,b)`, matching its tag
and selecting the first field can become the captured `a`. This requires `a`
already to have the correct demand behavior and the object to be compiler-owned.
Applying the same rewrite to a public object can drop a getter or change forcing.
The legality proof belongs to the plan boundary, not to the visual pattern alone.

Keep effect order and branch-local bindings explicit. A rewrite from
`select(true, x, y)` to `x` must not reintroduce `y` in a scope where it does not
exist, nor erase an evaluation that this language actually requires. Generic
runtime calls, error callbacks, mutable natives and deferred fields remain
outside an algebraic expression island unless their exact contracts are proved.

This can initially be a view of current terms rather than a new whole-program IR.
Only create a distinct representation after two existing optimizations need the
same facts and it allows their duplicated walkers to be removed.

## Transfer B: optimize a complete recursive component

Cranelift keeps loop-carried values in block parameters instead of creating
cycles in its pure expression graph. The corresponding Bend idea is to treat a
proved group of mutually recursive workers as one control component, with
explicit arguments/state transitions and bounded-stack tail transfer.

This does not license replacing arbitrary recursion by JS calls. A non-tail tree
walk needs frames or another stack-safe representation; a mutual tail cycle needs
parallel argument capture before updating state. Exceptions must unwind the
private proof scope, and reentry must not inherit a stale ownership assumption.

The [saved tree experiment](../../../implementation/phase37/optimizer/tree-findings.md)
already provides local evidence for attacking a whole component: 2.60–3.56× on
three sizes against its original Phase36 comparator. Production finite selectors
achieved only 1.165–1.270×. The larger result is neither implemented nor a further
multiplier on the current compiler; it needs remeasurement against Phase37 and a
second shape before becoming an architectural commitment.

## Transfer C: make the profitability boundary explicit

The rejected Phase37 candidate opened 1,968 tiny proof scopes and slowed active ray
by 35.6%. Final admission requires a selector touching data to justify a new root;
scalar selectors can still use an already valid scope.
[Retained negative evidence](../../../implementation/phase37/optimizer/ray-regression.md).

An improved plan could record required guards, expected call multiplicity where
statically justified, generic calls removed and extra emitted bytes. Choose among
the old path and one proved direct path. Do not make mandatory correctness guards
optional based on profitability. Unknown cost should select the existing path.

The first test should be a countdown or one saturated map step, not a large
equality-saturation engine. Counters demonstrate that the intended entry executes;
counter-free variants measure speed. Both are needed to avoid an inactive rewrite
appearing to be a successful optimization.

## Estimates, effort and stop conditions

These are conditional planning ranges for Bend, not external benchmark results.
They overlap and are not additive. Complexity includes proof and integration work.

| Candidate | Estimated gain and cost | Effort / earliest discriminator | Stop or defer when |
| --- | --- | --- | --- |
| Eager bounded private-plan simplification | 1.00–1.25× affected program execution; compiler request may improve or worsen by roughly 10% | Medium, 3–7 days; a 2–4 hour saved-output probe followed by 20/60-second execution selections | V8 already removes the work, or new machinery replaces no existing walker |
| Complete recursive worker component | Working hypothesis 1.5–3× selected component-heavy programs, not the suite; no parity forecast | High, 1–2 weeks; one day for a final-baseline saved-code probe and independent second shape | Demand/alias/reentry or constant-stack controls fail, or a second family needs unrelated special cases |
| Explicit scope profitability | Possibly recover 0–5% on affected regressions; may yield no gain | Low/medium, 1–3 days; half-day separate branch/guard ablations | The saving depends on weakening a mandatory guard or disappears without counters |
| General acyclic e-graph optimizer | No defensible incremental Bend speed range yet; substantial compile/maintenance cost | High, several weeks; one-day offline prototype first | No two concrete phase-order failures survive a simpler directional rule set |

Bound node count, rewrite depth, alternatives and component size before measuring.
Refusal falls back to existing code; exhausting an optimization budget is not a
language error. Record compiler request time, RSS and emitted size as well as
execution, because a new optimizer can worsen the iteration loop it aims to help.

Cranelift's [incremental cache implementation](https://github.com/bytecodealliance/wasmtime/blob/main/cranelift/codegen/src/incremental_cache.rs)
also ties keys to function material and target settings and checks a serialized
version marker. Any Bend plan cache needs similarly explicit identity; see the
[Zig study](zig.md) for the smaller request-local proposal.

No proposal here directly fixes a missing language feature. Its conformance value
comes from one shared, reviewable admission contract and systematic refusal cases.
Simplicity improves only if direct workers retire repeated specialized emission
logic; adding a graph engine beside every existing path would move in the wrong
direction. The best lesson from Cranelift is disciplined scope and cheap decisions.
