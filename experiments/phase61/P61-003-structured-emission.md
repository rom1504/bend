# P61-003 — Transport structured code and dependencies before final rendering

Registered 2026-10-07 before Phase61 outcomes. Owner: root-assigned backend
investigator; root builds/runs; independent demand/FFI/order review required.
Status: correctness unchecked; measurement not run; decision investigate.

**Hypothesis:** A Bend-owned structured code/dependency result can avoid repeated
String construction and render/scan/render work during emitted reach and final
library output. Phase60 String allocation is≥ 5% on 18/23 and refs/uses on 8/23;
active raytrace and low-String numeric recurrence provide contrasting contexts.
Neither family share is a removable wall fraction.

**Invariant:** Structured dependency/use facts represent precisely the code the
ordinary emitter would emit, including closures, erased/demanded arguments, FFI
and mutual-tail components. Preserve selected roots, member order, final bytes
unless a separately reviewed semantic change is intended, and exact refusal/resource
limits. Source quotations cannot forge refs; malformed metadata cannot silently
be admitted. Preserve `JD_USE` lazy binder demand, partial/overapplication,
callbacks, effects/throws, capture hygiene and public ownership boundaries.

**Cheapest disproof:** One real emitter entry returns fragments plus typed refs;
compare its rendering/ref inventory against the untouched route on opaque nested
calls, Ctr fields, Let/closure captures, dead/erased versus live FFI, cyclic/mixed-
arity tails and unknown roots. Counters must demonstrate eliminated rendering/
scanning rather than new names for the same work. Numeric recurrence is a held
contrast to String-heavy raytrace; use MapSet for backend/reference pressure.

**Prior work:** Phase53 ordering/hygiene counterexamples prohibit eager expression
forcing; [Phase54](../../implementation/phase54/qualification.md) graph budgets
preserve bounded refusal. [Phase58 reach dedup](../phase58/P58-005-reach-dedup.md)
fixes duplicate edges under unchanged caps, and [shared SCC](../phase58/P58-006-shared-scc.md)
fixes copied switches. Both survive and are not sufficient evidence for removing
remaining String scans. Current `direct/reach.bend::jd_reach_definition` renders
via `jd_definition`; final `direct/core.bend::jd_definitions` renders selected
bodies again. [Phase59 ancestor partition](../../implementation/phase59/profile-stage-attribution.md)
is sampled context, not API call counts.

Freeze one ablation before timing. Gate known refusals and genuine activation,
then checked/source/B2/FFI/native scope and full 23 correctness for a survivor.
No runtime JS compiler implementation or string-only saved-image diagnostic is
promoted by this plan. Record failed attempts and changed acceptance/resource
policy explicitly; do not infer universal gain from backend-heavy examples.
