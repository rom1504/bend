# P53-001: avoid intermediate JS arrays in F32 bit transport

Hypothesis: the source-oracle failure at a cold NaN payload read is introduced
by JavaScript array-literal transport in `f32_bits`, not Bend pattern matching.
Direct typed-array assignment should retain the tested quieted payload bits
without affecting finite values or source operand evaluation.

Owner: runtime/NaN agent, with independent semantic and source review agents.
Scope: direct runtime; no reference/compiler-source golden changes.
Falsifier: any checked cold/repeated source case still differs from its raw-bit
oracle, any finite/-0/subnormal regression, duplicated coercion, or unsafe shared
mutable scratch storage. Pinned TypeScript's independent failure remains visible.

Plan: [Phase53 design](../../design/phase53/default-direct-and-ordered-expressions.md).
Fresh evidence belongs under `selfhost/build/phase53`; outcomes belong in
`implementation/phase53`. This is a pre-execution plan, not a passing result.
