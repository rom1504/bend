

@unsafe
def p118b_read_name(owner: String) -> String:
  "$p118borrow.read." ++ owner


@unsafe
def p118b_value_name(n: U32) -> String:
  "p118b_value_" ++ U32.show(n)


@unsafe
def p118b_root_once(+wrapper: KTerm, params: List<&2,KTerm>, +roots: List<&2,U32>, +i: U32) -> Bool:
  match params:
    case Nil{}: True{}
    case Con{p,rest}:
      (Bool.not(no_root_index(roots,i)) || U32.is_eq(nq_uses(wrapper,ix(p)),1)) &&
        p118b_root_once(wrapper,rest,roots,U32.inc(i))


@unsafe
def p118b_eligible(+book: List<&2,KDef>, +plan: NO_Plan) -> Bool:
  +schema = no_plan_schema(plan)
  +params = no_plan_params(no_schema_params(schema))
  +roots = no_schema_roots(schema)
  +wrapper = no_schema_wrapper(schema)
  +result = no_schema_result(schema)
  +env : List<&2,NC_Binding> = Con{NC_Binding{result,"p118b_observation",N_W64{}},params}
  String.is_empty(no_plan_error(plan)) &&
    String.eq(dk(lookup(book,p118b_read_name(no_plan_owner(plan)))),"Absent") &&
    U32.is_gt(nt_count(U32,roots),0) &&
    U32.is_le(nt_count(U32,roots),2) && Bool.not(String.eq(tg(wrapper),"Var")) &&
    p118b_root_once(wrapper,no_schema_params(schema),roots,0) &&
    U32.is_eq(nq_uses(wrapper,result),1) && no_wrapper_once(wrapper,env) &&
    U32.is_le(no_wrapper_nodes(book,wrapper,env,2),2) &&
    String.is_empty(nc_error(no_emit(noa_body(no_plan_analysis(plan)),params,params,
      no_schema_specs_layouts(no_schema_specs(schema)),0)))


@unsafe
def p118b_candidates(+book: List<&2,KDef>, names: List<&2,String>, +permission: Bool) -> List<&2,String>:
  match names:
    case Nil{}: []
    case Con{+name,+rest}:
      +plan = no_observer_plan(book,name,permission)
      nt_choose(List<&2,String>,p118b_eligible(book,plan),
        u => Con{name,p118b_candidates(book,rest,permission)},
        u => p118b_candidates(book,rest,permission))


@unsafe
def p118b_plan(+request: NR_Request) -> P118BPlan:
  match request:
    case NR_Request{+source,+book,+names,paths,scope,+bound}:
      +error = nc_compile_error_known(source,bound)
      +permission = ns_definitions(book,names)
      P118BPlan{request,nt_choose(List<&2,String>,String.is_empty(error) && permission,
        u => p118b_candidates(book,no_candidate_names(book,names,nc_bangs_names(book,names)),permission),
        u => []),error}


@unsafe
def p118b_plan_names(plan: P118BPlan) -> List<&2,String>:
  match plan:
    case P118BPlan{request,names,error}: names

law p118b_eval:
  for +t: KTerm
  for +env: List<&2,NC_Binding>
  for +n: U32
  P113DCode

@unsafe
def p118b_eval(t,env,n):
  nt_choose(P113DCode,String.eq(tg(t),"Var") || String.eq(tg(t),"NWord"),
    u => p113d_emitted(P113DLocal{p118b_value_name(n)},U32.inc(n),p111_value(t,env)),
    u => nt_choose(P113DCode,String.eq(tg(t),"NO_ReadCall"),
      v => p128br_eval_call(nm(t),n,p118b_args(ks(t),env,U32.inc(n))),
      v => nt_choose(P113DCode,String.eq(tg(t),"Ctr") || String.eq(tg(t),"NCtr") || String.eq(tg(t),"NOp"),
        w => p118b_eval_call(t,n,p118b_args(ks(t),env,U32.inc(n))),
        w => p113d_fail("borrowed value: unsupported node",n))))

@unsafe
def p118b_args(terms: List<&2,KTerm>, +env: List<&2,NC_Binding>, +n: U32) -> P118BValues:
  match terms:
    case Nil{}: P118BValues{[],[],n,""}
    case Con{head,rest}: p118b_args_head(rest,env,n,p118b_eval(head,env,n))


@unsafe
def p118b_args_head(rest: List<&2,KTerm>, +env: List<&2,NC_Binding>, +n: U32, +first: P113DCode) -> P118BValues:
  p118b_args_tail(n,first,p118b_args(rest,env,p113d_fresh(first)))


@unsafe
def p118b_args_tail(+n: U32, +first: P113DCode, tail: P118BValues) -> P118BValues:
  match tail:
    case P118BValues{body,+values,next,error}:
      P118BValues{nt_append(P113DStmt,p113d_body(first),body),
        Con{N111Local{p118b_value_name(n)},values},next,p111_first(p113d_error(first),error)}


@unsafe
def p118b_eval_call(+t: KTerm, +n: U32, args: P118BValues) -> P113DCode:
  match args:
    case P118BValues{body,+values,next,error}:
      +value = nt_choose(P111ValueCode,String.eq(tg(t),"NOp"),
        u => p111_intrinsic(nm(t),values),u => p111_constructor(nm(t),values))
      p113d_join(P113DCode{body,next,error,[]},
        p113d_emitted(P113DLocal{p118b_value_name(n)},next,value))


