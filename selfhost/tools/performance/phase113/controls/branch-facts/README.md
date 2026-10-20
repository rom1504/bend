# Independent mandatory-bit and branch-provenance controls

Root runs `controls-v2.mjs CHECKED_API FRESH_PHASE113_OUT` under its serial
guard. The API must export `p113k_optimize` and `p113d_verify`.
`manifest02.json` freezes the method and independent interpreter; the original
nineteen-case method is retained unchanged.

Twenty finite property groups compare original, transformed and twice-transformed
IR against explicit full-word values and runtime-call traces. Two further
structural controls require hidden `@condition:` names to be refused by local
identifier validation, with invalid input retained unchanged by the optimizer.

The mandatory-bit controls check low/high OR bits, an actual constructor-ID
operand, AND removal, XOR cancellation and intersections at joins. The relation
controls check copies, inversions, changed conditions, load replacement,
runtime/direct-vector writes, comparison destination aliasing, mutations inside
branches and joins of equal epochs with different expressions. Packed full-width
words retain their exact value even when parameter metadata says `N_W32`.

One deliberately important witness overwrites a predicate's subject with a
*different proven Bool* before branching on the old copied condition. It remains
bounded to 0/1, so the numeric range gate cannot conceal a stale-epoch bug.
Observable keep/sink order must remain exact. Three known-mandatory-bit cases
also require the zero-comparison operation to disappear.

These finite raw-IR controls do not execute generated native code or prove
arbitrary optimizer equivalence. The original scalar-facts suite and native
Bool/Nat/source controls remain separate gates. The control author ran no
compiler API or target while preparing these files.
