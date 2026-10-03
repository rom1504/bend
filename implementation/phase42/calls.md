# Phase42 direct calls investigation

Correctness: saved-JS tools syntax checked with Node24.18.0; root execution is
pending. Measurement: not run by this owner. Decision: investigate, no installed
source change and no speedup claim.

Tools: [derive](../../selfhost/tools/performance/phase42/calls/derive.mjs) and
[controls](../../selfhost/tools/performance/phase42/calls/controls.mjs). The
complete-value oracle and diagnostics derive from retained Phase41 tree tools.
Neither Phase41 source nor raw evidence is written.

Root executes with new directories, serialized CPU4 jobs:

```sh
taskset -c 4 /home/ai/.nvm/versions/node/v24.18.0/bin/node \
  selfhost/tools/performance/phase42/calls/derive.mjs \
  selfhost/build/phase41/integration01/full-preparation/modules/tree-bitonic.mjs \
  selfhost/build/phase41/final-diagnostics01/modules/tree-bitonic/typescript.mjs \
  selfhost/build/phase42/calls-ablation01

taskset -c 4 /home/ai/.nvm/versions/node/v24.18.0/bin/node \
  selfhost/tools/performance/phase42/calls/controls.mjs \
  selfhost/build/phase42/calls-ablation01 \
  selfhost/build/phase42/calls-controls01
```

The derivation's compare.json is an explicit three-point saved-module screen
input. original/noise are required to equal parent bytes. leaf removes one
private warp_leaf dispatcher; leaf-key also removes one private key dispatcher;
guards erases repeated worker proof conditions; complete combines both changes.
Root guards and generic/public bodies are retained. Clean modules omit counters;
diagnostic modules add counters outside timing. All input/producer/attempt and
compiler dependency identities must pass before output creation.

Initial protocol fixes: Node was absent on the shell PATH; the coordinating
agent supplied the absolute Node24.18.0 path. No execution sample was attempted
using the missing executable. Syntax checks passed after the path correction.

The first derivation failed before a complete receipt: nested proof guards in a
discarded generic fallback overlap range deletions for its enclosing guard.
The original producer is preserved as derive-v1.mjs (and derive.mjs); root's
failure receipt is selfhost/build/phase42/supervision/calls-derive01/stderr.log.
No correctness or timing result is claimed from partial output. Successor
[derive-v2](../../selfhost/tools/performance/phase42/calls/derive-v2.mjs) recursively
renders the AST, selecting an admitted conditional branch before descending
into retained children. Removed fallbacks therefore produce no nested edits.
Its syntax check passes; root must use a fresh calls-ablation02 output.

Root successor receipts now establish successful saved-JS derivation and
controls: [derive02 stdout](../../selfhost/build/phase42/supervision/calls-derive02/stdout.log)
records one leaf edge, one key edge, and six retained private proof guards;
[controls02 report](../../selfhost/build/phase42/calls-controls02/report.json)
passes 191 complete/scalar/deep oracle cases and 75 hostile boundary cases across
five diagnostic roles. The depth30000 result retains nodes60002/leaves60003 and
sum420021. These are saved-JS agreement checks, not checked compiler output.
Execution measurements for call variants remain pending.

The fresh root [calls-screen01](../../selfhost/build/phase42/calls-screen01/report.md)
selects the complete call ablation as a source survivor: d8 medians2.71565ms
original,1.48962ms leaf,1.43745ms leaf-key,2.33833ms guards,1.15292ms
complete and0.289576ms TS. Across the three points, complete improves2.35–2.46x;
remaining TS gap is about4–4.8x. These are saved-output mechanism timings.

Source proposal [helpers-v2.patch](../../selfhost/tools/performance/phase42/calls/helpers-v2.patch)
adds general bounded typed acyclic helper lowering and a private direct-call
node; [source.patch](../../selfhost/tools/performance/phase42/calls/source.patch)
also includes the frames owner's exact inherited-context patch. Source compile,
actual emitted output agreement, guards and focused fixture execution are pending.
The first helper patch is retained separately; v2 adds a cheap exact-context
refusal before attempting the helper graph plan. No production source was edited
by this owner. The independent renamed fixture is retained under calls/ and its
review-owner original path; root runs its untested frontend/emission obligations.