law p118b_lower:
  for +t: KTerm
  for +env: List<&2,NC_Binding>
  for +params: List<&2,NC_Binding>
  for +layouts: List<&2,NO_Layout>
  for +n: U32
  P113DCode

@unsafe
def p118b_lower(t,env,params,layouts,n):
  nt_choose(P113DCode,String.eq(tg(t),"NO_Return"),u => p118b_terminal(False{},p118b_args(ks(t),env,n)),u =>
  nt_choose(P113DCode,String.eq(tg(t),"NO_Loop"),u => p118b_terminal(True{},p118b_args(ks(t),env,n)),u =>
  nt_choose(P113DCode,String.eq(tg(t),"NO_Let"),u => p118b_let(t,env,params,layouts,n),u =>
  nt_choose(P113DCode,String.eq(tg(t),"NO_Match"),u => p118b_match(t,env,params,layouts,n,no_layout(nm(t),layouts)),u =>
  nt_choose(P113DCode,String.eq(tg(t),"NO_Error") && String.eq(nm(t),"ERR_FIDS"),
    u => p113d_prepend([N111Call{"ignored",N111U64{},"p111_rt_fail",[p111_state(),p111_u32(4)]}],p113d_result(N111Const{0,0},P113DReturn{},n)),
    u => p113d_fail("borrowed residual: unsupported node",n))))))


@unsafe
def p118b_terminal(+loop: Bool, args: P118BValues) -> P113DCode:
  match args:
    case P118BValues{body,+values,next,error}:
      P113DCode{nt_append(P113DStmt,body,
        [nt_choose(P113DStmt,loop,u => P113DAgain{values},u => P113DResult{values})]),next,error,[]}


@unsafe
def p118b_let(+t: KTerm, +env: List<&2,NC_Binding>, +params: List<&2,NC_Binding>, +layouts: List<&2,NO_Layout>, +n: U32) -> P113DCode:
  +first = p118b_eval(kid(t,0),env,n)
  +assigned : N111Stmt = N111Set{"v_" ++ U32.show(ix(t)),N111U64{},N111Local{p118b_value_name(n)}}
  p113d_join(first,p113d_prepend([assigned],p118b_lower(kid(t,1),Con{nc_binding(ix(t)),env},params,layouts,p113d_fresh(first))))


@unsafe
def p118b_field_loads(fields: List<&2,KTerm>, +i: U32) -> List<&2,N111Stmt>:
  match fields:
    case Nil{}: []
    case Con{field,rest}: Con{N111Load{"v_" ++ U32.show(ix(field)),N111U64{},N111Local{"scratch"},U32.mul(i,8)},p118b_field_loads(rest,U32.inc(i))}


@unsafe
def p118b_reads(+layout: NO_Layout, +fields: List<&2,KTerm>, +word: N111Value) -> List<&2,N111Stmt>:
  match layout:
    case NO_Layout{key,+ctor,+storage,+width}:
      nt_choose(List<&2,N111Stmt>,String.eq(storage,"Boxed"),
        u => Con{N111Call{"p118b_read_status",N111U64{},"p118_rt_borrow_fields",
          [p111_state(),p111_word(word),p111_scratch(),N111Arg{N111U32{},N111CtorId{ctor}},p111_u32(width)]},p118b_field_loads(fields,0)},
        u => nt_choose(List<&2,N111Stmt>,String.eq(storage,"Nullary"),v => [],v =>
          nt_choose(List<&2,N111Stmt>,String.eq(storage,"Succ"),
            w => [N111Bin{"v_" ++ U32.show(ix(kid(kt("","",0,0,fields),0))),N111U64{},"sub",word,N111Const{1,0}}],
            w => [N111Set{"v_" ++ U32.show(ix(kid(kt("","",0,0,fields),0))),N111U64{},word}])) )


@unsafe
def p118b_match(+t: KTerm, +env: List<&2,NC_Binding>, +params: List<&2,NC_Binding>, +layouts: List<&2,NO_Layout>, +n: U32, found: Maybe<&2,NO_Layout>) -> P113DCode:
  match found:
    case None{}: p113d_fail("borrowed residual: absent layout",n)
    case Some{+layout}:
      match layout:
        case NO_Layout{key,+ctor,storage,width}:
          +word : N111Value = N111Local{nc_word(ix(kid(t,0)),env)}
          +fields = ks(kid(t,1))
          +yes = p118b_lower(kid(t,2),no_bind_fields(fields,env),params,layouts,n)
          +no = p118b_lower(kid(t,3),env,params,layouts,p113d_fresh(yes))
          p113d_prepend(p111_test(ctor,word),p113d_branch(N111Local{"match_condition"},
            p113d_prepend(p118b_reads(layout,fields,word),yes),no))


@unsafe
def p118b_functions(+book: List<&2,KDef>, +owner: String, +plan: NO_Plan) -> P118BWorkers:
  p126bp_extend(book,owner,plan,p126bp_original_functions(book,owner,plan))

# New flat observer symbols are a necessary precondition for the extra catalogue
# preparation. All other requests retain the original compose path and work.

