# Phase120: specialize verified computation toward native runtime parity

Status: **planned; implementation has not started**. This document is the sole
deliverable of the current request, together with navigation links and a commit.
Starting repository: `selfhost/bootstrap`, `26f2af2be303c24ef139f19f45a4941c97a89c9e`.
The qualified research compiler remains Phase118 safe03; installed selections
remain unchanged. Estimates below are hypotheses, not achieved performance.

## 1. Objective and evidence

Reach upstream compiled-program runtime parity by eliminating generic execution
work across verified regions. Keep the compiler written in Bend and retain the
direct QBE route. Improve native compiler execution and research throughput where
the same transformations transfer. Preserve conformance and keep the resulting
architecture understandable enough to continue improving it.

Authoritative inputs:

- [Phase119 profiles](../../implementation/phase119/README.md),
  [exact measurements](../../implementation/phase119/results.json) and
  [numeric machine audit](../../implementation/phase119/numeric-audit.md).
- [Phase118 selection](../../implementation/phase118/selection.json),
  [native qualification](../../implementation/phase118/native-results.md),
  [remaining opportunities](../../implementation/phase118/remaining-opportunities.md)
  and [source recipe](../../implementation/phase118/source-recipe.json).
- [Metric definitions](../../docs/self_hosted/METRICS.md),
  [compiler comparison protocol](../../docs/self_hosted/NATIVE_COMPILER_COMPARISON.md)
  and [current experimental frontier](../../experiments/STEERING.md).

The original45 corpus has44 timed points and one zero-work correctness sentinel.
Current QBE execution averages3.00893× pinned upstream C. The six difficult cases
in Phase119 average4.10290×, while mature selfhost C averages1.14186× on those
same cases. These different populations must remain separate. The latter
comparison demonstrates implementation headroom, not a controlled measurement
of QBE versus Clang alone; producer histories and optimization pipelines differ.

Current profiles establish:

- Scalar is2.134× upstream; its entire sampled execution is inside a call-free
  arithmetic kernel. The inspected hot iteration has97 instructions versus38
  upstream. Static instruction counts are not cycle predictions.
- Active ray is8.473× upstream. Intersection/nearest accounts for72.1% of samples;
  core assembly is unchanged by recent ownership wins. Typed-ABI-only experiments
  previously gained12.77%, insufficient to explain the entire remaining gap.
- List is3.419× upstream; destination fill/take2/extend1 accounts for59.5% of
  samples. Tree and map retain substantial field, construction and control costs.
- Current sampled libc work is copying; the earlier large fill share has gone
  from these captures. Physical leaves do not identify all callers or allocations.
- Native compiler destruction/reclamation accounts for28.1% of sampled leaves.
  Its exact lexer request takes1.89s versus2.68s on Phase114. That is a small
  diagnostic, separate from the three-source N1/N2/upstream comparison.

For a single program currently3× slower, accelerating90% of its execution4×
gives `3 * (0.10 + 0.90 / 4) = 0.975×` upstream time. This illustrates required
coverage and scale. It cannot be applied directly to a geometric mean or used
as a prediction. Parity requires improvements across substantial execution, not
one exceptionally favorable benchmark.

## 2. What counts as success

The primary goal is original-corpus geometric runtime ratio at or below1.0×,
with uncertainty reported. Retain the existing equal-point metric and also show
equal-original-family weighting, per-case ratios, family summaries, worst cases,
memory and generated-code size. Variations of one source are not independent
families. A favorable aggregate with large remaining deficits is aggregate parity,
not full coverage parity. A0.5× aggregate remains a stretch research objective.

Measure five axes separately:

| Axis | Measurement and decision |
| --- | --- |
| Generated-program execution | Same original sources, arguments, outputs, counts and pinned upstream products; clean timings separate from profiles. Seek broad parity and report every remaining deficit. |
| First compiler generation | Pin the checked hosted producer and qualified native N1 separately; report preparation, request, machine build and image acquisition clocks. |
| Second compiler generation | Qualify N2 independently before reporting its request/runtime behavior. Never substitute a hosted emission score for native-produced timing. |
| Conformance | Original output oracles, appropriate frontend/backend controls, verifier gates, ownership/stack/effect behavior and bootstrap consistency. State untested parallel/GPU scope. |
| Simplicity | Maintained Bend source and modules, runtime/support code separately, duplicated analyses, new ABI/capability obligations, removed paths and generated sizes. Evidence files are not compiler lines. |

