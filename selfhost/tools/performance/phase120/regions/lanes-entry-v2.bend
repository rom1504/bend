# Copies retain exact bits; pure local definitions kill only their destination.
# All other barriers still go through the frozen reset path. No reassociation.
@unsafe
def p114fl_other(+head: P113DStmt, +rest: List<&2,P113DStmt>, +buffers: List<&2,String>, +params: List<&2,NC_Binding>, +ids: N111Ids, +facts: List<&2,P114FLFact>, +code: P111QCode) -> P111QCode:
  match head:
    case P113DScalar{N111Set{destination,N111U64{},N111Local{source}}}:
      p114fl_stmts(rest,buffers,params,ids,p114fl_copy(facts,destination,source),p113w_one(head,params,ids,code))
    case P113DScalar{N111Set{destination,typ,value}}:
      p114fl_stmts(rest,buffers,params,ids,p114fl_remove(facts,destination),p113w_one(head,params,ids,code))
    case P113DScalar{N111Bin{destination,typ,op,left,right}}:
      p120nr_lane_bin(head,rest,destination,buffers,params,ids,facts,code)
    case P113DScalar{N111Alloca{destination,bytes,align}}:
      p114fl_stmts(rest,buffers,params,ids,p114fl_remove(facts,destination),p113w_one(head,params,ids,code))
    case P113DIf{condition,yes,no}:
      p114fl_stmts(rest,buffers,params,ids,[],p120nr_lane_branch(condition,yes,no,buffers,params,ids,facts,code))
    case _: p114so_old(head,rest,buffers,params,ids,code)
