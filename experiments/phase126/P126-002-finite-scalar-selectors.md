# P126-002: preserve finite scalar computations as constant tables

Status: checked prototype; runtime and independent observations pending.

The Phase126 machine audit found upstream emits finite scalar selectors as table
loads while the selected QBE path retains their decision ladders and closed float
computations. Test this independently of typed arguments before composing them.
This is a bounded extension of the persistent-value design: preserve a complete
closed computation, rather than making its individual arithmetic calls cheaper.

Implementation is checked Bend. Recognize canonical unary Nat selection with
four to sixty-four finite U32/F32 results and a constant final default. Evaluate
only authenticated scalar primitives and bounded closed scalar helper calls, with
each F32 operation rounded independently. Refuse unknown effects, free inputs,
owning helper arguments and fuel exhaustion. Lower to ordinary decision IR;
after the unchanged verifier, independently rederive the exact table from that
IR. Clamp the complete unsigned 64-bit Nat index before loading immutable data.
Do not truncate large indices or change the fallback compiler.

Frozen implementation: `selfhost/tools/performance/phase126/specialization/manifest01.json`.
Checked composition: `selfhost/build/phase126/table-source07/manifest.json`.
Checked API: `selfhost/build/phase111/p126-table07-api/report.json`.
Independent source review: `implementation/phase126/table-review.md`.

Controls cover exact float bits, large Nat indices, closed helper folding and
semantic refusals. Query refusal admission explicitly: some ordinary negative
examples are below the profitability threshold, so output equality alone cannot
prove that the semantic refusal is active. Require a non-ray transfer witness.
Compare table-only, typed-only and their composition on original frozen sources;
report whole-program runtime, actual machine instructions and compilation cost.

Stop if real selectors are not admitted, output differs, the complete runtime is
neutral, or analysis overhead exceeds its measured benefit. No benchmark names
participate in compiler admission, and no frozen benchmark definition changes.
