# Phase45: private execution graphs and composable backend selection

**Phase45 worker23 is installed; final selected qualification, release verification and all 42 CLI checks pass.** The exact-image closure verifies 8,755 assertions and 3,203 input identities across frontend/backend agreement, eight maintained suites, independent composition controls, all 669 execution samples and 36 compiler requests. Fresh nullary-demand/metadata, Unit/Map and six post-import host-hook controls also pass. The selected portable bundle and 14 curated evidence receipts are published; the closed raw archive is verified and published in five bounded parts. This report consolidates the [design](../../design/phase45/README.md), experiments, qualified results and installed-image status.

The complete runtime comparison shows **about 2× overall improvement, with TypeScript parity still unmet**. Fresh equal-point time falls from 6.0867× TypeScript for Phase44 to 3.0787× for worker23; equal-source time falls from 8.2713× to 4.1467×. Map128 improves 15.04× to 1.538× TypeScript, records256 improves 41.47× to 1.605×, active ray256 improves 13.89× to 1.843×, and lexer improves 4.85× to 1.472×. Smaller or generic paths remain much slower. All 45 medians and a logarithmic before/after diagram are in [the complete execution report](results.md).

The broader comparison mattered. Worker17b's first long batch exposed a 10.77× generic-row regression missed by the earlier selected screen. Worker18 restored the old output through a general alias-only entry profitability gate. Worker20 retested acyclic admission with fewer primitive guards and still slowed that row by 5.15×, so it was rejected. Worker23 preserves the corrected selection policy. It also fixes a supported post-import runtime observation discovered on worker22; the failed and passing observations remain separate evidence.

The fresh full comparison has 32 lower and 13 higher candidate medians; the largest slowdown is 4.93% on generic row. Two points beat TypeScript. These are descriptive medians, not significance tests or typical-application predictions. The maintained workloads informed development and are not untouched holdouts. Historical screen values below are retained as experiment history and are not pooled into the completed comparison.

| Full45 weighting | Fresh Phase44 / TypeScript | Worker23 / TypeScript | Geometric improvement |
| --- | ---: | ---: | ---: |
| Equal point | 6.0867× | 3.0787× | 1.9771× |
| Equal source | 8.2713× | 4.1467× | 1.9947× |
| Equal family | 8.4316× | 4.7340× | 1.7811× |

## Historical worker21 focused screen

Three serial 60-second-preset runs cover eleven points and 99 fresh samples in 84.14 seconds. Each point has three rotated rounds per role; all expected values pass. Baseline and TypeScript are freshly executed saved outputs, and the candidate is freshly acquired from the checked worker21 API/runtime. All numbers measure warmed repeated execution, excluding compilation, import and first call; even the tiny cases are warmed measurements. The protocol uses CPU 3, Node 24.18.0, 1 GiB heap, 2 GiB tree RSS cap, 350 ms warmup and a 150 ms target per sample.

| Point | Phase44 ms | Worker21 ms | Phase44 / worker21 | Worker21 / TypeScript |
| --- | ---: | ---: | ---: | ---: |
| Local pair | 2.652166 | 2.650350 | 1.0007× | 1.9846× |
| Local fold | 0.090816 | 0.091039 | 0.9975× | 1.4330× |
| Scalar region 0 | 0.004177 | 0.004161 | 1.0037× | 60.1676× |
| Scalar region 8192 | 0.113001 | 0.112670 | 1.0029× | 1.1264× |
| Complete generic row 32 | 0.384413 | 0.398447 | 0.9648× | 56.7051× |
| Morning | 0.241197 | 0.243357 | 0.9911× | 69.8730× |
| Evening | 0.171062 | 0.172790 | 0.9900× | 58.4593× |
| RLE roundtrip | 0.048866 | 0.031907 | 1.5315× | 53.3968× |
| Map/set operations | 2.049285 | 1.431397 | 1.4317× | 66.7079× |
| Map churn 128 | 22.803328 | 1.398069 | 16.3106× | 1.7206× |
| Records 256 | 103.510682 | 1.965055 | 52.6757× | 1.5509× |

The fast-five canaries show no large regression; generic row is 3.65% slower in this short run. RLE and Map/Set improve 1.5315× and 1.4317× against the same-run Phase44 control; morning/evening are effectively flat. Remaining half-window drift is material: up to 61% for candidate morning, 21% for candidate Map and 14% for candidate records. These short screens justify continued qualification, not precise universal gain estimates. [Remaining execution gaps](remaining-performance-gap.md) separates larger private graphs from repeated small public boundaries; [accounting](accounting.md) records measured validation cost without estimating agent reasoning time.

## Worker23 host-observation repair

