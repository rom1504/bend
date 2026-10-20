@unsafe
def p113bq_scalar_original(+condition: N111Value, +yes: List<&2,N111Stmt>, +no: List<&2,N111Stmt>, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match code:
    case P111QCode{chunks,n,terminal,error}:
      p111q_if_yes(n,no,ids,p111q_stmts(yes,ids,
        P111QCode{Con{p111q_label(n) ++ "\n",Con{"jnz " ++ p111q_value(condition,ids) ++ ", " ++ p111q_label(n) ++ ", " ++ p111q_label(U32.inc(n)) ++ "\n",chunks}},U32.add(n,3),False{},error}))


@unsafe
def p113bq_direct_original(+condition: N111Value, +yes: List<&2,P113DStmt>, +no: List<&2,P113DStmt>, +params: List<&2,NC_Binding>, +ids: N111Ids, code: P111QCode) -> P111QCode:
  match code:
    case P111QCode{chunks,n,terminal,error}:
      p113e_if_yes(n,no,params,ids,p113e_stmts(yes,params,ids,
        P111QCode{Con{p111q_label(n) ++ "\n",Con{"jnz " ++ p111q_value(condition,ids) ++ ", " ++ p111q_label(n) ++ ", " ++ p111q_label(U32.inc(n)) ++ "\n",chunks}},U32.add(n,3),False{},error}))