@unsafe
def p118b_project_call(+stmt: N111Stmt, +ids: N111Ids) -> P113DCode:
  match stmt:
    case N111Call{+name,+typ,+symbol,+args}:
      nt_choose(P113DCode,String.eq(symbol,"p118_rt_borrow_fields"),
        u => p118b_project_borrow(name,typ,args,ids),
        u => nt_choose(P113DCode,String.eq(symbol,"p118_rt_borrow_scalar_safe"),
          v => p128bs_project_guard(name,typ,args),
          v => P113DCode{[P113DScalar{stmt}],0,"",[]}))
    case _: P113DCode{[P113DScalar{stmt}],0,"",[]}

@unsafe
def p118b_arg_types(args: List<&2,N111Arg>, widths: List<&2,U32>) -> Bool:
  match args widths:
    case Nil{} Nil{}: True{}
    case Con{N111Arg{typ,value},rest} Con{width,more}:
      U32.is_eq(p111v_type(typ),width) && p118b_arg_types(rest,more)
    case _ _: False{}


@unsafe
def p118b_project_borrow(+name: String, +typ: N111Type, +args: List<&2,N111Arg>, +ids: N111Ids) -> P113DCode:
  +ctor = p111v_target(p111v_arg(args,3),ids,True{})
  +count = p111v_literal(p111v_arg(args,4))
  +ok = p118b_arg_types(args,[3,2,3,1,1]) && U32.is_eq(p111v_type(typ),2) &&
    Bool.not(String.eq(dk(ctor),"Absent")) && U32.is_eq(da(ctor),count) &&
    U32.is_ge(count,2) && U32.is_le(count,16)
  +projected : N111Stmt = N111Call{name,typ,"p111_rt_take",[
    p111_state(),p111_word(p111v_arg(args,1)),N111Arg{N111Ptr{},p111v_arg(args,2)},p111_u32(count)]}
  nt_choose(P113DCode,ok && p111v_state_argument(args),
    u => P113DCode{[P113DScalar{projected}],0,"",[]},
    u => p113d_fail("borrowed import: constructor/count contract",0))


@unsafe
def p118b_project(body: List<&2,P113DStmt>, ids: N111Ids) -> P113DCode:
  p118ns_project(body,ids,[],"")


@unsafe
def p118b_project_function(+function: P113DFunction, +ids: N111Ids) -> P118BWorkers:
  match function:
    case P113DFunction{name,params,result,public,body}:
      +projected = p118b_project(body,ids)
      P118BWorkers{[P113DFunction{name,params,result,public,p113d_body(projected)}],p113d_error(projected)}


@unsafe
def p118b_workers_join(+first: P118BWorkers, +second: P118BWorkers) -> P118BWorkers:
  match first second:
    case P118BWorkers{a,ae} P118BWorkers{b,be}: P118BWorkers{nt_append(P113DFunction,a,b),p111_first(ae,be)}


@unsafe
def p118b_project_functions(functions: List<&2,P113DFunction>, ids: N111Ids) -> P118BWorkers:
  p118ns_project_functions(functions,ids,[],"")


@unsafe
def p118b_verify_projected(+ids: N111Ids, workers: P118BWorkers) -> String:
  match workers:
    case P118BWorkers{functions,+error}:
      nt_choose(String,String.is_empty(error),u => p113e_functions(functions,ids,missing()),u => error)


@unsafe
def p118b_verify_functions(+functions: List<&2,P113DFunction>, +original: P111Program) -> String:
  match original:
    case P111Program{segments,constructors,show,names,effects,pure}:
      +ids : N111Ids = N111Ids{p113e_originals(segments,missing()),ns_ctor_index(constructors,missing())}
      p118b_verify_projected(ids,p118b_project_functions(functions,ids))

@unsafe
def p118b_rederive(+book: List<&2,KDef>, names: List<&2,String>, +permission: Bool) -> P118BWorkers:
  match names:
    case Nil{}: P118BWorkers{[],""}
    case Con{+name,rest}:
      +plan = no_observer_plan(book,name,permission)
      +here = nt_choose(P118BWorkers,p118b_eligible(book,plan),
        u => p118b_functions(book,name,plan),u => P118BWorkers{[],"borrowed plan no longer admitted: " ++ name})
      p118b_workers_join(here,p118b_rederive(book,rest,permission))


@unsafe
def p118b_new_functions(plan: P118BPlan) -> P118BWorkers:
  match plan:
    case P118BPlan{NR_Request{+source,+book,+names,paths,scope,+bound},selected,+error}:
      +checked = p111_first(error,nc_compile_error_known(source,bound))
      nt_choose(P118BWorkers,String.is_empty(checked),
        u => p118b_rederive(book,selected,ns_definitions(book,names)),
        u => P118BWorkers{[],checked})


@unsafe
def p118b_without(functions: List<&2,P113DFunction>, replaced: KDef) -> List<&2,P113DFunction>:
  p118ns_without(functions,replaced,[])

# Inline the old mutually recursive continuation into a direct self tail call.
# Preserve the original first-error stop: no later observer plan is evaluated.

@unsafe
def p118b_compose(+original: P113AProgram, workers: P118BWorkers) -> P111Emission:
  match original workers:
    case P113AProgram{P113DProgram{P112StaticProgram{+program,nodes},functions},certificate} P118BWorkers{+added,+error}:
      +checked = p111_first(error,p118b_verify_functions(added,program))
      +merged = nt_append(P113DFunction,added,p118b_without(functions,p113e_signatures(added,missing())))
      nt_choose(P111Emission,String.is_empty(checked),
        u => P134Planned{P134Admitted{P113AProgram{P113DProgram{P112StaticProgram{program,nodes},merged},certificate}}},
        u => P111Emission{[],"borrowed profile: " ++ checked})

