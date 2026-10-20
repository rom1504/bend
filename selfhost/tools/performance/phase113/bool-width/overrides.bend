# Exact pure diamonds only. Normalize arbitrary U32 conditions before extuw.
@unsafe
def p111q_if(+condition: N111Value, +yes: List<&2,N111Stmt>, +no: List<&2,N111Stmt>, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  +diamond = p113bq_scalar(yes,no)
  nt_choose(P111QCode,p113bq_ready(diamond,code),u => p113bq_emit(condition,diamond,ids,code),
    u => p113bq_scalar_original(condition,yes,no,ids,code))

@unsafe
def p113e_if(+condition: N111Value, +yes: List<&2,P113DStmt>, +no: List<&2,P113DStmt>, +params: List<&2,NC_Binding>, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  +diamond = p113bq_direct(yes,no)
  nt_choose(P111QCode,p113bq_ready(diamond,code),u => p113bq_emit(condition,diamond,ids,code),
    u => p113bq_direct_original(condition,yes,no,params,ids,code))
