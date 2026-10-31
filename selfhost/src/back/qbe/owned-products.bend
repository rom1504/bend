

@unsafe
def p114so_value_clear(value: N111Value, +buffer: String) -> Bool:
  match value:
    case N111Local{name}: Bool.not(String.eq(name,buffer))
    case _: True{}


@unsafe
def p114so_values_clear(values: List<&2,N111Value>, +buffer: String) -> Bool:
  match values:
    case Nil{}: True{}
    case Con{head,rest}: p114so_value_clear(head,buffer) && p114so_values_clear(rest,buffer)


@unsafe
def p114so_args_clear(args: List<&2,N111Arg>, +buffer: String) -> Bool:
  match args:
    case Nil{}: True{}
    case Con{N111Arg{typ,value},rest}: p114so_value_clear(value,buffer) && p114so_args_clear(rest,buffer)


@unsafe
def p114so_names_clear(names: List<&2,String>, +buffer: String) -> Bool:
  match names:
    case Nil{}: True{}
    case Con{name,rest}: Bool.not(String.eq(name,buffer)) && p114so_names_clear(rest,buffer)


@unsafe
def p114so_scalar_clear(stmt: N111Stmt, +buffer: String) -> Bool:
  match stmt:
    case N111Set{name,typ,value}: Bool.not(String.eq(name,buffer)) && p114so_value_clear(value,buffer)
    case N111Bin{name,typ,op,left,right}: Bool.not(String.eq(name,buffer)) && p114so_value_clear(left,buffer) && p114so_value_clear(right,buffer)
    case N111Call{name,typ,symbol,args}: Bool.not(String.eq(name,buffer)) && p114so_args_clear(args,buffer)
    case N111If{condition,yes,no}: p114so_value_clear(condition,buffer) && p114so_scalars_clear(yes,buffer) && p114so_scalars_clear(no,buffer)
    case N111Return{value}: p114so_value_clear(value,buffer)
    case N111Load{name,typ,base,offset}: Bool.not(String.eq(name,buffer)) && p114so_value_clear(base,buffer)
    case N111Store{typ,base,offset,value}: p114so_value_clear(base,buffer) && p114so_value_clear(value,buffer)
    case N111Offset{name,base,bytes}: Bool.not(String.eq(name,buffer)) && p114so_value_clear(base,buffer) && p114so_value_clear(bytes,buffer)
    case N111Alloca{name,bytes,align}: True{}


@unsafe
def p114so_scalars_clear(body: List<&2,N111Stmt>, +buffer: String) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{head,rest}: p114so_scalar_clear(head,buffer) && p114so_scalars_clear(rest,buffer)


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
def p114so_group(body: List<&2,P113DStmt>) -> P114SOGroup:
  match body:
    case Con{P113DScalar{N111Store{N111U64{},N111Local{+buffer},0,left}},Con{P113DScalar{N111Store{N111U64{},N111Local{other},8,right}},Con{P113DScalar{call},rest}}}:
      nt_choose(P114SOGroup,String.eq(buffer,other),u => p114so_group_call(call,buffer,left,right,2,rest),u => P114SONo{})
    case Con{P113DScalar{N111Store{N111U64{},N111Local{+buffer},0,left}},Con{P113DScalar{call},rest}}:
      p114so_group_call(call,buffer,left,N111Const{0,0},1,rest)
    case _: P114SONo{}


@unsafe
def p114so_stmt_clear(stmt: P113DStmt, +buffer: String) -> Bool:
  match stmt:
    case P113DScalar{scalar}: p114so_scalar_clear(scalar,buffer)
    case P113DIf{condition,yes,no}: p114so_value_clear(condition,buffer) && p114so_audit(yes,buffer) && p114so_audit(no,buffer)
    case P113DCall{names,target,args}: p114so_names_clear(names,buffer) && p114so_values_clear(args,buffer)
    case P113DResult{values}: p114so_values_clear(values,buffer)
    case P113DAgain{values}: p114so_values_clear(values,buffer)


