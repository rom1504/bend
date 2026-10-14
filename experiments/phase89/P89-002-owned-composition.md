# P89-002: consume intermediate native compiler results once

**Final outcome.** Completed: the owned candidate improves Map cold/fifth requests19.6%/26.4%. Integrated with chunks in the qualified native89 image; the isolated ordinary-JS ablation is1.15% slower on the six-source request geomean, so canonical promotion is rejected. [JS ablation](../../implementation/phase89/js-integration.md).

## Original registration and earlier checkpoints

Status: isolated candidate passes 19 standalone and nine actual-lowering products,
three live checks and 84 paired cold/repeated full-C comparisons. Cold Map request
time improves 19.6%, fifth request 26.4%; small cases are neutral/slightly slower.
Broad integration and promotion remain pending. [Report](../../implementation/phase89/composition.md).

Original hypothesis: Map physical profile attributes11.58% of request samples
to destroying retained child code bodies after parent composition;30.68% is
append plus direct ownership. Hypothesis: destructuring NC_Code once reduces
retention/copy/drop work without changing any field/order. Full product controls
precede full C, cold/warm timings and broad gates. Budgets are not additive
promised gains. A chunk representation is a separate escalation only if this
small prototype leaves a demonstrated larger copy cost.
[Design](../../design/phase89/bun-and-native-output.md).
