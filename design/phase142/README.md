# Phase142: make incremental compiler work proportional to the edit

2026-10-26. Planning only, based on `878ac52996bd2d5703eb877eb87074a4bfac6fec`
on `selfhost/bootstrap`. No compiler changes or new performance measurements
accompany this design. It continues the [Phase140 experiment](../../implementation/phase140/README.md)
and [next-boundary audit](../../research/phase140/next-reuse-boundary.md), retaining
the useful [Phase141 simplification](../../implementation/phase141/README.md).

**The objective is to rebuild a changed compiler by processing the affected
computation, rather than repeatedly inspecting and reconstructing everything
that did not change.** Target 10× faster warm local builds first. Investigate
100× only when the remaining whole-program floors have a credible replacement.
Neither target is a prediction for cold compilation or arbitrary global edits.

## 1. Baseline, scope and success

The final Phase140 full-compiler experiment changed `p131rg_width` from16 to15.
The complete products matched independent fresh builds of the respective source
revisions. Its available-executable comparison was:

| Boundary | Seconds |
|---|---:|
| Fresh qualified build of edited source B |346.960|
| Warm native stages |101.030|
| Output reconstruction |5.522|
| QBE, assembly and link |13.816|
| Warm subtotal |120.368|
| Shared session overhead additionally charged to B |4.311|
| Warm inclusive estimate |124.679|

This is **2.783×**, based on one late, same-width substantive edit. The machine
cost is an actual build of the identical product reused in the receipt join;
the inclusive estimate is not a newly timed interactive service. Acquisition,
cache seeding, outer resource supervision and qualification are separate costs.
Phase140's earlier source15 timings must not be mixed into this final-source table.

At the same historical denominator:

- **5×:** at most69.392s per edited executable.
- **10×:** at most34.696s; another3.59× improvement over the inclusive warm result.
- **100×:** at most3.4696s; another35.94× improvement over that warm result.

The current warm cost must fall by72.2% for10× or97.2% for100×. This requires
several stages to change, not a faster equality helper alone.

Keep the historical comparison, but establish matched candidate/incumbent
measurements when execution begins. Phase141 has a smaller source and an
ordinary-native-qualified N2; its incremental path remains experimental and
its full-edit session was1.7% slower than Phase140. Do not combine Phase141
products with Phase140 timestamps and call that a new speed result. Start
implementation from the exact Phase141 composition; use Phase140 as a retained
mechanism baseline and Phase137 N3 as the qualified independent fallback.

Define three separate outcomes:

1. `Tbuild`: source submission through a complete runnable edited executable.
2. `Tready`: `Tbuild` plus focused independent smoke requests executed by it.
3. Campaign cost: acquisition, seeding, updates, failed attempts, validation,
   qualification, human/agent research, memory and retained storage.

10×/100× here apply to `Tbuild`. Report `Tready` and campaign cost beside them.
Source submission includes authenticating the submitted source; a cached no-op
or returning the old executable does not count as a substantive edit.

## 2. What must disappear

| Current warm native stage | Seconds | Structural change to investigate |
|---|---:|---|
| Frontend |30.966|Retain and patch checked owner tables, indexes, reachability and aggregates instead of rebuilding their containers.|
| Raw lowering |13.306|Retain owner/segment units and report exact changed products when producing them.|
| Optimization and verification |40.079|Consume those changes instead of repeatedly comparing complete old/new products; isolate the independent final-verifier floor.|
| Registry |9.902|Update affected entries and preserve ordered unchanged units.|
| Rendering and close |6.777|Visit dirty output units; avoid walking every product to decide whether to reuse it.|

These are inclusive stage observations, not independently removable savings.
The40.079s is **not** a measurement of the final verifier alone. Its exclusive
cost is a first-order unknown: if unavoidable verification exceeds the target
budget,10× needs a separately justified verification architecture.

The output boundary matters too: roughly2MB of new payload still leads to
reconstruction of106MB. The old grouped-object cache cost16.064s under its
guard, versus14.699s monolithic. A high object-hit count did not win the complete
build. See the [machine-floor audit](../../implementation/phase140/audit/machine-floor.md).

An ambitious **budget to test, not a forecast**, is frontend8s, raw4s,
optimization/verification10s, registry/render5s, machine/link4s and request/
transport3s:34s total. Every number needs its own measured evidence. Keeping
today's19.338s output/machine tail and4.311s shared overhead leaves only11.047s
for all native stages at10×, requiring roughly9.15× faster native stages alone.
Reducing transport and machine work makes that target less demanding.

