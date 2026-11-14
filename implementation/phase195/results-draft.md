# Phase195 results draft

**Intermediate receipt snapshot: 2026-11-14 03:43:57 UTC. No final compiler
qualification, promotion, parity result, or full45 improvement is claimed.**
The reference is the qualified Phase194 N2 compiler's exact programs, freshly
timed beside each experiment. Its established full-catalog result remains
1.971034× mature Bend C; the partial screens below do not replace it.
See [checkpoint01](checkpoint01.md) and the frozen
[reference receipt](../../selfhost/build/phase195/references01/report.json).

## Completed development screens

Both screens cover the same six programs: local-pair, editdist, numeric256,
ray64, tree-bitonic, and lexer. They cover six of ten development cases and
zero of the original 35 held-out cases. Ratios compare role medians against
the baseline measured in the **same screen**; gains from separate screens
cannot be multiplied to predict composition.

| Mechanism | Six-case geometric ratio / baseline | Concrete observation | Current interpretation |
|---|---:|---|---|
| Physical compare/select | 1.00107 | Editdist 1.00730; local-pair 1.02320 despite hot row 77→65 instructions and unchanged 20 frame accesses | No useful standalone runtime gain |
| Constant-table calls to loads | 0.946039 | Ray64 0.729539; local-pair 1.00395 and numeric256 1.00181 | Retain for composition; regressions remain included |
| Hybrid joint/regional allocation | 0.998468 | Editdist 1.01000; ray64 1.01700 | No demonstrated useful standalone gain |
| Incoming branch facts | 0.920724 | Editdist 0.733333; lexer 0.963806; ray64 1.00350 | Promising development result; broader and composed evidence needed |
| Unconditional eleven-color pool | 0.992832 | Editdist 0.907216, but lexer 1.03793, ray64 1.02135, tree-bitonic 1.01567 | Mixed tradeoff; do not select the unconditional policy on this screen |
| Specialized sqrt call | 0.992282 | Ray64 0.931500, but editdist 1.02161 and lexer 1.00498 | Narrow candidate for composition, not a broad win |

The [physical/table screen](physical-table-screen01.md) has five balanced
rounds across five roles, a 250ms calibration target, 93 validated pilots and
150 measured samples. Lexer has a dispersion flag. The
[second screen](second-screen01.md) has three rounds across seven roles,
a 200ms target, 136 validated pilots and 126 samples. **Role positions are
not balanced** there; local-pair is dispersion-flagged. Its branch local-pair
ratio of 0.870367 is therefore exploratory. All flags and regressions remain
in the authenticated summaries. In the second screen, pool's fixed-catalog
equivalent sum increases 4734.48→4741.09ms even though its geometric ratio is
slightly below one.

The earlier selection-aware placement attempt also lacked useful runtime
transfer. Profiles explained why simply increasing admission is insufficient:
editdist's hot 99-row owner differs from the larger cold owner, and nine
physical colors face thirteen represented live values. The larger-admission
attempt increased stack traffic in ray functions. These are measured
frontiers, not evidence that every extra register or larger region is useful.

## Semantic controls and current composition

The branch, table, sqrt, physical and pool candidates pass their own finite
data/machine controls and six ordinary development output checks. Later RCX
and adaptive-pool controls also pass; adaptive adds thirteen profitability
assertions to the sixteen pool placement assertions. These later policies
have no runtime gain established by the two summaries above.

The combined source includes table-v3, branch/call facts and sqrt, with four
overrides. Canonical `x190_v_scalar` is unchanged; shared declarations occur
once. Float composition is excluded. Its checked hosted API and original
combined controls are complete: table has 17 data assertions and 2080 machine
observations per route; call facts have 12 and 1458; sqrt has 17 and 8192.
Each machine group uses direct ELF and rendered assembly from the same typed
sequence with an independently authored C observer. These are finite controls,
not independent compiler implementations or universal correctness proofs.
Receipts: [source preparation](../../selfhost/build/phase195/combined-source-preparation01.json),
[checked API](../../selfhost/build/phase195/combined-api01/report.json),
[table](../../selfhost/build/phase195/combined-table-controls01/report.json),
[call](../../selfhost/build/phase195/combined-call-controls01/report.json), and
[sqrt](../../selfhost/build/phase195/combined-sqrt-controls01/report.json).

Combined runtime transfer, held-out execution, full native reproduction and
final qualification remain open at this snapshot. Passing float-compose
controls alone does not justify including it. The maintained full45/44 metric
and final measurement policy remain unchanged.

## Ownership boundary and inspection disclosure

The independent borrowed-tree fixture improves to 0.404514× unique and
0.409837× shared baseline in four balanced rounds. This remains a finite
fixture ceiling. It is not a selected compiler transformation or a proof of
general actual-source admission. The first four owned-diagnostic API
acquisitions were rejected; those failures remain retained. Static audits do
not substitute for checked acceptance.

Ownership research inspected baseline generated code for
`coverage-map-churn-128` and `coverage-record-aggregation-256`, both in the
original frozen held-out list. Their artifact pins are recorded in
[ownership machine evidence](../../research/phase195/ownership/machine.json).
**Do not describe all 35 held-out programs as untouched.** Preserve the
original ten/35 split and original45/44 score; if final runtime is obtained,
add a separately labelled result for the remaining 33 after these two
baseline-code inspections. Do not silently redefine the held-out denominator.
Ownership is not selected at this checkpoint.

## Retained failures and recorded cost

The early sqrt emission and pool API run hit disk budgets because external
filesystem growth exceeded the declared roots' growth; these are resource
failures, not wrong-output findings. Retry plans raised their explicit budgets
to 96MiB, retaining the 5GiB reserve. Earlier source-checking refusals and
unexecuted malformed argv drafts are preserved. Recovery and retention work
are separate from compiler improvement.

The [guard-cost snapshot](guard-cost-draft01.json) records **79 terminal outer
guards: 62 passed and 17 failed**, including one prelaunch refusal. Their
summed wall time is **1779.923s (29.665min)**, including **119.781s of failed
jobs**. Failure reasons are fourteen command failures, two disk-budget stops,
and one disk-admission refusal. One in-progress guard is excluded at cutoff;
all counted terminal guards have sealed closure receipts. This is guarded
wall time, not CPU time, billing, full agent effort or compiler latency.
Unguarded metadata and retention/archival overhead outside these guards are
excluded.

The reusable tally reads immutable outer-guard receipts once each and performs
no target or retention action. Preserve this snapshot and use a fresh output
when the campaign is actually closed:

```sh
python3 -B selfhost/tests/phase195/tally-guard-cost.py \
  --out implementation/phase195/guard-cost-final.json --require-closed
```
