# Private single-Term workers over the verified original graph. The fixed
# admission passes exclude non-self cycles; self edges remain local loop edges.
type P112WorkerStmt is Data:
  P112WorkerScalar{+stmt: N111Stmt}
  P112WorkerIf{+condition: N111Value, +yes: List<&2,P112WorkerStmt>, +no: List<&2,P112WorkerStmt>}
  P112WorkerAgain{}
  P112WorkerResult{}
  P112WorkerCall{+target: String, +arity: U32}

type P112WorkerBody is Data:
  P112WorkerBody{+valid: Bool, +calls: U32, +body: List<&2,P112WorkerStmt>}

type P112WorkerPlan is Data:
  P112WorkerPlan{+valid: Bool, +calls: U32, +params: List<&2,String>, +body: List<&2,P112WorkerStmt>}
