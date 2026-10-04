# LLVM: composable optimizations with explicit proof and cost boundaries

Research date: **2026-10-04**. This is a source survey and a proposed transfer
plan, not an LLVM integration, new Bend experiment, or performance result.
The implementation pin is **LLVM 21.1.8**, tag `llvmorg-21.1.8`, commit
[`2078da43e25a4623cab2d0d60decddf709aaea28`][pin].
The [release page][release] resolves that tag to this commit. This deliberately
stable release is not claimed to be the newest LLVM available on the survey date.
Official reference documentation below is the separately versioned **21.1.0**
documentation; implementation-order claims come from the pinned source.
The Bend comparison is checkout `55e5b79dc9ac3e02436a712e34722f2eb519e5df`,
whose selected compiler remains Phase45 worker23.

The most useful lesson is to expose enough structure for several small passes
to cooperate, while controlling repetition and invalidating stale facts.
For Bend, the first candidate is bounded private inlining followed immediately
by constructor/projection elimination and conservative dead-value cleanup.
Full LLVM-style memory analysis and vectorization are later investments.
This ordering is a proposal inferred from the sources and our backend, not
evidence that these passes will close the measured execution gap.

## Source inspection map

These are implementation files inspected at the pin, not merely API overviews.
Links use the full commit so later upstream changes cannot alter the evidence.

| File | Symbols inspected | Relevant finding |
| --- | --- | --- |
| [IR/Value.h][S1] | `Value`, `replaceAllUsesWith`, use-list methods | Replacements update explicit uses rather than searching emitted text. |
| [IR/PassManager.h][S2] | `AnalysisManager`, `Invalidator`, `getResult`, `getCachedResult` | Analysis caching and dependency invalidation are separate contracts. |
| [PassBuilderPipelines.cpp][S3] | `buildFunctionSimplificationPipeline`, `buildInlinerPipeline`, `addVectorPasses` | Actual order and optional/default switches matter. |
| [Scalar/SROA.cpp][S4] | `runSROA`, `runOnAlloca`, `promoteAllocas`, `SROAPass::run` | Local allocation partitioning feeds SSA promotion. |
| [Scalar/SCCP.cpp][S5] | `runSCCP`, `SCCPPass::run` | Constants and executable edges are solved together. |
| [InstCombine/InstructionCombining.cpp][S6] | `InstCombinePass::run`, `combineInstructionsOverFunction` | Worklists, change tracking and iteration limits contain repeated cleanup. |
| [IPO/Inliner.cpp][S7] | `InlinerPass::run`, `getAdvisor`, `inlineHistoryIncludes` | Inlining combines advice, work ordering and recursion history. |
| [Analysis/MemorySSA.cpp][S8] | `MemorySSAAnalysis::run`, `Result::invalidate`, `OptimizeUses` | Memory facts depend on alias analysis and dominance. |
| [IPO/FunctionAttrs.cpp][S9] | `checkFunctionMemoryAccess`, `addMemoryAttrs`, `PostOrderFunctionAttrsPass::run` | SCC summaries conservatively combine memory effects. |
| [Scalar/LICM.cpp][S10] | `isSafeToExecuteUnconditionally`, MemorySSA caps | Invariance alone does not license moving an operation. |
| [IR/Verifier.cpp][S11] | `verifyFunction`, `verifyModule`, dominance checks | Structural validity is checked independently of parsing. |

## What the IR buys

LLVM instructions produce typed SSA values; basic blocks make control flow
explicit, and PHI operands represent values arriving on predecessor edges.
A definition must dominate its uses, with the appropriate edge interpretation
for PHIs. Memory locations do not automatically become scalar SSA values.
The [language reference][langref] distinguishes syntactic acceptance from
well-formed IR. `Value` supplies def-use traversal and replacement primitives;
these make local rewrites reusable across producers and consumers. [Source][S1]

Bend's [worker model][jwmodel] already has explicit assignments, direct calls,
constructor values, projections, cases and returns. It is a structured worker
IR, not a complete LLVM-style CFG: nested branch lists carry control, while
the emitter later creates program counters, register vectors and continuations.
It has no general PHI/block-argument model or explicit per-operation effect
summary. Literal JavaScript strings also retain semantic information outside
the typed node structure.

Therefore, adopt the useful invariants before adopting the whole representation:

