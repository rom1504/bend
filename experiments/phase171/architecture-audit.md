# Phase171: reduce complete compiler work before tuning dispatch

Source-only audit at `25dda2ff95e020d0dc3db799c2b46035c2f2022a`.
No compiler, generated program, profiler or machine-build jobs were run.
The installed Phase170 source is `434edd1d56128f9480800573abf8a0ae21d910a547837af089f25cd1d0e89b71`.
Its **189.329s** maintained cold QBE self-build includes machine construction.
A100s result requires **47.18% less complete time**; a20% step must save37.866s.

## Finding

The strongest remaining backend category is **repeated representations of the
same blocked computation**: construct a private candidate, reject its recursive
call interface, construct its scheduled family, then rediscover local callable
regions and render their public/continuation interfaces. The installed path
already avoids generic bodies for admitted direct owners. Repeating the old
“direct first” change or deleting thin public adapters is not a new opportunity.

Actual maintained boundaries:

- `early-observers.bend:340`, `p168_selected`, builds ordinary/product candidates
  for the non-seed names; `p168_candidates:328` runs SCC treatment and dependency
  admission. Prepared `NativeStaticBody` is already reused.
- `direct-lower.bend:82`, `p113d_call`, rejects a non-tail self call.
  `product-composition.bend:553`, `p126sc_tail`, requires an internal SCC call's
  residual body to be exactly its returned result. More admission fuel does not
  discharge either obligation.
- `early-demand.bend:288`, `p167l_family`, constructs the actual generic family
  only after demand identifies an unadmitted owner. `p167l_dispatch:322` keeps
  factories, generic implementations and admitted-owner adapters distinct.
- `local-continuations.bend:894`, `p114h_plan`, already admits bounded-shape,
  arbitrarily deep resumable computations. `p114h_close:823` resolves captured
  frames; `p114h_private:1062` emits explicit push/pop and loop dispatch. Current
  limits include arity/captures≤8, body≤512 and eight continuation cases. This is
  late analysis of existing generic segments, not an early callable interface
  through which private dependency admission can proceed.
- `early-emission.bend:44–76` seeds real private imports into region discovery.
  `stream-emission.bend:39,76` subsequently retains/emits private functions,
  legacy regions and public segments. Output already streams.

The consequence is both compiler work and execution work: a missing recursive
interface can keep its otherwise supported callers scheduled. The Phase167 real
verifier obstruction graph had61 error-free but dependency-blocked owners.
Breaking the comparison SCC subsequently admitted the predicted16 dependents;
`index_remove`, persistent insertion and verifier body/schema cycles remained
separate obstructions. Those are historical workload counts, not a census of
current full source.

## Two implementable approaches

| Approach | Concrete change and first implementation seam | Scope and risk |
|---|---|---|
| **A. Early verified resumable-worker interfaces** | Select one actual blocked SCC/owner from candidate-fate evidence. Reuse the existing `p114h` frame mechanism and original generic body as a temporary independent reference. Produce a checked callable frame-worker interface before `p113d_passes`; seed it alongside existing real imports. Keep required factories/public adapters and fallback. | Cheapest execution/coverage experiment: a bounded prototype in roughly2–4h if the existing plan admits the real body; estimate only. General SCC coverage needs explicit return/capture ownership and a verifier contract, not a fabricated ready entry. Initially it still constructs the generic reference, so compilation-work savings are limited. |
| **B. One function graph, two checked calling conventions** | At the prepared-definition boundary, lower once to a function graph retaining ordinary calls, branches, local identities and explicit suspend/resume edges. Derive the direct/private implementation or scheduled implementation from that graph. Run call-interface admission before constructing continuation families; retain a generic reference only for actual unsupported cases. `p168_selected`, `p167l_family`, and the registry/emitter boundary are the producer/consumer changes. | Larger architectural treatment, several sessions rather than a micro-patch. It removes failed-candidate reconstruction and repeated closure/flow discovery as well as exposing recursive callers. Requires full ownership, source/call-interface and independent-verifier obligations. Port one general shape end-to-end before broadening; a late pack/unpack layer is explicitly excluded. |

**Prefer A as a falsifier for B, not as a claimed100s implementation.** Make the
frame interface a real verified import with explicit ownership/return contracts;
do not mark a cyclic `P113DCall` graph ready or allow unbounded machine-stack
recursion. Do not simply raise `p114h` limits. First identify the actual rejected
predicate and measure the selected complete computation.

A constructor-tail rewrite is not a third missing mechanism:
`native-transport.bend:59–175` already contains `p118t` TRMC/destination handling.
The Phase164 explicit persistent-index zipper was neutral on complete native
operations:0.24517→0.24398s normal hashes and0.51873→0.52387s collision-heavy.
Replacing scheduler frames with another boxed path can just move the cost.
An explicit-frame experiment must reuse compact runtime frame storage rather
than assume that a source-level zipper is faster.