A new independent controller reproduced six post-import hook differences on
worker22 before source-body execution: `Reflect.apply`, three Object reflection
operations, `WeakSet.prototype.has`, and a getter for `Reflect.apply`. All lanes
returned 81, but extra preflight events violated the public observation contract.
The WeakSet event was already present in worker19; the other five were exposed
by the newly optimized nullary root. Worker23 is therefore a correctness repair,
not a claim that every earlier control was sufficient.

Worker23 captures private bookkeeping intrinsics during the already-required
standard module initialization, including bound WeakSet membership. Public
`.code`, live `.call` and `.env` observations and fallback order remain intact.
The unchanged six-hook controller now agrees with ordinary source invocation,
and fresh nullary/Unit boundary controls pass. This tests recording/delegating
hooks, not every possible throwing or reentrant host hook. See
[P45-023](../../experiments/phase45/P45-023-exact-entry-preflight.md) for exact
failed traces, source changes, preserved hashes and scope.

The separate Unit extension in22 admits proved canonical Unit payloads in complete
private graphs and has independently demonstrated activation. Its nine-point
corpus screen earned no speedup claim: all ten emitted files were byte-identical
to21. Worker23 retains that coverage with the corrected runtime. Its complete
performance table and chart are in [the execution report](results.md), derived
from three passing fresh batches and their identity-bound summary.

## What the new backend does

A complete, existing contextual-instance/JPure proof now lowers to a first-order
worker IR with explicit values, assignments, calls, cases and returns. This
separates call-graph analysis and representation decisions from source-term text
emission. Unsupported graphs retain the prior implementation. Public roots keep
scalar inputs and scalar or exact native String results; ordinary mutable
function descriptors remain boundary adapters.

The new modules cooperate in one lowering pipeline:

1. **Lower a verified graph.** Calls use explicit targets and stable evaluated
   values. Private calls avoid public argument vectors, function descriptors and
   trampoline dispatch. Constructor and projection operations carry layouts.
   Unknown callbacks, partial applications and unsupported native boundaries are
   not silently converted to direct calls.
2. **Plan exact call components.** A bounded graph analysis validates every edge,
   including both branches, and computes strongly connected components for at
   most 96 functions. Invalid or incomplete analysis refuses the backend. Acyclic
   functions use positional parameters and scalar locals; cross-component calls
   follow a DAG whose depth is independent of source recursion depth.
3. **Keep recursion bounded.** Non-tail components use a shared native allowance
   of 32 entries with `finally` restoration and the same private continuation
   machine at exhaustion. Same-component tail calls capture all arguments before
   updating scalar slots and continuing in the current frame. A component proved
   entirely tail-recursive needs only that loop, not a fallback machine or budget
   charge. This is not unbounded JavaScript recursion or a larger-stack workaround.
4. **Choose private representations.** Tagged ADTs use one fresh object with
   named fields instead of an object plus field array. A native-signature fence
   prevents those values crossing an incompatible public ABI. Whole eligible
   graphs use Number Nats internally, preserving exact 48-bit bounds and BigInt
   public inputs/results; unsupported operations retain the BigInt graph.
   Exact Bool/String/Char/Tuple constructors emit their existing native operation
   directly. Generic constructors and public layouts remain unchanged.
5. **Select a completed optimization.** The planner carries `JRootPlan{code,strong}`,
   introduced in worker17b, from its actual completed result. Successful complete fusion, a region without residual
   generic calls, or a successfully audited flat graph can outrank the new worker.
   A partial region does not. Trusted Base roots require a real contextual
   specialization, declining purely alias-based public workers. They remain eligible as private callees in larger
   graphs. New alias-only public entries additionally require a proved recursive
   component; real contextual specialization retains its existing path. Acyclic
   helpers remain eligible inside admitted private graphs.
6. **Preserve demanded nullary calls.** Worker21 admits proved computed zero-argument
   calls without caching or hoisting. Its public wrapper preserves ordinary
   zero-formal code metadata and raw-call/constructor behavior. Unsupported graphs
   retain source execution; a legacy path unable to lower demanded nullary references
   is refused. Full source/native/host guards remain in force.

The shared native projection plan also replaces duplicated String/Char vector
projection in the two inherited private emitters. It preserves input evaluation,
String method lookup order and the original repeated code-point read.

The implementation uses type/layout, saturation and call-graph facts, not program
names or complete-algorithm recognition. Existing specialized optimizations are
retained while their functionality awaits migration into general worker passes.
This is still a bounded private backend, not universal ownership analysis, SSA,
closure conversion or an unrestricted closed-world ABI.

## What changed the performance picture

The first continuation backend removed private generic dispatch but emitted
approximately 71 KB functions. Both Map and record CPU profiles explicitly said
**“Function is too big to be optimized.”** Splitting by exact call components
addressed an observed JIT failure. Later profiles no longer contain that reason;
its absence in sampled metadata is not proof that every function optimized.

