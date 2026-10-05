# Typed array effects checkpoint

The compiler source now has a shared canonical U32/F32 array effect contract in
`selfhost/src/back/js/array-effects.bend`. It proves the native definition's erased
kind, exact live arity, element-consistent arguments and result before emitting
new/get/set/swap/size. The existing local region and raw-array consumers can use
the same proof. `array-view.bend` additionally admits the existing canonical F32
primitive catalog and F32.to_u32 through the complete closed-graph audit.

The raw and handle printers share the operation selection. Existing U32
new/get/set output spelling is preserved. Swap retains two ordered index
conversions and length reads; size returns the original handle/backing value.
No store rounding, host cache, public layout change, or runtime edit was added.
Source native calls are normalized before private emission, including the live
F32.to_u32 operand, which must not be mistaken for an erased array element.

Independent static review passed the typed source slice, conditional on replacing
the root-owned local/region/emitter delegates consistently. Local checks covered
balanced Bend delimiters and controller JavaScript syntax. No compiler or target
program was executed by this author. Execution, actual activation, speed and
promotion remain pending the root's guarded queue.

The additive controls are under
`selfhost/tools/performance/phase48/controls/array-effects-*`. They bind checked
emissions to the exact source/catalog/compiler receipts, compare independent
F32/U32 recurrence oracles, distinguish NaN and signed zero, compare host-effect
and error traces, verify public handle identity with changing backing getters,
and separately instrument guarded raw entries. Prior Phase47 controls remain
unchanged, including unused aliased F32 signature checks.

Evening remains a distinct coverage question. Its nullary `fpart` constructs a
literal ANode/ALeaf tree before two swaps. The raw proof requires fresh Array.new
and scalar positive-arity entry, so widening element typing alone does not admit
that graph. Its main also includes Map, Set and string parsing/showing. The
source diagnosis is explicit in the [design](../../design/phase48/typed-array-effects.md);
this checkpoint makes no Evening performance claim. A later literal producer
or handle-preserving adapter must preserve lazy backing realization and repeated
nullary demand instead of silently treating constructors as raw allocation.
