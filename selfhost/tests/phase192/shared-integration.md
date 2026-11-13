Shared address experiment integration
====================================

The new source is `selfhost/src/back/x86/shared-addresses.bend`. It requires
the existing Phase191 address selection module. No pre-existing production
file was edited by its author; root owns integration and guarded target jobs.

1. Include the module in the x86 compiler source profile.
2. Replace the expression in `x191_placement(body,facts)` with
   `x192_shared_placement(x192_shared_pick(body,facts),body,facts)`.
3. In `x190_step`, include `x192_shared_address_enabled()` in the selector
   enabled condition and replace its selected branch with
   `x192_shared_step(x192_shared_pick(body,facts),body,facts,ids,frame,code)`.
4. Include the new flag in the initial facts gate and protected-name gate of
   `x190_branch_facts_when`, and in `x186_f_ordinary`'s `x191_ordinary` gate.
   This is necessary when the two older selection flags are disabled: selected
   emission must never run with an allocator that sees the old address uses.
5. Keep `x191_ordinary_facts`' original-body frame construction and its selected
   placement input to `x190_allocate_frame`. The selected placement goes through
   the joint allocator and every legacy refusal path, so base/index liveness is
   preserved even when a function exceeds the bounded joint allocator's limits.

The matcher scans at most seven original rows after one U64 multiply/shift.
It counts only rewritten uses of the eliminated scale and offsets, requiring
exact equality to whole-function reads and one unprotected definition each.
Every memory operation retains its position, and writes to a delayed address
input refuse selection. Offset names may be shared, and distinct bases may use
the same scale. An adjacent, globally single-use loaded word may use Phase191's
existing width-exact memory ALU rule. No source or function name is recognized.

Append `shared-address-controls.bend` to a checked API fixture and export
`p192sa_controls`; all 23 results must end in `=1`. Run with the new flag both
on/off and with the prior two flags independently off. The compiler-data rows
include mutation, width, setup/parameter, extra-use, control/effect, window-bound
and memory-order refusals. They are data tests, not all source-verifier-valid
programs (some deliberately append extra terminals to test global facts).

`shared-array-transfer.bend` is an unrelated array cipher with repeated masked
indices, multiply/xor updates and a wrapped U32 index. Its standalone C oracle
expects 8318258; Python unsigned-word evaluation independently gives that value.
Neither fixture nor compiler has been executed by this agent. Root should run
the source checks, C/Bend output agreement, forced-register/stack emitter cases,
and both joint/legacy allocator cells before any runtime claim. The first
structural falsifier is the actual optimized fold IR: its U64 scale/address
users must fit this eight-row certificate and emitted multiplication must vanish.