Bounded native execution alone initially gave mixed results. Proper tail
transfers were essential: a tail loop must not spend a non-tail recursion budget.
Historical worker09/11 controls at 50,000 steps distinguish a tail cycle with one
charged native entry and no machine entry from a non-tail cycle that consumes
32 entries and continues in the machine. The later tail-only plan removes that
one charge as well. Current exhausted-budget controls exercise entry into such a
component after the shared allowance reaches zero: 22 exact results and 28
activation observations pass. These controls test the intended mechanism instead
of inferring it from final output or emitted markers.

Representation then mattered. The paired worker10b → 11 experiment combines Number
Nats with elimination of proved native descriptor calls; it cannot attribute all
of its gain to BigInt removal. Native constructor emission subsequently beat the
simple prediction from sampled `ctor` self-time. Removing a call/vector can also
change inlining and allocation behavior; a profile percentage is neither a
causal attribution nor a fixed ceiling on speedup.

| Isolated comparison | Map 128 control / candidate | Records 256 control / candidate | Interpretation |
| --- | ---: | ---: | --- |
| Number-Nat and direct operations, 10b → 11 | 1.69358× | 1.72526× | Positive paired screen; representation and native-call changes combined |
| Native constructors, 11 → 14 | 1.83745× | 1.37583× | Positive paired screen; material warmup drift remains |
| Tail-only components, 11 → 15 | 1.00387× | 0.99361× | Effectively flat; retain provisionally for less generated machinery |

Each row uses its own fresh control, candidate and pinned TypeScript roles,
three rotated rounds per role, 350 ms warmup and a 150 ms sample target. These
ratios are not multiplied into an aggregate or attributed across different runs.
The [partitioned checkpoint](partitioned-workers.md),
[native representation report](native-representation.md) and
[worker11 profiles](profile-worker11.md) retain the intervening results and limits.

Worker11 sampled allocation estimates fall to 3.86 MB/call for Map and
5.52 MB/call for records, against 2.17 and 2.71 MB/call for TypeScript in the same
diagnostic campaign. These are sampling estimates, not exact allocations or
retained heap. They compare multiple compiler changes and do not isolate Nat.
Profiles and counter derivatives never supply clean timing samples.

The fresh [worker23 diagnostics](diagnostics.md) pass all 12 CPU/allocation
profiles on Map and records. Sampled candidate allocation is 2.914 MB/call for
Map and 3.786 MB/call for records, versus TypeScript's 2.184 and 2.729 MB/call
(1.334× and 1.388×). Against the same diagnostic Phase44 controls, allocation
falls 10.11× and 33.07×. Exclusive CPU samples in `apply`, `invokeExact`, `force`
and `callOwned` fall from 31.0% to 4.6% for Map and 42.6% to 8.3% for records.
Private String/Map components are now prominent residual costs. These samples
support the changed cost distribution; they do not measure clean throughput or
prove a causal share for each transformation.

## Historical worker17b screen and selection failure

Four serial screens cover 16 selected points and 144 fresh role samples in
115.80 seconds. Every sample passes its expected result. The table shows
same-run medians, with execution excluding compilation and import. The protocol
uses CPU 3, Node 24.18.0, a 1 GiB heap, 2 GiB process-tree RSS limit and 4096 KiB
stack, with 350 ms warmup, 40 ms calibration and a 150 ms sample target.
Default-stack correctness is tested separately at 984 KiB.

| Point | Phase44 ms | Worker17b ms | Phase44 / worker17b | Worker17b / TypeScript |
| --- | ---: | ---: | ---: | ---: |
| Map churn 128 | 22.815872 | 1.231252 | 18.5306× | 1.5588× |
| Records 256 | 101.222062 | 2.107509 | 48.0292× | 1.6885× |
| Active ray 256 | 35.242299 | 2.165413 | 16.2751× | 1.7304× |
| Unicode 64 | 2.142054 | 0.251538 | 8.5158× | 2.9799× |
| Lexer | 12.924241 | 2.605765 | 4.9599× | 1.5446× |
| Symbolic regression | 2.090412 | 1.617941 | 1.2920× | 1.4267× |
| Bitonic tree | 0.426115 | 0.405383 | 1.0511× | 1.4178× |
| List pipeline 512 | 0.015408 | 0.015386 | 1.0014× | 0.5385× |
| BST 64 | 0.118705 | 0.121864 | 0.9741× | 2.4538× |
| Local fold 8192 | 0.174481 | 0.174280 | 1.0012× | 1.4081× |
| Expression 128 | 0.043546 | 0.043334 | 1.0049× | 4.9772× |
| Numeric recurrence 1024 | 0.020435 | 0.020330 | 1.0051× | 2.5131× |
| RLE roundtrip | 0.048807 | 0.050386 | 0.9687× | 86.4448× |
| Map/set operations | 1.989182 | 2.004474 | 0.9924× | 94.1241× |
| Morning | 0.230067 | 0.234242 | 0.9822× | 74.0741× |
| Evening | 0.157976 | 0.159767 | 0.9888× | 57.4101× |

