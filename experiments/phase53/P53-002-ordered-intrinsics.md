# P53-002: statement-prefix lowering of computed intrinsic operands

Hypothesis: materializing computed operands in ordered statement temporaries
allows direct intrinsic expansion without the IIFE cost observed in P52-003.
The improvement should follow ordinary arithmetic/call structure, not benchmark
identity. Compare a checked correction/default-only baseline with the candidate.

Owner: lowering agent; independent semantic and review agents challenge order,
scope, partial calls, lazy views and dependency metadata. Root owns measurements.
Falsifiers: changed source semantics, earlier/later observable getter/coercion,
lost or duplicated evaluation, work escaping its demand scope, or no useful gain
on the unchanged rejection screen. Retain losing artifacts and restore baseline.

Plan: [Phase53 design](../../design/phase53/default-direct-and-ordered-expressions.md).
No optimization result is established by this plan.
