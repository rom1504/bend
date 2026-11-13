type X185Physical is Data:
  X185Physical{+wide: X187Operand, +narrow: X187Operand, +byte: X187Operand}
  X185PhysicalNone{}

# Experimental AMD64 SysV machine selection. The checked native operations
# remain the semantic input; this per-function frame is machine placement only.
# slots: X181Stack da=positive rbp displacement, X181Buffer da=end displacement,
# or X181Register da=register number (0=state/r12,1=rbx,2=r13,3=r14,4=r15).
# X185Transient da=0..4 is confined to one call-free region and maps to the
# separate rdi/rsi/rdx/r8/r9 pool; parameters and call arguments never use it.
# bytes is the last reserved rbp displacement; calls is maximum outgoing bytes.
type X181Frame is Data:
  X181Frame{+slots: KDef, +bytes: U32, +calls: U32, +params: List<&2,String>, +symbol: String}

type X181Code is Data:
  X181Code{+chunks: List<&2,X188Seq>, +next: U32, +terminal: Bool, +error: String}

type X181Output is Data:
  X181Output{+chunks: List<&2,X188Seq>, +error: String}

# Shared emission interfaces. Forward declarations are contracts, not proofs.
law x181_load:
  for +value: N111Value
  for +ids: N111Ids
  for +frame: X181Frame
  for +reg: X187Operand
  X188Seq
law x181_store:
  for +name: String
  for +frame: X181Frame
  for +reg: X187Operand
  X188Seq
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
  X187Operand
law x181_argreg:
  for +n: U32
  X187Operand
law x181_add:
  for +text: X188Seq
  for +code: X181Code
  X181Code
law x181_error:
  for +text: String
  for +code: X181Code
  X181Code
law x181_return:
  for +text: X188Seq
  for +frame: X181Frame
  for +code: X181Code
  X181Code
law x181_epilogue:
  for +frame: X181Frame
  X188Seq

law x181_call_text:
  for +symbol: String
  for +args: List<&2,N111Arg>
  for +ids: N111Ids
  for +frame: X181Frame
  X188Seq

law x185_transient_reg:
  for +index: U32
  X187Operand

law x185_transient_frame:
  for +frame: X181Frame
  for +params: List<&2,String>
  for +setup: List<&2,P113DStmt>
  for +body: List<&2,P113DStmt>
  X181Frame

law x185_dead_body:
  for +setup: List<&2,P113DStmt>
  for +body: List<&2,P113DStmt>
  List<&2,P113DStmt>

law x185_physical_binary:
  for name: String
  for +typ: N111Type
  for +op: String
  for +left: N111Value
  for +right: N111Value
  for +ids: N111Ids
  for +frame: X181Frame
  X188Seq

# Typed late address-selection plans, declared before emission modules.
type X191Address is Data:
  X191Address{+base: N111Value, +index: N111Value, +scale: U32, +disp: U32}
type X191Operation is Data:
  X191Load{+name: String, +typ: N111Type, +address: X191Address}
  X191Store{+typ: N111Type, +address: X191Address, +value: N111Value}
  X191MemoryAlu{+name: String, +typ: N111Type, +op: String, +left: N111Value, +address: X191Address}
type X191Pick is Data:
  X191Pick{+rest: List<&2,P113DStmt>, +operation: X191Operation}
type X191AddressCode is Data:
  X191AddressCode{+prefix: X188Seq, +operand: X187Operand}
