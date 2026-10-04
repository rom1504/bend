# Zig compiler architecture: compact facts and explicit lifetimes

Research date: **2026-10-04**. Source snapshot: **Zig 0.15.2**,
commit **`e4cbd752c8c05f131051f8c873cff7823177d7d3`**.
This is a deliberately pinned release study, not a claim about the newest Zig.
The annotated tag object is `3eac10ac2933d96a71a90a1424659238169d5f28`;
its target is the commit above. The tag date is 2025-10-11 03:45:47 UTC.
The commit patch records 2025-10-10 20:45:47 -0700, the same instant.
[Tag object][tag] and [release commit patch][commit-patch] establish provenance.

This note inspects source rather than inferring implementation from language
marketing. Twelve files were read, including selected regions of the large Sema
and native x86-64 implementation. No compiler was built or benchmarked.
Web reads used the verified release tag; the native files were fetched directly
at the full commit into temporary storage after ordinary sandbox DNS failed.
All source links below use the full commit. Symbols are the durable lookup keys.

The useful transfer to Bend is to construct reusable semantic facts, expose
operation effects and lifetimes, and make backend scheduling consume them.
It is not to copy Zig's language model or promise LLVM-quality optimization
from a compact IR alone. The transfer proposals below are unimplemented.

## Source evidence

| Inspected file | Symbols or fields | Concrete evidence |
| --- | --- | --- |
| [lib/std/zig/Ast.zig][ast] | `parse`, `TokenList`, `NodeList`, `extra_data` | Indexed syntax with separate token/node arrays and variable payload storage. |
| [lib/std/zig/AstGen.zig][astgen] | `generate`, `AstRlAnnotate.annotate` | AST lowering constructs ZIR and uses temporary arena storage. |
| [lib/std/zig/Zir.zig][zir] | `Inst`, `extraData`, `Header`, `bodySlice` | Immutable untyped instructions, string bytes, `u32` extra payloads and cache header. |
| [src/Sema.zig][sema] | `resolveConstValue`, `emitBackwardBranch`, inline-call memoization | Type checking, comptime evaluation and AIR production share semantic analysis. |
| [src/Air.zig][air] | `Inst.Ref`, `typeOfIndex`, `mustLower`, `Call` | Typed instruction references, explicit call payloads and an effect-sensitive lowering decision. |
| [src/InternPool.zig][intern] | `Index`, `Key`, `MemoizedCall`, `FuncInstance` | Canonical typed values and specialized functions use indexed identities. |
| [src/Air/Liveness.zig][liveness] | `analyze`, `analyzeBody`, `operandDies`, `getCondBr` | Separate loop/main passes, operand deaths and branch-specific death sets. |
| [src/Zcu.zig][zcu] | `saveZirCache`, `markDependeeOutdated`, `resolveReferences` | Cached lowering plus semantic dependency propagation and analysis-unit reachability. |
| [src/codegen.zig][codegen] | `importBackend`, `AnyMir`, `generateFunction`, `wantsLiveness` | Backend-specific dispatch, legalizing requirements and MIR transport. |
| [src/codegen/llvm.zig][llvm] | `Object.updateFunc`, `Object.emit`, `FuncGen.genBody` | AIR-to-LLVM lowering and separate LLVM object emission. |
| [src/arch/x86_64/CodeGen.zig][x64] | `generate`, `genBody`, `finishAir`, `processDeath`, `airAlloc` | Native instruction selection tracks machine locations and consumes deaths. |
| [src/arch/x86_64/Mir.zig][mir] | `instructions`, `extra`, `frame_locs`, `Inst` | Target MIR postpones offsets and encoding decisions. |

## Pipeline and responsibility boundaries

```text
source -> tokens/AST -> AstGen -> ZIR
                                  |
                           Sema + InternPool
                                  |
                         typed function AIR
                                  |
                    legalization / liveness
                                  |
                 +----------------+----------------+
                 |                                 |
          LLVM IR builder                  native target codegen
                 |                                 |
          LLVM optimization                   target MIR
          and target emission                  Isel / linker
```

This diagram summarizes the inspected contracts; it is not a complete build
driver or a claim that every backend runs identical passes. `wantsLiveness`
explicitly differs by backend: the inspected dispatcher returns false for
stage2 AArch64 and true otherwise. `AnyMir` carries each target's distinct
representation. `generateFunction` takes already-produced AIR and optional
liveness; its comment also acknowledges remaining backend purity bugs.
[Dispatcher contract][codegen]

