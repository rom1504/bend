# Exact Phase125 fallback, plus a post-verification table projection.
@unsafe
def p126s_prior_function(+function: P113DFunction, +ids: N111Ids, +heap_min: U32) -> String:
  match function:
    case P113DFunction{name,+params,result,public,+body}:
      +count = nt_count(NC_Binding,params)
      nt_choose(String,U32.is_eq(p113a_count_body(body,0),0),u => p113e_private(function,ids),u =>
        nt_choose(String,U32.is_gt(count,16) || Bool.not(p117h_params_clean(params)),u => p113ah_private(p113a_function(function,heap_min),ids),u =>
          p117h_finish(function,ids,heap_min,p117h_walk(body,count,
            P117HScan{p117h_seed(params,1,missing()),missing(),U32.sub(U32.shln(1,U32.to_nat(count)),1),0,False{},8192,0,missing()}))))

@unsafe
def p113ah_function(+function: P113DFunction, +ids: N111Ids, +heap_min: U32) -> String:
  +table = p126s_emit(function)
  nt_choose(String,String.is_empty(table),u => p126s_prior_function(function,ids,heap_min),u => table)
