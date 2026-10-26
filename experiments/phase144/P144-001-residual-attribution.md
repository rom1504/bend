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

Measured: the refreshed residual capture has10,083 samples with zero loss and
99.585% sampled-thread/process CPU coverage. The separate stage capture has
10,283 samples and23 exact entry intervals, including an explicitly optional
final-admission point. Both preserve the complete115,909,112-byte frozen QBE.
Diagnostic child clocks324.306s and330.816s are not clean speed measurements.

The disjoint stage budgets are117.000s frontend,50.806s admission/static/raw
lowering,64.031s initial optimization and first verifier,28.434s observer/final
admission,18.284s registry and51.845s output/exit. These explain why one lookup
optimization cannot plausibly establish a50s complete build.

The mechanism is now reusable as data-defined stage observations in
[`profiler/STAGES.md`](../../selfhost/tools/profiler/STAGES.md). A fresh generic
native Lexer gate passes its complete oracle and versioned sidecar;10 synthetic
contract tests and retained full/pilot replay also pass. Conditional absence,
duplicate entry, wrong order/address and incomplete coverage are explicit.

Evidence and interpretation: [stage profile](../../research/phase144/stage-profile.md),
[residual profile](../../research/phase144/residual-profile.md), and
[registry detail](../../research/phase144/registry-profile.md). The original
stage pilot's incorrect universal-final-pass assumption is retained as a failed
observation, not silently treated as valid timing.
