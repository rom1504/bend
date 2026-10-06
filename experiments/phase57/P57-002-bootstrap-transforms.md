# P57-002: quantify the extra bootstrap optimizations

Hypothesis: equality and literal-choice/tail-choice image transforms explain
much of derived B1's advantage. Compare original checked upstream-emitted Bend,
derived B1 and direct B2 from identical Bend source. Raw/derived comparisons
isolate the transform group; B2/raw compares different generated forms.
Require identical emitted libraries and independent fixture outputs.

[Design](../../design/phase57/compiler-performance-attribution.md).
Results belong in [Phase57](../../implementation/phase57/README.md).
An image ablation remains diagnostic and is not an installed compiler.
