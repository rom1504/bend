# Eliminating private constructions before native lowering

Phase121 adds two experimental optimizations written in Bend. They reuse the
existing JavaScript backend's structural semantic checks and feed scalar loops
to the existing native IR. The [report](../../implementation/phase121/README.md)
records measured results and scope; the [reproduction guide](../../selfhost/tools/performance/phase121/README.md)
identifies the selected source, tools and tests. This is a hosted experimental
producer, not a newly qualified native N1/N2 release.

## What changes

A private, total U32 list pipeline of this form:

```text
fold(map(filter(generate(U32.to_nat(count), seed))), initial)
```

can execute as one scalar loop. The loop evaluates each generated element and
next seed, applies the predicate, and conditionally maps and accumulates. It
preserves the original left-fold order and U32 wrapping. The temporary lists
never escape the verified shape, so they need not be allocated or destroyed.

An immediately applied closure factory of this form:

```text
chain(U32.to_nat(count))(seed)
chain(0)     = identity
chain(1 + p) = compose(captured_scalar_step(p), chain(p))
compose(f,g) = x => g(f(x))
```

can execute as a scalar countdown. It evaluates the captured expression and
step in descending count order. It does not replace arbitrary recursion with a
formula, assume commutativity, or optimize an unknown/escaping callback. Checked
`U32.to_nat` bounds the predecessor, allowing its `U32.from_nat` image to remain
a word instead of constructing Nat data.

## Admission and architecture

```mermaid
flowchart LR
  A[Checked Bend book] --> B[Bounded shape and semantic admission]
  B --> C[Private scalar loop]
  C --> D[Existing native scalar lowerer]
  D --> E[Existing IR and ABI verification]
  E --> F[QBE and native code]
  B -->|refused| G[Existing generic lowering]
```

The selected modules are `fusion03.bend` and `callback02.bend` under
`selfhost/tools/performance/phase121/`. They override the existing candidate
enumerator and retain its other candidates and fallback. No runtime or public
calling convention changes. Scalar expressions use `p113d_lower`, preserving
the existing operation semantics, temporary allocation and dependency tracking.

Admission reuses `j_fusion_*` and `j_callback_*` in
`selfhost/src/back/js/region.bend`: actual primitive and constructor identities,
types, recursive shape, total scalar operations, private use and composition
order matter; workload names do not. A 2048-node/64-depth syntax budget bounds
candidate inspection. Exhaustion refuses optimization.

Native requests contain checked helper bodies with erased `Lam q0`, while one
existing JS recognizer expects original-source `Lam q1`. A narrowly checked
adapter builds an analysis-only view of the three erased type formals. It
requires exact erased `All q0`/`Type&1` domains and no runtime use, then reruns
the unchanged complete recognizer. Emission uses the original checked book.
This is not permission to erase arbitrary runtime arguments.

## What is and is not established

Finite independent output models cover renamed helpers, altered arithmetic,
noncommutative fold/composition, empty and larger inputs, and wraparound.
Admission and actual emitted activation are checked separately. Shared/returned
containers, unknown callbacks and reversed composition conservatively fall back.
The native workers' disassembly contains no calls or allocation operations;
the list worker still contains some scratch stores and redundant word moves.

The rules cover two narrow but general structural families. They are not a
general deforestation pass, an effect system, a formal correctness theorem or
a claim that most Bend programs have these shapes. Full compiler-image speed,
parallel/GPU behavior and recursive research acceleration are unmeasured here.
The installed compiler and qualified Phase118 native chain remain unchanged.

## Next architectural step

The useful boundary is before data representation becomes allocation and runtime
calls. Keep a checked description of producer/consumer semantics until the
backend can choose a loop. Only extract these existing checks into a shared
backend-neutral module when another consumer needs them; this experiment does
not justify another broad IR rewrite. For compiler throughput, first measure a
real compiler-hot producer/consumer path and test its representation-elimination
ceiling. Better low-level code cannot compensate for materializing data that the
program never needed to retain.
