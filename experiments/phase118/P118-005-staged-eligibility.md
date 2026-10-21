# P118-005: avoid work after an observer has already been rejected

Status: checked and measured; neutral and excluded.

The checked float API eagerly evaluates all10 Boolean predicates in
`p118b_eligible`, including the mature C residual emitter, even when an earlier
condition rejects the plan. This is source/machine evidence of avoidable work,
not a measurement of its cost. `eligible-staged.bend` keeps identical predicates,
arguments, order and bounds, but uses9 lazy gates before the final residual gate.
Accepted workers retain the complete independent residual and QBE verification.

Independent review found no finite-pure semantic discrepancy. A rejected
candidate's residual diagnostic was never exposed: the function returns only
eligibility. Plan errors and accepted-worker lowering errors remain unchanged.
No effect/provider call is skipped. Prelude/schema/env construction remains eager.

Test the isolated float-source01 plus this one override. Require checked source
and byte-exact frozen emissions before paired same-Bun cost measurements, with
separate prepared seeds and retained warmup. Keep target execution serialized
behind the current native qualification. Source and measurement are independent
of safe03; do not silently relabel its native image as containing this change.

A gain must be material relative to observed variability. Start with lexer,
map128 and tree, then decide whether broad cost/equality and a new native image
are economical. Even identical emitted programs do not establish native image
qualification for modified compiler source. The archived cost-v2 harness changes
only explicit baseline selection; unchanged source/runtime pins and per-role
output hashes still authenticate both roles.

## Result

Checked API passes in12.32s. Three emissions match the selected float candidate
byte for byte. The paired cost campaign retains one warmup and three measured
rounds:24 complete output-hash observations. Whole prepared-request geometric
candidate/float ratio **1.000453×**; admitted entry **0.995824×**. Whole-request
per-case ratios: lexer1.01723, map1280.99279, tree0.99154. These are effectively
neutral, not a validated optimization gain. The full API/emission/cost guard
costs222.526s and peaks at1.696GiB.

Decision: retain the simpler selected eligibility code. Avoidable work is not
necessarily a measured bottleneck; do not extrapolate rejection counts into a
speedup. The staged source remains separate from safe03 and is not selected or
native-qualified. No new broad campaign is justified by these results.

Reproduction receipts: `selfhost/build/phase118/lazy-cost-plan01.json`,
`selfhost/build/phase113/p118-lazy-cost01/report.json`, `lazy-emit01/report.json`,
`lazy-cost01/report.json`, and `lazy-cost-guard01/process.json`. Exact source
7f9342449cd1d225c7414a20cff1654c715e3a6299c76db14c8e542d8264df93.
