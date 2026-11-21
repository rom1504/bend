@unsafe
def x191_function_saved(+symbol: String, +setup: List<&2,P113DStmt>, +body: List<&2,P113DStmt>,
    facts: X190BranchFacts, +ids: N111Ids, +frame: X181Frame) -> X181Output:
  x198fr_final(symbol,x190_stmts(body,facts,ids,frame,x181_add(x188_label(x181_loop_label(frame)),
    x181_stmts(setup,ids,frame,X181Code{[x181_prologue(frame)],0,False{},""}))),setup,body,frame)
