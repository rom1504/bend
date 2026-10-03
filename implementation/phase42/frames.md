# Phase42 frames: implementation status

The saved-output prototype and bounded recursion diagnostic are ready in
`selfhost/tools/performance/phase42/frames/prototype01/`. The producer records
input/output SHA256 and exact live variable lists in `derive.json`; all three
modules pass Acorn syntax parsing. No production source or old evidence changed.

| Worker | Original bytes | Live-continuation bytes | Saved live slots |
|---|---:|---:|---:|
| warp | 4675 | 2443 | 3 |
| flow | 3930 | 1986 | 3 |
| bsort | 2570 | 1920 | 3 |
| scan | 1655 | 1021 | 1 |

Total four-worker text shrinks 12830 to7370 bytes. Counts are static code size,
not executed work or performance. The live role removes two resumed match
prefixes, parent argument restoration, and per-push saved args array allocation.
The child `$next` tuple remains unchanged. Original has full original argument
vectors; live has scalar properties holding needed right/combine lexical values.

`prepare-controls.mjs` derives diagnostic modules and a scoped copy of the
existing Phase41 independent control owner. It records both owner hashes and
marks the new derivation `checked:false`. The recursive-ceiling role is excluded
from deep-stack equivalence; it is diagnostic and nondeployable.

Initial tool attempts failed because node was not in PATH, then because the
standalone identifier analysis lacked the `$visit` label, then because combine
extraction repeated prefix declarations. These were corrected before generation;
no failed candidate was timed. Adapter preparation exposed a syntax typo and a
missing inherited `all` constant; both were corrected before control execution.
The observed failures remain in the collaboration transcript; the bounded sanity check subsequently passed.

Correctness: syntax and tiny18bench/6alias controls passed on Node24.12.0 in0.11s; awaiting root reproduction on pinned Node24.18.0 and full controls. Measurement: awaiting root.
Decision: investigate; source promotion and source.patch depend on a surviving
mechanism and exact binder/live-use proof. Existing Phase41 proof is reused,
not weakened. Four-worker fixture restriction is explicit; unary remains excluded.

Root's corrected pinned-node screen reports live continuations only
1.015/1.018/1.029× faster at the three tree points; the bounded recursion
ceiling spans0.998–1.083×. This is a final small/null mechanism result, not a
source promotion. Root retains the exact serial run receipts. The frame rewrite
is deferred; its syntax tools, original diagnostic artifacts and failed attempts
remain preserved.

The subsequently assigned inherited-proof context investigation has an independent
source proposal at `frames/context-source.patch`, generated reproducibly by
`frames/make-context-patch.py`. It does not install the live-frame rewrite.
The proposal rewrites only admitted component emission bodies under their complete
JPure context. A nonself target must have its own valid component plan and every
transitive definition must match the context and canonical book by `exact_def`.
Missing, changed or same-name/different-body definitions retain guarded emission.
The public/runtime entry guard remains untouched. Existing JCall carries a private
mode bit selecting the already emitted `$tree` function; Ann preserves original
result typing for ordinary binder inference.

This patch intentionally depends on the calls owner's `j_direct_call_term` fallback
for acyclic helper lowering. It has not been compiled, timed or integrated here;
root's serial queue owns those gates. Source review is pending. Original frame
admission, self-recursive Ref nodes, argument vectors and deep continuation shapes
remain in the original emitter.

The whole-private-graph followup has a separate source proposal at
`frames/owned-constructor-source.patch` and generator `frames/make-owned-patch.py`.
It includes private component activation, direct tagged constructor literals and
marked unary reconstruction. Calls owner's `calls/owned-helper.patch` activates
admitted acyclic helpers. This is an uncompiled experimental supplement to the
already separate calls/context candidate; no constructor timing claim is made.

The final proposal leaves generic deferred `build` lowering unchanged. Closed
nonnative source types gate same-tag object/field-array construction; native
constructors remain on their original emitter. The guard and graph proof still
come from the original terms. Exact field order, fresh root allocation, child
aliasing and existing structural frames are preserved by construction; root must
validate the actual checked emission and controls before admission.

