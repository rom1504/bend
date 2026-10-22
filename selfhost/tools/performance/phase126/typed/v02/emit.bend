# Post-verification representation projection. Ordinary word values remain
# available for every non-float use; typed formal admission is separate.
type P126TCtx is Data:
  P126TCtx{+params: List<&2,NC_Binding>, +floats: List<&2,String>,
    +plans: List<&2,P126TPlan>, +buffers: List<&2,String>, +ids: N111Ids}

type P126TArgs is Data:
  P126TArgs{+prefix: String, +args: String, +next: U32}

@unsafe
def p126t_lane(word: String) -> String:
  "%p126_lane_" ++ nt_fid(word)

@unsafe
def p126t_symbol(name: String) -> String:
  "p126_typed_" ++ nt_fid(name)

@unsafe
def p126t_formals(params: List<&2,NC_Binding>, +floats: List<&2,String>, acc: String) -> String:
  match params:
    case Nil{}: acc
    case Con{NC_Binding{id,+word,kind},rest}:
      p126t_formals(rest,floats,acc ++ nt_choose(String,p114so_member(floats,word),
        u => ", s " ++ p126t_lane(word),u => ", l " ++ p111q_local(word)))

@unsafe
def p126t_seed(floats: List<&2,String>) -> List<&2,P114FLFact>:
  match floats:
    case Nil{}: []
    case Con{+word,rest}: Con{P114FLFact{word,p126t_lane(word)},p126t_seed(rest)}

@unsafe
def p126t_words(floats: List<&2,String>) -> String:
  match floats:
    case Nil{}: ""
    case Con{+word,rest}:
      +bits = "%p126_bits_" ++ nt_fid(word)
      bits ++ " =w cast " ++ p126t_lane(word) ++ "\n" ++
        p111q_local(word) ++ " =l extuw " ++ bits ++ "\n" ++ p126t_words(rest)

@unsafe
def p126t_args(params: List<&2,NC_Binding>, values: List<&2,N111Value>, +floats: List<&2,String>, +facts: List<&2,P114FLFact>, +ids: N111Ids, +site: U32, +prefix: String, +args: String) -> P126TArgs:
  match params values:
    case Nil{} Nil{}: P126TArgs{prefix,args,site}
    case Con{NC_Binding{id,word,kind},rest} Con{+value,more}:
      nt_choose(P126TArgs,p114so_member(floats,word),
        u => p126t_arg_float(rest,more,floats,facts,ids,site,prefix,args,p114fl_operand(value,facts,ids,site)),
        u => p126t_args(rest,more,floats,facts,ids,site,prefix,args ++ ", l " ++ p111q_value(value,ids)))
    case _ _: P126TArgs{"INVALID_P126_ARGUMENT_ARITY",args,site}

@unsafe
def p126t_arg_float(+params: List<&2,NC_Binding>, +values: List<&2,N111Value>, +floats: List<&2,String>, +facts: List<&2,P114FLFact>, +ids: N111Ids, +site: U32, +prefix: String, +args: String, operand: P114FLOperand) -> P126TArgs:
  match operand:
    case P114FLOperand{before,lane}:
      p126t_args(params,values,floats,facts,ids,U32.add(site,2),prefix ++ before,args ++ ", s " ++ lane)

@unsafe
def p126t_call(+destinations: List<&2,String>, +target: String, +values: List<&2,N111Value>, +ctx: P126TCtx, +facts: List<&2,P114FLFact>, +code: P111QCode) -> P111QCode:
  match ctx:
    case P126TCtx{params,floats,+plans,buffers,+ids}:
      p126t_call_found(destinations,target,values,ids,facts,code,p126t_find(plans,target))

@unsafe
def p126t_call_found(+destinations: List<&2,String>, +target: String, +values: List<&2,N111Value>, +ids: N111Ids, +facts: List<&2,P114FLFact>, +code: P111QCode, found: Maybe<&2,P126TPlan>) -> P111QCode:
  match code found:
    case _ None{}: p113e_call_emit(destinations,target,values,ids,code)
    case P111QCode{chunks,site,terminal,error} Some{P126TPlan{P113DFunction{name,params,result,public,body},floats}}:
      p126t_call_args(destinations,target,code,p126t_args(params,values,floats,facts,ids,site,"",
        nt_choose(String,U32.is_eq(nt_count(String,destinations),1),u => "l %state",u => "l %state, l %p113_results")))