## Whole-build envelopes, not promises

The latest retained Phase169 N2 physical capture had5,484 samples,99.35% CPU
coverage and no lost/overrun samples. It predates final Phase170 and lacks an
active-owner/stage bridge. Its disjoint leaves were **8.59% scheduler/transport**,
**40.41% ownership/product/reclamation**, and9.50% named String-equality workers.
These are not independent inclusive costs of the same callers. Eliminating all
scheduler leaves would still be far short of20%; ownership work is not wholly
avoidable. This rules out a dispatch-only path to100s. The four-helper46.73%
figure from Phase166 is a small lookup kernel, not the whole compiler.

The older Phase161 stage partition had156.571/239.794s in the complete backend.
Generic body construction alone was11.588s (4.83%); private candidates26.782s,
initial optimization23.673s, registry16.190s, rendering/teardown40.208s. A2×
complete backend would have removed32.65% of that **old diagnostic CPU** total.
This is sufficient scale for a structural>20% hypothesis, but cannot be
subtracted from the current189.329s clean wall time. The new early route already
removed some of that work. Current stage attribution is needed before setting
an implementation budget.

A useful admission target is conditional: **2× on a region occupying≥40% of
current complete time gives≥20% overall**. Even2× on65% gives only32.5%, so100s
would require another substantial category or closer to3.5× on that65%.
Neither current evidence nor function counts demonstrate those conditions.
The final machine-build portion must remain in the denominator.

## Why Phase164 failed to deliver the structural gain

Its same-source full acquisition was201.931→201.271s, effectively neutral,
despite10.44% fewer continuation segments and4.68% less QBE. Direct worker count
stayed2096; downstream candidate construction, optimizers, metadata and output
survived. Imports-only reproduced its small generated-program improvements, so
those gains cannot be credited to generic-body omission. Existing generic entry
wrappers often already called the fast private worker. Counts of wrappers or
QBE text were not counts of duplicated executed algorithms.

Phase169's older canonical census similarly found77.9% of output bytes in the
generic family, but this is **text share**, not CPU share or proof those bodies
are dead. A successful new experiment must demonstrate removed work or a faster
complete recursive computation, not merely a smaller inventory.

## Cheapest falsifier and decision gates

1. On the current profile/source, record candidate error/dependency fate and the
   first `p114h_plan` refusal for a real blocked computation. Start with the
   existing nonempty320-case checker and recursive verifier closures. Reuse their
   independent complete oracles and existing request methods. Avoid an empty
   verifier or an isolated field getter as the transfer gate.
2. For A, freeze one general shape, actual body/reference and frame contract.
   Validate complete results, retained aliases, nested non-tail returns,
   mutual-call return order and deep valid recursion; preserve the existing
   refusal/fallback routes. No malformed runtime or failure probes. Charge frame
   setup, all calls, output and teardown. Inspect actual emitted calls.
3. Measure the complete native computation and full backend request separately.
   A2× tiny kernel with a neutral real checker rejects the proposed leverage;
   a material complete-checker win justifies one compiler acquisition. For B,
   additionally count discarded candidate bodies, generic families and repeated
   analysis visits actually eliminated. Do not add another precomputed-Base or
   compact-body cache.
4. Before promotion preserve source-derived array/unshared authority, ordinary
   composition and cold-constructor plans. Phase169's editdist regression was
   about19× until those paths were restored. Existing45-product checks and a
   small runtime quality screen are required before an expensive broad campaign.

No present profile proves a single>20% change. The best next action is this
bounded early-frame transfer gate plus the parent's current-source stage capture;
if blocked SCCs are not a material inclusive cost, stop A and use measured
producer/consumer duplication to select B's first end-to-end function family.

## Evidence

- [Phase169 physical profile](../phase169/native-n2-profile-summary.md) and
  [limitations](../phase169/native-profile-findings.md).
- [Historical stage envelope](../phase169/critical-path.md),
  [canonical product census](../phase169/canonical-product-review.md).
- [Actual admission obstructions](../phase167/admission-obstructions.md).
- [Phase164 mixed negative](../../implementation/phase164/mixed-findings.md),
  [non-tail comparison](../phase164/non-tail-comparison.md),
  [index zipper negative](../phase164/index-zipper.md).

Audited source SHA256: `early-demand.bend`6a65b9c995642446961df57fb0f4dce2cbc7736a43f08e2a22455d5912e70607;
`early-observers.bend`c717a76c9e5e3b21632f9e39b5662453509d7f12208216cdf4a48712c0929afc;
`early-emission.bend`7c4e797c06fc79d2444c669ad7aa70c061a987e2310894b7ec2ac165a9ed001a;
`local-continuations.bend`1a2b14366029fd912e642aa287f43098d41625d76684c1d6035f1e5fdf441523.
