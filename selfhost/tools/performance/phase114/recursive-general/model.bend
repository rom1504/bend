# Optional singleton local continuation region. A reflected plan is not a
# certificate; production derives it from the checked original and ready set.
type P114GFrame is Data:
  P114GFrame{+name: String, +count: U32}

type P114GBody is Data:
  P114GBody{+valid: Bool, +frames: List<&2,P114GFrame>, +body: List<&2,P114RStmt>}

type P114GPlan is Data:
  P114GPlan{+valid: Bool, +params: List<&2,String>, +body: List<&2,P114RStmt>,
    +continuation: String, +captures: List<&2,String>, +result: String,
    +pop: String, +resume: List<&2,P112WorkerStmt>}
