@unsafe
def x187_encode(inst: X187Instruction, +offset: U32) -> X187Encoded:
  match inst:
    case X187Instruction{+op,+operands}:
      nt_choose(X187Encoded,U32.is_le(offset,4294967280),
        u => nt_choose(X187Encoded,String.eq(op,"sqrtss"),
          v => x187_e_selected(X187Op{7,128,81,0,243},operands,offset),v =>
        nt_choose(X187Encoded,String.eq(op,"cvttss2siq"),
          v => x192_float_cvtt_operands(operands,offset),
          v => x187_e_selected(x187_e_spec(op),operands,offset))),u => x187_e_error())
