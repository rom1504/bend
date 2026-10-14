# P89-001: upstream and Bend JS compilers on Bun

**Final outcome.** Completed: all210 C comparisons pass. Upstream Bun cold process time is20.2% lower than Node, but our JS B2 remains faster on Node. Engine changes are not compiler gains. The final native89 screen and remaining warm gaps are separate. [Engine report](../../implementation/phase89/engines.md), [final screen](../../implementation/phase89/qualified-screen.md).

## Original registration and earlier checkpoints

Status: preregistered. Hypothesis: changing JS engine materially changes cold
and repeated compilation, so upstream-on-Node ratios are insufficient for the
user's parity target. Pin unchanged source/images and outputs. Measure upstream
and B2 on Bun and Node; native B1 is unchanged. A speed gain is unknown until
measured. Separate engine/runtime effects, compiler changes and packaging.
[Design](../../design/phase89/bun-and-native-output.md).