Ratios below one in the improvement column are slower observations. This screen
retains the major larger-worker gains and recovers displaced existing plans.
Whole-module identity proves that the list, expression, numeric, local-fold and
four tiny-library programs have no generated-code change from Phase44; their
small timing differences cannot be attributed to a compiler transformation.
Closures is the ninth identical module among all 23 prepared sources. Fourteen
modules differ. Emitted size is not uniformly smaller: Map changes from 271,679
to 247,077 bytes, while records changes from 126,483 to 239,866 bytes and active
ray from 186,586 to 343,180 bytes.

Material warmup drift remains: record candidate second-half per-call times differ
from first-half times by about −25% to −28%, and RLE by +54%. The larger gains justify
broader measurement, but a 150 ms screen is not a steady-state qualification.
The first broader batch subsequently exposed the row regression below; the
remaining queue was stopped. No aggregate is inferred from this selected table.

The earlier worker16 screen explains why selection needed its own experiment.
It slowed the list pipeline by about 11.2×, numeric recurrence by 8.1×,
expression by 1.9× and bitonic by 2.1× against its own fresh Phase44 controls.
Those changes displaced already successful fusion, direct-loop, fold or
flat-graph plans. Conversely, the old lexer/ray regions retained residual generic
calls, so choosing every old region would lose major new gains. This motivates
typed plan strength rather than a universal backend priority or text inspection.

The four tiny library programs isolated a second issue. Replacing only their new
worker16 Base helper assignments reconstructs each complete Phase44 module byte
for byte. The new wrappers add 58–60 descriptor dependencies. They also install
those modules' first exact-code descriptors, enabling a WeakSet check on every
generic invocation. RLE's timed entry never calls its changed show wrapper, so
guard execution alone cannot explain its movement. Its worker16 half-window drift
was about +53%; the small median change is particularly uncertain. The
[selection-regression report](selection-regressions.md) preserves all four
historical timings and distinguishes this exact source isolation from the
still-unisolated runtime explanation. Worker17b restores all four entire modules
without narrowing host guards.

### The broader row test rejects worker17b

The completed first full-corpus batch observes generic row 32 at 0.420292 ms for
Phase44, 4.528299 ms for worker17b and 0.007297 ms for TypeScript: worker17b is
10.7742× slower than Phase44 and 620.5289× TypeScript time. All five rounds per
role return the expected value. This program was absent from the 16-point screen;
the omitted case changes the selection decision.

A complete-module AST comparison isolates the source change to the user-defined
`umin` helper: its assignment grows from 485 to 2,393 bytes. Replacing only that
assignment restores the entire Phase44 module byte for byte. The benchmark's
observation adapter is identical in both roles. No row, array, constructor or
loop assignment changed. The helper contains two acyclic functions and does one
comparison and selection, but its new public wrapper validates 56 descriptor
dependencies plus host and scalar conditions on entry. The generic row calls it
twice per cell. It also introduces the module's first exact-code descriptor.
This makes entry cost a strong explanation; source isolation does not separate
that cost from exact-entry state and JIT effects.

The Base-only profitability gate therefore missed the same structural problem in
a user helper. Worker18 corrects this through a typed recursive-component fact for new alias-only public entries, while preserving contextual specialization and private helpers. Worker20 confirms that smaller primitive fences alone do not make repeated acyclic public entry profitable. Neither selection rule uses program or helper names.
Static evidence is preserved in `local-row-analysis17b.json`, SHA-256
`47ee708bf39d9b1bc1924e67483c97646fd6c85742a605e8bd3f47dc0d95e1a1`.
Worker17b remains a rejected historical candidate. Worker23 now has the completed
fresh broad comparison and semantic closure above, followed by normal
installation, release verification and all 42 CLI smoke checks.

## Correctness evidence and preserved failures

Worker23's standard selected-image closure passes 8,755 assertions over 3,203
bound inputs. Frontend observations agree exactly on 3,026 main and 196 broader
inputs, with no result or extra-field differences. The main outcomes retain
2,525 passes, 497 observations and four shared failures; broader retains 195
passes and one observation. All 81 backend rows agree: 69 execution passes,
eight unavailable/not-applicable outcomes and four shared check failures.
Agreement does not convert the shared failures into successes. The independent
composition fixture also passes, and all 36 measured compiler requests reproduce
their expected output bytes. These artifact and repeated-execution counts are
not additional unique language-conformance tests.

