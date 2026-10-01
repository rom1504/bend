# MLton: make the private call graph first order before changing its data

Research date: 2026-10-01. This is source and literature research, not an
implemented optimization. Estimates use the [Phase38 contract](../method.md)
and installed [Phase37 baseline](../baseline.md). No external compiler was run.

## Sources and reproducible scope

The implementation inspected is MLton **20241230**, release tag
`on-20241230-release`, resolving to commit
[`b15e2d289c3d701131733665a74e2dd8438410b6`](https://github.com/MLton/mlton/commit/b15e2d289c3d701131733665a74e2dd8438410b6).
The annotated tag is dated 2024-12-30. Public GitHub tag metadata and the raw
files were fetched; development-branch pages were only discovery aids.

| Primary source | What was inspected |
| --- | --- |
| [Compiler overview](https://www.mlton.org/CompilerOverview) | Translation boundaries; corroborated with the pinned passes below |
| [Monomorphise](https://github.com/MLton/mlton/blob/b15e2d289c3d701131733665a74e2dd8438410b6/mlton/xml/monomorphise.fun) | `Cache`, type-vector keys, datatype instantiation, XML-to-SXML output |
| [ClosureConvert](https://github.com/MLton/mlton/blob/b15e2d289c3d701131733665a74e2dd8438410b6/mlton/closure-convert/closure-convert.fun) | Flow analysis, lambda sets, environment types, `apply` emission |
| [Contify](https://github.com/MLton/mlton/blob/b15e2d289c3d701131733665a74e2dd8438410b6/mlton/ssa/contify.fun) | `AnalyzeDom`, tail/non-tail edges, return and exception continuations |
| [DeepFlatten](https://github.com/MLton/mlton/blob/b15e2d289c3d701131733665a74e2dd8438410b6/mlton/ssa/deep-flatten.fun) | Flattenability constraints and treatment of mutable projections |
| [Fluet and Weeks, *Contification Using Dominators*, ICFP 2001](https://www.cs.cornell.edu/people/fluet/research/contification/ICFP01/icfp01.pdf) | Meaning and limitations of replacing calls/returns by local control flow |

This goes beyond [Phase35's flattening review](../../phase35/literature.md):
the useful subject here is the ordering of call-graph and representation work,
including what the implementation deliberately leaves boxed.

## The implemented pipeline

MLton first elaborates and removes modules, then monomorphizes XML into SXML.
Closure conversion takes this higher-order program to a first-order SSA form;
later representations progressively expose layout and machine details. This is
an ordering lesson, not an argument that Bend needs every MLton intermediate
language. [Pipeline overview](https://www.mlton.org/CompilerOverview).

The pinned monomorphizer caches instantiations by vectors of monomorphic types.
The closure converter propagates sets of possible lambdas, creates environment
datatypes for those sets, and translates application into a case over the set
with named calls in its arms. Its immediate output can still contain closures,
tags and environment allocations. Calling this pass alone “closure elimination”
would overstate what it does.
[Monomorphise](https://github.com/MLton/mlton/blob/b15e2d289c3d701131733665a74e2dd8438410b6/mlton/xml/monomorphise.fun),
[ClosureConvert](https://github.com/MLton/mlton/blob/b15e2d289c3d701131733665a74e2dd8438410b6/mlton/closure-convert/closure-convert.fun).

Contification asks where a function returns, not merely whether it is recursive.
The source builds a graph involving functions and continuations, then uses
dominators to classify candidates. Return information includes the exception
handler. A tail-recursive component with a common continuation can become local
control flow; arbitrary calls with different return destinations cannot simply
be changed to jumps.
[Pinned pass](https://github.com/MLton/mlton/blob/b15e2d289c3d701131733665a74e2dd8438410b6/mlton/ssa/contify.fun),
[paper](https://www.cs.cornell.edu/people/fluet/research/contification/ICFP01/icfp01.pdf).

DeepFlatten then operates under explicit representation constraints. In this
version it does not flatten sum constructors or objects with mutable fields,
and it discards known-value shortcuts for mutable projections. It also protects
outermost formal-parameter representations. These refusals are important:
whole-program visibility does not make every allocation disposable.
[Pinned DeepFlatten](https://github.com/MLton/mlton/blob/b15e2d289c3d701131733665a74e2dd8438410b6/mlton/ssa/deep-flatten.fun).

## Concrete mapping to the current Bend backend

The [Phase37 profiles](../../../implementation/phase37/profile-findings.md)
show list `apply`/`force` self shares of 25.77%/16.01%, and tree allocation of
about 23.08 MB/call against TypeScript's 1.37 MB. This supports investigating
calling machinery first. It does not identify every allocated object or show
that a different tree layout is needed.

Our narrow analogue of MLton's closed world is an admitted private component:
exact callee identities, compiler-owned values, proved demand, and a public
generic wrapper. Keep the existing tagged tree while replacing repeated calls
to its known workers. This separates direct-call gains from layout gains.

For a known mapping callback, explanatory JavaScript might change as follows:

```js
// Existing kind of transition, repeated for each element:
const y = callOwned(callbackDescriptor, [x]);
// Proposed private specialization, after admission of its captures:
const y = mapKnown(capturedOffset, x);
```

The proposed `mapKnown` is a named private worker with scalar capture slots.
This is not a replacement for public `apply`: partial application, oversaturation,
descriptor mutation and unknown callbacks still use the original runtime.
A small finite callback set could use a local tag dispatch, but start with one
known callback identity. A generic replacement `apply` over another boxed closure
datatype would probably retain much of the current cost.

For mutually tail-recursive workers, a bounded local loop can hold an entry tag
and parameters in slots. For non-tail tree recursion, left/right return points
need explicit frames or another bounded-stack strategy. A simple direct JS
recursive call is not an acceptable general replacement for the trampoline.
Reuse the existing tree frame machinery where its semantics match; do not infer
that a strongly connected call graph alone proves contification is legal.

## Candidate proposals and estimates

All ranges are conditional planning estimates against installed Phase37.
Unchanged speed or regression is possible, and rows overlap.

| Proposal | Eligible output-speed target | Effort and confidence |
| --- | --- | --- |
| One complete recursive tagged-tree component | **1.5–2.5×** on the existing tree workload; transfer to BST/lexer unknown | Several-hour saved-output test; roughly 3–7 focused engineering days for general admission, controls and integration; medium confidence on tree |
| Singleton callback specialization with capture slots | **1.5–3×** on selected list/closure workloads if dispatch and environment allocation disappear | Several-hour ablation; 2–5 days for a bounded first implementation; lower confidence |
| Flatten a surviving private product after direct calls | No independent multiplier yet; measure its residual allocation first | Medium-to-high ownership risk; defer until a direct component exposes a specific container |
| Memoize bounded specialization decisions within one compilation | No generated-program gain promised; possible recovery of repeated compiler analysis | Low-to-medium engineering risk if the key includes all relevant proof context; measure checked-request latency separately |

The earlier complete-tree saved-output prototype was **2.60–3.56× faster than
Phase36**, not this much faster than installed Phase37. Its finite-only variant
and component variant provide evidence of additional headroom, but manual graph
knowledge has not been translated into a reusable compiler proof.
[Original experiment and controls](../../../implementation/phase37/optimizer/tree-findings.md).

## Semantic obligations specific to our runtime

- **Closed graph:** a source name is insufficient. Guard every dependency that
  direct calls bypass, including native implementations, then keep callbacks out
  of the admitted region or suspend and revalidate its proof at the right point.
- **Demand:** a tagged object can contain deferred constructor fields. Direct
  field access requires already-forced private fields or the original forcing
  boundary. Purity alone does not justify evaluating an unused subtree early.
- **Aliasing:** shared children may be legal. Direct traversal can preserve them;
  destructive reuse or flattening must separately prove that identity, mutation
  and surviving references cannot observe the change.
- **Host behavior:** preserve DataView instance/prototype checks and native
  descriptor checks. `Error` construction can invoke a mutable host function and
  reenter the module; exceptional paths must leave proof state correct.
- **Stack and scheduling:** preserve tail-cycle boundedness and left-before-right
  traversal. Never substitute host recursion just because normal benchmarks are
  shallow. Fresh captures must stay fresh across iterations and reentry.
- **Specialization keys:** Bend's dependent/erased arguments do not automatically
  have MLton's monomorphic-type semantics. Include representation-relevant facts
  and exact book identity; do not cache across mutable public books by name.

## Falsifiable experiment and stopping rules

Freeze the installed tree module, then derive one direct component while keeping
its constructors, public functions and fallback byte-for-byte identifiable.
First run complete-tree, alias, delayed-field, descriptor/native mutation,
exception/reentry and deep-tail controls, with nonzero worker-entry witnesses.
This stage is a proposed experiment; it was not run during this research.

Measure three sizes in clean paired 20/60-second screens; capture allocation
separately. Then try one unrelated recursive shape before designing a shared
planner. For callbacks, use a direct-but-unfused list pipeline as the control so
that call specialization is not confused with removal of whole intermediate lists.

Stop if only a checksum agrees while shape/sharing differs, if frames grow with
a tail cycle, if the hot worker is never entered, or if the gain requires a source
name. Stop widening admission after a null timing result. Before promotion,
record checked compile cost, peak memory, emitted bytes, lines and concepts;
Phase37 already added 184 Bend lines and raised the tree request median 6.40%.

## Simplification, conformance and overlap

A shared typed call/return plan could eventually replace several worker-specific
paths. It only simplifies the compiler if old machinery is actually removed and
the proof vocabulary stays smaller than the cases it replaces. A wholesale
MLton-style optimizer would initially increase code and analysis complexity.

This work targets output speed, not new language conformance. The same public
fallback must remain valid, and backend gates must still report shared failures.
It overlaps GHC constructor specialization, known-call optimization, and fusion's
callback elimination. Do not multiply their predicted speedups. The useful
architectural bet is a small reusable private component, not a new universal IR
before two independent ablations have demonstrated the need.
