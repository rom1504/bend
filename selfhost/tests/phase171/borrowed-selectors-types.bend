# Experimental direct-IR readers. A nonempty path denotes an immutable value
# below held entry roots. Scalar machine values have an empty path.
# These records are compiler data, never a public borrowed-result ABI.
type P171DInfo is Data:
  P171DUnknown{}
  P171DWord{+path: String}
  P171DTag{+word: N111Value, +path: String}
  P171DTest{+word: N111Value, +path: String, +ctor: String, +equal: Bool}

type P171DLocal is Data:
  P171DLocal{+name: String, +info: P171DInfo}

type P171DCase is Data:
  P171DCase{+path: String, +ctor: String}

type P171DView is Data:
  P171DView{+path: String, +ctor: String, +width: U32}

type P171DContext is Data:
  P171DContext{+functions: List<&2,P113DFunction>, +ids: N111Ids, +stack: List<&2,String>, +depth: U32}

type P171DCode is Data:
  P171DCode{+body: List<&2,P113DStmt>, +helpers: List<&2,P113DFunction>, +next: U32, +accepted: U32, +declined: U32, +rooted: Bool}

type P171DWorker is Data:
  P171DWorker{+reader: String, +code: P171DCode}

type P171DShape is Data:
  P171DShape{+roots: List<&2,U32>, +count: U32, +valid: Bool}

type P171DProposal is Data:
  P171DProposal{+owner: String, +original: P113DFunction, +reader: String, +functions: List<&2,P113DFunction>, +accepted: U32, +declined: U32, +error: String}
