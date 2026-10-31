
# Preserve the selected emitter's two-phase full-word backedge. Its temporary
# spelling is intentionally retained to allow byte-exact QBE comparison.

@unsafe
def p126l_snapshot(params: List<&2,NC_Binding>, values: List<&2,N111Value>, +ids: N111Ids, +index: U32, +code: P111QCode) -> P111QCode:
  match params values code:
    case Nil{} Nil{} _: code
    case Con{NC_Binding{id,word,kind},rest} Con{value,more} P111QCode{chunks,site,terminal,error}:
      p126l_snapshot(rest,more,ids,U32.inc(index),
        p111q_line("%p126_next_" ++ U32.show(index) ++ " =l copy " ++ p111q_value(value,ids) ++ "\n",code))
    case _ _ _: p111q_problem("typed backedge arity",code)


@unsafe
def p126l_moves(params: List<&2,NC_Binding>, +index: U32, +code: P111QCode) -> P111QCode:
  match params:
    case Nil{}: p113e_again_end(code)
    case Con{NC_Binding{id,word,kind},rest}:
      p126l_moves(rest,U32.inc(index),p111q_line(
        p111q_local(word) ++ " =l copy %p126_next_" ++ U32.show(index) ++ "\n",code))

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
def p126l_forget(names: List<&2,String>, +facts: List<&2,P114FLFact>) -> List<&2,P114FLFact>:
  match names:
    case Nil{}: facts
    case Con{name,rest}: p126l_forget(rest,p114fl_remove(facts,name))



@unsafe
def p126l_kill_scalar(stmt: N111Stmt, +facts: List<&2,P114FLFact>) -> List<&2,P114FLFact>:
  match stmt:
    case N111Set{name,typ,value}: p114fl_remove(facts,name)
    case N111Bin{name,typ,op,a,b}: p114fl_remove(facts,name)
    case N111Call{name,typ,symbol,args}: p114fl_remove(facts,name)
    case N111Load{name,typ,base,offset}: p114fl_remove(facts,name)
    case N111Offset{name,base,bytes}: p114fl_remove(facts,name)
    case N111Alloca{name,bytes,align}: p114fl_remove(facts,name)
    case N111If{condition,yes,no}: p126l_kill_scalars(no,p126l_kill_scalars(yes,facts))
    case _: facts



@unsafe
def p126l_kill_scalars(body: List<&2,N111Stmt>, facts: List<&2,P114FLFact>) -> List<&2,P114FLFact>:
  match body:
    case Nil{}: facts
    case Con{head,rest}: p126l_kill_scalars(rest,p126l_kill_scalar(head,facts))



@unsafe
def p126l_kill(body: List<&2,P113DStmt>, +facts: List<&2,P114FLFact>) -> List<&2,P114FLFact>:
  match body:
    case Nil{}: facts
    case Con{P113DScalar{scalar},rest}: p126l_kill(rest,p126l_kill_scalar(scalar,facts))
    case Con{P113DIf{condition,yes,no},rest}: p126l_kill(rest,p126l_kill(no,p126l_kill(yes,facts)))
    case Con{P113DCall{names,target,args},rest}: p126l_kill(rest,p126l_forget(names,facts))
    case Con{P113DAgain{values},rest}: []
    case Con{P113DResult{values},rest}: facts



@unsafe
def p126l_scalar_facts(stmt: N111Stmt, +facts: List<&2,P114FLFact>) -> List<&2,P114FLFact>:
  match stmt:
    case N111Set{name,N111U64{},N111Local{source}}: p114fl_copy(facts,name,source)
    case _: p126l_kill_scalar(stmt,facts)

@unsafe
def p126l_stmts(body: List<&2,P113DStmt>, +ctx: P126LCtx, +facts: List<&2,P114FLFact>, +code: P111QCode) -> P111QCode:
  match body code:
    case Nil{} _: code
    case Con{+head,+rest} P111QCode{chunks,site,terminal,+error}:
      nt_choose(P111QCode,String.is_empty(error),u =>
        nt_choose(P111QCode,terminal,u => p111q_problem("typed statement after transfer",code),
          u => p126l_dispatch(head,rest,ctx,facts,code,p114so_group(Con{head,rest}))),u => code)



