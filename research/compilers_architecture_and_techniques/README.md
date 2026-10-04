# Compiler architectures and optimization techniques

Source survey completed 2026-10-04 against our selected Phase45 worker23 compiler
at `55e5b79dc9ac3e02436a712e34722f2eb519e5df`. This collection studies seven
external/reference implementations and connects them to current Bend code.
No external compiler was built, no benchmark was rerun, and no implementation
change was made for this survey.

Start with the [current compiler survey](../../docs/self_hosted/README.md), then
the [comparison](../../docs/remaining_opportunities/comparison.md) and
[ranked opportunities](../../docs/remaining_opportunities/README.md).

## Studies and exact source versions

| Study | Source snapshot | Why it is useful |
| --- | --- | --- |
| [Bend TypeScript](bend-typescript.md) | `018751270e800bc222a93dad7f257083ee53a5f7`, our pinned reference | Closest semantic/output comparison: direct calls, typed layout and native operations. |
| [Rust](rust.md) | 1.99.0, `b940084d7eb6a299eb4bfeb8e34901bc051e7ac4` | MIR pass composition, aggregate analysis, bounded optimization and query invalidation. |
| [Go](go.md) | 1.25.0, `6e676ab2b809d46623acb5988248d95d1eb7939c` | Interleaved target discovery/inlining, escape analysis, ordered effects and SSA. |
| [Zig](zig.md) | 0.15.2, `e4cbd752c8c05f131051f8c873cff7823177d7d3` | Compact staged representations, interned identities, liveness and compiler-work reuse. |
| [LLVM](llvm.md) | 21.1.8, `2078da43e25a4623cab2d0d60decddf709aaea28` | Explicit use/def, analysis management, inlining/SROA/cleanup and optimization budgets. |
| [V8](v8.md) | 13.8.258.18, `a14ab029e21658cba458b7001281c5d526e67636` | The consumer of generated JS: feedback, escape/load analysis, representation and code-size policy. |
| [Lean](lean.md) | 4.30.0, `d024af099ca4bf2c86f649261ebf59565dc8c622` | Functional specialization, join points, demand-sensitive arity reduction and lifetime reasoning. |

These versions provide coherent, reproducible source snapshots. They are **not
a claim to survey the newest release of every project**. The V8 pin is not
asserted to match the engine embedded in our Node executable. Each chapter
distinguishes pinned implementation evidence from floating official explanatory
documentation and from our proposed transfer.

## Method

Each study records source paths, symbols and immutable links. It traces actual
pipeline construction or consumers of an analysis rather than inferring the
default pipeline from a pass filename. Large files were read in relevant
sections; this is an architecture survey, not an exhaustive code audit.

Primary evidence is compiler source and official project documentation, with
original research papers where useful. Bounded public-source downloads resolved
browser cache misses; no large repository clones were required. Temporary
downloads are not durable artifacts. Exact URLs and, where recorded, source
hashes identify how to recover the inspected inputs. Lean's fetch manifest also
retains a missing guessed path instead of claiming it was inspected.

The comparison separates four questions:

1. What behavior/representation does the implementation actually have?
2. Which assumptions make the optimization legal in that language and runtime?
3. Which corresponding capability already exists in our selected compiler?
4. What new experiment could establish a benefit here, and what would refute it?

No benchmark multiplier published for Rust, Go, Zig, LLVM, V8 or Lean is reused
as a Bend speed forecast. Our gain ranges are explicitly prospective estimates
for affected workloads. Fast compilation, fast generated programs, small output
and short developer loops are different metrics.

## Relationship to earlier research

The [Phase38 collection](../../design/phase38/README.md) already studied
MLton, GHC, Flambda, Chez, Koka, Lean, Zig, JS engines, Cranelift, stream fusion
and compiler engineering. This collection extends that evidence with concrete
source comparisons against the new JIR/JW architecture; it does not replace or
retroactively update the earlier experimental baselines.

The [prior-experiment audit](../../docs/self_hosted/prior-experiments.md) records
where familiar proposals already had narrow implementations, successful trials,
null results or rejected regressions. In particular, inlining, callbacks,
Arrays, liveness, caching and helper sharing are not wholly new ideas here.

## How to use the collection

- For the next generated-program optimization, read **LLVM + Rust + Lean** for
  bounded inlining and aggregate elimination, then **V8** to avoid duplicating
  work the downstream JIT already performs.
- For broader higher-order coverage, read **Lean + Go**, and the existing
  [known-local-function design](../../design/phase45/known-local-functions.md).
- For Array coverage and safe code motion, read **Go + LLVM + Bend TypeScript**.
- For compiler latency and smaller backend complexity, read **Zig + Rust + LLVM**,
  keeping immutable compiler facts separate from mutable runtime entry checks.
- For faster validation, use the explicit
  [parallelization plan](../../docs/self_hosted/parallel-validation.md), not a
  compiler's own internal parallelism settings.

The consistent finding is a small collection of cooperating analyses and passes,
with stable identities, explicit effects, bounded work and useful diagnostics.
It is not a recommendation to import another compiler wholesale.
