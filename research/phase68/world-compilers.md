# Phase68: transferable compiler mechanisms for native parity

Research date: 2026-10-08. Source/data investigation only; no compiler or target
was executed and no production source was changed in this lane. Local source
was inspected at Phase68 start HEAD `b6eb5751f9bd460acfb7858b0ae8908e9335b6a0`,
with upstream `059266225b77c8ca256ac6b25ee5c21449bab151`. Subsequent Phase68
implementation and measurements must identify their own snapshots.

**Recommendation:** first broaden proved direct saturation through matches,
then forward freshly constructed result fields without boxing. Remove duplicate
ordinary entries when use information proves them unnecessary. A typed direct-C
worker lane is the next structural step if these leave substantial scheduler
traffic; a wholesale LLVM/SSA rewrite is not a prerequisite.

The reported 10.41× native gap is the finite six-family Phase67 result, not a
forecast for these proposals. No external compiler's speedup is transferred to
Bend. The source-backed claim is that these mechanisms can remove specific
operations that the current native lowering still introduces.

## Existing research and what this pass adds

Read together with the [seven-compiler survey](../compilers_architecture_and_techniques/README.md),
[remaining opportunities](../../docs/remaining_opportunities/README.md),
[comparison](../../docs/remaining_opportunities/comparison.md), and
[Phase67 report](../../implementation/phase67/README.md). The earlier priorities
mostly concern JS/JW. This note reevaluates the mechanisms against the native
word/segment ABI and the now much smaller JS performance gap. It does not label
inlining, closure conversion, arity specialization or scalar replacement new.

The existing Rust, Zig and Lean chapters pin exact compiler revisions. Those
remain historical source studies, not fresh reads of a latest release. Fresh
web inspection here used the official Go source browser, OCaml 5.5 manual,
Lean API/source documentation, GHC 9.15 development API/source documentation,
and LLVM/MLIR development source browsers. Floating pages are explanatory
evidence, not reproducible build inputs. Selected raw GitHub lookups failed
with cache misses and sandbox DNS was unavailable; no claim below depends on
the failed downloads. No external repository was cloned or compiler built.

## The actual local obstacles

| Native location | Inspected behavior | Consequence and proposed discriminator |
| --- | --- | --- |
| [`direct.bend`](../../selfhost/src/back/native/direct.bend), `nd_leading`, `nd_arity`, `nd_app` | Counts leading lambdas and annotations; exact saturated references use `NCall`; partial/unknown calls use the closure path. `Mat` is not counted. | A function whose branches return lambdas can have more usable arity than the current direct entry. Count dynamic intermediate closure creation in those helpers. |
| [`book.bend`](../../selfhost/src/back/native/book.bend), `nc_compile_def`; `direct.bend`, `nd_extend` | Lowers the ordinary body and additionally lowers a direct body when leading parameters exist. | Both implementations are emitted even if every use needs only one. Count ordinary-only/direct-only/both uses before attempting removal. |
| [`bridge.bend`](../../selfhost/src/back/native/bridge.bend), `nc_let`, `nc_let_cut` | Evaluated word/scalar atoms stay in the current segment. Other let values create a continuation and save live bindings. | Constructor creation, array result transport and direct calls still cross segment boundaries. Removing a box alone may leave most control overhead. |
| [`emit.bend`](../../selfhost/src/back/native/emit.bend), `ne_constructor`, `ne_closure`, `ne_jump`, `ne_ret` | General constructors/closures allocate runtime heap cells; direct calls still become register writes plus `WL_JMP`. | A native “direct” entry is not yet a direct C call. Separate closure-count, frame-count and dispatch-count reductions. |
| [`ir.bend`](../../selfhost/src/back/native/ir.bend), `N_Segment`; [`layout.bend`](../../selfhost/src/back/native/layout.bend) | The body is C text; each binding is one word; general values are boxed. Result counts exist, but lowering ordinarily produces one result word. | General scalar replacement cannot operate on explicit uses after text emission. A small structured value/result product before emission is the useful seam. |
| `bridge.bend`, `nc_live_env`, `nc_share_env`, `nc_drop_dead` | Repeatedly scans subterms per binding with `nc_occurs`. | A shared use summary could reduce emitter work, but it needs a measured consumer and must preserve branch/capture semantics. |

