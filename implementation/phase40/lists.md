# P40-L1 list investigation

Current selection: **checked06 is installed** with complete semantic, execution,
compiler-cost and release closure. Lists128/512 improve9.973×/13.113× over Phase39.
Checked05 remains performance-rejected for raytrace. Its list modules exactly
match fresh checked06 emission, so their complete paired timing rows are retained
under the reviewed [identity rule](../../design/phase40/identity-reuse.md).
See [final integration](integration.md), [execution](execution/report.md) and
[release](release-06.md). The chronological entries below preserve the status
and failed attempts at each earlier observation cutoff.

2026-10-02: saved-JS prototype authored within the first 15 minutes; no compiler
or Node execution by this owner. Correctness unchecked, measurement not run,
decision investigate. Root owns execution and any result-dependent changes.

Inputs: installed Phase39 current manifest and its byte-bound list module
`f8533e1dd7598b1ad848b05a04c2c9027542886a223cdc1ee9adc7e8286f10f5`.
The author inspected generated producer/filter/map/fold definitions and the
existing runtime exactCode/regionHostGuard/localGuard protocols. Original clean
output is identical to input. Producer-only and component both preserve BigInt
countdown; component materializes all three tagged List stages.

Tools: `selfhost/tools/performance/phase40/list-derive.py` and
`list-controls.mjs`. Each output directory must be fresh. Derivation consumes the
current manifest, module, and producer hashes; controls rehash all dependencies
and derived diagnostics before and after execution. Derivation is saved JS only,
not checked compiler output or production admission.

Focused gates: 49 complete-stage independent integer oracles; dependency
code/binding/getter mutations; exact-entry raw/forged/new/oversaturation/prefix/
argument-slot mutation and error controls; array/marker/Math host controls;
foreign tagged/getter/deferred producer and head/tail error observations; alias
and fresh Nil checks; full 30000-depth explicit-stage validation. Instrumented
private worker counts must prove actual admission and every refusal.

Source route assessment: do not drop zero-parameter guards. Grounded List needs
constructor telescope specialization, full parameter identity (including quantity)
and recursive-owner equality. Existing j_specialize can instantiate constructor
fields, but j_pure_type and j_fold_type currently bind recursion by owner name.
Changing those checks without full identity would be unsound. Producer unary
requires a saturated known combiner; p37.list/dbl instead return constructors.
Filter returns a list through a conditional combiner. suma changes its scalar
accumulator, currently refused by j_fold_call_args. Therefore admitting List alone
cannot optimize this component. A bounded general one-child structural transformer
plan should first be tested on zero-parameter tagged ADTs; grounded List admission
is a separate source proof obligation. Full-source integration is deferred until
saved-JS correctness and timing establish benefit.

Rejected/deferred: callbacks (Phase39 negative evidence), fusion (needs unfused
comparator), Number countdown (separate ablation), broad polymorphic ADT admission
(new dependent identity risks), runtime helpers (emitted indexed frames suffice).

## 2026-10-03 resumed outcomes

Root completed list-controls02:53 independent oracle rows,75 boundary rows and
2 admission rows pass. The initial list-controls01 RangeError is retained: its
producer-only deep full-stage test traversed unchanged non-tail generic filter
at2048. Corrected controls validate producer depth30000 independently, and full
component depth30000; producer-only complete stages stay512. No implementation
or semantic assertion was removed to make the optimized component pass.

Root's12.135-second saved-output screening passes. At128 the original/component
medians are0.484094/0.0327543ms (14.78×); at512,1.70265/0.0916638ms (18.57×).
Producer-only changes give1.22×/1.08×. These are selected short saved-JS signals,
not compiler gains or final retention evidence. The unchanged original control
has0.43548/1.78123ms medians; root retains full paired samples separately.

Exact consumed producer recovery: list-derive-v1.py is5205bytes with SHA
ba1902ef3261e2fc051756d72cd04ff16f79e1988c292813f3bc02a8abdc9738;
list-derive-v2.py is5510bytes with SHA
4da6002d58e1308f5f92e7dfb3e139afecedad6b8dd1f044161d6e32dea1b28a.
These match original derive01/02 manifests without altering those records. Future
list-derive.py outputs freeze consumed-derive.py and bind its immutable identity.

