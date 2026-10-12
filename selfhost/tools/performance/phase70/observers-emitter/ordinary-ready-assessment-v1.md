# P70-008 source assessment

The optional `ordinary-ready-v1.patch` changes one line and adds no source
lines. After the existing direct-entry check, a lazy `nt_choose` returns the
unchanged route if the original owner is already NF-ready. The actual Bend
plan query, typed schemas, annotations, private signatures, ordinary retry,
product selection and error/ownership lowering are unchanged.

`ordinary-ready-audit-v1.py` inspected six saved emitted C files without running
a compiler or native target. Its versioned JSON records exact source hashes,
ordinary/product/observer/adapter signatures, and each function body's hash.
Emitted NF definitions provide source evidence of final admission; this does
not establish dynamic call coverage.

| Saved source | Existing observer owner | Predicted policy |
| --- | --- | --- |
| Map family | `Map.bit.go`, `String.cmp` | Retain both; neither ordinary NF exists. |
| String-order coverage | `String.cmp` | Retain. |
| Tape coverage | `fixtures/tape-observer-v2:total`, `String.cmp` | Retain both. |
| Hidden scalar error | `inspect` | Skip; ordinary NF exists. |
| Partial factory demand | `inspect` | Retain; no ordinary NF exists. |
| Two-root alias | `strand:compare` | Retain. |

The hidden-error ordinary worker has parameters `Term` and `NF_SCALAR` after
the usual `Env`, `seq` and output arguments. Its exact signature/body hash is
preserved as a comparison oracle. The six C files contain 7–40 private worker
definitions each; these counts are not counts of avoided plan attempts.
Skipped failed analysis attempts must be measured directly by the root's next
compiler experiment.

Independent semantic review found no correctness blocker: the skip preserves
an already admitted ordinary route and does not weaken a proof. Membership is
for the exact original owner; product-only names do not trigger this policy.
The hypothesis registration records the possible loss of gains on dynamic or
scheduler calls into an ordinary-ready owner. Measure runtime before selecting
the policy, even though the inspected important recursive observers remain.

Plan-query acceptance stays unchanged. Emission selection must explicitly
record `ordinary-worker-already-ready` rather than invent a semantic refusal.
The prior twenty-source emission audit remains historical evidence and must
not be rewritten to fit the changed policy. A skipped hidden-error observer
cannot serve as an active observer error test; the retained partial-factory
case and separately routed recursive demand controls address that obligation.

No timing, candidate-build, conformance or selection result is claimed here.
