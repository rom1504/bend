# Derived renderer plan only. The original verified function stays immutable.
type P114SOGroup is Data:
  P114SONo{}
  P114SOYes{+buffer: String, +name: String, +id: U32,
    +left: N111Value, +right: N111Value, +rest: List<&2,P113DStmt>}

@unsafe
def p114so_value_clear(value: N111Value, +buffer: String) -> Bool:
  match value:
    case N111Local{name}: Bool.not(String.eq(name,buffer))
    case _: True{}

@unsafe
def p114so_values_clear(values: List<&2,N111Value>, +buffer: String) -> Bool:
  match values:
    case Nil{}: True{}
    case Con{head,rest}: p114so_value_clear(head,buffer) && p114so_values_clear(rest,buffer)

@unsafe
def p114so_args_clear(args: List<&2,N111Arg>, +buffer: String) -> Bool:
  match args:
    case Nil{}: True{}
    case Con{N111Arg{typ,value},rest}: p114so_value_clear(value,buffer) && p114so_args_clear(rest,buffer)

@unsafe
def p114so_names_clear(names: List<&2,String>, +buffer: String) -> Bool:
  match names:
    case Nil{}: True{}
    case Con{name,rest}: Bool.not(String.eq(name,buffer)) && p114so_names_clear(rest,buffer)

@unsafe
def p114so_scalar_clear(stmt: N111Stmt, +buffer: String) -> Bool:
  match stmt:
    case N111Set{name,typ,value}: Bool.not(String.eq(name,buffer)) && p114so_value_clear(value,buffer)
    case N111Bin{name,typ,op,left,right}: Bool.not(String.eq(name,buffer)) && p114so_value_clear(left,buffer) && p114so_value_clear(right,buffer)
    case N111Call{name,typ,symbol,args}: Bool.not(String.eq(name,buffer)) && p114so_args_clear(args,buffer)
    case N111If{condition,yes,no}: p114so_value_clear(condition,buffer) && p114so_scalars_clear(yes,buffer) && p114so_scalars_clear(no,buffer)
    case N111Return{value}: p114so_value_clear(value,buffer)
    case N111Load{name,typ,base,offset}: Bool.not(String.eq(name,buffer)) && p114so_value_clear(base,buffer)
    case N111Store{typ,base,offset,value}: p114so_value_clear(base,buffer) && p114so_value_clear(value,buffer)
    case N111Offset{name,base,bytes}: Bool.not(String.eq(name,buffer)) && p114so_value_clear(base,buffer) && p114so_value_clear(bytes,buffer)
    case N111Alloca{name,bytes,align}: True{}

@unsafe
def p114so_scalars_clear(body: List<&2,N111Stmt>, +buffer: String) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{head,rest}: p114so_scalar_clear(head,buffer) && p114so_scalars_clear(rest,buffer)

@unsafe
def p114so_group_call(stmt: N111Stmt, +buffer: String, +left: N111Value, +right: N111Value, +count: U32, +rest: List<&2,P113DStmt>) -> P114SOGroup:
  match stmt:
    case N111Call{+name,N111U64{},symbol,[N111Arg{N111Ptr{},N111Local{state}},N111Arg{N111U32{},N111Const{+id,0}},N111Arg{N111Ptr{},N111Local{input}},N111Arg{N111U32{},N111Const{argc,0}}]}:
      nt_choose(P114SOGroup,String.eq(symbol,"p111_rt_op") && String.eq(state,"state") &&
        Bool.not(String.eq(buffer,"state")) && String.eq(input,buffer) && U32.is_eq(count,argc) &&
        p112fp_supported(id,count) && Bool.not(String.eq(name,buffer)) &&
        p114so_value_clear(left,buffer) && p114so_value_clear(right,buffer),
        u => P114SOYes{buffer,name,id,left,right,rest},u => P114SONo{})
    case _: P114SONo{}

