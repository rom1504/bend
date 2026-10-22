# Independent native typed-F32 controls

Two ordinary Bend files, thirty complete output lines, pinned by `cases.json`.
`prepare.py` computes the independent output oracle and hashes files; it does
not compile or execute Bend. Source checking and target execution are root-owned
and pending. Preserve these files after execution; create versioned replacements
if a checker exposes a source mistake. This suite does not establish admission or
performance: inspect the derived worker before attributing a successful output
to a typed transformation.

`channel.from_bits` uses ordinary `U32{word}` destructuring and `F32{word}`
construction, as in `tests/compile/f32_table_nan_bits.bend`; no nonexistent
`F32.from_bits` primitive or foreign helper is introduced. `channel.raw_bits`
extracts that same Word without arithmetic. Native payload expectations are
intentional; the JS execution representation can quiet NaNs and is not the
bit-exact oracle for this test.

## Boundary values and evaluation

`float-boundaries01.bend` transports positive/negative zero, positive/negative
infinity, quiet NaNs with payload one and either sign, and the least positive
subnormal through ordinary helper calls. The inactive selection arm returns
positive zero. These transports must preserve exact bits; arithmetic NaN payload
selection is not asserted. NaN equality is false and inequality true.

The two deliberately non-algebraic witnesses are:

- `(16777216f + 1f) - 16777216f = +0`: the first addition rounds to even in
  binary32. Keeping the intermediate in binary64 would incorrectly return one.
- `((1 + 2^-23)f * (1 - 2^-23)f) - 1f = +0`: the exact product is `1 - 2^-46`,
  which rounds to one before subtraction. Fused multiply-add would return
  `-2^-46`, so preserving only the final mathematical expression is insufficient.

The same raw word `1065353216` is used as a U32 and as F32 one. Adding one gives
integer `1065353217` versus F32 two's bits `1073741824`; lane kinds cannot be
inferred from their common integer carrier alone. Rebinding and a retained
external float alias check that mutation of compiler-local slots does not change
the old value. The final two IO helpers print `first`, then `second`, before
printing the bits of `1.5f - 2.5f`. Typed regions must retain the effect boundary.

## Backedges and mixed ownership

`float-state01.bend` uses `(x,y,s) -> (y,x+1/4,3s+1)` from `(1,5,2^32-1)` at
depths 0, 1, 2, 17 and 4096. It catches sequential rather than simultaneous moves,
F32/U32 confusion and native-recursion reliance. Exact expected coordinates use
the closed forms: at even `n=2m`, `(1+m/4,5+m/4)`; at odd `n=2m+1`,
`(5+m/4,1+(m+1)/4)`. All remain exactly representable in binary32. The stamp is
`-(3^n+1)/2 mod 2^32`, independently calculated using modular exponentiation.

A mixed `Parcel{U32,F32,String,F32}` repeats the recurrence at 17 and 4096 while
preserving an externally observed alias of the complete original record. Both
the mutated result and original record, including their heap String payload,
are printed completely. Refusing this record while accepting scalar workers is
a valid narrow implementation; reinterpreting the String or overwriting the
retained record is not. Depth 4096 is an ordinary bounded semantic witness,
not a failure or stack-exhaustion probe.

The effect witness does not authorize crossing arbitrary foreign, closure, or
parallel boundaries. Existing checked admission must conservatively refuse or
adapt such edges. Keep the original unsupported-path and primitive-identity
controls alongside this suite.