The first general source proposal is applied after root's tree-only source
snapshot. Root checked02 succeeds in44.93seconds but list-pipeline remains exact
unchanged119735bytes with no direct workers/private root. This is a failed
admission attempt, not a speed/correctness failure. Root-run list-plan-probe.mjs
will inspect actual checked KTerms and ground-type/plan gates before another
build. A stray source quote from proposal generation was removed before the
checked build; the generator correction is retained. Independent tree/evidence
review of continuation/proof design found no blocker at its current scope.

The checked03 layout correction activates the list path: root observes148147
bytes, six structural workers and one private scalar root versus119735bytes,
zero workers/root in Phase39. The diagnostic type probe established the actual
Base ABI: List/Nil/Con are native, and specialized Con fields have quantity1.
The corrected proof requires those exact flags/quantities, and narrow List
admission in component/finite gates. General quantity/type cases remain generic.

Own review then refused primitive-call unary combiners: their purity path emits
operators directly and does not capture mutable G bindings. The new generic
combiner invocation must not read such an uncaptured binding. Checked04 includes
that refusal, and fixture-v3 adds affine/nested List and primitive-combiner
negative controls; fixture-v2 remains immutable after acquisition.

Actual checked04 list-controls01 fails after seven depth-zero oracle rows with
ReferenceError `$u2` in ground.make. The failure is retained. Diagnosis: analysis
Env records descendant `@child` provenance; lexical emission Env does not.
Reusing the ownership recognizer during emission returned child sentinel32,
causing a recursive `$u1` computation, empty next arguments and nonexistent
before-slot references. Emission now recovers only the already-proved saturated
self-call shape through dedicated helpers. Compile-time proper-descendant and
whole-graph/backedge proofs are unchanged. This also corrects direct tail
recognition. No successful correctness claim precedes the next actual controls.

Checked05 actual source controls pass: list-actual-controls02 contains52 oracle
rows,106 host-boundary rows and one admission row. Its49 bounded stage points
compare complete produced/filtered/mapped List and independent Chain values,
folds and ordinary export results with an independent BigInt integer oracle;
three additional rows exercise depth30000. The admission call raises successful
root count49→50 and each of all eight actual ground/chain worker counts98→99.
Aggregate producer/filter/map/fold counts each196→198. Root instrumentation is
inside the try after regionProofOpen($guards), and diagnostic adapter proof
openings use a different expression, so diagnostic calls cannot supply this
ordinary-export root witness. Clean modules are byte-identical to checked parents;
instrumentation adds counters/adapters only and binds frozen consumed scripts.

Boundary evidence compares exact values, errors and live event order across
Phase39/candidate, including dependency code/G getters, arguments, mutation,
throw/reentry, Array/BigInt/Math hooks, foreign deferred fields and refusal paths.
Hostile ordinary calls may enter another independently guarded region after
fallback; explicit diagnostic-refusal rows require no private producer entry.
This distinguishes fallback semantics from the successful whole-component proof.
Affine/nested/Bool/Nat List and same-input/primitive-combiner definitions retain
no new structural worker. This was the checked05 correctness checkpoint; the
later scalar-island precedence correction is recorded below.

Independent pinned TypeScript fixture-v3 public stage/export comparison is
prepared in list-typescript-controls.mjs. It verifies all three checked receipt
input identities, compares each compiler's own representation to integer-oracle
heads/tags, checks false-combiner child identity and49 size/seed points. This is a
separate independent correctness comparator, pending root execution; hostile
runtime hooks remain specific to the self-host runtime controls.

The former-final checked05 development-final01 ten-point campaign completes
successfully in184.472s, but checked05 is subsequently rejected for performance
on historical raytrace. The following list timings are retained diagnostic rows.
Five fresh pinned-CPU rounds per role use600ms warmup and250ms measurement; these
are generated-program execution measurements, not compiler speed measurements.
Static calculations and input report identities are in list-final-timing01.json.