@unsafe
def p126l_dispatch(+head: P113DStmt, +rest: List<&2,P113DStmt>, +ctx: P126LCtx, +facts: List<&2,P114FLFact>, +code: P111QCode, group: P114SOGroup) -> P111QCode:
  match ctx code group:
    case P126LCtx{params,+buffers,+ids} P111QCode{chunks,+site,terminal,error} P114SOYes{buffer,+name,+id,+left,+right,+more}:
      nt_choose(P111QCode,p114so_member(buffers,buffer) && p114so_room(code),
        u => p126l_stmts(more,ctx,p114fl_result(facts,name,id,site),p114fl_emit(id,name,left,right,facts,ids,code)),
        u => p126l_other(head,rest,ctx,facts,code))
    case _ _ _: p126l_other(head,rest,ctx,facts,code)



@unsafe
def p126l_other(+head: P113DStmt, +rest: List<&2,P113DStmt>, +ctx: P126LCtx, +facts: List<&2,P114FLFact>, +code: P111QCode) -> P111QCode:
  match head ctx:
    case P113DIf{condition,+yes,+no} _:
      p126l_stmts(rest,ctx,p126l_kill(no,p126l_kill(yes,facts)),p126l_if(condition,yes,no,ctx,facts,code))
    case P113DCall{+destinations,target,values} P126LCtx{params,buffers,ids}:
      p126l_stmts(rest,ctx,p126l_forget(destinations,facts),p113e_call_emit(destinations,target,values,ids,code))
    case P113DAgain{values} P126LCtx{+params,buffers,ids}:
      p126l_moves(params,0,p126l_snapshot(params,values,ids,0,code))
    case P113DScalar{scalar} _:
      p126l_width(head,rest,ctx,facts,code)
    case P113DResult{values} P126LCtx{params,buffers,ids}: p113e_result_emit(values,ids,code)



@unsafe
def p126l_width(+head: P113DStmt, +rest: List<&2,P113DStmt>, +ctx: P126LCtx, +facts: List<&2,P114FLFact>, +code: P111QCode) -> P111QCode:
  match rest ctx:
    case Con{+second,+more} P126LCtx{params,buffers,+ids}:
      nt_choose(P111QCode,p113w_pair(head,second) && p113w_room(code),
        u => p126l_stmts(more,ctx,p126l_kill([head,second],facts),p113w_pair_emit(head,ids,code)),
        u => p126l_width_one(head,rest,ctx,facts,code))
    case _ _: p126l_width_one(head,rest,ctx,facts,code)



@unsafe
def p126l_width_one(head: P113DStmt, +rest: List<&2,P113DStmt>, +ctx: P126LCtx, +facts: List<&2,P114FLFact>, +code: P111QCode) -> P111QCode:
  match head ctx:
    case P113DScalar{+scalar} P126LCtx{params,buffers,ids}:
      p126l_stmts(rest,ctx,p126l_scalar_facts(scalar,facts),p113w_one(P113DScalar{scalar},params,ids,code))
    case _ _: p111q_problem("typed width source is not scalar",code)



@unsafe
def p126l_if(+condition: N111Value, +yes: List<&2,P113DStmt>, +no: List<&2,P113DStmt>, +ctx: P126LCtx, +facts: List<&2,P114FLFact>, +code: P111QCode) -> P111QCode:
  match ctx:
    case P126LCtx{params,buffers,+ids}:
      +diamond = p113bq_direct(yes,no)
      nt_choose(P111QCode,p113bq_ready(diamond,code),u => p113bq_emit(condition,diamond,ids,code),
        u => p126l_if_original(condition,yes,no,ctx,facts,code))



@unsafe
def p126l_if_original(+condition: N111Value, +yes: List<&2,P113DStmt>, +no: List<&2,P113DStmt>, +ctx: P126LCtx, +facts: List<&2,P114FLFact>, code: P111QCode) -> P111QCode:
  match ctx code:
    case P126LCtx{params,buffers,ids} P111QCode{chunks,+site,terminal,error}:
      p126l_if_yes(site,no,ctx,facts,p126l_stmts(yes,ctx,facts,P111QCode{
        Con{p111q_label(site) ++ "\n",Con{"jnz " ++ p111q_value(condition,ids) ++ ", " ++ p111q_label(site) ++ ", " ++ p111q_label(U32.inc(site)) ++ "\n",chunks}},U32.add(site,3),False{},error}))



