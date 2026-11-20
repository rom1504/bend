@unsafe
def x185_function_place(+symbol: String, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +ids: N111Ids) -> X181Output:
  x186_function_memory(symbol,params,setup,x185_prepare_body(params,setup,
    x185_scratch_body(params,setup,x195rem_body(params,setup,body))),ids)
