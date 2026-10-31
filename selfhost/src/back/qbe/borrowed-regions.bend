
@unsafe
def p128bs_owned(owner: String) -> String:
  "$p128borrow.owned." ++ owner


@unsafe
def p128bs_leaf(body: List<&2,P113DStmt>) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{P113DCall{destinations,target,args},rest}: False{}
    case Con{P113DIf{condition,yes,no},rest}: p128bs_leaf(yes) && p128bs_leaf(no) && p128bs_leaf(rest)
    case Con{head,rest}: p128bs_leaf(rest)


@unsafe
def p128bs_eligible(+book: List<&2,KDef>, +plan: NO_Plan) -> Bool:
  +schema = no_plan_schema(plan)
  +wrapper = no_schema_wrapper(schema)
  +params = no_plan_params(no_schema_params(schema))
  +roots = no_schema_roots(schema)
  String.is_empty(no_plan_error(plan)) && String.eq(tg(wrapper),"Var") &&
    U32.is_eq(ix(wrapper),no_schema_result(schema)) &&
    String.eq(nm(wrapper),no_schema_observation(schema)) &&
    nol_scalar(book,kt("ADT",nm(wrapper),0,0,[])) &&
    U32.is_ge(nt_count(U32,roots),1) && U32.is_le(nt_count(U32,roots),2) &&
    String.eq(dk(lookup(book,p118b_read_name(no_plan_owner(plan)))),"Absent") &&
    String.eq(dk(lookup(book,p128bs_owned(no_plan_owner(plan)))),"Absent") &&
    String.is_empty(nc_error(no_emit(noa_body(no_plan_analysis(plan)),params,params,
      no_schema_specs_layouts(no_schema_specs(schema)),0)))


@unsafe
def p128bs_roots(params: List<&2,NC_Binding>, +roots: List<&2,U32>, +i: U32) -> List<&2,N111Arg>:
  match params:
    case Nil{}: []
    case Con{NC_Binding{id,word,kind},+rest}:
      nt_choose(List<&2,N111Arg>,no_root_index(roots,i),
        u => Con{p111_word(N111Local{word}),p128bs_roots(rest,roots,U32.inc(i))},
        u => p128bs_roots(rest,roots,U32.inc(i)))


@unsafe
def p128bs_guard_args(roots: List<&2,N111Arg>) -> List<&2,N111Arg>:
  match roots:
    case Con{a,Nil{}}: [p111_state(),a,p111_word(N111Const{0,0}),p111_u32(1)]
    case Con{a,Con{b,Nil{}}}: [p111_state(),a,b,p111_u32(2)]
    case _: []


@unsafe
def p128bs_drops(roots: List<&2,N111Arg>, +i: U32) -> List<&2,P113DStmt>:
  match roots:
    case Nil{}: []
    case Con{root,rest}:
      Con{P113DScalar{N111Call{"p128bs_drop_" ++ U32.show(i),N111U64{},"p111_rt_sink",[p111_state(),root]}},p128bs_drops(rest,U32.inc(i))}


@unsafe
def p128bs_functions(+book: List<&2,KDef>, +owner: String, +plan: NO_Plan, fallback: P113DFunction) -> P118BWorkers:
  match fallback:
    case P113DFunction{name,old_params,result,public,body}:
      +schema = no_plan_schema(plan)
      +params = no_plan_params(no_schema_params(schema))
      +roots = p128bs_roots(params,no_schema_roots(schema),0)
      +reader = p118b_lower(noa_body(no_plan_analysis(plan)),params,params,no_schema_specs_layouts(no_schema_specs(schema)),0)
      +yes : List<&2,P113DStmt> = Con{P113DCall{["p128bs_observation"],p118b_read_name(owner),p111_env_words(params)},
        nt_append(P113DStmt,p128bs_drops(roots,0),[P113DResult{[N111Local{"p128bs_observation"}]}])}
      +no : List<&2,P113DStmt> = [P113DCall{["p128bs_fallback"],p128bs_owned(owner),p111_env_words(params)},P113DResult{[N111Local{"p128bs_fallback"}]}]
      +adapter : List<&2,P113DStmt> = [P113DScalar{N111Call{"p128bs_borrow",N111U64{},"p118_rt_borrow_scalar_safe",p128bs_guard_args(roots)}},P113DScalar{N111Bin{"p128bs_condition",N111U64{},"ne",N111Local{"p128bs_borrow"},N111Const{0,0}}},P113DIf{N111Local{"p128bs_condition"},yes,no}]
      P118BWorkers{[
        P113DFunction{p128bs_owned(owner),old_params,result,False{},body},
        P113DFunction{p118b_read_name(owner),params,1,False{},p113d_body(reader)},
        P113DFunction{p113d_public(book,owner),params,1,True{},adapter}],p113d_error(reader)}


@unsafe
def p128bs_find(+book: List<&2,KDef>, +owner: String, +plan: NO_Plan, functions: List<&2,P113DFunction>) -> P118BWorkers:
  match functions:
    case Nil{}: P118BWorkers{[],""}
    case Con{+head,rest}:
      match head:
        case P113DFunction{+name,+params,+result,+public,+body}:
          nt_choose(P118BWorkers,String.eq(name,p113d_public(book,owner)),
            u => nt_choose(P118BWorkers,public && U32.is_eq(result,1) && p128bs_leaf(body) &&
              U32.is_eq(nt_count(NC_Binding,params),nt_count(KTerm,no_schema_params(no_plan_schema(plan)))),
              v => p128bs_functions(book,owner,plan,head),v => P118BWorkers{[],""}),
            u => p128bs_find(book,owner,plan,rest))


@unsafe
def p128bs_workers(+book: List<&2,KDef>, names: List<&2,String>, +original: List<&2,P113DFunction>, +reversed: List<&2,P113DFunction>) -> P118BWorkers:
  match names:
    case Nil{}: P118BWorkers{nt_reverse(P113DFunction,reversed,[]),""}
    case Con{+name,+rest}:
      +plan = no_observer_plan(book,name,True{})
      +here = nt_choose(P118BWorkers,p118b_eligible(book,plan),
        u => p118b_functions(book,name,plan),
        u => nt_choose(P118BWorkers,p128bs_eligible(book,plan),
          v => p128bs_find(book,name,plan,original),v => P118BWorkers{[],""}))
      p128bs_workers_next(book,rest,original,reversed,here)


@unsafe
def p128bs_workers_next(book: List<&2,KDef>, names: List<&2,String>, original: List<&2,P113DFunction>, reversed: List<&2,P113DFunction>, here: P118BWorkers) -> P118BWorkers:
  match here:
    case P118BWorkers{functions,+error}:
      nt_choose(P118BWorkers,String.is_empty(error),
        u => p128bs_workers(book,names,original,nt_reverse(P113DFunction,functions,reversed)),u => P118BWorkers{[],error})

# The new guard contract is checked before structural projection. This checks
# the interface, not semantic equivalence; NO + immutable runtime identity are
# the semantic justification, as with the existing readonly field helper.

@unsafe
def p128bs_project_guard(+name: String, +typ: N111Type, +args: List<&2,N111Arg>) -> P113DCode:
  +ok = p118b_arg_types(args,[3,2,2,1]) && p111v_state_argument(args) &&
    U32.is_eq(p111v_type(typ),2) &&
    U32.is_ge(p111v_literal(p111v_arg(args,3)),1) &&
    U32.is_le(p111v_literal(p111v_arg(args,3)),2)
  nt_choose(P113DCode,ok,
    u => P113DCode{[P113DScalar{N111Bin{name,N111U64{},"or",p111v_arg(args,1),p111v_arg(args,2)}}],0,"",[]},
    u => p113d_fail("scalar borrowed guard contract",0))


@unsafe
def p128bs_original(program: P113AProgram) -> List<&2,P113DFunction>:
  match program:
    case P113AProgram{P113DProgram{original,functions},certificate}: functions

# The successful original request verifier remains the only entry. Preserve
# existing flat-worker closure and final independent verification unchanged.

@unsafe
def p128bs_prepare(+request: NR_Request, +original: P113AProgram, +cold: Bool) -> P111Emission:
  match request:
    case NR_Request{+source,+book,+names,paths,scope,bound}:
      +prepared = nt_choose(P113AProgram,cold,
        u => p118e_cold(original,book,source,nh_definitions(book,names,[])),u => original)
      p126bp_integrated(request,prepared,
        p128bs_workers(book,no_candidate_names(book,names,nc_bangs_names(book,names)),
          p128bs_original(original),[]))


@unsafe
def p128bs_control_row(name: String, +ok: Bool) -> String:
  name ++ nt_choose(String,ok,u => ":pass",u => ":FAIL")


@unsafe
def p128bs_guard_control(+count: U32, typ: N111Type, +state: N111Arg) -> Bool:
  String.is_empty(p113d_error(p128bs_project_guard("guard",typ,
    [state,p111_word(N111Local{"left"}),p111_word(N111Local{"right"}),p111_u32(count)])))


