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

Orthogonal controls pass under root. Its fresh depth8 medians are flatBigInt
0.3113ms, arrayBigInt0.5282ms, flatNumber0.3052ms and TS0.2935ms. Depth6:
0.0656/0.0929/0.0617/0.0382ms; depth9:0.7465/1.3625/0.8475/0.7343ms.
Array versus flat is a material1.7–1.8× difference at depth8/9; Number is null.
See `selfhost/build/phase42/whole-tree-orthogonal-screen01/report.json`.
These remain bounded handwritten graph ceilings, not source results.

`actual-flat-v1.mjs` and `actual-flat-controls-v1.mjs` now provide the next
real-emission control. Derive from
`selfhost/build/phase42/checked01-preparation/modules/tree-bitonic.mjs`, retaining
its checked receipt. The two generated subdirectories `clone-array` and
`clone-flat` share the exact checked worker/control body; only cloned private
constructors and reads differ. Public original workers stay unchanged. BigInt,
stack machines and all14 helper IIFEs remain. Run the controls once per
subdirectory, then root serializes timing. Owner performed static inspection
only and claims no execution. This is saved-JS research, not a source compiler
patch; the general lowering context proposal is linked in the design.

Root's first actual clone derivation failed only on the flat clone at Acorn
line815 column1938. Clone-array artifacts and partial flat-original artifacts
remain in `selfhost/build/phase42/actual-flat01`; supervision retains the exact
failure at `supervision/actual-flat-derive01`. V1 inserted object property labels
at Acorn field AST starts, which exclude leading grouping parentheses/comments.
The resulting label could appear inside a grouped field expression.

Retain V1 rejected; `actual-flat-v2.mjs` locates element starts at the outer
array's token boundaries and prefixes labels before the complete expression.
It now writes candidate source before parsing, so any further parse failure
retains its exact candidate bytes. Controls are unchanged. No source/control
algorithm change or owner execution is introduced by this successor.

Frozen source V4 proposal: `source-v4.patch`, SHA256
`852d73b02ce0b0e4055e46e9bb3f57188730661ec87a8b5b2ed6d9e1a1ccd233`.
V1/V2/V3 artifacts remain retained. V3 fixes the late local-inline frontier and
exact call/saturation audits; V4 changes only inactive-context normal fallback.
The proposal adds208/removes9 physical lines and is not applied by this owner.

[`source-validation-catalog-v1.json`](../../selfhost/tools/performance/phase42/layout/source-validation-catalog-v1.json)
binds the patch, fixture and controller identities and lists root commands.
`actual-source-controls-v1.mjs` instruments complete intermediate Tree/Stat
returns of the exact selected emitted workers, asserts public worker source
byte identity, then enters private diagnostic workers only from scalar-created
values under the original full host/local guards. It checks20 full independent
Tree/Stat/scalar oracles,96 shared/uneven/mismatch flow cases, two freshness/alias
observations, two depth30000 private-frame cases, and68 fallback boundaries.
Native Bool's existing zero-field primitive ctor calls are permitted; all
user-ADT generic constructor/observer bridges inside flat clones are refused.
Diagnostic returned private values are observations, not public ABI admission.

Independent ReviewTree/ReviewStat `fixture-flat-v3.bend` has two scalar positive
roots and eight refusal roots. Its controller expects40 independent scalar
oracles, public complete ReviewTree observations, guarded exact fallback traces,
and static all-or-nothing admission/refusal. Parse/type diagnosis and checked
execution are still pending at delivery; syntax checking the controllers alone
is not checked source evidence. Use the catalog's commands and fresh outputs.

Checked08 successfully built the V4 source proposal but emitted zero flat
markers for the actual tree fixture. This is an admission failure, not a checked
optimization. `admission-probe-v1.mjs` retained a generated syntax failure;
V2 uses readable predicate captures and parses the derived API before invoking
the driver. A confined syntax-only checked08 derivative passed in0.30seconds.
Root-run predicate evidence is required before any source correction/build.

