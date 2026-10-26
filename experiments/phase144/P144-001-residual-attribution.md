# P144-001 — residual cost after the Phase143 gain

Parent `63dd41d`. Question: what actually occupies the remaining296.541s compiler
execution when the qualified Phase143 compiler processes the unchanged Phase142
source? The pre-optimization profile cannot answer this.

Reuse exact N2 object and a diagnostic runtime; independently bind source,
complete QBE, Base/carrier and sampler. First establish small exact-output
milestones, then collect one full profile with coverage/loss checks. Improve the
profiler with source-connected stage intervals where those boundaries are real.
Preserve output/refusals and do not count overlapping owner/physical samples
twice. A diagnostic process duration is not a clean speed result.

Decision: select the largest substantial representation/fact-lifetime experiment
whose actual consumers and removable work are identified. A hotspot count alone
does not justify a cache, a packed-IR rewrite or an estimated whole-build gain.

Status at design commit: not measured; no production or selected-image change.
