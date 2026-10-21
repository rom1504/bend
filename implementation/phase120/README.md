# Phase120: recover numeric identities and preserve numeric regions

Work in progress, starting2026-10-21 15:25UTC from`e1cc91f` (design parent
`962a3ef`), with the qualified Phase118 safe03 compiler as the exact baseline.
[Plan](../../design/phase120/runtime-specialization-and-parity.md) and
[bounded first cycle](../../design/phase120/first-cycle.md).

The first signed-word experiment recovers a useful operation lost by independent
primitive lowering. It proves that a low32 logical shift and exact sign-fill
selection refer to the same reaching value, then replaces their final OR by an
exact arithmetic-shift formulation. Calls, unknown memory operations and
unsupported joins invalidate facts. Original effects and both original/final
verification remain. No workload names choose the transformation.

Initial three-round screens give scalar-loop313ms versus parent431ms and
Mandelbrot718ms versus807ms; unrelated numeric recurrence is unchanged within
the screen's resolution. These are focused results, not a new whole45 score.
The scalar worker has90 machine instructions versus122, with four setcc rather
than seven. This is a whole-function static count, not the historical97-instruction
hot-loop count. Fourteen finite admission/refusal controls,60 independently
interpreted boundary values and the ordinary full-output boundary program pass.

The numeric-region investigation separates existing scalar-operand and float-lane
mechanisms from new branch-local facts and bounded leaf expansion. Operand-only
active ray is0.973×parent; local lanes0.870×; initial regions0.830×. The other
two numeric programs show little improvement. These separate screens retain their
own same-run parent/upstream controls. Do not attribute old lane gains to the
new region pass or infer general speedup from one favorable program.

Inspection explains an important limitation: the initial region passes leave
the central intersection calls intact. Immutable constructor-ID operands used
in Boolean tests were conservatively rejected. A separately versioned experiment
is investigating that restriction. The initial region also increases emission
cost, so a smaller output or successful verification is not a promotion criterion.

Every experiment uses checked Bend compiler modules, the unchanged Phase118
runtime, pinned upstream products and independent complete-output oracles. Two
offline agents help implementation/review; root alone owns serial CPU3 target
execution. Target processes use memory/time/output guards. No installed compiler
selection or native-image qualification has changed. Failed first source checks
and unqualified/rejected variants remain in the evidence.

Final measurements, reproducible evidence, cost accounting and recommendation
will replace this progress note at the end of the authorized one-to-two-hour cycle.