@unsafe
def p118b_emit_verified(+original: P113AProgram, +plan: P118BPlan, +error: String) -> P111Emission:
  nt_choose(P111Emission,String.is_empty(error),u => p126bp_plan(original,plan),
    u => P111Emission{[],"borrowed original: " ++ error})

@unsafe
def p118b_emission_chunks(emitted: P111Emission) -> List<&2,String>:
  p134e_emission_chunks(p134e_collect(emitted))

@unsafe
def p118b_chunks(+original: P113AProgram, +plan: P118BPlan) -> List<&2,String>:
  p118b_emission_chunks(p118b_emit_verified(original,plan,p113a_verify(original)))


@unsafe
def p118b_emit_lowered(+plan: P118BPlan, lowered: P113ALowering) -> P111Emission:
  match lowered:
    case P113ALowered{+program,+error}:
      nt_choose(P111Emission,String.is_empty(error),u => p118b_emit_verified(program,plan,p113a_verify(program)),
        u => P111Emission{[],"borrowed lowering: " ++ error})


@unsafe
def p118b_emit_request(+request: NR_Request) -> P111Emission:
  p118b_emit_lowered(p118b_plan(request),p113a_lower_request(request))


@unsafe
def p118c_ordinary(+name: String) -> Bool:
  Bool.not(nb_contains(["Zero","Succ","False","True","Chr","U32","F32",
    "ALeaf","ANode","WNil","WCon","Emit","Halt","Done","Fail"],name))


@unsafe
def p118c_ctor_names(ctors: List<&2,N_Constructor>, hot: List<&2,String>) -> List<&2,String>:
  p118ns_ctor_names(ctors,hot,[])


@unsafe
def p118c_candidates(book: List<&2,KDef>, defs: List<&2,KDef>, hot: List<&2,String>) -> List<&2,String>:
  p118ns_candidates(book,defs,hot,[])


@unsafe
def p118c_plan_hot(+request: NR_Request, +source: List<&2,KDef>, +book: List<&2,KDef>, +permission: Bool, +error: String, +hot: List<&2,String>) -> P118CPlan:
  +valid = permission && String.is_empty(error) && Bool.not(nb_contains(hot,"*"))
  P118CPlan{request,hot,nt_choose(List<&2,String>,valid,u => p118c_candidates(book,source,hot),u => []),valid,error}


@unsafe
def p118c_plan(+request: NR_Request) -> P118CPlan:
  match request:
    case NR_Request{+source,+book,+names,paths,scope,+bound}:
      +error = nc_compile_error_known(source,bound)
      +permission = ns_definitions(book,names)
      p118c_plan_hot(request,source,book,permission,error,
        nt_choose(List<&2,String>,permission && String.is_empty(error),
          u => nh_definitions(book,names,[]),u => ["*"]))


@unsafe
def p118c_hot(plan: P118CPlan) -> List<&2,String>:
  match plan:
    case P118CPlan{request,hot,cold,valid,error}: hot


@unsafe
def p118c_cold(plan: P118CPlan) -> List<&2,String>:
  match plan:
    case P118CPlan{request,hot,cold,valid,error}: cold


@unsafe
def p118c_valid(plan: P118CPlan) -> Bool:
  match plan:
    case P118CPlan{request,hot,cold,valid,error}: valid


@unsafe
def p118c_ctors(ctors: List<&2,N_Constructor>, cold: List<&2,String>) -> List<&2,N_Constructor>:
  p118ns_ctors(ctors,cold,[])


@unsafe
def p118c_apply_verified(original: P113AProgram, +cold: List<&2,String>) -> P113AProgram:
  match original:
    case P113AProgram{P113DProgram{P112StaticProgram{P111Program{segments,ctors,show,names,effects,pure},nodes},functions},certificate}:
      P113AProgram{P113DProgram{P112StaticProgram{P111Program{segments,p118c_ctors(ctors,cold),show,names,effects,pure},nodes},functions},certificate}


@unsafe
def p118c_apply_plan(+original: P113AProgram, plan: P118CPlan) -> P113AProgram:
  match plan:
    case P118CPlan{request,hot,cold,valid,error}:
      nt_choose(P113AProgram,valid && String.is_empty(error),u => p118c_apply_verified(original,cold),u => original)

# Re-derive the certificate before applying it; caller-supplied cold lists are
# not authority. The ordinary program and plan must share the same request in
# the root harness, whose manifest pins checked source and runtime identities.

@unsafe
def p118c_apply(+original: P113AProgram, plan: P118CPlan) -> P113AProgram:
  match plan:
    case P118CPlan{request,hot,cold,valid,error}:
      nt_choose(P113AProgram,String.is_empty(p113a_verify(original)),
        u => p118c_apply_plan(original,p118c_plan(request)),u => original)

@unsafe
def p118c_zero_byte(items: List<&2,P111QDatum>) -> Bool:
  p118ns_zero_byte(items,False{})

# Exact mature per-definition observer predicate. In particular trusted AND
# filled foreign permission, native authentication, and Rwt refusal remain.
# Only the new integrated entry uses this loop; mature C/JS policy is untouched.

