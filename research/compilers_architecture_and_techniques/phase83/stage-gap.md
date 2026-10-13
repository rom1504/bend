# Phase83: why B1 allocates more than B2

Investigation dated 2026-10-13; production source and installed images unchanged.
This is an audit of generated compiler code, existing profiles and primary-source
compiler research. No compiler or benchmark was run by this investigation lane.
The root subsequently supplied three current Numeric allocation profiles; their
analysis is below and their benchmark execution belongs to the coordinating report.

## Finding

A concrete, general cause of the B1/B2 difference is **control flow expressed as
short-lived functions**. B1's upstream JS lowering emits many Boolean choices as
selected closures and trampoline packets. B2's existing direct backend proves
these selectors structurally and emits branches inside its recursive loops.
Consequently, optimizing this mechanism further is primarily a **B1** opportunity;
it does not explain the remaining B2/upstream gap.

The [Phase82 result](../../../implementation/phase82/README.md) is 1.673x B1 and
1.328x B2 upstream on the established three-source C-compilation loop. These are
JS-hosted Bend-to-C request times, not the execution speed of C programs. Imports,
explicit Base preparation, Clang and execution are outside those request clocks.

## Evidence and source map

The [source-shape audit](stage-gap-shapes.json) binds both exact images and reuses
the lexical scanner from `selfhost/tools/performance/phase53/generated-shape.py`.
It excludes comments and string contents and counts selected generated function
bodies. Runtime definitions, export wrappers and emitted-JS text literals are not
counted. B2 private local transport helpers outside selected `$jd$` functions are
also outside the census. These are static sites, not execution counts or a full
JavaScript AST analysis.

| Current generated function bodies | B1 | B2 |
| --- | ---: | ---: |
| Selected declarations | 3,876 | 4,037 |
| `run_tail` call sites | 4,234 | 8 |
| `run_loop` call sites | 7,451 | 0 |
| Arrow tokens | 8,453 | 664 |
| `continue` tokens | 309 | 1,306 |

B1 SHA256: `8a4007259794bdf0bca9616bc106423f227436013442e9a9ced78659bf6f374c`.
B2 SHA256: `098320e8f3e40894156790d740ad205e386f375195b3c6741d67cca96e94e092`.
B2 still has runtime/export `run_loop` calls: zero in the table does not mean the
entire compiler module has none. The eight residual B2 tail sites occur in native
observer evaluator functions and implement actual higher-order application.

The critical example is independent of any benchmark:

- `selfhost/src/core/term.bend:4`: `kc` selects a `Unit -> A` continuation.
- `selfhost/src/core/index.bend:71`: `index_find` traverses the immutable symbol
  trie with nested `kc` choices.
- Current B1 `api.mjs:6029`: `$index_find$` contains three `run_tail` sites and six
  arrows. An ordinary nonzero-mask internal trie node returns a closure/packet;
  that closure creates the selected child closure/packet. The dispatcher invokes
  it and re-enters `index_find` for the next level.
- Current B2 `compiler.mjs:1416`: `$jd$index_95_find$scc` has no arrows or tail
  packets. Both child branches assign the next arguments and `continue`.
- `selfhost/src/back/js/direct/choices.bend:11` verifies the selector's definition,
  signature and literal continuations. Its call scanner gives those branches
  the caller's tail context, enabling the existing SCC loop.
- Pinned upstream `bend2/comp.ts:2912` lowers unknown closure applications using
  `run_tail`; `:2993` handles closure values. This is a difference in lowering
  the same Bend compiler, not proof that Bend intrinsically needs more allocation.

Both images still reconstruct some matched `KDef`/`KIndexNode` values. The B2
branch optimization therefore removes control overhead without eliminating all
semantic data allocation. Neither image turns ordinary string-prefix matching
into `startsWith`: both current `String.starts_with` bodies walk code points.
It would be wrong to attribute the whole allocation difference to string intrinsics.

## Existing profiles: useful attribution and its limits

[Phase81 profiles](../../../implementation/phase81/profiles.json) execute the
previous Phase78 compiler, before Phase82 removed canonical runtime-template
scanning. Numeric sampled allocation including collected objects was 538.16 MB
for B1, 138.19 MB for B2 and 147.57 MB for upstream. These are sampled allocation
estimates, not live heap, RSS or current Phase82 allocation measurements.

