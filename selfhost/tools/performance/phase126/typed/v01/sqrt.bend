# The runtime computes (f32)sqrt((double)input). Preserve that operation exactly;
# this is not sqrtf, reassociation, or a fast-math approximation.
@unsafe
def p114so_group_call(stmt: N111Stmt, +buffer: String, +left: N111Value, +right: N111Value, +count: U32, +rest: List<&2,P113DStmt>) -> P114SOGroup:
  match stmt:
    case N111Call{+name,N111U64{},symbol,[N111Arg{N111Ptr{},N111Local{state}},N111Arg{N111U32{},N111Const{+id,0}},N111Arg{N111Ptr{},N111Local{input}},N111Arg{N111U32{},N111Const{argc,0}}]}:
      nt_choose(P114SOGroup,String.eq(symbol,"p111_rt_op") && String.eq(state,"state") &&
        Bool.not(String.eq(buffer,"state")) && String.eq(input,buffer) && U32.is_eq(count,argc) &&
        (p112fp_supported(id,count) || (U32.is_eq(id,36) && U32.is_eq(count,1))) && Bool.not(String.eq(name,buffer)) &&
        p114so_value_clear(left,buffer) && p114so_value_clear(right,buffer),
        u => P114SOYes{buffer,name,id,left,right,rest},u => P114SONo{})
    case _: P114SONo{}

@unsafe
def p126t_sqrt(+name: String, +site: U32, operand: P114FLOperand) -> String:
  match operand:
    case P114FLOperand{prefix,lane}:
      +wide = p111q_tmp(U32.add(site,2))
      +root = p111q_tmp(U32.add(site,3))
      +out = p111q_tmp(U32.add(site,4))
      +bits = p111q_tmp(U32.add(site,5))
      prefix ++ wide ++ " =d exts " ++ lane ++ "\n" ++ root ++ " =d call $sqrt(d " ++ wide ++ ")\n" ++
        out ++ " =s truncd " ++ root ++ "\n" ++ bits ++ " =w cast " ++ out ++ "\n" ++ p111q_local(name) ++ " =l extuw " ++ bits ++ "\n"

@unsafe
def p114fl_text(+id: U32, +name: String, +left: N111Value, +right: N111Value, +facts: List<&2,P114FLFact>, +ids: N111Ids, +site: U32) -> String:
  nt_choose(String,U32.is_eq(id,36),u => p126t_sqrt(name,site,p114fl_operand(left,facts,ids,site)),u =>
    nt_choose(String,U32.is_eq(id,23),u => p114so_text(id,name,left,right,ids,site),u =>
      p114fl_binary(id,name,site,p114fl_operand(left,facts,ids,site),p114fl_operand(right,facts,ids,U32.add(site,2)))))

@unsafe
def p114fl_result(+facts: List<&2,P114FLFact>, +name: String, +id: U32, +site: U32) -> List<&2,P114FLFact>:
  p114fl_bind(facts,name,nt_choose(String,U32.is_eq(id,23) || U32.is_eq(id,36) || (U32.is_ge(id,26) && U32.is_le(id,29)),
    u => p111q_tmp(U32.add(site,4)),u => ""))