@unsafe
def p126l_if_yes(+label: U32, +no: List<&2,P113DStmt>, +ctx: P126LCtx, +facts: List<&2,P114FLFact>, yes: P111QCode) -> P111QCode:
  match yes:
    case P111QCode{chunks,next,+terminal,error}:
      +prefix = nt_choose(List<&2,String>,terminal,u => chunks,u => Con{"jmp " ++ p111q_label(U32.add(label,2)) ++ "\n",chunks})
      p111q_if_done(label,terminal,p126l_stmts(no,ctx,facts,P111QCode{Con{p111q_label(U32.inc(label)) ++ "\n",prefix},next,False{},error}))

@unsafe
def p126l_private(function: P113DFunction, +ids: N111Ids) -> String:
  match function:
    case P113DFunction{+name,+params,+result,public,+body}:
      +buffers = p114so_buffers(body)
      +allocas = p113e_allocas(body,["%v_scratch =l alloc8 2048\n"])
      +allocas = nt_choose(List<&2,String>,p113e_multi(body),u => Con{"%p113_results =l alloc8 64\n",allocas},u => allocas)
      +base = nt_choose(String,U32.is_eq(result,1),u => "l %state",u => "l %state, l %p113_result_out")
      "function l $" ++ p113e_symbol(name) ++ "(" ++ p113e_formals(params,base) ++ ") {\n@entry\n" ++
        p144e_body_tail(p126l_stmts(body,P126LCtx{params,buffers,ids},[],
          P111QCode{Con{"",Con{"@p113_loop\n",Con{"jmp @p113_loop\n",allocas}}},0,False{},""}),"}\n")

@unsafe
def p126l_emit_one(+function: P113DFunction, +ids: N111Ids, +heap_min: U32) -> String:
  match function:
    case P113DFunction{name,params,result,public,+body}:
      nt_choose(String,U32.is_eq(p113a_count_body(body,0),0) && Bool.not(List.is_empty(&2,String,p114so_buffers(body))),
        u => p126l_private(function,ids),u => p113ah_function(function,ids,heap_min))


@unsafe
def p126l_chunks(functions: List<&2,P113DFunction>, +ids: N111Ids, +heap_min: U32, acc: List<&2,String>) -> List<&2,String>:
  match functions:
    case Nil{}: nt_reverse(String,acc,[])
    case Con{head,rest}: p126l_chunks(rest,ids,heap_min,Con{p126l_emit_one(head,ids,heap_min),acc})


law p126s_eval:
  for +book: List<&2,KDef>
  for +term: KTerm
  for +kind: String
  for +fuel: U32
  KTerm

@unsafe
def p126s_eval(book,term,kind,fuel):
  nt_choose(KTerm,U32.is_gt(fuel,0),u =>
    p126s_eval_next(book,j_strip(term),kind,U32.sub(fuel,1),p126s_atom(j_strip(term),kind)),u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm})


@unsafe
def p126s_float(bits: U32) -> F32:
  match bits:
    case U32{word}: F32{word}


@unsafe
def p126s_kind(+book: List<&2,KDef>, +ty: KTerm) -> String:
  +head = wnf(book,ty)
  nt_choose(String,j_primitive_type(book,head,"F32"),u => "F32",u =>
    nt_choose(String,j_primitive_type(book,head,"U32"),u => "U32",u => ""))


@unsafe
def p126s_literal(+kind: String, value: Maybe<&2,U32>) -> KTerm:
  match value:
    case None{}: {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}
    case Some{+bits}:
      nt_choose(KTerm,String.eq(kind,"U32") || j_private_float_finite(bits),
        u => kl_make(kind,bits,""),u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm})


@unsafe
def p126s_atom(+term: KTerm, +kind: String) -> KTerm:
  nt_choose(KTerm,core_literal(term) && String.eq(nm(term),kind),
    u => p126s_literal(kind,Some{kl_number(term)}),u =>
    nt_choose(KTerm,String.eq(tg(term),"Ctr") && String.eq(nm(term),kind) && U32.is_eq(terms_len(ks(term)),1),
      u => p126s_literal(kind,j_word(j_strip(kid(term,0)),0,0)),u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}))


@unsafe
def p126s_result(+op: String, +a: U32, +b: U32) -> KTerm:
  +value = nt_choose(F32,String.eq(op,"U32.to_f32"),u => U32.to_f32(a),u =>
    nt_choose(F32,String.eq(op,"F32.add"),u => F32.add(p126s_float(a),p126s_float(b)),u =>
    nt_choose(F32,String.eq(op,"F32.sub"),u => F32.sub(p126s_float(a),p126s_float(b)),u =>
    nt_choose(F32,String.eq(op,"F32.mul"),u => F32.mul(p126s_float(a),p126s_float(b)),u => F32.div(p126s_float(a),p126s_float(b))))))
  p126s_literal("F32",Some{F32.bits(value)})


