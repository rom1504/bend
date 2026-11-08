# Experimental AMD64 SysV machine selection. The checked native operations
# remain the semantic input; this per-function frame is machine placement only.
# slots: X181Stack da=positive rbp displacement, X181Buffer da=end displacement,
# or X181Register da=register number (0=state/r12,1=rbx,2=r13,3=r14,4=r15).
# bytes is the last reserved rbp displacement; calls is maximum outgoing bytes.
type X181Frame is Data:
  X181Frame{+slots: KDef, +bytes: U32, +calls: U32, +params: List<&2,String>, +symbol: String}

type X181Code is Data:
  X181Code{+chunks: List<&2,String>, +next: U32, +terminal: Bool, +error: String}

type X181Output is Data:
  X181Output{+chunks: List<&2,String>, +error: String}

# Shared emission interfaces. Forward declarations are contracts, not proofs.
law x181_load:
  for +value: N111Value
  for +ids: N111Ids
  for +frame: X181Frame
  for +reg: String
  String
law x181_store:
  for +name: String
  for +frame: X181Frame
  for +reg: String
  String
law x181_scalar:
  for +stmt: N111Stmt
  for +ids: N111Ids
  for +frame: X181Frame
  for +code: X181Code
  X181Code
law x181_stmts:
  for +body: List<&2,P113DStmt>
  for +ids: N111Ids
  for +frame: X181Frame
  for +code: X181Code
  X181Code
law x181_direct:
  for +function: P113DFunction
  for +ids: N111Ids
  X181Output
law x181_segment:
  for +segment: N111Segment
  for +ids: N111Ids
  X181Output
law x181_frame:
  for +symbol: String
  for +params: List<&2,String>
  for +body: List<&2,P113DStmt>
  X181Frame
law x181_reg:
  for +n: U32
  String
law x181_argreg:
  for +n: U32
  String
law x181_add:
  for +text: String
  for +code: X181Code
  X181Code
law x181_error:
  for +text: String
  for +code: X181Code
  X181Code
law x181_return:
  for +text: String
  for +code: X181Code
  X181Code
law x181_epilogue:
  String

law x181_call_text:
  for +symbol: String
  for +args: List<&2,N111Arg>
  for +ids: N111Ids
  for +frame: X181Frame
  String
