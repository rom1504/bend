# Remaining opportunities after the architecture survey

Date: 2026-10-04. Baseline: installed Phase45 worker23, repository `55e5b79`.
**Recommendation: build a small shared value/use/effect foundation in JW, then
test selective private inlining followed by aggregate elimination. In parallel,
prepare known-function transport as the next coverage expansion.**

This is a research conclusion and proposed sequence, not a new implementation or
measured speedup. The supporting documents are the
[current architecture](../self_hosted/architecture.md),
[optimization inventory](../self_hosted/optimization-inventory.md),
[prior-work audit](../self_hosted/prior-experiments.md),
[seven compiler studies](../../research/compilers_architecture_and_techniques/README.md),
[comparison matrix](comparison.md) and [experiment plan](experiment-plan.md).

## What changed our recommendation

We have already implemented many useful techniques in narrower paths. General
first-order workers, exact SCCs, tail loops, private native representations,
bounded inlining, selected closure/callback lowering and fusion all exist.
An additional feature-name checklist would therefore overstate novelty.

The bigger gap is **shared information and composition**. Current JW exposes
calls and values but lacks reusable use/escape/effect analysis. Its small
simplifier does not perform general constructor-use elimination, interprocedural
value propagation or liveness-driven cleanup. These capabilities could serve
several program families and eventually replace overlapping recognizers.

The external sources reinforce this conclusion:

- Rust and LLVM place aggregate/value cleanup after enabling transformations.
- Go interleaves target discovery and inlining rather than making one isolated
  decision about every call before any transformation runs.
- Lean keeps local function and continuation structure visible, and simplifies
  an inlined body before attaching a continuation to avoid explosive duplication.
- Zig exposes effects and operand lifetimes rather than treating unused results
  as permission to omit evaluation.
- V8 can eliminate allocations itself when generated structure permits it;
  our pass needs to target surviving semantic obstacles, not merely fewer AST nodes.

These are source-based inferences from the linked studies, not measured Bend gains.

## Priorities, benefits and costs

Speed ranges below are **hypotheses on affected programs**, relative to selected23.
A workload without the relevant executed opportunity gains zero; regressions are
possible. The estimates overlap and must not be multiplied. Effort assumes a
focused implementation with existing infrastructure; public-boundary discoveries
can extend it. “Probe” excludes release qualification.

| ID | Opportunity | Expected benefit hypothesis | First probe / implementation effort | Risk and confidence |
| --- | --- | --- | --- | --- |
| O1 | Shared JW use/def, escape and operation-effect facts, with remarks | Enables O2/O3/O4/O6; **no standalone runtime gain promised** | 1–2h inventory; 4–12h for the first bounded facts and consumer | Medium; high confidence in architectural need, unmeasured cost |
| O2 | Selective single-exit private inlining → aggregate/projection elimination → cleanup | **1.15–1.7×** on workers where temporary calls/aggregates remain hot | 1–2h saved-output discriminator; roughly 1–3 days for a general checked slice and controls | Medium–high; moderate opportunity evidence, low confidence in multiplier |
| O3 | Finite local function targets/captures through factories and helpers | **3–15×** where currently generic function transport dominates | 1–2h discriminator; 2–5 days for bounded transport plus integration | High; concrete coverage gaps, uncertain realized gain |
| O4 | Typed private Array allocation/read/write/swap | **3–15×** where generic Array execution dominates | 1–2h operation/alias discriminator; 2–5 days for an internal-array/scalar-result slice | High; error, alias and sequencing requirements |
| O5 | Public composite-result adapters with explicit sharing/identity | Enables additional O3/O4 graphs; **no independent multiplier** | 1–2h boundary inventory; 2–5+ days depending permitted shapes | High; materialization can erase benefit |
| O6 | Value/tag/range propagation, local CSE and discard-safe DCE | **1.05–1.4×** where repeated checked work survives | 1h opportunity count; 1–3 days for a small scalar lattice/consumer | Medium–high; depends on effect and branch facts |
| O7a | Context-complete definition/SCC fact reuse | Compiler latency/allocations; **gain unquantified** until repeated work is measured | 1–2h query census; 1–3 days for one exact cache scope | Medium; previous broad memoization lost despite real repeats |
| O7b | Share equivalent typed private components across roots | Smaller output/import cost; warm runtime might range **0.95–1.3×** | 1–2h duplication ablation; 2–4 days with capture/proof controls | High; earlier hoist had no useful whole-program runtime gain |
| O8 | General live-across-call facts and continuation slot/retention cleanup | Deep non-tail execution or memory retention; **no broad multiplier justified** | ≤1h fallback/live-slot counters; 1–3 days only if they identify material cost | Medium–high; old compact-frame gains were small |
| O9 | Migrate selected fusion into shared producer/consumer passes | Broader transfer plus fewer special cases; **no additional gain credited to already fused cases** | 1–2h coverage map; several days per replaced semantic family | High; multi-consumer data and errors prevent naive fusion |
| O10 | Mixed optimized regions around explicitly modeled unsupported calls | More partial coverage; **unquantified** | 1–2h boundary-cost ablation after effect/result model; larger design if promising | Very high; call effects can invalidate entry assumptions |

The most promising first optimization is **O2**, supported by the minimum O1
facts it needs. Its advantage is a general structural target inside an already
proved graph, avoiding a simultaneous change to public representation and
entry admission. If V8 already removes the candidate allocations, reject that
slice quickly and advance O3 rather than expanding an optimizer with no consumer.

The biggest potential outlier gains are **O3 and O4**. Start their source/fixture
work concurrently, but integrate one coverage mechanism at a time. O5 is a
separate dependency for escaping composite results, not an incidental addition
to an Array whitelist.