@unsafe
def p126s_primitive_second(+op: String, +first: KTerm, +second: KTerm) -> KTerm:
  nt_choose(KTerm,core_literal(second),u => p126s_result(op,kl_number(first),kl_number(second)),u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm})


@unsafe
def p126s_primitive_first(+book: List<&2,KDef>, +call: KTerm, +fuel: U32, +first: KTerm) -> KTerm:
  nt_choose(KTerm,core_literal(first),u =>
    nt_choose(KTerm,String.eq(nm(call),"U32.to_f32"),u => p126s_result(nm(call),kl_number(first),0),u =>
      p126s_primitive_second(nm(call),first,p126s_eval(book,kid(call,1),"F32",fuel))),u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm})


law p126s_helper_arg:
  for +book: List<&2,KDef>
  for +body: KTerm
  for +ty: KTerm
  for +arg: KTerm
  for +rest: List<&2,KTerm>
  for +kind: String
  for +fuel: U32
  KTerm

@unsafe
def p126s_helper_arg(book,body,ty,arg,rest,kind,fuel):
  +input = p126s_kind(book,kid(ty,0))
  nt_choose(KTerm,String.eq(tg(body),"Lam") && U32.is_eq(terms_len(ks(body)),1) && String.eq(j_l_name(body),"") &&
    String.eq(tg(ty),"All") && Bool.not(U32.is_eq(qt(ty),0)) && Bool.not(String.is_empty(input)),u =>
      p126s_helper_value(book,body,ty,rest,kind,fuel,p126s_eval(book,arg,input,fuel)),u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm})


@unsafe
def p126s_helper(+book: List<&2,KDef>, +body: KTerm, +ty: KTerm, +args: List<&2,KTerm>, +kind: String, +fuel: U32) -> KTerm:
  match args:
    case Nil{}:
      nt_choose(KTerm,String.eq(p126s_kind(book,ty),kind),u => p126s_eval(book,body,kind,fuel),u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm})
    case Con{arg,rest}: p126s_helper_arg(book,j_strip(body),wnf(book,ty),arg,rest,kind,fuel)


@unsafe
def p126s_helper_value(+book: List<&2,KDef>, +body: KTerm, +ty: KTerm, +rest: List<&2,KTerm>, +kind: String, +fuel: U32, +value: KTerm) -> KTerm:
  nt_choose(KTerm,core_literal(value),u =>
    p126s_helper(book,subst(kid(body,0),ix(body),value),subst(kid(ty,1),ix(ty),value),rest,kind,fuel),u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm})


@unsafe
def p126s_call(+book: List<&2,KDef>, +call: KTerm, +kind: String, +fuel: U32) -> KTerm:
  +name = nm(call)
  +d = lookup(book,name)
  nt_choose(KTerm,String.eq(kind,"F32") && String.contains("|U32.to_f32|F32.add|F32.sub|F32.mul|F32.div|","|" ++ name ++ "|") && j_primitive_call(book,call),
    u => p126s_primitive_first(book,call,fuel,p126s_eval(book,kid(call,0),j_primitive_input(name,0),fuel)),u =>
    nt_choose(KTerm,String.eq(dk(d),"Def") && Bool.not(db(d) || nc_foreign(d)) && U32.is_eq(dx(d),0) &&
      U32.is_gt(da(d),0) && U32.is_le(da(d),2) && U32.is_eq(da(d),terms_len(ks(call))) && j_u32_bounded([dv(d)],64),
      u => p126s_helper(book,dv(d),dt(d),ks(call),kind,fuel),u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}))


@unsafe
def p126s_eval_spine(+book: List<&2,KDef>, +kind: String, +fuel: U32, +spine: KTerm) -> KTerm:
  nt_choose(KTerm,String.eq(tg(spine),"Call"),u => p126s_call(book,spine,kind,fuel),u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm})


@unsafe
def p126s_eval_next(+book: List<&2,KDef>, +term: KTerm, +kind: String, +fuel: U32, +value: KTerm) -> KTerm:
  nt_choose(KTerm,core_literal(value),u => value,u => p126s_eval_spine(book,kind,fuel,j_call_spine(term,[])))


