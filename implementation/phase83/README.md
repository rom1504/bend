# Phase83: deeper compilation investigation

Three research agents investigated pipeline work, native representations and the
B1/B2 gap. Root ran bounded serial diagnostics and integrated the results.
[Design](../../design/phase83/compilation-work-investigation.md) ·
[research collection](../../research/compilers_architecture_and_techniques/phase83/README.md) ·
[reproducible methods](../../selfhost/tools/performance/phase83/README.md).

**The strongest new finding is expensive construction of rejected workers.**
Map builds ordinary/product workers that cannot be admitted because of non-tail
recursion or unavailable dependencies. Their construction consumes379 ms in one
instrumented request. Four recursive helpers alone account for304 ms across12
attempts. The final renderer discards their C bodies.

This is a better-supported first prototype than adding another IR or cache.
It is workload dependent: the simple many-function case admits every worker.
No single measured mechanism yet supplies the25% general B2 time reduction
needed for parity. The purpose of this phase was investigation; **production
source, installed compiler and qualified performance metrics are unchanged**.

## Baseline and measurement boundary

Baseline commit `8042809`, selected Phase82 compiler04:

- Checked B1 `8a4007259794bdf0bca9616bc106423f227436013442e9a9ced78659bf6f374c`.
- Genuine B2 `098320e8f3e40894156790d740ad205e386f375195b3c6741d67cca96e94e092`.
- Upstream `059266225b77c8ca256ac6b25ee5c21449bab151`.

The qualified three-source ratios remain **1.673× B1 /1.328× B2** upstream.
These measure JS-hosted Bend-to-C requests including loading, checking, ordinary
reporting on the Bend side, and emission. Compiler imports, explicit prepared
Bend Base, Clang and native execution are separate. The inherited upstream
compilation comparator loads/checks Base and emits C but does not invoke its CLI
proof-report helper. The separate frontend experiment below includes that helper
on both sides; report-contract differences must not be hidden.

Current compiled-C execution evidence remains the earlier1.067× upstream result,
preserved through exact emitted bytes. This phase does not remeasure runtime.
Production remains32,540 physical Bend lines/132 modules. Existing conformance
limits, including thirteen broader native API gaps, are unchanged.

## Broader compilation sample

We selected eight existing, previously validated sources: the established
numeric/array/lexer trio; closures, maps and expression ADTs; and non-IO small
and65-function held-outs. This expands compilation diversity without claiming
all-language coverage. Several larger cases share IO/library loading, so they
are not eight independent frontend architectures. The48 clean requests rotate
B1/B2/upstream order over two rounds, with a fresh process per request.

| Source | B1 ms | B2 ms | Upstream ms | B1/upstream | B2/upstream |
|---|---:|---:|---:|---:|---:|
| Numeric |1222.5|973.3|747.9|1.635|1.301|
| Array |1271.5|986.1|768.4|1.655|1.283|
| Lexer |1778.8|1330.0|968.2|1.837|1.374|
| Closures |1254.5|1011.1|733.5|1.710|1.378|
| Map |2731.5|1889.5|1256.0|2.175|1.504|
| Expression |1292.6|1074.0|746.9|1.731|1.438|
| Small |286.0|275.0|332.3|0.861|0.828|
| Functions65 |687.0|599.1|402.7|1.706|1.488|

Values are two-sample medians, not confidence intervals. The three-source
geometric means here are1.707×/1.319×. The compiler did not change: differences
from Phase82 are run variability, not optimization gains. Keep held-outs and
this exploratory expansion separate from the qualified headline.
[All samples and identities](measurements.json).

## Finding1: generate less code that will be rejected

A disposable B2 derivative wraps existing internal boundaries without changing
their algorithms. All four requests reproduce their complete original C.
It records actual ordinary/product candidate results and final plan readiness.

| Input | Final workers /ready | Construction for ready names | Construction for unready names | Unready final C body units |
|---|---:|---:|---:|---:|
| Numeric |41/16|56.3 ms|36.1 ms|47,873|
| Map |104/36|38.0 ms|379.4 ms|717,818|
| Small |2/2|8.6 ms|0 ms|0|
| Functions65 |66/66|32.6 ms|0 ms|0|

Body units are JavaScript UTF-16 string length, not allocation bytes. Timing
includes analysis and diagnostic overhead; it is an upper bound on potentially
removable work, not a measured speedup. Recursive/inclusive region clocks must
not be summed. Final worker counts differ from construction counts because
ordinary retries create additional attempts.