Actual constructor comparison tools are prepared, unexecuted:
`frames/owned-actual-derive.mjs` / `owned-actual-controls.mjs` compare checked02
and checked03 tree modules with clean-byte preservation, full inherited calls
controls, native ABI checks and exact direct-constructor AST/admission counters.
The separate `owned-fixture.bend` / `owned-fixture-derive.mjs` /
`owned-fixture-controls.mjs` cover unary reconstruction, every-node freshness,
native List/Nat/Bool helpers, generic getter/throw ordering, and unguarded public
unary depth 30000 deferred fallback. The fixture's independent scalar oracle is
46 at main, and modulo-U32 arithmetic-series totals for the ordinary root grid.
Root owns parsing/checked emission/control execution; this owner has not run them.

The broader actual list gate exposed a real inherited-context bug: rewriting an
outer unary combiner App to JDirectCall erased the saturated original spine used
by structural child-position discovery. The broken keep_gt1 worker emitted an
empty next vector and invalid resume variables/name. Those failed actual modules
and source build attempts remain root-owned retained evidence; controls were not
weakened. `owner-thread-source-v1.patch` preserves the first corrective attempt,
whose generator omitted the new owner parameter from j_covered_terms due to a
literal replacement typo. Root's checked06 cheap gate caught that compile blocker.

The correction is `owner-thread-arity-fix.patch`; the reproducible producer is
`make-owner-thread-patch-v2.py`. The owner is explicit in the existing transform
family. An App subtree containing the original owner Ref keeps its original
App/Call shell while independent argument descendants still optimize. Bounded
reference-scan exhaustion conservatively refuses replacement. Static read-only
arity review covered all10 changed definitions/calls, and a search of every
selfhost source Bend module found no external callers requiring another update.
No compiler rerun or production edit was performed by this owner.

BST probe02 established the actual pair quantities1/1 (nonerased) and List
quantity2, superseding any2/2 Sigma assumption. Down prefix already passes,
Tuple elimination blocks step/insert.fin, and up's mutually exclusive branches
have single self-tail leaves. Build's computed scalar Let and inorder's sequential
child calls remain independent structural admission obligations. The representation
proposal explicitly retains them; it does not claim native layout admission alone
reaches the manual whole-graph ceiling.

Root/review accepted the simpler logically closed global JPure domain instead
of a new owned mode/cache hierarchy: source shape proof is not public ownership,
and every private call still requires the full scalar-root guard/proof. The
candidate native emitter is `frames/bst/native-emitter-source.patch`, generated
by `make-emitter-patch.py`, adding27lines over tree/finite sources. It covers
component and finite/direct helper Tuple projection and closed List admission,
retains runtime/native constructors and the U32 list algorithm selector, and
passes a read-only12-occurrence signature/call arity check. Actual checked
emission, complete values and negative controls remain root/calls-owned pending.

Host-callback falsifiers are frozen as independent diagnostic evidence.
`frames/preimport-bigint-counterexample.mjs` executed producer/retained bytes are
SHA256 b324d9a0ad8c0faaa7b01a743da01bf2a9480207ef1bab55f1b0bb7d015559b1.
Root's `selfhost/build/phase42/preimport-bigint-counterexample01/report.json`
records a real checked07/checked11 sequence counterexample: proxy-fold 26 versus 30,
outer 47 in both, and mutation callback 7 original code events versus 0 candidate.
Root holds the new bridge/native/sequential matched set. Public proof suspension
alone cannot repair a private callee selected before a converter callback mutates
its dependency, and replaying the root would duplicate the callback.

The separately frozen retained-core witness is
`frames/preimport-safe-core-counterexample-v1.mjs`, SHA256
40f579ad79a8660cb8f1c3862ea57c0bd7817bacfd43d6ab49d24168374404b2.
Root's core-boundary-tree-BigInt-01, core-boundary-tree-imul-01, and
core-boundary-fusion-imul-01 report directories retain all actual values, property
accesses, descriptor mutation events, primitive call order and worker counts.
Tree public scan/flow reentry traces match; tree helper mutation events differ.
Fusion also changes wrapped Math.imul call order and mutable dbl observations.
These are actual counterexamples under arbitrary pre-import callbacks. They do
not establish a portable native-provenance oracle from regionHostGuard's captured
current identities. Root reviewed the existing Phase30/36/40 standard-at-import
intrinsics contract and retained core/flat/fusion within that same boundary;
Phase36 guard-scoped-proof.md and private-producers.md explicitly exclude a
universal equivalence claim for arbitrary pre-import monkey-patching. The new
negative traces remain failed evidence, not relabeled passing controls.

