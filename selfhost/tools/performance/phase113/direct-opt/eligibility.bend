@unsafe
def p113i_name(+name: String) -> Bool:
  Bool.not(String.starts_with(name,"p113i_"))

@unsafe
def p113i_value(value: N111Value) -> Bool:
  match value:
    case N111Local{name}: p113i_name(name)
    case _: True{}

@unsafe
def p113i_values(values: List<&2,N111Value>) -> Bool:
  match values:
    case Nil{}: True{}
    case Con{head,rest}: p113i_value(head) && p113i_values(rest)

@unsafe
def p113i_names(names: List<&2,String>) -> Bool:
  match names:
    case Nil{}: True{}
    case Con{head,rest}: p113i_name(head) && p113i_names(rest)

@unsafe
def p113i_args(args: List<&2,N111Arg>) -> Bool:
  match args:
    case Nil{}: True{}
    case Con{N111Arg{typ,value},rest}: p113i_value(value) && p113i_args(rest)

@unsafe
def p113i_scalar_clean(stmt: N111Stmt) -> Bool:
  match stmt:
    case N111Set{name,typ,value}: p113i_name(name) && p113i_value(value)
    case N111Bin{name,typ,op,left,right}: p113i_name(name) && p113i_value(left) && p113i_value(right)
    case N111Call{name,typ,symbol,args}: p113i_name(name) && p113i_args(args)
    case N111If{condition,yes,no}: p113i_value(condition) && p113i_scalars_clean(yes) && p113i_scalars_clean(no)
    case N111Load{name,typ,base,offset}: p113i_name(name) && p113i_value(base)
    case N111Store{typ,base,offset,value}: p113i_value(base) && p113i_value(value)
    case N111Offset{name,base,bytes}: p113i_name(name) && p113i_value(base) && p113i_value(bytes)
    case N111Alloca{name,bytes,align}: p113i_name(name)
    case _: False{}

@unsafe
def p113i_scalars_clean(body: List<&2,N111Stmt>) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{head,rest}: p113i_scalar_clean(head) && p113i_scalars_clean(rest)

@unsafe
def p113i_clean(body: List<&2,P113DStmt>) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{P113DScalar{stmt},rest}: p113i_scalar_clean(stmt) && p113i_clean(rest)
    case Con{P113DIf{condition,yes,no},rest}: p113i_value(condition) && p113i_clean(yes) && p113i_clean(no) && p113i_clean(rest)
    case Con{P113DCall{destinations,target,args},rest}: p113i_names(destinations) && p113i_values(args) && p113i_clean(rest)
    case Con{P113DResult{values},rest}: p113i_values(values) && p113i_clean(rest)
    case Con{P113DAgain{values},rest}: p113i_values(values) && p113i_clean(rest)

@unsafe
def p113i_params(params: List<&2,NC_Binding>) -> Bool:
  match params:
    case Nil{}: True{}
    case Con{NC_Binding{id,word,kind},rest}: p113i_name(word) && p113i_params(rest)

# Count nested scalar branches as real nodes. Saturation avoids wraparound and
# keeps budget arithmetic independent of malformed or very large input graphs.
@unsafe
def p113i_add(left: U32, right: U32) -> U32:
  U32.min(4096,U32.add(left,right))

@unsafe
def p113i_scalar_size(stmt: N111Stmt) -> U32:
  match stmt:
    case N111If{condition,yes,no}: p113i_add(1,p113i_add(p113i_scalars_size(yes),p113i_scalars_size(no)))
    case _: 1

@unsafe
def p113i_scalars_size(body: List<&2,N111Stmt>) -> U32:
  match body:
    case Nil{}: 0
    case Con{head,rest}: p113i_add(p113i_scalar_size(head),p113i_scalars_size(rest))