Parsing preserves externally owned source bytes and stores token starts and
node data in `MultiArrayList` slices. `extra_data` holds additional `u32`
payloads. `parse` reserves estimated capacity before collecting tokens/nodes.
These are compiler-memory decisions, not claims about user object allocation.
[AST representation][ast]

`AstGen.generate` performs result-location annotation before lowering and uses
an arena for temporary work. Result-location preparation belongs here; it does
not establish a general escape analysis or scalar replacement pass.
[AST lowering][astgen]

ZIR stores untyped instructions separately from string bytes and extra words.
Its documented contract lets later successful compilation avoid walking source
tokens, nodes and bytes, apart from diagnostic needs. ZIR is immutable to permit
multiple analyses of the same lowering. Thus syntax lowering can be shared while
different semantic instances retain their own outcomes.
[ZIR boundary][zir]

Sema turns ZIR into AIR while checking types, evaluating comptime control flow
and generating safety checks. A compiletime-known value can become an interned
reference; runtime work remains in AIR. This is semantic staging, not a separate
bytecode interpreter bolted onto an otherwise finished runtime IR.
[Semantic analysis][sema]

## Compact instruction storage and canonical identities

AIR uses another instruction `MultiArrayList` and an extra-word array.
`Inst.Ref` distinguishes instruction results from interned values; `typeOfIndex`
recovers result types using operation contracts and InternPool. `Call` keeps
its variable argument list in extra storage. AIR exposes operations such as
arithmetic, branches, allocation, stores, calls and returns rather than embedding
source expressions that a backend must recognize again.
[Typed instruction representation][air]

InternPool's `Index` denotes a canonical typed value within one pool.
For values of the same type in that pool, index equality supplies value equality.
The pool distinguishes types, aggregates, pointers and function instances.
Namespace types retain declaration/capture identity; they are not all merged by
structural spelling. Variable payloads again use compact extra storage.
[Canonical values and types][intern]

The representation offers three separable ideas for Bend:

1. A stable handle can replace repeated tree comparison after exact checking.
2. A side table can hold variable payloads without enlarging every instruction.
3. A pass can read only the tag column when it does not need full payloads.

These are design possibilities, not measured benefits in Bend's selfhost.
Bend's compiler executes through its own generated representation and affine
data rules. A mutable Zig `MultiArrayList` cannot simply be substituted for a
Bend list, nor does an indexed table eliminate its construction cost.

Keep pool identity explicit. A cached normalized type ID must include the
checked book/image and exact native provenance. It must not equate independent
user constructors merely because their names or field counts match.
Dependent Sigma telescopes still require exact quantities and normalized fields.
Canonicalization should consume these facts after proof, not replace that proof.

## Compiletime evaluation and incremental dependencies

Sema counts backward branches and diagnoses quota exhaustion through
`emitBackwardBranch`. Inline/comptime calls depend on the callee's source hash.
Eligible comptime calls use a memoized function/argument key; arguments that can
mutate comptime state disqualify memoization. A hit charges its stored branch
count, preserving quota accounting. Crucially, the inspected code disables this
memoization under incremental compilation because caller dependencies are not
yet recorded adequately for cached calls.
[Evaluation and memoization restriction][sema]

`MemoizedCall` stores function, argument values, result and branch count in the
pool. It is a compiletime result cache, not a cache of arbitrary runtime calls.
[Memoized value encoding][intern]

Zcu serializes ZIR's header, tags, data, strings and extra words.
Separately, `markDependeeOutdated` and related routines track affected analysis
units, including potentially outdated dependers that may become current again.
`resolveReferences` caches analysis-unit reachability. A syntax cache and a
semantic dependency graph therefore solve different reuse problems.
[Cache and invalidation machinery][zcu]

For Bend, first target repeated proof work within one immutable request.
Per-definition and per-SCC facts can cover normalized formal types, exact erased
arity, native identity, coverage, call targets and admissible layouts.
An explicit `Pending / Refused / Ready` status should stop recursive queries
from reopening unfinished work. A refusal must carry its actual reason.

