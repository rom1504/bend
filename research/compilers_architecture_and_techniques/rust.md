# Rust: rustc architecture and bounded optimization techniques

Lookup date: **2026-10-04**. This is source research, not a benchmark or an
implementation proposal. No rustc build, Bend build, target execution or clone
was performed.

## Version and evidence boundary

The official [Rust 1.99.0 release](https://github.com/rust-lang/rust/releases/tag/1.99.0)
is dated October 1. The annotated tag object is
`daa8d75bc715f77869fa06d80b6ea1a3fe52d38e`; its peeled source commit is
**`b940084d7eb6a299eb4bfeb8e34901bc051e7ac4`**.
The [tag API](https://api.github.com/repos/rust-lang/rust/git/ref/tags/1.99.0)
and [annotated object API](https://api.github.com/repos/rust-lang/rust/git/tags/daa8d75bc715f77869fa06d80b6ea1a3fe52d38e)
were read to resolve that identity. This document does not claim to inspect the
latest nightly or latest `main` commit.

Initial browser requests exposed differently aged `main` snapshots and several
tag URLs failed with cache misses. The implementation facts below instead use
selected raw files fetched at the full commit above. Those files total less
than 0.6 MiB and were inspected locally under `/tmp`; that directory is scratch,
not a durable evidence capsule. Immutable URLs and SHA256 values below allow
independent recovery. The development guide supplies explanatory context and
test workflow; it is floating documentation, not proof of pinned source behavior.

## Source inventory

All paths below are relative to the Rust repository. `P` means the full release
commit above. Each link uses that commit, not a branch alias.

| Path at P | Symbols inspected | Role |
| --- | --- | --- |
| [compiler/rustc_middle/src/thir.rs](https://github.com/rust-lang/rust/blob/b940084d7eb6a299eb4bfeb8e34901bc051e7ac4/compiler/rustc_middle/src/thir.rs) | `Thir`, `Expr`, `ExprKind`, `Param`, `Arm` | Typed expression bodies and explicit scopes |
| [compiler/rustc_middle/src/mir/mod.rs](https://github.com/rust-lang/rust/blob/b940084d7eb6a299eb4bfeb8e34901bc051e7ac4/compiler/rustc_middle/src/mir/mod.rs) | `Body`, `LocalDecl`, `MirSource`, `MirPhase` | Typed CFG and phase metadata |
| [compiler/rustc_middle/src/mir/basic_blocks.rs](https://github.com/rust-lang/rust/blob/b940084d7eb6a299eb4bfeb8e34901bc051e7ac4/compiler/rustc_middle/src/mir/basic_blocks.rs) | `BasicBlocks`, `Cache`, `as_mut_preserves_cfg`, `invalidate_cfg_cache` | Analysis reuse and invalidation contract |
| [compiler/rustc_mir_transform/src/lib.rs](https://github.com/rust-lang/rust/blob/b940084d7eb6a299eb4bfeb8e34901bc051e7ac4/compiler/rustc_mir_transform/src/lib.rs) | `provide`, `mir_built`, `mir_promoted`, `optimized_mir`, `run_optimization_passes` | Actual query and pass ordering |
| [compiler/rustc_mir_transform/src/inline.rs](https://github.com/rust-lang/rust/blob/b940084d7eb6a299eb4bfeb8e34901bc051e7ac4/compiler/rustc_mir_transform/src/inline.rs) | `Inline::policy`, `ForceInline`, `NormalInliner`, `CostChecker` use | Cost and legality checks |
| [compiler/rustc_mir_transform/src/sroa.rs](https://github.com/rust-lang/rust/blob/b940084d7eb6a299eb4bfeb8e34901bc051e7ac4/compiler/rustc_mir_transform/src/sroa.rs) | `ScalarReplacementOfAggregates`, `escaping_locals`, `ReplacementMap` | Aggregate escape proof and rewriting |
| [compiler/rustc_mir_transform/src/gvn.rs](https://github.com/rust-lang/rust/blob/b940084d7eb6a299eb4bfeb8e34901bc051e7ac4/compiler/rustc_mir_transform/src/gvn.rs) | `GVN::run_pass`, `VnState`, `try_as_local` | Dominance-aware value reuse |
| [compiler/rustc_mir_transform/src/dataflow_const_prop.rs](https://github.com/rust-lang/rust/blob/b940084d7eb6a299eb4bfeb8e34901bc051e7ac4/compiler/rustc_mir_transform/src/dataflow_const_prop.rs) | `DataflowConstProp`, `ConstAnalysis`, `BLOCK_LIMIT`, `PLACE_LIMIT` | Bounded scalar propagation |
| [compiler/rustc_query_impl/src/lib.rs](https://github.com/rust-lang/rust/blob/b940084d7eb6a299eb4bfeb8e34901bc051e7ac4/compiler/rustc_query_impl/src/lib.rs) | `query_system`, `provide` | Provider tables, caches and query jobs |
| [compiler/rustc_query_impl/src/incremental.rs](https://github.com/rust-lang/rust/blob/b940084d7eb6a299eb4bfeb8e34901bc051e7ac4/compiler/rustc_query_impl/src/incremental.rs) | `encode_query_values`, `verify_query_key_hashes`, `promote_from_disk_inner` | Persistent reuse and fingerprint verification |
| [compiler/rustc_monomorphize/src/collector.rs](https://github.com/rust-lang/rust/blob/b940084d7eb6a299eb4bfeb8e34901bc051e7ac4/compiler/rustc_monomorphize/src/collector.rs) | `collect_crate_mono_items`, `UsageMap`, collection strategies | Instance reachability graph |
| [compiler/rustc_codegen_llvm/src/back/write.rs](https://github.com/rust-lang/rust/blob/b940084d7eb6a299eb4bfeb8e34901bc051e7ac4/compiler/rustc_codegen_llvm/src/back/write.rs) | `llvm_optimize`, `optimize`, `codegen` | Backend optimization and output |

## Pipeline and representations

The broad flow is parsing and expansion into AST, name resolution and AST-to-HIR
lowering, type checking, typed THIR bodies, MIR construction and borrow checking,
runtime MIR lowering/optimization, monomorphic instance collection and codegen
unit partitioning, then LLVM IR optimization and machine-code emission.
This is a dependency-driven compiler, so the diagram is a logical pipeline,
not a promise that every crate-wide stage runs eagerly in that order.
[Compiler overview](https://rustc-dev-guide.rust-lang.org/overview.html).

HIR retains source-oriented identity and desugared language structure. It is
useful for resolution, type checking, diagnostics and per-item queries. Rust's
AST lowering source explicitly separates owner identity, local IDs, spans,
bodies and arena allocation; the inspected supplementary
[AST lowering source](https://raw.githubusercontent.com/rust-lang/rust/main/compiler/rustc_ast_lowering/src/lib.rs)
was a floating `main` snapshot, so no claim about its exact layout at P follows.

THIR is body-oriented and typed: indexed vectors hold expressions, blocks,
statements, arms and parameters. Each expression records its type, span and
temporary-scope identity. Method calls and overloaded operators become ordinary
call expressions. Scope nodes retain destruction boundaries. This gives MIR
construction explicit semantic facts rather than requiring backend passes to
rediscover source typing. [Pinned THIR source](https://github.com/rust-lang/rust/blob/b940084d7eb6a299eb4bfeb8e34901bc051e7ac4/compiler/rustc_middle/src/thir.rs).

MIR `Body` stores basic blocks, typed local declarations, argument count, source
scopes, phase and source identity. Newtyped indices distinguish locals, blocks
and scopes. MIR represents assignments and control flow rather than an implicit
expression tree. Its explicit places, moves and calls support ownership and
dataflow reasoning; the existence of MIR does not imply it is globally SSA.
[Pinned MIR definitions](https://github.com/rust-lang/rust/blob/b940084d7eb6a299eb4bfeb8e34901bc051e7ac4/compiler/rustc_middle/src/mir/mod.rs).

Borrow checking must precede destructive runtime cleanup. Drop elaboration is a
semantic lowering step, not merely dead-code elimination. Generic runtime MIR
can be optimized before collecting concrete codegen instances; LLVM then works
on emitted backend IR. These divisions keep language-specific reasoning above
the backend. [MIR optimization guide](https://rustc-dev-guide.rust-lang.org/mir/optimizations.html).

## Pass order actually present at P

`run_analysis_cleanup_passes` removes analysis-only structure. Runtime lowering
orders normalization/subtyping before `ElaborateDrops`, then unwind handling,
packed-drop moves, dereference cleanup and coroutine transformation. Runtime
cleanup lowers intrinsics before the optimization sequence. The selected order
below is read from `run_optimization_passes`, not inferred from pass filenames.
Individual policy/flags can skip optional entries.
[Pinned pass orchestration](https://github.com/rust-lang/rust/blob/b940084d7eb6a299eb4bfeb8e34901bc051e7ac4/compiler/rustc_mir_transform/src/lib.rs).

| Relative order | Actual entries, with unrelated entries abbreviated |
| --- | --- |
| Before inlining | `LowerSliceLenCalls`, `InstSimplify::BeforeInline` |
| Inline | `ForceInline`, `Inline` |
| Shrink exposed code | `RemoveStorageMarkers`, `RemoveZsts`, `RemoveUnneededDrops`, unreachable-enum/CFG cleanup |
| Before value reuse | `InstSimplify::AfterSimplifyCfg`, condition simplification, `ReferencePropagation` |
| Aggregate/value sequence | `ScalarReplacementOfAggregates`, `SimplifyLocals::BeforeConstProp`, initial dead-store elimination, `GVN` |
| After GVN | `SimplifyLocals::AfterGVN`, `SsaRangePropagation`, `MatchBranchSimplification` |
| Constants/branches | `DataflowConstProp`, `SingleUseConsts`, condition simplification, `JumpThreading`, branch/comparison cleanup |
| Final cleanup | final CFG simplification, `CopyProp`, final dead-store elimination, `DestinationPropagation`, final locals simplification |

This sequence explains why inlining is followed by cleanup and why SROA can
expose operands to GVN and propagation. It does not mean every Rust optimization
is a MIR pass: LLVM has another configurable pipeline. The MIR source warns
against inserting CFG-invalidating work between passes sharing dominators.
Optimization ordering is therefore also a compile-cost decision.

## Mechanisms, legality and cost

**Inlining.** At MIR level 2, normal inlining defaults on only for the higher
codegen optimization levels with incremental mode disabled; levels 0/1 default
off, higher MIR levels default on. Heuristic thresholds distinguish forwarders,
cross-crate candidates and ordinary calls (30/100/50 before bonuses). Depth,
error-tainted bodies, instruction-set compatibility and explicit tail-call
terminators affect admission. `#[inline(always)]` still faces a MIR cost check;
`ForceInline` is a separate required policy. This is not blanket substitution.
[Pinned inliner](https://github.com/rust-lang/rust/blob/b940084d7eb6a299eb4bfeb8e34901bc051e7ac4/compiler/rustc_mir_transform/src/inline.rs).

**SROA.** At MIR level ≥2, eligible aggregate locals become field locals.
Whole-value escapes, parameters/return place, address-taking, enums/unions and
certain special representations exclude candidates. The pass repeats flattening
until no further replacements arise; typed replacement maps rewrite places,
storage statements and debug fragments. It skips coroutine types to avoid query
cycles. Eliminating one private tuple is a small analogue, not the entirety of
this transformation. [Pinned SROA](https://github.com/rust-lang/rust/blob/b940084d7eb6a299eb4bfeb8e34901bc051e7ac4/compiler/rustc_mir_transform/src/sroa.rs).

**GVN.** At MIR level ≥2, the pass constructs SSA-local facts, clones dominators,
and visits blocks in reverse postorder. A numbered value can replace a use with
a prior local only when its assignment dominates the use. Constants and place
projections are also simplified. This is more precise than a global textual
expression dictionary: reuse must obey control-flow availability and memory
semantics. MIR itself remains capable of repeated assignments.
[Pinned GVN](https://github.com/rust-lang/rust/blob/b940084d7eb6a299eb4bfeb8e34901bc051e7ac4/compiler/rustc_mir_transform/src/gvn.rs).

**Constant propagation.** The pinned dataflow pass propagates scalar facts and
defaults to MIR level ≥3. Below level 4 it refuses bodies over 100 blocks and
caps tracked places at 100; level 4 removes those bounds. Analysis reaches a
fixpoint, collects changes, then patches the body while preserving CFG.
Address-taken places are excluded because the pass does not assume a sufficient
alias model. The source describes its limits as provisional, not calibrated
performance constants. [Pinned propagation](https://github.com/rust-lang/rust/blob/b940084d7eb6a299eb4bfeb8e34901bc051e7ac4/compiler/rustc_mir_transform/src/dataflow_const_prop.rs).

**Analysis invalidation.** `BasicBlocks` caches predecessors, reverse postorder
and dominators in `OnceLock`s behind `Arc`. Ordinary mutable access invalidates
the cache. `as_mut_preserves_cfg` requires unchanged block count and successor
structure, including switch targets/kind. Invalidation clears a uniquely owned
cache or installs a fresh cache when clones share the old one. This permits
sharing immutable analysis results without making stale facts silently valid.
[Pinned CFG cache](https://github.com/rust-lang/rust/blob/b940084d7eb6a299eb4bfeb8e34901bc051e7ac4/compiler/rustc_middle/src/mir/basic_blocks.rs).

## Queries, incremental work and monomorphization

The query system has local/external provider tables, arenas, optional disk cache,
query vtables, side effects and job/cycle state. `query_system` constructs these
explicitly. This is demand-driven computation with compiler-specific keys and
results, not memoization keyed only by a function's printable name.
[Pinned query setup](https://github.com/rust-lang/rust/blob/b940084d7eb6a299eb4bfeb8e34901bc051e7ac4/compiler/rustc_query_impl/src/lib.rs).

The documented red/green model tracks dependency reads: an unchanged result can
remain reusable even when an input was recomputed. Persistent identity uses
stable fingerprints rather than process addresses. Dependency read order matters
when a changed earlier query selects a different later branch.
[Incremental explanation](https://rustc-dev-guide.rust-lang.org/queries/incremental-compilation-in-detail.html).

Pinned incremental code serializes only eligible keys, promotes known-green disk
results, recovers keys and verifies result fingerprints. Debug/explicit checking
verifies query-key uniqueness; normal disk-result verification rotates a
deterministic subset across 32 sessions, while an explicit flag verifies all.
Cache availability and correctness checking are separate concerns.
[Pinned incremental implementation](https://github.com/rust-lang/rust/blob/b940084d7eb6a299eb4bfeb8e34901bc051e7ac4/compiler/rustc_query_impl/src/incremental.rs).

Mono collection discovers roots from HIR, follows concrete-instance uses through
MIR, and includes function references, statics, closures and drop glue. Generic
definitions can produce multiple artifacts, including foreign-crate instances.
Lazy collection minimizes required code; eager collection favors stable sets
for incremental reuse. The collector also checks mentioned items so removal of
dead calls does not arbitrarily hide constant-evaluation errors. Parallel graph
collection ends with deterministic sorting.
[Pinned collector](https://github.com/rust-lang/rust/blob/b940084d7eb6a299eb4bfeb8e34901bc051e7ac4/compiler/rustc_monomorphize/src/collector.rs).

LLVM optimization and output have separate profiler activities. Configuration
selects optimization/LTO stage, vectorization, loop unrolling, instrumentation
and profile inputs before object/assembly/IR emission. MIR pass policies alone
cannot predict the final executable's performance or code size.
[Pinned LLVM backend](https://github.com/rust-lang/rust/blob/b940084d7eb6a299eb4bfeb8e34901bc051e7ac4/compiler/rustc_codegen_llvm/src/back/write.rs).

## Transfer to this Bend compiler: hypotheses and existing analogues

The following judgments are local analysis, not Rust benchmark claims. Scope is
`selfhost/src/back/js`, with the human-written `bend2/bend.ts` protected by AGENTS.

| Rust mechanism | Bend status observed | Bounded transfer |
| --- | --- | --- |
| Typed intermediate bodies | Already present in annotated `KTerm`/`KDef` and `JRegionBuild` plans | Preserve type/origin facts in an explicit private plan instead of repeatedly rebuilding them during emission |
| Known-call inlining | Narrow analogue: `j_region_inline_defs`/`j_region_inline_term`, finite selectors | Admit another proved acyclic helper with a size budget; do not erase mutable public descriptor lookup |
| SROA | Narrow virtual region outputs; transfer tuples remain in structural workers | Scalarize a proven nonescaping private tuple, evaluate all RHSs before slot updates, preserve escaping tagged values |
| Dominance-based GVN | No comparable general CFG pass established by this inspection | Begin with pure straight-line scalar terms and explicit scope availability; expand only with a real control-flow proof |
| Query/incremental reuse | No rustc-style persistent query graph established here | Cache repeated compile-time facts per immutable book/request; key source, types, options and dependencies together |
| Phase/cached-analysis contract | Bounded purity/shape plans exist, without this MIR cache protocol | Mark which source/typing/graph facts a transformation preserves and invalidate the rest |
| Monomorphization | Concrete private instance/proof machinery is a narrow analogue | Specialize only proved closed signatures/graphs; preserve ordinary erased/public ABI positions |
| Drop/borrow analysis | Rust-specific destructor and reference obligations | Reuse the idea of explicit lifetime/ownership boundaries; do not import a borrow checker wholesale |

Local anchors: [region.bend](../../selfhost/src/back/js/region.bend),
[tree.bend](../../selfhost/src/back/js/tree.bend),
[jpure.bend](../../selfhost/src/back/js/jpure.bend),
[finite.bend](../../selfhost/src/back/js/finite.bend).
An absence above means no general counterpart was established by this focused
inspection; it is not an audited claim that the entire compiler lacks the idea.

Bend's public JavaScript ABI permits host mutation, getters, partial application,
deferred construction and reentry. Rust's private MIR facts do not authorize
skipping any of those observations. A private rewrite needs the existing exact
entry and complete dependency guard, owned values, original evaluation/error
order and proof cleanup. Capture freshness, alias identity and continuation
stack bounds remain separate obligations. Rust SROA's escape refusals reinforce
that boundary; they do not supply a Bend-specific ownership proof.

The nearest compiler-cost hypothesis is reusing full typed graph/admission facts
within one request. Measure pass/query visits, request wall time and retained
memory before persistent caching. The nearest runtime hypothesis is private
transfer-tuple removal followed by selected helper admission. Keep their
ablations separate: faster generated code can still mean slower compilation.
No speedup number follows from this research, and Rust's heuristic thresholds
are not recommended Bend constants.

## Testing, remarks and reproducibility

Rust's MIR workflow captures before/after pass dumps and checks UI behavior;
compiletest has distinct UI, MIR-opt, codegen, assembly and incremental suites.
These observe different properties. A pretty dump verifies a transformation's
shape, not all runtime equivalence. Incremental revision tests additionally
exercise reuse/invalidation across edits.
[MIR workflow](https://rustc-dev-guide.rust-lang.org/mir/optimizations.html),
[compiletest suites](https://rustc-dev-guide.rust-lang.org/tests/compiletest.html).

For Bend, pair a saved private-plan/emission diff with checked-source emission,
full tagged values, aliases, hostile descriptors/getters, errors/reentry and
long-tail controls. Then measure compiler requests separately from target
execution, with exact source/API/runtime identities. Retain rejected artifacts.
LLVM optimization remarks or MIR dumps would be useful explanatory evidence in
a Rust experiment; no remarks, profiler captures or benchmarks were produced
here, so this document makes no cost attribution from them.

Selected fetched-file SHA256 values, in source-table order where applicable:

| File suffix | SHA256 |
| --- | --- |
| `middle/src/thir.rs` | `c72521805bff6f2fe1e23265dfd27a335af2aeaee0f399ea952206a9d8274289` |
| `middle/src/mir/mod.rs` | `f5b75f88dee241b32d45e76a9bc3a718b4efb306c326a1cbfa2e25f6f410a025` |
| `middle/src/mir/basic_blocks.rs` | `a1461276f35c6998ad5adcee4f2a639d8f565eee58f1a080f0cd552b1781dfed` |
| `mir_transform/src/lib.rs` | `485573f11548f1777ce49c246dc290dca6da1b37232bee7f511959215394a6ee` |
| `mir_transform/src/inline.rs` | `e27b931e3d6c07ce238772a0ad51b7388319fb062205615aa6b140d2e2b2060f` |
| `mir_transform/src/sroa.rs` | `c6d02aefbf3edb3b902b00d428a94cc43b901443a53733447688acf0fba4aaf7` |
| `mir_transform/src/gvn.rs` | `2c65ae9ecf3a61750789e7683d4ee5b40241cc27acf9ec60e7e680f8251ed181` |
| `mir_transform/src/dataflow_const_prop.rs` | `219bf069fcd3683fa646c89f78ec8887a3293fa3091366dfe761acd4efa06623` |
| `query_impl/src/lib.rs` | `c2d4d68c6c3045af4ad7bc38fd7f1abf49cd0d01bd35d8202288034668004b51` |
| `query_impl/src/incremental.rs` | `7855be59b195ee2fa0902962cd6a72f8cfe5186f54f4e9d0ff27b15d2b3e0034` |
| `monomorphize/src/collector.rs` | `6d3f00c995c488743415179bcd60f19aae3784b6fb1e13b389c40f12cb6f66f5` |
| `codegen_llvm/src/back/write.rs` | `efdfc5ea70f7ad84abeacb8cf56236a3f752e1edf1cae8f9d23d6b45f59c313b` |
