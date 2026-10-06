# P57-006: avoid repeated constructor-query miss objects

Discovered during the full-emission CPU investigation, not a preregistered fix.
`kt` plus `missing` dominate self samples in both expensive emission stages.
`j_arm_type` still globally searches nested constructor lists. Each intermediate
miss constructs an absent KDef and two KTerms; an ultimately successful search
can generate many such temporary misses. Phase55's typed-arity improvement is
already present and covers a different path.

Hypothesis: recover row telescopes from the known normalized owner before a
global fallback, and avoid constructing full absence records for internal probes.
First count callers, owner visits, empty constructor lists and intermediate
misses. Retain checked uniqueness, lookup precedence and fallback semantics.

Evidence: [source comparison](../../implementation/phase57/implementation-comparison.md)
and [Phase57 report](../../implementation/phase57/README.md).
Correctness: original full emission retained exact B2/B3 bytes.
Measurement: scoped CPU attribution; improvement unimplemented/unmeasured.
Decision: bounded source-level experiment after the small literal-field probe.
