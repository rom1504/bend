# Exact shared admission for the F32 machine expansion. An admitted operation
# reads two U64 cells at buffer+0 and buffer+8, then writes one U64 local. It
# never writes/escapes memory or calls a helper. Its only machine clobbers are
# reserved r10/r11, xmm0/xmm1 and flags; transient/callee-saved homes survive.
# All consumers use this constructor rather than rediscovering the call shape.
# These effects describe already verified IR; they do not bypass its verifier.
type X186InlineOp is Data:
  X186InlineNone{}
  X186InlineF32{+destination: String, +id: U32, +buffer: String}

@unsafe
def x186_inline_op_when(enabled: Bool, stmt: N111Stmt) -> X186InlineOp:
  match stmt:
    case N111Call{name,N111U64{},symbol,
      Con{N111Arg{N111Ptr{},N111Local{state}},Con{N111Arg{N111U32{},N111Const{+id,0}},Con{N111Arg{N111Ptr{},N111Local{+buffer}},Con{N111Arg{N111U32{},N111Const{+count,0}},Nil{}}}}}}:
      nt_choose(X186InlineOp,enabled && String.eq(symbol,"p111_rt_op") && String.eq(state,"state") &&
          (nt_choose(Bool,x192_float_unary(id),
            v => x192_float_conversions_enabled() && U32.is_eq(count,1) && Bool.not(String.eq(buffer,"state")),
            v => U32.is_ge(id,26) && p112fp_supported(id,count))),
        u => X186InlineF32{name,id,buffer},u => X186InlineNone{})
    case _: X186InlineNone{}

@unsafe
def x186_inline_op(stmt: N111Stmt) -> X186InlineOp:
  x186_inline_op_when(x185_float_enabled(),stmt)