@unsafe
def p114so_audit_group(+body: List<&2,P113DStmt>, +buffer: String, group: P114SOGroup) -> Bool:
  match group:
    case P114SOYes{name,destination,id,left,right,rest}:
      nt_choose(Bool,String.eq(name,buffer),u => p114so_audit(rest,buffer),u => p114so_audit_head(body,buffer))
    case P114SONo{}: p114so_audit_head(body,buffer)


@unsafe
def p114so_audit_head(body: List<&2,P113DStmt>, +buffer: String) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{head,rest}: p114so_stmt_clear(head,buffer) && p114so_audit(rest,buffer)


@unsafe
def p114so_audit(+body: List<&2,P113DStmt>, +buffer: String) -> Bool:
  p114so_audit_group(body,buffer,p114so_group(body))


@unsafe
def p114so_allocations(body: List<&2,P113DStmt>, +acc: List<&2,String>) -> List<&2,String>:
  match body:
    case Nil{}: acc
    case Con{P113DScalar{N111Alloca{name,bytes,align}},rest}:
      p114so_allocations(rest,nt_choose(List<&2,String>,U32.is_ge(bytes,8),u => Con{name,acc},u => acc))
    case Con{P113DIf{condition,yes,no},rest}: p114so_allocations(rest,p114so_allocations(no,p114so_allocations(yes,acc)))
    case Con{stmt,rest}: p114so_allocations(rest,acc)


@unsafe
def p114so_admit(candidates: List<&2,String>, +body: List<&2,P113DStmt>) -> List<&2,String>:
  match candidates:
    case Nil{}: []
    case Con{+name,+rest}: nt_choose(List<&2,String>,p114so_seen(body,name) && p114so_audit(body,name),u => Con{name,p114so_admit(rest,body)},u => p114so_admit(rest,body))


@unsafe
def p114so_buffers(+body: List<&2,P113DStmt>) -> List<&2,String>:
  p114so_admit(p114so_allocations(body,["scratch"]),body)


@unsafe
def p114so_member(names: List<&2,String>, +name: String) -> Bool:
  match names:
    case Nil{}: False{}
    case Con{head,rest}: String.eq(head,name) || p114so_member(rest,name)


@unsafe
def p114so_seen_group(+body: List<&2,P113DStmt>, +buffer: String, group: P114SOGroup) -> Bool:
  match group:
    case P114SOYes{name,destination,id,left,right,rest}:
      String.eq(name,buffer) || p114so_seen(rest,buffer)
    case P114SONo{}: p114so_seen_head(body,buffer)


@unsafe
def p114so_seen_head(body: List<&2,P113DStmt>, +buffer: String) -> Bool:
  match body:
    case Nil{}: False{}
    case Con{P113DIf{condition,yes,no},rest}: p114so_seen(yes,buffer) || p114so_seen(no,buffer) || p114so_seen(rest,buffer)
    case Con{head,rest}: p114so_seen(rest,buffer)


@unsafe
def p114so_seen(+body: List<&2,P113DStmt>, +buffer: String) -> Bool:
  p114so_seen_group(body,buffer,p114so_group(body))

@unsafe
def p114so_text(+id: U32, +name: String, left: N111Value, +right: N111Value, +ids: N111Ids, +n: U32) -> String:
  +a = p111q_tmp(n)
  +af = p111q_tmp(U32.add(n,1))
  +b = p111q_tmp(U32.add(n,2))
  +bf = p111q_tmp(U32.add(n,3))
  +out = p111q_tmp(U32.add(n,4))
  +bits = p111q_tmp(U32.add(n,5))
  +prefix = a ++ " =w copy " ++ p111q_value(left,ids) ++ "\n"
  nt_choose(String,U32.is_eq(id,23),
    u => prefix ++ out ++ " =s uwtof " ++ a ++ "\n" ++ bits ++ " =w cast " ++ out ++ "\n" ++ p111q_local(name) ++ " =l extuw " ++ bits ++ "\n",
    u => prefix ++ af ++ " =s cast " ++ a ++ "\n" ++ b ++ " =w copy " ++ p111q_value(right,ids) ++ "\n" ++ bf ++ " =s cast " ++ b ++ "\n" ++
      nt_choose(String,U32.is_lt(id,30),
        v => out ++ " =s " ++ p112fp_binary(id) ++ " " ++ af ++ ", " ++ bf ++ "\n" ++ bits ++ " =w cast " ++ out ++ "\n" ++ p111q_local(name) ++ " =l extuw " ++ bits ++ "\n",
        v => out ++ " =w " ++ p112fp_binary(id) ++ " " ++ af ++ ", " ++ bf ++ "\n" ++ p111q_local(name) ++ " =l extuw " ++ out ++ "\n"))