@unsafe
def p128bs_controls() -> List<&2,String>:
  [p128bs_control_row("guard-one-root",p128bs_guard_control(1,N111U64{},p111_state())),
   p128bs_control_row("guard-two-roots",p128bs_guard_control(2,N111U64{},p111_state())),
   p128bs_control_row("guard-zero-refused",Bool.not(p128bs_guard_control(0,N111U64{},p111_state()))),
   p128bs_control_row("guard-three-refused",Bool.not(p128bs_guard_control(3,N111U64{},p111_state()))),
   p128bs_control_row("guard-result-width-refused",Bool.not(p128bs_guard_control(1,N111U32{},p111_state()))),
   p128bs_control_row("guard-state-identity-refused",Bool.not(p128bs_guard_control(1,N111U64{},N111Arg{N111Ptr{},N111Local{"other_state"}}))),
   p128bs_control_row("guard-arity-refused",Bool.not(String.is_empty(p113d_error(p128bs_project_guard("guard",N111U64{},[p111_state()]))))),
   p128bs_control_row("leaf-tail-loop",p128bs_leaf([P113DAgain{[N111Local{"next"}]}])),
   p128bs_control_row("leaf-direct-call-refused",Bool.not(p128bs_leaf([P113DCall{["out"],"helper",[]}]))),
   p128bs_control_row("leaf-nested-call-refused",Bool.not(p128bs_leaf([P113DIf{N111Local{"condition"},[],[P113DCall{["out"],"helper",[]}]}]))),
   p128bs_control_row("transport-new-readonly-guard",p118z_runtime("p118_rt_borrow_scalar_safe")),
   p128bs_control_row("transport-divmod-repair-retained",p118z_runtime("p126_rt_nat_divmod"))]


@unsafe
def p128br_helpers(c: NO_Context) -> List<&2,P128BRHelper>:
  match c:
    case NO_Context{book,owner,schema,helpers}: helpers


@unsafe
def p128br_lookup(+name: String, helpers: List<&2,P128BRHelper>) -> Maybe<&2,P128BRHelper>:
  match helpers:
    case Nil{}: None{}
    case Con{+head,rest}:
      match head:
        case P128BRHelper{owner,params,roots,result,reader,wrapper,resultId}:
          nt_choose(Maybe<&2,P128BRHelper>,String.eq(name,owner),u => Some{head},u => p128br_lookup(name,rest))

@unsafe
def p128br_present(value: Maybe<&2,P128BRHelper>) -> Bool:
  match value:
    case None{}: False{}
    case Some{helper}: True{}


@unsafe
def p128br_held(+origin: KTerm, params: List<&2,KTerm>, +roots: List<&2,U32>, +i: U32) -> Bool:
  match params:
    case Nil{}: False{}
    case Con{head,rest}:
      (no_root_index(roots,i) && noa_below(origin,kt("OArg","",i,0,[]))) ||
        p128br_held(origin,rest,roots,U32.inc(i))


@unsafe
def p128br_arguments(+ctx: NO_Context, params: List<&2,KTerm>, +roots: List<&2,U32>, args: List<&2,KTerm>, +i: U32) -> Bool:
  match params args:
    case Nil{} Nil{}: True{}
    case Con{+param,rest} Con{+arg,more}:
      String.eq(noa_value_type(ctx,arg),nm(param)) &&
        nt_choose(Bool,no_root_index(roots,i),
          u => String.eq(tg(arg),"OA") && p128br_held(noa_origin(arg),
            no_schema_params(noa_schema(ctx)),no_schema_roots(noa_schema(ctx)),0),
          u => Bool.not(String.eq(tg(noa_scalar(ctx,arg)),"Absent"))) &&
        p128br_arguments(ctx,rest,roots,more,U32.inc(i))
    case _ _: False{}


@unsafe
def p128br_words(+ctx: NO_Context, args: List<&2,KTerm>, +roots: List<&2,U32>, +i: U32) -> List<&2,KTerm>:
  match args:
    case Nil{}: []
    case Con{+arg,rest}:
      Con{nt_choose(KTerm,no_root_index(roots,i),u => kid(arg,1),u => noa_scalar(ctx,arg)),
        p128br_words(ctx,rest,roots,U32.inc(i))}


@unsafe
def p128br_call(+ctx: NO_Context, helper: P128BRHelper, +args: List<&2,KTerm>, +facts: List<&2,KTerm>, +n: U32, +fuel: U32, +k: NO_Cont) -> NO_Analysis:
  match helper:
    case P128BRHelper{owner,+params,+roots,+result,reader,+wrapper,+resultId}:
      +id = nc_id(n)
      nt_choose(NO_Analysis,p128br_arguments(ctx,params,roots,args,0) &&
        nol_scalar(noa_book(ctx),kt("ADT",result,0,0,[])) &&
        Bool.not(p131p_parameter(resultId,params)) && p131p_wrapper_ok(wrapper,params,resultId,0),
        u => noa_prepend(kt("NO_Let","",id,0,[kt("NO_ReadCall",reader,0,0,p128br_words(ctx,args,roots,0))]),
          noa_continue(ctx,k,NO_Input{p131p_virtual(wrapper,params,args,resultId,
            noa_atom(result,kt("OUnique","",id,0,[]),var("",id))),facts,U32.inc(n),fuel})),
        u => noa_fail("observer: borrowed helper type, held-origin or result wrapper",n,fuel))

# The schema alone is not authority. Require its successfully lowered private
# reader in the same worker bundle that the existing integration will emit.

@unsafe
def p128br_reference(+ctx: NO_Context, +name: String, +args: List<&2,KTerm>, +facts: List<&2,KTerm>, +stack: List<&2,String>, +n: U32, +fuel: U32, +k: NO_Cont, helper: Maybe<&2,P128BRHelper>) -> NO_Analysis:
  match helper:
    case Some{ready}: p131rv_reference(ctx,name,args,facts,stack,n,fuel,k,ready)
    case None{}:
      +d = lookup(noa_book(ctx),name)
      nt_choose(NO_Analysis,String.eq(dk(d),"Def") && Bool.not(nc_foreign(d) || nc_native_def(d) || nb_contains(stack,name)) && U32.is_lt(nt_count(String,stack),8),
        u => noa_eval(ctx,nc_source_body(noa_book(ctx),d,n),[],facts,Con{name,stack},n,fuel,NO_KApplyArgs{args,k}),
        u => noa_fail("observer: helper effect, cycle or depth",n,fuel))

@unsafe
def p128br_eval_call(+name: String, +n: U32, args: P118BValues) -> P113DCode:
  match args:
    case P118BValues{body,values,next,error}:
      P113DCode{nt_append(P113DStmt,body,[P113DCall{[p118b_value_name(n)],name,values}]),next,error,[name]}


@unsafe
def p128br_project_call(+value: KTerm, +env: List<&2,NC_Binding>) -> KTerm:
  nt_choose(KTerm,String.eq(tg(value),"NO_ReadCall"),
    u => nt_choose(KTerm,no_atoms_valid(ks(value),env) && Bool.not(String.is_empty(nm(value))),
      v => kt("NWord","0",0,0,[]),v => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}),u => value)


@unsafe
def p128br_project_residual(+t: KTerm, +env: List<&2,NC_Binding>) -> KTerm:
  nt_choose(KTerm,String.eq(tg(t),"NO_Let") && U32.is_eq(terms_len(ks(t)),2),
    u => k_with_children(t,[p128br_project_call(kid(t,0),env),
      p128br_project_residual(kid(t,1),Con{nc_binding(ix(t)),env})]),
    u => nt_choose(KTerm,String.eq(tg(t),"NO_Match") && U32.is_eq(terms_len(ks(t)),4),
      v => k_with_children(t,[kid(t,0),kid(t,1),
        p128br_project_residual(kid(t,2),no_bind_fields(ks(kid(t,1)),env)),
        p128br_project_residual(kid(t,3),env)]),v => t))


@unsafe
def p128br_residual_error(+plan: NO_Plan) -> String:
  +schema = no_plan_schema(plan)
  +params = no_plan_params(no_schema_params(schema))
  nc_error(no_emit(p128br_project_residual(noa_body(no_plan_analysis(plan)),params),
    params,params,no_schema_specs_layouts(no_schema_specs(schema)),0))

@unsafe
def p128br_seed(+owner: String, +schema: NO_Schema, workers: P118BWorkers) -> List<&2,P128BRHelper>:
  match workers:
    case P118BWorkers{+functions,+error}:
      +wrapper = no_schema_wrapper(schema)
      +params = no_schema_params(schema)
      +result = no_schema_result(schema)
      +count = nt_count(P113DFunction,functions)
      nt_choose(List<&2,P128BRHelper>,String.is_empty(error) &&
        nt_choose(Bool,String.eq(tg(wrapper),"Var"),u => U32.is_eq(count,3),u => U32.is_ge(count,2) && U32.is_le(count,3)) &&
        Bool.not(p131p_parameter(result,params)) && p131p_wrapper_ok(wrapper,params,result,0) &&
        p131p_reader(p118b_read_name(owner),nt_count(KTerm,params),functions),
        u => [P128BRHelper{owner,params,no_schema_roots(schema),no_schema_observation(schema),p118b_read_name(owner),wrapper,result}],u => [])

@unsafe
def p128br_summaries(+book: List<&2,KDef>, names: List<&2,String>, +original: List<&2,P113DFunction>) -> List<&2,P128BRHelper>:
  match names:
    case Nil{}: []
    case Con{+name,rest}:
      +plan = no_observer_plan(book,name,True{})
      +here = nt_choose(List<&2,P128BRHelper>,p118b_eligible(book,plan),
        u => p128br_seed(name,no_plan_schema(plan),p118b_functions(book,name,plan)),u =>
        nt_choose(List<&2,P128BRHelper>,p128bs_eligible(book,plan),
          v => p128br_seed(name,no_plan_schema(plan),p128bs_find(book,name,plan,original)),v => []))
      nt_append(P128BRHelper,here,p128br_summaries(book,rest,original))