Independent fixture V3 failed affine ReviewTree leaf reuse; V4 introduces an
explicit unrestricted U32 binding. V4 then failed source-order resolution of
`review.out` because `bench` preceded its filled definition. V5 moves `bench`
after filled ReviewStat helpers; its type diagnosis is pending. V3/V4 remain
retained. The V3 fixture controller binds V5; the V2 actual controller binds its
independent oracle module and broadens the forbidden residual-operation audit.
Updated commands and identities are in `source-validation-catalog-v3.json`.

Probe03 identifies the sole refusal: all five flat audit gates pass, the cache
children have the expected exact source/planner/flat shape, and fourteen helper
definitions pass source identity. The selected annotated root `bench` differs
from its canonical source definition and fails the identity-only flat context.
`source-v5.patch` is an incremental correction on the applied V4 source:10
added/1removed line, SHA256
`61444cb9acb2e8cbc9149149069f467d85619ff72c097568c6a333289ff804b4`.
Only after every full-graph gate passes, it stores the exact canonical root in
the identity-only context; all helper objects, original full graph audit,
full guard coverage, lexical clone graph and normalized body remain unchanged.
Exact context checks are not weakened. Static review and checked rebuild are
root-owned. Fixture V5 now passes pinned TypeScript parse/type diagnosis in
`flat-fixture-ts-check03.json`; checked candidate emission is still pending.

Checked09 emits one actual flat block with direct fields after V5 repair. The
first actual control V2 failed before oracles because its static assertion
required field reads in `bsort`, a producer which has none in either baseline
or candidate. V3 retains strict byte identity of all five top-level original
workers and requires tagged-array constructors for `bsort`, tagged-array field
reads for the four consuming workers. No clone/public scope selection changed.
`admission-probe-v4.mjs` also asserts missing context remains inactive and six
invalid metadata contexts refuse (empty reserved name, wrong kind, inactive bit,
duplicate child, stale root and stale helper). Controls remain root-owned.

Root reports actual checked09 controls V3 pass20/98/68/2 and renamed fixture
controls V3 pass40 with all positive/negative admission flags. The context V4
probe used the old uncanonicalized graph when manually reconstructing the new
context and failed its positive activation assertion. V5 follows the exact
current source route through `j_flat_source_root` before `j_flat_book`, retains
all six negative cases, and records canonical stored-definition identity.
The actual checked09 derivative passed syntax-only inspection in0.355seconds;
root context execution and source performance acquisition remain pending.


`actual-source-controls-v4.mjs` is the hybrid-emitter successor. It captures the
complete result of the scalar wrapper for bsort/scan, audits each wrapper,
$hybrid and $stack body for residual generic bridges, and checks the four
paired hybrid declarations and exact budget16. All existing complete-value,
public-worker identity, hostile trace and depth30000 tests remain unchanged.
V3 and its successful checked09 evidence remain retained. V4 has passed only
pinned Node syntax inspection; root owns its candidate execution.

The Map follow-up is documented in `layout/map-gap-v1.md`. Its unexecuted
`map-bit-prepare-v1.py`/`map-bit-controls-v1.mjs` discriminator isolates source
prefix control in Map.bit's 29 saturated edges. It preserves String project
and constructor observations and returned key/bit, admits only guarded short
ASCII strings and bounded canonical BigInt positions, and keeps public Map
functions intact. This is saved-JS research, not compiler admission. Historical
profiles motivate this experiment; they are not fresh timing measurements.


Root reports hybrid source14 actual controls V4 pass20/98/68/deep30000. Map.bit
saved-JS controls also passed, but paired timing rejected the worker: Map32
14.630506ms original versus21.028193ms candidate, Map12875.226ms versus97.9323ms.
Repeated per-edge guards are a hypothesis for the regression, not an isolated
measurement. No production Map change follows from this experiment.


Source15's native owned Bool lowering changes the private global bsort worker
at exactly two constructor sites, so V4's raw identity check intentionally
refused before behavioral controls. V5 preserves that failure and compares the
consumed baseline after an AST-verified identity-only substitution: one empty
False constructor to false and one empty True constructor to true. Every other
bsort byte and all four other global structural bodies must remain exact; all
five actual public G bindings are checked separately for raw byte identity.
Raw, normalized and candidate hashes and both exact sites are recorded. The
baseline executable is untouched. V5 retains all existing behavioral checks;
only pinned Node syntax validation has run locally.
