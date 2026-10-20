# Fields are independent owning Terms, not borrowed payload views. Unknown
# representations are exactly one boxed Term. The shape is mature NQShape.
type P113PValueCode is Data:
  P113PValueCode{+body: List<&2,N111Stmt>, +values: List<&2,N111Value>, +error: String}

type P113PArguments is Data:
  P113PArguments{+valid: Bool, +values: List<&2,N111Value>}

type P113PTarget is Data:
  P113PTarget{+destinations: List<&2,String>, +shape: KTerm, +tail: Bool, +owner: String, +signatures: List<&2,KDef>}
