# Phase38: compiler research collection

Research date: **2026-10-01**. Baseline: installed Phase37 checked03 at
`9391ebe91ceeb73f69e4d02f1cdb67aa32a0c6a7`; upstream reference
`018751270e800bc222a93dad7f257083ee53a5f7`. This is a research phase. It changes
documentation, not the compiler, runtime, reference pin or benchmark results.

The question is which compiler techniques can remove our measured overhead
while preserving the existing language and JavaScript interface, and whether
they can also make the implementation easier to understand. The strongest
architectural candidate is a **bounded direct worker for a proved recursive
component**, behind the existing public wrapper and fallback. The cheapest
discriminators remain a private countdown and guard-scope experiments.

## Start here

1. [Evidence and research method](method.md): what is measured, what is inferred,
   what a gain estimate means, and which assumptions cannot transfer.
2. [Current baseline](baseline.md): execution, compilation, allocations and size.
3. [Bend TypeScript backend](research/bend-typescript.md): our closest comparison,
   including actual emitted code and the shared machinery behind its short emitter.
4. [Mined ideas and estimates](ideas.md): ranked proposals, overlap, risks and
   explicit reasons to defer larger rewrites.
5. [Architecture and simplification](architecture.md): one shared component
   analysis instead of another independent optimization subsystem.
6. [Falsifiable experiment queue](experiments.md): bounded probes before production
   work, with separate correctness, speed and complexity decisions.

## Compiler studies

| Study | Mechanisms examined | Main Bend question |
| --- | --- | --- |
| [Bend TypeScript](research/bend-typescript.md) | Saturation, tail components, native representations, boundary marshalling | Which overhead does the same-language implementation avoid? |
| [MLton](research/mlton.md) | Whole-program closure analysis, defunctionalization, flattening | Can known recursive calls stay direct? |
| [GHC](research/ghc.md) | Demand, worker/wrapper, constructor specialization, join points | Which facts justify bypassing generic demand machinery? |
| [OCaml / Flambda](research/ocaml-flambda.md) | Known closures, invariant arguments, bounded value facts | Can a list callback become a direct worker parameter? |
| [Lean](research/lean.md) | Borrowing, reset/reuse, compiler phase contracts | What ownership information is actually available in JS? |
| [Koka / Perceus](research/koka.md) | Precise liveness, reuse, frame-limited retention | Can private allocation be removed without retaining more memory? |
| [Chez Scheme](research/chez.md) | Arity-directed calls, SCCs, nanopass invariants | Can stronger pass contracts reduce reasoning complexity? |
| [JavaScript engines](research/js-engines.md) | Speculation, invalidation, shapes and escape analysis | What should generated JS expose to the existing JIT? |
| [Zig](research/zig.md) | Self-hosting history, compact data, incremental boundaries | How do we improve compiler iteration latency separately? |
| [Rust / Cranelift](research/rust-cranelift.md) | SSA, ISLE, bounded rewriting and extraction | How much optimizer machinery is justified? |
| [Stream fusion](research/stream-fusion.md) | Staging, producer/consumer composition, loop state | When can intermediate lists and closures disappear? |
| [Validation and compiler engineering](research/compiler-engineering.md) | Translation validation, superoptimization, bounded experiments | How can experiments stay fast and trustworthy? |

The [source registry](sources.md) gives version policy and entry points; each
chapter carries its concrete references. The [phase report](../../implementation/phase38/README.md)
records the research performed and documentation checks. These chapters are
independently readable but share the baseline and estimate vocabulary.

## Central finding

Our major gaps are often the cost of executing a generic calling convention,
not the cost of the source algorithm's arithmetic. TypeScript, MLton, GHC,
Flambda and Chez reach direct code by different means, but repeatedly preserve
facts about **callee identity, argument demand, data shape and control flow**.
Our existing private regions already contain part of this solution. Research
supports extending a useful proved boundary and consolidating its facts before
adopting a large new IR, global speculative cache or memory-management runtime.

This is an inference from our profiles and the inspected implementations, not
a proof of future speedup. A 150× current gap does not imply a 150× obtainable
gain. Published results on another compiler are never used as our forecast.
