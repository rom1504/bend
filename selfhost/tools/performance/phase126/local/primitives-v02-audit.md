# Explicit F32-to-U32 operand projection

This is a bounded extension of the selected local renderer, not an ABI or
arithmetic-policy change. The parent module is frozen as `primitives.bend`;
`primitives-v02.bend` replaces it in the same nine-module composition. No target
or compiler has been executed by this audit's author.

## Missing mechanism

The Phase118 fallback already removes the generic runtime call for operation58
in `p118f_to_u32`. Thus this change does not newly eliminate that runtime call.
The gap was the whole-buffer operand audit: the group recognizer admitted the
other arithmetic uses but rejected the final unary58 use. In local06's active-ray
`pixel` worker, the remaining shared scratch buffer has125 textual references
and the machine frame is0x928 bytes. Most of its float groups consequently
retain store/load/cast transport even though their arithmetic is already inline.
Those counts are static observations, not runtime fractions.

## Exact delta

- `p114so_group_call` admits operation58 only with the original exact state,
  helper symbol, U64 result, unary count and nonaliasing checks.
- `p114fl_text` sends that group to new `p126l_to_u32`.
- The new helper consumes `P114FLOperand` and otherwise reproduces the exact
  operation sequence of `p118f_to_u32`: ordered `value >= 0`, ordered
  `value < 4294967296`, conjunction, guarded `stoui`, zero extension, or0.
- `p114fl_result` is unchanged. Operation58 removes any old destination float
  fact; its U32 result is never mislabeled as an F32 lane.
- The original whole-function buffer audit, original structured IR and verifier,
  word ABI, loop argument snapshots, effect ordering, and unknown-use fallback
  remain unchanged.

Only the explicit operand transport changes. The operand either reuses a
previously established local float lane or reconstructs one from the same low32
bits used by the original scratch load. No semantic assumption that every
32-bit word is F32 is introduced: the verified primitive determines the use.

The helper reserves no new global machinery. Optional operand reconstruction
uses temporary slots0..1, comparisons/result use2..5, and branch labels use0..2.
The unchanged group emitter reserves nine fresh slots and retains its overflow
check. QBE labels and temporaries have distinct namespaces. The comparison is
performed before `stoui`, so NaNs, infinities, negative finite values and values
at or above2^32 never enter an out-of-domain conversion. Both signed zeros
produce0. Subnormals and fractions in[0,1) truncate to0.

## Controls and evidence gate

`primitives-controls02.bend` exports `p126lc_controls`: nine pure admission,
refusal, fact-invalidation and exact-emission checks. These invented analysis
nodes are never executed as native runtime inputs.

`../typed/controls/cases-v02.json` contains the unchanged mixed-state control
and an extended ordinary `float-boundaries02.bend`. Its49 exact output lines
retain the original21 boundaries, add25 direct bit-pattern conversions, and add
three multiplication-to-conversion witnesses. Included are signed zero and
subnormal values, negative values, fractions, adjacent values around2^31 and
2^32, both infinities, and positive/negative quiet/signaling NaNs. Expected
conversions come from IEEE bit decomposition with integer/rational arithmetic
in `prepare-v02.py`; this script does not invoke the compiler or generated code.
The three arithmetic products are exactly representable in binary32.

Parent must still check the composed API, run the finite controls and complete
ordinary outputs, inspect actual pixel admission/transport, then compare paired
runtime and compiler cost. No frame reduction or speed improvement is claimed
before those checks. Adding58 does not imply all remaining pixel scratch uses
are removable; a separate nonadmitted use could still force the original path.
