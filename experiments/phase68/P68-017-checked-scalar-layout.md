# P68-017: checked scalar-array representation

Registered 2026-10-11 before compiler edits. Design:
[checked scalar arrays](../../design/phase68/checked-scalar-arrays.md).
Hypothesis: recover at least the measured packed-only benefit (3.38× in P68-016)
through general compiler analysis, with raw/unknown programs retaining the ABI.
Keep sharing lookups initially. No gain is assumed for other native families.

Success requires actual checked compiler emission, active packed accesses,
correct independent runtime outputs and qualified same-work timings. Reject
on truncation, layout mixing, ownership/atomic failures, unauthenticated raw
admission, absence of active optimized sites or negligible measured benefit.
Compilation and generated-program clocks remain separate.

## Outcome

Implemented in checked compiler20. Array packed-only18:278/278/289ms;
packed+unshared20:172/176/174ms in the narrow loop. Fresh final balanced array
comparison: installed14591ms, candidate184ms, upstream185ms. All independent
oracles pass. The six-family geometric mean is1.7449× upstream,5.6816× faster
than installed; these cumulative Phase68 gains include earlier work. Width and
sharing certificates are separate; unauthenticated/raw calls retain fallback.
See the [integration report](../../implementation/phase68/checked-scalar-arrays.md)
for correctness scope, an inherited foreign-ABI failure, B1/B2 costs and limits.
