# These stages are the existing x185/x186 normalization pipeline with one
# selector before allocation. Non-admitted versions use the original entry.
def x199s_enabled() -> Bool: True{}

@unsafe
def x199s_copied(+symbol: String, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +ids: N111Ids) -> X181Output:
  x185_function_copied(symbol,params,setup,x199s_select(params,body),ids)

@unsafe
def x199s_memory(+symbol: String, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +ids: N111Ids) -> X181Output:
  x199s_copied(symbol,params,setup,x185_dead_body(setup,
    x185_copy_function(params,setup,x186_expression_body(setup,
      x190_local_values_body(setup,x192_predicate_body(x186_private_body(params,setup,body)))))),ids)

@unsafe
def x199s_place(+symbol: String, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +ids: N111Ids) -> X181Output:
  x199s_memory(symbol,params,setup,x185_prepare_body(params,setup,x185_scratch_body(params,setup,body)),ids)

@unsafe
def x199s_late_body(symbol: String, params: List<&2,String>, setup: List<&2,P113DStmt>,
    ids: N111Ids, body: P113ABody) -> X181Output:
  match body:
    case P113ABody{ready,next}: x199s_place(symbol,params,setup,ready,ids)

@unsafe
def x199s_late_setup(symbol: String, params: List<&2,String>, body: List<&2,P113DStmt>,
    +ids: N111Ids, setup: P113ABody) -> X181Output:
  match setup:
    case P113ABody{ready,next}: x199s_late_body(symbol,params,ready,ids,x185_late_stmts(body,ids,next))

@unsafe
def x199s_setup(+symbol: String, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +ids: N111Ids) -> X181Output:
  nt_choose(X181Output,x185_late_enabled() && p114t_names(params) && p114t_body_names(setup) && p114t_body_names(body),
    u => x199s_late_setup(symbol,params,body,ids,x185_late_stmts(setup,ids,0)),
    u => x199s_place(symbol,params,setup,body,ids))

@unsafe
def x199s_array_emit(+function: P113DFunction, +symbol: String, +prelude: List<&2,N111Stmt>,
    +ids: N111Ids, used: U32) -> X181Output:
  match function:
    case P113DFunction{name,+params,+result,public,body}:
      nt_choose(X181Output,x199s_enabled() && U32.is_eq(result,2) &&
          U32.is_eq(nt_count(NC_Binding,params),4) && U32.is_eq(used,p117h_bit(3)),
        u => x199s_setup(symbol,Con{"state",Con{"__x181_result_out",x181_param_names(params)}},
          x181_scalar_rows(Con{N111Load{"p113a_heap_base",N111Ptr{},N111Local{"state"},0},prelude}),body,ids),
        u => x185_array_emit(function,symbol,prelude,ids))