@unsafe
def p118c_has_cold(tables: List<&2,P111QData>) -> Bool:
  match tables:
    case Nil{}: False{}
    case Con{P111QData{+name,alignment,exported,items},rest}:
      (String.eq(name,"p111_cid_hot") && p118c_zero_byte(items)) || p118c_has_cold(rest)


@unsafe
def p118c_cap_item(item: P111QDatum) -> P111QDatum:
  match item:
    case P111QLong{lo,hi}: P111QLong{U32.or(lo,8),hi}
    case _: item


@unsafe
def p118c_cap_items(items: List<&2,P111QDatum>, +index: U32) -> List<&2,P111QDatum>:
  match items:
    case Nil{}: []
    case Con{+head,rest}: Con{nt_choose(P111QDatum,U32.is_eq(index,11),u => p118c_cap_item(head),u => head),p118c_cap_items(rest,U32.inc(index))}


@unsafe
def p118c_cap_tables(tables: List<&2,P111QData>) -> List<&2,P111QData>:
  match tables:
    case Nil{}: []
    case Con{P111QData{+name,alignment,exported,+items},rest}:
      Con{P111QData{name,alignment,exported,nt_choose(List<&2,P111QDatum>,String.eq(name,"p111_program"),
        u => p118c_cap_items(items,0),u => items)},p118c_cap_tables(rest)}


@unsafe
def p118c_tables(+tables: List<&2,P111QData>) -> List<&2,P111QData>:
  nt_choose(List<&2,P111QData>,p118c_has_cold(tables),u => p118c_cap_tables(tables),u => tables)

# The sole override. Existing p111_emit_plan still performs runtime admission;
# lower_request retains source/bound checking and the original lowering passes.
# The original full verifier runs once before either derived transformation.

@unsafe
def p118i_permission(request: NR_Request) -> Bool:
  match request:
    case NR_Request{source,book,names,paths,scope,bound}:
      p118ns_effect_definitions(True{},book,names)

@unsafe
def p118i_borrow(request: NR_Request, original: P113AProgram) -> P111Emission:
  p128br_prepare(request,original,False{})

@unsafe
def p118i_prepare(+request: NR_Request, +original: P113AProgram) -> P111Emission:
  nt_choose(P111Emission,p118i_permission(request),
    u => p118i_borrow(request,original),
    u => P134Planned{P134Admitted{original}})

# Internal continuation only: runtime admission, source checking and original
# IR verification have already succeeded in the request-bound integrated entry.
# Scalar false never reaches p118e_permitted or p118e_cold; neither cold facts
# nor the existing scalar/unshared certificate is changed by this overlay.

@unsafe
def p118z_transition(+symbol: String) -> Bool:
  String.eq(symbol,"p111_rt_jump") || String.eq(symbol,"p111_rt_return") || String.eq(symbol,"p111_rt_apply")


@unsafe
def p118z_runtime(+symbol: String) -> Bool:
  Bool.not(List.is_empty(&2,U32,p111v_signature(symbol))) ||
    String.eq(symbol,"p113_rt_array_pair") || String.eq(symbol,"p118_rt_extend") ||
    String.eq(symbol,"p118_rt_finish") || String.eq(symbol,"p118_rt_borrow_fields") ||
    String.eq(symbol,"p126_rt_nat_divmod") || String.eq(symbol,"p118_rt_borrow_scalar_safe") ||
    String.eq(symbol,"p125_rt_concat_typed")

@unsafe
def p118z_nonpointer(typ: N111Type) -> Bool:
  match typ:
    case N111Ptr{}: False{}
    case _: True{}


@unsafe
def p118z_scalar(stmt: N111Stmt, +direct: Bool) -> Bool:
  match stmt:
    case N111Set{name,typ,value}: p118z_nonpointer(typ)
    case N111Bin{name,typ,op,left,right}: p118z_nonpointer(typ)
    case N111Call{name,N111U64{},+symbol,args}:
      p118z_runtime(symbol) && p113e_runtime_args(args) &&
        Bool.not(direct && (p118z_transition(symbol) || String.eq(symbol,"p111_rt_reg_get")))
    case N111If{condition,yes,no}: p118z_scalars(yes,direct) && p118z_scalars(no,direct)
    case N111Load{name,typ,base,offset}: p118z_nonpointer(typ) && p113e_nonstate_pointer(base)
    case N111Store{typ,base,offset,value}: p118z_nonpointer(typ) && p113e_nonstate_pointer(base)
    case N111Alloca{name,bytes,align}: True{}
    case N111Return{value}: Bool.not(direct)
    # No pointer aliases/offsets/loads; other pointer roots are verified allocas.
    case _: False{}

# A transition must terminate its block immediately. This forbids reading the
# old segment's wider inputs after a narrower outgoing transfer. The original
# verifier checks the transition's count, target and return value definitions.

@unsafe
def p118z_scalars(body: List<&2,N111Stmt>, direct: Bool) -> Bool:
  p118ns_scalars(body,direct,True{})


@unsafe
def p118z_segments(segments: List<&2,N111Segment>) -> Bool:
  p118ns_segments(segments,True{})


@unsafe
def p118z_direct(body: List<&2,P113DStmt>) -> Bool:
  p118ns_direct(body,True{})


@unsafe
def p118z_functions(functions: List<&2,P113DFunction>) -> Bool:
  p118ns_functions(functions,True{})

