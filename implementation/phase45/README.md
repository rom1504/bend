# Phase45: private execution graphs and composable backend selection

**Worker23 is the current development candidate; final release qualification remains pending.** Phase44 checked04 remains installed. Worker23 freshly passes eight maintained suites, nullary-demand/metadata controls, Unit/Map controls and six post-import host-hook checks. Its full representative acquisition and qualification are underway. This report consolidates the [design](../../design/phase45/README.md), experiments and intermediate results without claiming release promotion.

The main finding is that complete private call graphs, suitable data representations and careful backend selection produce much larger gains than local expression cleanup. In the earlier worker21 screen, Map 128 takes 1.398 ms against Phase44's 22.803 ms and record aggregation takes 1.965 ms against 103.511 ms: **16.31× and 52.68× faster**, with remaining pinned TypeScript gaps of **1.721× and 1.551×**. These are combined-candidate results, not isolated nullary gains. Two tiny library programs also improve, but substantial generic-execution gaps remain.

The broader comparison mattered. Worker17b's first long batch exposed a 10.77× generic-row regression missed by the earlier selected screen. Worker18 restored the old output through a general alias-only entry profitability gate. Worker20 retested acyclic admission with fewer primitive guards and still slowed that row by 5.15×, so it was rejected. Worker23 preserves the corrected selection policy. It also fixes a supported post-import runtime observation discovered on worker22; the failed and passing observations remain separate evidence.

**There is no completed Phase45 aggregate or parity claim yet.** The preceding qualified 45-point result remains Phase44's 6.0832× TypeScript time with equal-point weighting and 8.3015× with equal-source weighting. Selected Phase45 screens cannot replace that result or predict typical application speed. These maintained workloads informed optimization; they are not untouched holdouts.

## Historical worker21 screen; worker23 full comparison pending

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
performance table and chart will appear in [the final execution report](results.md)
only after all three fresh batches and their identity-bound summary complete.

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
5. **Select a completed optimization.** Worker17b carries `JRootPlan{code,strong}`
   from the actual planner. Successful complete fusion, a region without residual
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
Worker17b remains a rejected historical candidate. The repaired descendants still require a completed fresh broad comparison.

## Correctness evidence and preserved failures

Worker23 freshly passes all eight maintained suites. Its nullary controller
passes six oracles, 39 boundary observations, six activation observations and
nine descriptor-metadata comparisons. Its Unit controller passes 27 numeric
oracles, ten mutation boundaries, four activation observations and two public
ABI/object bundles. Six post-import hook traces agree with ordinary source
invocation. These focused counts have different scopes; they do not establish
full frontend/backend or final composition qualification.

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
from Phase44, including the frontend. Full frontend/backend qualification and
installed-release closure remain pending for the final survivor.

Several failures changed the implementation or harness and remain visible:

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
| [023 exact-entry preflight](../../experiments/phase45/P45-023-exact-entry-preflight.md) | Six supported post-import hook differences reproduced on22 and repaired; fresh23 nullary/Unit/hook controls pass, full qualification pending |

The pre-import guard counterexample remains valid for that broader domain. The
later audit established that standard host intrinsics at module initialization
were already the supported contract: `selfhost/docs/ARCHITECTURE.md:152` dates to
`88619d9c`, and `docs/PHASE42_GENERATED_JS.md:123–129` to `f8e8ecc5`. Worker19 does
not relax that contract. It scans the complete original and private source graph,
including untaken branches, retains all source/native and full host guards, and
falls back to all primitive dependencies if analysis is incomplete. Forty fresh
supported post-import mutation observations pass. Host function identity alone
still does not establish native provenance under hostile pre-import shims.

## Historical source complexity and pending compiler-cost comparison

The frozen 17b counts below precede the later selection, primitive-fence and nullary changes; final candidate counts are pending. The new backend improves execution mechanisms but **does not simplify the total
compiler by line count**. Counts enumerate each frozen compiler manifest, excluding
runtime, host tooling, tests, documentation and unlisted files. Code lines omit
blank lines and whole-line comments; declarations are syntactic proxies.