The upstream lane independently identified array `fold.loop`, `fold.cell` and
`fold.step` as concrete arity-through-match opportunities. Its detailed report
owns those generated-output observations. Local upstream source confirms
`def_raise` in [`bend2/comp.ts`](../../bend2/comp.ts) traverses match branches and
takes their minimum; `emit_native` builds ordinary C functions, and `emit_fuse`
passes flat result words through a local output array. These are distinct
mechanisms: arity coverage, direct C calling and flat representation must not
be credited as one change.

## 1. Direct call workers with explicit captures

Go's `directClosureCall` in
[`cmd/compile/internal/walk/closure.go`](https://go.dev/src/cmd/compile/internal/walk/closure.go)
rewrites an immediately called literal closure into a normal function call,
prepending captured values or captured addresses to the arguments. It updates
the function signature and call type, then queues the function for compilation.
`walkClosure` retains closure construction for other uses. This is a concrete
example of eliminating a closure object without requiring its body to be
inlined.

OCaml Flambda separately describes closure-variable unboxing and a
**direct call surrogate**: selected direct callers use explicit extra arguments,
while indirect callers can retain the original closure convention. The manual
also cautions that wrapper crossings and code duplication can erase the gain.
This supports a private fast signature plus a compatibility entry, with a
profitability rule rather than unconditional duplication.
[OCaml 5.5, sections 24.9.1–24.9.3](https://ocaml.org/manual/5.5/flambda.html)

**Transfer to Bend.** Existing literal-lambda beta reduction and top-level
leading-lambda saturation already cover the easiest cases. The next useful
coverage is (a) arity made available after a match and (b) a local known closure
bound to a name and then called. Thread a target identity and evaluated capture
words into the existing direct entry, materializing a closure only for unknown
or escaping uses. Use the same target/capture fact for JS and native admission;
let their backends choose representations.

**Legality boundary.** A full call must not evaluate later arguments before an
earlier matcher/prefix that previously consumed data, failed or performed an
effect. Partial application must retain its original demand point. An unknown
target, heterogeneous branch arity, foreign entry or bang/scheduling boundary
is a conservative refusal. Preserve capture ownership separately from target
identity; proving a function target does not prove its environment unique.

**First implementation slice.** Match-aware private arity with an ordinary
entry retained, confined to explicit safe source forms, is smaller than general
closure transport. Validate different branch shapes, unused fields, sharing,
partial and oversaturated applications, and error/effect order. A generic
known-local-function pass is the subsequent slice.

## 2. Scalar replacement before the runtime heap ABI

LLVM's [`SROA.cpp`](https://llvm.org/doxygen/SROA_8cpp_source.html) analyzes
aggregate `alloca` uses, splits promotable regions and promotes scalar regions
into SSA values. Its analysis requires enough knowledge of the allocation's
uses; merely choosing an optimizing C compiler does not establish those facts.
This is the important boundary here: Bend's `heap_alloc`, `rfc_seal`,
`ctr_take` and cross-segment register/stack traffic are a runtime heap protocol,
not a plainly nonescaping local C struct.

The prior [Rust source study](../compilers_architecture_and_techniques/rust.md)
similarly inspected MIR `escaping_locals`, `compute_flattening` and replacement
of eligible aggregate locals by field locals. The official
[SROA API](https://doc.rust-lang.org/beta/nightly-rustc/rustc_mir_transform/sroa/index.html)
names these separate analysis and rewrite stages. Its language-specific borrow
and address-escape rules are not Bend ownership rules.

**Transfer to Bend.** At the checked/erased term boundary, record a fresh
constructor's evaluated fields. If all uses are local projections or a known
matching continuation, substitute field words and omit the shell. The first
slice can recognize a single consuming match; it does not require alias analysis
for arbitrary heap objects. For array operations returning an array plus value,
forward the two result words to the consuming continuation directly.

**Legality boundary.** Every field computation still occurs once and in order,
including unused fields that may fail. Removing the shell also removes its
sealing/taking actions, so the replacement must prove equivalent child ownership
and disposal. Do not rewrite a preexisting shared constructor as though it were
fresh. Escaping, aliased, identity-observed or unknown-consumer values retain
materialization. Array-handle ownership and array payload mutation remain
separate from the temporary pair shell.

**Discriminator.** Count heap allocations and corresponding take/free operations
on an immediate pair/match witness, with a control that returns the pair and a
control that shares a field. Then inspect real arrays, trees and Map helpers.
Reject a general SROA framework if the narrow operation is rare or runtime
traffic simply moves to continuations.

## 3. Multiple-result workers, boxing only at boundaries

GHC's
[`mkWwBodies`](https://ghc.gitlab.haskell.org/ghc/doc/libraries/ghc-9.15-inplace/GHC-Core-Opt-WorkWrap-Utils.html)
uses argument-demand and constructed-product-result information to build a
worker/wrapper pair. A private worker can accept unboxed fields and return
product fields in an unboxed tuple; the wrapper reconstructs the ordinary
result when needed. `DontUnbox`, `DoUnbox` and `DropAbsent` make the representation
decision explicit. GHC's laziness and demand proofs differ from Bend's; the
transfer is the private ABI structure, not those proofs.

**Transfer to Bend.** Generalize native result layout to a bounded vector of
words, beginning with an internal two-field product consumed immediately.
Carry the result width and field ownership into continuation parameters and
`WL_RETN(n)`, which the emitter already supports. A future C worker may return
through a local result struct or output fields, leaving Clang to choose machine
registers. Do not claim that a C output array guarantees register returns.

The ordinary one-word wrapper boxes when a value crosses into unknown closure
application, foreign code, general readback or storage. Memoize a worker by
definition/instantiation, argument representation and result representation;
do not create a distinct body for each caller. This is broader than an
Array-only peephole and can serve tuple-producing helpers in trees, Maps and
compiler code.

**Risk.** Cross-SCC result agreement, erased/dependent fields, register width,
parallel joins and CPU/device ABI must agree. Begin within one proved private
region; keep the scheduler boundary unchanged elsewhere.

## 4. Local continuations as joins; direct C functions as a separate tier

GHC's
[`Core` join-point invariants](https://ghc.gitlab.haskell.org/ghc/doc/libraries/ghc-9.15-inplace/src/GHC.Core.html)
require tail uses at a consistent join arity and constrain recursive groups.
Such a local continuation can be treated as control flow instead of a general
function value. Arity of the returned function and join arity are explicitly
different; the source illustrates a join that takes one argument but returns
another lambda. This is a useful warning against conflating arity raising with
join conversion.

Lean's
[`LCNF.Simp.inlineApp?`](https://lean-lang.org/doc/api/Lean/Compiler/LCNF/Simp/Main.html)
simplifies an inlined body before attaching its continuation. Its source
documentation records exponential growth from an earlier order that attached
the continuation first. This matters both to emitted C size and compiler speed.

**Transfer to Bend.** A structured local join can represent the suffix after a
non-tail operation and accept result fields without a heap closure. In a proved
sequential direct-C worker, emit a label/branch or normal local statement flow;
tail recursion becomes a loop. Do not replace scheduler frames with C recursion
wholesale: deep recursion, forks, effect suspension and device dispatch retain
their existing protocol unless separately admitted.

For small nonrecursive helpers, bounded inlining can expose constructor/match
cancellation first. Use a strict size/duplication budget, simplify before
attaching the caller suffix, and share branch continuations rather than copying
the entire suffix into every arm. Large helpers should benefit from direct C
calls without requiring inlining. These choices attack both runtime dispatch
and the reported large emitted C, but their benefit remains unmeasured.

## 5. Share semantic analysis; keep target ABI policy explicit

MLIR's
[`computeDestructuringInfo` and `destructureSlot`](https://mlir.llvm.org/doxygen/SROA_8cpp_source.html)
separate eligibility analysis from rewriting. Operations expose whether a use
can be rewired; blocking uses must be removable before destructuring proceeds.
The algorithm collects used subfields and rewrites supported users, rather
than hard-coding a single dialect's textual spelling. Its
[LLVM memory-slot adapter](https://mlir.llvm.org/doxygen/LLVMMemorySlot_8cpp_source.html)
supplies the concrete allocation/field behavior. This is a practical model
for shared analysis with backend-specific consumers.

The [Zig study](../compilers_architecture_and_techniques/zig.md) already records
typed AIR, shared semantic identities and target-specific lowering/liveness
contracts. Re-reading a broad Zig survey would add less than applying that
separation to the current Bend seams.

**Transfer to Bend.** Extract small backend-neutral products from existing
checked facts: runtime arity/demand boundaries, known target/captures, use/escape
summary, constructor shape, and operation effects. JS workers and native
lowering can consume those products. Their concrete public representations,
guard policies, failure hooks and ownership operations remain distinct.
`JWValue`/`JWInstruction` already expose constructs, projections, calls, cases
and returns; `N_Segment.body` does not. Reuse the facts and algorithms first,
then move a bounded native region onto structured operations when a measured
consumer needs them. Do not create a third parallel collection of arity, field
and liveness walkers merely to call it a common IR.

For compiler speed, compute use information once per immutable body and make
lowering query it. Current `nc_live_env`/`nc_drop_dead`/`nc_share_env` repeatedly
call occurrence scans; this is an identifiable work-reduction hypothesis.
However, the existing compiler-latency work found that broad caching can cost
more than repeated computation. Preserve book/instance/provenance identity,
measure summary construction and use counts, and do not forecast a B1/B2 gain
from fewer source traversals alone.

## 6. Ownership-aware reuse comes after transport removal

Lean's
[`IR.ResetReuse`](https://lean-lang.org/doc/api/Lean/Compiler/IR/ResetReuse.html)
inserts reset/reuse before explicit reference-count operations. It tracks
already-reset objects to prevent double reset, includes join-point liveness,
and tries same-constructor reuse before relaxed layout-compatible reuse. The
documentation also identifies an implementation choice that avoids repeated
suffix scanning and quadratic behavior.

**Transfer to Bend.** Native Bend has actual keep/seal/take/sink machinery, so
the runtime analogy is closer than it was in the JS survey. Nevertheless,
uniqueness, scheduler sharing and allocator class compatibility must come from
Bend's protocol. Prefer removing a fresh transport object entirely before
adding reuse for it. A later borrow/reuse pass can consume the same precise
liveness and ownership summaries; a whole-runtime RC redesign is not indicated.

## Ranked implementation slices and costs

These are engineering estimates for one experienced implementer with the
existing checked-B1 loop. They exclude full release qualification, waiting for
target access, and unexpected conformance failures. Confidence describes the
existence of the source-level opportunity, not a runtime multiplier.

| Priority | Concrete slice | First falsification | Estimated implementation effort | Confidence / principal risk |
| --- | --- | --- | --- | --- |
| 1 | Match-aware direct arity with ordinary fallback | Intermediate closures/dispatch remain in the identified array loop, or demand-order control differs | 2–6 h for a restricted candidate and focused controls | High opportunity; medium cost confidence; source demand and consuming matches |
| 2 | Fresh constructor → immediate match forwarding; then two-word primitive result | Alloc/take/frame counts do not fall, or boxed/escaping control changes | 4–12 h narrow slice; 1–3 days for composable result ABI | High opportunity; medium cost confidence; child ownership and result width |
| 3 | Use-directed ordinary/direct entry emission | Closed direct-only witnesses still need hidden ordinary references | 3–8 h, including reachability/partial-call controls | High duplication evidence; medium cost confidence; function IDs and implicit references |
| 4 | Known local closure target plus explicit captures | Factory/helper transport cannot retain ordered captures cheaply | 1–3 days bounded local scope | Medium; specializations and ownership can expand scope |
| 5 | Typed C workers with local joins and bounded inline cleanup | Scheduler/stack transitions dominate even inside admitted region, or code grows | 2–5 days first scalar/product region; longer for broad runtime coverage | High structural relevance; low estimate confidence; stack/effects/device ABI |
| Supporting | Shared arity/use/effect products with one JS and native consumer | Product building costs more than removed scans, or duplicates an existing product | 1–3 days incremental extraction | Medium; migration cost and cache identity |
| Later | Borrow/reset/reuse using native ownership facts | No significant hot keep/seal/take traffic survives earlier changes | 3–7 days for a narrow ownership-proved family | Medium relevance; low effort confidence; scheduler aliasing |

Use separate ablations for each slice. The core counters are emitted and
executed closures, constructors, frames, dispatches, ordinary/direct entries,
generated C bytes, Clang time, compiler emission time and executable time.
Count static occurrences only as opportunity evidence; they are not dynamic
cost estimates. A compiler speed result requires B1/B2 timing with their actual
images, and a native-only change does not establish a JS speed gain.

The useful order is **recover arity/target facts → forward scalar fields →
remove dead entries/transport → use direct C control where admitted**. This
composes mechanisms already demonstrated by upstream and the cited compilers,
while keeping each hypothesis small enough to reject on concrete evidence.