@unsafe
def p126t_call_args(+destinations: List<&2,String>, +target: String, code: P111QCode, args: P126TArgs) -> P111QCode:
  match destinations code args:
    case [name] P111QCode{chunks,site,terminal,error} P126TArgs{prefix,arguments,next}:
      +code : P111QCode = P111QCode{Con{prefix,chunks},next,terminal,error}
      p111q_line(p111q_local(name) ++ " =l call $" ++ p126t_symbol(target) ++ "(" ++ arguments ++ ")\n",code)
    case _ P111QCode{chunks,site,terminal,error} P126TArgs{prefix,arguments,next}:
      p113e_load_results(destinations,0,p111q_line("%p113_status =l call $" ++ p126t_symbol(target) ++ "(" ++ arguments ++ ")\n",P111QCode{Con{prefix,chunks},next,terminal,error}))

@unsafe
def p126t_forget(names: List<&2,String>, +facts: List<&2,P114FLFact>) -> List<&2,P114FLFact>:
  match names:
    case Nil{}: facts
    case Con{name,rest}: p126t_forget(rest,p114fl_remove(facts,name))

@unsafe
def p126t_scalar_facts(stmt: N111Stmt, +facts: List<&2,P114FLFact>) -> List<&2,P114FLFact>:
  match stmt:
    case N111Set{name,N111U64{},N111Local{source}}: p114fl_copy(facts,name,source)
    case N111Set{name,typ,value}: p114fl_remove(facts,name)
    case N111Bin{name,typ,op,a,b}: p114fl_remove(facts,name)
    case N111Call{name,typ,symbol,args}: p114fl_remove(facts,name)
    case N111Load{name,typ,base,offset}: p114fl_remove(facts,name)
    case N111Offset{name,base,bytes}: p114fl_remove(facts,name)
    case N111Alloca{name,bytes,align}: p114fl_remove(facts,name)
    case N111Store{typ,base,offset,value}: facts
    case _: []

@unsafe
def p126t_snapshot(params: List<&2,NC_Binding>, values: List<&2,N111Value>, +floats: List<&2,String>, +facts: List<&2,P114FLFact>, +ids: N111Ids, +index: U32, +code: P111QCode) -> P111QCode:
  match params values code:
    case Nil{} Nil{} _: code
    case Con{NC_Binding{id,word,kind},rest} Con{+value,more} P111QCode{chunks,site,terminal,error}:
      nt_choose(P111QCode,p114so_member(floats,word),
        u => p126t_snapshot_float(rest,more,floats,facts,ids,index,code,p114fl_operand(value,facts,ids,site)),
        u => p126t_snapshot(rest,more,floats,facts,ids,U32.inc(index),
          p111q_line("%p126_next_" ++ U32.show(index) ++ " =l copy " ++ p111q_value(value,ids) ++ "\n",code)))
    case _ _ _: p111q_problem("typed backedge arity",code)

@unsafe
def p126t_snapshot_float(+params: List<&2,NC_Binding>, +values: List<&2,N111Value>, +floats: List<&2,String>, +facts: List<&2,P114FLFact>, +ids: N111Ids, +index: U32, code: P111QCode, operand: P114FLOperand) -> P111QCode:
  match code operand:
    case P111QCode{chunks,site,terminal,error} P114FLOperand{prefix,lane}:
      p126t_snapshot(params,values,floats,facts,ids,U32.inc(index),P111QCode{
        Con{prefix ++ "%p126_next_" ++ U32.show(index) ++ " =s copy " ++ lane ++ "\n",chunks},U32.add(site,2),terminal,error})

@unsafe
def p126t_moves(params: List<&2,NC_Binding>, +floats: List<&2,String>, +index: U32, +code: P111QCode) -> P111QCode:
  match params:
    case Nil{}: p113e_again_end(code)
    case Con{NC_Binding{id,+word,kind},rest}:
      p126t_moves(rest,floats,U32.inc(index),p111q_line(
        nt_choose(String,p114so_member(floats,word),u => p126t_lane(word) ++ " =s copy ",u => p111q_local(word) ++ " =l copy ") ++ "%p126_next_" ++ U32.show(index) ++ "\n",code))

