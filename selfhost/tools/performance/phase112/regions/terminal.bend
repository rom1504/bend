@unsafe
def p112r_head_buffer(body: List<&2,N111Stmt>) -> String:
  match body:
    case Con{N111Store{N111U64{},N111Local{+base},+offset,+value},+rest}: base
    case Con{N111Call{+dest,N111U64{},+symbol,Con{+state,Con{+target,Con{N111Arg{N111Ptr{},N111Local{+base}},+rest}}}},+tail}: base
    case _: ""

@unsafe
def p112r_jump(body: List<&2,N111Stmt>, +owner: String, +arity: U32, +buffer: String) -> Bool:
  match body:
    case Con{N111Call{+dest,N111U64{},+symbol,Con{N111Arg{N111Ptr{},N111Local{+state}},Con{N111Arg{N111U32{},N111FuncId{+name}},Con{N111Arg{N111Ptr{},N111Local{+scratch}},Con{N111Arg{N111U32{},N111Const{+count,0}},Nil{}}}}}},Con{N111Return{N111Local{+word}},Nil{}}}:
      String.eq(symbol,"p111_rt_jump") && String.eq(dest,word) && String.eq(state,"state") && String.eq(name,owner) && String.eq(scratch,buffer) && U32.is_eq(count,arity)
    case _: False{}

@unsafe
def p112r_tail(+body: List<&2,N111Stmt>, +owner: String, +arity: U32, +index: U32, +buffer: String) -> Bool:
  nt_choose(Bool,U32.is_eq(index,arity),u => p112r_jump(body,owner,arity,buffer),u => p112r_tail_store(body,owner,arity,index,buffer))

@unsafe
def p112r_tail_store(body: List<&2,N111Stmt>, +owner: String, +arity: U32, +index: U32, +buffer: String) -> Bool:
  match body:
    case Con{N111Store{N111U64{},N111Local{+base},+offset,+value},+rest}:
      String.eq(base,buffer) && U32.is_eq(offset,U32.mul(index,8)) && p112r_tail(rest,owner,arity,U32.inc(index),buffer)
    case _: False{}

@unsafe
def p112r_result(body: List<&2,N111Stmt>, +sites: U32) -> Bool:
  match body:
    case Con{N111Store{N111U64{},N111Local{+base},0,+value},Con{N111Call{+dest,N111U64{},+symbol,Con{N111Arg{N111Ptr{},N111Local{+state}},Con{N111Arg{N111Ptr{},N111Local{+scratch}},Con{N111Arg{N111U32{},N111Const{1,0}},Nil{}}}}},Con{N111Return{N111Local{+word}},Nil{}}}}:
      p112r_buffer(base,sites) && String.eq(base,scratch) && String.eq(state,"state") && String.eq(symbol,"p111_rt_return") && String.eq(dest,word)
    case _: False{}

@unsafe
def p112r_target(body: List<&2,N111Stmt>, +sites: U32) -> String:
  match body:
    case Con{N111Store{N111U64{},N111Local{+base},+offset,+value},+rest}:
      nt_choose(String,p112r_buffer(base,sites),u => p112r_target(rest,sites),u => "")
    case Con{N111Call{+dest,N111U64{},+symbol,Con{+state,Con{N111Arg{N111U32{},N111FuncId{+name}},+rest}}},Con{N111Return{+value},Nil{}}}:
      nt_choose(String,String.eq(symbol,"p111_rt_jump"),u => name,u => "")
    case _: ""

@unsafe
def p112r_exit_stores(+count: U32, +index: U32, +last: P112WorkerStmt) -> List<&2,P112WorkerStmt>:
  nt_choose(List<&2,P112WorkerStmt>,U32.is_eq(count,index),u => [last],u =>
    Con{P112WorkerScalar{N111Store{N111U64{},N111Local{"scratch"},U32.mul(index,8),N111Local{"p112f_region_exit_" ++ U32.show(index)}}},p112r_exit_stores(count,U32.inc(index),last)})

# All operands are copied before any canonical slot is overwritten. The exact
# suffix has only pure value stores followed by its transfer, so secondary
# terminal stores can be replaced by this transport without moving owner calls.
@unsafe
def p112r_exit(body: List<&2,N111Stmt>, +count: U32, +last: P112WorkerStmt) -> List<&2,P112WorkerStmt>:
  nt_append(P112WorkerStmt,p112w_failure_nodes(p112f_snapshots(p112f_values(body,count),"p112f_region_","exit_",0)),p112r_exit_stores(count,0,last))
