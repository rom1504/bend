# Structured x86 consumer of the existing closed P114H plan.
# No new recursive-region recognizer and no native self-recursion. Runtime
# continuation frames remain authoritative. All transfers use one local loop.
# Caller must preserve mode/direct-public precedence before querying this path.
def x192h_regions_enabled() -> Bool: True{}

def x192h_v(name: String) -> N111Value: N111Local{name}
def x192h_c(value: U32) -> N111Value: N111Const{value,0}

def x192h_stack(symbol: String, destination: String, count: U32) -> P113DStmt:
  P113DScalar{N111Call{destination,N111U64{},symbol,[p111_state(),p111_u32(count)]}}

@unsafe
def x192h_values(names: List<&2,String>) -> List<&2,N111Value>:
  match names:
    case Nil{}: []
    case Con{name,rest}: Con{x192h_v(name),x192h_values(rest)}

@unsafe
def x192h_formals(params: List<&2,String>) -> List<&2,String>:
  Con{"state",nt_append(String,params,["p114h_mode","p114r_depth","p114r_value"])}

# x181_tail_args excludes the invariant leading state formal. Again therefore
# carries params+mode+depth+value, not state. Its existing parallel move/snapshot
# path protects cycles and aliases between parameters and result operands.
@unsafe
def x192h_transfer(values: List<&2,N111Value>, mode: U32, value: N111Value) -> P113DStmt:
  P113DAgain{nt_append(N111Value,values,[x192h_c(mode),x192h_v("p114r_depth"),value])}

@unsafe
def x192h_result(params: List<&2,String>, value: N111Value) -> P113DStmt:
  x192h_transfer(x192h_values(params),1,value)

def x192h_increment() -> P113DStmt:
  P113DScalar{N111Bin{"p114r_depth",N111U64{},"add",x192h_v("p114r_depth"),x192h_c(1)}}

@unsafe
def x192h_edge_name(index: U32) -> String:
  "p114h_edge_" ++ U32.show(index)

# Every scratch argument is read before any parameter is overwritten, including
# cross-parameter swaps and same-name results. Case buffers use QBE's rename.
@unsafe
def x192h_snapshots(+count: U32, +index: U32, +buffer: String) -> List<&2,P113DStmt>:
  nt_choose(List<&2,P113DStmt>,U32.is_eq(index,count),u => [],u =>
    Con{P113DScalar{N111Load{x192h_edge_name(index),N111U64{},x192h_v(buffer),U32.mul(index,8)}},
      x192h_snapshots(count,U32.inc(index),buffer)})

@unsafe
def x192h_edges(+count: U32, +index: U32) -> List<&2,N111Value>:
  nt_choose(List<&2,N111Value>,U32.is_eq(index,count),u => [],u =>
    Con{x192h_v(x192h_edge_name(index)),x192h_edges(count,U32.inc(index))})

@unsafe
def x192h_again(arguments: List<&2,N111Stmt>, +params: List<&2,String>, +buffer: String) -> List<&2,P113DStmt>:
  +count = nt_count(String,params)
  nt_append(P113DStmt,x181_scalar_rows(arguments),nt_append(P113DStmt,x192h_snapshots(count,0,buffer),
    [x192h_transfer(x192h_edges(count,0),0,x192h_v("p114r_value"))]))

law x192h_body:
  for body: List<&2,P114RStmt>
  for +params: List<&2,String>
  for +buffer: String
  List<&2,P113DStmt>

# Match all eight current constructors explicitly. A future constructor cannot
# silently gain admission through a permissive default. Frame/call statements
# retain their exact ordering and use the maintained runtime/late expansions.
@unsafe
def x192h_stmt(stmt: P114RStmt, +params: List<&2,String>, +buffer: String) -> List<&2,P113DStmt>:
  match stmt:
    case P114RScalar{scalar}: [P113DScalar{scalar}]
    case P114RIf{condition,yes,no}:
      [P113DIf{condition,x192h_body(yes,params,buffer),x192h_body(no,params,buffer)}]
    case P114RDescend{frame,arguments}:
      nt_append(P113DStmt,x181_scalar_rows(frame),Con{x192h_increment(),x192h_again(arguments,params,buffer)})
    case P114RAgain{arguments}: x192h_again(arguments,params,buffer)
    case P114RResult{value}: [x192h_result(params,value)]
    case P114RFailure{body}: x181_scalar_rows(body)
    case P114RResumeReady{frame,call,result}:
      nt_append(P113DStmt,x181_scalar_rows(frame),Con{x192h_increment(),
        nt_append(P113DStmt,x181_scalar_rows(call),[x192h_result(params,result)])})
    case P114RPushFrame{frame}: nt_append(P113DStmt,x181_scalar_rows(frame),[x192h_increment()])