1. Give every produced worker value a stable identity and a defined type/layout.
2. Build per-function use counts and a substitution map once per revision.
3. Verify definitions precede uses along structured paths; verify call targets,
   arities, projection indexes, return layouts and terminating branch shape.
4. Keep evaluation order explicit when expanding nested value expressions.
5. Introduce blocks and block parameters only when cross-branch joins or loop
   transformations need them; local aggregate elimination does not require them.

These are proposed additions. Existing `JWLower.valid` and graph rejection are
useful conservative checks, but should not be described as a general verifier.
The current [worker simplifier][jwsimplify] only eliminates selected terminal
cases for established one-constructor layouts; it does not implement SCCP.

## Analysis reuse must have an invalidation rule

The new pass manager nests module, call-graph SCC, function and loop work.
Adaptors express those boundaries. The official [new-PM guide][newpm] explains
why an inner pass cannot arbitrarily recompute outer analyses: repeated module
scans from each function can create quadratic compile time. Grouping local
passes also improves locality compared with separate whole-module traversals.

`AnalysisManager` computes requested results lazily and caches them.
Transforms report preserved analyses; dependent results can invalidate
themselves when their prerequisites change. Clearing a deleted IR unit is
distinct from invalidating an extant one. A cache lookup alone does not prove
that the cached result is applicable after a transformation. [Source][S2]

For Bend, cache immutable *definition facts* separately from *root admission*.
The former can include arity, exact native ownership, direct callees, effects,
layouts and escape information. The latter also depends on the selected root's
public ABI, erased/live argument split, dependency fence and representation mode.
Sharing the former does not permit sharing a root's guard or private closure.
The [current instance pipeline][jpure] makes this distinction operationally
important: a successful private graph still sits behind public entry checks.

Start with coarse revision invalidation, not a generic dependency framework:

| Transformation | Facts it may preserve | Facts to recompute initially |
| --- | --- | --- |
| Substitute an immutable local alias | Calls, branch structure, layouts | Uses/liveness |
| Eliminate a proven private aggregate | Call targets and control | Uses, escape, allocation counts |
| Inline a helper | Root boundary contract only if unchanged | Calls, SCCs, effects, uses, size |
| Fold a branch | Unchanged node layout facts | Reachability, uses, SCCs if calls disappear |
| Change a native representation | Nothing representation-dependent | Layout, ownership, conversion and boundary proofs |

These preservation choices are conservative proposals, not current pass behavior.
Versioned facts avoid stale results without requiring incremental repair first.

## What the pinned default pipeline actually orders

This is a selected O2/non-LTO subsequence, with intervening passes omitted:

| Scope | Relative sequence |
| --- | --- |
| Module simplification | Early cleanup → IPSCCP → called-value propagation → global optimization → inliner pipeline → dead arguments → global cleanup |
| CGSCC simplification | Inliner → recursive function attributes → function cleanup → function attributes again |
| Function cleanup | SROA → EarlyCSE → branch cleanup/InstCombine → loop work → SROA → GVN → SCCP → dead-bit cleanup/InstCombine → ADCE → memory cleanup/LICM → CFG cleanup/InstCombine |
| Loop work | Loop simplification → non-speculative LICM → rotation → speculative LICM → later induction/deletion/unroll work |
| Vector stage | Loop vectorization → cleanup → optional SLP → vector cleanup/unroll → SROA/InstCombine/LICM |

This is nested scheduling, not one flat universal list. O1 has a separate
function pipeline. The pin defaults to ordinary GVN, not NewGVN; Attributor is
disabled by default. SLP depends on tuning options, so a frontend's settings
matter. The source even questions historical SCCP placement. [Pipeline source][S3]

The transferable idea is *producer then consumer*: expose constants or
aggregates, simplify their users, then remove newly dead work. Copying this
entire pass sequence would import assumptions and compile costs we have not
justified. LLVM's default order is evidence of an engineering choice, not a
theorem that every language or JavaScript target should use it.

## Inlining and scalar replacement: the first useful composition

The inliner asks an advisor, tracks inline ancestry and maintains a worklist
as new call sites appear. Its implementation discusses how work ordering can
produce bad behavior on highly connected call graphs. Inlining is therefore
not simply “expand every known function.” [Source][S7]