@unsafe
def p128br_plan(+book: List<&2,KDef>, +owner: String, +helpers: List<&2,P128BRHelper>) -> NO_Plan:
  +ordinary = no_schema(book,lookup(book,owner),0)
  +schema = nt_choose(NO_Schema,String.is_empty(no_schema_error(ordinary)),u => ordinary,u => p128bl_schema(book,owner))
  nt_choose(NO_Plan,String.is_empty(no_schema_error(schema)),
    u => no_plan_result(owner,schema,noa_analyze_ready(NO_Context{book,owner,schema,helpers})),
    u => NO_Plan{owner,schema,noa_fail(no_schema_error(schema),no_schema_fresh(schema),4096),no_schema_error(schema)})

@unsafe
def p128br_eligible(+book: List<&2,KDef>, +plan: NO_Plan) -> Bool:
  +schema = no_plan_schema(plan)
  +wrapper = no_schema_wrapper(schema)
  +params = no_plan_params(no_schema_params(schema))
  +roots = no_schema_roots(schema)
  String.is_empty(no_plan_error(plan)) && String.eq(tg(wrapper),"Var") &&
    U32.is_eq(ix(wrapper),no_schema_result(schema)) &&
    String.eq(nm(wrapper),no_schema_observation(schema)) &&
    nol_scalar(book,kt("ADT",nm(wrapper),0,0,[])) &&
    U32.is_ge(nt_count(U32,roots),1) && U32.is_le(nt_count(U32,roots),2) &&
    String.eq(dk(lookup(book,p118b_read_name(no_plan_owner(plan)))),"Absent") &&
    String.eq(dk(lookup(book,p128bs_owned(no_plan_owner(plan)))),"Absent") &&
    String.is_empty(p128br_residual_error(plan)) &&
    String.is_empty(p113d_error(p118b_lower(noa_body(no_plan_analysis(plan)),params,params,
      no_schema_specs_layouts(no_schema_specs(schema)),0)))


@unsafe
def p128br_find(+book: List<&2,KDef>, +owner: String, +plan: NO_Plan, functions: List<&2,P113DFunction>) -> P118BWorkers:
  match functions:
    case Nil{}: P118BWorkers{[],""}
    case Con{+head,rest}:
      match head:
        case P113DFunction{+name,+params,+result,+public,body}:
          nt_choose(P118BWorkers,String.eq(name,p113d_public(book,owner)),
            u => nt_choose(P118BWorkers,public && U32.is_eq(result,1) &&
              U32.is_eq(nt_count(NC_Binding,params),nt_count(KTerm,no_schema_params(no_plan_schema(plan)))),
              v => p128bs_functions(book,owner,plan,head),v => P118BWorkers{[],""}),
            u => p128br_find(book,owner,plan,rest))


@unsafe
def p128br_patch(target: String, workers: P118BWorkers) -> P128BRPatches:
  match workers:
    case P118BWorkers{+functions,error}:
      P128BRPatches{nt_choose(List<&2,P128BRPatch>,List.is_empty(&2,P113DFunction,functions),
        u => [],u => [P128BRPatch{target,functions}]),error}


@unsafe
def p128br_join(first: P128BRPatches, second: P128BRPatches) -> P128BRPatches:
  match first second:
    case P128BRPatches{a,ae} P128BRPatches{b,be}: P128BRPatches{nt_append(P128BRPatch,a,b),p111_first(ae,be)}


@unsafe
def p128br_patches(+book: List<&2,KDef>, names: List<&2,String>, +original: List<&2,P113DFunction>, +helpers: List<&2,P128BRHelper>) -> P128BRPatches:
  match names:
    case Nil{}: P128BRPatches{[],""}
    case Con{+name,rest}:
      +here = nt_choose(P128BRPatches,p128br_present(p128br_lookup(name,helpers)),
        u => P128BRPatches{[],""},
        u => p128br_candidate(book,name,original,p128br_plan(book,name,helpers)))
      p128br_join(here,p128br_patches(book,rest,original,helpers))


@unsafe
def p128br_candidate(+book: List<&2,KDef>, +name: String, +original: List<&2,P113DFunction>, +plan: NO_Plan) -> P128BRPatches:
  nt_choose(P128BRPatches,p128br_eligible(book,plan),
    u => p128br_patch(p113d_public(book,name),p128br_find(book,name,plan,original)),
    u => P128BRPatches{[],""})


@unsafe
def p128br_replacement(+name: String, patches: List<&2,P128BRPatch>) -> Maybe<&2,List<&2,P113DFunction>>:
  match patches:
    case Nil{}: None{}
    case Con{P128BRPatch{target,functions},rest}:
      nt_choose(Maybe<&2,List<&2,P113DFunction>>,String.eq(name,target),u => Some{functions},u => p128br_replacement(name,rest))


@unsafe
def p128br_replace(original: P113DFunction, replacement: Maybe<&2,List<&2,P113DFunction>>) -> List<&2,P113DFunction>:
  match replacement:
    case None{}: [original]
    case Some{functions}: functions


@unsafe
def p128br_apply(functions: List<&2,P113DFunction>, patches: List<&2,P128BRPatch>) -> List<&2,P113DFunction>:
  p128bi_walk(functions,patches,missing(),[])

@unsafe
def p128br_finish(+request: NR_Request, +original: P113AProgram, +workers: P118BWorkers, patches: P128BRPatches) -> P111Emission:
  match patches:
    case P128BRPatches{+edits,+error}:
      nt_choose(P111Emission,String.is_empty(error),u => nt_choose(P111Emission,List.is_empty(&2,P128BRPatch,edits),
          v => p126bp_integrated(request,original,workers),
          v => p128br_compose(request,original,workers,edits)),
        u => P111Emission{[],"borrowed helper plan: " ++ error})


@unsafe
def p128br_compose(+request: NR_Request, original: P113AProgram, workers: P118BWorkers, +patches: List<&2,P128BRPatch>) -> P111Emission:
  match original workers:
    case P113AProgram{P113DProgram{+static,+functions},certificate} P118BWorkers{+added,+error}:
      +checked = p111_first(error,p128br_check_added(static,added))
      +merged = nt_append(P113DFunction,added,p118b_without(functions,p113e_signatures(added,missing())))
      nt_choose(P111Emission,String.is_empty(checked),
        u => p126bp_complete(static,certificate,p128br_apply(nt_choose(List<&2,P113DFunction>,p126bp_has_flat(added),
          v => p113d_passes(p113pl_inspect_request(request),p113e_signatures(merged,missing()),nt_reverse(P113DFunction,merged,[]),32),
          v => merged),patches)),
        u => P111Emission{[],"borrowed helper base: " ++ checked})


@unsafe
def p128br_check_added(static: P112StaticProgram, added: List<&2,P113DFunction>) -> String:
  match static:
    case P112StaticProgram{program,nodes}: p118b_verify_functions(added,program)


@unsafe
def p128br_prepare(+request: NR_Request, +original: P113AProgram, +cold: Bool) -> P111Emission:
  match request:
    case NR_Request{+source,+book,+names,paths,scope,bound}:
      p128br_scanned(request,original,book,source,names,cold,
        p128br_scan(book,no_candidate_names(book,names,nc_bangs_names(book,names)),p128bs_original(original),[],[],[]))

@unsafe
def p128br_helper_names(helpers: List<&2,P128BRHelper>) -> List<&2,String>:
  match helpers:
    case Nil{}: []
    case Con{P128BRHelper{owner,params,roots,result,reader,wrapper,resultId},rest}:
      Con{"helper=" ++ owner ++ ":" ++ result ++ ":" ++ tg(wrapper),p128br_helper_names(rest)}

# Current integrated path: these are the actual workers accumulated for emission,
# not an independently guessed signature set. Keep their old order and retry
# conditions. Product wrappers supply summaries alongside scalar-only readers.

@unsafe
def p128br_diagnose_lowered(+book: List<&2,KDef>, +names: List<&2,String>, +owner: String, lowered: P113ALowering) -> List<&2,String>:
  match lowered:
    case P113ALowered{+original,error}:
      +helpers = p128br_summaries(book,no_candidate_names(book,names,nc_bangs_names(book,names)),p128bs_original(original))
      +plan = p128br_plan(book,owner,helpers)
      +schema = no_plan_schema(plan)
      +params = no_plan_params(no_schema_params(schema))
      nt_append(String,["lowering_error=" ++ error,"owner=" ++ owner,
        "plan_error=" ++ no_plan_error(plan),"schema_error=" ++ no_schema_error(schema),
        "projected_residual_error=" ++ p128br_residual_error(plan),
        "eligible=" ++ U32.show(Bool.to_u32(p128br_eligible(book,plan))),
        "first_parameter=" ++ term_key(nq_layout_type(book,kid(nq_layout_type(book,dt(lookup(book,owner))),0))),
        "residual_error=" ++ nt_choose(String,String.is_empty(no_plan_error(plan)),
          u => p113d_error(p118b_lower(noa_body(no_plan_analysis(plan)),params,params,no_schema_specs_layouts(no_schema_specs(schema)),0)),u => "not-attempted")],
        p128br_helper_names(helpers))


@unsafe
def p128br_diagnose(+request: NR_Request, +owner: String) -> List<&2,String>:
  match request:
    case NR_Request{source,book,names,paths,scope,bound}:
      p128br_diagnose_lowered(book,names,owner,p113a_lower_request(request))


