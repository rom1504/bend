# JavaScript runtime IR

The compiler written in Bend lowers checked `KTerm` expressions into a separate
runtime representation before emitting JavaScript. The representation and its
passes live in [`src/back/js/ir/`](../src/back/js/ir/). They expose ordinary
language operations to shared transformations instead of requiring a recognizer
for each application family. The dependent core, checker and public runtime ABI
remain separate.

This is a structured expression IR, not an SSA graph. Its introduction does not
itself establish faster execution or TypeScript parity. The
[Phase44 design](../../design/phase44/README.md) specifies the migration and
validation sequence; the installed release is identified by
[`dist/release.json`](../dist/release.json).

## Pipeline and module boundaries

```text
checked, annotated KTerm
    -> lower: resolve runtime operations and demand
    -> simplify: bounded local transformations
    -> emit: expressions or statements
    -> existing JavaScript runtime
```

| Module | Responsibility |
| --- | --- |
| [`model.bend`](../src/back/js/ir/model.bend) | Typed operation and parameter definitions. |
| [`lower.bend`](../src/back/js/ir/lower.bend) | Type/provenance checks, erased slots, call chunks, literals and constructors. |
| [`control.bend`](../src/back/js/ir/control.bend) | Lower already admitted Boolean choices into ordered condition/branch operations. |
| [`facts.bend`](../src/back/js/ir/facts.bend) | The bounded `JIRCopy` environment, including lookup, admission and scope invalidation. |
| [`constants.bend`](../src/back/js/ir/constants.bend) | Fold nine admitted U32 operations on integer literal operands. |
| [`simplify.bend`](../src/back/js/ir/simplify.bend) | Bounded local alias propagation and exact identity-binding elimination. |
| [`emit.bend`](../src/back/js/ir/emit.bend) | Print the operations already selected by lowering. |
| [`statement.bend`](../src/back/js/ir/statement.bend) | Emit return-position bindings and branches as lexical blocks. |

The production entry is `j_expr -> jir_lower -> jir_compile`; `jir_compile`
runs `jir_simplify` before `jir_emit`. Lambda bodies use `jir_emit_return` for
statement emission. Compatibility entry points use the same compile schedule.

The facts module contains the lexical value environment actually consumed by
simplification. It is not a general effect, escape or ownership analysis. There
is no production structural-count visitor. Known target and arity alone do not
authorize bypassing a function's runtime descriptor.

## Operation contracts

- **Local and Null:** immutable lexical reads and the erased ABI value. Erased
  arguments, bindings and fields become Null without lowering their source
  expressions. Erasure must not evaluate an otherwise failing expression.
- **Global:** the ordinary `get(G, name)` operation. It can invoke a computed
  initializer on every reference, throw, or observe a mutated public binding.
  It is neither a constant nor a reusable pure load.
- **Literals:** preserve the existing checked provenance and runtime spelling.
  A user datatype named like a primitive retains its own representation. An F32
  word invokes bit reinterpretation; it is not automatically a movable constant
  under arbitrary host mutation.
- **Apply:** one already established application chunk. Evaluate the callee
  before the arguments and arguments left-to-right. Group only a proven leading
  lambda prefix. A matcher or intermediate computation can demand a result before
  later arguments run. Non-tail application retains `callOwned`; tail application
  retains the trampoline message.
- **Let:** parallel binding. Evaluate all RHSs in the outer environment, in
  order, before introducing any of the new binders. Source binder IDs can be
  deliberately reused by backend fixtures; shadowing must remain correct.
- **Lambda:** a public descriptor with the same leading arity and erased ABI
  slots. The delayed body retains tail demand. Captured values remain immutable
  lexical bindings.
- **Match:** delayed matcher construction. Its arm expression constructs the
  selected arm value when demanded; it is not an eagerly executed branch body.
  A proved single-constructor matcher has no emitted fallback. Ordinary field
  projection, copying and getter order remain runtime responsibilities.
- **Construct:** ordinary public construction. Non-tail fields are evaluated
  eagerly in order; tail fields remain delayed computations consumed by the
  trampoline. Passes must preserve that distinction and alias identity.
- **Primitive and choice operations:** retain the existing source/type/provenance
  admission. Primitive operands stay ordered and evaluated once. A Boolean choice
  evaluates its condition first and only its selected branch. Runtime arithmetic,
  errors and host assumptions are unchanged by representing the operation in IR.