Only after that bounded cache pays for itself should persistence be considered.
A persistent key needs source, Base, runtime, checked compiler and proof-policy
identities. A changed representation pass must invalidate affected call/layout
facts; stale success flags cannot authorize the new emission.

Do not confuse compile-time invalidation with runtime dependency fencing.
Bend's mutable public `G` bindings, descriptor code/env and native host methods
can change after import. Compiler caches may remain valid while a private worker
must refuse entry. Both dependency domains need explicit ownership and tests.

## Liveness, operand deaths and allocation

Liveness records instruction-result nonuse and each operand's last use.
Four bits per AIR instruction cover the common case; a sparse special table
and extra storage represent larger operands and branch deaths. `analyze` runs
loop analysis followed by main analysis; `analyzeBody` visits instructions in
reverse order. `getCondBr` exposes different deaths for the two branch arms.
This is more precise than one syntactic occurrence count.
[Liveness representation and traversal][liveness]

AIR's `mustLower` keeps required operations even when their result is unused.
Both inspected LLVM and native `genBody` loops skip an unused instruction only
when this additional test permits it. Result nonuse alone cannot discard effects.
[AIR effect gate][air], [LLVM consumer][llvm], [native consumer][x64]

Native x86-64 tracks registers, frame allocations and machine values.
`finishAir` consumes operand deaths through `processDeath`, except operands
reused as the result. `finishAirResult` restores tracking for such reused storage.
`airAlloc` creates a frame-address machine value; it does not necessarily imply
a heap allocation. This is backend location management, not general SROA.
[Native value lifetime handling][x64]