@unsafe
def p128bl_type(+name: String, types: List<&2,KTerm>) -> KTerm:
  match types:
    case Nil{}: {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}
    case Con{+head,rest}: nt_choose(KTerm,String.eq(name,nm(head)),u => head,u => p128bl_type(name,rest))


@unsafe
def p128bl_recursive(+owner: KTerm, fields: List<&2,KTerm>, +count: U32) -> Bool:
  match fields:
    case Nil{}: U32.is_eq(count,1)
    case Con{+head,+rest}:
      nt_choose(Bool,String.eq(nm(head),nm(owner)),
        u => norm_exact(head,owner) && U32.is_eq(count,0) && p128bl_recursive(owner,rest,1),
        u => p128bl_recursive(owner,rest,count))


@unsafe
def p128bl_pair(+book: List<&2,KDef>, +ty: KTerm, +nil: KDef, +cons: KDef) -> P128BLNode:
  +empty = nol_ctor_fields(book,ty,nil)
  +fields = nol_ctor_fields(book,ty,cons)
  nt_choose(P128BLNode,U32.is_eq(da(nil),0) && U32.is_ge(da(cons),2) &&
    String.eq(tg(empty),"NO_Types") && String.eq(tg(fields),"NO_Types") &&
    p128bl_recursive(ty,ks(fields),0),
    u => P128BLNode{[nol_spec(book,nm(ty),nil,"Nullary",[]),
      nol_spec(book,nm(ty),cons,"Boxed",ks(fields))],ks(fields),""},
    u => P128BLNode{[],[],"nested observer: constructor specialization or one recursive child"})


@unsafe
def p128bl_ctors(+book: List<&2,KDef>, +ty: KTerm, ctors: List<&2,KDef>) -> P128BLNode:
  match ctors:
    case Con{+a,Con{+b,Nil{}}}:
      nt_choose(P128BLNode,U32.is_eq(da(a),0),u => p128bl_pair(book,ty,a,b),u => p128bl_pair(book,ty,b,a))
    case _: P128BLNode{[],[],"nested observer: requires finite two-constructor spine"}


@unsafe
def p128bl_node(+book: List<&2,KDef>, +ty: KTerm) -> P128BLNode:
  +owner = lookup(book,nm(ty))
  p131rg_fallback(book,ty,
    nt_choose(P128BLNode,nol_owner(book,ty) && (Bool.not(db(owner)) ||
      String.eq(nm(ty),"String") || String.eq(nm(ty),"List")),
      u => p128bl_ctors(book,ty,dc(owner)),
      u => P128BLNode{[],[],"nested observer: unknown or native non-boxed owner"}))

@unsafe
def p128bl_graph(+book: List<&2,KDef>, todo: List<&2,KTerm>, +types: List<&2,KTerm>, +specs: List<&2,NO_Spec>, +fuel: U32) -> P128BLGraph:
  match todo:
    case Nil{}: P128BLGraph{types,specs,""}
    case Con{+raw,+rest}:
      +ty = nq_layout_type(book,raw)
      nt_choose(P128BLGraph,U32.is_eq(fuel,0),u => P128BLGraph{[],[],"nested observer: layout budget"},
        u => nt_choose(P128BLGraph,nol_scalar(book,ty),
          v => p128bl_graph(book,rest,types,specs,U32.sub(fuel,1)),
          v => p128bl_seen(book,ty,rest,types,specs,U32.sub(fuel,1),p128bl_type(nm(ty),types))))


@unsafe
def p128bl_seen(+book: List<&2,KDef>, +ty: KTerm, +todo: List<&2,KTerm>, +types: List<&2,KTerm>, +specs: List<&2,NO_Spec>, +fuel: U32, +previous: KTerm) -> P128BLGraph:
  nt_choose(P128BLGraph,String.eq(tg(previous),"Absent"),
    u => p128bl_extend(book,ty,todo,types,specs,fuel,p128bl_node(book,ty)),
    u => nt_choose(P128BLGraph,norm_exact(previous,ty),
      v => p128bl_graph(book,todo,types,specs,fuel),
      v => P128BLGraph{[],[],"nested observer: conflicting instantiations of " ++ nm(ty)}))


@unsafe
def p128bl_extend(+book: List<&2,KDef>, +ty: KTerm, +todo: List<&2,KTerm>, +types: List<&2,KTerm>, +specs: List<&2,NO_Spec>, +fuel: U32, node: P128BLNode) -> P128BLGraph:
  match node:
    case P128BLNode{added,children,+error}:
      nt_choose(P128BLGraph,String.is_empty(error),
        u => p128bl_graph(book,nt_append(KTerm,children,todo),Con{ty,types},nt_append(NO_Spec,added,specs),fuel),
        u => P128BLGraph{[],[],error})


@unsafe
def p128bl_finish(+book: List<&2,KDef>, +params: List<&2,KTerm>, +roots: List<&2,U32>, +fresh: U32, +result: KTerm, graph: P128BLGraph) -> NO_Schema:
  match graph:
    case P128BLGraph{types,specs,+error}:
      nt_choose(NO_Schema,String.is_empty(error),
        u => NO_Schema{params,roots,var(nm(result),nc_id(fresh)),nc_id(fresh),nm(result),
          nt_append(NO_Spec,specs,nol_scalar_specs(book,book)),U32.inc(fresh),""},
        u => nol_failure(error,fresh))


@unsafe
def p128bl_result(+book: List<&2,KDef>, +ty: KTerm, +params: List<&2,KTerm>, +roots: List<&2,U32>, +types: List<&2,KTerm>, +seen: List<&2,U32>, +fresh: U32, +arity: U32) -> NO_Schema:
  nt_choose(NO_Schema,U32.is_eq(terms_len(params),arity) &&
    U32.is_ge(nt_count(U32,roots),1) && U32.is_le(nt_count(U32,roots),2) &&
    Bool.not(nq_layout_dep(ty,seen)) && nol_scalar(book,ty),
    u => p128bl_finish(book,nt_reverse(KTerm,params,[]),nt_reverse(U32,roots,[]),fresh,ty,p128bl_graph(book,types,[],[],64)),
    u => nol_failure("nested observer: scalar result or root count",fresh))


@unsafe
def p128bl_params(+book: List<&2,KDef>, +ty: KTerm, +params: List<&2,KTerm>, +roots: List<&2,U32>, +types: List<&2,KTerm>, +seen: List<&2,U32>, +fresh: U32, +fuel: U32, +arity: U32) -> NO_Schema:
  nt_choose(NO_Schema,U32.is_eq(fuel,0),u => nol_failure("nested observer: telescope budget",fresh),
    u => p128bl_head(book,nq_layout_type(book,ty),params,roots,types,seen,fresh,U32.sub(fuel,1),arity))


@unsafe
def p128bl_head(+book: List<&2,KDef>, +head: KTerm, +params: List<&2,KTerm>, +roots: List<&2,U32>, +types: List<&2,KTerm>, +seen: List<&2,U32>, +fresh: U32, +fuel: U32, +arity: U32) -> NO_Schema:
  nt_choose(NO_Schema,String.eq(tg(head),"All"),
    u => nt_choose(NO_Schema,U32.is_eq(qt(head),0),
      v => p128bl_params(book,kid(head,1),params,roots,types,Con{ix(head),seen},fresh,fuel,arity),
      v => p128bl_param(book,head,nq_layout_type(book,kid(head,0)),params,roots,types,seen,fresh,fuel,arity)),
    u => p128bl_result(book,head,params,roots,types,seen,fresh,arity))


@unsafe
def p128bl_param(+book: List<&2,KDef>, +head: KTerm, +ty: KTerm, +params: List<&2,KTerm>, +roots: List<&2,U32>, +types: List<&2,KTerm>, +seen: List<&2,U32>, +fresh: U32, +fuel: U32, +arity: U32) -> NO_Schema:
  +scalar = nol_scalar(book,ty)
  nt_choose(NO_Schema,nol_owner(book,ty) && Bool.not(nq_layout_dep(ty,seen)) && U32.is_lt(terms_len(params),arity),
    u => p128bl_params(book,kid(head,1),Con{var(nm(ty),nc_id(fresh)),params},
      nt_choose(List<&2,U32>,scalar,v => roots,v => Con{terms_len(params),roots}),
      nt_choose(List<&2,KTerm>,scalar,v => types,v => Con{ty,types}),
      Con{ix(head),seen},U32.inc(fresh),fuel,arity),
    u => nol_failure("nested observer: unsupported or dependent parameter",fresh))


@unsafe
def p128bl_schema(+book: List<&2,KDef>, +owner: String) -> NO_Schema:
  +d = lookup(book,owner)
  nt_choose(NO_Schema,String.eq(dk(d),"Def") && Bool.not(nc_foreign(d) || nc_native_def(d)) && U32.is_le(nd_arity(book,owner),4),
    u => p128bl_params(book,dt(d),[],[],[],[],0,32,nd_arity(book,owner)),
    u => nol_failure("nested observer: unsupported owner",0))

# Stage1 succeeds unchanged on old schemas. Only its schema-refused candidates
# try the finite concrete graph; failed proofs retain an explicit diagnostic.

@unsafe
def p128br_test_context() -> NO_Context:
  NO_Context{[],"outer",NO_Schema{[var("String",10)],[0],var("Bool",11),11,"Bool",[],12,""},[]}


@unsafe
def p128br_test_arg(+tag: String, +ty: String, +origin: KTerm) -> KTerm:
  kt(tag,ty,0,0,[origin,var("",10)])


