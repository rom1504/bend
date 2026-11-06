# Three selected direct-body dispatchers. No verifier/runtime replacement.
@unsafe
def p113w_stmts(body: List<&2,P113DStmt>, +params: List<&2,NC_Binding>, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  p173b_stmts(body,params,ids,code)

@unsafe
def p126i_stmts(body: List<&2,P113DStmt>, +ctx: P126ICtx, +facts: List<&2,P114FLFact>, +code: P111QCode) -> P111QCode:
  p173b_i_stmts(body,ctx,facts,code)

@unsafe
def p126l_stmts(body: List<&2,P113DStmt>, +ctx: P126LCtx, +facts: List<&2,P114FLFact>, +code: P111QCode) -> P111QCode:
  p173b_l_stmts(body,ctx,facts,code)
