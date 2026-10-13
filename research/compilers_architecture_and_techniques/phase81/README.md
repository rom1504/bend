# Compilation latency: transfers worth testing after Phase80

Research date: 2026-10-13. This extends the existing [architecture survey](../README.md),
especially [Zig](../zig.md), [Go](../go.md), [Lean](../lean.md),
[term processing](../phase62-term-processing.md) and [query reuse](../phase62-query-reuse.md).
Those files retain their pinned source maps. No external compiler was built or
benchmarked here. The following are implementation lessons, not transferable
speed multipliers. New Bend evidence is in [Phase81](../../../implementation/phase81/README.md).

## V8: choose a representation with a cheap traversal order

The V8 team's March 2025 account of moving from Sea of Nodes to Turboshaft
describes repeated ineffective node visits, costly state retention and poor
locality. Their structured CFG supplies an inexpensive visitation order. This
supports designing our native representation around the order consumers need,
rather than adding a graph and hoping analyses become cheaper.
[Primary engineering account](https://v8.dev/blog/leaving-the-sea-of-nodes).

For Bend, preserve structured branches and evaluation order, resolve runtime
operands once, and compute local facts while constructing a function. A general
Sea of Nodes or whole-program SSA rewrite is unnecessary for emitting C. Our
current repeated tree walks differ from V8's old graph; its reported gains do
not predict ours. The relevant test is fewer visited/rebuilt nodes and lower
complete request time, including construction and cleanup.

## Cranelift: compose work during representation transitions

The original Cranelift RFC explains how separately repeated GVN and alias
passes amplify work. The author's April 2026 retrospective emphasizes fused
translation/optimization and the structured effect skeleton as central benefits;
maintaining many equivalent alternatives is a separate design choice.
[RFC](https://github.com/bytecodealliance/rfcs/blob/main/accepted/cranelift-egraph.md),
[author's retrospective](https://www.cfall.in/blog/2026/04/09/aegraph/).

Our inference: combine native type interpretation, erasure, operand discovery
and summaries at a single producer boundary. Let ordinary/product/observer
routes consume the resulting operation records. Do not install an equality
saturation engine: the present bottleneck is not failure to discover enough
algebraic rewrites. This transfer should remove existing passes and temporary
representations, not create a third backend framework beside them.

## Go and Zig: selective products with stable identities

Go's compiler documentation describes indexed export data that permits lazy
decoding, including type information and selected bodies/summaries. It also
discusses the expansion cost of deep dependency summaries. This distinction
matters after our eager 2.94 MB native-library product failed its gain gate.
[Go compiler documentation](https://go.dev/src/cmd/compile/README).

The existing pinned Zig source study documents indexed ZIR/AIR, separate
variable payloads, interned values and explicit analysis dependencies. A more
recent explanation by Zig's incremental-compilation implementer distinguishes
dependencies on a declaration's type and value; an edit invalidates only the
analyses that consumed the changed fact.
[Implementer's account](https://mlugg.co.uk/posts/incremental-compilation-internals/).

For cold Bend requests, first replace repeatedly computed book metadata with
small exact-world facts, and resolve names once to request-local handles.
Never use a hash as name equality, a binder ID as expression identity, or a
cached result from a different chronological world. A future module artifact
must load only demanded records and avoid reconstructing a second library
graph. For repeated edits, dependency-directed invalidation is promising but
belongs to a different metric. We already have prepared Base and a persistent
session; adding these under new names would not be new work.

## LLVM: scope analyses and run related work together

LLVM's new pass manager separates analysis ownership/invalidation and recommends
grouping function passes to process related data together. The documented
motivation includes cache locality and optimization interactions.
[Pass-manager documentation](https://llvm.org/docs/NewPassManager.html).

Transfer: one per-function native workspace, bounded in lifetime, with the
minimal facts needed by all lowering routes. Report dependencies, constructor
layouts and binder bounds belong to a request/world context instead. This
avoids both global memo-table growth and recomputing whole-book metadata inside
function consumers. Sharing JS/C source code is useful where the semantic facts
match; forcing their different runtime ownership rules into one pass is not.

## Lean and the upstream Bend evaluator: share evaluation, not syntax copies

The existing Lean source study covers conservative substitution summaries,
unchanged-node reuse and the costs of pure-language representations. The
Lean4Lean paper provides an especially relevant example of a typechecker
implemented in its own proof language, evaluated against the original kernel.
[Paper](https://arxiv.org/html/2403.14064v1), [local implementation audit](../phase62-term-processing.md).

At our exact upstream pin, `term_wnf` uses higher-order bodies and memoized
argument cells without mutating input syntax. Our weak-head evaluator still
substitutes into lambda bodies; our strong normalizer already has a graph heap,
and telescope substitution already has a delayed path. A closure/environment
evaluator is a real architectural option, but it must preserve readback, demand,
quantities, stuck terms and chronological worlds. Current samples make this a
lower priority than fixed work and native representation transitions.

## Fast code generators: avoid elaborate work for fixed output

Sparkplug starts from already-resolved bytecode, emits with little intervening
representation work and reuses builtins. It deliberately trades optimization
scope for compilation speed; we cannot assume that tradeoff preserves Bend
generated-program performance.
[V8's Sparkplug account](https://v8.dev/blog/sparkplug).

A compiler-framework study for query compilation identifies representation
conversion, symbol-string handling and emission infrastructure as important
costs, and describes a linear buffer-based IR. Its workloads and native backends
differ from our JS-hosted C emitter; its timing ratios do not transfer.
[Engelke and Schwarz, CGO 2024](https://home.cit.tum.de/~engelke/pubs/2403-cgo.pdf).

Our direct application is modest but well supported: bind the canonical C
runtime's template slots once, assemble chunks without scanning all characters,
and resolve internal symbols before emission. Keep custom/raw runtime fallback
and exact generated C. This changes compiler work without removing program
optimizations. A separate fast/debug optimization tier may help development,
but must not be reported as parity at the current optimization level.

## Source and evidence boundaries

The Go/LLVM/V8 documentation and author articles above were read on the research
date; they are not claimed to be immutable snapshots. The local Zig/Go/Lean
surveys provide pinned implementation references. A direct raw-file browser
read of pinned Zig AIR and Lean instantiate source failed during this refresh;
no claim of a newly completed line-by-line re-audit is made for those files.
Our local upstream comparison is pinned to
`059266225b77c8ca256ac6b25ee5c21449bab151`, not unverified upstream HEAD.
