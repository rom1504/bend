# Select generic Take2 and adjacent reconstruction with verified continuation.

@unsafe
def nx110rt_ops(+ops: List<&2,NxoOp>, +view: String, +tag_word: String) -> List<&2,NxStmt>:
  nx110rtg_ops(ops,view,tag_word)

def nx110rt_imports() -> List<&2,NxImport>:
  nx110rtg_imports()