law p126s_rows:
  for +book: List<&2,KDef>
  for +term: KTerm
  for +ty: KTerm
  for +kind: String
  for +left: U32
  Maybe<&2,List<&2,U32>>

@unsafe
def p126s_rows(book,term,ty,kind,left):
  +head = wnf(book,ty)
  nt_choose(Maybe<&2,List<&2,U32>>,U32.is_gt(left,0) && String.eq(tg(head),"All") && Bool.not(U32.is_eq(qt(head),0)) &&
    j_primitive_type(book,wnf(book,kid(head,0)),"Nat"),u => p126s_rows_on(book,j_strip(term),head,kind,left),u => None{})


@unsafe
def p126s_cons(first: KTerm, rest: Maybe<&2,List<&2,U32>>) -> Maybe<&2,List<&2,U32>>:
  match rest:
    case None{}: None{}
    case Some{values}: Some{Con{kl_number(first),values}}


@unsafe
def p126s_row_first(+book: List<&2,KDef>, +term: KTerm, +ty: KTerm, +kind: String, +left: U32, +first: KTerm) -> Maybe<&2,List<&2,U32>>:
  nt_choose(Maybe<&2,List<&2,U32>>,core_literal(first),u =>
    p126s_cons(first,p126s_rows(book,kid(j_strip(kid(term,1)),0),j_arm_type(book,ty,"Succ"),kind,U32.sub(left,1))),u => None{})


@unsafe
def p126s_last(+value: KTerm) -> Maybe<&2,List<&2,U32>>:
  nt_choose(Maybe<&2,List<&2,U32>>,core_literal(value),u => Some{[kl_number(value)]},u => None{})


@unsafe
def p126s_rows_on(+book: List<&2,KDef>, +term: KTerm, +ty: KTerm, +kind: String, +left: U32) -> Maybe<&2,List<&2,U32>>:
  +rest = j_strip(kid(term,1))
  nt_choose(Maybe<&2,List<&2,U32>>,String.eq(tg(term),"Lam") && U32.is_eq(terms_len(ks(term)),1) && String.eq(j_l_name(term),""),
    u => p126s_last(p126s_eval(book,kid(term,0),kind,8)),u =>
    nt_choose(Maybe<&2,List<&2,U32>>,String.eq(tg(term),"Mat") && String.eq(nm(term),"Zero") && U32.is_eq(terms_len(ks(term)),2) &&
      String.eq(tg(rest),"Mat") && String.eq(nm(rest),"Succ") && U32.is_eq(terms_len(ks(rest)),2) &&
      String.eq(tg(j_strip(kid(rest,1))),"Efq") && U32.is_eq(terms_len(ks(j_strip(kid(rest,1)))),0),
      u => p126s_row_first(book,term,ty,kind,left,p126s_eval(book,kid(term,0),kind,8)),u => None{}))


@unsafe
def p126s_plan_result(+book: List<&2,KDef>, +d: KDef, +ty: KTerm, +kind: String) -> Maybe<&2,List<&2,U32>>:
  nt_choose(Maybe<&2,List<&2,U32>>,Bool.not(String.is_empty(kind)) && j_u32_bounded([dv(d)],4096),
    u => p126s_rows(book,dv(d),ty,kind,64),u => None{})


@unsafe
def p126s_plan_type(+book: List<&2,KDef>, +d: KDef, +ty: KTerm) -> Maybe<&2,List<&2,U32>>:
  nt_choose(Maybe<&2,List<&2,U32>>,String.eq(tg(ty),"All") && Bool.not(U32.is_eq(qt(ty),0)) &&
    j_primitive_type(book,wnf(book,kid(ty,0)),"Nat"),
    u => p126s_plan_result(book,d,ty,p126s_kind(book,kid(ty,1))),u => None{})


@unsafe
def p126s_plan(+book: List<&2,KDef>, +d: KDef) -> Maybe<&2,List<&2,U32>>:
  nt_choose(Maybe<&2,List<&2,U32>>,String.eq(dk(d),"Def") && U32.is_eq(da(d),1) && U32.is_eq(dx(d),0) &&
    Bool.not(db(d) || nc_foreign(d)) && String.eq(tg(j_strip(dv(d))),"Mat"),
    u => p126s_plan_type(book,d,wnf(book,dt(d))),u => None{})

