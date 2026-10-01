# Phase39: research recommendations in practice

Work is in progress. The installed compiler remains Phase37 checked03; the new
source candidates have not yet completed release integration. The prospective
[design](../../design/phase39/README.md) and a portable checked03/TS baseline were
committed and pushed before promoting any source change.

## First checked candidate

`selfhost/build/phase39/checked01` contains the countdown and proof-scope changes.
Its checked build plus focused probes passed in 40.574 seconds with peak process
tree RSS 1,129,582,592 bytes. API SHA256:
`963caaea0005026a88f2aeadd0aec0b875bd457d968a69b9b1b6150370c2e298`.
Runtime, public ABI and upstream pin remain unchanged.

Fresh paired execution against installed checked03 and pinned TypeScript passed
all five selected points in 91.331 seconds, with five rounds per role. Numbers
below are milliseconds per call; each candidate range is disjoint from its
baseline range. This selected comparison is not an overall-program average.

| Point | Checked03 | Checked01 | Gain | Candidate / TS |
| --- | ---: | ---: | ---: | ---: |
| Numeric recurrence 256 | 0.016862 | 0.015691 | 1.075× | 7.518× |
| Numeric recurrence 1024 | 0.027217 | 0.022269 | 1.222× | 2.866× |
| Active ray 64 | 24.7351 | 9.86569 | 2.507× | 32.601× |
| Active ray 256 | 119.8518 | 38.18324 | 3.139× | 30.653× |
| Scalar loop 8192 | 0.142613 | 0.113024 | 1.262× | 1.137× |

These are protocol results, not universal steady-state ratios. Active-ray 256
baseline samples drift upward internally by 24–32%; candidate64 drifts downward
by 8–11%. Both source changes are present, so the combined gains cannot be
assigned exclusively to guard checks. Raw evidence is in
`selfhost/build/phase39/checked01-screen01/report.json`.

Actual countdown controls pass 66 oracles, 12 admission/refusal observations and
25 boundary observations. Actual guard controls pass 13 observations; full guard
checks fall from 730/2,973 to one per active-ray call. The emitted dependency
closure independently matches all 26 guard names. Details and failures remain
in the [countdown](countdown.md) and [guard-scope](guard-scope.md) reports.

## Further experiments

The [component experiments](components.md) first change saved output only. A
strict explicit-frame tree variant retaining generic leaf handling improves one
tree point by 1.509× in a short paired screen and passes 310 oracles, 112 boundary
checks and five admission observations. A broader handwritten component gains
2.2–3.1× across three sizes. The latter does not establish compiler admission.

An expression producer/picker prototype gains 7.0–9.2× in a short screen but has
substantial warmup drift. Longer confirmation and a general source rule are
still required. The [callback investigation](callbacks.md) found the existing
list-pipeline fixture already first-order, so it cannot measure callback
specialization. New affine fixtures are being checked before optimization.

## Preservation and next gates

All failures remain in fresh Phase39 directories, including sandbox-denied
read-only Git verification and an incorrect TypeScript Nat assumption in the
first countdown control. The corrected control checks exact public BigInt
results on all three compilers. Closed Phase35/36/37 evidence and 103 unrelated
starting files remain outside this phase's changes.

Pending: direct-component source controls, compiler cost, final-image regression
and conformance gates, release installation, evidence capsule and final report.
No PR comments have been posted.
