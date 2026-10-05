# Exact generated-code examples

These are unchanged selected direct06 and pinned TypeScript modules for three benchmark sources. Each whole module includes its runtime support. No code has been normalized, reformatted or postprocessed. Copying these files executed neither compiler nor generated program.

They illustrate source and generated-code shapes. They have no independent speed claim; use the complete45-point performance report for measurements and its semantic-scope limits. The direct files use the upstream-compatible callable contract, not the legacy mutable-G interface.

| Example | Bend source | Direct06 | TypeScript |
| --- | --- | --- | --- |
| `test-rle-roundtrip` | [source](test-rle-roundtrip/source.bend) | [module](test-rle-roundtrip/direct.mjs) | [module](test-rle-roundtrip/typescript.mjs) |
| `lexer` | [source](lexer/source.bend) | [module](lexer/direct.mjs) | [module](lexer/typescript.mjs) |
| `coverage-expression-128` | [source](coverage-expression-128/source.bend) | [module](coverage-expression-128/direct.mjs) | [module](coverage-expression-128/typescript.mjs) |

The [index](index.json) records exact original and copied source/module hashes, selected compiler identity and catalog point/oracle. The preserved [catalog](catalog.json), [selected manifest](selected-manifest.json) and [reference manifest](reference-manifest.json) retain their original bytes and paths as provenance, not a relocated executable bundle. The portable benchmark bundles provide that separate replay interface.

Selected derived-B1 API: `472da578ff9066413f0a2b8e5c0053b5bc26eae8c3cb343b5b0cbb2a62c03a3a`.
Pinned upstream: `018751270e800bc222a93dad7f257083ee53a5f7`.