@unsafe
def p126s_decision(+word: String, values: List<&2,U32>, +index: U32) -> List<&2,P113DStmt>:
  match values:
    case Nil{}: []
    case Con{bits,Nil{}}: [P113DResult{[N111Const{bits,0}]}]
    case Con{bits,rest}:
      +condition = "p126_select_" ++ U32.show(index)
      [P113DScalar{N111Bin{condition,N111U64{},"eq",N111Local{word},N111Const{index,0}}},
       P113DIf{N111Local{condition},[P113DResult{[N111Const{bits,0}]}],p126s_decision(word,rest,U32.inc(index))}]


@unsafe
def p126s_original_candidate(+book: List<&2,KDef>, +name: String, +signatures: List<&2,KDef>) -> P113DCandidate:
  +arity = nd_arity(book,name)
  +params = nk_typed_bindings(nd_entry_params(arity,0),nf_worker_kinds(book,name,arity))
  +owner = p113d_public(book,name)
  +body = nc_compact_definition(book,lookup(book,name),0)
  p113pl_candidate_code(owner,params,{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},True{},
    p113pl_lower(book,nd_reapply(body,nd_entry_args(params)),params,P113PTarget{[],{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},True{},owner,signatures},arity))


@unsafe
def p126s_candidate_params(+book: List<&2,KDef>, +name: String, +signatures: List<&2,KDef>, +values: List<&2,U32>, params: List<&2,NC_Binding>) -> P113DCandidate:
  match params:
    case [NC_Binding{+id,+word,+kind}]:
      P113DCandidate{P113DFunction{p113d_public(book,name),[NC_Binding{id,word,kind}],1,True{},p126s_decision(word,values,0)},"",[]}
    case _: p126s_original_candidate(book,name,signatures)


@unsafe
def p126s_candidate(+book: List<&2,KDef>, +name: String, +signatures: List<&2,KDef>, plan: Maybe<&2,List<&2,U32>>) -> P113DCandidate:
  match plan:
    case None{}: p126s_original_candidate(book,name,signatures)
    case Some{+values}:
      nt_choose(P113DCandidate,U32.is_ge(nt_count(U32,values),4),u =>
        p126s_candidate_params(book,name,signatures,values,nk_typed_bindings(nd_entry_params(1,0),nf_worker_kinds(book,name,1))),
        u => p126s_original_candidate(book,name,signatures))

@unsafe
def p126s_cells_cons(bits: U32, rest: Maybe<&2,List<&2,U32>>) -> Maybe<&2,List<&2,U32>>:
  match rest:
    case None{}: None{}
    case Some{values}: Some{Con{bits,values}}


@unsafe
def p126s_cells(+word: String, body: List<&2,P113DStmt>, +index: U32) -> Maybe<&2,List<&2,U32>>:
  match body:
    case [P113DResult{[N111Const{bits,hi}]}]:
      nt_choose(Maybe<&2,List<&2,U32>>,U32.is_eq(hi,0),u => Some{[bits]},u => None{})
    case [P113DScalar{N111Bin{+dest,N111U64{},op,N111Local{arg},N111Const{at,hi}}},
          P113DIf{N111Local{cond},[P113DResult{[N111Const{bits,upper}]}],rest}]:
      nt_choose(Maybe<&2,List<&2,U32>>,String.eq(op,"eq") && String.eq(arg,word) && String.eq(cond,dest) &&
        Bool.not(String.eq(dest,word)) && U32.is_eq(at,index) && U32.is_eq(hi,0) && U32.is_eq(upper,0) && U32.is_lt(index,63),
        u => p126s_cells_cons(bits,p126s_cells(word,rest,U32.inc(index))),u => None{})
    case _: None{}


@unsafe
def p126s_data(values: List<&2,U32>) -> List<&2,P111QDatum>:
  match values:
    case Nil{}: []
    case Con{bits,rest}: Con{P111QLong{bits,0},p126s_data(rest)}