## 3. Architecture: retained products with explicit dependencies

Build a small internal contract around the existing stages, not a new universal
IR or independent cache framework. The following is an interface sketch, not
implemented Bend syntax or an established proof:

```text
SessionEpoch = producer + schema + Base + runtime + target + policies + tools
Revision     = last committed successful source and product view
Unit         = semantic identity + immutable product identity + consumed facts
Fact         = identity + kind + value/version
Delta        = epoch + base revision + proposed revision
             + retained / replaced / inserted / deleted units
             + changed global facts + current ordering/binding obligations
update       : committed state × authenticated source -> pending state or error
commit       : pending state × successful gates -> committed state
```

Names identify declarations; versions identify their actual products. An owner
with unchanged spelling is not necessarily unchanged after freshening, erasure,
specialization or static placement. A product identity is minted by the stage
that produced it and retained only while that exact immutable result survives.
It proves nothing about dependencies outside that product.

Keep the first implementation in one private Bend session. No public pointer
identity, caller-supplied unchanged flag, or unvalidated serialized token.
Failure and cancellation must leave the last successful state usable. Detect
stale bases, wrong epochs, missing evidence and counter exhaustion; rebuild
conservatively. Publish the executable only after all required gates succeed.

Dependencies eventually distinguish signatures, reducible bodies, constructor
layouts, quantities/ownership facts, effects, helper readiness, negative lookup
results, fresh-number inputs and static bindings. These are not all implemented
in the first slice. Existing exact whole-context checks remain until a narrower
contract actually replaces them.

Separate semantic units, QBE transport bundles and machine-object groups. Their
best granularities differ. Keep stable groups large enough to avoid tens of
thousands of subprocesses, without recompiling a giant group for one small edit.

## 4. First experiment: raw-product evidence into verifier admission

**Do this first.** It is a bounded way to test the central mechanism without
changing optimization policy, generated-program semantics or the final verifier.

Relevant actual boundaries:

- [`p140og_record`](../../selfhost/tools/performance/phase140/owner/raw-v01.bend)
  currently reconstructs segment products even on raw-owner reuse.
- [`p140v_context` / `p140v_raw_walk`](../../selfhost/tools/performance/phase140/verify/core-v04.bend)
  inspect context and rediscover unchanged segment bodies.
- Later [`p140gm_changed`](../../selfhost/tools/performance/phase140/render/registry-v05.bend)
  and [`p140r_hit`](../../selfhost/tools/performance/phase140/render/reuse-v04.bend)
  repeat related work. They are follow-ups, not part of the first correctness claim.

First instrument exact equality visits, inspected body nodes, reconstructed list
nodes, hits/misses and relevant stage time. Separately time the existing final
verifier and frontend index/book assembly. Avoid per-node logging and measure
the uninstrumented candidate for performance; instrumentation can perturb costs.

Start narrower than the eventual `Delta` interface: carry one compact owner/run
witness from `p140og_old` through `p140og_record`, alongside the existing ordered
segments. Those paths retain the generic `P111Code` bodies/continuations even
though they reconstruct segment wrappers. Do not allocate an identity per IR
node or add a full traversal to construct the witness.

The consumer may reuse its previous successful body judgment only under the
same existing context gate and matching provenance from the **same successful
previous revision**. Raw-cache success and verifier success must share that
baseline, not just a producer. Misses use the current comparison/verification.
The producer must not mint evidence by doing the same extra deep scan we intend
to remove downstream. Establish equality of the complete old comparator's
projection, including regenerated wrapper fields/flags; retained body payload
alone does not certify the entire segment.

Initially use the witness only at the first raw-body verification boundary.
Keep direct-function comparisons unchanged: retained `P113DCandidate` inputs
do not imply identical `P113DFunction` results after readiness-dependent passes.
Do not carry the first witness through optimization or into the second verifier
until the intervening transformation establishes a corresponding contract.

In a diagnostic mode, run both old comparison and proposed admission. A new
reuse decision must imply that the old comparator and context gate accept it.
Recomputed-but-equal bodies may conservatively miss; count that lost opportunity.
Then turn off duplicate comparison for the timed candidate, retaining the old
route as a differential test oracle and the independent final gate unchanged.