Worker23 freshly passes all eight maintained suites. Its nullary controller
passes six oracles, 39 boundary observations, six activation observations and
nine descriptor-metadata comparisons. Its Unit controller passes 27 numeric
oracles, ten mutation boundaries, four activation observations and two public
ABI/object bundles. Six post-import hook traces agree with ordinary source
invocation. These focused scopes overlap and remain distinct from the standard
frontend/backend/composition closure; they do not establish universal backend
or host-observation equivalence.

Historical worker21's fixture first failed acquisition because a Nat literal
needed a type annotation. A new fixture version corrected only that annotation,
preserving the failed attempt. Raw calls with no argument vector, inherited
numeric getters, normal construction, oversaturation and genuine demand/reentry
remain explicit controls. Worker22's six reproduced host-hook failures are also
preserved; worker23 reran the unchanged controller and the nullary/Unit suites
on freshly acquired programs for its new runtime.

Worker16 passes all eight maintained suites: ordinary IR, basic backend, global
initializers, choice, matcher arms, primitive guards, constructor provenance and
foreign boundaries. Worker17b has freshly passed these same eight suites, plus
the actual-record controls (4 exact results, 57 boundaries, 61 activation/refusal
observations) and immutable-result controls (8 exact results, 44 boundaries,
8 activation observations). The following additional totals describe historical
worker16 executions:

| Independent control | Completed scope |
| --- | --- |
| Worker composition | 135 small oracle cases across three roles, five public-data checks, five mutation refusals, 15 activation observations and two diagnostic unwind/reentry cases |
| Deep execution | Five roots × depths 4096/50000 × two seeds: 20 candidate deep oracle cases, with separate activation/budget replay at default stack |
| Number Nat | 215 exact oracle cases across 16 roots and three roles; 5 overflows, 28 exact selfhost boundary comparisons, 73 activation observations |
| Monomorphic admission | 54 small oracles, 6 activation observations, 10 public mutations and one ABI bundle |
| Actual record module, controller v2 | 4 exact results, 57 boundaries, 61 activation/refusal observations |
| Exhausted-budget tail component | 22 oracle cases and 28 activation observations |

Counts have different scopes and are not added into a conformance percentage.
Some deep fixtures deliberately use unsafe recursion to exercise the backend;
they are not termination proofs. Injected diagnostic faults test machine cleanup,
while Nat overflow tests use genuine source errors. Four freshly checked and
emitted worker17b fixture modules are byte-identical to their worker16 modules:
composition, Number Nat, monomorphic admission and exhausted-tail execution.
`reuse-worker16-for17b.json` binds the complete module identities to nine earlier
control receipts. This reuses executions of identical programs; it does not
claim fresh worker17b execution of those controls or contribute timing samples.
The immutable fixture's former one-line shape scanner was wrong; its fresh v2
17b run now checks complete root assignments and passes activation as well.

One new external frontend probe deliberately contains the out-of-range compact
literal `4294967296n`. Pinned TypeScript and worker17b both correctly reject it
at parse time in the parse and check lanes: two expected-rejection passes per
role, with `checked:false` and `typeAccepted:false`. However, **both lanes differ
in their diagnostics**, so the strict-exact workflow finishes with `pass:false`
and two discrepancies. TypeScript reports the supported literal range and source
location; selfhost reports an invalid or unsupported numeric literal. This is
one fixture with two diagnostic mismatches, not successful typechecking, two
accepted invalid programs, or a full conformance result. No expectation or gate
was weakened. All 54 manifest modules outside the JavaScript backend are unchanged
from Phase44, including the frontend. The selected23 standard frontend/backend
inventory now passes exact agreement; this additional out-of-inventory probe
still records two diagnostic mismatches and receives no passing credit.
Normal installation, release verification and all 42 CLI checks now pass on
worker23. Curated evidence and the selected portable bundle are published; raw archive
closure is complete and separately preserves the selected and rejected scopes.

Several failures changed the implementation or harness and remain visible:

- The first selected23 receipt publisher refused diagnostics because it required
  a direct candidate-manifest input. Diagnostics correctly consumed a completed
  runtime report through `--from-run`. The failed preflight wrote no publication
  products. Its successor verifies the full diagnostic → timed module → checked
  acquisition/attempt chain. A second preflight found catalog-relative source
  paths being resolved at repository root. V3 binds each source to its verified
  catalog and emission receipts to their report directory. Its complete read-only
  preflight passed 3,620 input checks before the successful 14-copy publication;
  both failed scripts and their exact input identities remain preserved.
- Candidate13 returned a function descriptor instead of a scalar after a real
  helper getter mutation. Its public wrapper used declared arity across a matcher
  boundary. 13b requires exactly that many consecutive leading lambdas; partial
  application, raw code calls, oversaturation and getter demand are now explicit
  controls. This was a compiler bug, not a changed expectation.