Map's13 constructions with a non-tail-self-call error cost179.9 ms. An additional
198.0 ms constructs locally valid candidates whose dependencies prevent admission.
`Map.pop.go`, `Map.seek.go`, `Map.ins.go` and `Map.put.go` account for304.1 ms across
12 ordinary/product/retry constructions. This names observed sources, **not
proposed name-based special cases**. The compiler change must recognize the
general runtime control-flow property.

Admission itself costs only1.97 ms; replacing its list scans with a worklist
would miss the main problem. Seventeen ordinary retries cost84.1 ms, nested
inside candidate construction. Phase78 already skips unaffected retries.

The agent audited later observer integration: it admits fresh, collision-free
observer workers, not previously unready ordinary/product workers. Final
`nf_bodies` and `nf_prototypes` filter by readiness. Their discarded C is real;
their names, dependency facts and refusal metadata may still be needed.
[Raw region summary](regions.json) · [candidate attribution](candidate-fate.json) ·
[source-level fate audit](../../research/compilers_architecture_and_techniques/phase83/representation-replacement.md).

**Next discriminator:** prove definite non-tail refusal on compact runtime
syntax before constructing strings, preserving ordinary/product routing and
fallback for unknown cases. Then propagate proven dependency refusal. Avoid a
second approximate lowerer: use shared decisions and preserve current error,
quantity, tail-context and ownership semantics. A general delayed-rendering
builder is the larger follow-up if a conservative preflight cannot capture the
cost. Exact C is the first acceptance gate.

## Finding2: B1 control flow is costly; B2 allocation volume is already lower

Current Numeric sampled allocation, including collected objects:

| Compiler | Allocated MB, decimal |
|---|---:|
| B1 |456.98|
| B2 |100.80|
| Upstream |145.45|

This is one allocation sample per role, not RSS or a complete workload census.
It contradicts total allocation volume as a sufficient explanation for B2's
remaining latency gap. Work per traversal, generated code and cold execution
still matter; fewer bytes alone need not make a compiler faster.

B1's generated function bodies contain4,234 `run_tail` call sites and8,453 arrow
tokens; B2 has8 and664. The scanner excludes strings/comments and runtime/export
wrappers. In `index_find`, B1 repeatedly constructs selected closures and tail
packets; B2 uses branches inside its SCC loop. Current B1 named plus lexically
attributed anonymous `index_find` allocation is about70 MB, versus4.36 MB in the
B2 SCC sample. Attribution/inlining differences prevent exact subtraction.

The tempting broad rewrite was already tried: expanding160 branch helpers in
Phase78 gave only about3% benefit with substantial source growth. Test one hot
helper's actual cost before repeating it. A copied-image diagnostic can estimate
the mechanism's ceiling, but would not be a releasable Bend implementation.
Any accepted optimization must be expressed in the Bend compiler or its checked
bootstrap workflow; modifying upstream `bend.ts` is outside scope.
[Allocation/CPU evidence](profiles.json) ·
[generated-code audit and research](../../research/compilers_architecture_and_techniques/phase83/stage-gap.md).

## Finding3: frontend size is confounded by cold execution

An additional sweep generates8/32/65/128 chained scalar definitions. N=65 is
byte-identical to the existing Functions65 fixture. Each role/source gets one
fresh process and three ordinary check/report calls, with no persistent
inspector or new semantic cache. Both sides run their proof-report algorithm.

| Definitions | B2 first /third request | Upstream first /third request |
|---|---:|---:|
|8|171/93 ms|331/296 ms|
|32|283/86 ms|333/261 ms|
|65|351/136 ms|371/313 ms|
|128|453/175 ms|344/278 ms|

At65 definitions, B2 source completion falls144→45 ms, checking82→24 ms and
reporting39→12 ms. This establishes substantial warm-process sensitivity.
It does not isolate V8 tiering from allocation/GC, module or operating-system
state; three calls are not a steady-state benchmark. Nor does it demonstrate
quadratic parsing. Upstream still checks Base each call, while Bend uses its
explicit prepared Base; these are not equal amounts of frontend work.

The65-function B2 check-only first request is already slightly faster than
upstream's, despite its larger native-compilation gap. Native preparation and
planning therefore remain necessary targets. More compact generated frontend
control flow could still create headroom, but should be investigated with
logical visit counts and V8 tier traces before rewriting the parser.
[Frontend observations](frontend.json) ·
[pipeline investigation](../../research/compilers_architecture_and_techniques/phase83/pipeline-comparison.md).

## What other compiler implementations teach us