SROA partitions local `alloca` storage, rewrites supported accesses and promotes
eligible allocations with `PromoteMemToReg`. Its worklist can revisit storage
exposed by promotion. It does **not** establish that any arbitrary heap object
or observable JavaScript descriptor can be erased. [Source][S4]

Proposed Bend example, using conceptual typed IR rather than valid Bend syntax:

```text
pair = direct helper(x)       helper(x): return Construct Pair(x, x + 1)
a = Project Pair(pair, 0)
return a

bounded inline → preserve x + 1 evaluation/check → substitute a = x
             → remove Pair allocation if its identity/shape cannot escape
             → remove x + 1 only if separately proved safe to discard
```

The last condition is essential. Checked overflow can make an otherwise unused
field computation observable. Eliminating allocation and eliminating its field
evaluation are distinct transformations.

A first implementation could restrict inlining to private acyclic helpers with
small bodies and one return, alpha-rename their slots, and keep arguments in
their original order. Recursive SCCs retain their existing loop/continuation
policy. A constructor-use analysis can then replace matching private projections,
fold tags, and remove only nonescaping allocation nodes.

Count actual aggregate uses: returns, native boundaries, unknown calls and
identity-sensitive operations require materialization or rejection. Repeated
projection of a private field is different from reading a public object's getter.
Sharing private component code across roots is a separate optimization; it must
not accidentally share root-specific captured proofs or budgets.

Expected benefit is unmeasured: high if hot temporary aggregates survive V8,
near zero if V8 already removes them. Code growth can reverse the result.
Historical worker02 profile nodes explicitly reported oversized functions that
could not be optimized; [P45-005](../../experiments/phase45/P45-005-continuation-worker.md)
retains that evidence. Selected23 profiles contain no nonempty `deoptReason`.
This argues against uncontrolled code growth; it does not quantify inlining
cost or prove that every selected function optimized.

## Constants, combinations and dead code

SCCP jointly tracks executable control-flow edges and value facts, then removes
infeasible edges and simplifies instructions. At the pin it updates an available
dominator tree and explicitly declares its preservation. This is richer than
recursively folding literal expressions. [Source][S5]

InstCombine applies local canonicalizations through a worklist. The inspected
driver has a maximum-iteration option, optional fixpoint verification and
last-run tracking that can skip an unchanged function. [Source][S6]
The [pass reference][passes] distinguishes constant propagation, value numbering,
instruction combining and dead-code removal; they solve different problems.

Bend can start with a small lattice: unknown, exact scalar literal, or known
constructor with known fields. Distinguish “not visited” from a proven constant.
Do not treat an analysis budget exhaustion as an impossible branch or an
invalid value. Stop improving facts and preserve the original program.

Begin value numbering within a straight-line region, using typed operation,
operands and representation mode as the key. Cross-branch GVN requires dominance
and join reasoning. Native calls, public global reads and allocation identities
must not become common expressions merely because their text matches.
Dead-result removal needs both no-use and a proof that discarding evaluation
preserves observable behavior, including exceptions and demanded fields.

## MemorySSA and LICM: useful later, expensive to imitate early

MemorySSA models memory definitions, uses and merges separately from scalar
SSA, with a conservative memory versioning structure refined by alias queries.
It is an analysis, not a transformation that makes memory immutable.
The [MemorySSA guide][memoryssa] explains the distinction between possible
defining accesses and the actual clobber found by a walker.

The source obtains dominance and alias analyses when constructing MemorySSA;
invalidation depends on both. Its batched use optimizer reuses traversal state
instead of independently repeating every clobber search. [Source][S8]
This suggests shared analysis infrastructure, not a new proof that arbitrary
JavaScript property reads can move across callbacks.

LICM checks both movement legality and execution safety. The pin limits
MemorySSA clobber queries to 100 by default and gates memory promotion with a
250-access cap. These are compile-time precision limits, not semantic shortcuts.
Invariant operands alone do not prove that an operation may execute before the
loop or on a previously untaken path. [Source][S10]

For JW, first distinguish private immutable projection, checked arithmetic,
allocation, host call and unknown access. Private immutable data often permits
local elimination without alias analysis. Full MemorySSA becomes more relevant
if typed mutable arrays/effects enter the same IR. Loop hoisting additionally
needs explicit loop structure, dominance and a “safe to speculate” proof.
Hoisting an error out of a zero-iteration loop is incorrect.

