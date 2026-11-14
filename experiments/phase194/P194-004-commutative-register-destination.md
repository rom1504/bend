# P194-004 — commutative operations into the right operand home

This hypothesis came from the new register-pressure diagnostic, not from the initial roadmap. The few-live loop repeatedly emits right→scratch, left→destination, operation scratch→destination, although the destination already contains the right operand and the operation is commutative.

Test a physical-selection capability: for U32/U64 add, multiply, and, or, xor, when both inputs have register homes and the destination equals the right home, emit the operation with the left home directly. No expression motion, changed liveness/allocation, memory operands, or general dataflow pass. Retain exact existing fallback for all other cases. Flags are not a P113 value interface; comparison/shift/subtraction remain excluded. Width-specific instructions retain U32 zero-extension and modular arithmetic.

Prediction: remove22 MOVs from the pressure-few loop. This count is not a runtime prediction. The new diagnostic is a development probe; require independent machine controls and transfer to ordinary native45 programs before selecting a production change. Keep negative runtime results and compiler-cost overhead.

Implementation and controls: `selfhost/tests/phase194/commutative-{select,hook,controls}.bend`, independent C observer and typed object/assembly driver. Results pending; no qualification inferred from fixture authorship.

Accepted exact v2 in maintained `register-binary.bend`. The cheap applicability
precheck avoids a second frame lookup on ordinary refusals. Seventeen structural
controls and50 machine functions ×121 edge pairs (6,050 observations per route)
pass. Few-live loses the predicted22 MOVs and takes22.6% less time; unique-product
loses two MOVs and11.1% time; many-live remains unchanged. Value-rebinding has
identical hot bytes despite a timing gain, so arithmetic causation is unproved.
Native source/generation gates pass. The final full-suite, compiler cost and
retained failed attempts are reported in `implementation/phase194/README.md`.
