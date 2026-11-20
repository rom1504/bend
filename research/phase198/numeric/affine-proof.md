The candidate handles a positive countdown `n`, U32 counter `c`, and other
canonical U32 state `s`. Its checked abstract evaluator must establish:

- The prefix is pure, total integer operations, with no assignment to parameters.
- Every branch condition and each next state field is independent of `c` and `n`.
- The next counter is `c + d(s)` modulo 2^32. Only U32 addition/subtraction with
  independent operands preserves this fact; multiplication and full-word counter
  arithmetic refuse it. Branch joins retain the fact only under an independent
  condition.
- The backedge uses the exact U64 predecessor `n-1`; the sole return is `c`.

The ordinary prefix executes once. Compare every next/current noncounter state
field using full-word equality. When equal, the next transition reads identical
state and takes identical branches, so its delta remains `d(s)`. The remaining
result is `c' + (n-1) * (c'-c)` modulo 2^32. Truncating the multiplicand `n-1` to
U32 is exact for that result, even when `n` has a zero low word or equals 2^64-1.
The prefix and ordinary next counter still execute for every positive full-word
fuel. When state differs, the original simultaneous backedge executes unchanged.

A shared names/type/size gate retains original code for unsupported metadata,
reserved-name collisions, effects, observable fuel, invalid arity or excessive
bodies. The previous nonzero-mode certificate is computed from the original
prefix and may return even before the new prefix when it proves absorption.
The redundant inner positive-fuel test is removed only on a successful affine
rewrite beneath the existing full-width outer test.

This establishes the mathematical obligation, not broad qualification. The
independent Bend checker, separately written BigInt IR interpreter, refusal
controls, actual object emission and complete output checks remain separate gates.
