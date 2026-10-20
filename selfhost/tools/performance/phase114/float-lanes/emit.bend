type P114FLOperand is Data:
  P114FLOperand{+prefix: String, +lane: String}

@unsafe
def p114fl_operand(+value: N111Value, +facts: List<&2,P114FLFact>, +ids: N111Ids, +site: U32) -> P114FLOperand:
  +known = p114fl_value(value,facts)
  nt_choose(P114FLOperand,String.is_empty(known),
    u => P114FLOperand{p111q_tmp(site) ++ " =w copy " ++ p111q_value(value,ids) ++ "\n" ++
      p111q_tmp(U32.inc(site)) ++ " =s cast " ++ p111q_tmp(site) ++ "\n",p111q_tmp(U32.inc(site))},
    u => P114FLOperand{"",known})

@unsafe
def p114fl_binary(+id: U32, +name: String, +site: U32, left: P114FLOperand, right: P114FLOperand) -> String:
  match left right:
    case P114FLOperand{ap,+a} P114FLOperand{bp,+b}:
      +out = p111q_tmp(U32.add(site,4))
      +bits = p111q_tmp(U32.add(site,5))
      ap ++ bp ++ nt_choose(String,U32.is_lt(id,30),
        u => out ++ " =s " ++ p112fp_binary(id) ++ " " ++ a ++ ", " ++ b ++ "\n" ++
          bits ++ " =w cast " ++ out ++ "\n" ++ p111q_local(name) ++ " =l extuw " ++ bits ++ "\n",
        u => out ++ " =w " ++ p112fp_binary(id) ++ " " ++ a ++ ", " ++ b ++ "\n" ++
          p111q_local(name) ++ " =l extuw " ++ out ++ "\n")

@unsafe
def p114fl_text(+id: U32, +name: String, +left: N111Value, +right: N111Value, +facts: List<&2,P114FLFact>, +ids: N111Ids, +site: U32) -> String:
  nt_choose(String,U32.is_eq(id,23),
    u => p114so_text(id,name,left,right,ids,site),
    u => p114fl_binary(id,name,site,p114fl_operand(left,facts,ids,site),
      p114fl_operand(right,facts,ids,U32.add(site,2))))

@unsafe
def p114fl_emit(id: U32, name: String, left: N111Value, right: N111Value, facts: List<&2,P114FLFact>, ids: N111Ids, code: P111QCode) -> P111QCode:
  match code:
    case P111QCode{chunks,+site,terminal,error}:
      P111QCode{Con{p114fl_text(id,name,left,right,facts,ids,site),chunks},U32.add(site,9),terminal,error}

@unsafe
def p114fl_stmts(body: List<&2,P113DStmt>, +buffers: List<&2,String>, +params: List<&2,NC_Binding>, +ids: N111Ids, +facts: List<&2,P114FLFact>, +code: P111QCode) -> P111QCode:
  match body code:
    case Nil{} _: code
    case Con{+head,+rest} P111QCode{chunks,n,terminal,+error}:
      nt_choose(P111QCode,Bool.not(String.is_empty(error)),u => code,u =>
        nt_choose(P111QCode,terminal,u => p111q_problem("statement follows direct transfer",code),
          u => p114fl_dispatch(head,rest,buffers,params,ids,facts,code,p114so_group(Con{head,rest}))))

@unsafe
def p114fl_dispatch(+head: P113DStmt, +rest: List<&2,P113DStmt>, +buffers: List<&2,String>, +params: List<&2,NC_Binding>, +ids: N111Ids, +facts: List<&2,P114FLFact>, +code: P111QCode, group: P114SOGroup) -> P111QCode:
  match group:
    case P114SOYes{buffer,+name,+id,+left,+right,+more}:
      nt_choose(P111QCode,p114so_member(buffers,buffer) && p114so_room(code),
        u => p114fl_group(more,buffers,params,ids,facts,code,name,id,left,right),
        u => p114so_old(head,rest,buffers,params,ids,code))
    case P114SONo{}: p114fl_other(head,rest,buffers,params,ids,facts,code)

@unsafe
def p114fl_group(+rest: List<&2,P113DStmt>, +buffers: List<&2,String>, +params: List<&2,NC_Binding>, +ids: N111Ids, +facts: List<&2,P114FLFact>, +code: P111QCode, +name: String, +id: U32, +left: N111Value, +right: N111Value) -> P111QCode:
  match code:
    case P111QCode{chunks,+site,terminal,error}:
      p114fl_stmts(rest,buffers,params,ids,p114fl_result(facts,name,id,site),
        p114fl_emit(id,name,left,right,facts,ids,code))

@unsafe
def p114fl_other(+head: P113DStmt, +rest: List<&2,P113DStmt>, +buffers: List<&2,String>, +params: List<&2,NC_Binding>, +ids: N111Ids, +facts: List<&2,P114FLFact>, +code: P111QCode) -> P111QCode:
  match head:
    case P113DScalar{N111Set{destination,N111U64{},N111Local{source}}}:
      p114fl_stmts(rest,buffers,params,ids,p114fl_copy(facts,destination,source),p113w_one(head,params,ids,code))
    case _: p114so_old(head,rest,buffers,params,ids,code)
