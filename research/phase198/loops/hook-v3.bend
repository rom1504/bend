@unsafe
def x198lp_previous(+frame: X181Frame, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, registerBody: List<&2,P113DStmt>, +names: List<&2,String>, +ids: KDef, flow: X190LFlow) -> X181Frame:
  match flow:
    case X190LFlow{live,+graph}:
      x190_j_checked(frame,params,setup,body,registerBody,names,graph,
        nt_choose(List<&2,U32>,x190_coalescing_enabled(),u =>
          x190_a_color(names,graph,params,1,[0,0,0,0,0,0,0,0,0],
            x190_a_body(body,ids,x181_tail_args(frame),x190_a_body(setup,ids,x181_tail_args(frame),missing()))),
          u => x190_j_color(names,graph,params,1,[0,0,0,0,0,0,0,0,0])))


@unsafe
def x190_j_graphed(+frame: X181Frame, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +registerBody: List<&2,P113DStmt>, +names: List<&2,String>, +ids: KDef, +flow: X190LFlow) -> X181Frame:
  match flow:
    case X190LFlow{live,+graph}:
      nt_choose(X181Frame,x198lp_enabled() && x190_coalescing_enabled(),u =>
        x190_j_checked(frame,params,setup,body,registerBody,names,graph,
          x198lp_color(names,graph,params,1,[0,0,0,0,0,0,0,0,0],
            x190_a_body(body,ids,x181_tail_args(frame),x190_a_body(setup,ids,x181_tail_args(frame),missing())),
            x198lp_tail(body,ids,x181_tail_args(frame),missing()))),
        u => x198lp_previous(frame,params,setup,body,registerBody,names,ids,flow))