@unsafe
def p114so_emit(id: U32, name: String, left: N111Value, right: N111Value, ids: N111Ids, code: P111QCode) -> P111QCode:
  match code:
    case P111QCode{chunks,+n,terminal,error}:
      P111QCode{Con{p114so_text(id,name,left,right,ids,n),chunks},U32.add(n,9),terminal,error}


@unsafe
def p114so_room(code: P111QCode) -> Bool:
  match code:
    case P111QCode{chunks,next,terminal,error}: U32.is_le(next,4294967286)

# Whole-function buffers are passed only from the private-function entry.
# Nonmatching statements retain the selected word-width/Boolean emitters.

@unsafe
def p114so_stmts(body: List<&2,P113DStmt>, +buffers: List<&2,String>, +params: List<&2,NC_Binding>, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match body code:
    case Nil{} _: code
    case Con{+head,+rest} P111QCode{chunks,n,terminal,+error}:
      nt_choose(P111QCode,String.is_empty(error),u =>
        nt_choose(P111QCode,terminal,u => p111q_problem("statement follows direct transfer",code),
          u => p114so_dispatch(head,rest,buffers,params,ids,code,p114so_group(Con{head,rest}))),u => code)


@unsafe
def p114so_dispatch(+head: P113DStmt, +rest: List<&2,P113DStmt>, +buffers: List<&2,String>, +params: List<&2,NC_Binding>, +ids: N111Ids, +code: P111QCode, group: P114SOGroup) -> P111QCode:
  match group:
    case P114SOYes{buffer,name,id,left,right,more}:
      nt_choose(P111QCode,p114so_member(buffers,buffer) && p114so_room(code),
        u => p114so_stmts(more,buffers,params,ids,p114so_emit(id,name,left,right,ids,code)),
        u => p114so_old(head,rest,buffers,params,ids,code))
    case P114SONo{}: p114so_old(head,rest,buffers,params,ids,code)


@unsafe
def p114so_old(+head: P113DStmt, rest: List<&2,P113DStmt>, +buffers: List<&2,String>, +params: List<&2,NC_Binding>, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match rest:
    case Con{+second,+more}:
      nt_choose(P111QCode,p113w_pair(head,second) && p113w_room(code),
        u => p114so_stmts(more,buffers,params,ids,p113w_pair_emit(head,ids,code)),
        u => p114so_stmts(Con{second,more},buffers,params,ids,p113w_one(head,params,ids,code)))
    case Nil{}: p113w_one(head,params,ids,code)

# This first slice does not rewrite nested branch rendering. The original
# p113e_if and every selected public/runtime/recursive hook stay untouched.

@unsafe
def p114so_private(function: P113DFunction, +ids: N111Ids) -> String:
  match function:
    case P113DFunction{name,+params,+result,public,+body}:
      +buffers = p114so_buffers(body)
      +allocas = p113e_allocas(body,["%v_scratch =l alloc8 2048\n"])
      +allocas = nt_choose(List<&2,String>,p113e_multi(body),u => Con{"%p113_results =l alloc8 64\n",allocas},u => allocas)
      "function l $" ++ p113e_symbol(name) ++ "(" ++ p113e_formals(params,nt_choose(String,U32.is_eq(result,1),u => "l %state",u => "l %state, l %p113_result_out")) ++ ") {\n@entry\n" ++
        p144e_body_tail(p114so_stmts(body,buffers,params,ids,P111QCode{Con{"@p113_loop\n",Con{"jmp @p113_loop\n",allocas}},0,False{},""}),"}\n")


@unsafe
def p114fl_find(facts: List<&2,P114FLFact>, +word: String) -> String:
  match facts:
    case Nil{}: ""
    case Con{P114FLFact{name,lane},rest}:
      nt_choose(String,String.eq(name,word),u => lane,u => p114fl_find(rest,word))


@unsafe
def p114fl_value(value: N111Value, +facts: List<&2,P114FLFact>) -> String:
  match value:
    case N111Local{name}: p114fl_find(facts,name)
    case _: ""


@unsafe
def p114fl_remove(facts: List<&2,P114FLFact>, +word: String) -> List<&2,P114FLFact>:
  match facts:
    case Nil{}: []
    case Con{+fact,+rest}: p114fl_remove_head(fact,rest,word)


@unsafe
def p114fl_remove_head(fact: P114FLFact, +rest: List<&2,P114FLFact>, +word: String) -> List<&2,P114FLFact>:
  match fact:
    case P114FLFact{+name,+lane}:
      nt_choose(List<&2,P114FLFact>,String.eq(name,word),
        u => p114fl_remove(rest,word),u => Con{P114FLFact{name,lane},p114fl_remove(rest,word)})


@unsafe
def p114fl_limit(facts: List<&2,P114FLFact>, +left: U32) -> List<&2,P114FLFact>:
  match facts:
    case Nil{}: []
    case Con{head,rest}:
      nt_choose(List<&2,P114FLFact>,U32.is_eq(left,0),u => [],
        u => Con{head,p114fl_limit(rest,U32.sub(left,1))})


@unsafe
def p114fl_bind(+facts: List<&2,P114FLFact>, +word: String, +lane: String) -> List<&2,P114FLFact>:
  +remaining = p114fl_remove(facts,word)
  nt_choose(List<&2,P114FLFact>,String.is_empty(lane),u => remaining,
    u => Con{P114FLFact{word,lane},p114fl_limit(remaining,63)})

@unsafe
def p114fl_copy(+facts: List<&2,P114FLFact>, +destination: String, +source: String) -> List<&2,P114FLFact>:
  p114fl_bind(facts,destination,p114fl_find(facts,source))


@unsafe
def p114fl_result(+facts: List<&2,P114FLFact>, +name: String, +id: U32, +site: U32) -> List<&2,P114FLFact>:
  p114fl_bind(facts,name,nt_choose(String,U32.is_eq(id,23) || U32.is_eq(id,36) || (U32.is_ge(id,26) && U32.is_le(id,29)),
    u => p111q_tmp(U32.add(site,4)),u => ""))


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
  nt_choose(String,U32.is_eq(id,25),u => p111q_tmp(site) ++ " =w copy " ++ p111q_value(left,ids) ++ "\n" ++
    p111q_local(name) ++ " =l extuw " ++ p111q_tmp(site) ++ "\n",u =>
  nt_choose(String,U32.is_eq(id,36),u => p126l_sqrt(name,site,p114fl_operand(left,facts,ids,site)),u =>
  nt_choose(String,U32.is_eq(id,58),u => p126l_to_u32(name,site,p114fl_operand(left,facts,ids,site)),u =>
    nt_choose(String,U32.is_eq(id,23),u => p114so_text(id,name,left,right,ids,site),u =>
      p114fl_binary(id,name,site,p114fl_operand(left,facts,ids,site),p114fl_operand(right,facts,ids,U32.add(site,2)))))))



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
      nt_choose(P111QCode,String.is_empty(error),u =>
        nt_choose(P111QCode,terminal,u => p111q_problem("statement follows direct transfer",code),
          u => p114fl_dispatch(head,rest,buffers,params,ids,facts,code,p114so_group(Con{head,rest}))),u => code)


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
