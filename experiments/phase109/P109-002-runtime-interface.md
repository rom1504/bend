# P109-002: ownership facts across the runtime interface

Status: qualified for the frozen owned-worker slice; no production promotion.
[Report](../../implementation/phase109/README.md).

Observation: raw direct QBE and direct Clang take nearly identical worker time
despite substantially different machine optimizers. This falsifies the idea that
switching machine backends alone fixes this kernel's initial direct-IR regression.

Hypothesis: admission can establish stable runtime preconditions once; explicit
consume/build/tail structure can preserve a uniquely consumed constructor shell
and reduce field-transfer calls. Shared/static data must retain correct behavior.

Candidates: raw checked imports, trusted imports with immediate discriminant
reuse, and generic adjacent take/build/tail reconstruction. Source names never
select an optimization. The original owned graph is verified before lowering.

Evidence: phase109 `contracts01`, `suite01`, `suite02`, `admission-before01`,
`admission-after01`, `paired02`; offline machine archive and the final capsule in
`implementation/phase109/evidence/`. Five alternating paired rounds:
raw QBE 67.36 ms, trusted QBE 23.65 ms, fused QBE 19.52 ms, production Clang
14.09 ms per 20 × 65,536-cell reverse operations. Fused QBE is 3.45× faster than
raw and remains 1.39× Clang time. Six/five/three calls remain per node.

Limits: one timed compiler kernel; unrelated String and discard/duplication
coverage are correctness controls. The trusted bundle changes checks and tag
reuse together. Runtime acquisition is separate. The cproc kernel control lacks
Phase108 v3 accessor expansions. No whole-compiler or upstream gain is inferred.

Next falsifiable experiment: preserve constant constructor/field identities and
typed multiple-result ownership transfers across the call interface; compare
machine code and the same frozen ownership cases before expanding coverage.
