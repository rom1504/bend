# A scalar Nat-to-U32 group has no runtime effect: preserve exactly its low word.
# It is a low32 observation but is not itself evidence of useful float transport.
@unsafe
def p114so_group_call(stmt: N111Stmt, +buffer: String, +left: N111Value, +right: N111Value, +count: U32, +rest: List<&2,P113DStmt>) -> P114SOGroup:
  match stmt:
    case N111Call{+name,N111U64{},symbol,[N111Arg{N111Ptr{},N111Local{state}},N111Arg{N111U32{},N111Const{+id,0}},N111Arg{N111Ptr{},N111Local{input}},N111Arg{N111U32{},N111Const{argc,0}}]}:
      nt_choose(P114SOGroup,String.eq(symbol,"p111_rt_op") && String.eq(state,"state") &&
        Bool.not(String.eq(buffer,"state")) && String.eq(input,buffer) && U32.is_eq(count,argc) &&
        (p112fp_supported(id,count) || ((U32.is_eq(id,25) || U32.is_eq(id,36)) && U32.is_eq(count,1))) && Bool.not(String.eq(name,buffer)) &&
        p114so_value_clear(left,buffer) && p114so_value_clear(right,buffer),
        u => P114SOYes{buffer,name,id,left,right,rest},u => P114SONo{})
    case _: P114SONo{}

@unsafe
def p114fl_text(+id: U32, +name: String, +left: N111Value, +right: N111Value, +facts: List<&2,P114FLFact>, +ids: N111Ids, +site: U32) -> String:
  nt_choose(String,U32.is_eq(id,25),u => p111q_tmp(site) ++ " =w copy " ++ p111q_value(left,ids) ++ "\n" ++
    p111q_local(name) ++ " =l extuw " ++ p111q_tmp(site) ++ "\n",u =>
  nt_choose(String,U32.is_eq(id,36),u => p126t_sqrt(name,site,p114fl_operand(left,facts,ids,site)),u =>
    nt_choose(String,U32.is_eq(id,23),u => p114so_text(id,name,left,right,ids,site),u =>
      p114fl_binary(id,name,site,p114fl_operand(left,facts,ids,site),p114fl_operand(right,facts,ids,U32.add(site,2))))))

@unsafe
def p126a_group(group: P114SOGroup, +body: List<&2,P113DStmt>, +params: List<&2,NC_Binding>, +plans: List<&2,P126TPlan>, +buffers: List<&2,String>, +graph: KDef) -> KDef:
  match group:
    case P114SONo{}: p126a_head(body,params,plans,buffers,graph)
    case P114SOYes{buffer,name,+id,+left,+right,+rest}:
      nt_choose(KDef,p114so_member(buffers,buffer),
        u => p126a_body(rest,params,plans,buffers,p126a_mark(right,p126a_mark(left,graph,0,
          nt_choose(U32,U32.is_eq(id,25),v => 0,v => 1)),0,nt_choose(U32,U32.is_eq(id,25),v => 0,v => 1))),
        u => p126a_head(body,params,plans,buffers,graph))
