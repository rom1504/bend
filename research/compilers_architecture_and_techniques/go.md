# Go compiler architecture and techniques

Lookup date: **2026-10-04**. This survey pins **Go 1.25.0**, tag `go1.25.0`,
commit **`6e676ab2b809d46623acb5988248d95d1eb7939c`**.
The tag resolves to that commit in the [official Git repository](https://go.googlesource.com/go.git/+/refs/tags/go1.25.0).
The [release notes](https://go.dev/doc/go1.25) date the release to August 2025.
This is a deliberately pinned implementation, **not a claim about the latest Go release**.

The central lesson is a sequence of enabling transformations: identify callees,
inline selectively, analyze escapes, preserve evaluation order while lowering,
then optimize a typed control-flow graph with explicit memory dependencies.
Go does not obtain these benefits by treating every function as unconditionally pure.
For Bend, the reusable part is the organization of proofs and transformations;
Go's native ABI and ownership assumptions cannot replace Bend's public JS contract.

## Scope and evidence

I inspected the following files at the pinned commit, reading the named sections
and symbols rather than claiming an exhaustive audit of every architecture.
Pinned raw files were fetched individually; no repository clone, compiler build,
benchmark, or compiler execution was performed. Initial browser cache misses were
resolved by fetching the same commit's public raw GitHub files.
The official prose pages below were consulted on the lookup date and are not
versioned snapshots; implementation claims are anchored in the pinned sources.

| Pinned source | Sections or symbols inspected | Role |
| --- | --- | --- |
| [Compiler README](https://github.com/golang/go/blob/6e676ab2b809d46623acb5988248d95d1eb7939c/src/cmd/compile/README.md) | pipeline, export data, debugging, testing | architecture and supported diagnostics |
| [gc/main.go](https://github.com/golang/go/blob/6e676ab2b809d46623acb5988248d95d1eb7939c/src/cmd/compile/internal/gc/main.go) | `Main`, package loading through `compileFunctions` | middle-end ordering |
| [interleaved.go](https://github.com/golang/go/blob/6e676ab2b809d46623acb5988248d95d1eb7939c/src/cmd/compile/internal/inline/interleaved/interleaved.go) | `DevirtualizeAndInlinePackage`, call-site state and fixed point | mutual enabling of call transformations |
| [inl.go](https://github.com/golang/go/blob/6e676ab2b809d46623acb5988248d95d1eb7939c/src/cmd/compile/internal/inline/inl.go) | `CanInlineFuncs`, `inlineCostOK`, budgets | size and hotness policy |
| [devirtualize.go](https://github.com/golang/go/blob/6e676ab2b809d46623acb5988248d95d1eb7939c/src/cmd/compile/internal/devirtualize/devirtualize.go) | `StaticCall`, go/defer refusal | static target proof and panic timing |
| [devirtualize/pgo.go](https://github.com/golang/go/blob/6e676ab2b809d46623acb5988248d95d1eb7939c/src/cmd/compile/internal/devirtualize/pgo.go) | `ProfileGuided`, `maybeDevirtualizeFunctionCall` | guarded speculative direct calls |
| [escape.go](https://github.com/golang/go/blob/6e676ab2b809d46623acb5988248d95d1eb7939c/src/cmd/compile/internal/escape/escape.go) | invariants, `Funcs`, `Batch`, `flowClosure` | allocation placement and capture mode |
| [walk/closure.go](https://github.com/golang/go/blob/6e676ab2b809d46623acb5988248d95d1eb7939c/src/cmd/compile/internal/walk/closure.go) | `directClosureCall`, `walkClosure`, capture arguments | closure conversion |
| [walk/order.go](https://github.com/golang/go/blob/6e676ab2b809d46623acb5988248d95d1eb7939c/src/cmd/compile/internal/walk/order.go) | order-state machinery and temporaries | source evaluation ordering |
| [SSA README](https://github.com/golang/go/blob/6e676ab2b809d46623acb5988248d95d1eb7939c/src/cmd/compile/internal/ssa/README.md) | values, blocks, memory, passes, dumps | SSA model |
| [ssa/compile.go](https://github.com/golang/go/blob/6e676ab2b809d46623acb5988248d95d1eb7939c/src/cmd/compile/internal/ssa/compile.go) | `Compile`, `passes`, `passOrder` | pass sequencing and checks |
| [prove.go](https://github.com/golang/go/blob/6e676ab2b809d46623acb5988248d95d1eb7939c/src/cmd/compile/internal/ssa/prove.go) | `factsTable`, limits, `prove`, dominator traversal | range and branch reasoning |
| [cse.go](https://github.com/golang/go/blob/6e676ab2b809d46623acb5988248d95d1eb7939c/src/cmd/compile/internal/ssa/cse.go) | equivalence partitions and dominating replacements | common subexpression elimination |
| [deadcode.go](https://github.com/golang/go/blob/6e676ab2b809d46623acb5988248d95d1eb7939c/src/cmd/compile/internal/ssa/deadcode.go) | reachability and live-value roots | dead code elimination |
| [generic.rules](https://github.com/golang/go/blob/6e676ab2b809d46623acb5988248d95d1eb7939c/src/cmd/compile/internal/ssa/_gen/generic.rules) | constant and bounds-check patterns | generated rewrite rules |
| [ssagen/ssa.go](https://github.com/golang/go/blob/6e676ab2b809d46623acb5988248d95d1eb7939c/src/cmd/compile/internal/ssagen/ssa.go) | `buildssa`, `boundsCheck`, `genssa` | SSA construction and machine emission |
| [gc/compile.go](https://github.com/golang/go/blob/6e676ab2b809d46623acb5988248d95d1eb7939c/src/cmd/compile/internal/gc/compile.go) | `prepareFunc`, `compileFunctions` | serial preparation and parallel back end |

## From source to object code

The compiler's own [pipeline description](https://github.com/golang/go/blob/6e676ab2b809d46623acb5988248d95d1eb7939c/src/cmd/compile/README.md)
separates the representations instead of presenting SSA as the entire compiler:

```text
Go source → syntax AST → types2 checking → Unified IR / internal ir
          → devirtualization + inlining → escape analysis
          → walk: ordered temporaries + desugaring
          → generic SSA → optimized SSA → target-specific lowered SSA
          → layout/scheduling/register allocation → obj.Prog → object file
```

`syntax` records source positions and language syntax; `types2` checks that syntax.
The noder's Unified IR bridges checked code, imports/exports, generic instances,
and the compiler's `internal/ir` and `internal/types` representations.
Export data includes type information, inlineable bodies, generic bodies, and
parameter escape summaries. Its indexed representation supports lazy decoding;
this is a cross-package optimization interface, not just a symbol-name list.
[Compiler README, sections 1–3 and Export data](https://github.com/golang/go/blob/6e676ab2b809d46623acb5988248d95d1eb7939c/src/cmd/compile/README.md).

`gc.Main` loads the package and optional PGO information, invokes interleaved
call transformations, makes wrappers, handles loop-variable capture, and runs
escape analysis before compiling function bodies. ABI wrappers precede escape
analysis so their behavior participates in the analysis.
[gc/main.go, `Main`](https://github.com/golang/go/blob/6e676ab2b809d46623acb5988248d95d1eb7939c/src/cmd/compile/internal/gc/main.go).

`walk` introduces temporaries to retain evaluation order and lowers language
operations into simpler forms: switches may become comparisons or jump tables;
map and channel operations may become runtime calls. SSA therefore receives an
already ordered, substantially desugared function, not arbitrary source syntax.
[Compiler README, Walk](https://github.com/golang/go/blob/6e676ab2b809d46623acb5988248d95d1eb7939c/src/cmd/compile/README.md),
[walk/order.go, order-state machinery](https://github.com/golang/go/blob/6e676ab2b809d46623acb5988248d95d1eb7939c/src/cmd/compile/internal/walk/order.go).

`ssagen.buildssa` initializes memory state, constructs the function graph, and
calls `ssa.Compile`. Generic operations describe language-level computation;
`lower` and architecture rewrites select target operations. After later layout,
scheduling and allocation, `genssa` writes instruction records for object emission.
[ssagen/ssa.go, `buildssa`, `genssa`](https://github.com/golang/go/blob/6e676ab2b809d46623acb5988248d95d1eb7939c/src/cmd/compile/internal/ssagen/ssa.go),
[ssa/compile.go, `passes`](https://github.com/golang/go/blob/6e676ab2b809d46623acb5988248d95d1eb7939c/src/cmd/compile/internal/ssa/compile.go).

## Escape analysis and closure conversion

Go's escape analysis enforces two important stack-allocation conditions:
a stack address cannot reach the heap, and it cannot outlive its stack storage.
Locations and weighted assignment edges model copies, address taking and
indirection. The analysis is generally flow-, path-, and context-insensitive;
it also intentionally abstracts many compound-field and element distinctions.
Do not mistake this for a universal field-sensitive uniqueness analysis.
[escape.go, package commentary and `Batch`](https://github.com/golang/go/blob/6e676ab2b809d46623acb5988248d95d1eb7939c/src/cmd/compile/internal/escape/escape.go).

`Funcs` analyzes bottom-up groups, including mutually recursive functions.
Parameter summaries describe flows to heap and results and are reused at static
call sites and across package boundaries. Closure capture decisions wait until
assignment and address-taking information has been collected. `flowClosure`
captures by value when a variable is not address-taken or reassigned and fits the
pinned size limit of 128 bytes; otherwise it captures a reference.
[escape.go, `Funcs`, `Batch`, `flowClosure`](https://github.com/golang/go/blob/6e676ab2b809d46623acb5988248d95d1eb7939c/src/cmd/compile/internal/escape/escape.go).

`directClosureCall` converts a directly called literal closure into a normal
function call with captured variables added as parameters. Reference captures
become pointer parameters. This avoids allocating a closure object while keeping
capture evaluation and call arguments explicit. Ordinary escaping or retained
closures instead use an object containing a code pointer and captured fields;
`walkClosure` preserves escape facts and handles nonescaping preallocation.
[walk/closure.go, `directClosureCall`, `walkClosure`](https://github.com/golang/go/blob/6e676ab2b809d46623acb5988248d95d1eb7939c/src/cmd/compile/internal/walk/closure.go).

A literal immediately called lambda is the easy case. A global factory returning
a function requires a separate known-target/dataflow proof or enabling inlining.
The direct-closure pass alone is not evidence that every factory result can be
converted into a first-order call. Nor does nonescape imply that shared capture
identity or mutation may be discarded.

## Devirtualization, inlining and PGO

`StaticCall` can identify a concrete receiver behind an interface conversion and
replace a method dispatch with a concrete call; unsupported shapes remain indirect.
It explicitly refuses go/defer cases where receiver adaptation could move a nil
check from invocation time to statement evaluation time. That refusal is a useful
example of a target proof being insufficient without an evaluation-order proof.
[devirtualize.go, `StaticCall`](https://github.com/golang/go/blob/6e676ab2b809d46623acb5988248d95d1eb7939c/src/cmd/compile/internal/devirtualize/devirtualize.go).

In the pinned release, `DevirtualizeAndInlinePackage` computes inlineability,
tracks and resolves call sites, and processes bottom-up function groups to a
fixed point. Newly exposed call sites are resolved in batches before more inline
attempts, so a closure is not incorrectly considered single-use merely because
its second use has not yet been discovered. PGO devirtualization still occurs in
a separate preliminary traversal; the source contains a TODO to integrate it.
[interleaved.go, `DevirtualizeAndInlinePackage`](https://github.com/golang/go/blob/6e676ab2b809d46623acb5988248d95d1eb7939c/src/cmd/compile/internal/inline/interleaved/interleaved.go).

Inlining has explicit cost policy. This version's ordinary budget is 80, its hot
maximum 2000, with distinct treatment of large callers, closure calls and a
closure called once. These are compiler cost units, not machine instructions or
universal thresholds to transplant. Hotness permits larger candidates only under
additional size and policy conditions.
[inl.go, budgets and `inlineCostOK`](https://github.com/golang/go/blob/6e676ab2b809d46623acb5988248d95d1eb7939c/src/cmd/compile/internal/inline/inl.go).

PGO identifies hot indirect targets and creates a guarded direct-call path plus
the original indirect fallback. Interface calls use a receiver-type test;
function-value calls compare the function's entry PC. Actual closures are refused
by `maybeDevirtualizeFunctionCall` because the transformation does not provide
the required closure-context register plumbing. Profiles guide profitability;
the runtime condition establishes whether the chosen target applies now.
[devirtualize/pgo.go, `ProfileGuided`, `maybeDevirtualizeFunctionCall`](https://github.com/golang/go/blob/6e676ab2b809d46623acb5988248d95d1eb7939c/src/cmd/compile/internal/devirtualize/pgo.go).

The official [PGO guide](https://go.dev/doc/pgo) describes CPU profiles, automatic
`default.pgo` selection, explicit `-pgo` selection and representative workloads.
It cautions against unrepresentative microbenchmarks; the first profiled build can
rebuild dependencies, and more inlining can increase binary size. This survey
makes no measured Go speed or compile-latency claim.

## SSA, effects, ranges and elimination

A Go SSA value has an operation, type, arguments, auxiliary data and identity;
blocks carry control values and successors. Memory is a special SSA value:
stores and side-effecting operations consume and produce memory states, making
required ordering visible in data dependencies. This does not prove unrelated
addresses cannot alias, or authorize arbitrary movement of faulting operations.
[SSA README, Values, Blocks and Memory](https://github.com/golang/go/blob/6e676ab2b809d46623acb5988248d95d1eb7939c/src/cmd/compile/internal/ssa/README.md).

`boundsCheck` first normalizes index width, constructs an `IsInBounds` or
`IsSliceInBounds` condition, and splits success from a panic block. Panic bounds
operations carry memory. Compiler-generated safe indices can omit the check;
ordinary source conditions still undergo explicit graph reasoning. Spectre
masking is handled separately and is deliberately not equated with ordinary BCE.
[ssagen/ssa.go, `boundsCheck`](https://github.com/golang/go/blob/6e676ab2b809d46623acb5988248d95d1eb7939c/src/cmd/compile/internal/ssagen/ssa.go).

`prove` records signed, unsigned and boolean relations, ranges, and length/capacity
facts. It traverses the dominator tree with checkpoint/restore, so facts apply to
controlled descendants and do not leak into sibling paths. Contradictory branch
facts remove unreachable successors; a dominating successful bounds check can
prove a later equivalent check redundant. Induction-variable reasoning supplies
loop facts; this release supports one discovered induction variable per block.
[prove.go, `factsTable`, `limit`, `prove`](https://github.com/golang/go/blob/6e676ab2b809d46623acb5988248d95d1eb7939c/src/cmd/compile/internal/ssa/prove.go).

CSE refines equivalence classes by operation, type, auxiliary fields and operand
classes, normalizing commutative operands. A replacement must dominate the use;
phi equivalence also depends on block identity. Memory-typed values are excluded,
and a load's memory argument prevents treating reads across changed memory as the
same expression. CSE rewrites uses; later dead-code elimination removes leftovers.
[cse.go, `cse` and dominating replacement loop](https://github.com/golang/go/blob/6e676ab2b809d46623acb5988248d95d1eb7939c/src/cmd/compile/internal/ssa/cse.go).

DCE computes reachable blocks and a live operand closure. Calls, side effects,
nil checks and block controls seed liveness, so an unused result does not by
itself make a faulting or effectful instruction removable. Post-register-allocation
handling differs because the representation has additional allocation obligations.
[deadcode.go, reachability and live-value computation](https://github.com/golang/go/blob/6e676ab2b809d46623acb5988248d95d1eb7939c/src/cmd/compile/internal/ssa/deadcode.go).

Rewrite rules use typed SSA patterns with predicates, not emitted-text matching.
The generic rules include constant folds and bounds facts derived from extension
widths, masks and identical operands. Architecture rules are applied after lowering;
a generic rewrite and a machine-specific rewrite have different legal vocabularies.
[generic.rules, `IsInBounds` patterns](https://github.com/golang/go/blob/6e676ab2b809d46623acb5988248d95d1eb7939c/src/cmd/compile/internal/ssa/_gen/generic.rules),
[SSA README, Hacking on SSA](https://github.com/golang/go/blob/6e676ab2b809d46623acb5988248d95d1eb7939c/src/cmd/compile/internal/ssa/README.md).

## Pass ordering and compilation cost

The pinned `passes` list includes generic optimization, CSE, phi simplification,
nil-check elimination, `prove`, call expansion, SCCP, branch elimination, DSE,
write barriers, target lowering, lowered CSE, layout, scheduling and allocation.
It is not one unconstrained rewrite fixed point. `passOrder` checks dependencies:
CSE precedes `prove` and DSE; `prove` precedes generic dead code; lowered dead code
precedes `checkLower`; scheduling precedes register allocation. Some passes are
required even when ordinary optimization is disabled.
[ssa/compile.go, `passes`, `passOrder`](https://github.com/golang/go/blob/6e676ab2b809d46623acb5988248d95d1eb7939c/src/cmd/compile/internal/ssa/compile.go).

Frontend preparation, including walking and shared metadata work, is serialized.
`compileFunctions` orders queued functions by size so large work starts early,
then bounds backend workers by the requested compiler concurrency. Race builds
can randomize ordering to expose compiler races. This concerns compiler throughput,
not automatic parallelization of the compiled program.
[gc/compile.go, `prepareFunc`, `compileFunctions`](https://github.com/golang/go/blob/6e676ab2b809d46623acb5988248d95d1eb7939c/src/cmd/compile/internal/gc/compile.go).

`Compile` can check IR between passes, collect per-pass time/allocation statistics,
dump graphs, and randomize value order under checking. Dense value identities and
CSE's partition/cache machinery also avoid unnecessary map or repeated work.
These are concrete engineering choices; this source reading does not establish
an asymptotic bound for the complete compiler.
[ssa/compile.go, `Compile`](https://github.com/golang/go/blob/6e676ab2b809d46623acb5988248d95d1eb7939c/src/cmd/compile/internal/ssa/compile.go),
[cse.go, partition refinement and `storeOrdering`](https://github.com/golang/go/blob/6e676ab2b809d46623acb5988248d95d1eb7939c/src/cmd/compile/internal/ssa/cse.go).

## Diagnostics and regression evidence

The compiler documents `-m=2` for optimization decisions, `-d=ssa/check_bce/debug`
for bounds-check information, `GOSSAFUNC` for before/after SSA HTML, `-S` for
assembly, and `-bench` for compiler timing. These commands are examples from the
source documentation, not commands executed for this survey.
[Compiler README, Debugging](https://github.com/golang/go/blob/6e676ab2b809d46623acb5988248d95d1eb7939c/src/cmd/compile/README.md).

Tests include compiler-package tests and top-level language/optimization tests
run through `cmd/internal/testdir`; `ERROR` comments check diagnostics. Type-checker
changes share test data between `go/types` and `types2`. The README also describes
instrumenting compiler coverage and retaining a known-good toolchain while working.
[Compiler README, Testing your changes and Juggling compiler versions](https://github.com/golang/go/blob/6e676ab2b809d46623acb5988248d95d1eb7939c/src/cmd/compile/README.md).

The [Go 1.25 compiler notes](https://go.dev/doc/go1.25#compiler) describe a repaired
nil-check ordering bug: earlier compiler versions could incorrectly delay a field
access's panic past an error check. This is practical evidence that fault placement
is part of correctness, even when a faster program appears to return useful values.
The [diagnostics guide](https://go.dev/doc/diagnostics) separately distinguishes CPU,
allocation and retained-memory evidence and cautions that instrumentation can
interfere; compiler and application measurements should answer distinct questions.

## Comparison with Bend's Phase45 JIR/JW

Bend's ordinary [JIR model](../../selfhost/src/back/js/ir/model.bend) explicitly
records saturation chunks, left-to-right let values, delayed lambda bodies,
trampoline tail calls and demanded match arms. `JIRLegacy` and `JIRCallPlan` are
opaque/effect boundaries, not permission to infer purity from an outer node tag.
This resembles Go's separation between checked frontend IR and later lowered IR,
but Bend must additionally retain erased-argument and dependent-instance evidence.

The private [JW model](../../selfhost/src/back/js/ir/worker-model.bend) admits only
successful complete JPure instance graphs. It has slots, typed layout operations,
explicit direct-call instructions, cases and returns. It is **not full SSA**:
there are no phi or memory-token nodes in that model. The
[graph pass](../../selfhost/src/back/js/ir/worker-graph.bend) constructs bounded
call components, while emission keeps cyclic fallback machinery. The
[simplifier](../../selfhost/src/back/js/ir/worker-simplify.bend) removes only
established single-constructor layout cases while retaining prior evaluation.

| Go mechanism | Useful Bend transfer | Boundary that must remain |
| --- | --- | --- |
| Interleaved target discovery and inlining | bounded known-callee propagation before JW lowering | source telescope, erased prefix and capture provenance |
| Direct literal-closure calls | turn proved local captures into explicit private arguments | fresh/shared captures, saturation and construction order |
| Escape summaries | graph/SCC summaries of result, capture and public escape | nonescape does not establish unique ownership |
| Dominator range facts | remove repeated private scalar checks and refine Nat representation | wrap, overflow, panic and fallback behavior |
| Memory SSA and DCE roots | explicit host/failure barriers before broader CSE or dead-store work | descriptor getters, Error hooks and reentry |
| Pass order checks and dumps | phase invariants, refusal reasons and aggregate budgets | complete fallback and independent semantic controls |

Go's compiled code addresses and runtime closure layouts are not Bend's mutable
public `{arity, code, env, bound}` descriptors. A Go function-PC equality guard
cannot simply become a Bend `.code` comparison: environment, binding, prototype,
public dependency and observation boundaries may also matter. Bend's
[documented runtime contract](../../docs/PHASE42_GENERATED_JS.md#runtime-boundaries-and-maintenance)
assumes standard intrinsics at module initialization and supports subsequent
mutation and Error-hook reentry. Any guard reduction must preserve that domain;
neither profiles nor a pure source function type establish inert host access.

The smallest plausible extension is a source-proved known-function step that
first evaluates a factory prefix and its captures in order, then threads a private
target and environment through immediately applied uses. It should distinguish
literal lambdas from global returned functions, reject public escape or unknown
use, and preserve partial/oversaturated calls through the existing fallback.
Inlining may expose the required identity proof; it must not recompute captures
or pull delayed failure across the factory/application boundary.

A larger SSA-style extension should start inside already admitted JW graphs,
with effect/failure classification and explicit block/definition identities.
Only then should dominance-based CSE, range propagation or DCE grow beyond total
private operations. Native register allocation and instruction selection belong
to the JS engine for this backend; copying those Go passes would duplicate a
backend rather than address Bend's current admission and public-guard costs.

No new optimization or performance result is claimed here. The transferable
research direction is bounded call specialization plus ordered effect-aware IR,
qualified against Bend's source and public ABI before selecting profitability.
