# Typed private emission: independent source review

No concrete semantic defect was found in the reviewed emitter and sqrt overlay
under the existing checked-request, original direct-verifier and generated-name
premises. This is a source review, not a compiler/native qualification or timing
result. No compiler, target or additional agent was run for this review.

Reviewed files and SHA256:

| File | SHA256 |
| --- | --- |
| `phase126/typed/emit.bend` | `f4f0e2c95086d45e34e0e20bf52695c1619b38df79db5e86720cd65156adc546` |
| `phase126/typed/sqrt.bend` | `6f704b92542b45e87f74c073177e710686d5ee0e5493bc682225d6c66a328b9b` |
| `phase126/typed/analysis.bend` | `f534486b3a9ab7945efcb9e12164410bd4d490e34c3a135c097b51b821a1692f` |
| `build/phase125/runtime-verified01/runtime.c` | `4822c54600663e1bf1b2cc65766d95f1f0956ae72b24eaa63d9020ead5631de5` |

Tool paths above are relative to `selfhost/tools/performance/`; the runtime path
is relative to `selfhost/`. Earlier `typed/v01/emit.bend` is preserved. The current
emitter's changes from that snapshot are affine annotations, legal simultaneous
match ordering, and extraction of the unplanned fallback into a helper; they do
not change the emission behavior inspected here.

One concrete composition issue was reported early: the initial analysis and
emitter both defined five helpers with incompatible signatures. The current
analysis uses `p126a_` for these internal helpers; the reviewed files now have no
overlapping declaration names. Explicit module override permission would not
have been a sound repair for that issue.

## Representation and control flow

`p126t_snapshot` reads every old backedge argument into `%p126_next_INDEX` before
`p126t_moves` changes any word or float formal. Typed and untyped destinations
use their fixed formal types at every backedge. The jump reaches the same
`@p113_loop`; `p126t_words` reconstructs zero-extended word views inside the loop
before the original body. This handles swaps, repeated arguments, mixed owning
words and depth without introducing native recursion. No ownership operation
is removed by the backedge rewrite.

The reconstructed word discards high32 bits, so typed formal admission is
material. The analysis does not use `N_W32` as an F32 certificate: it traces all
copy/backedge destinations, both branch arms and every overwrite, refusing any
full-word observation. Ordinary calls, returns, memory use, conditions and
integer operations are such observations. Only exact audited primitive groups
and earlier admitted typed callee parameters ignore the high word. The visit
budget refuses on exhaustion. This is an observational low32 guarantee, not a
claim that every admitted carrier originated as a source F32. In particular,
U32-to-F32 operation23 still interprets the preserved low32 bits as an unsigned
integer, using the original conversion emitter.

Lane facts point to immutable generated scalar temporaries. A U64 local copy
looks up its source fact before replacing its destination fact; reassigning the
source later does not invalidate an alias's old scalar temporary. Each other
definition kills its destination fact. Calls kill all returned destinations;
preserving facts for other caller locals is sound because admitted callees
cannot assign those locals. Memory stores do not alter register-value facts.
Nested raw statements not explicitly classified clear all facts. Both structured
branch arms start with the incoming facts; neither arm's new facts reach the
other arm or the merge. Merge facts are empty. Backedge emission is terminal,
and the loop head starts from formal facts rather than prior-iteration facts.

## ABI, names and fallback

Original integer private symbols remain as adapters. They convert selected
arguments by a low32 bitcast and call the new typed symbol; scalar and product
result conventions remain unchanged. Direct calls use the same admitted target
catalogue. Argument conversion prefixes only define fresh temporaries; result
destinations change after the call, and multi-result loads retain the original
caller-local result buffer. The original verifier supplies exact arity and
distinct result-destination checks.

The new local namespaces (`%p126_lane_`, `%p126_bits_`, `%p126_next_`) are distinct
from original `%v_` locals, `%t_` temporaries and existing emitter auxiliaries.
`nt_fid` encodes each character numerically with separators, preserving identity.
Shared site numbering reserves two slots per argument conversion, nine per
primitive group and three per structured branch, threading the updated counter
through both arms and subsequent code. Repeated backedge snapshot names are
intentional mutable temporaries with fixed types. New global symbols rely on the
authenticated source-function naming factory; this review does not authorize
arbitrary forged reflected IR or arbitrary foreign symbol collisions.

Array operations are unchanged: analyzed typed functions require
`p113a_count_body == 0`; unplanned bodies with array operations delegate to the
original `p113ah_function`. Functions without an admitted isolated primitive
buffer also keep that fallback. Existing scalar operand buffer auditing requires
the buffer to be private and unobserved outside complete recognized groups, so
eliminating the argument stores does not leave a later observable stale load.
The new local renderer omits the old two-statement width-pair optimization but
still emits both original operations through `p113w_one`; this is a possible
performance difference, not a semantic defect.

## Sqrt correspondence and remaining qualification

Runtime lines622–630 reinterpret exactly the low32 input bits and return a
zero-extended binary32 word. Runtime lines4156–4158 compute
`(f32)sqrt(f32_unbox(args[0]))`: the C `sqrt` prototype takes and returns double.
The overlay emits `exts`, a double-argument/double-result call to the same
`sqrt`, `truncd`, then a bitcast and zero extension. It does not substitute
`sqrtf`, reassociate arithmetic or keep an F32 arithmetic result in double.
The cached result is the rounded single temporary at site+4, agreeing with the
still-emitted word result. Comparison results kill the destination's float fact.
The exact count1/op36 pattern and unchanged original verifier retain primitive
arity admission. Unsupported primitives retain their original runtime calls.

The ordinary boundary/state sources independently cover signed zero, NaN bit
transport, subnormals, exact rounding, unfused arithmetic, mixed record ownership
and parallel rotations. Their complete outputs alone do not prove typed routes
were used: qualification should additionally observe typed formals, admitted
backedges/calls and the exact double sqrt sequence in the emitted product. Add a
focused ordinary sqrt observation if none of the selected programs exercises
that route. This review makes no new execution or coverage claim.