Demand is part of the operation, not an emitter hint that a pass may freely
change. Returning an already demanded application must not convert it into a
tail message. Replacing a delayed constructor with an eager one can reorder
writes, reads and exceptions. Direct recursion also needs an explicit stack
strategy; known arity alone does not justify native recursive calls.

## General transformations

Copy propagation substitutes only admitted inert atoms. It evaluates parallel
RHSs using the old scope and invalidates a fact when either its alias binder or
its source is shadowed. At most 64 facts and 64 candidate bindings per scope are
considered. Larger scopes retain correct execution with less propagation.

An exact singleton `let x = value; x` becomes the same RHS node. The RHS is still
evaluated once in the outer scope, with its original demand. Other bindings stay
present because an opaque compatibility node may still refer to them.

Constant folding covers `U32.add`, `sub`, `and`, `or`, `xor`, `inc`, `not`, `shl`
and `shr` only when their already admitted IR operands are integer literal words.
The 32-line pass preserves modulo-2^32 arithmetic. It does not fold floating-point
words, mutable host functions such as `Math.imul`, or expressions involving
nonliteral operands. It introduces no general algebraic identity that could
discard an evaluation or coercion.

Statement emission removes immediate function calls around return-position
bindings. It first evaluates RHSs into reserved temporaries in one block, then
opens a nested block containing the source bindings and body. The two scopes are
necessary: declaring source bindings beside the temporaries would put outer-scope
RHS references into JavaScript's temporal dead zone. Constant bindings preserve
values captured by escaping closures. Branch statement emission retains delayed
branch selection and the same result demand.

These rules apply to operations and scopes. They do not test benchmark names,
input sizes or application algorithms.

## Remaining compatibility boundaries

`JIRLegacy` retains an expression, environment, type and demand for an inherited
backend path. Private layout/worker plans, deep closure factories, recursively
compressed constructor literals and less common runtime forms still use it.
Its hidden source uses and effects are opaque to IR transformations. Ordinary
children emitted by the adapter reenter the IR pipeline.

`JIRCallPlan` retains an inherited guarded call plan and a structured generic
fallback. The plan still consumes source facts during emission; the new printer
is therefore not yet completely independent of the checked book. Rewriting its
fallback does not authorize dropping binders referenced by the retained plan.

An opaque source subtree is not analyzed merely because its enclosing expression
has an IR node. Migrating an adapter should remove the replaced implementation,
not add a second unused path.

The exported library exposes mutable function descriptors and global bindings.
Known target and arity alone do not permit bypassing `code`, `env`, `bound`,
partial application or host hooks. Unknown calls and observer-bearing operations
can invalidate assumptions. Future direct-call passes must keep these boundaries
explicit; a closed executable contract cannot silently replace the library ABI.

## Extending and validating the pipeline

1. State the runtime operation and its demand, scope, erasure, representation and
   observer contracts. Separate a transformation's legality from its expected
   benefit.
2. Resolve source/type facts in lowering. Add one structured node only when the
   operation needs a distinct contract. Keep optimization passes independent of
   source definition names and JavaScript text.
3. Update simplification, expression emission and statement emission; update
   lexical fact rules if the node introduces scope or a substitutable value.
   Unsupported forms remain explicit boundaries.
4. First compare unchanged emission with a frozen compiler. Then test the
   transformation using combinations of features, renamed helpers, shadowing,
   erasure, delayed effects, host mutation and deep stacks. Existing backend tests
   cover these obligations; new rules need their own smallest counterexamples.
5. Measure compiler requests, emitted size and generated execution separately.
   Run fast semantic screens before broad conformance and timed corpus checks.
   Preserve failed attempts and report the actual migration/optimization scope.

The first Phase44 migration produced byte-identical output for the maintained
45-point, 23-source corpus and passed independent composition and backend
observations. That establishes a checked starting point for those artifacts;
subsequent transformations require their own qualification.

Run the focused IR contract suite from `selfhost/` with a checked attempt and a
fresh output directory:

```sh
node --max-old-space-size=1024 src/back/js/ir/test.mjs \
  build/phase44/checked04 build/phase44/ir-local-check01 \
  --expect-statements --expect-folds
```

The suite uses the real `j_library` entry and selected runtime; its synthetic
KDefs isolate backend contracts and do not replace checked-source conformance.
Both flags require actual transformation activation. Change the attempt path
when qualifying a successor and retain each previous output directory.
