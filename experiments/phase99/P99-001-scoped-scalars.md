# P99-001: checked scalar widths independent of array packing

Status: source02/source03 implemented and tested; not promoted because measured native append time did not improve.

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

Results: source02 passes21native executions; source03 passes the same21 plus a full-width String/alias control. Four balanced long-work pairs give ratios1.02699 and1.02743. Actual assembly confirms narrow captures, but this did not improve execution. Five source-bound law statements independently check; three standalone-admitted bad helpers fail those unchanged laws. See implementation/phase99/README.md and the raw phase99 receipts for scope. No full compiler image build was justified.
