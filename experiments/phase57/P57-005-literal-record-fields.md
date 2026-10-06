# P57-005: ordinary literal fields reduce constructor work

Discovered during Phase57 profiling; this was not a preregistered ablation.
The hot KTerm constructor has 103/788 bytecode/TurboFan bytes in B2 versus
38/532 in B1. B2's constant computed fields retain map updates and three
runtime property-definition calls. Both allocate the same visible 144-byte
batch in this specialization. Aliases and the inert loop optimize away.

Hypothesis: equivalent ordinary literal fields reduce constructor execution
cost broadly. Preserve computed own-property behavior for `__proto__` and all
value evaluation order. First test an exact syntax-only derivative with ordinary
request oracles and fresh clean latency; do not infer a gain from instruction size.

Evidence: [V8 findings](../../implementation/phase57/v8-findings.md).
Correctness: unchanged baseline requests passed; optimization not implemented.
Measurement: code-shape difference observed; optimization gain unmeasured.
Decision: prioritize a bounded experiment, no promotion.