| Maintained compiler measure | Phase44 checked04 | Worker16 | Worker17b |
| --- | ---: | ---: | ---: |
| Physical Bend lines | 21,813 | 22,871 | 22,898 |
| Nonblank/noncomment lines | 18,025 | 18,887 | 18,902 |
| Definitions | 2,452 | 2,579 | 2,582 |
| Type declarations | 75 | 86 | 87 |
| Law declarations | 629 | 629 | 629 |
| Manifest modules | 78 | 85 | 85 |
| JavaScript backend lines | 7,800 | 8,858 | 8,885 |
| Selected generated compiler API bytes | 1,487,170 | 1,569,902 | 1,570,842 |

Phase44 → 17b adds 1,085 lines (4.97%), 130 definitions and seven modules. The new
shared projection module has 52 lines; six worker modules have 971. Existing modules
add 62 net lines. Worker17b retires five obsolete global-selection/fusion wrappers while
introducing the typed plan result; its net addition over 16 is 27 lines. These
figures neither count semantic concepts mechanically nor establish maintainability.

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
self-emitted fixed point. The generated-program runtime was byte-identical to Phase44 through worker20. Worker21 adds a nullary exact-code wrapper, and worker23 repairs private entry bookkeeping; the final runtime has a distinct identity. No fresh controlled compiler-request comparison has yet established
Phase45 compiler-throughput or end-to-end iteration-speed improvement. Build and
acquisition durations must not be relabeled as either metric.

## Evidence, status and next decisions

Pinned upstream remains `018751270e800bc222a93dad7f257083ee53a5f7`. Worker23's
checked API SHA-256 is
`e77c504a9c91d9ae9d43e52f4f4899711eb7a8ebe707ee565348df2708488b4c`,
with emitted runtime
`4f057842e476d01be5cfa06ad7984fea55ad2537b2fe6e861965a782e8b94c26`.
The historical 17b size receipt remains
`selfhost/build/phase45/complexity17b-draft.json`, SHA-256
`0f005c1c84a3a7fb5149c6687b537c1810b2fff2eeedabdb39815c6d4c495602`.

Raw campaign paths are local evidence, not public downloadable artifacts.
Current correctness results are `qualify-worker23/report.json`,
`nullary23-controls-v3/report.json`, `unit23-controls-v1/report.json` and
`exact-entry-hooks23/report.json`; the failed predecessor is
`exact-entry-hooks22/report.json`. The historical21 timing reports remain
`runtime-worker21-{fast,nullary,map-record}/report.json`. Complete23 timing will
use `qualification23/runtime-{0,1,2}/report.json` and its summary.
Historical screens, rejected/stopped attempts, checked module identities and
per-job commands remain under `selfhost/build/phase45`, indexed by
`campaign.jsonl`. The completed 17b first long batch and deliberately interrupted
second batch remain separate from all successful complete comparisons. Earlier
raw campaigns stay closed; final archive closure is pending.

| Final release result | Status |
| --- | --- |
| Exact selected compiler, runtime and manifest | Worker23 development candidate; final qualification pending |
| Fresh 45-point execution comparison, point/source weighting | Pending; no Phase45 aggregate claimed |
| Frontend, broader frontend and backend qualification | Pending for selected image |
| Focused mixed-feature and boundary composition | Pending final image; fresh23 focused evidence and historical controls retained |
| Controlled compiler-request comparison | Pending |
| Final source/module/line counts | Pending; 17b historical counts above |
| Installation, portable evidence archive and release closure | Pending; Phase44 checked04 remains installed |

Run the maintained fast-five canaries before feature-focused and full screens.
Keep the major private-graph gains and the recovered stronger existing plans.
Use new profiles to choose between remaining private allocation/frame traffic,
function-valued calls, supported data boundaries and entry cost. The selected Unit/Map and nullary coverage must pass complete23 qualification; reopening
acyclic public entry without new evidence would repeat the rejected 20 experiment.