@unsafe
def x192h_body(body,params,buffer):
  match body:
    case Nil{}: []
    case Con{stmt,rest}: nt_append(P113DStmt,x192h_stmt(stmt,params,buffer),x192h_body(rest,params,buffer))

@unsafe
def x192h_buffers(cases: List<&2,P114HCase>, +index: U32) -> List<&2,P113DStmt>:
  match cases:
    case Nil{}: []
    case Con{head,rest}:
      Con{P113DScalar{N111Alloca{p112f_name(p114h_prefix(index),"scratch"),2048,8}},x192h_buffers(rest,U32.inc(index))}

@unsafe
def x192h_restore(captures: List<&2,String>, +index: U32, +prefix: String) -> List<&2,P113DStmt>:
  match captures:
    case Nil{}: []
    case Con{name,rest}:
      Con{x192h_stack("p111_rt_stack_get",p112f_name(prefix,name),index),x192h_restore(rest,U32.inc(index),prefix)}

# Runtime pop adjusts SP first; stack_get then reads the popped words. This is
# intentional, matching p114hs_case, not a conventional pop-returning-values API.
@unsafe
def x192h_case_prefix(+captures: List<&2,String>, result: String, +pop: String, +index: U32) -> List<&2,P113DStmt>:
  +count = nt_count(String,captures)
  +prefix = p114h_prefix(index)
  nt_append(P113DStmt,nt_choose(List<&2,P113DStmt>,U32.is_eq(count,0),u => [],
      u => [x192h_stack("p111_rt_stack_pop","p114h_popped",count)]),
    nt_append(P113DStmt,nt_choose(List<&2,P113DStmt>,String.is_empty(pop),u => [],
      u => [P113DScalar{N111Set{p112f_name(prefix,pop),N111U64{},x192h_c(0)}}]),
      nt_append(P113DStmt,x192h_restore(captures,0,prefix),
        [P113DScalar{N111Set{p112f_name(prefix,result),N111U64{},x192h_v("p114r_value")}}])))

@unsafe
def x192h_case(item: P114HCase, +index: U32, params: List<&2,String>) -> List<&2,P113DStmt>:
  match item:
    case P114HCase{name,captures,result,pop,body}:
      nt_append(P113DStmt,x192h_case_prefix(captures,result,pop,index),
        x192h_body(p114h_rename(body,p114h_prefix(index)),params,p112f_name(p114h_prefix(index),"scratch")))

@unsafe
def x192h_dispatch(cases: List<&2,P114HCase>, +index: U32, +params: List<&2,String>) -> List<&2,P113DStmt>:
  match cases:
    case Nil{}:
      [x192h_stack("p111_rt_fail","p114h_bad",4),P113DResult{[x192h_v("p114h_bad")]}]
    case Con{+head,rest}:
      match head:
        case P114HCase{name,captures,result,pop,body}:
          [P113DScalar{N111Bin{"p114h_test",N111U64{},"eq",x192h_v("p114h_fid"),N111FuncId{name}}},
           P113DIf{x192h_v("p114h_test"),x192h_case(head,index,params),x192h_dispatch(rest,U32.inc(index),params)}]

@unsafe
def x192h_unwind(cases: List<&2,P114HCase>, params: List<&2,String>) -> List<&2,P113DStmt>:
  [P113DScalar{N111Bin{"p114r_pending",N111U64{},"ne",x192h_v("p114r_depth"),x192h_c(0)}},
   P113DIf{x192h_v("p114r_pending"),
     Con{P113DScalar{N111Bin{"p114r_depth",N111U64{},"sub",x192h_v("p114r_depth"),x192h_c(1)}},
     Con{x192h_stack("p111_rt_stack_pop","p114h_popped",1),
     Con{x192h_stack("p111_rt_stack_get","p114h_fid",0),x192h_dispatch(cases,0,params)}}},
     [P113DResult{[x192h_v("p114r_value")]}]}]

