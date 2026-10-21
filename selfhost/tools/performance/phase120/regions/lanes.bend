# Branch-local facts describe immutable QBE s temporaries, never memory or types.
# Both arms inherit only dominating facts. No arm-produced fact escapes the join.
@unsafe
def p120nr_lane_if(+condition: N111Value, +yes: List<&2,P113DStmt>, +no: List<&2,P113DStmt>, +buffers: List<&2,String>, +params: List<&2,NC_Binding>, +ids: N111Ids, +facts: List<&2,P114FLFact>, code: P111QCode) -> P111QCode:
  match code:
    case P111QCode{chunks,+site,terminal,error}:
      p120nr_lane_yes(site,no,buffers,params,ids,facts,p114fl_stmts(yes,buffers,params,ids,facts,
        P111QCode{Con{p111q_label(site) ++ "\n",Con{"jnz " ++ p111q_value(condition,ids) ++ ", " ++ p111q_label(site) ++ ", " ++ p111q_label(U32.inc(site)) ++ "\n",chunks}},U32.add(site,3),False{},error}))

@unsafe
def p120nr_lane_yes(+label: U32, +no: List<&2,P113DStmt>, +buffers: List<&2,String>, +params: List<&2,NC_Binding>, +ids: N111Ids, +facts: List<&2,P114FLFact>, yes: P111QCode) -> P111QCode:
  match yes:
    case P111QCode{chunks,next,+terminal,error}:
      +prefix = nt_choose(List<&2,String>,terminal,u => chunks,u => Con{"jmp " ++ p111q_label(U32.add(label,2)) ++ "\n",chunks})
      p111q_if_done(label,terminal,p114fl_stmts(no,buffers,params,ids,facts,
        P111QCode{Con{p111q_label(U32.inc(label)) ++ "\n",prefix},next,False{},error}))

@unsafe
def p120nr_lane_branch(+condition: N111Value, +yes: List<&2,P113DStmt>, +no: List<&2,P113DStmt>, +buffers: List<&2,String>, +params: List<&2,NC_Binding>, +ids: N111Ids, +facts: List<&2,P114FLFact>, +code: P111QCode) -> P111QCode:
  +diamond = p113bq_direct(yes,no)
  nt_choose(P111QCode,p113bq_ready(diamond,code),u => p113bq_emit(condition,diamond,ids,code),
    u => p120nr_lane_if(condition,yes,no,buffers,params,ids,facts,code))
