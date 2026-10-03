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