@unsafe
def p128br_test_accept(arg: KTerm) -> Bool:
  p128br_arguments(p128br_test_context(),[var("String",20)],[0],[arg],0)


@unsafe
def p128br_test_residual(+arg: KTerm) -> KTerm:
  kt("NO_Let","",11,0,[kt("NO_ReadCall","checked-reader",0,0,[arg]),kt("NO_Return","",0,0,[var("",11)])])


@unsafe
def p128br_test_projection(+arg: KTerm) -> Bool:
  +env : List<&2,NC_Binding> = [nc_binding(10)]
  String.is_empty(nc_error(no_emit(p128br_project_residual(p128br_test_residual(arg),env),env,env,[],0)))


@unsafe
def p128br_call_controls() -> List<&2,String>:
  +root = kt("OArg","",0,0,[])
  +child = kt("OField","SCon",1,0,[root,ref("String")])
  [p128bs_control_row("borrow-call-held-root",p128br_test_accept(p128br_test_arg("OA","String",root))),
   p128bs_control_row("borrow-call-held-descendant",p128br_test_accept(p128br_test_arg("OA","String",child))),
   p128bs_control_row("borrow-call-unheld-refused",Bool.not(p128br_test_accept(p128br_test_arg("OA","String",kt("OArg","",1,0,[]))))),
   p128bs_control_row("borrow-call-fresh-origin-refused",Bool.not(p128br_test_accept(p128br_test_arg("OA","String",kt("OUnique","",1,0,[]))))),
   p128bs_control_row("borrow-call-virtual-root-refused",Bool.not(p128br_test_accept(p128br_test_arg("OC","String",root)))),
   p128bs_control_row("borrow-call-wrong-type-refused",Bool.not(p128br_test_accept(p128br_test_arg("OA","U32",root)))),
   p128bs_control_row("borrow-call-arity-refused",Bool.not(p128br_arguments(p128br_test_context(),[var("String",20)],[0],[],0))),
   p128bs_control_row("borrow-call-bound-atom-projects",p128br_test_projection(var("",10))),
   p128bs_control_row("borrow-call-unbound-atom-refused",Bool.not(p128br_test_projection(var("",99)))),
   p128bs_control_row("borrow-call-owning-constructor-refused",Bool.not(p128br_test_projection(kt("NCtr","SCon",0,0,[var("",10),var("",10)]))))]

@unsafe
def p128bl_test_error(graph: P128BLGraph) -> String:
  match graph:
    case P128BLGraph{types,specs,error}: error


@unsafe
def p128bl_controls() -> List<&2,String>:
  +strings = kt("ADT","List",0,0,[ref("String")])
  +words = kt("ADT","List",0,0,[ref("U32")])
  [p128bs_control_row("layout-single-recursive-child",p128bl_recursive(strings,[kt("ADT","String",0,0,[]),strings],0)),
   p128bs_control_row("layout-two-recursive-children-refused",Bool.not(p128bl_recursive(strings,[strings,strings],0))),
   p128bs_control_row("layout-changed-instantiation-refused",Bool.not(p128bl_recursive(strings,[words],0))),
   p128bs_control_row("layout-no-recursive-child-refused",Bool.not(p128bl_recursive(strings,[kt("ADT","String",0,0,[])],0))),
   p128bs_control_row("layout-instance-conflict-refused",Bool.not(String.is_empty(p128bl_test_error(p128bl_seen([],words,[],[strings],[],8,strings))))),
   p128bs_control_row("layout-identical-instance-reused",String.is_empty(p128bl_test_error(p128bl_seen([],strings,[],[strings],[],8,strings)))),
   p128bs_control_row("layout-budget-refused",Bool.not(String.is_empty(p128bl_test_error(p128bl_graph([],[strings],[],[],0)))))]


@unsafe
def p128br_retryable(+plan: NO_Plan) -> Bool:
  String.eq(no_plan_error(plan),"observer: helper effect, cycle or depth") ||
    String.eq(no_schema_error(no_plan_schema(plan)),"unsupported or dependent parameter")


@unsafe
def p128br_scan(+book: List<&2,KDef>, names: List<&2,String>, +original: List<&2,P113DFunction>, functions: List<&2,P113DFunction>, helpers: List<&2,P128BRHelper>, retry: List<&2,NO_Plan>) -> P128BROpen:
  match names:
    case Nil{}: P128BROpen{nt_reverse(P113DFunction,functions,[]),nt_reverse(P128BRHelper,helpers,[]),nt_reverse(NO_Plan,retry,[]),""}
    case Con{+name,rest}:
      p128br_scan_plan(book,rest,original,functions,helpers,retry,no_observer_plan(book,name,True{}))


@unsafe
def p128br_scan_plan(+book: List<&2,KDef>, +names: List<&2,String>, +original: List<&2,P113DFunction>, +functions: List<&2,P113DFunction>, +helpers: List<&2,P128BRHelper>, +retry: List<&2,NO_Plan>, +plan: NO_Plan) -> P128BROpen:
  nt_choose(P128BROpen,p118b_eligible(book,plan),
    u => p128br_scan_ready(book,names,original,functions,helpers,retry,plan,False{},p118b_functions(book,no_plan_owner(plan),plan)),
    u => nt_choose(P128BROpen,p128bs_eligible(book,plan),
      v => p128br_scan_ready(book,names,original,functions,helpers,retry,plan,True{},p128bs_find(book,no_plan_owner(plan),plan,original)),
      v => p128br_scan(book,names,original,functions,helpers,
        nt_choose(List<&2,NO_Plan>,p128br_retryable(plan),w => Con{plan,retry},w => retry))))


@unsafe
def p128br_scan_ready(+book: List<&2,KDef>, +names: List<&2,String>, +original: List<&2,P113DFunction>, +functions: List<&2,P113DFunction>, +helpers: List<&2,P128BRHelper>, +retry: List<&2,NO_Plan>, +plan: NO_Plan, +scalar: Bool, +workers: P118BWorkers) -> P128BROpen:
  match workers:
    case P118BWorkers{+added,+error}:
      nt_choose(P128BROpen,String.is_empty(error),
        u => p128br_scan(book,names,original,nt_reverse(P113DFunction,added,functions),
          nt_reverse(P128BRHelper,p128br_seed(no_plan_owner(plan),no_plan_schema(plan),workers),helpers),
          nt_choose(List<&2,NO_Plan>,scalar && List.is_empty(&2,P113DFunction,added),v => Con{plan,retry},v => retry)),
        u => P128BROpen{[],[],[],error})

@unsafe
def p128br_replan(+book: List<&2,KDef>, +plan: NO_Plan, +helpers: List<&2,P128BRHelper>) -> NO_Plan:
  +schema = no_plan_schema(plan)
  nt_choose(NO_Plan,String.is_empty(no_schema_error(schema)),
    u => no_plan_result(no_plan_owner(plan),schema,noa_analyze_ready(NO_Context{book,no_plan_owner(plan),schema,helpers})),
    u => p128br_plan(book,no_plan_owner(plan),helpers))


@unsafe
def p128br_retry_plans(+book: List<&2,KDef>, plans: List<&2,NO_Plan>, +original: List<&2,P113DFunction>, +helpers: List<&2,P128BRHelper>) -> P128BRPatches:
  match plans:
    case Nil{}: P128BRPatches{[],""}
    case Con{+plan,rest}:
      p128br_join(p128br_candidate(book,no_plan_owner(plan),original,p128br_replan(book,plan,helpers)),
        p128br_retry_plans(book,rest,original,helpers))


@unsafe
def p128br_scanned(+request: NR_Request, +original: P113AProgram, +book: List<&2,KDef>, +source: List<&2,KDef>, +names: List<&2,String>, +cold: Bool, scan: P128BROpen) -> P111Emission:
  match scan:
    case P128BROpen{functions,+helpers,retry,+error}:
      nt_choose(P111Emission,String.is_empty(error),
        u => p128br_finish(request,
          nt_choose(P113AProgram,cold,v => p118e_cold(original,book,source,nh_definitions(book,names,[])),v => original),
          P118BWorkers{functions,""},
          p128br_retry_plans(book,retry,p128bs_original(original),helpers)),
        u => P111Emission{[],"borrowed profile: " ++ error})

@unsafe
def p128bi_parameter(+word: String, params: List<&2,NC_Binding>, +i: U32) -> KTerm:
  match params:
    case Nil{}: {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}
    case Con{NC_Binding{id,name,kind},rest}:
      nt_choose(KTerm,String.eq(word,name),u => var("",i),u => p128bi_parameter(word,rest,U32.inc(i)))


@unsafe
def p128bi_pattern(value: N111Value, params: List<&2,NC_Binding>) -> KTerm:
  match value:
    case N111Local{name}: p128bi_parameter(name,params,0)
    case N111Const{lo,hi}: kt("P128BIConstant","",lo,hi,[])
    case _: {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}


@unsafe
def p128bi_patterns(values: List<&2,N111Value>, +params: List<&2,NC_Binding>) -> List<&2,KTerm>:
  match values:
    case Nil{}: []
    case Con{head,rest}: Con{p128bi_pattern(head,params),p128bi_patterns(rest,params)}


@unsafe
def p128bi_all_patterns(patterns: List<&2,KTerm>) -> Bool:
  match patterns:
    case Nil{}: True{}
    case Con{+head,rest}:
      (String.eq(tg(head),"Var") || String.eq(tg(head),"P128BIConstant")) && p128bi_all_patterns(rest)