Root reports checked01 passes in45.87s at1.21GB peakRSS, using helpers-v2 and
the inherited-context patch. The expansion-budget successor is a separate
[patch](../../selfhost/tools/performance/phase42/calls/expansion.patch), not part
of that first checked image. It must be consumed by a fresh successor before
integration.

Actual checked-output tools are now syntax checked:
[actual derivation](../../selfhost/tools/performance/phase42/calls/actual-derive.mjs)
and [actual controls](../../selfhost/tools/performance/phase42/calls/actual-controls.mjs).
They verify the candidate attempt and complete checked emission receipt, require
actual inline helper sites and erased inherited private-worker guards, preserve
clean bytes exactly, and instrument actual emitted helper bodies. Additional
leaf/key controls call actual selected structural worker leaf cases under the
diagnostic proof; they contain no handwritten direct helper stand-ins. Root
executes these with explicit baseline/candidate/TS/attempt/new-output arguments.

Actual checked01 receipts pass:
[derivation stdout](../../selfhost/build/phase42/supervision/checked01-actual-derive/stdout.log)
finds14 compiler-emitted inline helper sites and five structural workers;
[controls](../../selfhost/build/phase42/checked01-actual-controls/report.json)
passes191 complete/scalar/deep oracle cases and75 hostile boundaries. It retains
the exact depth30000 summary. This closes the source-to-emission check for that
first image, while integration, compilation-cost and final execution admission
remain separate root decisions.

The optional [renamed fixture controls](../../selfhost/tools/performance/phase42/calls/fixture-controls.mjs)
consume explicit checked library paths/attempt/new output and the independent
review owner's BigInt oracle. They check75 scalar/full-shape cases, complete
closure binding/getter mutation traces, ordinary inline entry and static refusal
of partial/first-class/String/backedge workers. Syntax passes; fixture compilation
and control execution are pending. [owned-helper.patch](../../selfhost/tools/performance/phase42/calls/owned-helper.patch)
is a separate one-line constructor experiment dependency on the frames owner's
marker/emitter patch; it does not belong to checked01.

Before successor integration, static review found that v2's generic recursive
helper rewrite also visited annotation types. Its tested tree helpers do not
exercise parameterized/type-alias annotations, but those source type applications
must not become private value-call plans. The separate
[annotation-types.patch](../../selfhost/tools/performance/phase42/calls/annotation-types.patch)
preserves the original Ann type child, rewrites only its value child, and restricts
private-call candidates to positive-arity Def headers. It applies cleanly to the
current source. Retain checked01 as the measured first image; include this
narrowing and expansion budget in a fresh successor before integration.

Actual [checked01 screen](../../selfhost/build/phase42/checked01-screen/report.md)
passes fresh comparisons: tree8 medians2.83109ms Phase41/1.21817ms checked01/
0.287773ms TS; tree6 0.489719/0.175951/0.03773; tree9 6.55377/2.73129/
0.731186. This is the checked source survivor's generated-program result,
separate from the earlier manual ablation and the larger combined experiments.

The post-calls residual tools are syntax checked, with execution left to root:
[frames](../../selfhost/tools/performance/phase42/calls/post-calls-frames.mjs),
[scopes](../../selfhost/tools/performance/phase42/calls/post-calls-scopes.mjs),
[diagnostic derivation](../../selfhost/tools/performance/phase42/calls/post-calls-controls-derive.mjs)
and [controls](../../selfhost/tools/performance/phase42/calls/post-calls-controls.mjs).
The frame derivative preserves its old owner unchanged, but fixes lexical
liveness/remapping for reused helper binder IDs and retains shadowing sentinels.
The native recursive role records its deep RangeError explicitly. No source
patch or timing claim is made for these residual variants before root execution.

