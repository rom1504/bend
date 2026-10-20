# Footprints refer only to the callee's implicit scratch buffer. Explicit
# nested allocas retain their own bounds. Unknown use keeps the full 2048 bytes.
@unsafe
def p113j_is_scratch(value: N111Value) -> Bool:
  match value:
    case N111Local{name}: String.eq(name,"scratch")
    case _: False{}

@unsafe
def p113j_scratch_values(values: List<&2,N111Value>) -> Bool:
  match values:
    case Nil{}: False{}
    case Con{head,rest}: p113j_is_scratch(head) || p113j_scratch_values(rest)

@unsafe
def p113j_scratch_args(args: List<&2,N111Arg>) -> U32:
  match args:
    case Nil{}: 0
    case Con{N111Arg{typ,value},rest}: U32.add(Bool.to_u32(p113j_is_scratch(value)),p113j_scratch_args(rest))

@unsafe
def p113j_scratch_count(+args: List<&2,N111Arg>, +position: U32, +count_at: U32) -> U32:
  nt_choose(U32,U32.is_eq(p113j_scratch_args(args),1) && p113j_is_scratch(p111v_arg(args,position)),
    u => p113j_scratch_literal(p111v_arg(args,count_at)),u => 2048)

@unsafe
def p113j_scratch_literal(value: N111Value) -> U32:
  match value:
    case N111Const{+count,0}: nt_choose(U32,U32.is_le(count,256),u => U32.max(8,U32.mul(count,8)),u => 2048)
    case _: 2048

@unsafe
def p113j_scratch_call(+symbol: String, +args: List<&2,N111Arg>) -> U32:
  nt_choose(U32,U32.is_eq(p113j_scratch_args(args),0),u => 0,u =>
  nt_choose(U32,String.eq(symbol,"p111_rt_op") || String.eq(symbol,"p111_rt_ctor") ||
      String.eq(symbol,"p111_rt_take") || String.eq(symbol,"p111_rt_special_ctor") ||
      String.eq(symbol,"p113_rt_array_pair"),
    u => p113j_scratch_count(args,2,3),u =>
  nt_choose(U32,String.eq(symbol,"p111_rt_special_take"),
    u => p113j_scratch_count(args,3,4),u => 2048)))

@unsafe
def p113j_scratch_scalar(stmt: N111Stmt) -> U32:
  match stmt:
    case N111Load{name,typ,+base,+offset}:
      nt_choose(U32,p113j_is_scratch(base),u => U32.min(2048,U32.add(offset,8)),u => 0)
    case N111Store{typ,+base,+offset,+value}:
      nt_choose(U32,p113j_is_scratch(value),u => 2048,u =>
        nt_choose(U32,p113j_is_scratch(base),v => U32.min(2048,U32.add(offset,8)),v => 0))
    case N111Call{name,typ,symbol,args}: p113j_scratch_call(symbol,args)
    case N111If{condition,yes,no}:
      nt_choose(U32,p113j_is_scratch(condition),u => 2048,u => U32.max(p113j_scratch_scalars(yes),p113j_scratch_scalars(no)))
    case N111Set{name,typ,value}: nt_choose(U32,p113j_is_scratch(value),u => 2048,u => 0)
    case N111Bin{name,typ,op,left,right}: nt_choose(U32,p113j_is_scratch(left) || p113j_is_scratch(right),u => 2048,u => 0)
    case N111Offset{name,base,bytes}: nt_choose(U32,p113j_is_scratch(base) || p113j_is_scratch(bytes),u => 2048,u => 0)
    case _: 0

@unsafe
def p113j_scratch_scalars(body: List<&2,N111Stmt>) -> U32:
  match body:
    case Nil{}: 0
    case Con{head,rest}: U32.max(p113j_scratch_scalar(head),p113j_scratch_scalars(rest))

@unsafe
def p113j_scratch(body: List<&2,P113DStmt>) -> U32:
  match body:
    case Nil{}: 0
    case Con{P113DScalar{stmt},rest}: U32.max(p113j_scratch_scalar(stmt),p113j_scratch(rest))
    case Con{P113DIf{condition,yes,no},rest}:
      nt_choose(U32,p113j_is_scratch(condition),u => 2048,u => U32.max(p113j_scratch(yes),U32.max(p113j_scratch(no),p113j_scratch(rest))))
    case Con{P113DCall{destinations,target,args},rest}:
      nt_choose(U32,p113j_scratch_values(args),u => 2048,u => p113j_scratch(rest))
    case Con{P113DResult{values},rest}:
      nt_choose(U32,p113j_scratch_values(values),u => 2048,u => p113j_scratch(rest))
    case Con{P113DAgain{values},rest}:
      nt_choose(U32,p113j_scratch_values(values),u => 2048,u => p113j_scratch(rest))

@unsafe
def p113j_scratch_alloc(+body: List<&2,P113DStmt>, +prefix: String) -> List<&2,P113DStmt>:
  +bytes = p113j_scratch(body)
  nt_choose(List<&2,P113DStmt>,U32.is_eq(bytes,0),u => [],
    u => [P113DScalar{N111Alloca{p112f_name(prefix,"scratch"),U32.mul(U32.div(U32.add(bytes,7),8),8),8}}])