# Project every node in the original left-to-right order and retain the first
# diagnostic. The old projector always produces fresh=0 and calls=[]; those
# fields remain identical. Reversing each small prefix into an accumulator and
# reversing once at completion preserves every statement/function order.

@unsafe
def p118z_eligible(program: P113AProgram) -> Bool:
  match program:
    case P113AProgram{P113DProgram{P112StaticProgram{P111Program{segments,constructors,show,names,effects,pure},nodes},functions},certificate}:
      p118z_segments(segments) && p118z_functions(functions)

# Pure finite refusals; no malformed target code is run by these controls.

@unsafe
def p118z_controls() -> List<&2,String>:
  +load : N111Stmt = N111Load{"probe",N111U64{},N111Local{"state"},48}
  +alias : N111Stmt = N111Set{"alias",N111Ptr{},N111Local{"state"}}
  +reg : N111Stmt = N111Call{"value",N111U64{},"p111_rt_reg_get",[p111_state(),p111_u32(0)]}
  +ret : N111Stmt = N111Call{"reply",N111U64{},"p111_rt_return",[p111_state(),p111_scratch(),p111_u32(1)]}
  [p113ft_row("transport-state-load-refused",Bool.not(p118z_scalar(load,False{}))),
   p113ft_row("transport-state-alias-refused",Bool.not(p118z_scalar(alias,False{}))),
   p113ft_row("transport-direct-register-read-refused",Bool.not(p118z_scalar(reg,True{}))),
   p113ft_row("transport-verified-generic-register-read",p118z_scalar(reg,False{})),
   p113ft_row("transport-terminal-return",p118z_scalars([ret,N111Return{N111Local{"reply"}}],False{})),
   p113ft_row("transport-post-transition-read-refused",Bool.not(p118z_scalars([ret,reg,N111Return{N111Local{"reply"}}],False{}))),
   p113ft_row("transport-multi-result-generic-refused",Bool.not(p118z_segments([N111Segment{"probe",2,2,0,0,[]}]))),
   p113ft_row("transport-multi-input-continuation-refused",Bool.not(p118z_segments([N111Segment{"probe",2,1,2,0,[]}])))]

@unsafe
def p118z_cap_items(items: List<&2,P111QDatum>, +index: U32) -> List<&2,P111QDatum>:
  match items:
    case Nil{}: []
    case Con{+head,rest}: Con{nt_choose(P111QDatum,U32.is_eq(index,11),u => p118z_cap_item(head),u => head),p118z_cap_items(rest,U32.inc(index))}


@unsafe
def p118z_cap_item(item: P111QDatum) -> P111QDatum:
  match item:
    case P111QLong{lo,hi}: P111QLong{U32.or(lo,4),hi}
    case _: item


@unsafe
def p118z_tables(tables: List<&2,P111QData>) -> List<&2,P111QData>:
  match tables:
    case Nil{}: []
    case Con{P111QData{+name,alignment,exported,+items},rest}:
      Con{P111QData{name,alignment,exported,nt_choose(List<&2,P111QDatum>,String.eq(name,"p111_program"),
        u => p118z_cap_items(items,0),u => items)},p118z_tables(rest)}


@unsafe
def p118z_bundle(+program: P111Program, +nodes: List<&2,P112SNode>, +functions: List<&2,P113DFunction>, +arrays: Bool) -> List<&2,String>:
  match program:
    case P111Program{+segments,constructors,show,names,effects,pure}:
      +ids = p111q_ids(program)
      +tables = nt_choose(List<&2,P111QData>,List.is_empty(&2,P112SNode,nodes),u => p111q_tables(program,ids),u => p112s_tables(program,nodes,ids))
      nt_append(String,nt_choose(List<&2,String>,arrays,
        u => p113a_segment_chunks(segments,functions,ids,p113a_heap_min(nodes),p112f_index(segments)),
        u => p113e_segment_chunks(segments,functions,ids,p112f_index(segments))),
        nt_append(String,p111q_data_chunks(p118z_tables(nt_choose(List<&2,P111QData>,arrays,
          u => p117p_tables(tables,[]),u => tables))),[p111q_main()]))


@unsafe
def p118z_original_chunks(program: P113AProgram) -> List<&2,String>:
  match program:
    case P113AProgram{+original,+certificate}:
      nt_choose(List<&2,String>,p113a_enabled(certificate),
        u => p113a_enabled_chunks(original),u => p113e_admitted_chunks(original))


@unsafe
def p118ns_scalars(body: List<&2,N111Stmt>, +direct: Bool, +valid: Bool) -> Bool:
  match body:
    case Nil{}: valid
    case Con{N111Call{+name,N111U64{},+symbol,+args},Con{N111Return{N111Local{+reply}},Nil{}}}:
      valid && nt_choose(Bool,p118z_transition(symbol),
        u => Bool.not(direct) && String.eq(name,reply) && p118z_scalar(N111Call{name,N111U64{},symbol,args},direct),
        u => p118z_scalar(N111Call{name,N111U64{},symbol,args},direct) && p118z_scalar(N111Return{N111Local{reply}},direct))
    case Con{N111Call{name,typ,+symbol,args},rest}:
      p118ns_scalars(rest,direct,valid && Bool.not(p118z_transition(symbol)) &&
        p118z_scalar(N111Call{name,typ,symbol,args},direct))
    case Con{head,rest}: p118ns_scalars(rest,direct,valid && p118z_scalar(head,direct))


