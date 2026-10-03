# P40-L1 list investigation

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
no new structural worker. No source edit follows this passing source snapshot.

Independent pinned TypeScript fixture-v3 public stage/export comparison is
prepared in list-typescript-controls.mjs. It verifies all three checked receipt
input identities, compares each compiler's own representation to integer-oracle
heads/tags, checks false-combiner child identity and49 size/seed points. This is a
separate independent correctness comparator, pending root execution; hostile
runtime hooks remain specific to the self-host runtime controls.