Use Phase118 safe03 source SHA `a1aac003bbcac3731cc47b3c00dcc7e27f9323842fd26cb60417c2115e85ff10`
and runtime SHA `1b740d48e0db4504b214e0c909d0b5f28cd49064850e9be69fdb20a53a6c55fe`
as the initial research parent. Authenticate exact receipts instead of selecting
the newest filename. Preserve the distinct float01 timed producer and its exact
safe03 emission bridge. Installed Phase102 native and Phase90 JS are separate.

## 3. Architectural direction: retain facts until they remove work

The existing `P113DProgram`/`P113DFunction`/`P113DStmt` layer already represents
private functions, mutable locals, calls, results, branches and explicit loop
backedges. `N111Stmt` supplies structured machine operations; `p111v_*` verifies
them and `p111q_*` renders QBE. `p114s` boundaries preserve original verification
context. Mature `ntr`/`no`/`nh`/`ns`/`nr` plans and Phase118 already supply
construction, observer, cold-constructor, array and transport facts.

Extend those structures and analyses at the information-loss boundaries. Do not
create another complete compiler IR, mandatory SSA conversion or backend before
an experiment demonstrates that existing structures cannot express the need.

The small proposed interface is a verified function/region summary attached to
existing bodies. This is an interface sketch, not a new implementation mandate:

```text
ValueFacts:
  definition identity and source/program identity
  representation: generic Term | word32 | float32 | pointer | flat fields
  known range / canonical Boolean / constructor layout, when established
  ownership: owned | borrowed(root identity) | private destination
  escape and alias information required by this transformation

RegionSummary:
  parameter/result facts and existing structured body
  effects, possible failures, calls and required runtime interaction
  ownership transfers and roots that must remain live
  backedges, exits and fact obligations at each boundary

TransformationResult:
  replacement body + independently checkable obligations
  bounded size/work accounting + rejection reason
```

Start with only the fields used by the first two transformations. A word-valued
ownership category is not a signedness or Boolean-encoding proof. Bind facts to
reaching definitions; mutable variable names alone are insufficient. Copies,
branch joins, backedges with parallel assignment, memory aliases and calls must
transfer or invalidate facts explicitly. An unknown fact selects the existing
general lowering. Bound specialization per function and overall code growth.

Four uses of the same information should become possible:

1. Native scalar parameters/locals survive across private calls and local joins.
2. Proven field/layout operations lower to explicit accesses instead of repeated
   generic helper dispatch and copying through temporary field buffers.
3. Proven control regions use ordinary calls or loops while preserving required
   runtime interaction; unsupported recursion remains in the existing trampoline.
4. Non-escaping intermediate values are scalar-replaced or fused away, removing
   their construction, access and lifetime operations together.

Keep public/runtime boundaries compatible initially. Materialize generic values
only where the existing external contract requires them, and verify every exit.
The first direct field operations must retain actual heap/ownership semantics;
layout knowledge does not establish uniqueness or permit dropping a live root.

## 4. Hypotheses and gain estimates

These ranges describe successful mechanisms with adequate coverage. Zero or
negative gain remains possible. The ranges overlap and must not be multiplied.

| Hypothesis | Conditional performance potential | First decisive prototype |
| --- | --- | --- |
| Specialize generic runtime work out of verified regions |2–4× on heavily affected regions; perhaps1.5–2.5× across the corpus if coverage is broad |2–4h for one vertical slice with explicit representation, ownership and exit obligations |
| Recover exact scalar identities |15–35% less time on affected scalar loops; likely1–5% corpus-wide |1–3h including low32/Boolean/shift controls and a second numeric case |
| Preserve typed numeric computations across calls |25–50% less time on suitable numeric programs beyond the prior ABI-only result; ray-only aggregate effect remains limited |2–4h comparing ABI-only, local representation and region formation |
| Eliminate intermediate containers |1.5–3× on eligible pipelines; corpus benefit depends on distribution and transfer |3–6h for one pure producer/consumer contract and an unrelated transfer case |
| Reduce compiler temporary construction/lifetime |5–15% less request time from a first measured producer;15–30% from a broader successful change |Attribute one producer first; this estimate is not established by destructor leaves alone |

These are separate effort estimates, not promises that every prototype fits in
one six-hour session. A successful larger region might also expose specialization,
scalar replacement and eventually vectorization. Upstream ray SIMD is evidence
of an additional capability; scalar QBE region formation does not supply it
automatically. Do not build another backend merely to claim this potential.

## 5. Sequential phases and decision gates

### Phase A — freeze the decision and build one fact-propagation pilot

