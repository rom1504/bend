# Inherited component diagnostic successor

The preserved Phase39 actual-component fixture says tail recursion is outside
its then-new two-child rule. Checked06 legitimately emits that direct-tail
worker. The original deriver therefore fails its old worker-absence assertion in
`phase39-owners02/run-derive-component/stderr.log`; the failure and consumed tool
stay unchanged. Candidate root markers also changed from finite to scalar as
the current complete root-selection rule admits the same checked graph.

`component-inherited-derive-v1.mjs` is a versioned successor of the exact Phase39
deriver (SHA256 `37aa551f6e330a24fd5a782405e26a34caea5cf678b16a44d792147ac1388618`).
It uses the original fixture and all three checked receipts. Attempt/snapshot,
source/output, pinned TypeScript, compiler API/runtime/Base/driver, catalog,
producer/verifier and actual helper-closure checks remain. The candidate must
declare exactly one mix worker and one tail worker; the baseline declares
neither. Dependent, backedge, cycle and mutual-worker refusals are unchanged.
The tail worker must have no frame push and exactly one actual leaf constructor
assignment. Counters and leaf identity capture do not rewrite evaluated work.
Clean modules stay byte-identical to their checked parents.

The original three finite-root markers and candidate four scalar-root markers
must each match their exact guarded proof-admission scope inventory. Root
counters run after proof opening rather than before guard admission. Diagnostic
owned-tail adapters open separate scopes and invoke the public generic function,
whose real emitted recursive call site chooses the worker. Their openings cannot
supply the ordinary-entry root witness.

Run the complete existing `phase39/component-actual-controls.mjs` unchanged on
this derivation: its independent full mixed shapes, aliases, mutation/error/reentry,
deep component and runtime tail-cycle obligations all remain mandatory. In
addition, `component-inherited-tail-controls-v1.mjs` requires 13 independent
tail value rows (including depth30000), exact terminal-result identity, 19 live
refusal/demand/error boundary groups and one ordinary tail_check admission.
These supplement rather than replace the separate mixed linear-order owner.

Root-only recipe, with fresh successor output directories:

```sh
PHASE40_NODE=/home/ai/.nvm/versions/node/v24.18.0/bin/node
PHASE40_COMPONENT=selfhost/build/phase40/phase39-owners02/cohort-component/component
python3 selfhost/tools/performance/phase32/bounded-run.py --seconds 60 \
 --rss-mib 2048 --available-mib 2048 selfhost/build/phase40/run-inherited-component-derive03 -- \
 taskset -c 3 "$PHASE40_NODE" --stack-size=4096 --max-old-space-size=1024 \
 selfhost/tools/performance/phase40/component-inherited-derive-v1.mjs \
 "$PHASE40_COMPONENT/baseline.mjs" "$PHASE40_COMPONENT/candidate.mjs" \
 "$PHASE40_COMPONENT/typescript.mjs" selfhost/build/phase40/checked06 \
 selfhost/build/phase40/inherited-component-derived03
python3 selfhost/tools/performance/phase32/bounded-run.py --seconds 180 \
 --rss-mib 2048 --available-mib 2048 selfhost/build/phase40/run-inherited-component-controls03 -- \
 taskset -c 3 "$PHASE40_NODE" --stack-size=4096 --max-old-space-size=1024 \
 selfhost/tools/performance/phase39/component-actual-controls.mjs \
 selfhost/build/phase40/inherited-component-derived03 \
 selfhost/build/phase40/inherited-component-controls03
python3 selfhost/tools/performance/phase32/bounded-run.py --seconds 60 \
 --rss-mib 2048 --available-mib 2048 selfhost/build/phase40/run-inherited-component-tail03 -- \
 taskset -c 3 "$PHASE40_NODE" --stack-size=4096 --max-old-space-size=1024 \
 selfhost/tools/performance/phase40/component-inherited-tail-controls-v1.mjs \
 selfhost/build/phase40/inherited-component-derived03 \
 selfhost/build/phase40/inherited-component-tail03
```

Expected deriver under2seconds; parent controls under10seconds; tail controls
under5seconds and500MiB. No heavy job is run by the author. Only syntax checks
have run; these semantic expectations await root execution.

Closure needs a versioned specification, not a skipped producer assertion:
point only its component deriver entry at `../phase40/component-inherited-derive-v1.mjs`
and add that exact file/hash to its frozen files table, retaining the parent
specification/tool hashes as lineage. Parent component controls, counts, kinds,
cohort/checked-emission and command/receipt checks can stay unchanged. The new
tail report and execution must also be bound as an additional successor owner
before final closure. An auditor successor must verify this exact parent-derived
contract and both successful supervised executions; no blanket acceptance of
arbitrary producers or unbound report kinds is appropriate.

## Actual acquisition and deferred-boundary correction

Root runs the successor deriver03 successfully and unchanged inherited parent
controls03 pass159 oracle rows,113 boundaries and three admissions. Tail03
passes13 oracles,17 boundaries and one admission before its deferred boundary
fails the live-event requirement. Both roles instead produce the same early
TypeError with no callbacks. The failed report and V1 consumed tool stay intact.

The deferred descriptor shape matches runtime build exactly, but runtime apply
does not force its arguments before a matcher. Passing a raw descriptor directly
to component.tail therefore never reaches its deferred field callbacks. The
versioned `component-inherited-tail-controls-v2.mjs` routes both original deferred
cases through an actual foreign component.makeA producer return and ordinary
tail_check. Runtime callOwned/force then demands left and right fields in order
before constructing the matcher input. This repeats the real foreign-producer
path already witnessed by the unchanged inherited controls, rather than adding
another evaluator or accepting an inactive boundary.

V2 retains13/19/one obligations and both boundary names. It additionally requires
exact events `producer,left,right`, successful scalar24, and the right-sentinel
Error for the failing case. It pins V1 ancestry. Deriver03 and parent controls03
need no rerun; root must run V2 alone against derived03 with fresh
`inherited-component-tail04` and `run-inherited-component-tail04` directories.
Its report kind is `phase40-inherited-component-tail-controls-v2`; the closure
owner/spec successor must pin its exact hash and preserve failed V1 lineage.
V2 syntax and root's fresh tail04 execution pass:13 oracles,19 live boundaries
and one ordinary admission. The [final integration record](integration.md) binds
the four inherited owner groups and supplementary tail gate to installed06.
