# Corrected cold-parent refusal controls

These versioned successors repair three source-fixture errors observed in
`selfhost/build/phase69/combined08-controls02/execution/selected/reference.json`.
The original fixtures remain unchanged. This directory was prepared by source
inspection; execution and generated-code assertions belong to root's lane.

| Fixture | Repair | Expected output |
| --- | --- | --- |
| `shared-user-refusal.bend` | Annotate the constructor literal as `Branch` | `30n` |
| `container-user-refusal.bend` | Annotate the list literal as `List<&2, Branch>` | `52n` |
| `captured-user-refusal.bend` | Keep the closure affine and duplicate its captured dynamic Branch inside the lambda | `25n` |

The original captured-user fixture attempted to copy a function using `+f`.
Bend rejects this because ordinary function types have kind `Type`, not `Data`.
Consequently it never tested a compiled ownership path. The successor tests
the meaningful typed boundary: a dynamic user constructor captured by a single
closure still must not be classified as unshared when the closure body copies
that capture. Its golden stays 25n, but this repair changes the witness; it is
not evidence that duplicable closures are admitted by the language.

All three candidates must emit `NATIVE_COLD_USER_CTORS 0`; matching output alone
does not establish that the global certificate declined. The separate passing
`fixtures/shared-user-dynamic-refusal.bend` remains the stronger nonliteral
direct-parent witness, since static lifting can make the literal variant's
runtime lifetime trivial.
