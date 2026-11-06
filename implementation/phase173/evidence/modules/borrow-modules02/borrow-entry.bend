# Experimental exact replacement of p113w_stmts only. Apply via maintained
# source preparation; do not edit the production emitter or verifier.
@unsafe
def p113w_stmts(body: List<&2,P113DStmt>, +params: List<&2,NC_Binding>, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  p173b_stmts(body,params,ids,code)
