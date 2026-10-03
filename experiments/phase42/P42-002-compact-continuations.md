# P42-002: compact continuations

**Final outcome — Phase42 installed:** Compact saved-frame variants were not promoted: null or negative timing. Bounded native recursion with the original deep iterative fallback was accepted as a separate execution strategy. Saved-slot pruning regressed and remains excluded.

See the [final report](../../implementation/phase42/README.md), [mechanisms](../../implementation/phase42/mechanisms-and-decisions.md), and [complete results](../../implementation/phase42/results.md).

Original prospective status: investigate; correctness unchecked, measurement not run.
Baseline Phase41 checked01; unchanged pinned TypeScript. See the
[Phase42 plan](../../design/phase42/README.md) for hypothesis, falsifiers and
resource/admission requirements. Results belong in the corresponding owner
report under implementation/phase42; prototypes never imply installed gains.