@unsafe
def p113i_size(body: List<&2,P113DStmt>) -> U32:
  match body:
    case Nil{}: 0
    case Con{P113DScalar{stmt},rest}: p113i_add(p113i_scalar_size(stmt),p113i_size(rest))
    case Con{P113DIf{condition,yes,no},rest}: p113i_add(1,p113i_add(p113i_size(yes),p113i_add(p113i_size(no),p113i_size(rest))))
    case Con{stmt,rest}: p113i_add(1,p113i_size(rest))

@unsafe
def p113i_scalar_leaf(stmt: N111Stmt) -> Bool:
  match stmt:
    case N111Alloca{name,bytes,align}: U32.is_le(bytes,2048) && U32.is_eq(align,8)
    case N111Call{name,typ,symbol,args}: Bool.not(String.starts_with(symbol,"p113_"))
    case N111If{condition,yes,no}: p113i_scalars_leaf(yes) && p113i_scalars_leaf(no)
    case _: True{}

@unsafe
def p113i_scalars_leaf(body: List<&2,N111Stmt>) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{head,rest}: p113i_scalar_leaf(head) && p113i_scalars_leaf(rest)

# Before a shared suffix, both branches must fall through. Final branches must
# both return. This deliberately refuses early-return/common-suffix shapes.
@unsafe
def p113i_plain(body: List<&2,P113DStmt>) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{P113DScalar{stmt},rest}: p113i_scalar_leaf(stmt) && p113i_plain(rest)
    case Con{P113DIf{condition,yes,no},rest}: p113i_plain(yes) && p113i_plain(no) && p113i_plain(rest)
    case _: False{}

@unsafe
def p113i_returns(body: List<&2,P113DStmt>) -> Bool:
  match body:
    case Con{P113DResult{Con{value,Nil{}}},Nil{}}: True{}
    case Con{P113DIf{condition,yes,no},Nil{}}: p113i_returns(yes) && p113i_returns(no)
    case Con{P113DIf{condition,yes,no},rest}: p113i_plain(yes) && p113i_plain(no) && p113i_returns(rest)
    case Con{P113DScalar{stmt},rest}: p113i_scalar_leaf(stmt) && p113i_returns(rest)
    case _: False{}

@unsafe
def p113i_eligible(function: P113DFunction) -> Bool:
  match function:
    case P113DFunction{name,+params,result,public,+body}:
      public && U32.is_eq(result,1) && U32.is_le(nt_count(NC_Binding,params),8) &&
        U32.is_le(p113i_size(body),48) && U32.is_le(p113i_stack(body),8192) && p113i_params(params) && p113i_returns(body)

@unsafe
def p113i_original_clean(function: P113DFunction) -> Bool:
  match function:
    case P113DFunction{name,params,result,public,body}: p113i_params(params) && p113i_clean(body)

@unsafe
def p113i_stack_add(left: U32, right: U32) -> U32:
  U32.min(65536,U32.add(left,right))

@unsafe
def p113i_scalar_stack(stmt: N111Stmt) -> U32:
  match stmt:
    case N111Alloca{name,bytes,align}: U32.min(bytes,65536)
    case N111If{condition,yes,no}: p113i_stack_add(p113i_scalars_stack(yes),p113i_scalars_stack(no))
    case _: 0

@unsafe
def p113i_scalars_stack(body: List<&2,N111Stmt>) -> U32:
  match body:
    case Nil{}: 0
    case Con{head,rest}: p113i_stack_add(p113i_scalar_stack(head),p113i_scalars_stack(rest))

@unsafe
def p113i_stack(body: List<&2,P113DStmt>) -> U32:
  match body:
    case Nil{}: 0
    case Con{P113DScalar{stmt},rest}: p113i_stack_add(p113i_scalar_stack(stmt),p113i_stack(rest))
    case Con{P113DIf{condition,yes,no},rest}: p113i_stack_add(p113i_stack(yes),p113i_stack_add(p113i_stack(no),p113i_stack(rest)))
    case Con{stmt,rest}: p113i_stack(rest)
