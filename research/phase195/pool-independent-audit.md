# Independent eleven-color pool audit

Read-only compiler review of `pool/allocator-v1.bend`,
`allocator-controls-v1.bend`, `physical-hooks.bend` and
`physical-controls.bend`. No semantic blocker found. The reviewer subsequently
authored independent machine fixtures, but did not edit the allocator/hooks
or run source checking, compilation or targets. Passing source checks and
machine observations remain root-owned requirements.

Reviewed compiler-file SHA256 values:

| File | SHA256 |
| --- | --- |
| allocator-v1.bend | e226b0e47a52faa25703e5c6b02cd2e55ccde97e94e2d2eb8d5d195a0c728112 |
| allocator-controls-v1.bend | 4668b7487e50ec321ddfcce045eca69a73b59a826fb2c204b67ab84efe093ff0 |
| physical-hooks.bend | 48980628f17dca7b1bbaa840a2d5654523bd849f6326df9beae0d9bba9e99ae3 |
| physical-controls.bend | e7764d997df8a3ef620fdff0135af6eb00bb07943adf0e41c3837d1c5261035a |

## State relocation and saved R12

The inspected emitter accesses state through its frame slot: incoming copies,
scalar loads, implicit state arguments of private calls, explicit runtime calls
and heap-base loads all respect the Stack home. The fixed R12 references found
are its physical/saved-home mapping, not a separate hidden state load. Appending
an aligned word leaves existing buffers, result/tail slots and save locations
unchanged. The prologue recomputes total stack reservation from the new frame
size, and the allocator checks enough signed-displacement/call capacity for
that growth.

The save-mask traversal sees an ordinary local assigned Register0 and therefore
preserves caller R12. If color10 is unused, state and frame size remain original.
Refusal passes the original frame to the complete legacy allocator. This relies
on the canonical fresh frame and parameter ordering supplied by the pipeline:
`x195_p_state_safe` is not an independent validator of arbitrary forged frame
maps or overlapping stack slots.

## RCX clobbers, imports and calls

Both scalar and physical variable-shift paths read their operands before writing
ECX. A dying source may therefore occupy RCX. The physical destination cannot:
it receives the left operand before the count is copied into ECX. The additional
mask correctly includes the destination even when dead, and all live-out names,
using the original loop fixed point and suffix transfer functions. The setup
scan uses the body header. Constant RHS shifts use immediate instructions in
both Stack and register-destination paths; when immediate selection is disabled,
the mask conservatively treats them as RCX clobbers too.

The incoming-position restriction for RCX is3, matching the fourth SysV register
argument and sequential incoming copies. Existing five caller mappings are
unchanged, so the overridden ABI getter does not alter legacy allocation.
Real-call self edges reject caller-color values live across calls. A dying RCX
argument is legal because the widened call-slot validator requires the existing
snapshot path. R12 remains a saved color and can cross real calls.

## Again and eleven-color validation

The pool preserves the original graph's simultaneous parameter writes and
loop fixed point. Parallel transport already compares actual homes. The hook
admits RCX and ordinary R12 local destinations, while forbidding literal state
as a destination even after state moves to Stack. Canonical tail arguments
exclude state; cyclic moves retain the snapshot fallback.

The new validator checks11 groups, duplicate assignment, graph interference,
call self edges, incoming positions and the RCX mask. It uses its own11-valued
uncolored sentinel rather than the old9 sentinel. Candidate IDs and graph rows
remain32-bit. Construction and validation share legality helpers, so the
validator rejects malformed assignments but does not independently establish
that the clobber model is correct. The physical consumer review and execution
controls address that separate boundary.

The existing23 allocator and13 physical controls check useful finite cases,
including the high bit, state append/refusal, caller/saved call treatment,
incoming RCX position, bounds and save masks. They are compiler-data checks;
they do not alone observe machine state preservation.

## Independent machine handoff

`pool/machine-controls-v1.bend` derives the real fixed-point graph and shift
mask for seven workers, then asks the production validator to install deliberately
forced assignments. Sixteen exact assertions establish actual RCX/R12 homes,
Stack state, an RCX-argument snapshot, an Again-cycle refusal and unsafe-shift
assignment refusals. This tests physical transport without relying on a greedy
coloring heuristic to happen to select the new registers.

The separate C observer performs1200 observations per machine route over high
words, wraparound values and shift counts0/31/32/63/64/65 and larger values.
It checks the fourth incoming argument, state-pointer effects across a real
call, live R12 across that call, caller R12 preservation using a fixed-register
asm witness, an R12/RCX backedge cycle, dying left/right RCX shift sources,
U32 canonical results, and the two refused RCX assignments. Call arguments
include RCX directly, forcing the expanded snapshot contract. State effects
and results are computed independently in C.

The driver compares direct ELF and GNU-as routes from the same typed output;
these are two emission routes, not two independent selectors. The contract,
source/input pins and exact preparation/acquisition/gate argv are retained in
`pool/machine-plan-v1.json`. Metadata extraction, delimiter/match-order review,
exact-label agreement and parser-only V8 checking of the driver completed.
No checked-source or machine pass is claimed here.

The remaining highest-value falsifier after these finite controls is a real
automatically colored pressure loop whose new RCX/R12 homes remove executed
stack accesses, paired with a call-heavy case that exposes the added state
loads. Extra register capacity is not itself a runtime speedup or suite ceiling.
