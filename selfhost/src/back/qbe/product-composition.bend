

@unsafe
def p126i_lookup(tables: List<&2,P126ITable>, +name: String) -> Maybe<&2,U32>:
  match tables:
    case Nil{}: None{}
    case Con{P126ITable{key,last},rest}:
      nt_choose(Maybe<&2,U32>,String.eq(key,name),u => Some{last},u => p126i_lookup(rest,name))


@unsafe
def p126i_cells(+name: String, cells: Maybe<&2,List<&2,U32>>, +acc: List<&2,P126ITable>) -> List<&2,P126ITable>:
  match cells:
    case None{}: acc
    case Some{values}:
      +count = nt_count(U32,values)
      nt_choose(List<&2,P126ITable>,U32.is_ge(count,4),
        u => Con{P126ITable{name,U32.sub(count,1)},acc},u => acc)


@unsafe
def p126i_add(function: P113DFunction, +acc: List<&2,P126ITable>) -> List<&2,P126ITable>:
  match function:
    case P113DFunction{name,[NC_Binding{id,+word,kind}],result,public,body}:
      nt_choose(List<&2,P126ITable>,U32.is_eq(result,1),
        u => p126i_cells(name,p126s_cells(word,body,0),acc),u => acc)
    case _: acc


@unsafe
def p126i_catalogue(functions: List<&2,P113DFunction>, acc: List<&2,P126ITable>) -> List<&2,P126ITable>:
  match functions:
    case Nil{}: nt_reverse(P126ITable,acc,[])
    case Con{head,rest}: p126i_catalogue(rest,p126i_add(head,acc))


@unsafe
def p126i_present(found: Maybe<&2,U32>) -> Bool:
  match found:
    case Some{last}: True{}
    case None{}: False{}


@unsafe
def p126i_recognized(names: List<&2,String>, target: String, values: List<&2,N111Value>, tables: List<&2,P126ITable>) -> Bool:
  match names values:
    case Con{name,Nil{}} Con{value,Nil{}}: p126i_present(p126i_lookup(tables,target))
    case _ _: False{}


@unsafe
def p126i_calls_walk(body: List<&2,P113DStmt>, +pending: List<&2,List<&2,P113DStmt>>, +tables: List<&2,P126ITable>) -> Bool:
  match body pending:
    case Nil{} Nil{}: False{}
    case Nil{} Con{more,rest}: p126i_calls_walk(more,rest,tables)
    case Con{P113DCall{names,target,values},rest} _:
      nt_choose(Bool,p126i_recognized(names,target,values,tables),
        u => True{},u => p126i_calls_walk(rest,pending,tables))
    case Con{P113DIf{condition,yes,no},rest} _:
      p126i_calls_walk(yes,Con{no,Con{rest,pending}},tables)
    case Con{stmt,rest} _: p126i_calls_walk(rest,pending,tables)


@unsafe
def p126i_calls(body: List<&2,P113DStmt>, tables: List<&2,P126ITable>) -> Bool:
  match tables:
    case Nil{}: False{}
    case Con{head,rest}: p126i_calls_walk(body,[],Con{head,rest})

@unsafe
def p126i_table_name(name: String) -> String:
  "p126s_table_" ++ nt_fid(name)


@unsafe
def p126i_room(code: P111QCode) -> Bool:
  match code:
    case P111QCode{chunks,next,terminal,error}: U32.is_le(next,4294967292)


@unsafe
def p126i_load(+dest: String, +target: String, +value: N111Value, +last: U32, +ids: N111Ids, code: P111QCode) -> P111QCode:
  match code:
    case P111QCode{chunks,+site,terminal,error}:
      +prefix = "%p126_inline_" ++ U32.show(site) ++ "_"
      +word = p111q_value(value,ids)
      +bound = U32.show(last)
      +text = prefix ++ "inside =w cultl " ++ word ++ ", " ++ bound ++ "\n" ++
        "jnz " ++ prefix ++ "inside, " ++ p111q_label(site) ++ ", " ++ p111q_label(U32.inc(site)) ++ "\n" ++
        p111q_label(site) ++ "\n" ++ prefix ++ "index =l copy " ++ word ++ "\n" ++
        "jmp " ++ p111q_label(U32.add(site,2)) ++ "\n" ++
        p111q_label(U32.inc(site)) ++ "\n" ++ prefix ++ "index =l copy " ++ bound ++ "\n" ++
        "jmp " ++ p111q_label(U32.add(site,2)) ++ "\n" ++
        p111q_label(U32.add(site,2)) ++ "\n" ++ prefix ++ "bytes =l shl " ++ prefix ++ "index, 3\n" ++
        prefix ++ "addr =l add $" ++ p126i_table_name(target) ++ ", " ++ prefix ++ "bytes\n" ++
        p111q_local(dest) ++ " =l loadl " ++ prefix ++ "addr\n"
      P111QCode{Con{text,chunks},U32.add(site,3),terminal,error}


@unsafe
def p126i_selected(+dest: String, +target: String, +value: N111Value, +ids: N111Ids, +code: P111QCode, found: Maybe<&2,U32>) -> P111QCode:
  match found:
    case Some{last}: nt_choose(P111QCode,p126i_room(code),
      u => p126i_load(dest,target,value,last,ids,code),
      u => p113e_call_emit([dest],target,[value],ids,code))
    case None{}: p113e_call_emit([dest],target,[value],ids,code)


