# Phase47: remaining generated-program outliers

This is a read-only census of the selected Phase45 worker23 artifacts. No
compiler build, generated program, profiler or benchmark was executed for this
note. Saved JavaScript was parsed as data, and its hashes were checked against
the completed preparation. Phase45 and Phase46 evidence remains unchanged.

The six large ratios do **not** have one common explanation. Morning and Evening
lack complete private workers; generic row has both Array and public-result
boundaries. RLE already has a complete worker. Map/Set is partly covered. The
scalar zero case already selects the same private implementation that is close
to TypeScript on a longer input.

The best immediate causal experiment is **hoisting a proved private Array's
backing storage and length outside an existing loop**. It has actual generated
code and profile evidence, two independent source families to test, and a small
initial transformation. For the larger representation project, shared use,
escape and effect facts should support both typed Array operations and aggregate
forwarding across known private calls. Finite-function transport is a separate
important coverage extension; Morning alone does not establish its corpus gain.

## Measured scope

The authoritative selected comparison is [Phase45 results](../phase45/results.md)
and its [portable runtime summary](../../selfhost/tools/performance/phase45/evidence/runtime-summary.json):
45 points from 23 sources, 669 fresh samples, all expected results passing.
The equal-point geometric mean is **3.07865× TypeScript**, versus 6.08672× for the
fresh Phase44 baseline. These are exported-call timings, including the harness's
validation, excluding compilation and import. They are not compiler-speed ratios.

| Point | Worker23 µs/call | TypeScript µs/call | Worker23 / TS | Phase44 / worker23 |
| --- | ---: | ---: | ---: | ---: |
| `test-morning-program` | 198.779 | 3.279 | 60.614× | 0.995× |
| `scalar-region-0` | 4.043 | 0.067 | 60.117× | 1.017× |
| `complete-generic-row32` | 394.599 | 6.782 | 58.181× | 0.953× |
| `test-map-set-ops` | 1166.426 | 20.515 | 56.857× | 1.275× |
| `test-rle-roundtrip` | 31.776 | 0.563 | 56.415× | 1.143× |
| `test-evening-program` | 130.006 | 2.636 | 49.328× | 1.003× |

Nearby controls prevent interpreting those ratios as a universal loop cost:

| Point | Worker23 / TS | Why it matters |
| --- | ---: | --- |
| `scalar-region-8192` | 1.155× | Exact same module and export as the zero case; work amortizes the entry cost. |
| `local-pair` | 2.134× | Same Bend source as generic row, but a scalar-result whole-region entry already specializes Array work. |
| `local-fold` | 2.253× | Independent private Array loop, useful alongside local pair. |
| `variation-local-fold8192-123` | 1.481× | Same fold source under a different work/input scale. |
| `coverage-closures256` | 0.477× | Existing callback construction/application fusion beats TS on this point despite having no contextual-worker marker. |
| `coverage-list-pipeline512` | 0.572× | Existing scalar fusion is effective; a new pass must preserve its selection. |
| `coverage-map-churn128` | 1.538× | Large Map worker, with current CPU/allocation diagnostics. |
| `coverage-record-aggregation256` | 1.605× | Independent larger source exercising private Map/string/aggregate work. |

The [catalog](../../selfhost/tools/performance/phase37/catalog.json) binds each
point to its source, export, arguments and oracle. The generic row's observed
entry serializes all four returned Array backings; it is not the scalar `pair`
entry. A change that accelerates `pair` cannot claim coverage of this observation.

## Actual private coverage and remaining work

All counts below come from complete `G["name"]` assignment AST ranges in the
saved worker23 modules. They count emitted sites, including fallback paths;
they are neither dynamic activation counts nor measured hot-cost percentages.
“Has a worker” means that the guarded private branch exists. No new counter
derivative was run to measure entry frequency in this survey.