- The first worker10 isolation omitted the shared recursion-budget declaration
  and failed before timing. 10b restores that declaration; causal Nat comparisons
  use 10b, never the failed image.
- Nat controller v1 confused TypeScript's internal Number representation with its
  typed public BigInt ABI. V2 keeps the exact mathematical oracles and supplies
  shared BigInt inputs; it does not coerce unexpected results into passing.
- Record controller v1 assumed one contextual entry in the entire module. New
  valid helper roots made that assumption false. V2 selects the unique complete
  `G['bench']` AST assignment; all 4/57/61 semantic assertions remain unchanged.
- The first 17 source omitted a local `JRootPlan` annotation. 17b adds only that
  annotation, preserving the failed build and leaving physical line counts equal.

## Experiments retained, rejected and deferred

| Experiment | Decision and evidence |
| --- | --- |
| [001 immutable String results](../../experiments/phase45/P45-001-immutable-results.md) | Retained general admission rule; stronger five-round records replay showed 2.8185× improvement with remaining drift |
| [002 exact-entry state](../../experiments/phase45/P45-002-exact-entry-state.md) | Deferred; saved-JavaScript permission-object ablation was essentially flat |
| [003 native projection fields](../../experiments/phase45/P45-003-native-projections.md) | Retained for combined qualification; isolated lexer 1.7117×, Map 1.0820×, Unicode 0.9648×: mixed, not universal |
| [004 public fallback precursor](../../experiments/phase45/P45-004-worker-stack-policy.md) | Rejected before implementation: public fallback could reenter the exhausted wrapper and did not unwind native frames |
| [005 continuation worker](../../experiments/phase45/P45-005-continuation-worker.md) | Retained after SCC partition; initial giant function hit a measured V8 size limit; isolated tail-vector reuse lacked useful gain |
| [006 remaining frontier](../../experiments/phase45/P45-006-remaining-frontier.md) | Diagnosis only; guard cost, nullary entry and function-valued results remain distinct problems |
| [007 guard temporaries](../../experiments/phase45/P45-007-guard-temporaries.md) | Stopped before execution; imported custom Array.every behavior prevents the proposed contract-preserving shortcut |
| [008 nullary workers](../../experiments/phase45/P45-008-nullary-workers.md) | Original version rejected and reverted; four screens regressed. Later 21 is a separate ABI-correct experiment on the improved backend |
| [009 bounded native workers](../../experiments/phase45/P45-009-bounded-native-workers.md) | Retained with proper tail transfers and explicit non-tail fallback; deep controls distinguish both mechanisms |
| [010 private named fields](../../experiments/phase45/P45-010-private-named-fields.md) | Retained in the combined representation; one allocation removed structurally, isolated timing inconclusive across drift |
| [011 Number Nat](../../experiments/phase45/P45-011-number-nat.md) | Retained; positive paired 10b → 11 screen and exact public BigInt boundaries; change includes direct native operations |
| [012 primitive fences](../../experiments/phase45/P45-012-primitive-capabilities.md) | Historical hold preserved, including hostile pre-import counterexample;19 re-evaluates the same collector against the existing documented supported domain |
| [013 monomorphic roots](../../experiments/phase45/P45-013-monomorphic-roots.md) | Retained with 13b public-prefix fix; broad 16 regressions require profitability/selection correction |
| [014 native constructors](../../experiments/phase45/P45-014-native-constructors.md) | Retained after positive paired screen and actual-record mutation controls |
| [015 tail-only components](../../experiments/phase45/P45-015-tail-only-components.md) | Provisionally retained for less code and no needless machine path; isolated execution effectively flat |
| [016 typed root ranking](../../experiments/phase45/P45-016-root-plan-ranking.md) | Retained; recovers stronger existing plans, but 17b's long comparison required the additional 18 profitability gate |
| [017 nullary retry hypothesis](../../experiments/phase45/P45-017-nullary-retry-hypothesis.md) | Deferred proposal identified the missing public `.code.length` boundary; 21 supplies a separately controlled implementation |
| [018 alias-entry profitability](../../experiments/phase45/P45-018-acyclic-root-profitability.md) | Retained; exact SCC fact prevents expensive new acyclic public wrappers while preserving private helpers |
| [019 used primitive fences](../../experiments/phase45/P45-019-used-primitive-fences.md) | Retained after contract audit, eight suites and 40 positive-arity mutation controls; short timing mixed, no universal speedup claim |
| [020 acyclic readmission](../../experiments/phase45/P45-020-acyclic-reentry-ablation.md) | Rejected: generic row 5.1548× slower than 19 despite the smaller primitive fence; independent renamed fixture prepared but unexecuted |
| [021 nullary ABI](../../experiments/phase45/P45-021-nullary-abi.md) | Retained after demand/metadata controls and eleven-point screen;23 subsequently repairs newly exposed preflight hook observations |
| [022 canonical Unit](../../experiments/phase45/P45-022-canonical-unit.md) | Retained coverage extension after independent activation/value/public-boundary controls; existing corpus files unchanged, no timing gain attributed |
| [023 exact-entry preflight](../../experiments/phase45/P45-023-exact-entry-preflight.md) | Six supported post-import hook differences reproduced on22 and repaired; fresh23 nullary/Unit/hook controls and full selected qualification pass |
| [024 native String equality](../../experiments/phase45/P45-024-native-string-equality.md) | Unselected prototype: independent controls and unchanged-module checks pass; short Map/Set benefit has substantial drift and emitted code grows 56.5% |
| [025 equality with Number Nat](../../experiments/phase45/P45-025-string-equality-number-nat.md) | Unselected prototype: representation passes compose correctly; no useful isolated short-screen gain. Combined23→25 longer Map/Set comparison improves 1.378×, still 41.336× TypeScript, with 56.4% more emitted code and remaining drift |