Controls include changed and unchanged dependencies, inserted/reordered headers,
alias/layout changes, fresh-ID shifts including balanced changes, literal-pool
changes, bang flags, missing helper becoming present, failure/recovery,
edit/revert, mismatched raw/verifier revisions, stale/cross-producer evidence,
and retained-state eviction. Include a deliberately invalid reuse claim that
the independent comparison rejects. Current dirty-datatype refusal stays intact.

**Decision:** any false hit blocks escalation. For performance, seek2× reduction
in the affected stage and10% complete small-request improvement on two relevant
workloads under the [existing gate policy](../phase139/validation-gates.md).
Those thresholds select experiments, not statistical truth. If the seam is too
small to meet the end-to-end threshold, record a foundation only; combine an
adjacent measured boundary before paying for a full native acquisition. If
comparisons are cheap and the final verifier dominates, change priority promptly.

## 5. Sequence after the first result

| Step | Implementation and falsifier | Planning allowance / ambition |
|---|---|---|
| A. One exact evidence bridge | Raw→verifier slice above. Reject false hits or moving equal work into evidence construction. | First1–3h decision; no guaranteed speed milestone.|
| B. Composed downstream reuse | Propagate surviving product identities into optimizer admission, registry and rendering. Delete superseded scans from the active candidate; retain reference implementations in tests/evidence. | Several further hours, conditional on A; first path toward5×.|
| C. Persistent frontend products | Patch ordered checked/erased owners, lookup indexes, reachable views and maxima. Preserve duplicate precedence, error order and post-freshening contracts. Measure allocations/reclamation as well as visits. | Several hours to a narrow prototype; broader invalidation may require multiple sessions.|
| D. Direct retained units→objects | Reuse unchanged ordered authenticated groups without rebuilding the full QBE file. Emit fresh groups plus changed data/dispatch units, link with retained objects. | Roughly2–4h bounded integration after product identities exist; binding churn may block it.|
| E. Real request service | Accept unplanned successive edits in the retained Bend process, commit success transactionally, recover after errors/cancellation, expose receipts and bounded retention. | Roughly1–3h for a narrow protocol; hardening priced separately.|
| F. Fact-specific invalidation | Stop propagation when consumed semantic results are unchanged. Expand beyond late same-width edits; retain conservative global fallbacks. | Multiple bounded experiments; gains depend on edit family, not current hit counts.|
| G. Compositional verification and stable binding | Replace measured remaining global floors under explicit contracts; test narrow laws/certificates and stable literal/function placement. | Research track, not a three-hour commitment; prerequisite for a credible100× path.|

B and C may exchange order after profiling. D has a useful independent host-audit
preparation task, but a set-membership fix alone cannot meet its end-to-end budget.
E should follow the first integrated win, not wait for100×: a fast predeclared
batch is not yet a usable development loop. F may be necessary sooner if real
edits invalidate most units. Do not implement all steps just to finish a list.

For C, deleting the previous maximum requires a correct aggregate update, not
`max(old,new)`. Retaining an index is not enough if every lookup consumes and
reconstructs it: use actual Bend ownership/borrowing costs to choose a structure.
Keep only committed and pending revisions plus explicitly bounded shared products;
do not pin every old graph indefinitely.

For D, use compiler-issued bundle/completion metadata, including on reused pieces.
Do not parse QBE to infer compiler semantics. Deduplicate authentication within
an immutable supervised epoch; retain checks on incoming sources, external
objects and publication. The method hash is part of object-cache identity:
changing the auditor requires reseeding or an explicit validated migration.
No mtime-only trust or silently reusing receipts from a different implementation.

For G, distinguish symbolic unit identity from numeric runtime binding. Ordinary
ELF relocations cannot relocate all tagged heap-relative literal integers. First
retain canonical binding/exact output; only change binding with explicit handling
of insertion, deletion, capacity, tombstones and compaction. A history-dependent
layout requires a recorded manifest and different validation, and can change
runtime performance despite unchanged source semantics.

## 6. The ambitious paths and how to earn them

**1× ambition: one demonstrated removal of repeated work.** Within the first
bounded session, establish exact evidence transfer and a complete-request win,
or decisively identify why it cannot pay. Retain a useful experimental change
without overstating qualification. This is the foundation, not parity with a
different compiler or a promise of a particular speedup.