The next continuation discriminator is frozen but not executed by this owner:
`frames/hybrid-flat-derive-v1.mjs` and `hybrid-flat-controls-v1.mjs`. It derives
bounded native prefixes 4/8/16 from the exact checked09 flat binary workers,
then hands current operands to the original iterative worker. The original
worker dependency DAG is checked for cycles; helpers, BigInt Nat, constructor
layout, source algorithm and operation order are retained. Complete generated
trees/Stat/public scalars are checked against an independent same-algorithm
oracle, with mixed/asymmetric/shared cases, fresh roots/aliased children, and
actual scan depth 30000 requiring the iterative fallback. This is a saved-output
performance discriminator, not a compiler source integration or a Number/algorithm
change. Root owns all execution and measurement.

Root subsequently completed the source BST/sequential matched-set13 controls.
Under the already documented standard-at-import host contract, the pre-import
callback diagnostic does not itself block that bridge/native source route. The
initial hold remains historical; it is superseded by root's successful supported-
boundary validation. No universal arbitrary-host equivalence claim is added.

Hybrid derivation01 failed its exact four-worker assertion before any outputs:
its selector demanded a flat field read and omitted bsort, which creates flat
values but takes scalar/Nat inputs. Frozen v1 is retained. Version2 selects the
original framed declarations by containment inside the exact flat-graph block,
then retains the same exact four-worker and binary-spine checks. No local runs.

Root's corrected hybrid-flat02 derivation and hybrid-flat-controls02 pass:
168 complete/warp observations, 48 ordinary scalar entries, 20 freshness/alias
assertions, and four scan depth 30000 cases. Every hybrid deep case recorded
minimum budget 0, two original iterative fallback entries and no active proof
on exit. Clean screen hybrid-flat02-screen01 measures literal 16 at 0.368417 ms
versus original 0.570217 ms at tree8; tree9 is 0.921017 ms versus 1.350445 ms and
tree6 is 0.076507 ms versus 0.102197 ms. Algorithm, BigInt Nat and flat layout stay
identical; this isolates bounded continuation handling. The benchmark remains
slower than pinned TypeScript, and no algorithm/Number speedup is attributed.

The isolated source candidate `hybrid-source-v1.patch` adds 58/removes 2 lines of
tree.bend. Canonical prepatch SHA256 is
f8d705f0a38693f39e7f42a0343fe8b3ab12f513e80d0c8f6a916b27ad387791;
frozen patch SHA256 is
a1a6dfd6b65fe91356ab8434c51409b2f320f96bb480db5b6ad6691430951ae8.
Independent review approved original typed binder/order preservation, binary
refusal, budget-before-demand and existing full-closure backedge/DAG proof.
Root applied it and owns source14 compilation and actual validation. The actual
comparison tools are `hybrid-actual-derive-v1.mjs` and
`hybrid-flat-controls-v2.mjs`: four literal 16 hybrid markers, budget 0 before
prefix, byte-identical original iterative fallback bodies, ordinary/full values,
asymmetric/shared cases, aliases and actual deep fallback counts. No source
integration has been marked complete merely from the saved-output screen.

Root checked14 build passes in 47.27 s. Actual source integration derivation
`selfhost/build/phase42/hybrid-actual14/derive.json` and controls
`selfhost/build/phase42/hybrid-actual14-controls` pass in 0.67 s/0.5 s.
The four emitted iterative fallback bodies are byte-identical to source13;
all four actual hybrid wrappers use literal 16 and check budget0 before prefix.
The two-module controls cover 84 complete/warp observations, 24 ordinary scalar
checks, 10 freshness/alias assertions and two scan depth30000 runs. Candidate
counters record 6317 hybrid activations, 2 fallback entries, minimum budget0,
no active proof on exit and deep-fallback delta 2. Root's candidate API is
ee2239af083829f4b5a8aad0e446c2fb3d683b520b12d64b1162b69691098788,
with unchanged runtime 6dbda18f176702557041530652690601c32b09261327ad49af7bf0cc8e7fb81c.
Validation owner received exact groups, identities and assertions for final
matched-v4 extension. Actual source performance confirmation is root-owned.

Actual checked source confirmation `hybrid-actual14-screen01` passes separately
from the saved hybrid-flat02 prototype. Median source13/source14/TypeScript ms:
tree8 0.647930/0.442217/0.316952; tree6 0.105213/0.076815/0.038534;
tree9 1.350673/0.838008/0.685509. Source14 gains 1.37–1.61x over source13,
while remaining 1.22x TypeScript at tree9, 1.395x at tree8 and 1.99x at tree6.
These are bounded hybrid continuation gains with unchanged algorithm, BigInt
Nat and flat layout. Final full boundary/fixture/matched-set gates remain
root-owned; this screen alone is not their substitute.

