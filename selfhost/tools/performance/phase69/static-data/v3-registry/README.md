# Static integration registry repair

Build03 failed with undefined `ns_word`. Its assembled compiler contains no
`NS_Image` or `ns_word` declaration: the native manifest addition does not
automatically update `selfhost/src/compiler.json`. Add the new module to that
explicit full-compiler registry using this patch.

This is not evidence that forward laws are required. Existing cross-module
`nd_scalar_word` and within-module forward helpers have no such law and already
compile. All type declarations are hoisted before definitions by assemble.mjs.
The new module is appended immediately after native/book.bend.

The v2 implementation and consumed build03 inputs remain unchanged. This
follow-up edits no production source and runs no compiler target.
