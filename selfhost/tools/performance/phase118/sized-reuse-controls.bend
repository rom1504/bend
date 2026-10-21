# Pure finite emission projections. No runtime failure inputs.

def p118qsc_take(count: U32) -> N111Stmt:
  N111Call{"value",N111U64{},"p118_rt_reuse_take",[p111_state(),p111_word(N111Const{10,0}),p111_scratch(),p111_u32(count),p111_word(N111Const{42,0})]}

def p118qsc_extend(count: U32) -> N111Stmt:
  N111Call{"node",N111U64{},"p118_rt_reuse_extend",[p111_state(),p111_word(N111Const{0,0}),N111Arg{N111U32{},N111CtorId{"Con"}},
    p111_scratch(),p111_u32(count),p111_word(N111Const{42,0}),p118r_out()]}

@unsafe
def p118qsc_call(stmt: N111Stmt, symbol: String, arity: U32, credit_at: U32) -> Bool:
  match stmt:
    case N111Call{name,N111U64{},actual,+args}:
      String.eq(actual,symbol) && U32.is_eq(nt_count(N111Arg,args),arity) &&
        U32.is_eq(p111v_literal(p111v_arg(args,credit_at)),42)
    case _: False{}

@unsafe
def p118qs_controls() -> List<&2,String>:
  [p113ft_row("reuse-sized-take-two",p118qsc_call(p118q_sized(p118qsc_take(2)),"p118_rt_reuse_take2",4,3)),
   p113ft_row("reuse-sized-take-four",p118qsc_call(p118q_sized(p118qsc_take(4)),"p118_rt_reuse_take4",4,3)),
   p113ft_row("reuse-sized-take-five-fallback",p118qsc_call(p118q_sized(p118qsc_take(5)),"p118_rt_reuse_take",5,4)),
   p113ft_row("reuse-sized-extend-one",p118qsc_call(p118q_sized(p118qsc_extend(1)),"p118_rt_reuse_extend1",6,4)),
   p113ft_row("reuse-sized-extend-seven",p118qsc_call(p118q_sized(p118qsc_extend(7)),"p118_rt_reuse_extend7",6,4)),
   p113ft_row("reuse-sized-extend-eight-fallback",p118qsc_call(p118q_sized(p118qsc_extend(8)),"p118_rt_reuse_extend",7,5))]
