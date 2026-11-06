# Additional typed dispatcher hooks. Use together with borrow-prelude.bend.
law p173b_i_stmts:
  for +body: List<&2,P113DStmt>
  for +ctx: P126ICtx
  for +facts: List<&2,P114FLFact>
  for +code: P111QCode
  P111QCode

law p173b_l_stmts:
  for +body: List<&2,P113DStmt>
  for +ctx: P126LCtx
  for +facts: List<&2,P114FLFact>
  for +code: P111QCode
  P111QCode