@unsafe
def p118ns_segments(segments: List<&2,N111Segment>, +valid: Bool) -> Bool:
  match segments:
    case Nil{}: valid
    case Con{N111Segment{name,arity,result,incoming,flags,body},rest}:
      p118ns_segments(rest,valid && U32.is_eq(result,1) && U32.is_le(incoming,1) && p118z_scalars(body,False{}))


@unsafe
def p118ns_direct(body: List<&2,P113DStmt>, +valid: Bool) -> Bool:
  match body:
    case Nil{}: valid
    case Con{P113DScalar{stmt},rest}: p118ns_direct(rest,valid && p118z_scalar(stmt,True{}))
    case Con{P113DIf{condition,yes,no},rest}: p118ns_direct(rest,valid && p118z_direct(yes) && p118z_direct(no))
    case Con{stmt,rest}: p118ns_direct(rest,valid)


@unsafe
def p118ns_functions(functions: List<&2,P113DFunction>, +valid: Bool) -> Bool:
  match functions:
    case Nil{}: valid
    case Con{P113DFunction{name,params,result,public,body},rest}:
      p118ns_functions(rest,valid && p118z_direct(body))


@unsafe
def p118ns_project_node(stmt: P113DStmt, +ids: N111Ids) -> P113DCode:
  match stmt:
    case P113DScalar{scalar}: p118b_project_call(scalar,ids)
    case P113DIf{condition,yes,no}: p113d_branch(condition,p118b_project(yes,ids),p118b_project(no,ids))
    case _: P113DCode{[stmt],0,"",[]}


@unsafe
def p118ns_project(body: List<&2,P113DStmt>, +ids: N111Ids, reversed: List<&2,P113DStmt>, error: String) -> P113DCode:
  match body:
    case Nil{}: P113DCode{nt_reverse(P113DStmt,reversed,[]),0,error,[]}
    case Con{head,rest}:
      +projected = p118ns_project_node(head,ids)
      p118ns_project(rest,ids,nt_reverse(P113DStmt,p113d_body(projected),reversed),
        p111_first(error,p113d_error(projected)))


@unsafe
def p118ns_project_functions(functions: List<&2,P113DFunction>, +ids: N111Ids, reversed: List<&2,P113DFunction>, error: String) -> P118BWorkers:
  match functions:
    case Nil{}: P118BWorkers{nt_reverse(P113DFunction,reversed,[]),error}
    case Con{head,rest}:
      +projected = p118b_project_function(head,ids)
      p118ns_project_functions(rest,ids,nt_reverse(P113DFunction,p118ns_worker_functions(projected),reversed),
        p111_first(error,p118ns_worker_error(projected)))


@unsafe
def p118ns_without(functions: List<&2,P113DFunction>, +replaced: KDef, +reversed: List<&2,P113DFunction>) -> List<&2,P113DFunction>:
  match functions:
    case Nil{}: nt_reverse(P113DFunction,reversed,[])
    case Con{+head,rest}:
      match head:
        case P113DFunction{name,params,result,public,body}:
          next = nt_choose(List<&2,P113DFunction>,String.eq(dk(p111v_get(replaced,name)),"Absent"),
            u => Con{head,reversed},u => reversed)
          p118ns_without(rest,replaced,next)


@unsafe
def p118ns_worker_functions(workers: P118BWorkers) -> List<&2,P113DFunction>:
  match workers:
    case P118BWorkers{functions,error}: functions


@unsafe
def p118ns_worker_error(workers: P118BWorkers) -> String:
  match workers:
    case P118BWorkers{functions,error}: error


@unsafe
def p118ns_workers(valid: Bool, +book: List<&2,KDef>, names: List<&2,String>, reversed: List<&2,P113DFunction>, error: String) -> P118BWorkers:
  match valid:
    case False{}: P118BWorkers{[],error}
    case True{}:
      match names:
        case Nil{}: P118BWorkers{nt_reverse(P113DFunction,reversed,[]),""}
        case Con{+name,rest}:
          +plan = no_observer_plan(book,name,True{})
          +workers = nt_choose(P118BWorkers,p118b_eligible(book,plan),
            u => p118b_functions(book,name,plan),u => P118BWorkers{[],""})
          +next_error = p118ns_worker_error(workers)
          p118ns_workers(String.is_empty(next_error),book,rest,
            nt_reverse(P113DFunction,p118ns_worker_functions(workers),reversed),next_error)


@unsafe
def p118ns_ctor_names(ctors: List<&2,N_Constructor>, +hot: List<&2,String>, +reversed: List<&2,String>) -> List<&2,String>:
  match ctors:
    case Nil{}: nt_reverse(String,reversed,[])
    case Con{N_Constructor{+name,+arity,was_hot},rest}:
      next = nt_choose(List<&2,String>,U32.is_gt(arity,0) && p118c_ordinary(name) && Bool.not(nb_contains(hot,"ctor:" ++ name)),
        u => Con{name,reversed},u => reversed)
      p118ns_ctor_names(rest,hot,next)


