# Additive private plan over the original, independently verified N111 graph.
# No owning/runtime operation is replaced. Again replaces only one exact
# terminal self-transfer after its complete scratch argument stores.
type P112TailStmt is Data:
  P112TailScalar{+stmt: N111Stmt}
  P112TailIf{+condition: N111Value, +yes: List<&2,P112TailStmt>, +no: List<&2,P112TailStmt>}
  P112TailAgain{}

type P112TailPrelude is Data:
  P112TailPrelude{+valid: Bool, +params: List<&2,String>, +prefix: List<&2,N111Stmt>, +body: List<&2,N111Stmt>}

type P112TailBody is Data:
  P112TailBody{+valid: Bool, +loops: U32, +body: List<&2,P112TailStmt>}

type P112TailPlan is Data:
  P112TailPlan{+valid: Bool, +loops: U32, +params: List<&2,String>, +prefix: List<&2,N111Stmt>, +body: List<&2,P112TailStmt>}