## Function attributes, Attributor and vectorization

`FunctionAttrs` analyzes SCC memory effects and respects whether definitions are
exact; a replaceable definition cannot simply inherit the visible body's facts.
Unknown accesses remain conservative. [Source][S9]
That exact-definition distinction resembles Bend's mutable public `G` boundary:
source visibility alone is insufficient to bypass the runtime dependency proof.

Attributor's [original infrastructure design][attributor-design] describes a
shared abstract-attribute fixpoint with dependent facts and conservative timeout.
This explains the concept; it is historical primary evidence, not a claim that
the original 2019 implementation is the pinned implementation. The current survey
verified its default scheduling switch in the pinned pipeline, not every solver.
For Bend, a small shared SCC summary is a better first step than reproducing
the entire framework. “No host mutation” and “cannot throw” must remain distinct.

LLVM's [vectorization guide][vectorizers] separates loop vectorization and SLP,
and describes legality checks, target cost modeling and runtime alias checks.
JW currently lacks a typed vector operation set, array access/dependence model
and a JavaScript SIMD lowering contract. These prerequisites make vectorization
a poor first response to descriptor/aggregate allocation or unsupported graphs.
Keep native array specialization separate from a claim of general vectorization.

## Semantics we must not import from C or LLVM UB

LLVM IR has its own semantics; it is not identical to C. Nevertheless, its
[UB manual][ub] permits behavior removal on paths with immediate undefined
behavior and describes poison from operations such as oversized shifts.
The manual also explicitly rejects speculative division that introduces UB
on a previously valid path. Even LLVM does not authorize arbitrary speculation.

| Tempting assumption | Required Bend/JavaScript boundary |
| --- | --- |
| Unused computation can disappear | Preserve checked errors, callbacks and demand unless discardability is proved. |
| Visible global definition is constant | Public getters and mutable `G`, `.code`, `.env`, `.bound` retain observations. |
| Integer algebra permits reassociation | Preserve U32 wrapping, Nat range checks, division behavior and shift rules. |
| Float identities are mathematical identities | Preserve the selected F32 rounding, NaN and signed-zero behavior. |
| Aggregate projection is a free load | Prove exact private layout and nonescape; public projection can call getters. |
| A no-memory-effect call is movable | Separately prove exception, termination, reentry and host-observation behavior. |
| Inlining only changes speed | Preserve saturation boundaries, erased arguments and source evaluation order. |
| An impossible source case is LLVM `unreachable` | Do not erase an observable backend error on admitted public/raw ABI inputs. |

The existing [ordinary-IR facts][jirfacts] deliberately substitute only locals
and null, granting no effect proof to global loads, constructors or primitives.
Any wider rule needs a new explicit legality fact, not removal of that boundary.

## A bounded adoption and validation sequence

1. **Observe:** add optional per-pass remarks for candidates, accepted rewrites,
   refusals, instruction/aggregate counts and elapsed compiler time. No rewrites.
2. **Verify:** implement local worker well-formedness and stable use/def accounting.
3. **Simplify:** exact private constructor/projection/tag folding, alias propagation
   and conservative dead-value cleanup; use one bounded local worklist.
4. **Compose:** bounded acyclic private inlining, then rerun only affected cleanup.
   Cap per-call expansion and total function/module growth; emit refusal reasons.
5. **Generalize:** executable-edge constants and shared SCC summaries, then
   dominance-based value numbering if profiles establish remaining opportunities.
6. **Defer:** memory motion, broad loop transforms and vectorization until their
   typed legality models exist and cheaper transformations leave relevant costs.

These are design recommendations, not authorized implementation steps here.
Track compilation latency and emitted size alongside program speed; existing
[compiler-cost results][compilecost] show why runtime gains alone are insufficient.

LLVM offers three useful validation layers. Its [verifier][S11] catches broken
IR invariants, while [`opt -verify-each`][opt] localizes the pass that introduced
them; neither proves semantic equivalence. [lit/FileCheck][testing] supports
small reproducible pass tests and output-shape checks. [Optimization remarks][remarks]
distinguish successful, missed and analytical observations and can be serialized.