| Source/entry | Saved implementation | Concrete remaining boundary or work | Cheapest discriminating observation |
| --- | --- | --- | --- |
| Morning `main.out` | No contextual root anywhere in the module. Its public root remains generic. | `Str.split` and `Str.join.go` return functions after matching; their finish helpers accept and invoke them. This is finite closure transport through helper parameters, not just immediate beta reduction. | A renamed tiny factory/match/helper composition: require correct capture and prefix order, private entry, and direct lifted calls. Then report which remaining native/type obligation prevents the complete source from entering. |
| Evening `main.out` | No contextual roots. `fpart` remains generic. | `fpart` constructs `Array<F32>`, swaps two positions, transports Array/value pairs and performs F32 arithmetic. Typed Array operations are not admitted into this complete worker proof. Parsing/Map paths supply additional obligations. | Separate U32 and F32 scalar-result fixtures using allocation/read/swap and aliases; compare complete observations before attempting the full Evening graph. |
| Generic row `row.probe` | Generic row entry; the separate `pair` has the inherited private scalar/Array plan. | `Dp` returns four Array handles across the public result boundary. The body also needs allocation, reads and writes. Internal Array support alone cannot authorize replacing this escaping representation. | First test the private loop with a scalar consumer. Separately test an unchanged public `Dp`/Array adapter, including alias identity and all returned contents. |
| RLE `main.out` | One contextual root: seven native components, four continuation components, three tail-only wrappers. Its private graph includes Number-Nat mode. | Private List/tuple allocation, projection and recursive work remain. `rle.step` returns state consumed by `rle`; the encoded list is subsequently used twice. | Count actual entries/allocations in a derivative, then scalar-replace one proved nonescaping state tuple across a known call. Keep the list's two consumers intact. |
| Map/Set checks | Contextual roots `chk_get` and `chk_union`; `chk_order` retains an inherited finite-selector path. `main.out`, `chk_set` and `chk_del` have no complete contextual root. | Exact native `String.eq` blocks verified order/set paths. Unit is already supported. Remaining `chk_del` refusal is not fully diagnosed here. Admitted roots still construct/project private aggregates. | Reuse the already-tested equality prototype as a scoped comparison; separately identify a removable transient aggregate shared with Map churn/records. Do not infer all causes from the root marker. |
| Scalar zero `bench` | Inherited private scalar-root plan; `mit` contains a native countdown/scalar loop and helper specializations. | Even zero iterations pay public invocation, argument validation, dependency checking and seed computation. This is consistent with fixed cost, not proof of its exact distribution. | Paired zero/small/8192 inputs from this one module, plus a counter/source ablation of one entry-check class. Preserve descriptor/prototype mutation and call-order behavior. |

The source evidence is in the maintained historical fixtures:
[Morning](../../selfhost/tools/performance/phase37/fixtures-historical/test-morning-program.bend),
[Evening](../../selfhost/tools/performance/phase37/fixtures-historical/test-evening-program.bend),
[RLE](../../selfhost/tools/performance/phase37/fixtures-historical/test-rle-roundtrip.bend),
[Map/Set](../../selfhost/tools/performance/phase37/fixtures-historical/test-map-set-ops.bend),
[scalar region](../../selfhost/tools/performance/phase37/fixtures-historical/scalar-region.bend),
[local row](../../selfhost/tools/performance/phase37/fixtures-historical/local-row.bend),
and [local fold](../../selfhost/tools/performance/phase37/fixtures-historical/local-fold.bend).

The [existing coverage audit](../../design/phase45/remaining-general-coverage.md)
records the same structural boundaries. The corresponding compiler gates are
`j_pure_type_head`/`j_pure_native` in [jpure.bend](../../selfhost/src/back/js/jpure.bend)
and `jw_expr`/`jw_native_boundary` in [worker-lower.bend](../../selfhost/src/back/js/ir/worker-lower.bend).
Function values and arbitrary local application are outside the current first-order
worker language; native Array operations need a separate effect-aware admission.
These source restrictions establish incompatibilities, not a complete trace of
the first failing predicate for each public root.

## What the profiles actually establish

The selected Phase45 diagnostics cover **Map churn and records**, not the six
outliers above. There are no fresh selected23 outlier CPU/allocation profiles in
that diagnostic campaign. Their absence must not be filled with percentages from
older candidates or a different source. See [the exact diagnostic report](../phase45/diagnostics.md).

