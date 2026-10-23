# P129-001: semantic facts as reusable compiler work

Status: research and current-image profiling complete; compiler transformation
not attempted. Selected compiler remains qualified Phase128 source02.

Hypothesis: preserving/reusing checked semantic facts and ownership across
complete computations removes more work than another independent recognizer.
Investigate Bend2's actual proof/type/runtime capabilities before assuming they
already certify the optimizer or provide QBE parallel execution.

Evidence: [research](../../research/phase129/README.md),
[selected-source audit](../../research/phase129/selected-compiler-audit.md),
[new profile report](../../implementation/phase129/README.md).

The fixed Base decoder runs the same 1,087,899 decimal-parser entry segments on
each short request. Map usage queries and register-bank transport remain useful
targets. Forty captures pass the existing sample-quality gates and 55 complete
QBE observations match retained oracles. Active contexts, physical leaves and
event counts remain separate; no new speedup or full-source exposure is claimed.

Negative/limiting findings: affine use is not physical uniqueness; 680 selected
`law` signatures are not 680 mathematical proofs; `@unsafe` remains a broad
kernel boundary; QBE intentionally serializes and its RFC-load optimization
assumes one worker. First context preparation refused an omitted quoted header
before build and was corrected in a fresh path. No correctness gate was weakened.

Next: compare a fixed-state materialization ceiling with a complete borrowed
scalar query; separately test one safe use-summary theorem and production bridge.
Follow [ranked costs and falsifiers](../../research/phase129/qbe-opportunities.md).
