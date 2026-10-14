# P89-001: upstream and Bend JS compilers on Bun

Status: preregistered. Hypothesis: changing JS engine materially changes cold
and repeated compilation, so upstream-on-Node ratios are insufficient for the
user's parity target. Pin unchanged source/images and outputs. Measure upstream
and B2 on Bun and Node; native B1 is unchanged. A speed gain is unknown until
measured. Separate engine/runtime effects, compiler changes and packaging.
[Design](../../design/phase89/bun-and-native-output.md).
