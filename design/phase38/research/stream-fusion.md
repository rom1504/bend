# Stream fusion: erase the pipeline protocol, not just its lists

Research date: 2026-10-01. This chapter studies two implemented routes to fusion:
library rewriting followed by compiler optimization, and direct staged code
generation. It proposes experiments only. No compiler, library or benchmark was
run; [Phase37](../baseline.md) remains the installed baseline.

## Exact sources and versions

| Primary source | Version and inspected subject |
| --- | --- |
| [Coutts, Leshchinskiy and Stewart, *Stream Fusion: From Lists to Streams to Nothing at All*, ICFP 2007](https://www.cs.tufts.edu/~nr/cs257/archive/duncan-coutts/stream-fusion.pdf) | Original stepper formulation, optimization dependencies and limitations |
| [*Stream Fusion, to Completeness*, POPL 2017](https://arxiv.org/html/1612.06668) | Staging, state elimination, nested streams and the scope of the guarantee |
| [vector release commit](https://github.com/haskell/vector/commit/d9d0d46623fdecce7652f59caa4a28849292a0e7) | `vector-0.13.2.0`, 2024-10-31; accompanying `vector-stream` declares version `0.1.0.1` |
| [Data.Stream.Monadic](https://github.com/haskell/vector/blob/d9d0d46623fdecce7652f59caa4a28849292a0e7/vector-stream/src/Data/Stream/Monadic.hs) | `Step`, existential stream state, `mapM`, `filterM`, strict/non-strict folds |
| [Data.Vector.Generic](https://github.com/haskell/vector/blob/d9d0d46623fdecce7652f59caa4a28849292a0e7/vector/src/Data/Vector/Generic.hs) | `stream`/`unstream` rewrite rules and construction boundary |
| [Bundle.Monadic](https://github.com/haskell/vector/blob/d9d0d46623fdecce7652f59caa4a28849292a0e7/vector/src/Data/Vector/Fusion/Bundle/Monadic.hs) | Element/chunk representations, size information, filter changing exact size to a maximum |
| [Fusion phase definitions](https://github.com/haskell/vector/blob/d9d0d46623fdecce7652f59caa4a28849292a0e7/vector/include/vector.h) | Separate fused and inner inlining phases |
| [Strymonas source commit](https://github.com/strymonas/strymonas-ocaml/commit/3e33fcbc01f91cec58edb3c5f7db1bde3683255c) | Pinned development revision, 2026-07-07; not identified here as a numbered release |
| [Strymonas raw generator](https://github.com/strymonas/strymonas-ocaml/blob/3e33fcbc01f91cec58edb3c5f7db1bde3683255c/lib/stream_raw_fn.ml) | Initializers, producers, termination conditions, linearity and nested streams |
| [Strymonas cooked operations](https://github.com/strymonas/strymonas-ocaml/blob/3e33fcbc01f91cec58edb3c5f7db1bde3683255c/lib/stream_cooked_fn.ml) | Fold state, let insertion in map, take and map-accumulate |

Pinned raw source was inspected. Vector's `Data.Vector.Fusion.Stream.Monadic`
file is only a re-export in this version; the real stepper lives in
`vector-stream/src/Data/Stream/Monadic.hs`. The newer Strymonas implementation is
additional evidence, not a claim that every line is the 2017 artifact.

## Route one: expose a state machine, then optimize it away

The original stream-fusion representation combines a hidden state with a step
function. A step can yield an element, advance without yielding, or terminate.
The skip case lets a filter remain a nonrecursive transformation of one step.
After conversion/cancellation, ordinary compiler transformations must eliminate
the resulting state and dispatch overhead.
[Original paper](https://www.cs.tufts.edu/~nr/cs257/archive/duncan-coutts/stream-fusion.pdf).

The pinned vector implementation makes this dependency concrete. `mapM` invokes
the source step and transforms a yielded element; `filterM` turns a rejected
yield into a skip. Folds repeatedly case-analyze the step result. Its strict fold
explicitly demands the accumulator, while the other fold does not. These are
different semantic operations, not interchangeable loop spellings.
[Stream implementation](https://github.com/haskell/vector/blob/d9d0d46623fdecce7652f59caa4a28849292a0e7/vector-stream/src/Data/Stream/Monadic.hs).

Vector supplies cancellation rules at construction boundaries and separates
outer fusion from inner inlining phases. Bundles retain size information, with
filter weakening exact size to an upper bound. This is coordinated library and
compiler design; a stream datatype by itself does not guarantee zero allocation.
[Generic rules](https://github.com/haskell/vector/blob/d9d0d46623fdecce7652f59caa4a28849292a0e7/vector/src/Data/Vector/Generic.hs),
[phases](https://github.com/haskell/vector/blob/d9d0d46623fdecce7652f59caa4a28849292a0e7/vector/include/vector.h),
[bundle implementation](https://github.com/haskell/vector/blob/d9d0d46623fdecce7652f59caa4a28849292a0e7/vector/src/Data/Vector/Fusion/Bundle/Monadic.hs).

## Route two: generate the loop directly

The staged approach separates code-generation-time structure from runtime
state. Its completeness result concerns its supported stream language and
staging assumptions, not arbitrary source-language programs. The paper also
explains why nested streams and combinations of filtering/zipping make simple
rewrite-based elimination more difficult.
[Staged fusion paper](https://arxiv.org/html/1612.06668).

The inspected Strymonas generator represents initialization, flat and nested
streams explicitly. An element producer receives a code-generating continuation;
termination is separate, and linearity records whether stepping yields exactly
one item. Its map inserts a generated local binding, and fold allocates accumulator
state in the generated computation. Those continuations belong to the generator;
the intended emitted loop need not allocate a callback per item.
[Raw generator](https://github.com/strymonas/strymonas-ocaml/blob/3e33fcbc01f91cec58edb3c5f7db1bde3683255c/lib/stream_raw_fn.ml),
[cooked layer](https://github.com/strymonas/strymonas-ocaml/blob/3e33fcbc01f91cec58edb3c5f7db1bde3683255c/lib/stream_cooked_fn.ml).

The useful transfer is a bounded compiler plan for a known producer/consumer,
not a new public streaming API and not a runtime `Yield` object on every step.
Existing Bend producer and slot lowering already captures part of this idea.
This chapter extends [Phase35](../../phase35/literature.md) by distinguishing the
library's residual protocol from the generator's explicit control/state plan.

## Mapping a Bend pipeline without changing its meaning

Consider the explanatory expression `sum(filter(p, map(f, make(n))))`.
A desirable private result is a loop with generator state, a temporary `y`, a
predicate branch, and an accumulator. There are two separate optimization steps:
first make its callbacks and traversals direct; then remove intermediate data.

```text
direct but unfused: materialize -> direct map -> direct filter -> direct fold
candidate fused:   generate x -> bind y=f(x) -> test p(y) -> update accumulator
```

That diagram is a proposal, not an equivalence proof. If the original program
finishes every mapping operation before any predicate, fusion changes ordering.
Even pure operations may throw at different points. A predicate error on an
early element can move ahead of a mapping error on a later element. A valid
first subset therefore needs total, non-hooking scalar operations over proved
bounds, or a separate demonstration that the actual original demand order is
already the same. `JPure` alone is insufficient.

A source list retained by another consumer can remain materialized while a
single private mapped/filtered result disappears. If the intermediate result is
shared between consumers, fusion may duplicate traversal or callback work.
The public returned list must still have its original constructors and sharing
where observable. Borrowing the word “linear” does not establish a JS ownership
proof or equate Strymonas's yield property with Bend's affine quantities.

## Local evidence, estimates and the right control

Installed list-512 is about **44.42× slower than TypeScript**; its sampled
allocation is about **2.78 MB/call versus 94 KB**. `apply`/`force` account for
about 41.78% of CPU self samples. These expose protocol overhead, but do not
identify what fraction is unavoidable output versus disposable intermediates.
The measured +4.65% Phase37 list regression remains unexplained.
[Final profiles](../../../implementation/phase37/profile-findings.md),
[clean execution](../../../implementation/phase37/execution/report.md).

| Proposal | Conditional incremental output gain | Confidence and complexity |
| --- | --- | --- |
| Direct known callback/traversal, keep lists materialized | **1.5–3×** selected pipeline/closure code | Lower confidence; several-hour ablation, roughly 2–5 days for bounded integration |
| Fuse one total scalar map/filter/fold pipeline | **1.5–3×** against installed Phase37 on an eligible pipeline; additional gain over direct unfused code is unknown | Low confidence; half-day to one-day diagnostic prototype, roughly 3–7 days for first general admission and controls |
| Nested streams, zip, early termination and effects | No useful multiplier before simple fusion works | High correctness/engineering risk; defer rather than extending the first subset |

The first two ranges remove overlapping work and must not be multiplied. Large
published fusion gains are not predictions for Bend. A fusion candidate only
earns a compiler change if it improves on a direct-but-unfused control enough to
justify the added demand and escape analysis. Tree sorting is not automatically
a linear stream pipeline; this estimate does not transfer to it or to BST/maps.

## A small falsifiable campaign

Create four saved-output roles: installed module, direct calls with unchanged
intermediates, fused scalar loop, and pinned TypeScript output. Preserve complete
small outputs and compare allocation separately from clean timing. Counters must
show fewer intermediate constructors and actual candidate entry; a smaller
source file or equal aggregate checksum is insufficient evidence.

Use fresh lengths including 0, 1, 15, 17, 31 and larger nonmultiples of 16, with
all/none/mixed predicate selectivity and higher-entropy values. The current list
generator's low-bit cycle and whole-cycle lengths do not cover these variations.
Keep the frozen Phase37 points unchanged and introduce a new catalog revision.

Boundary controls must distinguish early/late callback failures, zero-length
demand, retained aliases, callbacks capturing changing values, descriptor
replacement, DataView/Error reentry and public partial application. Ineligible
cases must take the generic route before any additional user-observable work.
Long inputs need bounded stack and memory observations. For later zip support,
check which input advances first and whether an exhausted side causes an extra
step on the other side; for early termination check that no extra predicate runs.

Start with a 20/60-second paired execution screen after controls. Stop if direct
unfused code captures essentially all the gain, if a runtime `Step` allocation
survives per item, or if fusion relies on changed exception order. Stop widening
the optimizer after a null result. A winner then needs a second source shape,
checked compile-cost measurements and new heldouts before wider acceptance.

## Simplification, conformance and overlap

A tiny producer/consumer plan may consolidate existing destination-slot logic,
callback specialization and loop emission. A second independent stream IR with
its own optimizer would increase maintenance, and merely adding library rewrites
would create new phase-order dependencies. Require a concrete deletion plan
before claiming fewer concepts or lines.

Fusion adds no supported syntax or semantic conformance by itself. It can easily
reduce conformance by changing demand, aliasing or failure order. It overlaps
MLton's known-call specialization, GHC's constructor specialization and existing
private producer lowering. The promising new experiment is removal of a measured
intermediate after direct execution is established, not a universal fusion pass
or a prediction that all 45 benchmark points will benefit.
