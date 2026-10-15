# P95-001: native ownership attribution and intervention

Status: registered, unmeasured. Baseline `5544d3b`, native source D04.
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