The three agents refreshed primary sources rather than building external
compilers. Their research documents link source/documentation and distinguish
moving pages from immutable pins. No published speed multiplier is transferred
to Bend.

- **Zig AIR/liveness:** per-function runtime products with explicit consumers;
  retain a separate traversal when the required analysis order differs.
- **Cranelift SSA builder:** collect necessary facts while constructing the
  representation their consumers use. Explicit completion boundaries matter.
  The associated SSA paper also warns that fewer intermediate instructions need
  not yield proportional total compiler savings.
- **Go:** demand-driven body decoding and restrained retained summaries;
  repeating eager library-product caching would ignore our Phase79 failure.
- **LLVM:** own/invalidate analyses at the right scope; avoid whole-module work
  hidden inside every function pass. Group related work without duplicating it.
- **Lean/Flambda2:** erase type complexity at the runtime boundary and represent
  control continuations as jumps rather than allocated ordinary functions.
- **V8:** representation and specialization during construction influence
  traversal and execution cost. Profile cold generated compiler code as well as
  the algorithms it implements.

Our existing request already retains erased bodies, arities and compact/static
bodies. Observers deliberately retain the original erased body. A real native
producer replacement must remove `Ann` construction, annotated-book merging and
subsequent semantic reinterpretation, while supplying the layout/scalar/observer
permissions those consumers need. Another retained graph does not achieve that.

## Ranked next experiments

Percentages below mean reductions in complete request time, conditional on the
hypothesis. They are not measured gains and cannot be added. Effort estimates
include implementation and focused validation; broad integration may uncover
additional semantic work.

| Priority | Experiment | Gain hypothesis | Prototype /integration | Risk |
|---|---|---|---|---|
|1|Prove definite worker refusal before C construction; propagate refused dependencies|B2 Map8–15%, Numeric1–3%, zero on fully admitted cases; B1 benefit unmeasured|2–4h /6–12h|Medium: tail context and product route differ; unknown cases must fall back.|
|2|Isolate B1 hot helper control flow, starting with index lookup|3–8% B1 as a falsification target, negligible direct B2 gain|45–90min diagnostic /3–6h if source change stays small|Medium: prior broad expansion disappointed; source complexity can erase value.|
|3|One dependency/report graph and exact-world metadata|2–5% B1/B2, workload dependent|1–2h /3–6h|Low–medium: unsafe roots, recursion and source-order diagnostics.|
|4|Measure cold generated frontend code shape, then simplify a proven hot region|Gain unknown; require≥5% complete-request evidence before expansion|1–2h attribution; implementation estimate follows finding|Medium: warmth is not pure JIT attribution; code growth can worsen startup.|
|5|Replace native annotation/layout/erasure producer and its consumers|4–12% B2 on annotation-heavy cases; smaller elsewhere|2–4h narrow pilot /12–24h broad integration|High: permissions, dependent erasure and original observer shape.|
|6|Broader operation representation plus shared consumer analyses|8–20% B2 remains an unproved target; regression possible|4–8h credible pilot /24–40h migration|High: adding another framework instead of removing old work.|

The first prototype should cover both positive and negative cases: Map-like
non-tail recursive trees, cheap rejected dynamic calls, tail-recursive accepted
workers, product fallback, Numeric and Functions65. Test generated-C identity
before widening the experiment. Keep a five-source short loop, then the broader
eight-source screen; use full conformance/selfhosting/runtime gates only for a
selected production candidate.

Parity remains plausible as a target, but this investigation does not justify
promising a25% general gain from one rewrite. Reaching0.5× would require roughly
62% less current B2 request time; none of these measurements establishes that.

## Validation, efficiency and preserved evidence

There were48 clean requests,16 CPU profiles,3 allocation profiles and4 internal
region requests: **71 complete C outputs matched their prior per-role oracles**.
Eight frontend processes accepted all24 generated check/report requests.
Three Base preparations plus those jobs total82 guarded executions, **253.6 s
of target occupancy**, peak aggregate RSS488.5 MiB and at least25.67 GiB available.
No OOM, timeout, nonzero target exit, compiler build or native executable run.

The three agents owned separate research files; root alone ran target jobs.
Target time excludes analysis, browsing, offline profile processing and writing.
No inference about consumed Codex quota is made. Unrelated inherited Phase6/68
files were preserved, and no PR comment was posted.

[Resources and counts](resources.json) · [survey qualification](qualification.json) ·
[evidence archive](evidence.json). The archive preserves all new raw artifacts;
its parent inputs remain bound to existing Phase81/82 and earlier evidence.
No compiler promotion or new broad conformance claim is made.