Native-owned source15 is a separate valid constructor change. Static source13
inspection finds exactly one zero-field ctor False and one zero-field ctor True
in the flat bsort iterative body; the other three framed bodies contain neither.
Thus the original hybrid-v1 identity test against source13 cannot remain literal
for that one body after source15. The checked source14 strict four-body witness
is retained unchanged, as are all frozen earlier producer versions.

`hybrid-actual-derive-v2.mjs`, SHA256
f921b4e717cfa30d7ae01b812f919c41544aee1bf9945a5d8a55681a1a2c8e8a,
normalizes only a temporary identity-witness body string. Exactly two baseline
bsort AST calls must have tags True/False, two arguments and empty field arrays;
the substitutions are only true/false literals. The complete source15 candidate
fallback body must equal that expected string, and both literal AST positions,
values and text must correspond. The other three fallback bodies retain raw
byte identity. Site offsets, texts and hashes plus before/normalized/actual body
hashes are recorded. The witness is explicitly derived unchecked, parentChecked,
and nonexecutable; source13.clean module bytes and executable baseline behavior
remain unchanged. Existing independent source15 native-header/constructor proof
and full-value controls cover the separate native optimization.

Read-only actual source15 inspection confirms the predicted bsort comparison:
raw source13 body 3aaa8da35c3b60519210ee25dd3f12f610ae7ad0bd4f307f777bc118879f155b;
normalized/actual source15 body
d83a345707a44867bb1411cee4500738e3133d178f808785939a944e351ede68.
Root owns the fresh v2 focused execution and final matched-v6 recipe; no test
assertion is discarded and no fabricated checked compiler baseline is introduced.

Inherited gate inspection found real stale instrumentation after lexical flat
clones: Phase41's ordinary tree bench bypasses its previously counted global
warp_node, and Phase40's Nat-flow closure check treated distinct lexical scopes
as duplicate declarations. Root's checked16 actual Nat fixture confirms one
global and one lexical natflow.flow, one flat root, and five scalar root markers
with five proof admissions; the old duplicate-helper failure is retained in
focused16/run-actual-tree-derive, queue53. The earlier prediction that Phase40's
ordinary list fixture would fuse was disproved by root's exact emission; its
original gate remains unchanged.

Frozen owned successors preserve all complete-value, alias, refusal, mutation
and deep controls: phase41-actual-derive-v3.mjs / phase41-actual-controls-v2.mjs
count exact global and lexical warp_node declarations, with mandatory ordinary
lexical activation. phase40-tree-derive-v5.mjs / phase40-tree-controls-v2.mjs
resolve every worker call to its nearest lexical declaration, reject duplicates
within the same scope, and count exact global/lexical Nat-flow entries. Ordinary
bench must increase the lexical counter; owned diagnostics must enter the
original global worker. Producer/report kinds and checked receipt contracts
stay unchanged; only additional scope/counter witnesses are added. Earlier tools
and failed attempts remain immutable. Root/review/validation own fresh focused
execution and the integration03 matched-v7 recipe.

Inherited component instrumentation successor: the actual checked16 cohort duplicated `component.mix$tree` across its global and flat lexical scope, so the old global-name uniqueness assertion failed before controls. Frozen `frames/component-inherited-derive-v2.mjs` resolves calls to lexical declarations, rejects same-scope duplicates, and instruments both global and lexical mix/tail workers. The global tail emits exactly one `OEnd` tagged-array result rather than runtime `ctor`; the successor captures that exact result for the retained alias oracle and retains the no-continuation-push check. Original component and tail controllers remain unchanged, as do the exact tailWorker/tailLeafSites=1 and scalar root counts 4/3. Root execution and independent review determine final admission.

The actual16 owned unary fixture ordinary scalar root selects its lexical flat `owned.copy$tree`; the prior diagnostic counted only the global worker. Frozen `owned-fixture-derive-v3.mjs` retains the independently checked runtime-role binding from calls v2, requires exactly one global and one candidate lexical phase2 unary worker, and counts both. `owned-fixture-controls-v2.mjs` retains all 31 value/order/alias/native/public/deep checks and additionally requires lexical candidate ordinary-entry activation, baseline global activation, and total counter consistency. This is an instrumentation correction; root-run execution remains the admission gate.