The post-calls [controls](../../selfhost/build/phase42/postcalls-controls01/report.json)
pass191 oracles/75 boundaries and preserve the native ceiling's depth30000
RangeError with proof restoration. The [residual screen](../../selfhost/build/phase42/residual-tree-screen01/report.md)
is provisional while root audits possible validation-process overlap. Its three
point medians show helper hoisting inconsistent (tree9 slower), live frames weak
on tree9, and direct owned constructors clearly useful. Hoisting and typed
liveness source implementation are deferred pending that corrected denominator.

New [stack derivation](../../selfhost/tools/performance/phase42/calls/stack-derive.mjs)
and [controls](../../selfhost/tools/performance/phase42/calls/stack-controls.mjs)
are syntax checked. Root supplies exact checked03 saved tree, TS module,
owned-actual adapter directory and a new output. The tool produces prune/lazy/
combined variants with exact original/noise controls, checks every frame-phase
write/initializer is0/1 before pruning, and changes allocation only within the
four private structural workers. Lazy stack allocation occurs immediately
before first frame access and unwind checks null explicitly. Expected controls
are192 oracles/75 boundaries, including eager1/lazy0 allocation on an actual
warp leaf case; all roles retain depth30000 stack safety. No execution claim yet.

The independent renamed fixture's first baseline compilation failed parsing at
computed match scrutinee line15, retained in
[baseline receipt](../../selfhost/build/phase42/fixtures-baseline01/modules/calls-fixture-renamed.mjs.json).
The exact v1 source/controls remain preserved. Successor
[fixture v2](../../selfhost/tools/performance/phase42/calls/fixture-renamed-v2.bend)
extracts review.pair.at and matches its Bool parameter; the pair helper passes
the computed xor result as a normal argument. Main37035 is unchanged.
[controls v2](../../selfhost/tools/performance/phase42/calls/fixture-controls-v2.mjs)
binds the new source and requires pair.at in the full closure. Root must first
validate pinnedTS parsing/checking before treating these as successful fixtures.

Pinned TS checking rejects fixture v2's original leaf binder because pair/key
consume x twice. The frozen v2 source/controls remain retained.
[fixture v3](../../selfhost/tools/performance/phase42/calls/fixture-renamed-v3.bend)
introduces an explicit typed unrestricted scalar alias before the same pair/key
expression; [controls v3](../../selfhost/tools/performance/phase42/calls/fixture-controls-v3.mjs)
binds its identity. No refusal definitions or oracle semantics changed. Only
controls syntax has been checked here; root owns fixture validation.

Root's complete-stage controls exposed a source-shape regression in checked03
and checked05: covered-helper rewriting changed an outer unary reconstruction
App into JDirectCall before the structural emitter discovered its recursive
child. j_linear_spine then returned an empty spine, sentinel child index32
produced undefined $u0 captures, and keep_gt1 failed for n>=2 despite benchmark
checksum success. Existing complete-stage controls remain unchanged. Frames
owner is preparing a narrowly scoped worker rewrite that preserves original
App shape whenever its original subtree references the structural owner.
This is a correctness fix, not a new optimization; current successful benchmark
and leaf-control results do not establish complete graph correctness.

Root's isolated [stack screen](../../selfhost/build/phase42/stack-screen01/report.md)
rejects prune/lazy/combined source promotion: tree8 original.7738ms versus
lazy.7316/combined.7272, tree6 .12183 versus .11744/.11735, but tree9 original
1.7628 versus prune1.8399/lazy1.8913/combined1.8897. Largest-point regression
(~7–10% versus noise) defeats consistent gain. The three saved-JS hypotheses
remain diagnostic artifacts only. Root audited that the earlier 3s validation
job ended before the residual screen; a separate0.2s mapping job is noted.

