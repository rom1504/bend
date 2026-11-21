@unsafe
def x204_live_header(flow: X190LFlow) -> X190LFixed:
  match flow:
    case X190LFlow{live,graph}: X190LFixed{live,True{}}

@unsafe
def x204_for_collection(+setup: List<&2,P113DStmt>, +body: List<&2,P113DStmt>, +ids: KDef,
    +parameters: U32) -> X190LFixed:
  nt_choose(X190LFixed,x190_register_loop(body) || x190_register_loop(setup),
    u => x204_live_header(x190_l_body(body,X190LFlow{0,[]},X190LEnv{ids,parameters,0,False{}})),
    u => X190LFixed{0,True{}})