**10× ambition: a usable edit service around retained semantic units.** Compose
B–F until `Tbuild` is below the matched10× threshold on at least three predeclared
substantive supported edits, including a different owner and an earlier edit
when supported. Report every edit, fallback, cold cost and `Tready`. Aim for
changes proportional to affected units rather than total compiler size. One
34s late edit is a valuable scoped result, not a universal10× compiler.

**100× ambition: eliminate the remaining global floors.** Local updates should
verify affected units and their interfaces, preserve machine identities, and
materialize only changed code/data. Demonstrate a sub3.47s *actual* edited
executable before claiming100× on the historical baseline. Unknown final-gate,
binding and publication costs make this speculative. If ordinary linking is
already subsecond, do not write a linker first. Consider incremental linking
only after it is the measured dominant floor.

Useful Bend-specific proof work is a narrow replay/frame property: a judgment
for a retained immutable body remains valid when every fact it consumes is
preserved. The difficult part is relating the dependency summary to all actual
reads, not proving that equal inputs produce equal outputs. Connect any theorem
to the implementation's checker and dependency collector; distinguish a law
declaration, source checking, finite tests and independently accepted BendTT
proof. Keep the final verifier until an independently justified replacement is
ready. A whole-compiler proof is not the entry requirement.

## 7. Research lessons we should actually use

