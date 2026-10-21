# Exact arity specialization after the original IR verifier. All runtime checks
# and owning semantics remain in the constant-count helper. No uniqueness claim.
@unsafe
def p118q_sized(stmt: N111Stmt) -> N111Stmt:
  match stmt:
    case N111Call{name,typ,+symbol,+args}:
      +count = p111v_literal(p111v_arg(args,3))
      nt_choose(N111Stmt,(String.eq(symbol,"p111_rt_ctor") || String.eq(symbol,"p111_rt_take")) &&
        U32.is_ge(count,1) && U32.is_le(count,4),
        u => N111Call{name,typ,"p118_" ++ symbol ++ U32.show(count),args},u => stmt)
    case _: stmt

@unsafe
def p114t_stmt(stmt: N111Stmt, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match code:
    case P111QCode{chunks,next,terminal,error}:
      p114t_expanded(p114t_expand(p118q_sized(stmt),ids,next),ids,code)
