@unsafe
def p111q_stmt(stmt: N111Stmt, ids: N111Ids, code: P111QCode) -> P111QCode:
  p114t_stmt(stmt,ids,code)

@unsafe
def p113a_verify(+program: P113AProgram) -> String:
  p114t_verify_done(program,p114t_original_verify(program))
