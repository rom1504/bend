# Allocation-only counterpart of the bounded count specialization experiment.
# Compose after sized-calls.bend; u32-divmod's emission hook still delegates here.
# The original five-argument structured call is verified before this projection.

@unsafe
def p118xs_original(stmt: N111Stmt) -> N111Stmt:
  match stmt:
    case N111Call{name,typ,+symbol,+args}:
      +count = p111v_literal(p111v_arg(args,3))
      nt_choose(N111Stmt,(String.eq(symbol,"p111_rt_ctor") || String.eq(symbol,"p111_rt_take")) &&
        U32.is_ge(count,1) && U32.is_le(count,4),
        u => N111Call{name,typ,"p118_" ++ symbol ++ U32.show(count),args},u => stmt)
    case _: stmt

@unsafe
def p118xs_prefix(args: List<&2,N111Arg>) -> List<&2,N111Arg>:
  match args:
    case Con{a,Con{b,Con{c,Con{d,Con{count,Nil{}}}}}}: [a,b,c,d]
    case _: []

@unsafe
def p118q_sized(+stmt: N111Stmt) -> N111Stmt:
  match stmt:
    case N111Call{+name,N111U64{},+symbol,+args}:
      +count = p111v_literal(p111v_arg(args,4))
      nt_choose(N111Stmt,String.eq(symbol,"p118_rt_extend") &&
        U32.is_eq(nt_count(N111Arg,args),5) && U32.is_ge(count,1) && U32.is_le(count,7),
        u => N111Call{name,N111U64{},"p118_rt_extend" ++ U32.show(count),p118xs_prefix(args)},
        u => p118xs_original(stmt))
    case _: p118xs_original(stmt)
