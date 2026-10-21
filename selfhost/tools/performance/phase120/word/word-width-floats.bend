# Optional compatibility module: include only with Phase120 region/float modules.
# Each consumed triple writes exactly one local; invalidate exactly its old lane.
@unsafe
def p120wp_original_so(+head: P113DStmt, rest: List<&2,P113DStmt>, +buffers: List<&2,String>, +params: List<&2,NC_Binding>, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match rest:
    case Con{+second,+more}:
      nt_choose(P111QCode,p113w_pair(head,second) && p113w_room(code),
        u => p114so_stmts(more,buffers,params,ids,p113w_pair_emit(head,ids,code)),
        u => p114so_stmts(Con{second,more},buffers,params,ids,p113w_one(head,params,ids,code)))
    case Nil{}: p113w_one(head,params,ids,code)

@unsafe
def p120wp_original_lane(+head: P113DStmt, rest: List<&2,P113DStmt>, +destination: String, +buffers: List<&2,String>, +params: List<&2,NC_Binding>, +ids: N111Ids, +facts: List<&2,P114FLFact>, +code: P111QCode) -> P111QCode:
  match rest:
    case Con{+second,+more}:
      nt_choose(P111QCode,p113w_pair(head,second) && p113w_room(code),
        u => p114fl_stmts(more,buffers,params,ids,p114fl_remove(facts,destination),p113w_pair_emit(head,ids,code)),
        u => p114fl_stmts(Con{second,more},buffers,params,ids,p114fl_remove(facts,destination),p113w_one(head,params,ids,code)))
    case Nil{}: p113w_one(head,params,ids,code)


@unsafe
def p114so_old(+head: P113DStmt, +rest: List<&2,P113DStmt>, +buffers: List<&2,String>, +params: List<&2,NC_Binding>, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match rest:
    case Con{+second,Con{third,more}}:
      nt_choose(P111QCode,p113w_room(code) && p120wp_triple(head,second,third),
        u => p114so_stmts(more,buffers,params,ids,p120wp_emit(head,second,ids,code)),
        u => p120wp_original_so(head,rest,buffers,params,ids,code))
    case _: p120wp_original_so(head,rest,buffers,params,ids,code)

@unsafe
def p120nr_lane_bin(+head: P113DStmt, +rest: List<&2,P113DStmt>, +destination: String, +buffers: List<&2,String>, +params: List<&2,NC_Binding>, +ids: N111Ids, +facts: List<&2,P114FLFact>, +code: P111QCode) -> P111QCode:
  match rest:
    case Con{+second,Con{third,more}}:
      nt_choose(P111QCode,p113w_room(code) && p120wp_triple(head,second,third),
        u => p114fl_stmts(more,buffers,params,ids,p114fl_remove(facts,destination),p120wp_emit(head,second,ids,code)),
        u => p120wp_original_lane(head,rest,destination,buffers,params,ids,facts,code))
    case _: p120wp_original_lane(head,rest,destination,buffers,params,ids,facts,code)
