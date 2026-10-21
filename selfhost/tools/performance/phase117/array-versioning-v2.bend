# General loop versioning over the independently proven entry-origin map.
# Generated fallback has a distinct symbol and the exact old structured body.
@unsafe
def p117v_all(+sites: KDef, +count: U32, +used: U32, +index: U32) -> Bool:
  nt_choose(Bool,U32.is_eq(index,count),u => True{},u =>
    U32.is_gt(U32.and(used,p117h_bit(p117h_get(sites,U32.show(index)))),0) && p117v_all(sites,count,used,U32.inc(index)))

@unsafe
def p117v_guard(params: List<&2,NC_Binding>, +origin: U32, +used: U32) -> List<&2,N111Stmt>:
  match params:
    case Nil{}: []
    case Con{head,rest}:
      nt_append(N111Stmt,nt_choose(List<&2,N111Stmt>,U32.is_eq(U32.and(used,p117h_bit(origin)),0),u => [],u =>
        [N111Bin{"p113a_version_guard",N111U32{},"and",N111Local{"p113a_version_guard"},p117h_ref(origin,"admitted")}]),
        p117v_guard(rest,U32.inc(origin),used))

@unsafe
def p117v_template(+original: N111Stmt, +n: U32, +origin: U32) -> List<&2,N111Stmt>:
  match original:
    case N111Call{destination,N111U64{},symbol,+args}:
      +id = p113a_call_id(symbol,args)
      nt_append(N111Stmt,p113a_inputs(id,p111v_arg(args,2),n),
        nt_choose(List<&2,N111Stmt>,U32.is_eq(id,75),
          u => p113a_pair_store(destination,p111v_arg(args,4),p117h_ref(origin,"size"),n),
          u => nt_append(N111Stmt,p117h_address(id,n,origin),p113a_success(id,destination,p111v_arg(args,4),n))))
    case _: [original]

@unsafe
def p117v_rewrite(body: List<&2,P113DStmt>, +n: U32, +heap_min: U32, +used: U32, +sites: KDef) -> P113ABody:
  match body:
    case Nil{}: P113ABody{[],n}
    case Con{P113DScalar{+stmt},+rest}:
      +origin = p117h_get(sites,U32.show(n))
      nt_choose(P113ABody,U32.is_eq(p113a_stmt_id(stmt),0),
        u => p113a_prefix([P113DScalar{stmt}],p117v_rewrite(rest,n,heap_min,used,sites)),u =>
        p113a_prefix(p113d_scalars(nt_choose(List<&2,N111Stmt>,U32.is_eq(U32.and(used,p117h_bit(origin)),0),
          v => p113a_template(stmt,n,heap_min),v => p117v_template(stmt,n,origin))),
          p117v_rewrite(rest,U32.inc(n),heap_min,used,sites)))
    case Con{P113DIf{condition,yes,no},rest}:
      p117v_rewrite_yes(condition,no,rest,heap_min,used,sites,p117v_rewrite(yes,n,heap_min,used,sites))
    case Con{head,rest}: p113a_prefix([head],p117v_rewrite(rest,n,heap_min,used,sites))

@unsafe
def p117v_rewrite_yes(condition: N111Value, no: List<&2,P113DStmt>, rest: List<&2,P113DStmt>, +heap_min: U32, +used: U32, +sites: KDef, yes: P113ABody) -> P113ABody:
  match yes:
    case P113ABody{body,next}: p117v_rewrite_no(condition,body,rest,heap_min,used,sites,p117v_rewrite(no,next,heap_min,used,sites))

@unsafe
def p117v_rewrite_no(condition: N111Value, yes: List<&2,P113DStmt>, rest: List<&2,P113DStmt>, +heap_min: U32, +used: U32, +sites: KDef, no: P113ABody) -> P113ABody:
  match no:
    case P113ABody{body,next}: p113a_prefix([P113DIf{condition,yes,body}],p117v_rewrite(rest,next,heap_min,used,sites))


