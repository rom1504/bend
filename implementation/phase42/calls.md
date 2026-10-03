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
