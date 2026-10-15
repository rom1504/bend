# Phase98: co-develop useful laws and native compiler optimizations

Start: 2026-10-15 20:07:27 UTC. The user authorizes implementation, qualification,
reporting, commits/pushes and at least three hours of work: continue through
23:07:27 UTC, then finish any necessary consolidation. Baseline is `47ddee3`;
upstream `0592662`, maintained Phase90 compiler and qualified D04/native07 chain.

## Objective

Seek a material reduction in real native compilation time, aiming for20–30%,
while preserving generated-program behavior/speed, conformance and simplicity.
This is a target, not a forecast. Build reusable production-connected laws alongside
the transformations, measure their incremental contribution over finite tests,
and retain rejected experiments. Whole-runtime correctness is outside this window.

Phase94–97 repeatedly found large helper wins with negligible compiler gains.
Select widespread observation/dispatch/closure costs using existing physical
caller profiles and fresh bounded evidence. A helper-only win is insufficient.

## Work sequence

1. **0–15min:** authenticate current artifacts; inspect profile and generated-code
   evidence; choose related source-level and, if needed, backend opportunities.
   Register hypotheses, exact source patches and observation boundaries.
2. **15–60min:** first implementation wave: shared observations, dispatch, unused
   closure work. Develop safe reference laws and independently selected faults
   in parallel. Run real compiler screens as soon as candidates are admissible.
3. **60–105min:** improve/generalize successful transformations across hot callers;
   investigate shared-string comparison and projection/comparison fusion. A
   narrowly guarded backend prototype is allowed if source changes cannot remove
   the cost. Identify explicitly whether a change affects native B1, B2 or products.
4. **105–135min:** compose compatible winners, exercise law maintenance with a
   legitimate refactor, assess proof-only/test-only/shared detections, and repeat
   real request comparisons. Preserve failed mechanisms and redirect effort.
5. **135–165min:** qualify the strongest candidate using affected compiler stages,
   broader exact outputs/conformance and runtime checks when generated products
   change. Promotion requires sufficient evidence; no default flip from a micro.
6. **165–180min and consolidation:** implementation report, five-metric scope,
   reproducible commands, compact verified evidence, documentation, commits/push.

Time allocations are checkpoints rather than permission to stop early. If the
initial candidate is neutral, pursue the next justified mechanism during the
authorized window. Stop expanding candidate scope before final qualification.

## Laws and production connections

Reuse Phase96 term representation laws. Add obligations only where a concrete
optimization needs them: full observations, dispatch selection, preserved
evaluation/error behavior, alias/ownership transfer, and composition. Prefer
exact safe production helper bodies plus simple reference semantics. State all
premises and trust boundaries; a proof of a model does not prove C lifetime safety.

Freeze specifications before candidate results. Independently select well-typed
wrong implementations and legitimate changes. Compare frozen finite tests with
formal obligations: proof-only, test-only, both, neither; admit bad helpers before
crediting semantic proof rejection. Do not weaken a law to accept a candidate.
Any specification correction needs separate evidence and a retained old attempt.

For native observer experiments retain complete values and live aliases in tests,
inspect actual generated C, and identify ownership of escaped children. Never
enable a global borrowed-observer flag as a substitute for establishing legality.
Preserve diagnostics, ordering and all relevant payload/metadata fields.

## Efficient execution and qualification

Root owns all target executions, serially, under established RSS/deadline/disk
guards. Four narrowly scoped collaborators prepare proof, source/dispatch,
comparison/ownership, and independent challenges/review offline. They do not run
compiler/program targets, spawn additional agents, or edit canonical production
without coordination. Reuse existing toolchains/images; no large fresh survey.

Use seconds-long source/proof/full-value checks, then small native generated-code
and timing screens. Acquire full native candidates only after those provide a
mechanism and evidence. Balance timing order, preserve outliers, and avoid claims
from millisecond noise. Reuse the six-source actual compiler screen; expand a
material winner to full input and affected B2 qualification. Exact unchanged
program C can reuse artifact continuity; changed products need native execution
and representative timing before broader scope claims.

Native B1 is built by upstream C; native B2 by our backend. Source changes may
affect both. Our-emitter-only changes cannot explain a B1 execution improvement.
Keep acquisition/build time, compilation request time, process wall time and
generated-program runtime separate. JS/compiler conformance remains part of
integration when maintained sources change.

Maintain a file per hypothesis, frozen methods/patches, raw failed attempts and
time/resource accounting. Preserve unrelated dirty Phase6/68 files and pinned
upstream code. Do not edit human-written `bend2/bend.ts`. No PR comments.

## Deliverables

Useful production-connected obligations and reusable fast commands; measured
compiler candidates and justified promotion/rejection; independent fault and
maintenance evidence; a comprehensive Phase98 report and updated documentation.
Report actual gains and unresolved proof/runtime boundaries candidly. Record
target occupancy and elapsed work separately; do not invent quota percentages.
