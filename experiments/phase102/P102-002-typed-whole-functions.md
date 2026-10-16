# P102-002: remove continuation transport with typed whole-function lowering

Status: registered 2026-10-16. [Campaign](../../design/phase102/ambitious-native-campaign.md).

Hypothesis: extend existing direct/scalar lowering across a larger typed region
so scanning/state-machine programs avoid repeated saves of 10–15 values.
Phase101 physical source-index profiles identify three continuations accounting
for about 34.5% of sampled leaves. Those shares are evidence of location, not a
speedup estimate or a complete ownership attribution.

Inspect existing lowering and refused shapes first. Prototype a general
structural mechanism, preserve strict calls and fallback, then measure complete
source indexing and held-out applications. Expected useful gain is conditional;
do not replace an application with handwritten code. Record compiler code size
and acquisition cost before integration.
