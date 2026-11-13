# Phase192 argument-staging mechanism and controls

At parent `aa7cfa4`, there is already a complete operation-staging elimination
pipeline. No new `operation-effects.bend` or additional pass is needed.

1. `x186_f_plan` in `float-values.bend` discharges an admitted operation's
   memory reads using exact current `X185ScratchCell` facts. Its private
   `X186FloatValues` node retains the actual operands and destination.
2. `x186_f_ready` derives read/escape footprints from those private nodes.
   A discharged operation has only local-value reads, so its argument-buffer
   address disappears from the footprint.
3. `x186_f_prune` removes globally unobserved stores and allocations using the
   existing `x186_m_dead_cell` / `x186_m_dead_buffer` predicates. The final
   placement and XMM scans consume this pruned node list.

The observed binary-operation stores survive because the later op58 call
remains `X186FloatPlain`. `x186_m_unknown_call` sees the reused buffer among
that call's arguments and blocks the **entire buffer**, including stores for
earlier already-forwarded operations. Admitting/discharging op58 eliminates
that escape. This exposes the earlier stores to the already implemented global
private-memory rule. Unary23 needs the same shared effect contract, although
its machine expansion already exists independently.

## Integration contract

The conversion agent's integration reuses `X186InlineF32` for unary23/58 and
`X186FloatValues` with the same operand in both positions. Consequently:

- Shared admission must match exact state, symbol, return/argument types,
  id/arity and enabled flags. Any mismatch preserves the original call.
- `x186_f_operation` must fetch offset0 once for unary operations; offset8
  must not be required or read. A legal eight-byte buffer is sufficient.
- `x186_m_call` must report only offset0 for an admitted, unforwarded unary
  operation. The binary footprint remains offset0 plus offset8.
- The ordinary memory emitter (`x186_float_operation`) and both private
  value emitters must dispatch unary operations explicitly. The old binary
  emitter unconditionally reads offset8 and cannot emit a unary fallback.
- The shared no-call effects permit existing transient/loop-liveness code to
  preserve caller-register homes. New machine instructions must clobber only
  the summarized r10/r11, xmm0/xmm1 and flags. Destination writes remain at
  the same inclusive read/write endpoint.
- Unary outputs must publish the complete canonical zero-extended word for
  XMM home reuse. An arbitrary 64-bit input must not be assumed canonical.
  Duplicate unary operands in placement metadata count the same read twice
  for scoring; this is a priority effect, not a second semantic memory read.

No semantic arithmetic is introduced into checked IR. The synthetic placement
`N111Bin` remains metadata only: it must never reach value optimization or
machine emission.

## Preserved conservative boundaries

Only bounded named private frame cells are eligible. Parameters, conflicting
definitions and unsupported buffers are blocked by the existing buffer scan.
Current facts die on source reassignment, overlapping writes, unknown-address
writes, unknown calls, branches and terminal edges. They are never imported
from setup or carried over a loop backedge. A failed fact lookup keeps the
original statement.

The read/escape scan covers setup and every branch. Loads retain all overlapping
four-byte cells, and address copies, pointer arithmetic, ordinary call arguments,
stored addresses, returned addresses and Again values conservatively block
whole buffers. Thus an operation can be value-forwarded while its old stores
remain necessary because another observer exists. Escape of a different buffer
does not block a genuinely independent private buffer.

## Finite controls and execution status

`staging-controls.bend` exports `p192st_controls(): List<String>` with 27 fixed
`name=1` expectations. Include this fixture in the same checked hosted source
used for the conversion controls and evaluate that function after integration.
No additional runtime or helper implementation is needed for these
compiler-data controls; they inspect the actual final private plan.

The positive composition witness is op23 -> op26 -> op58 sharing one buffer:
three value nodes, zero stores, zero allocas and zero original calls. Negative
controls cover observation, escapes, unknown calls, source mutation, partial
overlap, branches/joins, setup, nonprivate/incoming buffers, unsupported
operations, arity mismatch and destination/source aliasing.

These are finite transformation controls, not whole-program verification or
runtime evidence. Some explicit refusal inputs are compiler data outside the
ordinary source verifier's admitted subset. No compiler/target job was executed
by this audit agent. Root owns source checking, execution and machine evidence.
The existing Phase186 unary controls that expected op23 to remain a conservative
call barrier need intentional updated expectations when reused for Phase192;
historical frozen artifacts remain unchanged.

For causal attribution, compare conversion-only against conversion plus the
existing prune/XMM composition on the exact numeric loop. Confirm the old
eight binary staging stores disappear in the composed machine output, then
measure matched runtime. Static store removal alone is not a speed result.