@unsafe
def p128bi_once(+patterns: KTerm, +count: U32, +i: U32) -> Bool:
  nt_choose(Bool,U32.is_eq(i,count),u => True{},
    u => U32.is_eq(nq_uses(patterns,i),1) && p128bi_once(patterns,count,U32.inc(i)))

# Each rule is immutable source-derived semantic metadata in the existing
# hash index: name=old public entry, type=callee identity, value=argument pattern.
# Constant low/high words remain exact; variables name original parameter slots.

@unsafe
def p128bi_rule(function: P113DFunction) -> KDef:
  match function:
    case P113DFunction{+name,+params,+result,+public,body}:
      match body:
        case Con{P113DCall{Con{+out,Nil{}},+target,args},Con{P113DResult{Con{N111Local{reply},Nil{}}},Nil{}}}:
          +patterns = kt("P128BIPattern","",0,0,p128bi_patterns(args,params))
          +arity = nt_count(NC_Binding,params)
          nt_choose(KDef,public && U32.is_eq(result,1) && String.eq(out,reply) &&
            U32.is_le(arity,4) && U32.is_le(terms_len(ks(patterns)),8) &&
            p128bi_all_patterns(ks(patterns)) && p128bi_once(patterns,arity,0),
            u => KDef{name,"P128BIRule",arity,1,ref(target),patterns,[],False{},False{}},u => missing())
        case _: missing()


@unsafe
def p128bi_index(+index: KDef, +rule: KDef) -> KDef:
  +target = nm(dt(rule))
  +old = index_find(index,target,index_hash(target,2166136261),32)
  nt_choose(KDef,String.eq(dk(rule),"P128BIRule"),
    u => p113e_insert(index,KDef{target,"P128BIRules",0,0,{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},Con{rule,dc(old)},False{},False{}}),
    u => index)


@unsafe
def p128bi_match_value(+pattern: KTerm, value: N111Value) -> Bool:
  nt_choose(Bool,String.eq(tg(pattern),"Var"),u => True{},
    u => p128bi_match_constant(pattern,value))


@unsafe
def p128bi_match_constant(+pattern: KTerm, value: N111Value) -> Bool:
  match value:
    case N111Const{lo,hi}: String.eq(tg(pattern),"P128BIConstant") && U32.is_eq(ix(pattern),lo) && U32.is_eq(qt(pattern),hi)
    case _: False{}


@unsafe
def p128bi_matches(patterns: List<&2,KTerm>, args: List<&2,N111Value>) -> Bool:
  match patterns args:
    case Nil{} Nil{}: True{}
    case Con{pattern,rest} Con{value,more}: p128bi_match_value(pattern,value) && p128bi_matches(rest,more)
    case _ _: False{}


@unsafe
def p128bi_argument(+i: U32, patterns: List<&2,KTerm>, args: List<&2,N111Value>) -> N111Value:
  match patterns args:
    case Con{+pattern,rest} Con{+value,more}:
      nt_choose(N111Value,String.eq(tg(pattern),"Var") && U32.is_eq(ix(pattern),i),
        u => value,u => p128bi_argument(i,rest,more))
    case _ _: N111Const{0,0}


@unsafe
def p128bi_arguments(+count: U32, +i: U32, +patterns: List<&2,KTerm>, +args: List<&2,N111Value>) -> List<&2,N111Value>:
  nt_choose(List<&2,N111Value>,U32.is_eq(i,count),u => [],
    u => Con{p128bi_argument(i,patterns,args),p128bi_arguments(count,U32.inc(i),patterns,args)})


@unsafe
def p128bi_pick(rules: List<&2,KDef>, +destinations: List<&2,String>, +args: List<&2,N111Value>, +original: P113DStmt, +candidate: P113DStmt, +count: U32) -> P113DStmt:
  match rules:
    case Nil{}: nt_choose(P113DStmt,U32.is_eq(count,1),u => candidate,u => original)
    case Con{+rule,+rest}:
      nt_choose(P113DStmt,p128bi_matches(ks(dv(rule)),args),
        u => p128bi_pick(rest,destinations,args,original,
          P113DCall{destinations,dn(rule),p128bi_arguments(da(rule),0,ks(dv(rule)),args)},U32.inc(count)),
        u => p128bi_pick(rest,destinations,args,original,candidate,count))


@unsafe
def p128bi_call(+stmt: P113DStmt, +index: KDef) -> P113DStmt:
  match stmt:
    case P113DCall{+destinations,+target,+args}:
      +bucket = index_find(index,target,index_hash(target,2166136261),32)
      nt_choose(P113DStmt,String.eq(dk(bucket),"P128BIRules") && U32.is_eq(nt_count(String,destinations),1),
        u => p128bi_pick(dc(bucket),destinations,args,stmt,stmt,0),u => stmt)
    case _: stmt


@unsafe
def p128bi_body(body: List<&2,P113DStmt>, +index: KDef) -> List<&2,P113DStmt>:
  match body:
    case Nil{}: []
    case Con{P113DIf{condition,yes,no},rest}:
      Con{P113DIf{condition,p128bi_body(yes,index),p128bi_body(no,index)},p128bi_body(rest,index)}
    case Con{head,rest}: Con{p128bi_call(head,index),p128bi_body(rest,index)}


@unsafe
def p128bi_function(function: P113DFunction, index: KDef) -> P113DFunction:
  match function:
    case P113DFunction{name,params,result,public,body}: P113DFunction{name,params,result,public,p128bi_body(body,index)}


@unsafe
def p128bi_walk(functions: List<&2,P113DFunction>, +patches: List<&2,P128BRPatch>, +index: KDef, reversed: List<&2,P113DFunction>) -> List<&2,P113DFunction>:
  match functions:
    case Nil{}: nt_reverse(P113DFunction,reversed,[])
    case Con{+head,rest}:
      match head:
        case P113DFunction{name,params,result,public,body}:
          p128bi_step(head,rest,patches,index,reversed,p128br_replacement(name,patches))


@unsafe
def p128bi_step(+original: P113DFunction, +rest: List<&2,P113DFunction>, +patches: List<&2,P128BRPatch>, +index: KDef, reversed: List<&2,P113DFunction>, replacement: Maybe<&2,List<&2,P113DFunction>>) -> List<&2,P113DFunction>:
  match replacement:
    case None{}: p128bi_walk(rest,patches,index,Con{p128bi_function(original,index),reversed})
    case Some{functions}: p128bi_walk(rest,patches,p128bi_index(index,p128bi_rule(original)),nt_reverse(P113DFunction,functions,reversed))


@unsafe
def p128bi_test_params() -> List<&2,NC_Binding>:
  [NC_Binding{1,"x",N_W64{}},NC_Binding{2,"y",N_W64{}}]


@unsafe
def p128bi_test_wrapper(+name: String, args: List<&2,N111Value>) -> P113DFunction:
  P113DFunction{name,p128bi_test_params(),1,True{},
    [P113DCall{["answer"],"worker",args},P113DResult{[N111Local{"answer"}]}]}


@unsafe
def p128bi_test_pattern() -> List<&2,N111Value>:
  [N111Const{1,0},N111Local{"x"},N111Local{"y"},N111Const{0,0}]


@unsafe
def p128bi_test_call(+selector: N111Value) -> P113DStmt:
  P113DCall{["out"],"worker",[selector,N111Local{"u"},N111Local{"v"},N111Const{0,0}]}


@unsafe
def p128bi_test_target(stmt: P113DStmt) -> String:
  match stmt:
    case P113DCall{out,target,args}: target
    case _: "not-call"


@unsafe
def p128bi_test_bound(stmt: P113DStmt, +left: String, +right: String) -> Bool:
  match stmt:
    case P113DCall{out,target,Con{N111Local{a},Con{N111Local{b},Nil{}}}}:
      String.eq(target,"observe") && String.eq(a,left) && String.eq(b,right)
    case _: False{}


@unsafe
def p128bi_test_caller(name: String) -> P113DFunction:
  P113DFunction{name,p128bi_test_params(),1,False{},
    [P113DCall{["answer"],"worker",p128bi_test_pattern()},P113DResult{[N111Local{"answer"}]}]}


@unsafe
def p128bi_test_body_target(+name: String, functions: List<&2,P113DFunction>) -> String:
  match functions:
    case Nil{}: "missing"
    case Con{P113DFunction{target,params,result,public,body},rest}:
      nt_choose(String,String.eq(name,target),
        u => p128bi_test_first(body),u => p128bi_test_body_target(name,rest))


@unsafe
def p128bi_test_first(body: List<&2,P113DStmt>) -> String:
  match body:
    case Con{head,rest}: p128bi_test_target(head)
    case _: "empty"


@unsafe
def p128bi_test_walk() -> List<&2,P113DFunction>:
  +original = p128bi_test_wrapper("observe",p128bi_test_pattern())
  +replacement : List<&2,P113DFunction> = [p128bi_test_caller("owned"),
    P113DFunction{"observe",p128bi_test_params(),1,True{},
      [P113DCall{["answer"],"owned",[N111Local{"x"},N111Local{"y"}]},P113DResult{[N111Local{"answer"}]}]}]
  p128br_apply([p128bi_test_caller("before"),original,p128bi_test_caller("after")],
    [P128BRPatch{"observe",replacement}])