The B1 CPU profile records 249.1 ms self time in `run_loop`, 347.3 ms in anonymous
functions and 84.1 ms in GC, within a profiled 1,262.9 ms request. Anonymous time
includes real compiler work inside callbacks; it is not all removable dispatch.
GC time cannot be assigned to allocating ancestors by this profile. Dispatch,
callback, allocation and inclusive function clocks must not be added as independent
saving estimates.

The new audit resolves anonymous profile locations to their lexical top-level
Bend function using the actual old image. It does not infer the dynamic caller.

| Historical B1 allocation | MB, decimal |
| --- | ---: |
| All anonymous self allocations | 224.18 |
| Anonymous sites inside `ne_template_plain` | 36.71 |
| Anonymous sites inside `ne_template_step` | 31.29 |
| Anonymous sites inside `index_find` | 24.41 |
| Named `index_find` self allocations | 47.24 |
| Anonymous sites inside `ni_template` | 16.67 |
| Anonymous sites inside `nq_uses` | 16.44 |
| Named `run_tail` self allocations | 28.16 |

`index_find` therefore accounts for 71.65 MB of disjoint named/lexical-anonymous
self allocation, about 13.3% of the old B1 total. This includes allocations made
inside those bodies, not only closure objects. In B2 the named SCC's corresponding
self allocation was 4.09 MB. The two images can have different inlining and sample
attribution, so this is strong mechanism evidence, not a precise subtraction.
Phase82 removes the canonical `ne_template_step`/scanner path, but retains
`ne_template_plain` safety checks on payloads. These paths must not be conflated;
current allocation evidence below distinguishes them.

## Current Phase83 allocation refresh

The root ran one new Numeric sampled-allocation request per role using selected
Phase82. The [audit JSON](stage-gap-shapes.json) binds all three raw profiles and
reports by SHA256. Samples include collected allocations; instrumentation clocks
are not clean speed measurements, and this is one source with one sample per role.

| Sampled allocation, decimal MB | Current B1 | Current B2 | Upstream |
| --- | ---: | ---: | ---: |
| Total | 456.98 | 100.80 | 145.45 |

Current B1 lexical-anonymous attribution identifies `ne_template_plain` at
37.03 MB, `index_find` at 23.59 MB, `ni_template` at 18.07 MB and `nq_uses` at
16.67 MB. Named `index_find` adds 46.52 MB and named `run_tail` adds 24.23 MB
across all callers. Current B2 has 4.36 MB in `index_find` and 5.11 MB in
`ne_template_plain`; stage attribution/inlining differences still apply.

This strengthens the B1 control-flow diagnosis and narrows the B2 explanation:
**B2 already allocates less overall than upstream on this input, yet compiles
more slowly.** Reducing allocation alone is not an adequate parity plan. We need
work counts and execution cost per visit, including structural queries, immutable
lookup, normalization and planning. A more efficient representation may reduce
both traversal cost and allocation, but its value must be demonstrated in complete
requests. The historical and current profiles are separate samples, so their
allocation differences are not presented as a precise measured Phase82 reduction.

## Why not repeat the previous branch rewrite

