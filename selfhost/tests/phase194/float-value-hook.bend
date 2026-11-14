@unsafe
def x186_float_function(+symbol: String, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +ids: N111Ids) -> X181Output:
  nt_choose(X181Output,x186_float_values_enabled() && x185_float_enabled() &&
      U32.is_lt(p113i_add(p113i_size(setup),p113i_size(body)),4096),
    u => nt_choose(X181Output,x186_f_has_body(body),
      v => x194fv_place(symbol,params,setup,x186_f_ready(params,setup,
        x186_f_plan(body,x186_f_buffers(params,setup,body),[])),ids),
      v => x186_f_ordinary(symbol,params,setup,body,ids)),
    u => x186_f_ordinary(symbol,params,setup,body,ids))
