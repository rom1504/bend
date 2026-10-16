# P99-001: checked scalar widths independent of array packing

Status: planned, no candidate execution yet.

Baseline: Phase98 source `2a72bbdc…`, commit `795ad05`.
[Design](../../design/phase99/native-scalar-and-borrowing.md).

Hypothesis: the IO-bearing compiler loses existing scalar lowering because the
typed-scalar flag shares a global array-layout gate. A narrowly justified scalar
permission can recover raw character/capture transport without enabling array,
cold-constructor or product representations. This should reduce reference-tag
checks and continuation overhead across ordinary programs, including the compiler.

Falsifier: the emitted narrow fields do not change, their affected native workload
does not improve, or complete-value/authority controls expose an unsound premise.
Check source and generated-code shape before a full compiler rebuild. Record all
attempts here; pass qualification separately from deciding to promote.
