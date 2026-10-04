# Lean: staged functional IR, specialization and lifetime analysis

Surveyed 2026-10-04. Source snapshot: Lean v4.30.0, commit
[`d024af099ca4bf2c86f649261ebf59565dc8c622`](https://github.com/leanprover/lean4/tree/d024af099ca4bf2c86f649261ebf59565dc8c622).
This reuses the pin from [Phase38](../../design/phase38/research/lean.md), with
fresh inspection of source sections relevant to our new general worker IR.
It is not a claim that this is the newest Lean release. No compiler was run.

## Source map

The selected files were downloaded from exact commit URLs; their identities
are in [lean-sources.json](lean-sources.json). A guessed `Simp/Inline.lean`
path returned 404; the actual inlining logic inspected is in `Simp/Main.lean`.
No claim depends on the missing file. Source reading was selective, not a
complete correctness audit.

| Pinned source | Inspected symbols and purpose |
| --- | --- |
| [Basic.lean](https://github.com/leanprover/lean4/blob/d024af099ca4bf2c86f649261ebf59565dc8c622/src/Lean/Compiler/LCNF/Basic.lean) | `Purity`, `LetValue`, `Code`, `Decl`: ANF-style operations, local functions, join points, explicit impure operations. |
| [PassManager.lean](https://github.com/leanprover/lean4/blob/d024af099ca4bf2c86f649261ebf59565dc8c622/src/Lean/Compiler/LCNF/PassManager.lean) | `Pass`, `PassManager`, `validatePasses`: named passes and representation-phase contracts. |
| [Passes.lean](https://github.com/leanprover/lean4/blob/d024af099ca4bf2c86f649261ebf59565dc8c622/src/Lean/Compiler/LCNF/Passes.lean) | `builtinPassManager`: actual ordering and deliberate repetition. |
| [Simp/Main.lean](https://github.com/leanprover/lean4/blob/d024af099ca4bf2c86f649261ebf59565dc8c622/src/Lean/Compiler/LCNF/Simp/Main.lean) | `inlineApp?`, `simpCasesOnCtor?`, `simp`: inlining, constructor-case reduction, substitution and dead bindings. |
| [Specialize.lean](https://github.com/leanprover/lean4/blob/d024af099ca4bf2c86f649261ebf59565dc8c622/src/Lean/Compiler/LCNF/Specialize.lean) | `shouldSpecialize`, `mkKey`, `findSpecCache?`, `loop`: profitable specialization, cached identities and bounded rounds. |
| [LambdaLifting.lean](https://github.com/leanprover/lean4/blob/d024af099ca4bf2c86f649261ebf59565dc8c622/src/Lean/Compiler/LCNF/LambdaLifting.lean) | `mkAuxDecl`, `lambdaLifting`: explicit captures and cached auxiliary declarations. |
| [ReduceArity.lean](https://github.com/leanprover/lean4/blob/d024af099ca4bf2c86f649261ebf59565dc8c622/src/Lean/Compiler/LCNF/ReduceArity.lean) | `collectUsedParams`, `Decl.reduceArity`: smaller private signatures with wrappers. |
| [CSE.lean](https://github.com/leanprover/lean4/blob/d024af099ca4bf2c86f649261ebf59565dc8c622/src/Lean/Compiler/LCNF/CSE.lean) | `Code.cse`, `withNewScope`: scoped common-subexpression reuse in pure LCNF. |
| [LiveVars.lean](https://github.com/leanprover/lean4/blob/d024af099ca4bf2c86f649261ebf59565dc8c622/src/Lean/Compiler/LCNF/LiveVars.lean) | `Code.isFVarLiveIn`: follows reachable join points, not just textual occurrences. |
| [ResetReuse.lean](https://github.com/leanprover/lean4/blob/d024af099ca4bf2c86f649261ebf59565dc8c622/src/Lean/Compiler/LCNF/ResetReuse.lean) | `mayReuse`, `D`, `S`, `insertResetReuse`: dead-value and compatible-allocation analysis. |
| [InferBorrow.lean](https://github.com/leanprover/lean4/blob/d024af099ca4bf2c86f649261ebf59565dc8c622/src/Lean/Compiler/LCNF/InferBorrow.lean) | `infer`, `OwnReason`, `inferBorrow`: interprocedural ownership requirements and heuristics. |

## A nearby architectural model for Bend

Lean is particularly relevant because its compiler must erase rich static
information, specialize higher-order functional code and preserve runtime
behavior while compiling itself. It is not simply a C-like SSA compiler.

LCNF is an ANF-style representation with named intermediate values. It has local
functions and join points: a join point represents shared control continuation
without requiring a general escaping closure. Phase-indexed operations separate
pure transformations from explicit allocation, field access and memory effects.
That representation makes legality visible to passes instead of depending on
the eventual spelling of emitted code. [Basic.lean](https://github.com/leanprover/lean4/blob/d024af099ca4bf2c86f649261ebf59565dc8c622/src/Lean/Compiler/LCNF/Basic.lean)

```mermaid
flowchart LR
    B[Base LCNF] --> S[Simplify, specialize, join points]
    S --> M[Monomorphic LCNF]
    M --> A[Arity reduction, lifting, cleanup]
    A --> I[Impure representation]
    I --> O[Reuse, borrow, boxing and explicit RC]
    O --> E[Backend lowering]
```

The inspected pass list repeats simplification and CSE around transformations
that expose new opportunities. It performs early lifting for specialization,
later general lifting, and arity reduction before another simplification.
After the impure transition it orders reset/reuse insertion, dead-variable
cleanup, borrow inference, boxing, explicit RC, reuse expansion and RC cleanup.
This is a sequence of cooperating representations, not a long unordered list of
peepholes. [Passes.lean](https://github.com/leanprover/lean4/blob/d024af099ca4bf2c86f649261ebf59565dc8c622/src/Lean/Compiler/LCNF/Passes.lean)

## Five directly useful details

### 1. Simplify before duplicating a continuation

`inlineApp?` simplifies an inlined body before connecting its continuation.
The source records an exponential-growth problem in an earlier arrangement.
If the result still has multiple exits, it can create a shared join point
instead of duplicating the continuation. Function-valued results receive a
different treatment that keeps local functions visible.

For Bend, this is a concrete design requirement for selective inlining: do not
copy the whole suffix into both arms of every `JWCase`. Start with a single-exit
helper, or introduce a well-defined join representation before generalizing.
This is more specific than the already-known proposal to add an inliner.
[Simp/Main.lean](https://github.com/leanprover/lean4/blob/d024af099ca4bf2c86f649261ebf59565dc8c622/src/Lean/Compiler/LCNF/Simp/Main.lean)

### 2. Specialize and share identities

Lean uses specialization keys/caches and a bounded specialization loop, while
lambda lifting constructs explicit capture parameters and can reuse an already
cached auxiliary declaration. This connects higher-order optimization with code
growth control. It is not a recommendation to clone a worker for every observed
combination of arguments.

Bend can start with a statically known local function transported through a
helper. Its explicit captures and target ID can become a private first-order
call before worker proof. The cache key must retain our type, representation,
dependency and runtime assumptions.
[Specialize.lean](https://github.com/leanprover/lean4/blob/d024af099ca4bf2c86f649261ebf59565dc8c622/src/Lean/Compiler/LCNF/Specialize.lean),
[LambdaLifting.lean](https://github.com/leanprover/lean4/blob/d024af099ca4bf2c86f649261ebf59565dc8c622/src/Lean/Compiler/LCNF/LambdaLifting.lean)

### 3. Shrink private signatures without changing public ones

`reduceArity` builds an auxiliary function with fewer used parameters and keeps
a wrapper. The implementation deliberately refuses the zero-used-parameter
case because converting a function into a constant can change when code runs.
Its self-recursion reasoning is narrower than arbitrary mutual recursion.

This is closely related to our demand-sensitive nullary boundary. Future JW
dead-argument elimination must preserve argument evaluation and public arity,
even if an internal worker no longer needs the computed value. Do not infer
that an unused argument expression is safe to skip.
[ReduceArity.lean](https://github.com/leanprover/lean4/blob/d024af099ca4bf2c86f649261ebf59565dc8c622/src/Lean/Compiler/LCNF/ReduceArity.lean)

### 4. Lifetime analysis follows control flow

The liveness helper accounts for uses through reachable join points. Reset/reuse
analysis searches for a dead value followed by a layout-compatible allocation;
the implementation avoids naively rescanning every suffix as described by a
simple quadratic formulation. These are useful lessons for JW continuation
frames and per-pass compile cost.

First apply liveness to compact saved registers and remove dead private values.
Actual reuse of JavaScript objects requires a separate escape/identity proof.
[LiveVars.lean](https://github.com/leanprover/lean4/blob/d024af099ca4bf2c86f649261ebf59565dc8c622/src/Lean/Compiler/LCNF/LiveVars.lean),
[ResetReuse.lean](https://github.com/leanprover/lean4/blob/d024af099ca4bf2c86f649261ebf59565dc8c622/src/Lean/Compiler/LCNF/ResetReuse.lean)

### 5. Pure CSE is a restricted permission

Lean's CSE operates on pure LCNF with scoped expression maps; its ownership
inference separately propagates parameter requirements through calls. The
inference also protects tail calls from cleanup inserted after the transfer.

Our JS-facing compiler cannot label a native operation freely reorderable merely
because the source function is pure. Supported host observations, getters,
exceptions, allocation identity and delayed demand remain relevant. A small
effect summary is therefore a prerequisite for generalized CSE/DCE and reuse.
[CSE.lean](https://github.com/leanprover/lean4/blob/d024af099ca4bf2c86f649261ebf59565dc8c622/src/Lean/Compiler/LCNF/CSE.lean),
[InferBorrow.lean](https://github.com/leanprover/lean4/blob/d024af099ca4bf2c86f649261ebf59565dc8c622/src/Lean/Compiler/LCNF/InferBorrow.lean)

## What not to copy

Lean's native reference-counted heap can test exclusivity. JavaScript's garbage
collector does not expose a corresponding complete alias count. Affine source
usage does not account for every host reference or exported mutable object.
Adding reference counting around the existing JS runtime would introduce a new
memory-management system without evidence that it is the right bottleneck.

Prefer eliminating nonescaping aggregate shells, then consider reuse only for
fresh private allocations with a complete lifetime proof. Preserve sharing and
identity when materializing an exported result. No global scratch buffer can
silently survive reentrant execution.

Nor should we copy all Lean representations. JW already expresses explicit
calls, branches, returns and SCCs. Add the facts and control constructs needed
by the next useful transformation; require each addition to replace duplicated
logic rather than creating a third competing private backend.

## Proposed transfers and falsifiers

| Transfer | Current Bend status | First discriminating test |
| --- | --- | --- |
| Inline, simplify constructor/projection, then remove dead shell | Narrow fusion/projection precedents; general JW pass absent in this survey | Count executed fresh aggregate-to-projection chains; preserve throwing field evaluation. |
| Explicit captures plus cached specialization | Narrow known callbacks exist; general function transport remains proposed | Renamed factory/helper/application chain with capture and prefix-demand controls. |
| Private arity reduction | Erased-argument handling exists; general use-driven private signature reduction is separate | Compare dead argument slots while retaining an observable argument computation. |
| Liveness-guided frame shape | Tail-only machine omission exists; general live-slot packing remains separate | Deep non-tail workload and counters proving saved dead slots actually occur. |
| Shared continuation after inlining | JW has structured cases; general join-point optimization is not established | Branchy helper with a growing suffix: bound generated size and check both arms. |

The original [Counting Immutable Beans paper](https://arxiv.org/abs/1908.05647)
explains ownership and reuse; the inspected source provides the concrete current
implementation at this chosen pin. Neither supplies a measured speed forecast
for Bend. Ranking, overlap and expected effort are in
[remaining opportunities](../../docs/remaining_opportunities/README.md).