The immediate Bend opportunity is the continuation register vector.
[JW's current contract](../../selfhost/docs/JAVASCRIPT_IR.md) stores nontrivial
results in stable slots and saves the current vector for a non-tail same-SCC call.
A proposed backwards analysis could identify slots live across that call,
with a separate branch-sensitive set at each continuation PC. The parent vector
is currently saved by reference: packing a live subset can add copying or a new
allocation. First distinguish dead-reference retention, physical slot compaction
and child argument-vector allocation rather than assume every save copies slots.

This must include slots referenced inside projections, constructors and primitive
arguments, plus the return destination and all later continuation uses.
Known private calls are explicit `JWDirectCall` instructions in
[worker-model.bend](../../selfhost/src/back/js/ir/worker-model.bend), which gives
the analysis a tractable boundary. Opaque ordinary IR remains outside its proof.

Clearing a dead vector entry could reduce retained memory before slot reuse.
Physical slot coalescing is a second experiment: it also changes restoration,
branch joins and parallel assignment. Capture all tail-call arguments before any
write, and give nested continuation frames separate ownership.

Neither last use nor affine source quantity proves that an object is unaliased.
Retained public results, nested fields and Error reentry can still observe it.
Keep tuple-shell freshness and private graph ownership proofs separate from
slot death. Test old-field RHS reuse, nested aliases and deep exhausted-budget
calls before attributing any allocation gain to liveness.

## Which backend does which optimization?

The LLVM backend builds LLVM IR, carries function attributes and uses liveness
to avoid unnecessary lowering. `Object.emit` creates a target machine and passes
optimization/safety/size options into LLVM emission. Debug selects codegen level
None; other modes select Aggressive at this interface. Broad LLVM transformations
and register allocation are downstream responsibilities. This source inspection
does not identify a Zig AIR pass implementing LLVM's SROA, loop vectorization or
whole-module optimization, and does not credit those to AstGen or Liveness.
[LLVM emission boundary][llvm]

Native x86-64 generates its own target MIR and handles register/frame locations.
The pinned `airCall` explicitly rejects `always_tail` calls as unimplemented.
This concrete limitation prevents assuming equal feature coverage across backends.
[Native call implementation][x64]

MIR's stated purpose includes deferring offsets until instruction selection so
smaller jump encodings can be chosen. Its storage includes instructions, extra
data and frame locations. This is target-specific encoding work, not a reusable
JavaScript optimizer or a proof that machine code is always faster.
[x86-64 MIR contract][mir]

For Bend's JS backend, the host JIT supplies final machine optimization, but it
cannot recover erased semantic permissions for public getters and descriptors.
Bend must first expose proven positional calls and representations without
changing observable demand, mutation fallback or errors. Backend selection and
profitability remain distinct from legality.

## Scoped transfer experiments and rejection criteria

| Proposal | Small first test | Benefit hypothesis | Reject or narrow if |
| --- | --- | --- | --- |
| Immutable per-request proof fact table | Count normalized-type and graph queries on one mixed program; preserve emission exactly. | Fewer repeated traversals and compiler allocations. | Table construction/memory costs exceed eliminated work, or refusal/selection changes. |
| Explicit worker operation effects | Classify private operations, retaining unknown/global/native demand. | Enable safe nonuse removal without hidden source scans. | An error, getter, dependency or evaluation order changes. |
| Continuation live-slot sets | Emit only diagnosed live frame entries, initially without coalescing. | Smaller saved vectors and less retained data. | Deep/branch/reentry restoration differs or selected workers fail to activate. |
| Canonical checked layout/type handles | Cache exact normalized layouts inside one book. | Cheaper equality and less repeated layout reconstruction. | Native/quantity/telescope distinctions merge or compilation regresses. |
| Separate backend consumption contract | Freeze call/effect/layout facts before emission. | Contain planner/emitter cycles and make costs attributable. | New hidden queries or duplicate proof families remain necessary. |

These experiments need separate compiler-request, emitted-size, runtime and
allocation measurements. Cold full compilation and repeated incremental edits
are different workloads. A faster compiler backend can produce slower programs;
a stronger optimizer can improve programs while increasing compilation cost.
No cross-language throughput number follows from this source study.

Do not copy the entire Zig pipeline merely to gain its names.
Do not introduce LLVM or a mutable global intern pool without a measured target.
Do not use comptime result caching for dynamic Bend public globals.
Do not replace ownership/escape proofs with last-use bits.
Do not treat packed arrays as automatically cheaper in the selfhost runtime.
Do not remove stronger existing selectors because a general backend is cleaner.
Do not infer universal backend equivalence from one successful native target.

The first useful experiment is an unchanged-emission proof-query inventory.
It can establish whether fact construction removes actual repeated work before
changing user execution. Continuation liveness is the separate allocation probe.
Both should retain bounded refusal and the existing public mutation boundary.

[tag]: https://api.github.com/repos/ziglang/zig/git/tags/3eac10ac2933d96a71a90a1424659238169d5f28
[commit-patch]: https://github.com/ziglang/zig/commit/e4cbd752c8c05f131051f8c873cff7823177d7d3.patch
[ast]: https://github.com/ziglang/zig/blob/e4cbd752c8c05f131051f8c873cff7823177d7d3/lib/std/zig/Ast.zig
[astgen]: https://github.com/ziglang/zig/blob/e4cbd752c8c05f131051f8c873cff7823177d7d3/lib/std/zig/AstGen.zig
[zir]: https://github.com/ziglang/zig/blob/e4cbd752c8c05f131051f8c873cff7823177d7d3/lib/std/zig/Zir.zig
[sema]: https://github.com/ziglang/zig/blob/e4cbd752c8c05f131051f8c873cff7823177d7d3/src/Sema.zig
[air]: https://github.com/ziglang/zig/blob/e4cbd752c8c05f131051f8c873cff7823177d7d3/src/Air.zig
[intern]: https://github.com/ziglang/zig/blob/e4cbd752c8c05f131051f8c873cff7823177d7d3/src/InternPool.zig
[liveness]: https://github.com/ziglang/zig/blob/e4cbd752c8c05f131051f8c873cff7823177d7d3/src/Air/Liveness.zig
[zcu]: https://github.com/ziglang/zig/blob/e4cbd752c8c05f131051f8c873cff7823177d7d3/src/Zcu.zig
[codegen]: https://github.com/ziglang/zig/blob/e4cbd752c8c05f131051f8c873cff7823177d7d3/src/codegen.zig
[llvm]: https://github.com/ziglang/zig/blob/e4cbd752c8c05f131051f8c873cff7823177d7d3/src/codegen/llvm.zig
[x64]: https://github.com/ziglang/zig/blob/e4cbd752c8c05f131051f8c873cff7823177d7d3/src/arch/x86_64/CodeGen.zig
[mir]: https://github.com/ziglang/zig/blob/e4cbd752c8c05f131051f8c873cff7823177d7d3/src/arch/x86_64/Mir.zig
