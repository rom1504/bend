# P54-003: direct compiler-image qualification

Hypothesis: direct named-field exports can use the existing stage0/no-G host
loader contract, allowing compiler execution without the legacy descriptor ABI.
First test restricted checked exports and term transport, then compiler-scale
emission and checked self-emission. Legacy private-image transformations remain
separate consumers until migrated.

Falsifiers: transport/erasure mismatch, missing API, changed source result/error,
resource refusal, recursion failure or non-identical qualified successive stages.
No emitter/source golden may be weakened; no hidden TypeScript fallback.

[Design](../../design/phase54/backend-cleanup-and-direct-bootstrap.md).
Preserve the working compatibility route until this experiment actually passes.