@unsafe
def p128bi_controls() -> List<&2,String>:
  +good = p128bi_rule(p128bi_test_wrapper("observe",p128bi_test_pattern()))
  +index = p128bi_index(missing(),good)
  +permuted = p128bi_index(missing(),p128bi_rule(p128bi_test_wrapper("observe",
    [N111Const{1,0},N111Local{"y"},N111Local{"x"},N111Const{0,0}])))
  +duplicate = p128bi_rule(p128bi_test_wrapper("observe",[N111Local{"x"},N111Local{"x"}]))
  +missing_arg = p128bi_rule(p128bi_test_wrapper("observe",[N111Local{"x"}]))
  +bad_result = p128bi_rule(P113DFunction{"observe",p128bi_test_params(),1,True{},
    [P113DCall{["answer"],"worker",p128bi_test_pattern()},P113DResult{[N111Local{"different"}]}]})
  +permuted_result = p128bi_rule(P113DFunction{"observe",p128bi_test_params(),2,True{},
    [P113DCall{["a","b"],"worker",p128bi_test_pattern()},P113DResult{[N111Local{"b"},N111Local{"a"}]}]})
  +ambiguous = p128bi_index(index,p128bi_rule(p128bi_test_wrapper("alternative",p128bi_test_pattern())))
  +walk = p128bi_test_walk()
  [p128bs_control_row("boundary-exact-wrapper",String.eq(dk(good),"P128BIRule")),
   p128bs_control_row("boundary-inverse-bindings",p128bi_test_bound(p128bi_call(p128bi_test_call(N111Const{1,0}),index),"u","v")),
   p128bs_control_row("boundary-inverse-permutation",p128bi_test_bound(p128bi_call(p128bi_test_call(N111Const{1,0}),permuted),"v","u")),
   p128bs_control_row("boundary-wrong-selector-falls-back",String.eq(p128bi_test_target(p128bi_call(p128bi_test_call(N111Const{0,0}),index)),"worker")),
   p128bs_control_row("boundary-high-selector-bits-preserved",String.eq(p128bi_test_target(p128bi_call(p128bi_test_call(N111Const{1,1}),index)),"worker")),
   p128bs_control_row("boundary-dynamic-selector-falls-back",String.eq(p128bi_test_target(p128bi_call(p128bi_test_call(N111Local{"dynamic"}),index)),"worker")),
   p128bs_control_row("boundary-repeated-formal-refused",String.eq(dk(duplicate),"Absent")),
   p128bs_control_row("boundary-missing-formal-refused",String.eq(dk(missing_arg),"Absent")),
   p128bs_control_row("boundary-different-result-refused",String.eq(dk(bad_result),"Absent")),
   p128bs_control_row("boundary-result-permutation-refused",String.eq(dk(permuted_result),"Absent")),
   p128bs_control_row("boundary-ambiguous-rule-falls-back",String.eq(p128bi_test_target(p128bi_call(p128bi_test_call(N111Const{1,0}),ambiguous)),"worker")),
   p128bs_control_row("boundary-earlier-caller-untouched",String.eq(p128bi_test_body_target("before",walk),"worker")),
   p128bs_control_row("boundary-later-caller-rewritten",String.eq(p128bi_test_body_target("after",walk),"observe")),
   p128bs_control_row("boundary-owning-fallback-untouched",String.eq(p128bi_test_body_target("owned",walk),"worker")),
   p128bs_control_row("boundary-new-adapter-untouched",String.eq(p128bi_test_body_target("observe",walk),"owned"))]

# Keep the existing numeric IDs; retain constructor arity in unused emitter
# metadata so this late template checks the same descriptor/count again.

@unsafe
def p128bf_known(+ctor: String, +count: U32, ids: N111Ids) -> Bool:
  match ids:
    case N111Ids{functions,constructors}:
      +entry = index_find(constructors,ctor,index_hash(ctor,2166136261),32)
      String.eq(dk(entry),"N111Id") && U32.is_lt(da(entry),65536) && U32.is_eq(dx(entry),count)


@unsafe
def p128bf_match(+stmt: N111Stmt, +ids: N111Ids, +site: U32) -> P128BFRead:
  match stmt:
    case N111Call{+dest,N111U64{},+symbol,
      Con{N111Arg{N111Ptr{},N111Local{+state}},
      Con{N111Arg{N111U64{},term},
      Con{N111Arg{N111Ptr{},N111Local{+buffer}},
      Con{N111Arg{N111U32{},N111CtorId{+ctor}},
      Con{N111Arg{N111U32{},N111Const{+count,+high}},Nil{}}}}}}}:
        nt_choose(P128BFRead,String.eq(symbol,"p118_rt_borrow_fields") && String.eq(state,"state") &&
          U32.is_eq(high,0) && U32.is_ge(count,2) && U32.is_le(count,8) &&
          p114t_buffer(buffer) && p128bf_known(ctor,count,ids) && U32.is_le(site,4294967200),
          u => P128BFRead{dest,term,buffer,ctor,count},u => P128BFSkip{})
    case _: P128BFSkip{}


@unsafe
def p128bf_guard(+term: N111Value, +ctor: String, +site: U32) -> List<&2,N111Stmt>:
  [N111Set{p114t_name(site,"borrow_word"),N111U64{},term},
   N111Bin{p114t_name(site,"borrow_tag_bits"),N111U64{},"shr",p114t_local(site,"borrow_word"),N111Const{56,0}},
   N111Bin{p114t_name(site,"borrow_tag"),N111U64{},"and",p114t_local(site,"borrow_tag_bits"),N111Const{127,0}},
   N111Bin{p114t_name(site,"borrow_is_ctr"),N111U64{},"eq",p114t_local(site,"borrow_tag"),N111Const{2,0}},
   N111Bin{p114t_name(site,"borrow_aux_bits"),N111U64{},"shr",p114t_local(site,"borrow_word"),N111Const{40,0}},
   N111Bin{p114t_name(site,"borrow_aux"),N111U64{},"and",p114t_local(site,"borrow_aux_bits"),N111Const{65535,0}},
   N111Bin{p114t_name(site,"borrow_is_ctor"),N111U64{},"eq",p114t_local(site,"borrow_aux"),N111CtorId{ctor}},
   N111Bin{p114t_name(site,"borrow_guard"),N111U32{},"and",p114t_local(site,"borrow_is_ctr"),p114t_local(site,"borrow_is_ctor")}]

# rfc_view's exact low/high word layout. The selected CPU runtime has no
# concurrent refcount mutation; this is not a concurrent/device template.

@unsafe
def p128bf_rfc(+site: U32) -> List<&2,N111Stmt>:
  [N111Bin{p114t_name(site,"borrow_header_bytes"),N111U64{},"shl",p114t_local(site,"borrow_location"),N111Const{3,0}},
   N111Offset{p114t_name(site,"borrow_header"),p114t_local(site,"borrow_heap"),p114t_local(site,"borrow_header_bytes")},
   N111Load{p114t_name(site,"borrow_low"),N111U32{},p114t_local(site,"borrow_header"),0},
   N111Load{p114t_name(site,"borrow_high"),N111U32{},p114t_local(site,"borrow_header"),4},
   N111Bin{p114t_name(site,"borrow_high_shift"),N111U64{},"shl",p114t_local(site,"borrow_high"),N111Const{32,0}},
   N111Bin{p114t_name(site,"borrow_header_word"),N111U64{},"or",p114t_local(site,"borrow_low"),p114t_local(site,"borrow_high_shift")},
   N111Bin{p114t_name(site,"borrow_location"),N111U64{},"shr",p114t_local(site,"borrow_header_word"),N111Const{24,0}}]


@unsafe
def p128bf_fields(+buffer: String, +count: U32, +site: U32, +index: U32) -> List<&2,N111Stmt>:
  nt_choose(List<&2,N111Stmt>,U32.is_eq(index,count),u => [],u =>
    Con{N111Load{p114t_name(site,"borrow_field_" ++ U32.show(index)),N111U64{},p114t_local(site,"borrow_fields"),U32.mul(index,8)},
    Con{N111Store{N111U64{},N111Local{buffer},U32.mul(index,8),p114t_local(site,"borrow_field_" ++ U32.show(index))},
      p128bf_fields(buffer,count,site,U32.inc(index))}})


@unsafe
def p128bf_fast(+dest: String, +buffer: String, +count: U32, +site: U32) -> List<&2,N111Stmt>:
  nt_append(N111Stmt,
    [N111Load{p114t_name(site,"borrow_heap"),N111Ptr{},N111Local{"state"},0},
     N111Bin{p114t_name(site,"borrow_location"),N111U64{},"and",p114t_local(site,"borrow_word"),N111Const{4294967295,255}},
     N111Bin{p114t_name(site,"borrow_rfc_bit"),N111U64{},"shr",p114t_local(site,"borrow_word"),N111Const{63,0}},
     N111Bin{p114t_name(site,"borrow_is_rfc"),N111U64{},"ne",p114t_local(site,"borrow_rfc_bit"),N111Const{0,0}},
     N111If{p114t_local(site,"borrow_is_rfc"),p128bf_rfc(site),[]},
     N111Bin{p114t_name(site,"borrow_field_bytes"),N111U64{},"shl",p114t_local(site,"borrow_location"),N111Const{3,0}},
     N111Offset{p114t_name(site,"borrow_fields"),p114t_local(site,"borrow_heap"),p114t_local(site,"borrow_field_bytes")}],
    nt_append(N111Stmt,p128bf_fields(buffer,count,site,0),[N111Set{dest,N111U64{},N111Const{count,0}}]))