Reuse the Phase119 manifests, profiles and machine captures; no new broad survey.
Write one experiment file per mechanism before editing. Record exact source/API,
runtime, original oracles and parent products. Reserve newly selected transfer
programs/inputs before examining candidate performance. Existing45 is development
and regression data; a new input to the same program tests input transfer, not a
new program family. Record these distinctions rather than calling all data held out.

Implement a general signed-word identity recognizer in Bend at the existing
structured boundary. The first pattern is the low32 expression equivalent to
`(x >> 8) | (sign(x) ? 0xff000000 : 0)`. Establish reaching definitions, exact
constants and selection polarity before replacing it with a32-bit arithmetic
shift followed by the required U32 zero-extension. Preserve full-Nat shift-count
semantics; QBE's modulo-width shifts do not replace a source count>=32 guard.

Controls cover zero, signed boundaries, all ones, neighboring values, varied
counts where applicable, branch/copy invalidation and untouched fallback cases.
Use the existing law/control machinery for the exact local identity, plus the
independent source expression and generated-code execution. An optimizer's own
assertion is not independent validation. Reuse a suitable proved law where one
exists; do not start a whole-compiler proof campaign for this pilot.

Gate: correct outputs, fewer relevant executed operations in the hot machine
loop and a repeatable runtime gain on the complete scalar workload, followed by
an unrelated numeric case. Reject shorter IR with neutral/worse machine code.
A small clean win can be retained without meeting the later2× architecture goal.

### Phase B — specialize one complete native region

Choose a bounded region whose current hot path contains the missing capability.
Use intersection/nearest for numeric representation and one tree/map/lexer region
for layout/borrow/control transfer. Avoid benchmark-name selection in the pass.

Reuse the prior float-lane prototype as an ablation, not the final architecture.
The minimal comparison is:

| Variant | Change isolated |
| --- | --- |
| Parent | Authenticated Phase118 path |
| ABI only | Typed private arguments/results; same internal boundaries |
| Local representation | Native locals through computations/joins, if separable economically |
| Region | Bounded calls specialized/combined with facts preserved across boundaries |

Use existing structured instructions and extend typed operand/result support
where genuinely absent. The current `N111Type` word/pointer vocabulary needs
explicit checked float support for this purpose; merely naming a value F32 is
insufficient. Keep operation order and every required F32 rounding point.
Inspect conversions, calls, stack accesses, conditional work and actual hot
instructions for equivalent computations. Whole-function counts across different
inlining boundaries cannot stand in for this comparison.

Transfer the same fact/region mechanism to an unrelated integer, array or
ownership computation. For layout/borrow regions, eliminate proven generic
field-copy/dispatch operations using the same summary contract. Preserve root
liveness and all unknown/shared/static fallbacks. Do not infer unique ownership
from a locally named variable or constant constructor ID.

Gate: complete-program correctness and repeatable gain, identified by ablation.
If conversions merely move to the boundary or larger regions increase spills,
reject or narrow the transformation before adding more machinery. Seek roughly
2× complete-workload speedup in at least two unrelated families as the ambitious
case for broad architectural expansion. A single worker microbenchmark, related
ray variants or two passing programs do not satisfy that claim.

### Phase C — eliminate one intermediate structure

Proceed when the summaries can express escape, effects, ownership and sequencing
needed by a concrete producer/consumer pair. Analysis of a candidate may happen
alongside Phase B, but it must not block the first decisive region experiment.

Begin with a pure, bounded producer→consumer composition and exactly established
use multiplicity. Transform its intermediate list/record into direct loop state
or scalar locals. Verify that the allocation and associated operations actually
disappear from generated IR/machine code. Preserve the original fallback.

Evaluation-order changes require proof that interleaving is unobservable: purity
alone does not establish totality or absence of errors. Effects, failure order,
sharing, escaped values and unsupported recursion refuse fusion initially. A
recursive source traversal must not silently become unbounded native recursion.
Use ordinary deep inputs and preserved stack behavior to qualify the new path.

Test empty/singleton/long inputs, captured/shared/static values and scalar/boxed
elements. Then test a separate text/tree pipeline selected before tuning. Compare
fusion alone, region specialization alone and their combination; do not credit
the same eliminated work twice. Prior destination-cursor/cell-reuse failures are
preserved evidence, not reason to replay those implementations unchanged.

Gate: independently correct outputs, demonstrated disappearance of temporary
structures, material complete-program benefit and transfer. If only the known
list benchmark benefits, retain an experimental result without generalizing the
architecture or changing defaults.

### Phase D — make the compiler a workload and simplify shared planning

