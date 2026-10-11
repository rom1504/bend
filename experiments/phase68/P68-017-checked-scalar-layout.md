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