On those two larger admitted graphs, the named generic invocation helpers fall
to 4.6% and 8.3% of self CPU. Sampled allocation remains about **1.33× and 1.39×**
TypeScript. Private Map bit/seek and String comparison components have substantial
named samples. This makes general aggregate transport a better-supported residual
hypothesis than assuming another elimination of generic calls explains the whole
gap. Wrapper-attributed allocation does not prove continuation-frame allocation;
inlined constructors can receive the wrapper's profile position.

The emitted Map/Set root expressions are large: `chk_get` is 122,929 characters
and `chk_union` 106,690, containing 51 and 46 private `$R` declarations respectively.
These are static code-size/duplication observations. They justify tracking code
growth and compilation cost, but do not prove an instruction-cache or JIT cause
for this point's execution time.

[Phase46's fresh array evidence](../phase46/source-findings.md) uses worker23
under a different batch harness. Its JS fold already removes generic per-step
calls and the evolving Array/accumulator tuple. It still calls `arraydata` for
the read and again through `arrayset` for the write; those helpers validate the
handle/backing and convert/reduce the index. The selfhost profile places 93.63%
of samples in the fold-loop function and 1.62% in GC. This locates loop work;
it does not prove that V8 fails to inline or eliminate those checks.

That is why backing-view hoisting needs a causal saved-output experiment before
adding an analysis pass. “More garbage collection” is not supported as the main
JS Array explanation by these samples. The Phase46 C small-allocation/segment
counts explain a different backend and must not become JS cost estimates.

## Ranking general opportunities

| Candidate | Independent evidence and likely reach | What is genuinely new here | Main risk / fastest falsifier |
| --- | --- | --- | --- |
| Owned Array view/length hoisting | Existing hot local-fold and local-pair regions; broader Array foundation relevant to Evening and row. | Reuse a proved stable backing view across iterations, rather than repeated helper validation. Existing tuple removal must not be counted again. | V8 may already remove most cost. First make one diagnostic derivative, validate outputs/aliases, and compare clean focused timings. Reject if gains do not survive nearby inputs. |
| Typed private Array operations plus effects | U32 row/fold and independently structured F32 Evening. | Explicit allocate/read/write/swap semantics in the worker IR, with shared alias/effect facts. | More admission does not solve escaping public results; incorrect reordering breaks alias writes, errors or host conversions. Start with nonescaping scalar roots. |
| Aggregate forwarding across known calls | RLE state tuples; remaining Map/record allocation; Array/value pairs in currently generic paths. | A reusable use/escape/layout analysis and private multi-value transport, beyond earlier selected tuple patterns. | Shared values and materialization boundaries matter. Prove one single-use constructor/projection chain first; do not erase RLE's shared encoded list. |
| Bounded finite-function transport | Direct structural witness in Morning; independently renamed factory/helper fixtures can establish generality. | Lift finite lambda alternatives and specialize helper function parameters before existing first-order proof/SCC lowering. | Captures, staged demand, partial application and public closure escape. One workload does not establish whole-corpus gain. |
| Broader native coverage | Existing String-equality experiment admits more Map/Set roots. | Composition of already-proved native signatures with representation facts. | Repeats an existing experiment if treated as novel; generated code growth and narrow coverage already measured. |
| Entry-check amortization | Scalar0 versus8192; tiny RLE denominator; selected guard samples on larger graphs. | Broader complete private graphs or a demonstrated safe reduction in redundant checking. | Another tiny guarded public helper can make execution much worse. Do not cache mutable public identities across calls. |

There is no defensible numerical speedup estimate for the first four unmeasured
changes. Static eligibility establishes possible reach, not gain. The best
low-cost next candidate is the Array view experiment; the broadest evidenced
allocation project is aggregate forwarding across already-admitted graphs.
Neither should wait for a universal SSA framework to exist.

The compiler comparisons already explain useful ordering:
[MLton](../../design/phase38/research/mlton.md) makes finite function targets
explicit before flattening data; closure conversion itself need not remove the
environment allocation. [GHC](../../design/phase38/research/ghc.md) separates
demand, usage and constructor shape, which prevents “known tuple” from being
mistaken for “safe to duplicate or erase.” [Lean](../../design/phase38/research/lean.md)
and [Koka](../../design/phase38/research/koka.md) motivate explicit ownership and
escape facts; adding reference counting to JavaScript is not the lesson.
The existing [known-local-functions design](../../design/phase45/known-local-functions.md)
already specifies the finite-function proposal. Its older baseline/status
paragraphs are historical; worker23 now supports nullary roots.

## Cheap discriminators and stop conditions

1. Preserve selected23 modules and make any instrumentation or source ablation a
   separately hashed diagnostic derivative. Clean program timings and derivative
   counters answer different questions. No program-name recognizer belongs in
   the compiler implementation.
2. For Array views, start with local fold and local pair, then U32/F32 renamed
   fixtures. Include zero iterations, empty backing behavior, alias writes,
   repeated use, public escape refusal, index bounds/wraparound and mutable host
   conversion hooks. Do not hoist a first-demand error onto a zero-iteration path.
3. For aggregate forwarding, observe one allocated state and its complete use
   chain before changing it. Check returned object identity, retained aliases,
   mutation, branch order, exceptions and reentry. Require a second independent
   graph to benefit before presenting it as broad progress.
4. For functions, require both singleton and finite branch-dependent targets,
   evaluated captures, factory-prefix ordering, helper-parameter transport and
   exact refusal for unknown/public callbacks. Compare actual worker entries as
   well as output equality; a correct generic fallback is not optimization credit.
5. Reuse the maintained fast canaries before a full campaign. In particular keep
   generic row and scalar0: Phase45's tiny acyclic-wrapper experiment made row
   about 10.77× slower; a later reduced-guard attempt still lost about 5.15×.
   [Selection regressions](../phase45/selection-regressions.md) are falsifiers,
   not permission to weaken public mutation semantics.

The [unselected String-equality probes](../phase45/native-string-equality.md)
already observed a 1.37766× Map/Set gain in a longer comparison, with roughly
56.4% larger generated code and remaining drift. That result must be retained as
a prior attempt, not claimed as a new Phase47 discovery or part of worker23.

## Artifact identity and reproduction of this census

The saved preparation is
`selfhost/build/phase45/full-preparation-worker23/manifest.json`; its adjacent
`modules/*.mjs.json` checked-emission receipts bind source, compiler and runtime.
Selected API is `e77c504a9c91d9ae9d43e52f4f4899711eb7a8ebe707ee565348df2708488b4c`;
runtime is `4f057842e476d01be5cfa06ad7984fea55ad2537b2fe6e861965a782e8b94c26`.
The pinned upstream is `018751270e800bc222a93dad7f257083ee53a5f7`.

| Saved module | SHA-256 |
| --- | --- |
| `test-morning-program.mjs` | `3f7c598879d1e2e26d90faf1e0f9aecfe9aedf4df626feb1e2eebb070929fee1` |
| `test-evening-program.mjs` | `853f6e84f30e9e59114d5dfa42a8319a24a0f0dc5a353c544fbd6d33bed2a8e7` |
| `test-rle-roundtrip.mjs` | `0337d8cc760ee3eec80436988104ead81f72440f36b57f165a1b87d69f6ea123` |
| `test-map-set-ops.mjs` | `ba929668501bf38594c3d8ce6022d06136b2c49759680c532b9226dabf685a65` |
| `scalar-region.mjs` | `8d817be9e1bf771a7e96b32978bed0fe5d7be9c2dcaffe6ae87a838655784721` |
| `local-row-observed.mjs` | `00272df61c2eadb4fdf702e1f145de7c5df463d2fcb18d8e1f78982870c94686` |
| `local-fold.mjs` | `f07852cf5e5147f37d006f5d36e202e67f23d33b979e064f0de29e26cbf3c990` |

Static inspection parsed these bytes with the Acorn bundled in Node24.18.0,
located complete computed `G[LiteralString] = ...` assignments, and counted
markers only within those AST spans. It did not import generated modules.
Counts/ratios here are a documentation snapshot; no new measurement receipt or
modification of either closed phase was needed.