@unsafe
def p118ns_candidates(+book: List<&2,KDef>, defs: List<&2,KDef>, +hot: List<&2,String>, reversed: List<&2,String>) -> List<&2,String>:
  match defs:
    case Nil{}: nt_reverse(String,reversed,[])
    case Con{+d,rest}:
      prefix = nt_choose(List<&2,String>,String.eq(dk(d),"ADT") &&
        Bool.not(nb_contains(["Nat","U32","F32","Char","Bool","Array","Word.Nil","Word.Con","IO","IO.OP"],dn(d))),
        u => p118c_ctor_names(nc_ctor_specs(book,dc(d),da(d)),hot),u => [])
      p118ns_candidates(book,rest,hot,nt_reverse(String,prefix,reversed))


@unsafe
def p118ns_ctors(ctors: List<&2,N_Constructor>, +cold: List<&2,String>, reversed: List<&2,N_Constructor>) -> List<&2,N_Constructor>:
  match ctors:
    case Nil{}: nt_reverse(N_Constructor,reversed,[])
    case Con{N_Constructor{+name,arity,hot},rest}:
      p118ns_ctors(rest,cold,Con{N_Constructor{name,arity,Bool.not(nb_contains(cold,name))},reversed})


@unsafe
def p118ns_zero_byte(items: List<&2,P111QDatum>, +found: Bool) -> Bool:
  match items:
    case Nil{}: found
    case Con{P111QByte{value},rest}: p118ns_zero_byte(rest,found || U32.is_eq(value,0))
    case Con{item,rest}: p118ns_zero_byte(rest,found)


@unsafe
def p118ns_effect_definition(+d: KDef) -> Bool:
  nt_choose(Bool,nc_native_def(d),u => True{},u => nt_choose(Bool,nc_foreign(d),
    v => no_effect_foreign_allowed(db(d),String.eq(tg(nc_unann(dv(d))),"Foreign"),dn(d)),
    v => String.eq(dk(d),"Def") && no_effect_terms([dv(d)])))


@unsafe
def p118ns_effect_definitions(+valid: Bool, +book: List<&2,KDef>, names: List<&2,String>) -> Bool:
  match valid:
    case False{}: False{}
    case True{}:
      match names:
        case Nil{}: True{}
        case Con{name,rest}:
          p118ns_effect_definitions(p118ns_effect_definition(lookup(book,name)),book,rest)


@unsafe
def p118ns_scale(+requested: U32) -> List<&2,String>:
  +count = U32.min(requested,65536)
  +functions = p118nsc_functions(count,[])
  +ids : N111Ids = N111Ids{missing(),missing()}
  +plain = p118nsc_definition("probe",kt("NWord","7",0,0,[]),False{})
  [p113ft_row("stack-large-segments",p118z_segments(p118nsc_segments(count,[]))),
   p113ft_row("stack-large-scalars",p118z_scalars(p118nsc_scalars(count,[]),True{})),
   p113ft_row("stack-large-direct-functions",p118z_functions(functions)),
   p113ft_row("stack-large-projected-order",p118nsc_projected(p118b_project_functions(functions,ids),count)),
   p113ft_row("stack-large-retained-order",p118nsc_projected(P118BWorkers{p118b_without(functions,missing()),""},count)),
   p113ft_row("stack-large-effect-definitions",p118ns_effect_definitions(True{},[plain],p118nsc_names(count,[])))]


@unsafe
def p118ns_controls() -> List<&2,String>:
  +plain = p118nsc_definition("probe",kt("NWord","7",0,0,[]),False{})
  +rewrite = p118nsc_definition("rewrite",kt("Rwt","",0,0,[]),False{})
  +trusted = p118nsc_definition("IO.print",{KTerm{"Foreign", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},True{})
  +untrusted = p118nsc_definition("IO.print",{KTerm{"Foreign", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},False{})
  +absent = p118nsc_definition("IO.print",{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},True{})
  +unknown = p118nsc_definition("custom.foreign",{KTerm{"Foreign", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},True{})
  +ids : N111Ids = N111Ids{missing(),missing()}
  +body : List<&2,P113DStmt> = [
    P113DScalar{N111Set{"a",N111U64{},N111Const{1,0}}},
    P113DScalar{N111Bin{"test",N111U64{},"eq",N111Local{"a"},N111Const{0,0}}},
    P113DIf{N111Local{"test"},[P113DResult{[N111Const{9,0}]}],[P113DResult{[N111Const{7,0}]}]}]
  +original : P113DFunction = P113DFunction{"p118_projection",[],1,False{},body}
  +projected = p118b_project(body,ids)
  nt_append(String,
    [p113ft_row("stack-permission-empty",p118nsc_permission([],[])),
     p113ft_row("stack-permission-ordinary",p118nsc_permission([plain],["probe","probe"])),
     p113ft_row("stack-permission-rewrite",p118nsc_permission([plain,rewrite],["probe","rewrite","probe"])),
     p113ft_row("stack-permission-trusted-foreign",p118nsc_permission([trusted],["IO.print"])),
     p113ft_row("stack-permission-untrusted-foreign",p118nsc_permission([untrusted],["IO.print"])),
     p113ft_row("stack-permission-unfilled-foreign",p118nsc_permission([absent],["IO.print"])),
     p113ft_row("stack-permission-unknown-foreign",p118nsc_permission([unknown],["custom.foreign"])),
     p113ft_row("stack-projection-nested-exact",String.is_empty(p113d_error(projected)) &&
       String.eq(p113e_private(original,ids),p113e_private(P113DFunction{"p118_projection",[],1,False{},p113d_body(projected)},ids)))],
    nt_append(String,p118z_controls(),p118ns_scale(8)))