The pre-import guard counterexample remains valid for that broader domain. The
later audit established that standard host intrinsics at module initialization
were already the supported contract: `selfhost/docs/ARCHITECTURE.md:152` dates to
`88619d9c`, and `docs/PHASE42_GENERATED_JS.md:123–129` to `f8e8ecc5`. Worker19 does
not relax that contract. It scans the complete original and private source graph,
including untaken branches, retains all source/native and full host guards, and
falls back to all primitive dependencies if analysis is incomplete. Forty fresh
supported post-import mutation observations pass. Host function identity alone
still does not establish native provenance under hostile pre-import shims.

## Selected worker23 source complexity and compiler cost

The final source accounting binds the frozen worker23 manifest, every listed
original/frozen source pair, checked attempt, API and runtime. The compiler has
**23,007 physical / 18,983 code Bend lines, 2,594 definitions, 87 types and
85 modules**. It adds 1,194 physical lines (5.47%) over Phase44; execution improved,
but **the total compiler did not become shorter**. Counts exclude runtime, host
tooling, tests, documentation, generated images and unlisted files. Code lines
omit blanks and whole-line comments; declaration counts are syntactic proxies,
not a count of semantic concepts.

| Compiler measure | Phase44 checked04 | Historical worker16 | Historical worker17b | Worker23 |
| --- | ---: | ---: | ---: | ---: |
| Physical Bend lines | 21,813 | 22,871 | 22,898 | 23,007 |
| Nonblank/noncomment lines | 18,025 | 18,887 | 18,902 | 18,983 |
| Definitions | 2,452 | 2,579 | 2,582 | 2,594 |
| Type declarations | 75 | 86 | 87 | 87 |
| Law declarations | 629 | 629 | 629 | 629 |
| Manifest modules | 78 | 85 | 85 | 85 |
| JavaScript backend lines | 7,800 | 8,858 | 8,885 | 8,994 |
| Selected generated compiler API bytes | 1,487,170 | 1,569,902 | 1,570,842 | 1,577,688 |

Phase44 → worker23 adds 958 code lines, 142 definitions, 12 types and seven
modules. The shared projection module has 52 physical lines and the six worker
modules have 989; existing modules add 153 net lines. These changes account for
all 1,194 additional manifest-listed Bend lines. The runtime is separately bound
and contains 56,140 bytes; it is excluded from the Bend source totals.

The historical17b snapshot added 1,085 lines (4.97%), 130 definitions and seven
modules over Phase44. Its shared projection module had 52 lines and six worker
modules had 971; existing modules added 62 net lines. It retired five obsolete
global-selection/fusion wrappers while introducing the typed plan result,
adding 27 net lines over16. Later selection, primitive-fence, nullary and Unit
changes bring worker23 to the final totals above. No earlier snapshot is
relabeled as the selected source.

The major added concepts are explicit private calls/values, exact SCC planning,
bounded native/machine execution, private tagged/native layouts, whole-graph Nat
representation and typed root-plan strength. They now have separate modules and
contracts. Ordinary Phase44 IR and historical specialized paths remain, including
compatibility boundaries; the implementation is not yet one fully unified backend.
Further cleanup should remove duplicated functionality as those transformations
migrate into shared IR passes, rather than merely deleting a faster existing plan.

