# Exact selected local primitive expansion; no parameter or call-ABI facts.
@unsafe
def p114so_group_call(stmt: N111Stmt, +buffer: String, +left: N111Value, +right: N111Value, +count: U32, +rest: List<&2,P113DStmt>) -> P114SOGroup:
  match stmt:
    case N111Call{+name,N111U64{},symbol,[N111Arg{N111Ptr{},N111Local{state}},N111Arg{N111U32{},N111Const{+id,0}},N111Arg{N111Ptr{},N111Local{input}},N111Arg{N111U32{},N111Const{argc,0}}]}:
      nt_choose(P114SOGroup,String.eq(symbol,"p111_rt_op") && String.eq(state,"state") &&
        Bool.not(String.eq(buffer,"state")) && String.eq(input,buffer) && U32.is_eq(count,argc) &&
        (p112fp_supported(id,count) || ((U32.is_eq(id,25) || U32.is_eq(id,36) || U32.is_eq(id,58)) && U32.is_eq(count,1))) && Bool.not(String.eq(name,buffer)) &&
        p114so_value_clear(left,buffer) && p114so_value_clear(right,buffer),
        u => P114SOYes{buffer,name,id,left,right,rest},u => P114SONo{})
    case _: P114SONo{}


@unsafe
def p126l_sqrt(+name: String, +site: U32, operand: P114FLOperand) -> String:
  match operand:
    case P114FLOperand{prefix,lane}:
      +wide = p111q_tmp(U32.add(site,2))
      +root = p111q_tmp(U32.add(site,3))
      +out = p111q_tmp(U32.add(site,4))
      +bits = p111q_tmp(U32.add(site,5))
      prefix ++ wide ++ " =d exts " ++ lane ++ "\n" ++ root ++ " =d call $sqrt(d " ++ wide ++ ")\n" ++
        out ++ " =s truncd " ++ root ++ "\n" ++ bits ++ " =w cast " ++ out ++ "\n" ++ p111q_local(name) ++ " =l extuw " ++ bits ++ "\n"


# Exact p118f_to_u32 operation sequence with the proved explicit operand.
# Input lane reconstruction consumes slots 0..1; values use 2..5 and branch
# labels 0..2. The unchanged p114fl_emit reserves nine fresh slots.
@unsafe
def p126l_to_u32(+name: String, +site: U32, operand: P114FLOperand) -> String:
  match operand:
    case P114FLOperand{prefix,+value}:
      +nonnegative = p111q_tmp(U32.add(site,2))
      +below_limit = p111q_tmp(U32.add(site,3))
      +valid = p111q_tmp(U32.add(site,4))
      +answer = p111q_tmp(U32.add(site,5))
      +target = p111q_local(name)
      +yes = p111q_label(site)
      +no = p111q_label(U32.inc(site))
      +done = p111q_label(U32.add(site,2))
      prefix ++ nonnegative ++ " =w cges " ++ value ++ ", s_0\n" ++
        below_limit ++ " =w clts " ++ value ++ ", s_4294967296\n" ++
        valid ++ " =w and " ++ nonnegative ++ ", " ++ below_limit ++ "\n" ++
        "jnz " ++ valid ++ ", " ++ yes ++ ", " ++ no ++ "\n" ++ yes ++ "\n" ++
        answer ++ " =w stoui " ++ value ++ "\n" ++
        target ++ " =l extuw " ++ answer ++ "\n" ++
        "jmp " ++ done ++ "\n" ++ no ++ "\n" ++
        target ++ " =l copy 0\n" ++
        "jmp " ++ done ++ "\n" ++ done ++ "\n"


@unsafe
def p114fl_text(+id: U32, +name: String, +left: N111Value, +right: N111Value, +facts: List<&2,P114FLFact>, +ids: N111Ids, +site: U32) -> String:
  nt_choose(String,U32.is_eq(id,25),u => p111q_tmp(site) ++ " =w copy " ++ p111q_value(left,ids) ++ "\n" ++
    p111q_local(name) ++ " =l extuw " ++ p111q_tmp(site) ++ "\n",u =>
  nt_choose(String,U32.is_eq(id,36),u => p126l_sqrt(name,site,p114fl_operand(left,facts,ids,site)),u =>
  nt_choose(String,U32.is_eq(id,58),u => p126l_to_u32(name,site,p114fl_operand(left,facts,ids,site)),u =>
    nt_choose(String,U32.is_eq(id,23),u => p114so_text(id,name,left,right,ids,site),u =>
      p114fl_binary(id,name,site,p114fl_operand(left,facts,ids,site),p114fl_operand(right,facts,ids,U32.add(site,2)))))))


@unsafe
def p114fl_result(+facts: List<&2,P114FLFact>, +name: String, +id: U32, +site: U32) -> List<&2,P114FLFact>:
  p114fl_bind(facts,name,nt_choose(String,U32.is_eq(id,23) || U32.is_eq(id,36) || (U32.is_ge(id,26) && U32.is_le(id,29)),
    u => p111q_tmp(U32.add(site,4)),u => ""))


@unsafe
def p114fl_bind(+facts: List<&2,P114FLFact>, +word: String, +lane: String) -> List<&2,P114FLFact>:
  +remaining = p114fl_remove(facts,word)
  nt_choose(List<&2,P114FLFact>,String.is_empty(lane),u => remaining,
    u => Con{P114FLFact{word,lane},p114fl_limit(remaining,63)})