Root reports checked07 owner-shape fix build passed43.3s and fresh fixed-fusion
controls passed116/79 plus255 independent arithmetic checks; renamed calls
fixture v3 passed pinnedTS diagnosis and actual controls75/16. These are root
observations, not executions performed by this owner. The held general
[sequential review](../../selfhost/tools/performance/phase42/calls/sequential-review.md)
and [independent fixture](../../selfhost/tools/performance/phase42/calls/fixture-sequential-v1.bend)
cover closed scalar entry without claiming original BST graph admission.

The [BST/sequential catalog v1](../../selfhost/tools/performance/phase42/calls/bst-sequential-catalog-v1/catalog.json)
copies the original BST source exactly and the independent sequential fixture.
Root reports the independent sequential fixture pinnedTS check passes.
[structural derive v2](../../selfhost/tools/performance/phase42/calls/structural-derive-v2.mjs)
binds explicit baseline/candidate checked attempt identities; root's baseline
is checked07, a mechanism comparator rather than the Phase41 reference. Exact
original/TS/candidate clean files remain byte copies; only diagnostics add
actual worker/helper/phase2 counters and guarded routes through source workers.
[controls v2](../../selfhost/tools/performance/phase42/calls/structural-controls-v2.mjs)
and the independent iterative BigInt/tree/zipper oracles are syntax checked only.
No target/compiler execution was performed by this owner.

Required bounded contracts are216 BST oracles/24 pointer aliases or87 sequential
oracles/0 aliases, each3*fullGuardCount+7 refusals and3 deep records. Complete
BST trees, partial-fuel pairs, ordered zipper frames, reconstruction, duplicates
and wrapped inorder results are independently compared. Native aliases include
chosen/other child and path-tail identity plus down(0)/up(Nil) identity. Ordinary
scalar roots must enter down/up/inorder or all4 sequential folds, with real
phase2 resumes. Public external ADT calls, full dependency binding/code/getter
mutations, Array protocol changes and a changed producer supplying proxy fields
must enter zero private workers. Proxy demand traces match exactly. Deep30000
BST down/up/right-inorder compares complete results across all roles; left-inner
continuation candidate success and original/TS outcomes are recorded, with
changed-inorder deep fallback outcome parity. This distinction avoids claiming
a generic baseline stack guarantee before execution establishes it.

Checked10 BST derivation correctly refuses before execution: actual emitted bench
and all5 sequential scalar roots lack $guards/private scalar-root admission,
despite down/up/inorder and sequential worker declarations. The local region
argument grammar still rejects3-field recursive ADTs (its fold-layout selector
admits at most2 ctor fields). Native JPure proof success alone does not establish
ordinary root entry; no assertion was relaxed.

The [finite component policy patch](../../selfhost/tools/performance/phase42/calls/finite-component-root.patch)
adds8 lines to the existing finite useful-work gate: a non-scalar full-graph
callee with an original self reference and a separately admitted canonical
component plan qualifies. Existing finite-root machinery already performs scalar
header checks, complete original JPure graph proof, exact entry/null-proof/host/
input/full-dependency guards, force of the original generic body inside try/
finally and public fallback. Region/u32/flat/fusion priority remains unchanged;
local type/layout selectors are untouched. No new proof API or recursive IR is
introduced. Patch review/build/runtime validation remain root-owned.

Root's checked11 bridge builds/emits and all5 independent sequential scalar
roots admit actual workers. Initial structural controls v2 pass87 oracles, then
fail at boundary13 because the tool mutated make_left while always invoking
sequence.right, whose exact graph excludes make_left. This is a tool guard-
selection error, not evidence of a source guard defect. Frozen v2 is retained.
[derive v3](../../selfhost/tools/performance/phase42/calls/structural-derive-v3.mjs)
records every root's exact single complete guard vector and requires independent
admission for every expected root; [controls v3](../../selfhost/tools/performance/phase42/calls/structural-controls-v3.mjs)
chooses and records an owning root for each changed dependency. Strict zero-
entry and exact fallback event/outcome checks remain unchanged, as do all count
contracts. Only syntax is checked by this owner; fresh execution is root-owned.