[Phase78](../../../implementation/phase78/README.md#preserved-experiment-sequence)
already expanded 160 branch helpers. Removing those helpers cost only about 3%
in its screening comparisons, while avoiding substantial source expansion. The
scanner-only rewrite was approximately neutral. Those experiments are direct
counterevidence to assuming that all dispatcher self time can be recovered by
mechanically expanding source matches.

Potential reasons require measurement: selected helpers may miss the global
index/term-access hotspots; helper calls may retain cross-function overhead;
closure-body work remains necessary; cold JIT decisions can shift after expansion.
None is established as the sole explanation. B2's existing elimination of almost
all packets makes a second broad B2 closure-elimination campaign especially weak.

## Research transfers

### Flambda2: continuations can be branches, not allocated functions

Flambda2 explicitly distinguishes second-class control continuations from ordinary
functions. Its control representation exposes jumps and branching while retaining
ordinary function applications separately. This permits common control handling
and avoids encoding every continuation as an allocated language closure.
[Implementers' foundational account](https://ocamlpro.com/blog/2024_03_19_the_flambda2_snippets_1/).

Its loopification transforms suitable recursion into internal loops, allowing
later simplification and representation improvements; it is not merely an ABI
trick for cheaper calls. [Loopification account](https://ocamlpro.com/blog/2024_05_07_the_flambda2_snippets_2/).

Transfer: preserve explicit branches and tail transfers through the proposed
native representation. Do not create a new closure-based CPS representation.
B2 already realizes this lesson for structurally admitted Boolean selectors.
For B1, improvements must survive the upstream bootstrap lowering; changing our
JS emitter alone cannot change how upstream emits B1.

### Lean: simplify dependent types at the backend boundary

Lean's LCNF type conversion deliberately forgets dependencies that obstruct
backend transformations while retaining useful runtime type structure. Its
conversion introduces join points to share continuation code across match exits.
[LCNF type design](https://lean-lang.org/doc/api/Lean/Compiler/LCNF/Types.html),
[match/join-point conversion](https://lean-lang.org/doc/api/Lean/Compiler/LCNF/ToLCNF.html).

Transfer: a native per-function product should contain the runtime layout and
control facts required by consumers. Keeping full dependent types and repeatedly
normalizing them inside optimization passes is not required by the source language.
The adaptation still needs Bend-specific proofs for erasure, quantities and foreign
boundaries; Lean's implementation is not that proof. This complements replacing
annotation/erasure/reconstruction rather than retaining another typed graph.

### Flambda2: compute summaries while rebuilding

Flambda2's functional simplifier combines downward analysis with upward rebuilding.
Free-variable information from the rebuilt body determines whether a binding is
needed; discarded bindings do not introduce new free variables. Continuation
analysis is scheduled so argument facts are available before analyzing its handler.
[Traversal design](https://ocamlpro.com/blog/2025_02_19_the_flambda2_snippets_4/).

Transfer: create live-variable/use information during the pass that already builds
the native operation body, instead of separately building an occurrence summary
and retaining the original reconstruction path. Phase80's summary-only result
was small; fused production must remove a consumer or traversal to justify itself.
This is an inference about our design, not an externally demonstrated Bend gain.

### V8: bounded compilation matters for fresh requests

Maglev uses a compact CFG/SSA representation and performs specialization while
building it, reducing later generic lowering work. Its motivation includes code
that does not run long enough to benefit fully from peak-tier optimization.
[Maglev design](https://v8.dev/blog/maglev).
V8's escape-analysis explanation also makes clear that unproven escaping objects
must be allocated; relying on the engine to erase arbitrary trampoline state is
not a dependable compiler strategy.
[Escape-analysis explanation](https://v8.dev/blog/disabling-escape-analysis).

Transfer: use cheap first-execution control flow and one representation transition.
Do not infer current Node tier behavior solely from these articles; pin flags and
collect an optimization trace if tiering becomes the decisive hypothesis. The
2017 escape-analysis article supplies the principle, not current implementation
or performance numbers. Warm throughput and fresh request latency remain separate.

## Cheapest falsifier before a source rewrite

A diagnostic-only copy of current B1 can replace **only `index_find`'s control
flow** with explicit branches and an iterative child traversal. Preserve hash
computation, node tests, missing-key behavior, value reconstruction, fallback
helpers and all other code. It must not replace the trie with a JavaScript `Map`.
This derivative is not a Bend-produced release candidate and must never be installed.

1. Record original/replacement function hashes and full image lineage. Validate
   results on empty, absent, leaf, collision-bucket and internal-node lookups,
   including legacy `KDef` fallback shapes.
2. Run the same fresh small compilation set, with Numeric, functions65 and a
   broader non-IO input; require complete C and report equality.
3. Collect one separate allocation profile; do not compare its clocks with clean
   requests. Record whether packets/closures disappeared and whether allocation
   merely moved elsewhere.
4. If total request saving is under roughly 3%, stop this lane. If 5% or more
   survives held-outs, estimate the next few hotspots from fresh attribution
   before implementing compact Bend matches. A whole-image 15–25% forecast is
   currently unsupported by a successful ablation.

Estimated effort: 30–60 minutes for the bounded diagnostic and its controls;
2–4 hours for a small source-level implementation and focused qualification if
it succeeds. These are planning estimates. A general bootstrap control-flow
transform would be a separate compiler project and needs its own justification.
No production edits or new speedup measurements are claimed here.

The main recommendation for **B2 parity** remains replacing repeated semantic
representation work. For **B1**, targeted control-flow experiments have concrete
mechanistic support, but the earlier weak branch-expansion result rules out
promising parity from source rewrites alone.
