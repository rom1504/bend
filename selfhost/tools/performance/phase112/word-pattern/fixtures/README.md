# Independent native source witnesses for scalar-pattern recovery

`manifest.json` freezes the source and raw expected stdout before candidate
execution. Each source also contains the same expected `#|` lines. All successful
cases require status0 and empty stderr. These files were prepared without running
a compiler or native program; checking and native qualification are separate gates.

- `boundaries.bend`: U32 zero, one, signed-boundary neighbors, maximum and default
  cases; Unicode Char literals and a dynamic String newline head.
- `owned-branches.bend`: literal17 selects one consumed String owner; default18
  selects the other. Both inputs come from String reversal, retained aliases of
  both are observed afterward, and the selected result is observed again. This
  exercises both unused-owner drops and retained ownership across the branch.
- `escaping-tail.bend`: returns an actual `Word(31n)` from a U32 destructure, then
  reconstructs its low bit as false. The current no-escaping-tail matcher must
  refuse this shape and preserve generic lowering; correct output alone does not
  prove that refusal happened. Inspect admission/emitted operations separately.
- `float-bits.bend`: explicit low-bit-first 32-bit constructor patterns distinguish
  positive/negative zero, signaling/quiet NaN payloads and both infinities. A finite
  value and another NaN payload use the default. These are constructor-bit tests,
  not floating equality tests. Outputs were assigned from the literal bit patterns.

Source expectations are not a proof of ownership correctness. Pair these witnesses
with the existing raw recognizer/refusal tests and inspect actual lowering before
interpreting a successful native run as evidence that the new path was exercised.