Use the qualified native compiler's ordinary requests before self-compilation.
Locate one producer of the destruction/reclamation work through bounded stage
or caller attribution. Distinguish frontend, analyses, lowering, rendering and
request teardown. Physical destructor samples do not establish which phase
allocates the objects or that caching an analysis would remove them.

Apply the same general region/fusion capability to the compiler implementation
where admitted. Keep source transformations separate from backend policy changes
when measuring their effects. Check the larger compiler catalogue for traversal
depth, worklist behavior, memory and specialization growth before image acquisition.

There is also a specific architectural simplification to investigate when its
cost is measured: let C and QBE consume one checked residual/semantic plan.
Phase118 already shares mature construction and observer plans, but one accepted
observer gate still builds discarded C text. Extract its validation obligations
before replacing that gate; never delete the independent check to save time.
Prepared-book bang analysis is an exact duplicated computation; original-book
and prepared-book facts are not interchangeable. Keep verification signatures
distinct from emission IDs. Reuse immutable request-local context where justified;
a persistent cache and large policy-search framework require amortization evidence.

Gate: exact output bridge where output is intended to remain unchanged, semantic
output checks when optimization intentionally changes code, and matched hosted/
native request costs. Report acquisition/qualification costs separately. A faster
compiler alone does not demonstrate accelerating optimization research.

### Phase E — integrate, qualify and measure distance to parity

Select useful orthogonal transformations using ablations; remove failed hooks
from the selected source while retaining experiment records. Consolidate shared
analysis and explicit boundary handling before a new full image campaign.

Run the original45 once a candidate shows useful transfer. Replay all outputs,
report44 timed ratios and the zero-work sentinel separately, include family
weighting and examine the largest deficits. Add the reserved transfer set.
If only a few families improve, investigate missing admission/representation
capabilities before launching an unconstrained rewrite search.

Measure hosted compiler cost early, then qualified N1/N2 requests and machine-build
cost after justified acquisition. Run native self-reproduction, focused controls
and native-produced corpus correctness with exact source/runtime provenance.
If claiming native-produced runtime performance, time those products or establish
an explicit exact-product bridge; one-shot correctness is insufficient.

Qualify any installed promotion separately. Preserve supported parallel scheduling,
effects and stack behavior in transformations; single-thread/GPU-off benchmarks
do not qualify changed parallel/device execution. Either preserve the unchanged
path for those configurations or run their applicable gates before expanding scope.

## 6. Initial four-to-six-hour execution budget

This is a future execution schedule, not work authorized by the plan-writing
request. Reallocate effort based on evidence; do not spend the whole session
building infrastructure or waiting for a full native image.

| Elapsed budget | Work and exit decision |
| --- | --- |
|0–20min|Authenticate current artifacts; freeze pilot/transfer selections and hypotheses. Reuse profiles.|
|20–90min|Signed-word/fact-invalidation pilot, independent controls, actual machine-code and clean runtime check. Stop a failed mechanism promptly.|
|90–210min|One bounded region prototype, ABI/representation ablations and an unrelated transfer attempt. Root owns target execution.|
|210–270min|Expand the strongest mechanism; begin a small fusion experiment only if its prerequisites already exist. Otherwise finish region transfer.|
|270–330min|Targeted regression set, compiler-cost screen, size/memory checks; original45 only if the candidate justifies it.|
|330–360min|Consolidate selected source, rejected attempts and report; decide whether broader architecture or native qualification is justified.|

The main high-ambition target is a reusable mechanism with roughly2× gain across
two different complete workload families. Missing that target is information:
retain simple sound wins, report the gap, and avoid claiming the expensive
architecture is justified. Full implementation of all phases can require several
such cycles. Do not promise parity within the first prototype budget.

## 7. Fast loops, measurement and acceptance discipline

Use the existing [Phase118 tooling](../../selfhost/tools/performance/phase118/README.md)
and [Phase119 refresh](../../selfhost/tools/performance/phase119/README.md).
Implement compiler analyses/transformations in Bend. Host tools may compose,
authenticate, supervise and measure; they must not become semantic lowering.

Prefer three increasing costs: local law/control plus one full program; a small
transfer/regression set with compiler-cost checks; then original45 and native
self-reproduction. Reuse immutable checked APIs, outputs and runtime objects
when their exact boundaries permit it. Never relabel a changed source/runtime
as an old qualified producer or overwrite hardlinked frozen artifacts.

Use paired rotated clean order on CPU3, preserved raw observations and fixed
source/oracle identities. Three rounds screen large effects. Repeat longer only
for noisy or decision-critical conclusions; use resampling/interval estimates
appropriate to paired observations for final claims. Treat shared family variants
as correlated when discussing generalization. Profile separately after the
executed graph changes enough to make the old attribution stale.

