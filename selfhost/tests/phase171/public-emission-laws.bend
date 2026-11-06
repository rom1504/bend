# The public override precedes its private emitter in the canonical inventory.
law p171pe_stmts:
  for +body: List<&2,N111Stmt>
  for +owner: String
  for +ready: KDef
  for +ids: N111Ids
  for +code: P111QCode
  P111QCode

law p171pe_tail:
  for +body: List<&2,N111Stmt>
  for +left: U32
  for +target: String
  for +arity: U32
  for +ids: N111Ids
  for +code: P111QCode
  P111QCode