@unsafe
def p126t_stmts(body: List<&2,P113DStmt>, +ctx: P126TCtx, +facts: List<&2,P114FLFact>, +code: P111QCode) -> P111QCode:
  match body code:
    case Nil{} _: code
    case Con{+head,+rest} P111QCode{chunks,site,terminal,+error}:
      nt_choose(P111QCode,Bool.not(String.is_empty(error)),u => code,u =>
        nt_choose(P111QCode,terminal,u => p111q_problem("typed statement after transfer",code),
          u => p126t_dispatch(head,rest,ctx,facts,code,p114so_group(Con{head,rest}))))

@unsafe
def p126t_dispatch(+head: P113DStmt, +rest: List<&2,P113DStmt>, +ctx: P126TCtx, +facts: List<&2,P114FLFact>, +code: P111QCode, group: P114SOGroup) -> P111QCode:
  match ctx code group:
    case P126TCtx{params,floats,plans,+buffers,+ids} P111QCode{chunks,+site,terminal,error} P114SOYes{buffer,+name,+id,+left,+right,+more}:
      nt_choose(P111QCode,p114so_member(buffers,buffer) && p114so_room(code),
        u => p126t_stmts(more,ctx,p114fl_result(facts,name,id,site),p114fl_emit(id,name,left,right,facts,ids,code)),
        u => p126t_other(head,rest,ctx,facts,code))
    case _ _ _: p126t_other(head,rest,ctx,facts,code)

@unsafe
def p126t_other(+head: P113DStmt, +rest: List<&2,P113DStmt>, +ctx: P126TCtx, +facts: List<&2,P114FLFact>, +code: P111QCode) -> P111QCode:
  match head ctx:
    case P113DIf{condition,yes,no} _:
      p126t_stmts(rest,ctx,[],p126t_if(condition,yes,no,ctx,facts,code))
    case P113DCall{+destinations,target,values} _:
      p126t_stmts(rest,ctx,p126t_forget(destinations,facts),p126t_call(destinations,target,values,ctx,facts,code))
    case P113DAgain{values} P126TCtx{+params,+floats,plans,buffers,ids}:
      p126t_moves(params,floats,0,p126t_snapshot(params,values,floats,facts,ids,0,code))
    case P113DScalar{scalar} P126TCtx{+params,floats,plans,buffers,+ids}:
      p126t_stmts(rest,ctx,p126t_scalar_facts(scalar,facts),p113w_one(head,params,ids,code))
    case P113DResult{values} P126TCtx{params,floats,plans,buffers,ids}: p113e_result_emit(values,ids,code)

@unsafe
def p126t_if(+condition: N111Value, +yes: List<&2,P113DStmt>, +no: List<&2,P113DStmt>, +ctx: P126TCtx, +facts: List<&2,P114FLFact>, code: P111QCode) -> P111QCode:
  match ctx code:
    case P126TCtx{params,floats,plans,buffers,ids} P111QCode{chunks,+site,terminal,error}:
      p126t_if_yes(site,no,ctx,facts,p126t_stmts(yes,ctx,facts,P111QCode{
        Con{p111q_label(site) ++ "\n",Con{"jnz " ++ p111q_value(condition,ids) ++ ", " ++ p111q_label(site) ++ ", " ++ p111q_label(U32.inc(site)) ++ "\n",chunks}},U32.add(site,3),False{},error}))

@unsafe
def p126t_if_yes(+label: U32, +no: List<&2,P113DStmt>, +ctx: P126TCtx, +facts: List<&2,P114FLFact>, yes: P111QCode) -> P111QCode:
  match yes:
    case P111QCode{chunks,next,+terminal,error}:
      +prefix = nt_choose(List<&2,String>,terminal,u => chunks,u => Con{"jmp " ++ p111q_label(U32.add(label,2)) ++ "\n",chunks})
      p111q_if_done(label,terminal,p126t_stmts(no,ctx,facts,P111QCode{Con{p111q_label(U32.inc(label)) ++ "\n",prefix},next,False{},error}))

@unsafe
def p126t_values(params: List<&2,NC_Binding>) -> List<&2,N111Value>:
  match params:
    case Nil{}: []
    case Con{NC_Binding{id,word,kind},rest}: Con{N111Local{word},p126t_values(rest)}

