# Post-verification ABI projection. Original ctor/take calls remain in the
# structured program and pass the unchanged original verifier before emission.
@unsafe
def p125v_previous_sized(stmt: N111Stmt) -> N111Stmt:
  match stmt:
    case N111Call{name,typ,+symbol,+args}:
      +count = p111v_literal(p111v_arg(args,3))
      nt_choose(N111Stmt,(String.eq(symbol,"p111_rt_ctor") || String.eq(symbol,"p111_rt_take")) &&
        U32.is_ge(count,1) && U32.is_le(count,4),
        u => N111Call{name,typ,"p118_" ++ symbol ++ U32.show(count),args},u => stmt)
    case _: stmt

@unsafe
def p125v_shape(+state: String, +buffer: String, +count: U32) -> Bool:
  String.eq(state,"state") && Bool.not(String.eq(buffer,"state")) && U32.is_ge(count,1) && U32.is_le(count,4)

@unsafe
def p118xs_original(+stmt: N111Stmt) -> N111Stmt:
  match stmt:
    case N111Call{+dest,N111U64{},+symbol,
      Con{N111Arg{N111Ptr{},N111Local{+state}},
      Con{N111Arg{N111U32{},N111CtorId{+cid}},
      Con{N111Arg{N111Ptr{},N111Local{+buffer}},
      Con{N111Arg{N111U32{},N111Const{+count,0}},Nil{}}}}}}:
      nt_choose(N111Stmt,String.eq(symbol,"p111_rt_ctor") && p125v_shape(state,buffer,count),
        u => N111Call{dest,N111U64{},"p125_rt_ctor" ++ U32.show(count),[
          p111_state(),N111Arg{N111U32{},N111CtorId{cid}},N111Arg{N111Ptr{},N111Local{buffer}}]},
        u => p125v_previous_sized(stmt))
    case N111Call{+dest,N111U64{},+symbol,
      Con{N111Arg{N111Ptr{},N111Local{+state}},
      Con{N111Arg{N111U64{},+term},
      Con{N111Arg{N111Ptr{},N111Local{+buffer}},
      Con{N111Arg{N111U32{},N111Const{+count,0}},Nil{}}}}}}:
      nt_choose(N111Stmt,String.eq(symbol,"p111_rt_take") && p125v_shape(state,buffer,count),
        u => N111Call{dest,N111U64{},"p125_rt_take" ++ U32.show(count),[
          p111_state(),p111_word(term),N111Arg{N111Ptr{},N111Local{buffer}}]},
        u => p125v_previous_sized(stmt))
    case _: p125v_previous_sized(stmt)
