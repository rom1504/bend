# Preserve the direct-worker parameter kinds until after the existing scalar
# normalization. Fallback retains the old pipeline; no operation is selected here.
@unsafe
def x198n_normalized(symbol: String, +names: List<&2,String>, +params: List<&2,NC_Binding>, body: List<&2,P113DStmt>, ids: N111Ids) -> X181Output:
  x186_float_function(symbol,names,[],x198n_body(x185_dead_body([],
    x185_copy_function(names,[],x186_expression_body([],
      x190_local_values_body([],x192_predicate_body(x186_private_body(names,[],body)))))),params),ids)

@unsafe
def x198n_place(symbol: String, +names: List<&2,String>, params: List<&2,NC_Binding>, body: List<&2,P113DStmt>, ids: N111Ids) -> X181Output:
  x198n_normalized(symbol,names,params,x185_prepare_body(names,[],x185_scratch_body(names,[],body)),ids)

@unsafe
def x198n_late(symbol: String, names: List<&2,String>, params: List<&2,NC_Binding>, ids: N111Ids, result: P113ABody) -> X181Output:
  match result:
    case P113ABody{body,next}: x198n_place(symbol,names,params,body,ids)

@unsafe
def x181_direct(function,ids):
  match function:
    case P113DFunction{+name,+params,+result,public,+body}:
      +names : List<&2,String> = Con{"state",nt_choose(List<&2,String>,U32.is_eq(result,1),u => x181_param_names(params),u => Con{"__x181_result_out",x181_param_names(params)})}
      +error = p111_first(x181_hygiene_names(x181_param_names(params)),x181_hygiene_stmts(body))
      nt_choose(X181Output,String.is_empty(error),u =>
        nt_choose(X181Output,x198n_enabled() && U32.is_eq(result,1) && U32.is_le(nt_count(NC_Binding,params),8) && x185_late_enabled() && p114t_names(names) && p114t_body_names(body),v =>
          x198n_late(p113e_symbol(name),names,params,ids,x185_late_stmts(body,ids,0)),v =>
          x181_function(p113e_symbol(name),names,body,ids)),u => X181Output{[],error})