@unsafe
def p114so_group(body: List<&2,P113DStmt>) -> P114SOGroup:
  match body:
    case Con{P113DScalar{N111Store{N111U64{},N111Local{+buffer},0,left}},Con{P113DScalar{N111Store{N111U64{},N111Local{other},8,right}},Con{P113DScalar{call},rest}}}:
      nt_choose(P114SOGroup,String.eq(buffer,other),u => p114so_group_call(call,buffer,left,right,2,rest),u => P114SONo{})
    case Con{P113DScalar{N111Store{N111U64{},N111Local{+buffer},0,left}},Con{P113DScalar{call},rest}}:
      p114so_group_call(call,buffer,left,N111Const{0,0},1,rest)
    case _: P114SONo{}

@unsafe
def p114so_stmt_clear(stmt: P113DStmt, +buffer: String) -> Bool:
  match stmt:
    case P113DScalar{scalar}: p114so_scalar_clear(scalar,buffer)
    case P113DIf{condition,yes,no}: p114so_value_clear(condition,buffer) && p114so_audit(yes,buffer) && p114so_audit(no,buffer)
    case P113DCall{names,target,args}: p114so_names_clear(names,buffer) && p114so_values_clear(args,buffer)
    case P113DResult{values}: p114so_values_clear(values,buffer)
    case P113DAgain{values}: p114so_values_clear(values,buffer)

@unsafe
def p114so_audit_group(+body: List<&2,P113DStmt>, +buffer: String, group: P114SOGroup) -> Bool:
  match group:
    case P114SOYes{name,destination,id,left,right,rest}:
      nt_choose(Bool,String.eq(name,buffer),u => p114so_audit(rest,buffer),u => p114so_audit_head(body,buffer))
    case P114SONo{}: p114so_audit_head(body,buffer)

@unsafe
def p114so_audit_head(body: List<&2,P113DStmt>, +buffer: String) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{head,rest}: p114so_stmt_clear(head,buffer) && p114so_audit(rest,buffer)

@unsafe
def p114so_audit(+body: List<&2,P113DStmt>, +buffer: String) -> Bool:
  p114so_audit_group(body,buffer,p114so_group(body))

@unsafe
def p114so_allocations(body: List<&2,P113DStmt>, +acc: List<&2,String>) -> List<&2,String>:
  match body:
    case Nil{}: acc
    case Con{P113DScalar{N111Alloca{name,bytes,align}},rest}:
      p114so_allocations(rest,nt_choose(List<&2,String>,U32.is_ge(bytes,8),u => Con{name,acc},u => acc))
    case Con{P113DIf{condition,yes,no},rest}: p114so_allocations(rest,p114so_allocations(no,p114so_allocations(yes,acc)))
    case Con{stmt,rest}: p114so_allocations(rest,acc)

@unsafe
def p114so_admit(candidates: List<&2,String>, +body: List<&2,P113DStmt>) -> List<&2,String>:
  match candidates:
    case Nil{}: []
    case Con{+name,+rest}: nt_choose(List<&2,String>,p114so_seen(body,name) && p114so_audit(body,name),u => Con{name,p114so_admit(rest,body)},u => p114so_admit(rest,body))

@unsafe
def p114so_buffers(+body: List<&2,P113DStmt>) -> List<&2,String>:
  p114so_admit(p114so_allocations(body,["scratch"]),body)

@unsafe
def p114so_member(names: List<&2,String>, +name: String) -> Bool:
  match names:
    case Nil{}: False{}
    case Con{head,rest}: String.eq(head,name) || p114so_member(rest,name)

@unsafe
def p114so_seen_group(+body: List<&2,P113DStmt>, +buffer: String, group: P114SOGroup) -> Bool:
  match group:
    case P114SOYes{name,destination,id,left,right,rest}:
      String.eq(name,buffer) || p114so_seen(rest,buffer)
    case P114SONo{}: p114so_seen_head(body,buffer)

@unsafe
def p114so_seen_head(body: List<&2,P113DStmt>, +buffer: String) -> Bool:
  match body:
    case Nil{}: False{}
    case Con{P113DIf{condition,yes,no},rest}: p114so_seen(yes,buffer) || p114so_seen(no,buffer) || p114so_seen(rest,buffer)
    case Con{head,rest}: p114so_seen(rest,buffer)

@unsafe
def p114so_seen(+body: List<&2,P113DStmt>, +buffer: String) -> Bool:
  p114so_seen_group(body,buffer,p114so_group(body))