# Preserve the complete previous rendering path, including Phase126 Nat and
# Phase114 transport templates. Calling this directly on the fallback prevents
# recursively expanding the same import inside its own slow branch.

@unsafe
def p128bf_previous(+stmt: N111Stmt, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match code:
    case P111QCode{chunks,next,terminal,error}:
      nt_choose(P111QCode,Bool.not(terminal) && String.is_empty(error),
        u => p126nt_emit(stmt,ids,code,p126nt_expand(stmt,next)),u => p126nt_previous_stmt(stmt,ids,code))


@unsafe
def p128bf_join(+stmt: N111Stmt, +ids: N111Ids, +label: U32, fast: P111QCode) -> P111QCode:
  match fast:
    case P111QCode{+chunks,n,terminal,error}:
      +prefix = nt_choose(List<&2,String>,terminal,u => chunks,u => Con{"jmp " ++ p111q_label(U32.add(label,2)) ++ "\n",chunks})
      p111q_if_done(label,terminal,p128bf_previous(stmt,ids,
        P111QCode{Con{p111q_label(U32.inc(label)) ++ "\n",prefix},n,False{},error}))


@unsafe
def p128bf_branch(+stmt: N111Stmt, +read: P128BFRead, +ids: N111Ids, +site: U32, +code: P111QCode) -> P111QCode:
  match read code:
    case P128BFRead{dest,term,buffer,ctor,count} P111QCode{chunks,n,terminal,error}:
      p128bf_join(stmt,ids,n,p111q_stmts(p128bf_fast(dest,buffer,count,site),ids,
        P111QCode{Con{p111q_label(n) ++ "\n",Con{"jnz " ++ p111q_value(p114t_local(site,"borrow_guard"),ids) ++ ", " ++
          p111q_label(n) ++ ", " ++ p111q_label(U32.inc(n)) ++ "\n",chunks}},U32.add(n,3),False{},error}))
    case _ _: p128bf_previous(stmt,ids,code)


@unsafe
def p128bf_selected(+stmt: N111Stmt, +read: P128BFRead, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match read code:
    case P128BFRead{dest,term,buffer,ctor,count} P111QCode{chunks,next,terminal,error}:
      p128bf_branch(stmt,read,ids,next,
        p111q_stmts(p128bf_guard(term,ctor,next),ids,P111QCode{chunks,U32.inc(next),terminal,error}))
    case _ _: p128bf_previous(stmt,ids,code)


@unsafe
def p128bf_test_ids() -> N111Ids:
  N111Ids{missing(),p111q_constructor_ids(
    [N_Constructor{"pair",2,False{}},N_Constructor{"packed",1,False{}},N_Constructor{"large",8,False{}}],0,missing())}


@unsafe
def p128bf_test_call(symbol: String, state: String, buffer: String, ctor: N111Value, count: N111Value, typ: N111Type) -> N111Stmt:
  N111Call{"status",typ,symbol,[N111Arg{N111Ptr{},N111Local{state}},p111_word(N111Local{"word"}),
    N111Arg{N111Ptr{},N111Local{buffer}},N111Arg{N111U32{},ctor},N111Arg{N111U32{},count}]}


@unsafe
def p128bf_test_ordinary(+ctor: String, count: U32) -> N111Stmt:
  p128bf_test_call("p118_rt_borrow_fields","state","scratch",N111CtorId{ctor},N111Const{count,0},N111U64{})


@unsafe
def p128bf_test_admitted(stmt: N111Stmt, ids: N111Ids, site: U32) -> Bool:
  p128bf_test_result(p128bf_match(stmt,ids,site))


@unsafe
def p128bf_test_result(result: P128BFRead) -> Bool:
  match result:
    case P128BFRead{dest,term,buffer,ctor,count}: True{}
    case _: False{}


@unsafe
def p128bf_test_text(+stmt: N111Stmt, +previous: Bool) -> String:
  +ids = p128bf_test_ids()
  +code : P111QCode = P111QCode{[],0,False{},""}
  p111q_body_text(p111q_stmt(N111Return{N111Local{"status"}},ids,
    nt_choose(P111QCode,previous,u => p128bf_previous(stmt,ids,code),u => p111q_stmt(stmt,ids,code))))


@unsafe
def p128bf_test_same(+stmt: N111Stmt) -> Bool:
  String.eq(p128bf_test_text(stmt,True{}),p128bf_test_text(stmt,False{}))


@unsafe
def p128bf_controls() -> List<&2,String>:
  +ids = p128bf_test_ids()
  +read = p128bf_test_ordinary("pair",2)
  +text = p128bf_test_text(read,False{})
  [p128bs_control_row("field-pair-admitted",p128bf_test_admitted(read,ids,0)),
   p128bs_control_row("field-eight-admitted",p128bf_test_admitted(p128bf_test_ordinary("large",8),ids,0)),
   p128bs_control_row("field-packed-refused",Bool.not(p128bf_test_admitted(p128bf_test_ordinary("packed",1),ids,0))),
   p128bs_control_row("field-wrong-width-refused",Bool.not(p128bf_test_admitted(p128bf_test_ordinary("pair",3),ids,0))),
   p128bs_control_row("field-unknown-ctor-refused",Bool.not(p128bf_test_admitted(p128bf_test_ordinary("absent",2),ids,0))),
   p128bs_control_row("field-zero-refused",Bool.not(p128bf_test_admitted(p128bf_test_ordinary("pair",0),ids,0))),
   p128bs_control_row("field-counter-bound-refused",Bool.not(p128bf_test_admitted(read,ids,4294967295))),
   p128bs_control_row("field-missing-metadata-refused",Bool.not(p128bf_test_admitted(read,N111Ids{missing(),p111q_insert(missing(),"pair",0)},0))),
   p128bs_control_row("field-numeric-cid-refused",Bool.not(p128bf_test_admitted(p128bf_test_call("p118_rt_borrow_fields","state","scratch",N111Const{0,0},N111Const{2,0},N111U64{}),ids,0))),
   p128bs_control_row("field-high-count-refused",Bool.not(p128bf_test_admitted(p128bf_test_call("p118_rt_borrow_fields","state","scratch",N111CtorId{"pair"},N111Const{2,1},N111U64{}),ids,0))),
   p128bs_control_row("field-wrong-state-refused",Bool.not(p128bf_test_admitted(p128bf_test_call("p118_rt_borrow_fields","other","scratch",N111CtorId{"pair"},N111Const{2,0},N111U64{}),ids,0))),
   p128bs_control_row("field-unknown-buffer-refused",Bool.not(p128bf_test_admitted(p128bf_test_call("p118_rt_borrow_fields","state","arbitrary",N111CtorId{"pair"},N111Const{2,0},N111U64{}),ids,0))),
   p128bs_control_row("field-pointer-result-refused",Bool.not(p128bf_test_admitted(p128bf_test_call("p118_rt_borrow_fields","state","scratch",N111CtorId{"pair"},N111Const{2,0},N111Ptr{}),ids,0))),
   p128bs_control_row("field-other-import-unchanged",p128bf_test_same(p128bf_test_call("other","state","scratch",N111CtorId{"pair"},N111Const{2,0},N111U64{}))),
   p128bs_control_row("field-packed-byte-identical",p128bf_test_same(p128bf_test_ordinary("packed",1))),
   p128bs_control_row("field-ids-preserved",String.eq(p111q_value(N111CtorId{"large"},ids),"2")),
   p128bs_control_row("field-template-contains-guard",String.contains(text,"_borrow_guard =w and ") && String.contains(text,"jnz %v_p114t_0_borrow_guard")),
   p128bs_control_row("field-template-contains-rfc",String.contains(text,"_borrow_high =l loaduw ") && String.contains(text,"_borrow_header_word =l or ")),
   p128bs_control_row("field-original-fallback-retained",String.contains(text,"call $p118_rt_borrow_fields(l %state, l %v_word, l %v_scratch, w 0, w 2)")),
   p128bs_control_row("field-exact-status",String.contains(text,"%v_status =l copy 2\n") && String.contains(text,"ret %v_status\n")),
   p128bs_control_row("field-not-blanket-pointer-admission",Bool.not(p111v_memory(N111Local{"arbitrary"},0,2,missing(),ids)))]

@unsafe
def p128bf_oracle_function(+name: String, +arity: U32, +count: U32) -> String:
  +ids : N111Ids = N111Ids{missing(),p111q_constructor_ids([N_Constructor{"oracle",arity,False{}}],0,missing())}
  +call : N111Stmt = N111Call{"status",N111U64{},"p118_rt_borrow_fields",
    [p111_state(),p111_word(N111Local{"word"}),p111_scratch(),
      N111Arg{N111U32{},N111CtorId{"oracle"}},p111_u32(count)]}
  "export function l $" ++ name ++ "(l %state, l %v_word, l %v_scratch) {\n@entry\n" ++
    p111q_body_text(p111q_stmts([call,N111Return{N111Local{"status"}}],ids,P111QCode{[],0,False{},""})) ++ "}\n"


@unsafe
def p128bf_oracle_widths(+width: U32) -> String:
  nt_choose(String,U32.is_gt(width,8),u => "",u =>
    p128bf_oracle_function("p128bf_width_" ++ U32.show(width),width,width) ++ p128bf_oracle_widths(U32.inc(width)))


@unsafe
def p128bf_oracle_module() -> String:
  p128bf_oracle_widths(0) ++ p128bf_oracle_function("p128bf_mismatched_count",2,3)
