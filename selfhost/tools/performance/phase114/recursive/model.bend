# Exact local descent/unwind plan over the original verified N111 graph.
# First slice retains runtime frame storage and constructor operations. It
# removes only recursive register-bank transfer and global return dispatch.
type P114RStmt is Data:
  P114RScalar{+stmt: N111Stmt}
  P114RIf{+condition: N111Value, +yes: List<&2,P114RStmt>, +no: List<&2,P114RStmt>}
  P114RDescend{+frame: List<&2,N111Stmt>, +arguments: List<&2,N111Stmt>}
  P114RAgain{+arguments: List<&2,N111Stmt>}
  P114RResult{+value: N111Value}
  P114RFailure{+body: List<&2,N111Stmt>}

type P114RBody is Data:
  P114RBody{+valid: Bool, +frames: List<&2,String>, +body: List<&2,P114RStmt>}

type P114RPlan is Data:
  P114RPlan{+valid: Bool, +params: List<&2,String>, +body: List<&2,P114RStmt>,
    +continuation: String, +head: String, +result: String, +unwind: List<&2,N111Stmt>}

type P114RInspection is Data:
  P114RInspection{+entries: List<&2,String>, +error: String}
