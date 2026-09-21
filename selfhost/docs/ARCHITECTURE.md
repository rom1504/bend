# Compiler architecture

The typed compiler uses a first-order representation shared by the frontend,
checker, normalizer and emitters. The original single-file compiler remains
available as a historical regression baseline.

## Components

| Component | Responsibility | Source |
|---|---|---|
| Core terms | Binder IDs, substitutions, definitions, data declarations | `src/core/term.bend` |
| Normalizer | Weak evaluation, memoized strong normalization, definitional equality | `src/core/normalize.bend`, `src/core/graph.bend` |
| Quantities | Affine-use accounting, erased/reusable demand | `src/check/quantity.bend` |
| Kernel | Dependent bidirectional checking and termination | `src/check/kernel.bend` |
| Frontend | Lexing, syntax, desugaring, pattern compilation | `src/front/` |
| Loader | Canonical namespaces, import graph, foreign paths | `src/load/` |
| Diagnostics | Failed terms, expected/observed types, local context and available source spans | `src/diagnostic/` |
| JavaScript backend | Checked-term lowering, code emission, readback descriptors | `src/back/js/` |
| Native backend | Layouts, segments, closure/fork lowering, C emission | `src/back/native/` |
| Host JS runtime | Primitive representations and asynchronous effects | `src/runtime/js/` |
| Native runtime | Shared CPU/Metal/CUDA runtime and effect implementations | `src/runtime/native/` |
| Driver | End-to-end check/compile/run routing | `src/driver/` |

These components are implemented. Their measured compatibility is recorded
separately in the conformance report.

## Compilation flow

The loader parses the source graph, resolves imports and aliases, elaborates
surface syntax, and gives binders distinct IDs. The checker validates declaration
order, types, quantities and recursive calls before specialization creates live
template instances. The normalizer also supplies definitional equality and the
interpreter's result.

Strong normalization uses explicit work frames and a persistent heap of lazy
cells. Repeated uses of an argument share its evaluation; materialization returns
the ordinary core term format. Weak evaluation and conversion retain the kernel's
existing interface. Binder freshening also uses explicit frames so large generated
terms do not depend on the host JavaScript call-stack depth.

Emission selects reachable definitions while retaining the complete indexed book
as its type context. Annotation reconstructs the checked types needed for erasure,
runtime layouts, foreign marshalling and readback. Backend-specific intrinsic
stops must be shared by reachability, annotation and layout validation. Pruning
the type context itself would lose constructors and dependent type definitions.

The JavaScript backend emits functions and trampolined applications against the
JavaScript runtime. The native backend lowers to segments, closures and fork
continuations, then emits C against the pinned CPU/Metal/CUDA runtime. Its general
boxed representation differs from upstream's flat-layout optimizations; runtime
and performance equivalence are distinct validation questions.

## Compiler source assembly

The compiler implementation modules use one shared internal namespace, with
component-specific prefixes. `tools/assemble.mjs` gathers their type declarations,
forward law signatures, and definitions into a deterministic bootstrap input.
It performs no user-program parsing or compilation. This ordering permits the
mutually recursive compiler routines to refer to declared signatures, while
preserving Bend's sequential declaration rules. The generated file has a source
map back to individual modules. It is not the primary editable source.

The old `src/compiler.bend` is not linked into this typed implementation: its
surface AST lacks quantities and dependent types. It remains a bootstrap aid
and regression baseline, clearly separate from the typed compiler.

## Host representation boundary

Self-emitted libraries use positional constructor fields. The host accesses
these through lazy, read-only named views and unwraps a view when passing it
back to another compiler phase. This preserves graph sharing between phases
without copying entire compiler books. Newly supplied host values are encoded
iteratively. See [the ABI adapter and validation](COMPILER-ABI.md).

## Trust boundary

A successful parse is not a successful type check. The driver must reject a
checker failure before emitting executable code. Proof/type negative tests
cannot pass merely because a parser does not implement their syntax. Bootstrap
upstream APIs are used only to build/test the port; normal operation must not
fall back to the TypeScript compiler.

Copied upstream C/Metal/CUDA runtime code is a runtime dependency, not a
substitute for porting code-generation logic. Target hardware limitations must
be reported as untested capabilities, not passing GPU tests.
