@unsafe
def p112i_after_float(+stmt: N111Stmt, +ids: N111Ids, result: P112IEmission) -> P111QCode:
  match result:
    case P112IEmission{expanded,+code}:
      nt_choose(P111QCode,expanded,u => code,u => p112fp_after_accessors(stmt,ids,p112fp_expand(stmt,code)))

@unsafe
def p111q_stmt(+stmt: N111Stmt, +ids: N111Ids, code: P111QCode) -> P111QCode:
  p112i_after_float(stmt,ids,p112i_expand(stmt,ids,code))