The compiler is still written in Bend. Its selected **compiler API** is generated
JavaScript produced through the checked B1/equality-derivation workflow; it compiles
user programs whose **execution** the timing tables measure. This is not a newly
self-emitted fixed point. The generated-program runtime was byte-identical to Phase44 through worker20. Worker21 adds a nullary exact-code wrapper, and worker23 repairs private entry bookkeeping; the final runtime has a distinct identity. The controlled compiler-request comparison now passes all 36 expected-byte
checks across four sources, three rotated processes and three compiler roles.
The [compiler-cost report](compiler-cost.md) finds request medians **8.62% slower
for local pair, 28.55% slower for lexer, 1.32% slower for Map and 1.20% slower for
closures** than fresh Phase44 controls. Candidate/TypeScript request ratios are
6.160×, 11.684×, 15.957× and 4.547× respectively. There is no compiler-throughput
gain in this four-source comparison. Request, import and process boundaries
remain distinct; build/acquisition durations do not replace controlled timing.

## Evidence, status and next decisions

Pinned upstream remains `018751270e800bc222a93dad7f257083ee53a5f7`. Worker23's
checked API SHA-256 is
`e77c504a9c91d9ae9d43e52f4f4899711eb7a8ebe707ee565348df2708488b4c`,
with emitted runtime
`4f057842e476d01be5cfa06ad7984fea55ad2537b2fe6e861965a782e8b94c26`.
Selected source accounting is
`selfhost/build/phase45/complexity23-draft.json`, SHA-256
`75ef2f9ed6c80e029aee4910b7416b79a9718746a166668f68b300f902b6b7b2`.
Despite the retained `draft` filename, its source/API/runtime joins and counts
are complete; release qualification is a separate decision. Historical17b remains
in `complexity17b-draft.json`, SHA-256
`0f005c1c84a3a7fb5149c6687b537c1810b2fff2eeedabdb39815c6d4c495602`.

Raw campaign paths are local evidence, not public downloadable artifacts.
Current correctness results are `qualify-worker23/report.json`,
`nullary23-controls-v3/report.json`, `unit23-controls-v1/report.json` and
`exact-entry-hooks23/report.json`; the failed predecessor is
`exact-entry-hooks22/report.json`. The historical21 timing reports remain
`runtime-worker21-{fast,nullary,map-record}/report.json`. Complete23 timing uses
`qualification23/runtime-{0,1,2}/report.json` and the final
`qualification23/runtime-summary.json`, which exactly matches the earlier
validated preview. `qualification23/selected-qualification.json` closes the
standard semantic/runtime/cost gates before installation.
Historical screens, rejected/stopped attempts, checked module identities and
per-job commands remain under `selfhost/build/phase45`, indexed by
`campaign.jsonl`. The completed 17b first long batch and deliberately interrupted
second batch remain separate from all successful complete comparisons. Earlier
raw campaigns stay closed. The [final evidence index](../../selfhost/tools/performance/phase45/evidence/selected-release.json) binds all 55,014 archived files, exact release identities and protected-input checks.

| Final release result | Status |
| --- | --- |
| Exact selected compiler, runtime and manifest | PASS: worker23 selected qualification, 8,755 assertions / 3,203 input identities |
| Fresh 45-point execution comparison, point/source weighting | PASS: 669 samples, 3.0787× TypeScript equal-point and 4.1467× equal-source |
| Frontend, broader frontend and backend qualification | PASS: 3,026 main + 196 broader exact observations; all 81 backend rows agree, shared failures retained |
| Focused mixed-feature and boundary composition | PASS: fresh selected composition and separate23 focused controls; historical controls retain their original scopes |
| Controlled compiler-request comparison | PASS: all 36 expected bytes; request medians regress 1.20–28.55%, detailed per-source cost reported separately |
| Final source/module/line counts | Complete: exact frozen23 joins; 23,007 physical / 18,983 code lines, 2,594 definitions, 87 types, 85 modules |
| Installation and CLI release validation | PASS: normal install, release verification and all 42 ordinary/relocated smoke checks |
| Portable publication and curated evidence | PASS: selected23 portable exchange, 14 exact report copies, six retained17b path/hash identities |
| Closed raw evidence archive | PASS: 55,014 files, 1,194,248,393 logical bytes; 173,957,843 compressed bytes in five verified parts; all 103 protected files unchanged/unstaged |

Run the maintained fast-five canaries before feature-focused and full screens.
Keep the major private-graph gains and the recovered stronger existing plans.
Use new profiles to choose between remaining private allocation/frame traffic,
function-valued calls, supported data boundaries and entry cost. The selected Unit/Map and nullary coverage must remain bound to complete23
qualification; reopening acyclic public entry without new evidence would repeat
the rejected20 experiment. The [final native-equality study](native-string-equality.md)
retains candidates24/25 as uninstalled prototypes. Their local benefit is separate
from the selected45-point score; neither has full qualification or a controlled
compiler-cost comparison. Shared proof facts and shared private component
emission are the next architectural candidates for reducing repeated analysis and
code growth while extending coverage.