There is also a concrete **compiler-latency question** from the source audit:
the current ABI-2 `check_program_diagnostic(book, validated, origins)` ignores
`validated` and invokes `dg_check_world(book)`. A cached Base book therefore
does not establish that its prefix avoids checking on this path. Measure the
time and exact work before proposing reuse; earlier prefix/context and broad
memoization work already showed that a definition-only cache is insufficient.
Restoring reuse would need a checked context/instance/diagnostic contract, not
simply skipping the prefix. No gain or cause of the Phase45 regression is yet
established. [Current source](../../selfhost/src/driver/api.bend),
[host caller](../../selfhost/tools/typed-driver.mjs),
[prior cache evidence](../self_hosted/prior-experiments.md)

## What is actually new relative to prior attempts

| Familiar name | Already explored | Proposed new scope |
| --- | --- | --- |
| Inlining | Bounded region inlining, specialization and narrower closure lifting | One shared JW inliner using use/effect facts and immediately exposing general aggregate cleanup |
| Scalar replacement | Pair/read-shell removal, scalar state, direct constructors, private fields | Complete fresh aggregate uses across private calls/joins, independent of source names |
| Closure conversion | Narrow callback/factory fusion; existing known-local-functions design | General bounded lambda-site transport with explicit captures into the current worker graph |
| Arrays | Local-region operations and typed immediate tuple consumption | Composable JW operation/effect family plus separately proved exported-result adaptation |
| Memoization | Selected root-plan caches; rejected broad compiler caches | Context-complete per-definition/SCC summaries for measured repeated Phase45 queries |
| Code sharing | A module-hoist prototype reduced bytes without useful runtime gain | Equivalent typed components across overlapping root graphs, with root state kept separate |
| Liveness | Selected traversal/frame work and a small-gain compact-frame prototype | General JW live-across-call facts, with separate retention, slot and child-vector measurements |
| SSA/ANF | Structured JIR/JW, explicit call statements, earlier theory research | Add specific joins/use facts when a measured pass needs them; no wholesale SSA rewrite prerequisite |

See the [18-technique history table](../self_hosted/prior-experiments.md) for exact
attempts, rejected results and source symbols. We cannot establish “never tried”
over every archived byte; this is a bounded audit of selected code and reports.

## Speed evidence and the route toward parity

The maintained corpus currently measures **3.0787×** TypeScript by equal-point
geometric mean and **4.1467×** by equal-source weighting. Several substantial
programs now run around 1.5–2×, while six points remain about 49–61× slower.
Two points already beat TypeScript. These are different weighting schemes over
the same exposed development corpus, not universal language performance.
[Results](../../implementation/phase45/results.md)

There are therefore two required improvements:

1. Reduce work in admitted graphs through O2/O6 and eventual shared fusion.
2. Expand efficient execution to unsupported function/Array/result compositions
   through O3/O4/O5, without putting a new guard on every tiny helper.

As an illustrative geometric-mean calculation, bringing only those six worst
points all the way to parity would still leave approximately **1.8×** overall
equal-point slowdown. That hypothetical holds every other point unchanged; it
is not a forecast. Fixing a few outliers alone does not achieve suite-wide parity.

The selected Map/records profiles show named generic invocation at 4.6%/8.3%
and named guards at 8.0%/4.65% self CPU. Perfect removal of the named guard time
alone would yield only about 1.087×/1.049× there, assuming the attribution were
complete and everything else stayed constant. RLE already has a complete worker.
Those observations do not justify forecasting a broad 3× gain from guard tuning
or coverage expansion alone. [Diagnostics](../../implementation/phase45/diagnostics.md)

Parity is a testable goal; no source survey proves it is near. An overall 0.5×
result would probably require substantial fusion or allocation elimination beyond
matching the reference's lowering. Individual sub-parity points demonstrate
possibility for particular shapes, not a transferable global multiplier.

## Simplicity and conformance remain constraints

Prefer one analysis with multiple consumers to parallel recognizers for the same
fact. State which old walker/plan can be retired after each migration. Count
manifest-listed source, modules, IR variants, traversals and duplicate decision
sites separately; more modules can improve organization without reducing code.
The last phase grew source 5.47%, so do not claim current simplification gains.

A shared fact may reduce opportunities for inconsistent arity/layout/ownership
decisions, but it does not automatically fix a conformance failure. Unknown,
effectful or escaping cases must retain correct fallback. An unused value does
not make its evaluation discardable; private ownership does not imply unaliased
data; a known call does not imply its public descriptor is immutable.

Public APIs, `.code`/`.env`/`.bound`, host hooks, source demand, errors, aliasing,
Nat/F32 boundaries and the selected deep-stack policy remain validation axes.
No proposal silently relaxes the language or host contract to reach a ratio.

## Work to do first

1. Pilot the [parallel correctness/acquisition plan](../self_hosted/parallel-validation.md)
   while preserving exclusive timing. This attacks loop latency independently
   of generated-program semantics.
2. Record a small current JW opportunity/refusal census and compiler-stage costs.
   Reuse existing runner/report formats rather than building another framework.
3. Test one structural O2 transformation on saved output, then a genuinely checked
   compiler implementation only if activation and clean timing justify it.
4. Prepare independent O3 function-flow and O4 Array controls in parallel. Select
   the next implementation by executed coverage/cost, not the largest guessed gain.
5. Integrate survivors, test fresh held-out compositions, then run one complete
   qualification on the exact combined artifact. Preserve rejected ablations.

The [experiment plan](experiment-plan.md) defines owners, dependencies, stop
conditions and validation. This survey stops before those implementation steps.
