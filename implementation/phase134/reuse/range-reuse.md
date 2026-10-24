# Exact inner-range reuse: checked, screened, not selected

The inliner already invokes `p113k_function`; the outer pipeline subsequently
applies the same pure range transformation. The experiment records the actual
inner `(input, output)` pair and reuses the result only when the outer function
is structurally equal to the recorded **input**. Otherwise it executes the
original pass. It does not assume idempotence, use the output as a key, or reuse
unchecked data across revisions.

This preserves original inlining admission, stack limits, scanning order and
publication into the inlining table. It uses the separately audited unchanged-
function verification optimization; the existing independent final verifier
remains intact. The implementation and source argument are in
[`range-reuse-v01.bend`](../../../selfhost/tools/performance/phase134/compact/range-reuse-v01.bend)
and [the audit](../../../selfhost/tools/performance/phase134/compact/range-reuse-audit.md).

The actual combined source passes all **79 controls**: 26 verification-reuse,
20 range-reuse, 18 existing optimizer and 15 emission controls. All three full
products equal the qualified frozen native QBE. The subsequent complete-request
screen compares the extra range memo against **verification reuse alone**:

| Request | Verification only | Additional range reuse | Ratio | Exact memo hits/misses |
|---|---:|---:|---:|---:|
| Lexer | 5.935 s | 5.012 s | 0.845 | 11 / 20 |
| Closures | 0.510 s | 0.654 s | 1.284 | 3 / 4 |
| Map | 8.104 s | 8.143 s | 1.005 | 23 / 11 |

These are single ordered hosted pairs, with the closure pair reversed. They are
not calibrated native effects. The complete screen, including independent
hit census work, costs 39.00 s and peaks at 547 MB.

**Do not select this extra memo machinery from these results.** It removes
actual range calls, but its additional retained IR, list allocation and equality
checks do not demonstrate a broad complete-request benefit. The largest hit
count, on Map, gives essentially unchanged elapsed time. The lexer observation
is vulnerable to JIT/order effects, and the closure result is worse. Further
native qualification is not justified merely by the hit counts. The selected
native candidate therefore contains verification reuse and the no-copy writer,
without these range memo types or orchestration.

Two negative controls were useful. The first source attempt exposed unsupported
computed match scrutinees in the test code; typed continuation helpers fix this.
The initial "changing pass" test used U64 addition, which derives a bound but
does not produce the expected exact fold in this pass. Its no-idempotence control
failed. The replacement uses supported exact XOR propagation; all 20 range
controls then pass. Original failed attempts are retained rather than changing
the expected result to hide the mistake.

The stronger next reuse boundary is a separate experiment: retain exact input,
consumed inlining-table facts and optimized output **across a real source edit**.
That can avoid an entire expensive transformation instead of paying retention
and comparison costs to remove a smaller duplicated pass in the same request.
The present screen neither proves nor disproves that future cache's value.

Evidence: [79 controls](phase134/range-finite02/report.json),
[three-request screen](phase134/range-screen01/report.json),
[checked source](phase111/p134-range-api03/report.json).