Provisional acceptance rules, fixed before candidate results:

- Any semantic, ownership, effect or stack-safety mismatch rejects that candidate.
  The existing verifier remains independent; new derived obligations supplement it.
- A repeated runtime regression above3% on a covered case triggers diagnosis;
  above5% blocks default selection until explained and fixed or scoped by a
  general semantic/profitability rule. Never exclude a case to improve the score.
- Investigate compiler-request or executable-size growth above5%; do not silently
  accept growth above10% in a default. An experimental opt-in path can document
  an explicit tradeoff. No new persistent cache to hide ordinary compiler cost.
- A sustained additional memory cost or specialization growth needs an explicit
  bound and source-scale control. Cheap, benefit-free passes are still removed.
- Report missed opportunities and refusal reasons with dynamic relevance. High
  refusal counts alone do not justify another policy search.

One root-owned serial target lane; ordinary guard2GiB RSS,16GiB available floor.
The documented6GiB image gate is reserved for justified native qualification.
Check disk before larger output; retain evidence and do not delete unrelated work.
Use ordinary valid-source controls; no custom failure-runtime probes. Do not edit
the human-written `bend2/bend.ts` or historical upstream checkouts.

Default to the leader implementing and measuring one candidate, with at most one
or two bounded offline audits when they remove a clear dependency. Agents can
review law obligations, source flow or machine differences on disjoint files.
They do not launch concurrent benchmarks or duplicate full acquisitions. Use
shared result messages and explicit stop criteria; more agents are not a throughput
goal. Record execution, failed attempts, acquisition, validation and research
wall time separately; do not infer quota/billing from elapsed time.

## 8. Correctness obligations and simplicity constraints

| Boundary | Required protection |
| --- | --- |
| Word arithmetic |Exact width, modular behavior, sign-fill polarity, count guards and output extension.|
| Bool values |Distinguish raw0/1 facts from source/runtime encodings; invalidate across unknown definitions.|
| Float operations |Preserve every required F32 rounding, NaN/signed-zero behavior and evaluation order; no unproved reassociation, FMA or speculative exceptional operation.|
| Ownership/layout |Prove root liveness, permitted sharing, constructor/field shape, destination initialization and escape behavior independently.|
| Control |Preserve cleanup, error/effect order, required polling/runtime interaction and bounded-stack behavior; handle backedge assignments simultaneously.|
| Derived code |Keep original program verification and check new calls, summaries, exits and lowered operations; source checking alone does not establish backend equivalence.|

Co-develop a small number of useful laws with each transformation. Reuse the
[existing law workflow](../../docs/self_hosted/COMPILER_LAWS.md); distinguish
machine-checked local identities, finite controls and empirical whole-program
agreement. Exercise rejection/fallback with ordinary sources outside admission.
Do not add a broad theorem library disconnected from generated-code changes.

Maintain one source of semantic decisions where C/QBE can actually share it.
Extract the smallest interface required by two useful consumers. Remove replaced
duplicate lowering from the selected path after its replacement qualifies; retain
explicit general fallbacks. Track obligations and concepts as well as lines.
No broad optimizer search, second compiler implementation or automatic policy
archive is required to establish the first general capability.

## 9. Deliverables and stopping decisions

For each execution phase, write a short design/experiment entry before the run,
commit useful implementation and evidence at coherent milestones, and finish
with a report under `implementation/phase120/`. Push completed work; do not post
PR comments unless explicitly requested. The report must include:

1. Hypothesis, exact selected/rejected source and runtime identities, commands,
   raw evidence and independent semantic results.
2. Ablations showing which work disappeared and which costs merely moved.
3. Per-case/family runtime ratios, compiler requests, acquisition, memory, source
   and generated size, alongside untouched and regressed workloads.
4. Qualification and production status, including remaining language/backend gaps.
5. Time/cost accounting and the next smallest decisive experiment.

Continue toward parity when improvements transfer and remaining deficits match
the same missing capability. Narrow or reject a mechanism when local instruction
improvements fail to change runtime, cost exceeds benefit, or generalization
requires many workload-specific exceptions. If QBE instruction selection or
vector capability becomes the measured limiting factor after representation work,
design one small backend capability comparison then; no new backend is presumed.

The intended result is a compiler that preserves enough semantic information to
remove whole categories of execution work, then uses those same capabilities on
its own implementation. Successive commits and self-reproduction remain distinct
from a measured positive feedback loop in research productivity.
