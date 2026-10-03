# Phase42 private layout investigation

Status: selected semantic controls pass for an unchecked saved-output prototype;
root timing pending. No production source edits or proposed source patch exist.
The representation mechanism and admission obligations are in
[design](../../design/phase42/layout.md).

`derive.mjs` uses the final checked Phase41 tree module byte identity, not a
handwritten sorting twin. It preserves its control/continuation machinery,
proof guards, Bool representation, BigInt Nat, primitive expressions and public
fallback constructors. Three roles isolate no packing, checked slot selection,
and an unsupported direct private-slot ownership assumption.

Preserved attempts:

- Initial `node` invocation failed because Node was absent from shell PATH;
  no artifact was created. Discovery found Playwright Node v24.11.1. Root's
  canonical host is v24.18.0 and must regenerate/run before timing admission.
- `layout/prepared01/` retains the rejected pretest property-marker experiment.
  A public `_p42` getter would become newly demanded by its project/fields/slot
  path. No correctness or performance claim is made for it. The unsafe emitted
  code is retained verbatim; it was not timed or run for correctness.
- `layout/prepared02/` replaces marker demand with bound original WeakSet
  membership methods. On Node24.11.1, the controls completed in under one second:
  40 complete Tree + Stat input/direction cases, known depth8 checksum and 59
  boundary observations. [Receipt](../../selfhost/tools/performance/phase42/layout/controls02.json).
  Public mutation/getter/throw/reentry traces agree across roles; an input with
  throwing `_p42`/`_0` getters retains original tagged field demand. These are
  selected finite probes, not a ownership proof or broad conformance result.

Root regeneration commands (run from repository root, unique output names):

```sh
/home/ai/.nvm/versions/node/v24.18.0/bin/node \
  selfhost/tools/performance/phase42/layout/derive.mjs \
  selfhost/build/phase41/tree-preparation01/modules/tree-bitonic.mjs \
  selfhost/tools/performance/phase42/layout/prepared03
/home/ai/.nvm/versions/node/v24.18.0/bin/node --max-old-space-size=1024 \
  selfhost/tools/performance/phase42/layout/controls.mjs \
  selfhost/tools/performance/phase42/layout/prepared03 \
  selfhost/tools/performance/phase42/layout/controls03.json
```

Timing modules are `original.clean.mjs`, `flat.clean.mjs`, and
`direct.clean.mjs` beneath the prepared directory. They share the same bench
export and support the catalog tree points. Diagnostic `.mjs` exports intentionally
return full private values for testing and are not public admission evidence.
The private WeakSet retains no strong tree references, but its registration and
membership have measured costs. Residual generic consumers allocate projection
argument vectors. Slot assumptions, heterogeneous fallback and host hook
mutation remain review obligations. No Number Nat or allocation counters are
introduced, so timing addresses layout separately from those mechanisms.

## Root first screen and successor

Root's `tree-structure-screen01` reports the `flat` role3.35–5.69 times slower
and `directlayout-ceiling`3.16–5.47 times slower than Phase41 on the three tree
points. At depth8 the flat median is12.76ms versus2.76ms. Root rejected this
integration. WeakSet registration and residual generic projection plausibly
contribute, but this timing does not isolate their individual causal costs.
Retain all earlier roles and results; no source patch follows this result.

A separate `layout/complete-v1.mjs` successor is ready for root execution:

```sh
/home/ai/.nvm/versions/node/v24.18.0/bin/node \
  selfhost/tools/performance/phase42/layout/complete-v1.mjs \
  selfhost/build/phase41/tree-preparation01/modules/tree-bitonic.mjs \
  selfhost/tools/performance/phase42/layout/complete-prepared01
/home/ai/.nvm/versions/node/v24.18.0/bin/node --max-old-space-size=1024 \
  selfhost/tools/performance/phase42/layout/complete-controls-v1.mjs \
  selfhost/tools/performance/phase42/layout/complete-prepared01 \
  selfhost/tools/performance/phase42/layout/complete-controls01.json
```

