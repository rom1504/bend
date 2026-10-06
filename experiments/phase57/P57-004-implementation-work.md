# P57-004: compare compiler algorithms and representations

Hypothesis: some of the Bend-port versus handwritten-TypeScript gap is extra
semantic work, different data structures or traversal algorithms. Inspect both
sources and profile comparable phases; identify term representation, indexing,
substitution, checking, specialization and emission costs separately.

[Design](../../design/phase57/compiler-performance-attribution.md).
Results belong in [Phase57](../../implementation/phase57/README.md).
The implementations need not perform identical work merely because both accept
the same input. Require concrete evidence before attributing their ratio to
the language, a representation or a compiler pass.
