# Cross-compiler comparison: what structure buys optimization

Survey date: 2026-10-04. Bend snapshot: Phase45 worker23 at `55e5b79`.
External implementation versions and precise source maps are in the
[research index](../../research/compilers_architecture_and_techniques/README.md).
This document synthesizes source inspections; it contains no new runtime results.

## Compare responsibilities, not brand names or raw line counts

| Compiler | Relevant representation and responsibility | Closest lesson for this compiler |
| --- | --- | --- |
| [Bend selfhost](../self_hosted/architecture.md) | Checked terms → ordinary JIR or proved private JW → JS; native segments are separate. JIR still has opaque compatibility paths. | We now have a usable first-order interior; reusable value/effect facts and broader coverage are the missing next layer. |
| [Pinned Bend TypeScript](../../research/compilers_architecture_and_techniques/bend-typescript.md) | Shared typed call/arity/layout facts → direct JS, tail loops, native values and host marshalling. | Preserve direct shape through more source constructs; keep the public compatibility cost at boundaries. |
| [Rust](../../research/compilers_architecture_and_techniques/rust.md) | Several semantic IRs, MIR transformations and monomorphization before LLVM; demand-driven queries organize compiler work. | Stage-specific invariants, small MIR-like transformations, and explicit cached-query dependencies. |
| [Go](../../research/compilers_architecture_and_techniques/go.md) | Frontend IR with escape/call/inlining work, then SSA and target lowering. | Cooperating call-target and inlining decisions; explicit memory/effect dependencies and cheap value proofs. |
| [Zig](../../research/compilers_architecture_and_techniques/zig.md) | Untyped ZIR → semantic analysis/InternPool → typed AIR → LLVM or native backend; separate liveness. | Compact stable facts and operand lifetimes; compiler speed and downstream code optimization are separate achievements. |
| [LLVM](../../research/compilers_architecture_and_techniques/llvm.md) | Typed SSA/CFG, separate memory analysis, nested passes and analysis invalidation. | Inlining → aggregate simplification → cleanup, with budgets and explicit preserved facts. |
| [V8](../../research/compilers_architecture_and_techniques/v8.md) | Runtime feedback and optimizing tiers, including graph reducers, representation analysis and deoptimization. | Emit analyzable JS, then let its JIT do machine work; measure what remains after warmup. |
| [Lean](../../research/compilers_architecture_and_techniques/lean.md) | Functional ANF-style LCNF, specialization/join points/lifting, then explicit memory operations. | Optimize higher-order functional structure before lowering it away; share continuations instead of duplicating branch suffixes. |

Rust's borrow checking, Go's escape model, Lean's reference-counted runtime and
V8's deoptimization machinery solve different language/runtime problems. They
are not interchangeable proofs for mutable JavaScript descriptors. LLVM/Zig
machine-code backends also own instruction selection and register allocation;
V8 owns that work for our generated JavaScript. Counting all their passes or
source lines against our JS emitter would be a misleading complexity comparison.

## Mechanism-by-mechanism gap map

Status terms: **general** means reusable within its stated domain; **narrow**
means a specialized path; **proposed** means not selected/implemented as that
general mechanism. None of these labels implies full-language conformance.
Source anchors and historical outcomes are in the
[inventory](../self_hosted/optimization-inventory.md) and
[prior-work audit](../self_hosted/prior-experiments.md).