@unsafe
def x192h_worker_body(+params: List<&2,String>, body: List<&2,P114RStmt>, cases: List<&2,P114HCase>) -> List<&2,P113DStmt>:
  [P113DIf{x192h_v("p114h_mode"),x192h_unwind(cases,params),x192h_body(body,params,"scratch")}]

@unsafe
def x192h_public_loads(params: List<&2,String>, +index: U32) -> List<&2,P113DStmt>:
  match params:
    case Nil{}: []
    case Con{name,rest}:
      Con{x192h_stack("p111_rt_reg_get",name,index),x192h_public_loads(rest,U32.inc(index))}

@unsafe
def x192h_public_args(params: List<&2,String>) -> List<&2,N111Arg>:
  match params:
    case Nil{}: [N111Arg{N111U64{},x192h_c(0)},N111Arg{N111U64{},x192h_c(0)},N111Arg{N111U64{},x192h_c(0)}]
    case Con{name,rest}: Con{N111Arg{N111U64{},x192h_v(name)},x192h_public_args(rest)}

@unsafe
def x192h_adapter(name: String, +params: List<&2,String>) -> List<&2,P113DStmt>:
  Con{P113DScalar{N111Alloca{"p114r_outer_out",8,8}},nt_append(P113DStmt,x192h_public_loads(params,0),[
    P113DScalar{N111Call{"p114r_outer_value",N111U64{},p114r_symbol(name),Con{p111_state(),x192h_public_args(params)}}},
    P113DScalar{N111Store{N111U64{},x192h_v("p114r_outer_out"),0,x192h_v("p114r_outer_value")}},
    P113DScalar{N111Call{"p114r_outer_reply",N111U64{},"p111_rt_return",[
      p111_state(),N111Arg{N111Ptr{},x192h_v("p114r_outer_out")},p111_u32(1)]}},
    P113DResult{[x192h_v("p114r_outer_reply")]}])}

@unsafe
def x192h_output_or_original(segment: N111Segment, ids: N111Ids, +candidate: X181Output) -> X181Output:
  match candidate:
    case X181Output{chunks,error}:
      nt_choose(X181Output,String.is_empty(error),u => candidate,u => x181_segment(segment,ids))

# Keep original/public bodies as fallback on unavailable ready helpers, naming
# collisions, incomplete structured emission or any ordinary selector refusal.
# Availability is checked over setup, body AND adapter before machine emission.
@unsafe
def x192h_emit_checked(+segment: N111Segment, +name: String, +params: List<&2,String>,
    +setup: List<&2,P113DStmt>, +body: List<&2,P113DStmt>, +adapter: List<&2,P113DStmt>,
    +ids: N111Ids, +available: KDef) -> X181Output:
  +error = p111_first(x181_program_stmts(setup,available),p111_first(x181_program_stmts(body,available),
    p111_first(x181_program_stmts(adapter,available),p111_first(x181_hygiene_names(params),
      p111_first(x181_hygiene_stmts(setup),p111_first(x181_hygiene_stmts(body),x181_hygiene_stmts(adapter)))))))
  nt_choose(X181Output,String.is_empty(error),u => x192h_output_or_original(segment,ids,
    x181_program_join(x185_function_setup(p114r_symbol(name),params,setup,body,ids),
      x185_function_setup(p111q_symbol(name),["state"],[],adapter,ids))),u => x181_segment(segment,ids))

@unsafe
def x192h_public_planned(+segment: N111Segment, +ids: N111Ids, available: KDef, plan: P114HPlan) -> X181Output:
  match segment plan:
    case N111Segment{+name,arity,result,incoming,flags,original} P114HPlan{valid,+params,body,+cases}:
      nt_choose(X181Output,valid,u => x192h_emit_checked(segment,name,x192h_formals(params),
        Con{P113DScalar{N111Alloca{"scratch",2048,8}},x192h_buffers(cases,0)},
        x192h_worker_body(params,body,cases),x192h_adapter(name,params),ids,available),
        u => x181_segment(segment,ids))

# This entry obtains its plan only from the original checked H planner. It does
# not query the extended callable view or relax readiness/hygiene/closure caps.
@unsafe
def x192h_public(+segment: N111Segment, index: P112FusionIndex, +ids: N111Ids,
    ready: KDef, available: KDef) -> X181Output:
  nt_choose(X181Output,x192h_regions_enabled(),u =>
    x192h_public_planned(segment,ids,available,p114h_plan(segment,index,ready)),u => x181_segment(segment,ids))