| List size | Phase39 median ms (min–max) | Checked05 median ms (min–max) | Ratio of medians | Round-paired Phase39/checked05 ratios |
| --- | --- | --- | --- | --- |
|128|0.446039 (0.442908–0.446615)|0.044725 (0.044193–0.044734)|9.973×|9.990,10.093,9.985,9.979,9.903|
|512|1.739693 (1.663637–2.036742)|0.132664 (0.130180–0.133899)|13.113×|15.646,13.562,12.425,13.214,13.009|

Within-call half drift is10.77…12.26% for Phase39 at128 and−19.93…−1.76%
at512; checked05 drift is−4.66…−3.00% and2.03…4.69% respectively. The
512 baseline spread/drift makes its precise ratio less stable, but all paired
ratios exceed12×. TypeScript medians0.006863/0.029402ms still lead checked05 by
6.52×/4.51×. The other eight selected points are unchanged-byte controls:
closures64/256, Unicode16/64, map32/128, numeric256/1024. Their Phase39/candidate
median ratios are1.012,1.002,1.034,0.995,0.995,1.010,1.005,1.007 respectively.
These movements measure run noise; they cannot be attributed to source changes.

The separate saved-JS confirmation uses three rounds,350ms warmup and150ms
measurement. At128/512 original medians0.427217/1.660570ms and specialized
component medians0.030525/0.078045ms give13.996×/21.277×; paired ratios are
14.206,13.931,13.772 and21.358,21.174,21.500. Its unchanged-byte noise medians
0.424597/1.668883ms corroborate that comparison. Actual checked compiler code
therefore retains a large gain but trails this prototype's selected signal.
The protocols differ: cross-run candidate medians are descriptive comparisons,
not a paired ablation establishing where the performance gap originates.

Inspection suggests plausible overhead in the general source mechanism. Actual
producer/filter/map continuations save a frame object, argument array and before
array per node, create next-argument arrays, restore owner arguments and replay
constructor-prefix matching during unwind. The prototype saves only head numbers
in a dense array and rebuilds in a direct loop. Actual tail fold also forms a
next-argument array each step; prototype updates scalar locals. Actual code uses
ctor dispatch and the existing shared phase0/1/2 continuation skeleton, while the
prototype directly creates tagged objects. Both retain tagged intermediate
stages, BigInt producer countdown and native U32 operations; both remain unfused.
Frame/argument representation, repeated tests and general constructor handling
could explain the shortfall. This is an inspection inference, not an isolated
measured cause; this inspection itself introduces no source change.

Historical raytrace checked05 timing raises a regression concern; final paired
measurement remains root-owned. Static comparison identifies new global colf
and rowf structural workers plus a new bench root. That direct region route
bypasses the retained Phase39 colf scalar island and its nine local helpers:
the old island's leaf calls private colf.px directly; global colf instead calls
the ordinary curried G.colf.px runtime. The historical fixture traverses64 rows
and16384 column leaves per row (1048576 total), although most columns lie beyond
width80. Generic leaf dispatch is therefore a plausible dominant regression
cause. This is not a lost Number-countdown optimization: the old scalar tree
already uses BigInt, since its predecessor also enters U32.shln.

Root authorizes a narrow correction after independent tree review: only the
new Nat-first component alternative excludes scalar result types through
j_region_scalar(book,j_fold_root_result(book,dt(d),da(d))). Existing JPure
signature proof still verifies every retained nonscalar result as a closed ADT
or grounded List. Nat data producers remain admitted; List/ADT-first scalar
folds remain admitted; existing Nat scalar islands retain prior selection.
The exact source delta is list-nat-scalar-precedence.patch. Checked05 controls
and timing are preserved; fresh source evidence must use a new checked attempt.

list-scalar-island-controls.py supplies a static independent refusal witness:
entire historical raytrace candidate bytes must equal Phase39, colf/rowf source
signatures must be Nat→U32, no new structural worker/root may appear, and both
retained scalar islands must carry entry/host/local guards, closed proof scope
and relevant leaf dependencies. It also requires the private colf.px leaf call.
Root runs this after the corrected emission, plus fresh actual List/Nat/linear
controls bound to the corrected API. No regression recovery claim precedes them.