@unsafe
def p126i_call(+names: List<&2,String>, +target: String, +values: List<&2,N111Value>, +tables: List<&2,P126ITable>, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match names values:
    case Con{dest,Nil{}} Con{value,Nil{}}: p126i_selected(dest,target,value,ids,code,p126i_lookup(tables,target))
    case _ _: p113e_call_emit(names,target,values,ids,code)

@unsafe
def p126i_stmts(body: List<&2,P113DStmt>, +ctx: P126ICtx, +facts: List<&2,P114FLFact>, +code: P111QCode) -> P111QCode:
  match body code:
    case Nil{} _: code
    case Con{+head,+rest} P111QCode{chunks,site,terminal,+error}:
      nt_choose(P111QCode,String.is_empty(error),u =>
        nt_choose(P111QCode,terminal,u => p111q_problem("typed statement after transfer",code),
          u => p126i_dispatch(head,rest,ctx,facts,code,p114so_group(Con{head,rest}))),u => code)



@unsafe
def p126i_dispatch(+head: P113DStmt, +rest: List<&2,P113DStmt>, +ctx: P126ICtx, +facts: List<&2,P114FLFact>, +code: P111QCode, group: P114SOGroup) -> P111QCode:
  match ctx code group:
    case P126ICtx{params,+buffers,+ids,tables} P111QCode{chunks,+site,terminal,error} P114SOYes{buffer,+name,+id,+left,+right,+more}:
      nt_choose(P111QCode,p114so_member(buffers,buffer) && p114so_room(code),
        u => p126i_stmts(more,ctx,p114fl_result(facts,name,id,site),p114fl_emit(id,name,left,right,facts,ids,code)),
        u => p126i_other(head,rest,ctx,facts,code))
    case _ _ _: p126i_other(head,rest,ctx,facts,code)



@unsafe
def p126i_other(+head: P113DStmt, +rest: List<&2,P113DStmt>, +ctx: P126ICtx, +facts: List<&2,P114FLFact>, +code: P111QCode) -> P111QCode:
  match head ctx:
    case P113DIf{condition,+yes,+no} _:
      p126i_stmts(rest,ctx,p126l_kill(no,p126l_kill(yes,facts)),p126i_if(condition,yes,no,ctx,facts,code))
    case P113DCall{+destinations,target,values} P126ICtx{params,buffers,ids,tables}:
      p126i_stmts(rest,ctx,p126l_forget(destinations,facts),p126i_call(destinations,target,values,tables,ids,code))
    case P113DAgain{values} P126ICtx{+params,buffers,ids,tables}:
      p126l_moves(params,0,p126l_snapshot(params,values,ids,0,code))
    case P113DScalar{scalar} _:
      p126i_width(head,rest,ctx,facts,code)
    case P113DResult{values} P126ICtx{params,buffers,ids,tables}: p113e_result_emit(values,ids,code)



@unsafe
def p126i_width(+head: P113DStmt, +rest: List<&2,P113DStmt>, +ctx: P126ICtx, +facts: List<&2,P114FLFact>, +code: P111QCode) -> P111QCode:
  match rest ctx:
    case Con{+second,+more} P126ICtx{params,buffers,+ids,tables}:
      nt_choose(P111QCode,p113w_pair(head,second) && p113w_room(code),
        u => p126i_stmts(more,ctx,p126l_kill([head,second],facts),p113w_pair_emit(head,ids,code)),
        u => p126i_width_one(head,rest,ctx,facts,code))
    case _ _: p126i_width_one(head,rest,ctx,facts,code)



@unsafe
def p126i_width_one(head: P113DStmt, +rest: List<&2,P113DStmt>, +ctx: P126ICtx, +facts: List<&2,P114FLFact>, +code: P111QCode) -> P111QCode:
  match head ctx:
    case P113DScalar{+scalar} P126ICtx{params,buffers,ids,tables}:
      p126i_stmts(rest,ctx,p126l_scalar_facts(scalar,facts),p113w_one(P113DScalar{scalar},params,ids,code))
    case _ _: p111q_problem("typed width source is not scalar",code)



@unsafe
def p126i_if(+condition: N111Value, +yes: List<&2,P113DStmt>, +no: List<&2,P113DStmt>, +ctx: P126ICtx, +facts: List<&2,P114FLFact>, +code: P111QCode) -> P111QCode:
  match ctx:
    case P126ICtx{params,buffers,+ids,tables}:
      +diamond = p113bq_direct(yes,no)
      nt_choose(P111QCode,p113bq_ready(diamond,code),u => p113bq_emit(condition,diamond,ids,code),
        u => p126i_if_original(condition,yes,no,ctx,facts,code))



@unsafe
def p126i_if_original(+condition: N111Value, +yes: List<&2,P113DStmt>, +no: List<&2,P113DStmt>, +ctx: P126ICtx, +facts: List<&2,P114FLFact>, code: P111QCode) -> P111QCode:
  match ctx code:
    case P126ICtx{params,buffers,ids,tables} P111QCode{chunks,+site,terminal,error}:
      p126i_if_yes(site,no,ctx,facts,p126i_stmts(yes,ctx,facts,P111QCode{
        Con{p111q_label(site) ++ "\n",Con{"jnz " ++ p111q_value(condition,ids) ++ ", " ++ p111q_label(site) ++ ", " ++ p111q_label(U32.inc(site)) ++ "\n",chunks}},U32.add(site,3),False{},error}))



@unsafe
def p126i_if_yes(+label: U32, +no: List<&2,P113DStmt>, +ctx: P126ICtx, +facts: List<&2,P114FLFact>, yes: P111QCode) -> P111QCode:
  match yes:
    case P111QCode{chunks,next,+terminal,error}:
      +prefix = nt_choose(List<&2,String>,terminal,u => chunks,u => Con{"jmp " ++ p111q_label(U32.add(label,2)) ++ "\n",chunks})
      p111q_if_done(label,terminal,p126i_stmts(no,ctx,facts,P111QCode{Con{p111q_label(U32.inc(label)) ++ "\n",prefix},next,False{},error}))

@unsafe
def p126i_private(function: P113DFunction, +tables: List<&2,P126ITable>, +ids: N111Ids, +buffers: List<&2,String>) -> String:
  match function:
    case P113DFunction{+name,+params,+result,public,+body}:
      +allocas = p113e_allocas(body,["%v_scratch =l alloc8 2048\n"])
      +allocas = nt_choose(List<&2,String>,p113e_multi(body),u => Con{"%p113_results =l alloc8 64\n",allocas},u => allocas)
      +base = nt_choose(String,U32.is_eq(result,1),u => "l %state",u => "l %state, l %p113_result_out")
      "function l $" ++ p113e_symbol(name) ++ "(" ++ p113e_formals(params,base) ++ ") {\n@entry\n" ++
        p144e_body_tail(p126i_stmts(body,P126ICtx{params,buffers,ids,tables},[],
          P111QCode{Con{"",Con{"@p113_loop\n",Con{"jmp @p113_loop\n",allocas}}},0,False{},""}),"}\n")

# Expensive recognition is staged: array refusal, one buffer audit, then only
# bufferless functions need the compact table-call presence walk.

@unsafe
def p126i_with_buffers(+function: P113DFunction, +tables: List<&2,P126ITable>, +ids: N111Ids, +heap_min: U32, +buffers: List<&2,String>) -> String:
  match function:
    case P113DFunction{name,params,result,public,body}:
      nt_choose(String,List.is_empty(&2,String,buffers),
        u => nt_choose(String,p126i_calls(body,tables),
          v => p126i_private(function,tables,ids,buffers),
          v => p113ah_function(function,ids,heap_min)),
        u => p126i_private(function,tables,ids,buffers))


@unsafe
def p126i_emit_one(+function: P113DFunction, +tables: List<&2,P126ITable>, +ids: N111Ids, +heap_min: U32) -> String:
  match function:
    case P113DFunction{name,params,result,public,+body}:
      nt_choose(String,U32.is_eq(p113a_count_body(body,0),0),
        u => p126i_with_buffers(function,tables,ids,heap_min,p114so_buffers(body)),
        u => p113ah_function(function,ids,heap_min))


@unsafe
def p126i_chunks(functions: List<&2,P113DFunction>, +tables: List<&2,P126ITable>, +ids: N111Ids, +heap_min: U32, acc: List<&2,String>) -> List<&2,String>:
  match functions:
    case Nil{}: nt_reverse(String,acc,[])
    case Con{head,rest}: p126i_chunks(rest,tables,ids,heap_min,Con{p126i_emit_one(head,tables,ids,heap_min),acc})


@unsafe
def p126i_control_text(code: P111QCode) -> String:
  match code:
    case P111QCode{chunks,next,terminal,error}: nt_text_finish(chunks,"")


@unsafe
def p126i_control_next(code: P111QCode, +expected: U32) -> Bool:
  match code:
    case P111QCode{chunks,next,terminal,error}:
      U32.is_eq(next,expected) && Bool.not(terminal) && String.is_empty(error)


@unsafe
def p126i_control_row(+name: String, result: Bool) -> String:
  nt_choose(String,result,u => name ++ ":pass",u => name ++ ":FAIL")


@unsafe
def p126i_controls() -> List<&2,String>:
  +ids: N111Ids = N111Ids{missing(),missing()}
  +params: List<&2,NC_Binding> = [NC_Binding{0,"p",N_Imm64{}}]
  +function: P113DFunction = P113DFunction{"selector",params,1,False{},p126s_decision("p",[0,2147483648,1065353216,4294967295],0)}
  +tables = p126i_catalogue([function],[])
  +start: P111QCode = P111QCode{[],7,False{},""}
  +call = p126i_call(["p"],"selector",[N111Local{"p"}],tables,ids,start)
  +text = p126i_control_text(call)
  +unknown = p126i_call(["out"],"unknown",[N111Local{"p"}],tables,ids,start)
  +wide = p126i_control_text(p126i_call(["out"],"selector",[N111Const{0,256}],tables,ids,start))
  +two: List<&2,N111Value> = [N111Const{1,0},N111Const{2,0}]
  +caller: P113DFunction = P113DFunction{"caller",params,1,False{},[P113DCall{["out"],"selector",[N111Local{"p"}]},P113DResult{[N111Local{"out"}]}]}
  [p126i_control_row("table-catalogue",p126i_present(p126i_lookup(tables,"selector"))),
   p126i_control_row("unknown-target",Bool.not(p126i_present(p126i_lookup(tables,"unknown")))),
   p126i_control_row("call-shape",p126i_recognized(["out"],"selector",[N111Local{"p"}],tables)),
   p126i_control_row("wrong-arity",Bool.not(p126i_recognized(["out"],"selector",two,tables))),
   p126i_control_row("multi-result",Bool.not(p126i_recognized(["a","b"],"selector",[N111Local{"p"}],tables))),
   p126i_control_row("full-word-clamp",String.contains(wide,"cultl 1099511627776, 3\n")),
   p126i_control_row("alias-input-before-write",String.contains(text,"%p126_inline_7_index =l copy %v_p\n") && String.contains(text,"%v_p =l loadl %p126_inline_7_addr\n")),
   p126i_control_row("counter-three",p126i_control_next(call,10)),
   p126i_control_row("exact-unknown-fallback",String.eq(p126i_control_text(unknown),p126i_control_text(p113e_call_emit(["out"],"unknown",[N111Local{"p"}],ids,start)))),
   p126i_control_row("exact-arity-fallback",String.eq(p126i_control_text(p126i_call(["out"],"selector",two,tables,ids,start)),p126i_control_text(p113e_call_emit(["out"],"selector",two,ids,start)))),
   p126i_control_row("table-global-retained",String.eq(p126i_emit_one(function,tables,ids,0),p126s_emit(function))),
   p126i_control_row("nonfloat-caller-selected",String.contains(p126i_emit_one(caller,tables,ids,0),"%p126_inline_0_addr =l add $" ++ p126i_table_name("selector")))]

@unsafe
def p126bp_fields(terms: List<&2,KTerm>) -> Bool:
  match terms:
    case Nil{}: True{}
    case Con{+head,rest}:
      String.eq(tg(head),"Var") && p126bp_fields(rest)


@unsafe
def p126bp_shape(+info: KDef, +params: List<&2,NC_Binding>, +wrapper: KTerm) -> Bool:
  String.eq(tg(dv(info)),"NQSig") && p113p_known(dt(info)) &&
    Bool.not(nq_has_shape(ks(dv(info)))) && U32.is_eq(terms_len(ks(dv(info))),nt_count(NC_Binding,params)) &&
    (String.eq(tg(wrapper),"Ctr") || String.eq(tg(wrapper),"NCtr")) &&
    String.eq(nm(wrapper),nm(dt(info))) && U32.is_eq(terms_len(ks(wrapper)),ix(dt(info))) &&
    p126bp_fields(ks(wrapper))


@unsafe
def p126bp_flat(+owner: String, +params: List<&2,NC_Binding>, +schema: NO_Schema, +info: KDef) -> List<&2,P113DFunction>:
  +env : List<&2,NC_Binding> = Con{NC_Binding{no_schema_result(schema),"p118b_observation",N_W64{}},params}
  [P113DFunction{nm(dv(info)),params,ix(dt(info)),False{},[
    P113DCall{["p118b_observation"],p118b_read_name(owner),p111_env_words(params)},
    P113DResult{p111_values(ks(no_schema_wrapper(schema)),env)}]}]


@unsafe
def p126bp_extra(+book: List<&2,KDef>, +owner: String, +plan: NO_Plan) -> List<&2,P113DFunction>:
  +schema = no_plan_schema(plan)
  +params = no_plan_params(no_schema_params(schema))
  +info = nq_signature_def(book,owner)
  nt_choose(List<&2,P113DFunction>,p126bp_shape(info,params,no_schema_wrapper(schema)) &&
    String.eq(nm(dv(info)),"$product." ++ owner),
    u => p126bp_flat(owner,params,schema,info),u => [])

# Exact original reader and owning boxed adapter remain first, in their old order.

@unsafe
def p126bp_original_functions(+book: List<&2,KDef>, +owner: String, +plan: NO_Plan) -> P118BWorkers:
  +schema = no_plan_schema(plan)
  +params = no_plan_params(no_schema_params(schema))
  +reader = p118b_lower(noa_body(no_plan_analysis(plan)),params,params,no_schema_specs_layouts(no_schema_specs(schema)),0)
  +result = no_schema_result(schema)
  +env : List<&2,NC_Binding> = Con{NC_Binding{result,"p118b_observation",N_W64{}},params}
  +wrapper = p118b_eval(no_schema_wrapper(schema),env,0)
  +adapter : List<&2,P113DStmt> = Con{P113DCall{["p118b_observation"],p118b_read_name(owner),p111_env_words(params)},
    nt_append(P113DStmt,p113d_body(wrapper),[P113DResult{[N111Local{p118b_value_name(0)}]}])}
  P118BWorkers{[
    P113DFunction{p118b_read_name(owner),params,1,False{},p113d_body(reader)},
    P113DFunction{p113d_public(book,owner),params,1,True{},adapter}],
    p111_first(p113d_error(reader),p113d_error(wrapper))}


@unsafe
def p126bp_extend(+book: List<&2,KDef>, +owner: String, +plan: NO_Plan, +original: P118BWorkers) -> P118BWorkers:
  match original:
    case P118BWorkers{functions,+error}:
      nt_choose(P118BWorkers,String.is_empty(error),
        u => P118BWorkers{nt_append(P113DFunction,functions,p126bp_extra(book,owner,plan)),error},u => original)


@unsafe
def p126bp_has_flat(functions: List<&2,P113DFunction>) -> Bool:
  match functions:
    case Nil{}: False{}
    case Con{P113DFunction{+name,params,result,public,body},rest}:
      nt_choose(Bool,String.starts_with(name,"$product."),u => True{},u => p126bp_has_flat(rest))


@unsafe
def p126bp_complete(+original: P112StaticProgram, +certificate: P113ACertificate, +functions: List<&2,P113DFunction>) -> P111Emission:
  match original:
    case P112StaticProgram{+program,nodes}:
      +direct : P113DProgram = P113DProgram{original,functions}
      +assembled : P113AProgram = P113AProgram{direct,certificate}
      +checked = p114t_verify_done(assembled,p113a_verify_after(direct,certificate,p118b_verify_functions(functions,program)))
      nt_choose(P111Emission,String.is_empty(checked),
        u => P134Planned{P134Admitted{assembled}},
        u => P111Emission{[],"flat observer closure: " ++ checked})

@unsafe
def p126bp_close(+request: NR_Request, original: P113AProgram, +added: List<&2,P113DFunction>) -> P111Emission:
  match original:
    case P113AProgram{P113DProgram{+static,+functions},+certificate}:
      +merged = nt_append(P113DFunction,added,p118b_without(functions,p113e_signatures(added,missing())))
      p126bp_complete(static,certificate,
        p113d_passes(p113pl_inspect_request(request),p113e_signatures(merged,missing()),
          nt_reverse(P113DFunction,merged,[]),32))


@unsafe
def p126bp_workers(+request: NR_Request, +original: P113AProgram, +workers: P118BWorkers) -> P111Emission:
  match original workers:
    case P113AProgram{P113DProgram{P112StaticProgram{+program,nodes},functions},certificate} P118BWorkers{+added,+error}:
      +checked = p111_first(error,p118b_verify_functions(added,program))
      nt_choose(P111Emission,String.is_empty(checked),
        u => nt_choose(P111Emission,p126bp_has_flat(added),
          v => p126bp_close(request,original,added),v => p118b_compose(original,workers)),
        u => P111Emission{[],"flat observer workers: " ++ checked})


@unsafe
def p126bp_plan(+original: P113AProgram, +plan: P118BPlan) -> P111Emission:
  match plan:
    case P118BPlan{request,names,error}: p126bp_workers(request,original,p118b_new_functions(plan))


@unsafe
def p126bp_controls() -> List<&2,String>:
  [p126bpc_row("exact-flat-constructor",p126bpc_allowed(p126bpc_tuple(),[{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}],p126bpc_wrapper())),
   p126bpc_row("constant-field-refused",Bool.not(p126bpc_allowed(p126bpc_tuple(),[{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}],kt("NCtr","Tuple",0,0,[var("",1),kt("NWord","",7,0,[])])))),
   p126bpc_row("input-flattening-refused",Bool.not(p126bpc_allowed(p126bpc_tuple(),[p126bpc_tuple(),{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}],p126bpc_wrapper()))),
   p126bpc_row("input-count-refused",Bool.not(p126bpc_allowed(p126bpc_tuple(),[{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}],p126bpc_wrapper()))),
   p126bpc_row("opaque-result-refused",Bool.not(p126bpc_allowed({KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},[{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}],p126bpc_wrapper()))),
   p126bpc_row("constructor-mismatch-refused",Bool.not(p126bpc_allowed(kt("NQShape","Different",2,0,[]),[{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}],p126bpc_wrapper()))),
   p126bpc_row("field-count-refused",Bool.not(p126bpc_allowed(kt("NQShape","Tuple",3,0,[]),[{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}],p126bpc_wrapper()))),
   p126bpc_row("nested-constructor-refused",Bool.not(p126bpc_allowed(p126bpc_tuple(),[{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}],kt("NCtr","Tuple",0,0,[var("",1),kt("NCtr","Node",0,0,[var("",3)])])))),
   p126bpc_row("primitive-field-refused",Bool.not(p126bpc_allowed(p126bpc_tuple(),[{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}],kt("NCtr","Tuple",0,0,[var("",1),kt("NOp","u32_add",0,0,[var("",2),var("",3)])])))),
   p126bpc_row("full-function-verification",String.is_empty(p126bpc_verify())),
   p126bpc_row("wrong-reader-result-abi-refused",Bool.not(String.is_empty(p126bpc_wrong_result())))]

@unsafe
def p126bp_integrated(+request: NR_Request, +original: P113AProgram, +workers: P118BWorkers) -> P111Emission:
  match workers:
    case P118BWorkers{functions,+error}:
      nt_choose(P111Emission,String.is_empty(error) && p126bp_has_flat(functions),
        u => p126bp_workers(request,original,workers),
        u => p118e_emit_workers(original,workers))

# The scalar-permitted path retains its exact original cold-metadata derivation.

@unsafe
def p126dp_original_let(+book: List<&2,KDef>, +value: KTerm, +body: KTerm, +env: List<&2,NC_Binding>, +id: U32, +target: P113PTarget, +n: U32) -> P113DCode:
  +shape = nt_choose(KTerm,String.eq(tg(value),"NPCall"),
    u => nq_call_shape(book,nm(value),ks(value),p113pl_view(target)),
    u => nq_value_shape(book,value,p113pl_view(target)))
  nt_choose(P113DCode,p113p_known(shape) && p113p_bindable(body,id),
    u => p113pl_bind_flat(book,value,body,env,id,target,n,shape),
    u => p113pl_bind_boxed(book,value,body,env,id,target,n))


@unsafe
def p126dp_original_live_let(+book: List<&2,KDef>, +value: KTerm, +rest: P112Liveness, +env: List<&2,NC_Binding>, +id: U32, +target: P113PTarget, +n: U32) -> P113DCode:
  +shape = nt_choose(KTerm,String.eq(tg(value),"NPCall"),
    u => nq_call_shape(book,nm(value),ks(value),p113pl_view(target)),
    u => nq_value_shape(book,value,p113pl_view(target)))
  nt_choose(P113DCode,p113p_known(shape),
    u => p113px_known(book,value,rest,env,id,target,n,shape),
    u => p113px_boxed(book,value,rest,env,id,target,n))


@unsafe
def p126dp_original_primitive(+name: String, +values: List<&2,N111Value>, +wanted: KTerm, +n: U32) -> P113PValueCode:
  nt_choose(P113PValueCode,p113p_array_pair(name,nt_count(N111Value,values)) && p113p_known(wanted) && String.eq(nm(wanted),"Tuple") && U32.is_eq(ix(wanted),2),
    u => p113p_pair_code(p111_op_id(name),values,n),
    u => nt_choose(P113PValueCode,p113p_known(wanted),
      v => P113PValueCode{[],[],"primitive product shape unsupported"},
      v => p113p_boxed(p113ai_intrinsic(name,values,n))))


@unsafe
def p126dp_original_scalar_safe(+stmt: N111Stmt) -> Bool:
  match stmt:
    case N111Call{name,N111U64{},+symbol,+args}:
      nt_choose(Bool,String.eq(symbol,"p125_rt_concat_typed"),u => p113e_runtime_args(args),u => p125p_previous_scalar_safe(stmt))
    case _: p125p_previous_scalar_safe(stmt)


@unsafe
def p126dp_original_stmt(+stmt: P113DStmt, +schema: KDef, +live: KDef, +ids: N111Ids, +ready: KDef, +arity: U32, +result: U32) -> P111VFlow:
  match stmt:
    case P113DScalar{N111Call{+name,+typ,+symbol,+args}}:
      nt_choose(P111VFlow,String.eq(symbol,"p125_rt_concat_typed"),u => p125p_import(name,typ,args,schema,live,ids),
        u => p125p_previous_stmt(stmt,schema,live,ids,ready,arity,result))
    case _: p125p_previous_stmt(stmt,schema,live,ids,ready,arity,result)


@unsafe
def p126dp_value_shape(+book: List<&2,KDef>, +value: KTerm, +target: NC_Target) -> KTerm:
  nt_choose(KTerm,String.eq(tg(value),"NOp") && U32.is_eq(p111_op_id(nm(value)),70) && U32.is_eq(terms_len(ks(value)),2),
    u => kt("NQShape","Tuple",2,0,[]),
    u => nt_choose(KTerm,String.eq(tg(value),"App"),
      v => nt_choose(KTerm,U32.is_eq(p111_op_id(nd_native_call(book,value)),70),
        w => kt("NQShape","Tuple",2,0,[]),w => nq_value_shape(book,value,target)),
      v => nq_value_shape(book,value,target)))

@unsafe
def p126dp_code(+left: N111Value, +right: N111Value, +n: U32) -> P113PValueCode:
  +out = "p126dp_out_" ++ U32.show(n)
  +first = "p126dp_first_" ++ U32.show(n)
  +second = "p126dp_second_" ++ U32.show(n)
  P113PValueCode{[
    N111Alloca{out,16,8},
    N111Call{"p126dp_status_" ++ U32.show(n),N111U64{},"p126_rt_nat_divmod",
      [p111_state(),p111_word(left),p111_word(right),N111Arg{N111Ptr{},N111Local{out}}]},
    N111Load{first,N111U64{},N111Local{out},0},
    N111Load{second,N111U64{},N111Local{out},8}],
    [N111Local{first},N111Local{second}],""}


@unsafe
def p126dp_selected(+name: String, +values: List<&2,N111Value>, +wanted: KTerm) -> Bool:
  U32.is_eq(p111_op_id(name),70) && U32.is_eq(nt_count(N111Value,values),2) &&
    p113p_known(wanted) && String.eq(nm(wanted),"Tuple") && U32.is_eq(ix(wanted),2)


@unsafe
def p126dp_import(+name: String, +typ: N111Type, +args: List<&2,N111Arg>, +schema: KDef, +live: KDef, +ids: N111Ids) -> P111VFlow:
  p111v_step(U32.is_eq(p111v_type(typ),2) && p113e_runtime_args(args) &&
    p111v_args(args,[3,2,2,3],live,ids) && p111v_memory(p111v_arg(args,3),8,2,live,ids),
    name,schema,live,"Nat.divmod product import signature/output capacity mismatch")


@unsafe
def p126dp_controls() -> List<&2,String>:
  [p126dpc_row("local-shape-admitted",p126dpc_shape(kt("NOp","nat_divmod",0,0,[var("",1),var("",2)]))),
   p126dpc_row("local-wrong-arity-refused",Bool.not(p126dpc_shape(kt("NOp","nat_divmod",0,0,[var("",1)])))),
   p126dpc_row("shared-C-predicate-unchanged",Bool.not(nq_pair_primitive("nat_divmod"))),
   p126dpc_row("exact-product-selected",p126dp_selected("nat_divmod",[N111Const{0,0},N111Const{0,0}],p126dpc_tuple())),
   p126dpc_row("full64-operands-selected",p126dp_selected("nat_divmod",[N111Const{4294967295,65535},N111Const{33,0}],p126dpc_tuple())),
   p126dpc_row("wrong-operation-refused",Bool.not(p126dp_selected("nat_add",[N111Const{0,0},N111Const{0,0}],p126dpc_tuple()))),
   p126dpc_row("wrong-arity-refused",Bool.not(p126dp_selected("nat_divmod",[N111Const{0,0}],p126dpc_tuple()))),
   p126dpc_row("opaque-result-refused",Bool.not(p126dp_selected("nat_divmod",[N111Const{0,0},N111Const{0,0}],{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}))),
   p126dpc_row("wrong-constructor-refused",Bool.not(p126dp_selected("nat_divmod",[N111Const{0,0},N111Const{0,0}],kt("NQShape","Other",2,0,[])))),
   p126dpc_row("wrong-width-refused",Bool.not(p126dp_selected("nat_divmod",[N111Const{0,0},N111Const{0,0}],kt("NQShape","Tuple",1,0,[])))),
   p126dpc_row("generated-function-verifies",String.is_empty(p126dpc_code(p126dp_code(N111Local{"a"},N111Local{"b"},7)))),
   p126dpc_row("exact-output-buffer",String.is_empty(p126dpc_import(16,"out",N111U64{}))),
   p126dpc_row("small-output-refused",Bool.not(String.is_empty(p126dpc_import(8,"out",N111U64{})))),
   p126dpc_row("state-output-refused",Bool.not(String.is_empty(p126dpc_import(16,"state",N111U64{})))),
   p126dpc_row("missing-output-refused",Bool.not(String.is_empty(p126dpc_import(16,"missing",N111U64{})))),
   p126dpc_row("wrong-result-width-refused",Bool.not(String.is_empty(p126dpc_import(16,"out",N111U32{}))))]

@unsafe
def p126sc_name(function: P113DFunction) -> String:
  match function:
    case P113DFunction{name,params,result,public,body}: name


@unsafe
def p126sc_params(function: P113DFunction) -> List<&2,NC_Binding>:
  match function:
    case P113DFunction{name,params,result,public,body}: params


@unsafe
def p126sc_body(function: P113DFunction) -> List<&2,P113DStmt>:
  match function:
    case P113DFunction{name,params,result,public,body}: body


@unsafe
def p126sc_shape(function: P113DFunction) -> Bool:
  match function:
    case P113DFunction{name,+params,result,public,body}:
      U32.is_eq(result,1) && U32.is_le(nt_count(NC_Binding,params),8)


@unsafe
def p126sc_has(names: List<&2,String>, +name: String) -> Bool:
  match names:
    case Nil{}: False{}
    case Con{head,rest}: nt_choose(Bool,String.eq(head,name),u => True{},u => p126sc_has(rest,name))


@unsafe
def p126sc_internal(+name: String, +left: String, +right: String) -> Bool:
  String.eq(name,left) || String.eq(name,right)

# The whole residual block must be exactly Result([the call destination]).

@unsafe
def p126sc_tail(destinations: List<&2,String>, rest: List<&2,P113DStmt>) -> Bool:
  match destinations rest:
    case Con{name,Nil{}} Con{P113DResult{Con{N111Local{word},Nil{}}},Nil{}}: String.eq(name,word)
    case _ _: False{}


@unsafe
def p126sc_safe(body: List<&2,P113DStmt>, +left: String, +right: String, +la: U32, +ra: U32, +self_arity: U32) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{P113DCall{+destinations,+target,+args},+rest}:
      nt_choose(Bool,p126sc_internal(target,left,right),
        u => p126sc_tail(destinations,rest) && U32.is_eq(nt_count(N111Value,args),nt_choose(U32,String.eq(target,left),v => la,v => ra)),
        u => p126sc_safe(rest,left,right,la,ra,self_arity))
    case Con{P113DIf{condition,yes,no},rest}:
      p126sc_safe(yes,left,right,la,ra,self_arity) && p126sc_safe(no,left,right,la,ra,self_arity) && p126sc_safe(rest,left,right,la,ra,self_arity)
    case Con{P113DAgain{values},rest}: U32.is_eq(nt_count(P113DStmt,rest),0) && U32.is_eq(nt_count(N111Value,values),self_arity)
    case Con{stmt,rest}: p126sc_safe(rest,left,right,la,ra,self_arity)


@unsafe
def p126sc_pair_safe(+left: P113DFunction, +right: P113DFunction) -> Bool:
  +ln = p126sc_name(left)
  +rn = p126sc_name(right)
  +la = nt_count(NC_Binding,p126sc_params(left))
  +ra = nt_count(NC_Binding,p126sc_params(right))
  nt_choose(Bool,Bool.not(String.eq(ln,rn)) && p126sc_shape(left) && p126sc_shape(right),
    u => nt_choose(Bool,p126sc_has(p113j_calls(p126sc_body(left)),rn) && p126sc_has(p113j_calls(p126sc_body(right)),ln),
      v => p126sc_safe(p126sc_body(left),ln,rn,la,ra,la) && p126sc_safe(p126sc_body(right),ln,rn,la,ra,ra),
      v => False{}),u => False{})


@unsafe
def p126sc_zeros(count: U32) -> List<&2,N111Value>:
  match count:
    case 0: []
    case _: Con{N111Const{0,0},p126sc_zeros(U32.sub(count,1))}


@unsafe
def p126sc_lanes(+tag: U32, +args: List<&2,N111Value>, +width: U32) -> List<&2,N111Value>:
  Con{N111Const{tag,0},nt_append(N111Value,args,p126sc_zeros(U32.sub(width,nt_count(N111Value,args))))}


@unsafe
def p126sc_lane_params(+count: U32, +index: U32) -> List<&2,NC_Binding>:
  nt_choose(List<&2,NC_Binding>,U32.is_eq(count,index),u => [],u =>
    Con{NC_Binding{index,"p126scc_arg_" ++ U32.show(index),N_W64{}},p126sc_lane_params(count,U32.inc(index))})


@unsafe
def p126sc_param_values(params: List<&2,NC_Binding>) -> List<&2,N111Value>:
  match params:
    case Nil{}: []
    case Con{NC_Binding{id,word,kind},rest}: Con{N111Local{word},p126sc_param_values(rest)}


@unsafe
def p126sc_bind(params: List<&2,NC_Binding>, +prefix: String, +index: U32) -> List<&2,P113DStmt>:
  match params:
    case Nil{}: []
    case Con{NC_Binding{id,word,kind},rest}:
      Con{P113DScalar{N111Set{p112f_name(prefix,word),N111U64{},N111Local{"p126scc_arg_" ++ U32.show(index)}}},p126sc_bind(rest,prefix,U32.inc(index))}


@unsafe
def p126sc_rewrite(body: List<&2,P113DStmt>, +prefix: String, +left: String, +right: String, +self_tag: U32, +width: U32) -> List<&2,P113DStmt>:
  match body:
    case Nil{}: []
    case Con{P113DScalar{stmt},rest}:
      Con{P113DScalar{p112f_stmt(stmt,prefix)},p126sc_rewrite(rest,prefix,left,right,self_tag,width)}
    case Con{P113DIf{condition,yes,no},rest}:
      Con{P113DIf{p112f_value(condition,prefix),p126sc_rewrite(yes,prefix,left,right,self_tag,width),p126sc_rewrite(no,prefix,left,right,self_tag,width)},p126sc_rewrite(rest,prefix,left,right,self_tag,width)}
    case Con{P113DCall{destinations,+target,+args},+rest}:
      nt_choose(List<&2,P113DStmt>,p126sc_internal(target,left,right),
        u => [P113DAgain{p126sc_lanes(nt_choose(U32,String.eq(target,left),v => 0,v => 1),p113j_values(args,prefix),width)}],
        u => Con{P113DCall{p113j_names(destinations,prefix),target,p113j_values(args,prefix)},p126sc_rewrite(rest,prefix,left,right,self_tag,width)})
    case Con{P113DResult{values},rest}: Con{P113DResult{p113j_values(values,prefix)},p126sc_rewrite(rest,prefix,left,right,self_tag,width)}
    case Con{P113DAgain{values},rest}: [P113DAgain{p126sc_lanes(self_tag,p113j_values(values,prefix),width)}]


@unsafe
def p126sc_external(calls: List<&2,String>, +left: String, +right: String) -> List<&2,String>:
  match calls:
    case Nil{}: []
    case Con{+name,+rest}: nt_choose(List<&2,String>,p126sc_internal(name,left,right),u => p126sc_external(rest,left,right),u => Con{name,p126sc_external(rest,left,right)})


@unsafe
def p126sc_worker(+left: P113DFunction, +right: P113DFunction, +name: String) -> P113DCandidate:
  +ln = p126sc_name(left)
  +rn = p126sc_name(right)
  +lb = p126sc_body(left)
  +rb = p126sc_body(right)
  +width = U32.max(nt_count(NC_Binding,p126sc_params(left)),nt_count(NC_Binding,p126sc_params(right)))
  +params : List<&2,NC_Binding> = Con{NC_Binding{4294967295,"p126scc_tag",N_W64{}},p126sc_lane_params(width,0)}
  +yes = nt_append(P113DStmt,p126sc_bind(p126sc_params(left),"p113i_14_",0),p126sc_rewrite(lb,"p113i_14_",ln,rn,0,width))
  +no = nt_append(P113DStmt,p126sc_bind(p126sc_params(right),"p113i_15_",0),p126sc_rewrite(rb,"p113i_15_",ln,rn,1,width))
  +body : List<&2,P113DStmt> = nt_append(P113DStmt,p113j_scratch_alloc(lb,"p113i_14_"),nt_append(P113DStmt,p113j_scratch_alloc(rb,"p113i_15_"),[
    P113DScalar{N111Bin{"p126scc_side",N111U64{},"eq",N111Local{"p126scc_tag"},N111Const{0,0}}},P113DIf{N111Local{"p126scc_side"},yes,no}]))
  P113DCandidate{P113DFunction{name,params,1,False{},body},"",p126sc_external(nt_append(String,p113j_calls(lb),p113j_calls(rb)),ln,rn)}


@unsafe
def p126sc_wrapper(function: P113DFunction, +worker: String, +tag: U32, +width: U32) -> P113DCandidate:
  match function:
    case P113DFunction{name,+params,result,public,body}:
      P113DCandidate{P113DFunction{name,params,result,public,[
        P113DCall{["p126scc_result"],worker,p126sc_lanes(tag,p126sc_param_values(params),width)},
        P113DResult{[N111Local{"p126scc_result"}]}]},"",[worker]}

@unsafe
def p126sc_call_terms(calls: List<&2,String>) -> List<&2,KTerm>:
  match calls:
    case Nil{}: []
    case Con{name,rest}: Con{kt("Ref",name,0,0,[]),p126sc_call_terms(rest)}


@unsafe
def p126sc_call_has(calls: List<&2,KTerm>, +name: String) -> Bool:
  match calls:
    case Nil{}: False{}
    case Con{head,rest}: nt_choose(Bool,String.eq(nm(head),name),u => True{},u => p126sc_call_has(rest,name))


@unsafe
def p126sc_counts(candidates: List<&2,P113DCandidate>, +counts: KDef, +slot: U32) -> KDef:
  match candidates:
    case Nil{}: counts
    case Con{P113DCandidate{function,error,calls},rest}:
      +name = p126sc_name(function)
      p126sc_counts(rest,index_set(counts,KDef{name,"P126Count",U32.inc(da(p111v_get(counts,name))),slot,{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},kt("Calls","",0,0,p126sc_call_terms(calls)),[],False{},False{}},index_hash(name,2166136261),32),U32.inc(slot))


@unsafe
def p126sc_index(candidates: List<&2,P113DCandidate>, +counts: KDef, +index: P113ITable) -> P113ITable:
  match candidates:
    case Nil{}: index
    case Con{P113DCandidate{+function,+error,calls},+rest}:
      +name = p126sc_name(function)
      nt_choose(P113ITable,String.is_empty(error) && p126sc_shape(function) && U32.is_eq(da(p111v_get(counts,name)),1),
        u => p126sc_index(rest,counts,p113i_put(index,function,index_hash(name,2166136261),0)),
        u => p126sc_index(rest,counts,index))


@unsafe
def p126sc_partner_try(+left: P113DFunction, +counts: KDef, +slot: U32, +done: KDef, found: Maybe<&2,P113DFunction>) -> Maybe<&2,P113DFunction>:
  match found:
    case None{}: None{}
    case Some{+right}:
      nt_choose(Maybe<&2,P113DFunction>,String.eq(dk(p111v_get(done,p126sc_name(right))),"Absent") && U32.is_gt(dx(p111v_get(counts,p126sc_name(right))),slot) && p126sc_call_has(ks(dv(p111v_get(counts,p126sc_name(right)))),p126sc_name(left)),
        u => nt_choose(Maybe<&2,P113DFunction>,p126sc_pair_safe(left,right),v => Some{right},v => None{}),u => None{})


law p126sc_partner:
  for +calls: List<&2,String>
  for +left: P113DFunction
  for +index: P113ITable
  for +counts: KDef
  for +slot: U32
  for +done: KDef
  Maybe<&2,P113DFunction>

@unsafe
def p126sc_partner(calls,left,index,counts,slot,done):
  match calls:
    case Nil{}: None{}
    case Con{+name,rest}: p126sc_partner_next(rest,left,index,counts,slot,done,p126sc_partner_try(left,counts,slot,done,p113i_get(index,name,index_hash(name,2166136261),0)))


@unsafe
def p126sc_partner_next(+calls: List<&2,String>, +left: P113DFunction, +index: P113ITable, +counts: KDef, +slot: U32, +done: KDef, found: Maybe<&2,P113DFunction>) -> Maybe<&2,P113DFunction>:
  match found:
    case None{}: p126sc_partner(calls,left,index,counts,slot,done)
    case Some{right}: Some{right}


law p126sc_walk:
  for +candidates: List<&2,P113DCandidate>
  for +index: P113ITable
  for +counts: KDef
  for +done: KDef
  for +slot: U32
  for +acc: List<&2,P113DCandidate>
  List<&2,P113DCandidate>

@unsafe
def p126sc_walk(candidates,index,counts,done,slot,acc):
  match candidates:
    case Nil{}: nt_reverse(P113DCandidate,acc,[])
    case Con{candidate,rest}: p126sc_one(candidate,rest,index,counts,done,slot,acc)


@unsafe
def p126sc_found(+candidate: P113DCandidate, +left: P113DFunction, +rest: List<&2,P113DCandidate>, +index: P113ITable, +counts: KDef, +done: KDef, +slot: U32, +acc: List<&2,P113DCandidate>, found: Maybe<&2,P113DFunction>) -> List<&2,P113DCandidate>:
  match found:
    case None{}: p126sc_walk(rest,index,counts,done,U32.inc(slot),Con{candidate,acc})
    case Some{+right}:
      +worker = "$p126scc." ++ U32.show(slot)
      +width = U32.max(nt_count(NC_Binding,p126sc_params(left)),nt_count(NC_Binding,p126sc_params(right)))
      nt_choose(List<&2,P113DCandidate>,String.eq(dk(p111v_get(counts,worker)),"Absent"),
        u => p126sc_walk(rest,index,counts,p111v_put(p111v_put(done,p126sc_name(left),"P126Used",0,0),p126sc_name(right),"P126Used",0,0),U32.inc(slot),
          Con{p126sc_wrapper(right,worker,1,width),Con{p126sc_wrapper(left,worker,0,width),Con{p126sc_worker(left,right,worker),acc}}}),
        u => p126sc_walk(rest,index,counts,done,U32.inc(slot),Con{candidate,acc}))


@unsafe
def p126sc_one(+candidate: P113DCandidate, +rest: List<&2,P113DCandidate>, +index: P113ITable, +counts: KDef, +done: KDef, +slot: U32, +acc: List<&2,P113DCandidate>) -> List<&2,P113DCandidate>:
  match candidate:
    case P113DCandidate{+function,+error,+calls}:
      +name = p126sc_name(function)
      nt_choose(List<&2,P113DCandidate>,String.eq(dk(p111v_get(done,name)),"Absent"),
        u => nt_choose(List<&2,P113DCandidate>,String.is_empty(error) && p126sc_shape(function) && U32.is_eq(da(p111v_get(counts,name)),1),
          v => p126sc_found(candidate,function,rest,index,counts,done,slot,acc,p126sc_partner(calls,function,index,counts,slot,done)),
          v => p126sc_walk(rest,index,counts,done,U32.inc(slot),Con{candidate,acc})),
        u => p126sc_walk(rest,index,counts,done,U32.inc(slot),acc))


@unsafe
def p126sc_candidates_counted(+candidates: List<&2,P113DCandidate>, +counts: KDef) -> List<&2,P113DCandidate>:
  p126sc_walk(candidates,p126sc_index(candidates,counts,P113IEmpty{}),counts,missing(),0,[])


@unsafe
def p126sc_candidates(+candidates: List<&2,P113DCandidate>) -> List<&2,P113DCandidate>:
  p126sc_candidates_counted(candidates,p126sc_counts(candidates,missing(),0))

@unsafe
def p126sc_row(+name: String, ok: Bool) -> String:
  nt_choose(String,ok,u => name ++ ":pass",u => name ++ ":FAIL")


@unsafe
def p126sc_test_function(+name: String, +other: String) -> P113DFunction:
  P113DFunction{name,[NC_Binding{0,"x",N_W64{}},NC_Binding{1,"y",N_W64{}}],1,False{},[
    P113DScalar{N111Bin{"stop",N111U64{},"eq",N111Local{"x"},N111Const{0,0}}},
    P113DIf{N111Local{"stop"},[P113DResult{[N111Local{"y"}]}],[P113DCall{["answer"],other,[N111Local{"y"},N111Local{"x"}]},P113DResult{[N111Local{"answer"}]}]}]}


@unsafe
def p126sc_test_candidate(+function: P113DFunction) -> P113DCandidate:
  P113DCandidate{function,"",p113j_calls(p126sc_body(function))}


@unsafe
def p126sc_test_functions(candidates: List<&2,P113DCandidate>) -> List<&2,P113DFunction>:
  match candidates:
    case Nil{}: []
    case Con{P113DCandidate{function,error,calls},rest}: Con{function,p126sc_test_functions(rest)}


@unsafe
def p126sc_full_word(values: List<&2,N111Value>) -> Bool:
  match values:
    case Con{N111Const{1,0},Con{N111Const{4294967295,4294967295},Con{N111Const{0,256},Con{N111Const{0,0},Nil{}}}}}: True{}
    case _: False{}


@unsafe
def p126sc_controls() -> List<&2,String>:
  +left = p126sc_test_function("a","b")
  +right = p126sc_test_function("b","a")
  +ca = p126sc_test_candidate(left)
  +cb = p126sc_test_candidate(right)
  +merged = p126sc_candidates([ca,cb])
  +ids : N111Ids = N111Ids{missing(),missing()}
  +params = p126sc_params(left)
  +nonterminal : P113DFunction = P113DFunction{"a",params,1,False{},[
    P113DCall{["z"],"b",[N111Local{"x"},N111Local{"y"}]},P113DScalar{N111Set{"extra",N111U64{},N111Local{"z"}}},P113DResult{[N111Local{"extra"}]}]}
  +wrong_result : P113DFunction = P113DFunction{"a",params,1,False{},[
    P113DCall{["z"],"b",[N111Local{"x"},N111Local{"y"}]},P113DResult{[N111Local{"x"}]}]}
  +wrong_arity : P113DFunction = P113DFunction{"a",params,1,False{},[
    P113DCall{["z"],"b",[N111Local{"x"}]},P113DResult{[N111Local{"z"}]}]}
  +multi : P113DFunction = P113DFunction{"a",params,2,False{},p126sc_body(left)}
  +oneway = p126sc_test_function("b","outside")
  +collision = p126sc_test_candidate(p126sc_test_function("$p126scc.0","outside"))
  [p126sc_row("pair-tail-admitted",p126sc_pair_safe(left,right)),
   p126sc_row("nonterminal-refused",Bool.not(p126sc_pair_safe(nonterminal,right))),
   p126sc_row("different-result-refused",Bool.not(p126sc_pair_safe(wrong_result,right))),
   p126sc_row("wrong-arity-refused",Bool.not(p126sc_pair_safe(wrong_arity,right))),
   p126sc_row("multi-result-refused",Bool.not(p126sc_pair_safe(multi,right))),
   p126sc_row("one-way-refused",Bool.not(p126sc_pair_safe(left,oneway))),
   p126sc_row("three-candidates",U32.is_eq(nt_count(P113DCandidate,merged),3)),
   p126sc_row("unchanged-verifier",String.is_empty(p113e_functions(p126sc_test_functions(merged),ids,missing()))),
   p126sc_row("duplicate-name-fallback",U32.is_eq(nt_count(P113DCandidate,p126sc_candidates([ca,ca,cb])),3)),
   p126sc_row("generated-name-collision-fallback",U32.is_eq(nt_count(P113DCandidate,p126sc_candidates([ca,cb,collision])),3)),
   p126sc_row("single-candidate-fallback",U32.is_eq(nt_count(P113DCandidate,p126sc_candidates([ca])),1)),
   p126sc_row("full-u64-lanes",p126sc_full_word(p126sc_lanes(1,[N111Const{4294967295,4294967295},N111Const{0,256}],3))),
   p126sc_row("self-tail-accepted",p126sc_safe([P113DAgain{[N111Local{"x"},N111Local{"y"}]}],"a","b",2,2,2)),
   p126sc_row("self-tail-arity-refused",Bool.not(p126sc_safe([P113DAgain{[N111Local{"x"}]}],"a","b",2,2,2))),
   p126sc_row("external-dependency-preserved",p126sc_has(p126sc_external(["a","outside","b"],"a","b"),"outside")),
   p126sc_row("internal-dependencies-removed",U32.is_eq(nt_count(String,p126sc_external(["a","b","a"],"a","b")),0))]

@unsafe
def p126dpa_native(+builtin: Bool, +arity: U32, +mode: U32) -> Bool:
  +d : KDef = KDef{"Nat.divmod","Def",2,0,{KTerm{"Type", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},{KTerm{"Body", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},[],builtin,False{}}
  p113p_known(p126dp_value_shape([d],nd_reapply(kt("Ref","Nat.divmod",0,mode,[]),nc_prim_args(arity,0)),NC_Scheduler{}))


@unsafe
def p126dp_app_controls() -> List<&2,String>:
  [p126dpc_row("app-authenticated-native",p126dpa_native(True{},2,0)),
   p126dpc_row("app-ordinary-lookalike-refused",Bool.not(p126dpa_native(False{},2,0))),
   p126dpc_row("app-partial-refused",Bool.not(p126dpa_native(True{},1,0))),
   p126dpc_row("app-overapplied-refused",Bool.not(p126dpa_native(True{},3,0))),
   p126dpc_row("app-bang-refused",Bool.not(p126dpa_native(True{},2,3)))]
