# P132-001 — Is generated text size mostly avoidable spelling?

Status: measured, frozen-artifact experiment; no production selection change.

Hypothesis: compact identifiers can remove a large fraction of the qualified
compiler's 107 MB QBE without changing its machine computation. This is not a
claim that the complete compiler can be represented in 1 MB.

Parent: Phase131 source `1bc5930e…728f9`, QBE `f3ff63b0…76e`, native N2
`2fae3602…5dc`; exact identities in the linked census.

Method: count token classes and instructions; bijectively rename globals and
function-local variables/labels outside strings/comments. Preserve exports in
the conservative experiment. Independently invert the mapping to exact original
bytes; build both artifacts with the same QBE/runtime/as/link flags and compare
allocated machine sections, normalized symbols and relocations.

Result: [census](../../implementation/phase132/census.md),
[compact experiment](../../research/phase132/compact-symbols.md). Conservative
private+local compaction removes46.27% of text. Machine text and allocated
sections match except the build-ID note; exported names and normalized symbols/
relocations match. One build pair saves about0.65s of13.97s child machine work;
this is descriptive, not a robust runtime speedup or Bend emitter measurement.

Negative finding: private globals alone save2.50%, all generated globals7.40%.
One million bytes is not credible through naming alone for2.29M instructions.
Host rewriting is charged separately and is not adopted as a production pass.

Next discriminator: integrate compact local identities before text construction
only if it reduces actual Bend request time/RSS without costly per-token lookup.