Time `original.clean.mjs` against `complete.clean.mjs`. The new graph uses
BigInt and named single-object ADTs, no generic invocation/projection/boxing
or WeakSet inside, and the same Bend sorting/flow/scan algorithm. Existing
closed scalar guards and proof entry/exit remain; greater-than12 depths use the
original fallback. Native recursion makes this a bounded diagnostic architecture
ceiling. Its effects cannot be attributed to layout alone, and production
stack/ownership/source correctness remains unestablished.

The prospective control script binds input/module/producer identities before
and after observations, preserves a consumed copy, compares40 complete
Tree/Stat values, and runs202 independent private flow/warp shape and alias
oracles. It also compares mutable/getter/throw/reentry public traces and hostile
public host fields. These successor controls have not been run by this owner;
root owns their bounded execution and all timings.

Review supersedes the preceding successor commands before execution:
`complete-v1.mjs` placed the depth comparison before canonical scalar admission,
which could newly coerce a hostile count. It is retained as rejected.
Use `complete-v2.mjs`, `complete-controls-v2.mjs`, `complete-prepared02`, and
`complete-controls02.json` in the same command shape. V2 places the depth cap
at the end of the original full entry guard, after canonical-number and host
checks. Its controls add coercion-getter/throw/reentry/Symbol count observations
and raw code entry comparisons. No owner execution is claimed for either
complete successor; root remains the executor.

Root derived `selfhost/build/phase42/whole-tree-ablation01` successfully with
V2. Its first V2 control run failed at the first `bsort/reentry` boundary:
the accessor's inner bench refused private entry then demanded the same accessor
again without a bound. Both roles reached stack exhaustion, with656 versus662
getter events. Those traces are preserved in
`selfhost/build/phase42/supervision/whole-tree-controls01/stderr.log`; they do
not establish equivalent bounded behavior or a candidate semantic defect.

The new `complete-controls-v3.mjs` explicitly allows one nested accessor entry,
setting the guard before invoking the inner bench. It still compares complete
value/error/event observations, with case labels. Diagnostic-only instrumented
copies count proof/private entry and must show zero for all guarded mutation
refusals and raw entries, and one for the normal canonical root. The original
clean modules stay byte-identical. V3 remains root-executed; V2 is retained.

Root's V3 controls next reached the raw-code observations and rejected direct
cross-module equality of a bounce containing an anonymous function. The bounce
payloads were structurally equal, but their code functions have distinct module
identity. Preserve this failure at
`selfhost/build/phase42/supervision/whole-tree-controls02/stderr.log` and keep V3.
`complete-controls-v4.mjs` adds a diagnostic-only export of each module's own
`force` and compares complete scalar results after forcing raw code results,
including zero private/proof entry counts and the bounce flag. The forced value
must also equal the normal baseline call. Clean modules remain unchanged.

Root's whole-tree screen passes after V4 control correction. Complete private
BigInt/named graph median is0.306237ms at depth8 versus TS0.284206ms (1.0775×),
and0.728263ms at depth9 versus0.691791ms (1.0527×). Depth6 is0.063769ms versus
TS0.041408ms (1.54×). Root reports Phase41 about8–10 times slower than this
complete role, with explicit warming/noise in the baseline samples. These are
bounded diagnostic architecture ceiling observations, not compiler-source gains.

The new `complete-ablate-v1.mjs` accepts the existing whole-tree directory and
a fresh output directory, emits three orthogonal subdirectories, and retains
parent/module/producer hashes. Run `complete-controls-v4.mjs` separately against
each subdirectory before timing. `flat-bigint/complete.clean.mjs` is identical
to the previous complete clean module; `array-bigint` changes only object/field
layout; `flat-number` changes only bounded private Nat representation. All
use the same pure graph and native recursion. Owner has not executed these.
The source implementation proposal is recorded in the design and coordinated
with the frame owner; no source patch or production edits exist.
