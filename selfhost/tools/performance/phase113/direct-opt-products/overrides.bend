# Optional final overrides after the product inliner profile. Base source13
# remains unchanged. The original pre/post verifier is still mandatory.
@unsafe
def p113i_eligible(function: P113DFunction) -> Bool:
  match function:
    case P113DFunction{name,+params,+result,public,+body}:
      U32.is_ge(result,1) && U32.is_le(result,8) && U32.is_le(nt_count(NC_Binding,params),32) &&
        U32.is_le(p113i_size(body),192) && U32.is_le(p113i_stack(body),8192) &&
        p113i_params(params) && p113j_returns(body,result)

@unsafe
def p113i_function(+function: P113DFunction, +table: P113ITable) -> P113DFunction:
  match function:
    case P113DFunction{+name,+params,+result,+public,+body}:
      nt_choose(P113DFunction,p113i_params(params) && p113i_clean(body) && U32.is_le(p113i_size(body),2048),
        u => p113i_function_done(function,name,params,result,public,p113i_scan(body,table,0,512)),u => function)

@unsafe
def p113i_scan_stmt(+stmt: P113DStmt, +rest: List<&2,P113DStmt>, +table: P113ITable, +site: U32, +budget: U32) -> P113IScan:
  match stmt:
    case P113DCall{destinations,+target,args}:
      nt_choose(P113IScan,U32.is_lt(site,16),
        u => p113j_scan_found(stmt,rest,table,site,budget,destinations,args,p113i_get(table,target,index_hash(target,2166136261),0)),
        u => p113i_prepend(stmt,p113i_scan(rest,table,site,budget)))
    case _: p113i_prepend(stmt,p113i_scan(rest,table,site,budget))

@unsafe
def p113p_array_call(symbol: String, args: List<&2,N111Arg>) -> Bool:
  p113j_array_call(symbol,args)
