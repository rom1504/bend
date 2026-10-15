# P95-001: native ownership attribution and intervention

Status: completed; attribution obtained, isolated intervention not promoted.
Baseline `5544d3b`, native source D04.
[Design](../../design/phase95/native-ownership-attribution.md).

Hypothesis: a small number of general shared-value observations or eager
disposals account for a material fraction of native compilation cleanup, unlike
the low-impact environment fusion tested in Phase94. Recover physical callers
on current images before choosing a transformation. Compare Map with full self
source rather than extrapolating the small fixture's profile.

Require exact image/table authentication, preserved raw samples, explicit phase
and unwind limits, a small intervention control, then an uninstrumented compiler
comparison. Ownership leaf fractions are not speedup predictions. Keep compiler
execution separate from the performance of its emitted programs.

Result: accepted five-request Map capture has 962 request samples, 56.44% in
cleanup, with every C product exact. Full self emits the exact 38.6MB C oracle,
but two timer overruns keep its profile exploratory. Recorded self request
samples attribute 27.08% to string-comparison cleanup, 7.87% to `kc` closure
disposal and 2.57% to `nb_contains` cleanup. Own-leaf samples are separate.
No allocation counts, full logical call tree or B2 CPU attribution is claimed.

The [membership experiment](P95-002-eager-membership.md) proves a local early-hit
mechanism but yields a neutral six-source screen and only a 1.2% full-input
difference in one pair. Production and installed images remain unchanged.
See the [report](../../implementation/phase95/README.md) and preserved raw evidence.
