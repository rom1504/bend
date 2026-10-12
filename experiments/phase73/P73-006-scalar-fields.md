# P73-006: scalar constructor fields

Hypothesis: even checked monomorphic scalar fields become opaque64-bit values
at matches and private product arguments/results. Retain the same field-width
fact at these three boundaries so Clang can remove scalar keeps, sinks and
packing fallback. Only zero-parameter, unindexed user datatypes are covered;
erased fields do not shift live indexes, unknown field types stay opaque.
Facts require the existing checked/effect permission and apply only on CPU.
This changes no runtime representation, scheduler or C-recursion policy.
Measure tree, AST, BST and lexer, then retain only if the general benefit pays
for code size and compilation work. It is complementary to shared-root borrowing.
