@unsafe
def x185_function_copied(+symbol: String, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +ids: N111Ids) -> X181Output:
  nt_choose(X181Output,String.starts_with(symbol,"p113d_FID_"),
    u => x198_perm_selected(x198_perm_pick(params,setup,body),symbol,params,setup,body,ids),
    u => x186_float_function(symbol,params,setup,body,ids))
