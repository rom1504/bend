# Optional experiment only: use admission diagnostics before selecting this
# final override. Source15's default 192/512 policy remains unchanged.
@unsafe
def p113i_eligible(function: P113DFunction) -> Bool:
  match function:
    case P113DFunction{name,+params,+result,public,+body}:
      U32.is_ge(result,1) && U32.is_le(result,8) && U32.is_le(nt_count(NC_Binding,params),32) &&
        U32.is_le(p113i_size(body),384) && U32.is_le(p113i_stack(body),8192) &&
        p113i_params(params) && p113j_returns(body,result)

@unsafe
def p113i_function(+function: P113DFunction, +table: P113ITable) -> P113DFunction:
  match function:
    case P113DFunction{+name,+params,+result,+public,+body}:
      nt_choose(P113DFunction,p113i_params(params) && p113i_clean(body) && U32.is_le(p113i_size(body),2048),
        u => p113i_function_done(function,name,params,result,public,p113i_scan(body,table,0,1024)),u => function)
