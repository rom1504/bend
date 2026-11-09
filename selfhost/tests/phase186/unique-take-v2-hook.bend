# Experimental rendering selection only. Production keeps register transport.
@unsafe
def p186ch_emitted(+stmt: N111Stmt, +ids: N111Ids, +code: P111QCode, expansion: P114TExpansion) -> P111QCode:
  match expansion:
    case P114TExpansion{body,changed}:
      nt_choose(P111QCode,changed,u => p114t_words(body,ids,code),u => p186uv_stmt(stmt,ids,code))
