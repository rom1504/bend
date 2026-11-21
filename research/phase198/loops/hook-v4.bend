# Complete-pool, no-spill certificate. Cheap pressure gate rejects truncated pools.
# Failed speculative allocations fall back to exact original selection and coloring.
@unsafe
def x198lp_pool_fits(names: List<&2,String>, +reads: KDef, +slots: KDef, +fuel: U32) -> Bool:
  match names:
    case Nil{}: True{}
    case Con{+name,+rest}:
      nt_choose(Bool,U32.is_gt(da(p111v_get(reads,name)),0) && String.eq(dk(p111v_get(slots,name)),"X181Stack"),
        u => nt_choose(Bool,U32.is_eq(fuel,0),u => False{},u => x198lp_pool_fits(rest,reads,slots,U32.sub(fuel,1))),
        u => x198lp_pool_fits(rest,reads,slots,fuel))

@unsafe
def x198lp_full(names: List<&2,String>, +groups: List<&2,U32>, +bit: U32) -> Bool:
  match names:
    case Nil{}: True{}
    case Con{name,rest}: U32.is_lt(x190_j_home(groups,bit,0),9) && x198lp_full(rest,groups,U32.shl(bit))

@unsafe
def x198lp_original_counted(+frame: X181Frame, params: List<&2,String>, setup: List<&2,P113DStmt>,
    body: List<&2,P113DStmt>, registerBody: List<&2,P113DStmt>, counts: X181ReadCounts) -> X181Frame:
  match frame counts:
    case X181Frame{slots,bytes,calls,words,symbol} X181ReadCounts{reads,names}:
      x190_j_selected(frame,params,setup,body,registerBody,
        x190_l_candidates(nt_reverse(String,names,[]),reads,slots,1,32,missing(),[]))

@unsafe
def x198lp_certified(+frame: X181Frame, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +registerBody: List<&2,P113DStmt>, +counts: X181ReadCounts,
    +names: List<&2,String>, +graph: List<&2,U32>, +groups: List<&2,U32>) -> X181Frame:
  nt_choose(X181Frame,x198lp_full(names,groups,1) && x190_j_valid(names,graph,params,1,groups),
    u => x190_j_install(names,groups,1,frame),
    u => x198lp_original_counted(frame,params,setup,body,registerBody,counts))

@unsafe
def x198lp_graphed(+frame: X181Frame, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +registerBody: List<&2,P113DStmt>, +counts: X181ReadCounts,
    +names: List<&2,String>, +ids: KDef, flow: X190LFlow) -> X181Frame:
  match flow:
    case X190LFlow{live,+graph}:
      x198lp_certified(frame,params,setup,body,registerBody,counts,names,graph,
        x198lp_color(names,graph,params,1,[0,0,0,0,0,0,0,0,0],
          x190_a_body(body,ids,x181_tail_args(frame),x190_a_body(setup,ids,x181_tail_args(frame),missing())),
          x198lp_tail(body,ids,x181_tail_args(frame),missing())))

@unsafe
def x198lp_solved(+frame: X181Frame, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +registerBody: List<&2,P113DStmt>, +counts: X181ReadCounts,
    +names: List<&2,String>, +ids: KDef, +parameters: U32, fixed: X190LFixed) -> X181Frame:
  match fixed:
    case X190LFixed{+header,ready}:
      +env: X190LEnv = X190LEnv{ids,parameters,header,True{}}
      nt_choose(X181Frame,ready,u => x198lp_graphed(frame,params,setup,body,registerBody,counts,names,ids,
        x190_l_incoming(params,x190_l_body(setup,x190_l_body(body,X190LFlow{0,x190_l_zeros(names)},env),env),env)),
        u => x198lp_original_counted(frame,params,setup,body,registerBody,counts))

@unsafe
def x198lp_selected(+frame: X181Frame, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +registerBody: List<&2,P113DStmt>, +counts: X181ReadCounts, candidates: X190LCandidates) -> X181Frame:
  match candidates:
    case X190LCandidates{names,+ids}:
      +parameters = x190_l_names(x181_tail_args(frame),ids)
      x198lp_solved(frame,params,setup,body,registerBody,counts,names,ids,parameters,x190_l_fixed(body,ids,parameters,0,33))

@unsafe
def x190_j_counted(+frame: X181Frame, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +registerBody: List<&2,P113DStmt>, +counts: X181ReadCounts) -> X181Frame:
  match frame counts:
    case X181Frame{+slots,bytes,calls,words,symbol} X181ReadCounts{+reads,+names}:
      nt_choose(X181Frame,x198lp_enabled() && x190_coalescing_enabled() && x198lp_pool_fits(names,reads,slots,32),
        u => x198lp_selected(frame,params,setup,body,registerBody,counts,
          x190_l_candidates(nt_reverse(String,names,[]),x198lp_scores(body,x181_tail_args(frame),reads,reads),slots,1,32,missing(),[])),
        u => x198lp_original_counted(frame,params,setup,body,registerBody,counts))
