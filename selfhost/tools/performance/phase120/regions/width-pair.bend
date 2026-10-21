# Preserve the selected adjacent ring-op/mask emission. The mask predicate
# requires the same destination, so only that word's old float fact is killed.
@unsafe
def p120nr_lane_bin(+head: P113DStmt, rest: List<&2,P113DStmt>, +destination: String, +buffers: List<&2,String>, +params: List<&2,NC_Binding>, +ids: N111Ids, +facts: List<&2,P114FLFact>, +code: P111QCode) -> P111QCode:
  match rest:
    case Con{+second,+more}:
      nt_choose(P111QCode,p113w_pair(head,second) && p113w_room(code),
        u => p114fl_stmts(more,buffers,params,ids,p114fl_remove(facts,destination),p113w_pair_emit(head,ids,code)),
        u => p114fl_stmts(Con{second,more},buffers,params,ids,p114fl_remove(facts,destination),p113w_one(head,params,ids,code)))
    case Nil{}: p113w_one(head,params,ids,code)