@unsafe
def p126s_render(+name: String, +word: String, +values: List<&2,U32>) -> String:
  +table = "p126s_table_" ++ nt_fid(name)
  +last = U32.show(U32.sub(nt_count(U32,values),1))
  "function l $" ++ p113e_symbol(name) ++ "(l %state, l " ++ p111q_local(word) ++ ") {\n@entry\n" ++
  "%p126s_inside =w cultl " ++ p111q_local(word) ++ ", " ++ last ++ "\n" ++
  "jnz %p126s_inside, @p126s_input, @p126s_default\n@p126s_input\n" ++
  "%p126s_index =l copy " ++ p111q_local(word) ++ "\njmp @p126s_load\n@p126s_default\n" ++
  "%p126s_index =l copy " ++ last ++ "\njmp @p126s_load\n@p126s_load\n" ++
  "%p126s_bytes =l shl %p126s_index, 3\n%p126s_addr =l add $" ++ table ++ ", %p126s_bytes\n" ++
  "%p126s_result =l loadl %p126s_addr\nret %p126s_result\n}\n" ++
  p111q_data(P111QData{table,8,False{},p126s_data(values)})


@unsafe
def p126s_emit_cells(+name: String, +word: String, cells: Maybe<&2,List<&2,U32>>) -> String:
  match cells:
    case None{}: ""
    case Some{+values}:
      nt_choose(String,U32.is_ge(nt_count(U32,values),4),u => p126s_render(name,word,values),u => "")


@unsafe
def p126s_emit(function: P113DFunction) -> String:
  match function:
    case P113DFunction{name,[NC_Binding{id,+word,kind}],result,public,body}:
      nt_choose(String,U32.is_eq(result,1),u => p126s_emit_cells(name,word,p126s_cells(word,body,0)),u => "")
    case _: ""


@unsafe
def p126s_has_cells(cells: Maybe<&2,List<&2,U32>>) -> Bool:
  match cells:
    case Some{values}: U32.is_ge(nt_count(U32,values),4)
    case _: False{}


@unsafe
def p126s_is_table(function: P113DFunction) -> Bool:
  match function:
    case P113DFunction{name,[NC_Binding{id,+word,kind}],result,public,body}:
      U32.is_eq(result,1) && p126s_has_cells(p126s_cells(word,body,0))
    case _: False{}

@unsafe
def p126s_prior_function(+function: P113DFunction, +ids: N111Ids, +heap_min: U32) -> String:
  match function:
    case P113DFunction{name,+params,result,public,+body}:
      +count = nt_count(NC_Binding,params)
      nt_choose(String,U32.is_eq(p113a_count_body(body,0),0),u => p113e_private(function,ids),u =>
        nt_choose(String,U32.is_gt(count,16) || Bool.not(p117h_params_clean(params)),u => p113ah_private(p113a_function(function,heap_min),ids),u =>
          p117h_finish(function,ids,heap_min,p117h_walk(body,count,
            P117HScan{p117h_seed(params,1,missing()),missing(),U32.sub(U32.shln(1,U32.to_nat(count)),1),0,False{},8192,0,missing()}))))


@unsafe
def p126s_inspect(request: NR_Request, +name: String) -> Maybe<&2,List<&2,U32>>:
  match request:
    case NR_Request{source,+book,names,paths,scope,bound}: p126s_plan(book,lookup(book,name))


@unsafe
def p126s_float_bits(bits: U32) -> U32:
  F32.bits(p126s_float(bits))


@unsafe
def p126s_projection_control() -> String:
  +params : List<&2,NC_Binding> = [NC_Binding{0,"v_0",N_Imm64{}}]
  +function : P113DFunction = P113DFunction{"selector",params,1,False{},p126s_decision("v_0",[0,2147483648,1065353216,4294967295],0)}
  nt_choose(String,p126s_is_table(function) && String.contains(p126s_emit(function),"loadl") &&
    String.contains(p126s_emit(function),"cultl %v_v_0, 3"),u => "table-projection:pass",u => "table-projection:FAIL")

@unsafe
def p126r_scalar(stmt: N111Stmt) -> Bool:
  match stmt:
    case N111If{condition,yes,no}: p126r_scalars(yes) && p126r_scalars(no)
    case _: p112t_scalar_safe(stmt)


@unsafe
def p126r_scalars(body: List<&2,N111Stmt>) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{head,rest}: p126r_scalar(head) && p126r_scalars(rest)


@unsafe
def p126r_arguments(+body: List<&2,N111Stmt>, +owner: String, +arity: U32) -> Bool:
  nt_choose(Bool,p112t_tail(body,owner,arity,0),u => True{},
    u => p126r_arguments_next(body,owner,arity))


@unsafe
def p126r_arguments_next(body: List<&2,N111Stmt>, +owner: String, +arity: U32) -> Bool:
  match body:
    case Con{head,rest}: p126r_scalar(head) && p126r_arguments(rest,owner,arity)
    case _: False{}

