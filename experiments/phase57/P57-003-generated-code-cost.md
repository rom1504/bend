# P57-003: generated control flow, allocation and wrappers

Hypothesis: compiler-heavy patterns expose a code-generation gap not covered
by the existing warmed program corpus. Collect matched CPU profiles first,
then allocation and selected V8 evidence. Compare the same hot definitions
across raw upstream output, derived B1 and B2, preserving source locations.
Static object/closure/call counts are opportunities, not observed execution cost.

[Design](../../design/phase57/compiler-performance-attribution.md).
Results belong in [Phase57](../../implementation/phase57/README.md).
Use a bounded isolated diagnostic ablation only after a profile identifies
a candidate cause. Retain failed captures and label unproven explanations.