The selected corrective checked06 source passes fresh actual List controls
(list-actual-controls06:52 oracle rows,106 boundaries, one admission), independent
pinned TypeScript List/Chain public complete-stage/export controls
(list-typescript-controls06:49 rows), Nat controls
(tree-nat-controls06:302 oracle rows,84 boundaries), and mixed unary/binary
linear controls (linear-order-controls06:160 oracles,12 order witnesses,
36 boundaries). Each fresh diagnostic binds checked06 receipts/API; no passing
checked05 result substitutes for the new source check.

Actual List fixture checked06 output is byte-identical to checked05:119867bytes,
SHA2568f4f3f62b6d7bd7c2c924b1c794d5fffc60b32eb946564714dc80caffcd879b0.
The scalar-island static control passes three checks, requiring complete
historical raytrace byte equality with Phase39 plus both typed refusal/guard
owner witnesses. Thus the corrective Nat result gate removes the competing
Nat→scalar route while preserving the independently validated List output.

The fresh precedence-screen06 completes47.620s with Phase39/candidate median
ratios: historical raytrace0.999705 (same bytes), tree-bitonic2.538105,
list51213.314126 and scalar8192 0.996058. This bounded confirmation supports
regression recovery and retention of List/Nat-data gains. Same-byte ray/scalar
ratios measure run variation; no code-speed gain is attributed to them.
Corrected final45-point candidate preparation/timing remains root-owned and
pending at this checkpoint. Earlier checked05 campaign rows and source hashes
remain preserved as rejected-candidate diagnostic evidence.

Inherited recursive-fold owner gate on checked06 fails after27 successful oracle
rows and iterative structure checks because its broad frame counter observes2
entries for benchDeep. Inspection separates them: one new admitted fold.make
structural producer and one original private $node fold. This is an obsolete
diagnostic counter expectation, not a discovered value/order failure. Original
Phase35 tool and failed final-plan02 owner report remain preserved unchanged.

Authorized fold-controls-v2.mjs preserves every inherited semantic/boundary
assertion and the requirement of exactly one fold entry, narrowing only its
instrumentation marker to the original $node frame initializer. It independently
counts the single actual fold.make structural worker and requires producer
entries1/0/1/1 for Deep/Shared/Weight/Record. It also requires exact captured
root/producer/fold guard owners, host/local entry guards, region coverage and
proof finally restoration. The JSON derivation record binds the unchanged
parent and derived script; exact substitution replay passes before execution.
Successor runtime controls remain pending root execution at this checkpoint.

The final auditor accepts an owner mapping row with both direct successor
control and unchanged fold-guards report identities, each complete/pass/error-free
and independently reaching the selected API and attempt through tested hash
edges. The new guard config binds checked06 attempt/API identities; the unchanged
guard script consumes that config. This closes provenance without changing the
auditor, rewriting the failed wrapper, or substituting an unrelated final API.

The consumed v2 successor fails on benchShared's distinct producer expectation
after the inherited27 oracle rows pass. This expectation was incomplete: source
fold.share binds fold.make once, then Two{child,child}; its emitted residual
invokes the global producer under region coverage opened by benchShared. Thus
one producer entry is independently required even though benchShared's own
line contains no direct producer invocation. V2 files/failure remain immutable.

fold-controls-v3.mjs derives from exact v2 and changes the shared producer
expectation to1, extends captured guard inventory to
benchShared/fold.share/fold.make/fold.size, proves one emitted producer call
inside the shared binder, and requires both actual fold.size input child slots
to alias. The original fold-entry requirement remains1 throughout. Its JSON
record binds parent derivation and failed v2 report; exact substitutions replay
and emitted shared-binder pattern checks pass statically. Runtime validation is
pending root execution; no semantic assertion or compiler source is changed.

Before v3 consumption, root review catches an unescaped single-quoted Two literal
inside its generated witness-source string. Explicit pinned Node24 --check
confirms the syntax error; changing that inner literal to double quotes repairs
it. The unconsumed failed syntax source is preserved as
fold-controls-v3-syntax-failed.mjs (SHAa7756356…516ebe). V3 script/derivation/patch
are updated coherently: corrected SHA04d05cf0…55db04, exact parent substitution
replay passes, and pinned Node --check exits0. This is static validation only;
successor execution remains pending, and v2 consumed artifacts remain unchanged.