@unsafe
def p126nt_expand(+stmt: N111Stmt, +site: U32) -> P114TExpansion:
  match stmt:
    case N111Call{+dest,N111U64{},+symbol,
      Con{N111Arg{N111Ptr{},N111Local{+state}},
      Con{N111Arg{N111U32{},N111Const{4,0}},
      Con{N111Arg{N111U64{},+term},
      Con{N111Arg{N111Ptr{},N111Local{+buffer}},
      Con{N111Arg{N111U32{},N111Const{1,0}},Nil{}}}}}}}:
        nt_choose(P114TExpansion,String.eq(symbol,"p111_rt_special_take") && String.eq(state,"state") &&
          Bool.not(String.eq(buffer,"state")) && U32.is_le(site,4294967292),
          u => P114TExpansion{[
            N111Bin{p114t_name(site,"nat_pred"),N111U64{},"sub",term,N111Const{1,0}},
            N111Store{N111U64{},N111Local{buffer},0,p114t_local(site,"nat_pred")},
            N111Set{dest,N111U64{},N111Const{1,0}}],True{}},
          u => P114TExpansion{[stmt],False{}})
    case _: P114TExpansion{[stmt],False{}}


@unsafe
def p126nt_previous_stmt(stmt: N111Stmt, ids: N111Ids, code: P111QCode) -> P111QCode:
  p114t_stmt(stmt,ids,code)


@unsafe
def p126nt_emit(+stmt: N111Stmt, +ids: N111Ids, +code: P111QCode, expansion: P114TExpansion) -> P111QCode:
  match expansion:
    case P114TExpansion{body,changed}:
      nt_choose(P111QCode,changed,u => p114t_expanded(P114TExpansion{body,changed},ids,code),u => p126nt_previous_stmt(stmt,ids,code))


@unsafe
def p126nt_controls() -> List<&2,String>:
  [p126ntc_row("one-full-word",p126ntc_word(1,0)),
   p126ntc_row("2pow32",p126ntc_word(0,1)),
   p126ntc_row("2pow40",p126ntc_word(0,256)),
   p126ntc_row("2pow48-minus1",p126ntc_word(4294967295,65535)),
   p126ntc_row("analysis-only-u64-max",p126ntc_word(4294967295,4294967295)),
   p126ntc_row("destination-alias-input",p126ntc_changed(p126nt_expand(p126ntc_valid(N111Local{"answer"},"answer","scratch"),7))),
   p126ntc_row("renamed-continuation-buffer",p126ntc_changed(p126nt_expand(p126ntc_valid(N111Local{"n"},"ignored","p114h_case_0_local_scratch"),7))),
   p126ntc_row("wrong-symbol",p126ntc_refused(p126ntc_call("p111_rt_take",4,0,1,0,"state","scratch","answer",N111Const{1,0}))),
   p126ntc_row("zero-case-refused",p126ntc_refused(p126ntc_call("p111_rt_special_take",3,0,0,0,"state","scratch","answer",N111Const{0,0}))),
   p126ntc_row("char-case-refused",p126ntc_refused(p126ntc_call("p111_rt_special_take",5,0,1,0,"state","scratch","answer",N111Const{65,0}))),
   p126ntc_row("wrong-count",p126ntc_refused(p126ntc_call("p111_rt_special_take",4,0,2,0,"state","scratch","answer",N111Const{1,0}))),
   p126ntc_row("kind-high-word",p126ntc_refused(p126ntc_call("p111_rt_special_take",4,1,1,0,"state","scratch","answer",N111Const{1,0}))),
   p126ntc_row("count-high-word",p126ntc_refused(p126ntc_call("p111_rt_special_take",4,0,1,1,"state","scratch","answer",N111Const{1,0}))),
   p126ntc_row("wrong-state",p126ntc_refused(p126ntc_call("p111_rt_special_take",4,0,1,0,"other","scratch","answer",N111Const{1,0}))),
   p126ntc_row("state-output-refused",p126ntc_refused(p126ntc_call("p111_rt_special_take",4,0,1,0,"state","state","answer",N111Const{1,0}))),
   p126ntc_row("counter-limit",Bool.not(p126ntc_changed(p126nt_expand(p126ntc_valid(N111Local{"n"},"answer","scratch"),4294967295))))]