@unsafe
def p126t_adapter(+name: String, +params: List<&2,NC_Binding>, +result: U32, +floats: List<&2,String>, +ids: N111Ids) -> String:
  +base = nt_choose(String,U32.is_eq(result,1),u => "l %state",u => "l %state, l %p113_result_out")
  p126t_adapter_args(name,params,base,p126t_args(params,p126t_values(params),floats,[],ids,0,"",base))

@unsafe
def p126t_adapter_args(+name: String, +params: List<&2,NC_Binding>, +base: String, args: P126TArgs) -> String:
  match args:
    case P126TArgs{prefix,arguments,next}:
      "function l $" ++ p113e_symbol(name) ++ "(" ++ p113e_formals(params,base) ++ ") {\n@entry\n" ++ prefix ++
        "%p126_return =l call $" ++ p126t_symbol(name) ++ "(" ++ arguments ++ ")\nret %p126_return\n}\n"

@unsafe
def p126t_private(function: P113DFunction, +floats: List<&2,String>, +plans: List<&2,P126TPlan>, +ids: N111Ids) -> String:
  match function:
    case P113DFunction{+name,+params,+result,public,+body}:
      +buffers = p114so_buffers(body)
      +allocas = p113e_allocas(body,["%v_scratch =l alloc8 2048\n"])
      +allocas = nt_choose(List<&2,String>,p113e_multi(body),u => Con{"%p113_results =l alloc8 64\n",allocas},u => allocas)
      +typed = Bool.not(List.is_empty(&2,String,floats))
      +symbol = nt_choose(String,typed,u => p126t_symbol(name),u => p113e_symbol(name))
      +base = nt_choose(String,U32.is_eq(result,1),u => "l %state",u => "l %state, l %p113_result_out")
      nt_choose(String,typed,u => p126t_adapter(name,params,result,floats,ids),u => "") ++
        "function l $" ++ symbol ++ "(" ++ p126t_formals(params,floats,base) ++ ") {\n@entry\n" ++
        p111q_body_text(p126t_stmts(body,P126TCtx{params,floats,plans,buffers,ids},p126t_seed(floats),
          P111QCode{Con{p126t_words(floats),Con{"@p113_loop\n",Con{"jmp @p113_loop\n",allocas}}},0,False{},""})) ++ "}\n"

@unsafe
def p126t_emit_one(+function: P113DFunction, +plans: List<&2,P126TPlan>, +ids: N111Ids, +heap_min: U32) -> String:
  match function:
    case P113DFunction{+name,params,result,public,+body}:
      p126t_emit_found(function,plans,ids,heap_min,p126t_find(plans,name))

@unsafe
def p126t_emit_found(+function: P113DFunction, +plans: List<&2,P126TPlan>, +ids: N111Ids, +heap_min: U32, found: Maybe<&2,P126TPlan>) -> String:
  match found:
    case Some{P126TPlan{original,floats}}: p126t_private(function,floats,plans,ids)
    case None{}: p126t_emit_unplanned(function,plans,ids,heap_min)

@unsafe
def p126t_emit_unplanned(+function: P113DFunction, +plans: List<&2,P126TPlan>, +ids: N111Ids, +heap_min: U32) -> String:
  match function:
    case P113DFunction{name,params,result,public,+body}:
      nt_choose(String,U32.is_eq(p113a_count_body(body,0),0) && Bool.not(List.is_empty(&2,String,p114so_buffers(body))),
        u => p126t_private(function,[],plans,ids),u => p113ah_function(function,ids,heap_min))

@unsafe
def p126t_chunks(functions: List<&2,P113DFunction>, +plans: List<&2,P126TPlan>, +ids: N111Ids, +heap_min: U32, acc: List<&2,String>) -> List<&2,String>:
  match functions:
    case Nil{}: nt_reverse(String,acc,[])
    case Con{head,rest}: p126t_chunks(rest,plans,ids,heap_min,Con{p126t_emit_one(head,plans,ids,heap_min),acc})

@unsafe
def p113ah_private_chunks(+functions: List<&2,P113DFunction>, +ids: N111Ids, +heap_min: U32, +acc: List<&2,String>) -> List<&2,String>:
  p126t_chunks(functions,p126t_plans(functions),ids,heap_min,acc)
