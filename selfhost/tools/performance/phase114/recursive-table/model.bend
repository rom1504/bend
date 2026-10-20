# Internal plans are derived from verified original IR, never supplied as proof.
type P114HCase is Data:
  P114HCase{+name: String, +captures: List<&2,String>, +result: String,
    +pop: String, +body: List<&2,P114RStmt>}

type P114HPlan is Data:
  P114HPlan{+valid: Bool, +params: List<&2,String>, +body: List<&2,P114RStmt>, +cases: List<&2,P114HCase>}

type P114HClosed is Data:
  P114HClosed{+valid: Bool, +cases: List<&2,P114HCase>}

type P114HEntry is Data:
  P114HEntry{+name: String, +continuations: List<&2,String>}

type P114HInspection is Data:
  P114HInspection{+entries: List<&2,P114HEntry>, +error: String}