Root's v3 retry passes87 sequential oracles and37 pre-host refusals, then fails
the Array.isArray zero-entry premise: the original runtime does not include that
global function in regionHostGuard. Its uses are initialization descriptor
setup, Tuple projection, showing and external conversion; this sequential scalar
path requires none after initialization. Frozen v3 is retained.
[controls v4](../../selfhost/tools/performance/phase42/calls/structural-controls-v4.mjs)
keeps Array.isArray outcome/proof-restoration parity and records callback/entry
deltas without assuming zero admission. Changed Array.prototype.slice adds a
meaningful strict protocol refusal alongside push and iterator. Final boundary
contract becomes3*unionGuardCount+8; all other contracts remain unchanged.
This is an explicit correction of the tool premise, not a general weakening of
host controls. Preimport BigInt/iterator observer witnesses remain separate
root/frames obligations for newly guarded generic execution.

The matched native-container/sequential/finite-root bridge proceeds under the
published standard-host-intrinsics-at-module-initialization contract
(`docs/BEND-IN-BEND-PERFORMANCE.md:405–416`). Root's preserved preimport BigInt
observer diagnostic gives a public proxy result26 versus30 and changed-code
callbacks7 versus0. This is evidence about broadening that contract, rather than
a supported-contract release failure. Complete original typed source closure
alone does not establish safety under arbitrary host replacement before import.
The initialization premise must remain explicit in acquisition and controls.

[prepared rollback v2](../../selfhost/tools/performance/phase42/calls/held-rollback-v2/source.patch)
remains unused. It reverses exactly228 net lines (8 bridge,63 sequential,27 native
emitter,130 closed native proof) against its recorded canonical hashes. The
frozen v1 reversal failed on adjacent flat-v5 context; v2 reverses each exact
changed run from the4 owner artifacts once byte-for-byte. Its
[report](../../selfhost/tools/performance/phase42/calls/held-rollback-v2/report.json)
records patch/chunk identities and file hashes, with76 retained core function
bodies unchanged. The rollback predates the separately applied Nat.add metadata
patch and makes no claim to remove that later patch.

Root reports checked13 BST controls216 oracles/24 aliases and sequential
controls87 oracles all passing under supported initialization. Nat.add boundary
controls separately compare exact near-limit arithmetic, overflow, later clean
reactivation, changed dependency descriptors, and Error-observer proof
suspension. Their versioned producers bind checked07 baseline and checked13
candidate acquisitions independently, including intentionally different runtime
hashes; actual success is established only by root-run reports.

If the contract is broadened to preimport observer replacements, a future design
must stage original callee selection and observable argument work outside proof,
preserve demand order, then validate the complete graph plus scalar argument and
provenance facts before private entry. Refusal must continue with already
selected callable/arguments: rerunning duplicates effects, and rereading G can
change the selected callee. Reentry must see null proof, and externally observed
ADT values cannot inherit ownership. No such future repair is claimed here; the
outside-contract witness and unused rollback remain preserved.

Native Nat.add v1 actual controls passed at
`selfhost/build/phase42/native-nat-controls13/report.json`:10 arithmetic/error
oracles and4 boundaries, with exact guards `Nat.add`, `sequence.fold`,
`sequence.make_right`, `sequence.nat`. Frozen v2 adds arity/bound/env accessors
and postimport BigInt/Math.imul mutations, retaining exact trace parity and
zeroentry obligations. It expects10 oracles/9 boundaries; actual root execution
must establish those successor claims.

Fresh BST64 checked13 diagnostics show sampled allocation estimates around
1.873MB/call versus393KB/call pinned TypeScript (about4.76×). The private
`bst.down` worker dominates sampled allocation and CPU. These are weighted
sampling estimates, not exact allocation events or throughput ratios. A cheap
next discriminator is removing only tail-transfer `$next` arrays: evaluate each
original argument into an ordered temporary before assigning any `$s` state.
This preserves demand order and stack safety while separating transfer-array
cost from native pair/list construction and helper IIFEs. No source change is
justified by this profile alone.

