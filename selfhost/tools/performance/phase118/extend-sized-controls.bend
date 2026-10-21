# Finite projection controls only; no malformed runtime operation is executed.

def p118xsc_call(count: U32) -> N111Stmt:
  N111Call{"node",N111U64{},"p118_rt_extend",[p111_state(),p111_word(N111Const{42,0}),
    N111Arg{N111U32{},N111CtorId{"Con"}},p111_scratch(),p111_u32(count)]}

@unsafe
def p118xsc_shape(stmt: N111Stmt, expected: String, arity: U32) -> Bool:
  match stmt:
    case N111Call{name,N111U64{},symbol,+args}:
      String.eq(name,"node") && String.eq(symbol,expected) && U32.is_eq(nt_count(N111Arg,args),arity) &&
        U32.is_eq(p111v_literal(p111v_arg(args,1)),42)
    case _: False{}

@unsafe
def p118xs_controls() -> List<&2,String>:
  [p113ft_row("extend-sized-one",p118xsc_shape(p118q_sized(p118xsc_call(1)),"p118_rt_extend1",4)),
   p113ft_row("extend-sized-three",p118xsc_shape(p118q_sized(p118xsc_call(3)),"p118_rt_extend3",4)),
   p113ft_row("extend-sized-seven",p118xsc_shape(p118q_sized(p118xsc_call(7)),"p118_rt_extend7",4)),
   p113ft_row("extend-sized-zero-fallback",p118xsc_shape(p118q_sized(p118xsc_call(0)),"p118_rt_extend",5)),
   p113ft_row("extend-sized-eight-fallback",p118xsc_shape(p118q_sized(p118xsc_call(8)),"p118_rt_extend",5))]