| Mechanism | Existing Bend capability | External implementation lesson | Actual remaining scope |
| --- | --- | --- | --- |
| Explicit runtime operations | Ordinary JIR plus private JW | LLVM/Go make uses/control explicit; Lean represents local functions and joins. | Remove opaque adapters only as equivalent structured forms become useful and qualified. |
| Known first-order calls | General within admitted JW graphs | Upstream Bend direct calls; Go devirtualization. | Already implemented. Do not restart a direct-call project. |
| Higher-order calls | Narrow callbacks, factories, fusion and instance specialization | Lean specialization/lifting; Go devirtualization interacting with inlining. | Shared finite target/capture facts for local function transport. |
| Tail recursion | JW exact SCCs, tail loops, bounded native recursion plus continuation fallback | Upstream tail cycles; Lean join points. | Preserve this contract while other transformations alter calls. |
| Aggregate representation | Named private fields, native tuples/constructors, narrow pair/flat/fusion paths | Rust MIR SROA, LLVM allocation promotion, V8 escape analysis. | General fresh aggregate-to-projection elimination and scalar argument/result flow. |
| Inlining | Source specialization and narrow expression/worker composition | LLVM budgets; Lean simplifies before attaching continuations. | Bounded private helper inlining followed by cleanup, with code-growth control. |
| Def-use and liveness | Lexical JIR facts; specialized state/continuation handling | Zig operand deaths; LLVM explicit uses; Lean join-aware liveness. | Reusable JW use/escape/live-across-call facts, not another one-off frame recognizer. |
| Effects | Whole-graph purity/admission and explicit runtime boundaries | Go memory dependencies; LLVM function effects; Zig `mustLower`. | Per-operation discard/duplicate/move permissions, including error/demand/host observations. |
| Constants and branches | Literal folding, local aliases, single-constructor case simplification | LLVM SCCP; Go prove; Rust dataflow constants. | Propagate value/tag/range facts across private calls and branches. |
| CSE/load elimination | Narrow repeated-work removal and specialized scalar paths | Lean scoped pure CSE; LLVM value numbering; V8 load elimination. | Safe local value numbering after effects and private provenance are explicit. |
| Arrays | Ordinary native semantics and specialized paths | Upstream direct templates; Go effect-aware SSA; V8 typed operation handling. | Typed private allocation/read/write/swap with alias and failure semantics. |
| Public result conversion | Scalars/immutable String in general private backend | Upstream marshalling; worker/wrapper patterns in Lean. | Owned composite-result adaptation preserving public identities, sharing and handles. |
| Cached analyses | Existing `j_plan_context`/`j_plan_lookup` and other caches | Rust queries; LLVM analysis managers; Zig dependency tracking. | Context-complete per-definition/SCC summaries beyond current root plans. |
| Emitted code sharing | Specialized emission and earlier hoist/dedup experiment | Lean auxiliary-declaration cache; V8 inlining budgets. | Share equivalent typed private components across overlapping roots without sharing root state. |
| Continuation storage | Full current register vector in non-tail JW suspension; tail-only machines omitted | Zig/Lean lifetime analysis. | Pack/clear only proven live slots after measuring actual fallback frequency. |
| Fusion | Several strong selected specialized plans | Functional pipeline simplification; earlier Phase38 fusion research. | Express selected mechanisms as reusable producer/consumer transformations without losing multi-consumer behavior. |
| Profitability | Root-plan strength ranking and recursive-work admission gate | LLVM/Go/V8 use budgets and benefit estimates. | Explicit cost features: boundary frequency, duplicated IR, size, calls removed and expected exposure to V8. |
| Missed-optimization reporting | Experiment-specific counters/profiles and inventories | LLVM remarks, Go pass dumps, V8 tracing. | One stable decision schema connecting root refusal, IR pass and emitted function. |
| Pass verification | Lowering validity, graph checks and focused controls | LLVM verifier; Rust/Go/Lean IR checks. | Cheap local invariants after each change, separate from semantic equivalence. |
| Incremental build work | Frozen checked attempts, caches and persistent validation workers | Rust/Zig dependency-based compiler reuse. | First measure in-request duplicated work; persistent reuse requires stronger identity contracts. |
| Parallel development | Parallel agents, mostly serial target work | Compiler pass scheduling and build systems distinguish dependent units. | Bounded throughput queue plus exclusive timing lease; no concurrent clean timings. |

The central difference is not that other compilers have an IR and we do not.
It is that more transformations can consume the same stable facts, expose work
to one another and clean up each other's temporary structures.

## Five combinations that matter more than isolated passes

### A. Inline → expose aggregate → substitute fields → remove shell

A helper returning a tuple can hide scalar values behind an allocation. Small
inlining reveals that allocation; projection propagation forwards fields;
escape analysis licenses removing the shell. Dead-value cleanup is separate:
the original field computation can still throw or perform an observable read.

LLVM and Rust provide representation-specific aggregate transforms, Lean shows
how inlining and simplification cooperate, and V8 supplies a second optimization
opportunity downstream. The Bend-specific question is whether surviving hot
aggregates cross boundaries V8 cannot simplify. Measure that before implementing
a large interprocedural optimizer.

### B. Target/capture facts → specialization → first-order worker → cleanup

