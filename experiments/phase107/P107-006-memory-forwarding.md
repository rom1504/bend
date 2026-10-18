# P107-006 — fresh-allocation load forwarding with validated loop facts

2026-10-18. Closing status: bounded pass implemented and finite controls passed;
load removal alone did not deliver the hoped-for material QBE shared-loop gain.

Initial hypothesis: after effectful leaf inlining, the owned observer retains
an alias barrier between `parent[0]` and `child[0]`. Its preheader actually creates
two fresh allocations and stores the child pointer in a separate parent field.
Tracking that provenance can replace stable pointer/payload loads without deleting
ownership operations or assuming that differently named pointers are disjoint.

Candidate API: Bend `nx_memory_forward(program)`. Distinct live, nonzero fixed-size
allocations get distinct abstract roots. Copies and constant pointer offsets retain
that provenance. Facts record exact byte ranges/types and atomic stored values.
Overlapping stores invalidate facts, and assignment invalidates facts depending on
the old local value. Unknown calls/frees erase provenance and values; unknown stores
erase memory facts. Successful allocations preserve their original runtime behavior.

Loop rewriting is inductive and deliberately narrow: remove facts depending on any
assigned local, probe a straight-line body, discard written candidate cells, then
reanalyze from only the survivors. Require every surviving fact disjoint from all
resolved second-pass writes. Calls, free/allocation, nested loops and branches make
that loop attempt fail closed. Only original preheader invariants escape the loop;
facts learned during an iteration never become facts about a zero-trip loop.

Only loads at their original sites can change, to an existing atomic value. No
store, allocation, free or call is deleted/reordered and no access is hoisted.
This preserves aliasing and avoids speculative accesses through zero-trip paths.
The scope is sequential, well-defined memory IR under the pinned64-bit ABI, not
volatile/atomic/concurrent memory, arbitrary forged pointers or an independent
memory-safety theorem. Allocation failure behavior is inherited unchanged; no new
claim about OOM or null-allocation recovery is made.

Before performance: exact range helper contracts; independent full-result controls
for aliased roots, partial overlap, local-version dependencies, pointer reassignment,
changing loop payload, pointer-field mutation, calls/free, self-assignment and skipped
invalid accesses. Negative controls must detect invented disjointness, ignored widths
and invalidated facts retained across iterations. Verify structural effect preservation
and non-increasing node count. Existing source/leaf controls remain held-out tests.

Then compare the frozen leaf/reachable baseline against the additional pass on the
same shared/borrowed workloads and unrelated memory controls. Record optimizer cost,
remaining loads, object/build cost, repeated runtime and complete output. A gain on
this bounded IR does not establish whole-compiler speed, complete memory correctness
or a production policy. Root owns guarded acquisition and execution; this agent
performs source preparation/review only. All failed runs remain evidence.

## Closed result

[Memory audit01](../../selfhost/build/phase107/memory-audit01/report.json)
passes 21 families, 300 native outputs, 280 distinct model executions, 576
independent interval checks and four detected semantic mutants. The overlap
witness uses `-fno-strict-aliasing` for its typed-C control; ordinary optimized
typed C is not a valid oracle for that byte-memory case. Local helper laws and
finite controls do not establish whole-pass memory safety or a production
ownership contract. Existing source/leaf fixtures are regression/transfer
controls, not a newly independent discovery holdout.

[Code-shape inspection](../../implementation/phase107/code-shapes.md) showed that
forwarding invariant loads left the repeated scalar heap updates. The subsequent
[scalar-promotion experiment](P107-009-scalar-promotion.md) addresses those updates
and provides the larger composed gain; do not attribute that result to forwarding
alone. The [phase report](../../implementation/phase107/README.md) separates the
measurements and preserves the restricted sequential allocation contract.