For each Bend rule, keep a tiny before/after IR fixture plus independently
derived value/error/host-event oracles. Test renamed constructors/functions,
unused throwing fields, public mutation, partial application, recursive depth
and representation boundaries. Confirm actual allocation/call removal rather
than accepting a faster unrelated path. Then use the maintained short canaries,
feature cases and controlled full corpus, with timing separate from profiling.
Stop or revise if compiler cost/code growth exceeds the experiment's stated
budget, the opportunity is cold, or V8 already performs the proposed cleanup.

The concrete next hypothesis is: **small private inlining exposes nonescaping
aggregate elimination that V8 misses, enough to repay compile and code-size
costs**. Its opposite is equally testable. Neither this survey nor LLVM's use
of these techniques supplies a numerical Bend speedup estimate.

[pin]: https://github.com/llvm/llvm-project/commit/2078da43e25a4623cab2d0d60decddf709aaea28
[release]: https://github.com/llvm/llvm-project/releases/tag/llvmorg-21.1.8
[S1]: https://github.com/llvm/llvm-project/blob/2078da43e25a4623cab2d0d60decddf709aaea28/llvm/include/llvm/IR/Value.h
[S2]: https://github.com/llvm/llvm-project/blob/2078da43e25a4623cab2d0d60decddf709aaea28/llvm/include/llvm/IR/PassManager.h
[S3]: https://github.com/llvm/llvm-project/blob/2078da43e25a4623cab2d0d60decddf709aaea28/llvm/lib/Passes/PassBuilderPipelines.cpp
[S4]: https://github.com/llvm/llvm-project/blob/2078da43e25a4623cab2d0d60decddf709aaea28/llvm/lib/Transforms/Scalar/SROA.cpp
[S5]: https://github.com/llvm/llvm-project/blob/2078da43e25a4623cab2d0d60decddf709aaea28/llvm/lib/Transforms/Scalar/SCCP.cpp
[S6]: https://github.com/llvm/llvm-project/blob/2078da43e25a4623cab2d0d60decddf709aaea28/llvm/lib/Transforms/InstCombine/InstructionCombining.cpp
[S7]: https://github.com/llvm/llvm-project/blob/2078da43e25a4623cab2d0d60decddf709aaea28/llvm/lib/Transforms/IPO/Inliner.cpp
[S8]: https://github.com/llvm/llvm-project/blob/2078da43e25a4623cab2d0d60decddf709aaea28/llvm/lib/Analysis/MemorySSA.cpp
[S9]: https://github.com/llvm/llvm-project/blob/2078da43e25a4623cab2d0d60decddf709aaea28/llvm/lib/Transforms/IPO/FunctionAttrs.cpp
[S10]: https://github.com/llvm/llvm-project/blob/2078da43e25a4623cab2d0d60decddf709aaea28/llvm/lib/Transforms/Scalar/LICM.cpp
[S11]: https://github.com/llvm/llvm-project/blob/2078da43e25a4623cab2d0d60decddf709aaea28/llvm/lib/IR/Verifier.cpp
[langref]: https://releases.llvm.org/21.1.0/docs/LangRef.html
[newpm]: https://releases.llvm.org/21.1.0/docs/NewPassManager.html
[memoryssa]: https://releases.llvm.org/21.1.0/docs/MemorySSA.html
[passes]: https://releases.llvm.org/21.1.0/docs/Passes.html
[ub]: https://releases.llvm.org/21.1.0/docs/UndefinedBehavior.html
[vectorizers]: https://releases.llvm.org/21.1.0/docs/Vectorizers.html
[attributor-design]: https://reviews.llvm.org/D59918
[opt]: https://releases.llvm.org/21.1.0/docs/CommandGuide/opt.html
[testing]: https://releases.llvm.org/21.1.0/docs/TestingGuide.html
[remarks]: https://releases.llvm.org/21.1.0/docs/Remarks.html
[jwmodel]: ../../selfhost/src/back/js/ir/worker-model.bend
[jwsimplify]: ../../selfhost/src/back/js/ir/worker-simplify.bend
[jirfacts]: ../../selfhost/src/back/js/ir/facts.bend
[jpure]: ../../selfhost/src/back/js/jpure.bend
[phase45]: ../../implementation/phase45/README.md
[compilecost]: ../../implementation/phase45/compiler-cost.md
