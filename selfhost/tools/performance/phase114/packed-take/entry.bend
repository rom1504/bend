@unsafe
def p111q_stmt(stmt: N111Stmt, ids: N111Ids, code: P111QCode) -> P111QCode:
  p114pk_stmt(stmt,ids,code)

@unsafe
def p113a_verify(+program: P113AProgram) -> String:
  p114pk_verify_done(program,p114pk_original_verify(program))