@unsafe
def p117v_allocas(+body: List<&2,P113DStmt>) -> List<&2,String>:
  +allocas = p113e_allocas(body,["%v_scratch =l alloc8 2048\n"])
  nt_choose(List<&2,String>,p113e_multi(body),u => Con{"%p113_results =l alloc8 64\n",allocas},u => allocas)

@unsafe
def p117v_signature(params: List<&2,NC_Binding>, result: U32) -> String:
  p113e_formals(params,nt_choose(String,U32.is_eq(result,1),u => "l %state",u => "l %state, l %p113_result_out"))

@unsafe
def p117v_fallback(function: P113DFunction, +ids: N111Ids, heap_min: U32) -> String:
  p117v_fallback_ready(p113a_function(function,heap_min),ids)

@unsafe
def p117v_fallback_ready(function: P113DFunction, +ids: N111Ids) -> String:
  match function:
    case P113DFunction{+name,+params,+result,public,+body}:
      "function l $p117v_" ++ nt_fid(name) ++ "(" ++ p117v_signature(params,result) ++ ") {\n@entry\n" ++
        p111q_body_text(p113ah_loop(body,params,ids,p111q_stmt(
          N111Load{"p113a_heap_base",N111Ptr{},N111Local{"state"},0},ids,P111QCode{p117v_allocas(body),0,False{},""}))) ++ "}\n"

@unsafe
def p117v_private(function: P113DFunction, +ids: N111Ids, +prelude: List<&2,N111Stmt>, +used: U32) -> String:
  match function:
    case P113DFunction{+name,+params,+result,public,+body}:
      +dispatch = "jnz %v_p113a_version_guard, @p117_fast, @p117_fallback\n@p117_fallback\n%p117_fallback_value =l call $p117v_" ++ nt_fid(name) ++ "(" ++ p117v_signature(params,result) ++ ")\nret %p117_fallback_value\n@p117_fast\n"
      +setup = nt_append(N111Stmt,Con{N111Load{"p113a_heap_base",N111Ptr{},N111Local{"state"},0},prelude},
        Con{N111Set{"p113a_version_guard",N111U32{},N111Const{1,0}},p117v_guard(params,1,used)})
      "function l $" ++ p113e_symbol(name) ++ "(" ++ p117v_signature(params,result) ++ ") {\n@entry\n" ++
        p111q_body_text(p113ah_loop(body,params,ids,p111q_line(dispatch,p111q_stmts(setup,ids,P111QCode{p117v_allocas(body),0,False{},""})))) ++ "}\n"

@unsafe
def p117v_previous_finish(+function: P113DFunction, +ids: N111Ids, +heap_min: U32, scan: P117HScan) -> String:
  match function scan:
    case P113DFunction{name,+params,result,public,body} P117HScan{facts,slots,+mask,+used,+again,left,next,+sites}:
      +used = U32.and(mask,used)
      nt_choose(String,again && U32.is_gt(used,0),u =>
        p117h_private(p113a_function_done(name,params,result,public,p117h_rewrite(body,0,heap_min,used,sites)),ids,
          p117h_prelude(params,1,used,heap_min)),
        u => p113ah_private(p113a_function(function,heap_min),ids))


@unsafe
def p117h_finish(+function: P113DFunction, +ids: N111Ids, +heap_min: U32, +scan: P117HScan) -> String:
  match function scan:
    case P113DFunction{name,+params,result,public,+body} P117HScan{facts,slots,+mask,+used,+again,left,+next,+sites}:
      +used = U32.and(mask,used)
      nt_choose(String,again && U32.is_gt(used,0) && U32.is_gt(next,0) && U32.is_le(p113i_size(body),1024) && p117v_all(sites,next,used,0),u =>
        p117v_fallback(function,ids,heap_min) ++
        p117v_private(p113a_function_done(name,params,result,public,p117v_rewrite(body,0,heap_min,used,sites)),ids,
          p117h_prelude(params,1,used,heap_min),used),
        u => p117v_previous_finish(function,ids,heap_min,scan))
