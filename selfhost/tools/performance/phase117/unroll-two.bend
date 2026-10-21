# Experiment-local two-iteration expansion for small versioned direct loops.
# The only call exception is the original exact pattern-match failure helper;
# it remains at its original sequential position, including in the second copy.
@unsafe
def p117u_scalar(stmt: N111Stmt) -> Bool:
  match stmt:
    case N111Call{name,N111U64{},symbol,
      Con{N111Arg{N111Ptr{},N111Local{state}},Con{N111Arg{N111U32{},N111Const{4,0}},Nil{}}}}:
        String.eq(symbol,"p111_rt_fail") && String.eq(state,"state")
    case N111Call{name,typ,symbol,args}: False{}
    case N111Set{name,N111Ptr{},value}: False{}
    case N111Bin{name,N111Ptr{},op,left,right}: False{}
    case N111Load{name,N111Ptr{},base,offset}: False{}
    case N111Store{N111Ptr{},base,offset,value}: False{}
    case N111Return{value}: False{}
    case N111Offset{name,base,bytes}: String.starts_with(name,"p113a_")
    case N111If{condition,yes,no}: p117u_scalars(yes) && p117u_scalars(no)
    case _: True{}

@unsafe
def p117u_scalars(body: List<&2,N111Stmt>) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{head,rest}: p117u_scalar(head) && p117u_scalars(rest)

@unsafe
def p117u_safe(body: List<&2,P113DStmt>, +count: U32) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{P113DScalar{stmt},rest}: p117u_scalar(stmt) && p117u_safe(rest,count)
    case Con{P113DIf{condition,yes,no},rest}: p117u_safe(yes,count) && p117u_safe(no,count) && p117u_safe(rest,count)
    case Con{P113DAgain{values},Nil{}}: U32.is_eq(nt_count(N111Value,values),count)
    case Con{P113DResult{values},Nil{}}: True{}
    case _: False{}

@unsafe
def p117u_edges(body: List<&2,P113DStmt>) -> U32:
  match body:
    case Nil{}: 0
    case Con{P113DAgain{values},rest}: U32.inc(p117u_edges(rest))
    case Con{P113DIf{condition,yes,no},rest}: U32.add(p117u_edges(yes),U32.add(p117u_edges(no),p117u_edges(rest)))
    case Con{head,rest}: p117u_edges(rest)

# Again emits two full-word moves per formal plus a jump. Counting those moves
# makes the bound reflect the existing emitter rather than a one-node fiction.
@unsafe
def p117u_cost(+body: List<&2,P113DStmt>, count: U32) -> U32:
  U32.add(p113i_size(body),U32.mul(U32.mul(2,count),p117u_edges(body)))

@unsafe
def p117u_strip_scalars(body: List<&2,N111Stmt>) -> List<&2,N111Stmt>:
  match body:
    case Nil{}: []
    case Con{N111Alloca{name,bytes,align},rest}: p117u_strip_scalars(rest)
    case Con{N111If{condition,yes,no},rest}: Con{N111If{condition,p117u_strip_scalars(yes),p117u_strip_scalars(no)},p117u_strip_scalars(rest)}
    case Con{head,rest}: Con{head,p117u_strip_scalars(rest)}

@unsafe
def p117u_strip(body: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  match body:
    case Nil{}: []
    case Con{P113DScalar{stmt},rest}: nt_append(P113DStmt,p113d_scalars(p117u_strip_scalars([stmt])),p117u_strip(rest))
    case Con{P113DIf{condition,yes,no},rest}: Con{P113DIf{condition,p117u_strip(yes),p117u_strip(no)},p117u_strip(rest)}
    case Con{head,rest}: Con{head,p117u_strip(rest)}

@unsafe
def p117u_snapshot(values: List<&2,N111Value>, +index: U32) -> List<&2,P113DStmt>:
  match values:
    case Nil{}: []
    case Con{value,rest}: Con{P113DScalar{N111Set{"p113a_unroll_" ++ U32.show(index),N111U64{},value}},p117u_snapshot(rest,U32.inc(index))}

@unsafe
def p117u_assign(params: List<&2,NC_Binding>, +index: U32) -> List<&2,P113DStmt>:
  match params:
    case Nil{}: []
    case Con{NC_Binding{id,name,kind},rest}: Con{P113DScalar{N111Set{name,N111U64{},N111Local{"p113a_unroll_" ++ U32.show(index)}}},p117u_assign(rest,U32.inc(index))}

@unsafe
def p117u_expand(body: List<&2,P113DStmt>, +params: List<&2,NC_Binding>, +second: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  match body:
    case Nil{}: []
    case Con{P113DAgain{values},Nil{}}: nt_append(P113DStmt,p117u_snapshot(values,0),nt_append(P113DStmt,p117u_assign(params,0),second))
    case Con{P113DIf{condition,yes,no},rest}: Con{P113DIf{condition,p117u_expand(yes,params,second),p117u_expand(no,params,second)},p117u_expand(rest,params,second)}
    case Con{head,rest}: Con{head,p117u_expand(rest,params,second)}

@unsafe
def p117u_bounded(+original: List<&2,P113DStmt>, +count: U32, +candidate: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  nt_choose(List<&2,P113DStmt>,U32.is_le(p117u_cost(candidate,count),U32.mul(2,p117u_cost(original,count))),u => candidate,u => original)

@unsafe
def p117u_body(+body: List<&2,P113DStmt>, +params: List<&2,NC_Binding>) -> List<&2,P113DStmt>:
  +count = nt_count(NC_Binding,params)
  nt_choose(List<&2,P113DStmt>,U32.is_le(count,16) && U32.is_eq(p117u_edges(body),1) &&
    U32.is_le(p117u_cost(body,count),256) && p117u_safe(body,count),
    u => p117u_bounded(body,count,p117u_expand(body,params,p117u_strip(body))),u => body)

# Sole override: unchanged dispatcher/fallback ABI around the structured body.
@unsafe
def p117v_private(function: P113DFunction, +ids: N111Ids, +prelude: List<&2,N111Stmt>, +used: U32) -> String:
  match function:
    case P113DFunction{+name,+params,+result,public,+body}:
      +body = p117u_body(body,params)
      +dispatch = "jnz %v_p113a_version_guard, @p117_fast, @p117_fallback\n@p117_fallback\n%p117_fallback_value =l call $p117v_" ++ nt_fid(name) ++ "(" ++ p117v_signature(params,result) ++ ")\nret %p117_fallback_value\n@p117_fast\n"
      +setup = nt_append(N111Stmt,Con{N111Load{"p113a_heap_base",N111Ptr{},N111Local{"state"},0},prelude},
        Con{N111Set{"p113a_version_guard",N111U32{},N111Const{1,0}},p117v_guard(params,1,used)})
      "function l $" ++ p113e_symbol(name) ++ "(" ++ p117v_signature(params,result) ++ ") {\n@entry\n" ++
        p111q_body_text(p113ah_loop(body,params,ids,p111q_line(dispatch,p111q_stmts(setup,ids,P111QCode{p117v_allocas(body),0,False{},""})))) ++ "}\n"
