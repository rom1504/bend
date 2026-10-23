# Next independent projection: Nat.divmod product, if closure earns its cost

**Status: design only.** No runtime/helper/import/shape change is implemented.
First establish actual routing admission and runtime benefit from source26.

Current verified runtime opcode70 computes the full-width unsigned pair
`b == 0 ? (0,a) : (a/b,a%b)` and constructs an owning Tuple. Actual Map.bit
stores `(pos,33)` to scratch and calls that opcode; Map.bit.at consumes the
Tuple. A direct dependency closure can remove scheduling without necessarily
removing this product allocation. Upstream's corresponding path keeps quotient
and remainder as scalar words and eliminates the shell entirely.

The smallest general lowering would preserve existing product machinery:

1. Add a **QBE-local** shape query used by `p113pl_let`: exact `NOp nat_divmod`
   with two operands has existing `NQShape Tuple2`. Delegate every other case
   to the current `nq_value_shape`/NPCall logic. Do not broaden shared
   `nq_pair_primitive`: the mature C dispatcher treats that predicate as an
   array-operation selector and its final branch performs array_swap.
2. Extend only `p113p_primitive`'s exact wanted-Tuple2 case for opcode70 and two
   evaluated inputs. Produce a16-byte aligned local output, a call with full
   U64 operands, then two U64 loads. Keep all opaque/escaping results on the
   original boxed primitive path. Existing `p113p_bindable` must still prove
   the one-use substitution; retain original evaluation order and fresh names.
3. An additive helper can use
   `p126_rt_nat_divmod(state, uint64_t a, uint64_t b, uint64_t out[2]) -> uint64_t`.
   It writes exact quotient/remainder and returns an ignored status word.
   There is no input scratch buffer, no constructor ID, no Term allocation,
   and no new binary operator in the generic IR. State is retained only for
   the existing import convention. Inputs must stay64-bit: this is Nat, not
   U32. Zero divisor is valid and must return `(0,a)` exactly.
4. The explicit additive import rule requires result U64, argument kinds
   `[Ptr,U64,U64,Ptr]`, exact state argument, nonstate local output, and verified
   capacity through offset8. Existing `p111v_args`, `p111v_memory` and direct
   runtime-pointer checks supply those structural obligations. Keep the generic
   verifier unchanged; document the new trusted helper semantics and derived
   lowering scope rather than claiming the old verifier already knows it.

The private ABI remains the existing multiresult convention. No host C
expression strings, new ownership protocol, quotient/remainder product types,
signed arithmetic, or generic division opcode are needed. If a whole-source
candidate cannot verify, retain the original path rather than forcing admission.

The cheapest falsifiers are exact ordinary Nat.divmod results for divisor0/1/2/
3/33 and high Nat boundaries, including retained product results and a flat
one-use consumer. Only the flat consumer should lose allocation. Then inspect
actual Map.bit routing QBE for disappearance of opcode70's boxed result and
the matching take; count runtime helper allocations separately in a diagnostic
build if needed. Measure source preparation/emission cost as well as runtime.
If late closure still dominates preparation, placement/reuse is an enabling
step; adding another optimization should not conceal that cost.