Known local functions should survive factory/helper transport as semantic facts,
then become explicit capture parameters and direct calls. The current complete
private-graph proof can consume the first-order result. This reuses Phase45's
investment rather than creating a separate callback backend for each pattern.

Retain prefix evaluation, capture aliasing and saturation order. Unknown or
escaping function values keep the public representation. Bound specialization
counts and share equivalent instances; the function benchmark that already
benefits from fusion is not evidence that all higher-order code is covered.

### C. Typed Array effects → result forwarding → wider admitted graph

Array get/size operations can return both an array handle and a scalar. If the
pair is private, forward its fields without rebuilding a shell. If a public
result includes the array, preserve that handle and its alias behavior.
Effectful array operations need a distinct ordering model from pure constructor
elimination. Combining the concepts is promising; combining their first tests
would make a failure difficult to diagnose.

### D. Shared semantic summaries → smaller plans → shared emission

Reuse declaration facts without confusing them with a root's runtime entry
permission. Then identify equivalent specialized components across roots and
emit one body where capture/dependency/representation contracts permit it.
Keep root-captured proof state and the existing shared root recursion-budget
scope separate from shared code. Continuation frames remain invocation-owned;
sharing a body must not reset the budget on nested same-root entry.

Earlier broad caches and helper hoisting did not automatically improve speed.
The new test must identify duplicated Phase45 work, distinguish cache construction
cost from hits, and preserve emission/selection before optimizing runtime size.

### E. Inline with shared continuations → liveness → compact machine fallback

Lean's source exposes a concrete inlining hazard: duplicating a continuation
across exits can explode code. Restrict the first inliner to single-exit helpers.
A later join representation can share suffixes. Once control uses are explicit,
liveness can identify compactable state without altering the native recursion
budget. Current suspension saves its parent vector by reference, so packing it
can add work. Clearing dead references, slot compaction and child-vector
allocation require separate measurements.

Wrapper allocation attribution does not prove continuation fallback is hot.
This chain needs activation counters first; it is not justified by a hot wrapper
name alone.

## Important mismatches and non-goals

| Imported idea | Why direct copying is unsafe or premature |
| --- | --- |
| Rust borrow checker | Our frontend already has a different dependent/affine language; host aliasing still needs separate proofs. |
| Lean runtime reuse | JavaScript exposes no complete RC uniqueness count; affine source use is insufficient. |
| LLVM UB-based folding | Bend errors, bounded Nat arithmetic, F32 rounding and host observations have their own semantics. |
| V8 speculative deoptimization | We currently guard entry and retain fallback, not arbitrary mid-function state reconstruction. |
| Zig packed storage everywhere | Faster access may not offset construction/conversion costs in this selfhost's generated representation. |
| Full SSA/MemorySSA immediately | Structured JW supports useful local transformations first; whole-framework construction delays falsification. |
| Native/Wasm replacement | Changes the backend and interoperability problem; it does not validate the existing JS speed target. |
| Wider whole-graph limits by default | The 96-function worker bound and analysis fuel are safeguards; count refusals before raising them. |
| Eliminate every compatibility path | Existing fusion/flat/region plans sometimes outperform the new worker and preserve distinct contracts. |
| Copy another compiler's benchmark gain | Different language, inputs, runtime and baseline; no transferable measured multiplier. |

## What the current measurements constrain

The [selected diagnostics](../../implementation/phase45/diagnostics.md) cover
two programs. Named generic invocation is now 4.6%/8.3% of sampled self CPU,
and named guards are 8.0%/4.65%. Those particular costs cannot alone explain a
new broad 3× improvement. Sampled allocation is about 1.33×/1.39× TypeScript
there; these figures do not bound every other program or identify removable
allocations precisely.

At the other extreme, several complete workload points remain 49–61× slower.
Source inspection finds higher-order, Array and result-shape gaps, but RLE
already has a worker. Hence neither “optimize all workers” nor “admit all missing
graphs” is sufficient alone. The
[ranked plan](README.md) combines both and separates measurements from estimates.

Most named techniques were discussed previously. The substantial new opportunity
is their **general composition over the current JW**, plus precise decisions
about when existing facts may be reused. The
[history audit](../self_hosted/prior-experiments.md) prevents treating a new name
for an old failed experiment as an unexplored result.
