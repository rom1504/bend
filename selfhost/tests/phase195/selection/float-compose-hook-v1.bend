@unsafe
def x186_x_emit_frame(+symbol: String, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +nodes: List<&2,X186FloatNode>, +ids: N111Ids, +frame: X181Frame) -> X181Output:
  nt_choose(X181Output,x195fc_enabled(),u => x195fc_frame(symbol,params,setup,nodes,ids,frame),
    u => x195fc_frame_previous(symbol,params,setup,nodes,ids,frame))