The frozen root-run `bst-ablation-derive-v1.mjs` now produces five variants:
original/noise, transfer temporaries, native owned Tuple/List/Bool construction,
and combined. Only private structural worker bodies change. Transfer evaluates
all original expressions in order before assigning state; native constructors
keep exactly the existing array product/tagged list ABI and leave Nat untouched.
Each variant reuses the actual checked13 entry/resume/proof adapter and full
structural controls; comparison configs require a passing derivative-specific
report before exposing32/128 points. Saved-JS variants remain explicitly
unchecked, with checked13 original as mechanism comparator. No timing or target
execution was run by this owner.

Root subsequently reports Nat.add v2 success (10 oracles/9 boundaries).
BST ablation v2 refused `inorder` because its transfer array has intervening
frame bookkeeping before state assignments; this is a real unmatched use
pattern. Frozen v3 limits transfer removal to the four exact three-argument
`bst.down` sites and retains consecutive-assignment plus no-later-use checks.
Sequential result-hole continuation code remains byte-identical. Native
constructor ablation still touches only private worker bodies.

Root-run BST32/128 screens accepted native constructor discrimination:
original .202823/1.49189ms, native .156467/.892787ms; transfer .197473/1.344934,
combined .159583/.905265. Noise .202322/1.486671. Native alone wins roughly
1.30–1.67×, while transfer adds no gain over native; transfer source promotion
is declined. All variants passed full semantic controls first.

`native-owned-v2/source.patch` adds25 emitter lines, gated by the existing owned
marker and original Ctr shape. Exact closed independent Sigma (both quantity1,
nondependent family) emits a fresh dense two-element array; exact closed
List quantity2 emits the same tagged `Con`/`Nil` object with a field array;
exact native Bool nullary constructors emit primitives. Original specialized
`j_ctor_args` retains quantity erasure, field order, aliases and dynamic
arguments. Public/unmarked and deferred tail construction remain unchanged;
Nat/String/other native constructors remain residual. The isolated v1 draft
had an outer delimiter typo, caught before compiler acquisition, and is retained;
v2 delimiters are statically balanced. Checked acquisition and source controls
are root-owned and pending; this is a source proposal, not a checked claim.

Independent reviewer found no static blocker in native-owned-v2's exact gates,
quantity handling and private scope. `native-owned-assay-v1.mjs` binds actual
checked13/15 acquisitions and records private worker constructor/literal AST
counts. It also requires exact module bytes outside private worker bodies and
explicitly marked private helper arrow bodies; this preserves generic public
fallbacks while permitting guarded helper branches inside public registrations
to change. Runtime hash and source input must match. Actual constructor
activation and full behavioral controls remain separate obligations.

Final integration preflight counter exposed an actual admission regression,
not an instrumentation rename: checked15 emits no `count.keep`, `count.observe`
or `count.store` private vector worker, while scalar Number lowering remains.
All35 value oracles passed through fallback before the structural assertion.
The established fixture uses `Sigma<&2,&2,...>` states. Closedproof04 changed
shared `j_region_same_type` to route every Sigma through `j_pure_same_closed`,
whose independent native Sigma header admits only quantity1. Existing local
vector admission still supports quantity2, so shared equality incorrectly
removed that domain. Root/facts/reviewer were notified. The controller must
remain unchanged; source compatibility repair is a separate reviewed obligation.

The minimal repair proposal is `equality-domains-v1/source.patch`: restore the
shared region equality body byte-for-byte from Phase41 checked01 and move
exactly three JPure comparisons (Ann, Var, saturated-result) to explicit
`j_pure_same_closed(...,64)`. This separates established local vector/List
admission from the new strict quantity1 Sigma/List ownership proof. Remaining
shared callers are the original local_type-guarded builder and fusion gates,
which admit only original fold owners or ground U32 List with scalar fields.
No new closed native container relies on that regional policy. Five source
lines change; exact before/after and Phase41 snapshot identities are recorded.
This preserves all strict JPure shape/quantity/type checks while restoring the
pre-existing optimized vector domain. No canonical edits or target execution
were performed by this owner.
