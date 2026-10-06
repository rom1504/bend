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

## Outcome

Confirmed and installed in ordered02. Replacing intermediate ordinary-array
transport with a fresh typed array and indexed assignment preserves cold NaN
payloads and once-only conversion. The original source golden remains40:
candidate returns40 and pinned TypeScript returns1 because of its separate
constant-table defect. Candidate cold/repeated sequences are40/40/40.

The original suite passes96/96; expanded numeric controls pass34/34, including
finite, signed-zero, subnormal, ordering and renamed cold controls. Reference
numeric28/34 retains six healthy NaN-source failures. These overlapping scopes
are not summed. The correction-only eight-point screen is effectively speed
neutral (1.001759× versus original direct06); the later ordered optimization
is measured separately. See [diagnosis](../../implementation/phase53/nan-payload.md),
[qualification](../../implementation/phase53/qualification.md), and
[publication index](../../selfhost/tools/performance/phase53/publication.json).