**Zig:** persistent compilation state, dependencies on individual semantic facts,
result-sensitive invalidation, tracked identity remapping and bounded function-IR
lifetimes work together. The July2026 implementation-author demo reports5s initial
and50–70ms updates for Fizzy on its own setup; it does not predict Bend cold or
optimized self-build times. Our pinned0.17 source audit also records limitations.
Transfer these boundaries while keeping QBE; do not confuse compact serialization
with avoiding semantic work. Sources: [implementation explanation](https://mlugg.co.uk/posts/incremental-compilation-internals/)
and [our pinned source study](../../research/phase133/zig-incremental.md).

**OCaml:** `.cmi` carries compiled interfaces, while `.cmx` also carries client
optimization information. `-opaque` avoids dependence on that implementation
information at a possible optimization cost. For Bend, separate required semantic/
ABI/ownership facts from optional optimization facts, without globally disabling
cross-function optimizations. A Bend reducible body can affect dependent checking
even with an unchanged signature. [Official native compiler manual](https://ocaml.org/manual/5.5/native.html).

**Dune:** its memo API supports recorded dependencies and output cutoffs. Revisit
consumers when their *consumed results* change, not merely because a predecessor
ran. This is build-system evidence, not proof that `ocamlopt` incrementally compiles
individual native functions. [Memo interface](https://raw.githubusercontent.com/ocaml/dune/main/src/memo/memo.mli).

## 8. Validation that informs decisions without consuming the campaign

Use [Phase139's complete gate specification](../phase139/validation-gates.md).
The following is the execution order, not permission to omit correctness gates:

1. Freeze source/tool/runtime identities and edit fixtures. Reuse exact existing
   references when applicable. Changes to the compiler-under-test cannot alter
   its independent oracle or acceptance rules.
2. Run20–60s focused contract controls after changing a reuse rule. Compare
   complete products and diagnostics, including rejection/recovery paths.
3. Run60–180s screens on actual affected computations and unrelated controls.
   Count removed work and whole-request cost, not just hit rates. Inspect the
   final-verifier floor before a costly campaign.
4. Acquire one native candidate only after a coherent set of changes survives.
   Run one frozen real compiler edit, then broaden at5×/10× milestones. Full
   acquisition/seed/reference blocks can cost25–40min; budget them explicitly.
5. Verify the rebuilt compiler actually contains the edit and compiles independent
   programs. Exact QBE with the same runtime/tools can reuse authenticated machine
   and runtime evidence. Changed binding/linkage requires corresponding checks.
6. Reserve full native reproduction and ordinary/focused conformance for adoption
   or materially changed semantic/ABI boundaries. Phase137 N3 remains available;
   ordinary Phase141 qualification does not qualify the incremental session.

Preserve the existing promotion limits: generated-program overall/family means
at most2% slower, any case at most5%, cold compilation overhead within5%.
These are decision limits, not confidence intervals. Phase140 has not established
the cold limit; a warm-only research success does not silently pass it. An
intentional larger cold/warm tradeoff needs an explicit decision and break-even
evidence. Preserve all initial results; confirm only flagged/noisy cases instead
of rerunning everything until it passes.

Predeclare edit classes: no-op, late local body, early/middle body, changed
reducible dependency, signature/layout, name insertion/deletion, literal-size
change, runtime/policy epoch change, failure/recovery and revert. No-op is a
control, not a headline. Include multiple edits within a session, report range
and median, and report tails only with enough observations to support them.
Track evaluated/invalidated units separately: a high hit rate can still entail
an expensive full traversal. Include retention/eviction and source-order scaling
controls to expose hidden whole-program work.

## 9. Spend research time where it changes the decision

First three-hour *execution* block, to be started separately from this design:

| Time | Desired decision/product |
|---|---|
|0–20min|Freeze inputs and reuse existing profile/source audit; add only the missing exclusive counters. Identify the affected-stage ceiling.|
|20–65min|Implement one producer/consumer evidence contract and dual-admission controls. Reject unsound evidence immediately.|
|65–110min|Measure small complete requests; remove displaced scans in the active candidate. Extend one adjacent consumer only if the first result warrants it.|
|110–155min|One integrated native edit if cheap gates justify its acquisition cost; otherwise investigate the next measured floor.|
|155–180min|Report effect, limitations, failures and costs; commit/push the coherent result and select the next seam.|

These are decision checkpoints, not deadlines for mandatory gates. Do not run
expensive jobs simply to occupy a block. If acquisition will overrun, finish a
clear experimental result rather than claim qualification. Further stages can
take several sessions; promising3h results would not establish the whole10× plan.

Use one coordinating implementation owner and, when useful, two bounded agents:
one audits invalidation/provenance, one prepares independent fixtures or inspects
the machine boundary. They should not each build full compilers. Keep one heavy
CPU3 lane, a4GiB process-tree cap,16GiB available-memory floor and an explicit
disk budget. Record research/agent work separately from build/verification wall
time; do not claim unavailable token/quota measurements.

Keep a fixed builder A while developing many candidate revisions B. Editing the
compiler source being compiled does not change A's executing policy. Adopting B
as the next builder changes the producer epoch and must pay its own reseeding
and qualification costs. This distinction is essential to useful self-development.

For a fixed edit family, compare actual costs:

```text
ordinary campaign    = ordinary setup + sum(fresh build + required validation)
incremental campaign = acquisition + seed + sum(update + required validation)
                     + failures + extra qualification
break-even updates   ≈ additional fixed cost / measured saving per update
```

Only genuinely additional qualification belongs in the difference; both methods
still owe their correctness gates. Include fallback edits and compiler-epoch
changes in a realistic workload. A3s update is poor research economics if each
experiment forces a fresh six-minute seed and repeated qualification.

## 10. Traps and stop rules

| Trap | Prevention |
|---|---|
|Another cache around every stage|Carry exact producer evidence once; remove the replaced discovery work.|
|99% hits but linear warm cost|Measure visits, comparisons, reconstruction, reclamation and bytes touched, plus complete latency.|
|Claiming10× from a slower candidate cold path|Compare the same edited B against the preserved qualified incumbent as well as candidate cold.|
|Only a late one-digit edit is fast|Freeze diverse edit classes and show unsupported fallbacks; improve coverage as a separate result.|
|Signature equality mistaken for semantic stability|Track reducible bodies, layouts, absence, freshening and other consumed facts; preserve conservative refusal.|
|Validation silently delegated to cache provenance|Keep independent oracles/final gate; provenance names a product, not all assumptions used to judge it.|
|Retained state consumes the machine|Bound current/pending history, test eviction/recovery and account for shared graph retention.|
|Skipping optimization to resemble millisecond demos|Keep the optimization policy and compare exact products first; price an explicit policy tradeoff separately.|
|106MB rebuilt behind a2MB update protocol|Connect retained units to objects and measure total bytes read/copied/hashed.|
|Stable names mistaken for stable machine binding|Audit literal addresses, dispatch IDs, fresh names and relocations; stage binding changes separately.|
|Full compiler validation after every edit|Small differential loop first; one acquisition per coherent candidate and authenticated evidence reuse.|
|A new architecture that only adds machinery|State which existing walks/containers each interface replaces; delete active duplicates when qualified.|

Stop broadening a proposal if it produces false hits, no complete-request gain,
unbounded retained state, or an unexplained material code-quality regression.
Preserve the failed evidence and change the bottleneck under investigation.

The best result would be a single reusable contract that removes whole-program
rediscovery from several stages, keeps generated code unchanged and makes the
next compiler experiment cheap. Start by proving that advantage at one real
boundary; earn the larger architecture through measured composition.
