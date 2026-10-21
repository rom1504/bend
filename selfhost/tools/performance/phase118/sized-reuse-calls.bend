# Emission-only exact projection of verified runtime calls. Counts become part
# of the symbol; original structured signatures/contracts remain unchanged.
# Compose after sized-calls.bend and trmc-reuse.bend.

@unsafe
def p118qs_original(stmt: N111Stmt) -> N111Stmt:
  match stmt:
    case N111Call{name,typ,+symbol,+args}:
      +count = p111v_literal(p111v_arg(args,3))
      nt_choose(N111Stmt,(String.eq(symbol,"p111_rt_ctor") || String.eq(symbol,"p111_rt_take")) &&
        U32.is_ge(count,1) && U32.is_le(count,4),
        u => N111Call{name,typ,"p118_" ++ symbol ++ U32.show(count),args},u => stmt)
    case _: stmt

@unsafe
def p118qs_without(args: List<&2,N111Arg>, +index: U32) -> List<&2,N111Arg>:
  match args:
    case Nil{}: []
    case Con{head,+rest}:
      nt_choose(List<&2,N111Arg>,U32.is_eq(index,0),u => rest,
        u => Con{head,p118qs_without(rest,U32.sub(index,1))})

@unsafe
def p118q_sized(+stmt: N111Stmt) -> N111Stmt:
  match stmt:
    case N111Call{+name,N111U64{},+symbol,+args}:
      +take_count = p111v_literal(p111v_arg(args,3))
      +prefix_count = p111v_literal(p111v_arg(args,4))
      nt_choose(N111Stmt,String.eq(symbol,"p118_rt_reuse_take") && U32.is_eq(nt_count(N111Arg,args),5) &&
        U32.is_ge(take_count,1) && U32.is_le(take_count,4),
        u => N111Call{name,N111U64{},"p118_rt_reuse_take" ++ U32.show(take_count),p118qs_without(args,3)},u =>
      nt_choose(N111Stmt,String.eq(symbol,"p118_rt_reuse_extend") && U32.is_eq(nt_count(N111Arg,args),7) &&
        U32.is_ge(prefix_count,1) && U32.is_le(prefix_count,7),
        u => N111Call{name,N111U64{},"p118_rt_reuse_extend" ++ U32.show(prefix_count),p118qs_without(args,4)},
        u => p118qs_original(stmt)))
    case _: p118qs_original(stmt)
