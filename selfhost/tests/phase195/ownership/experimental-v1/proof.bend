# This module produces diagnostic evidence only. It has no adapter emitter and
# cannot replace a function. Every outcome retains the original implementation.
@unsafe
def p195od_inputs(c: P195ODContext) -> List<&2,KTerm>:
  match c:
    case P195ODContext{book,owner,schema,helpers,inputs,summaries}: inputs

@unsafe
def p195od_helpers(c: P195ODContext) -> List<&2,P128BRHelper>:
  match c:
    case P195ODContext{book,owner,schema,helpers,inputs,summaries}: helpers

@unsafe
def p195od_summaries(c: P195ODContext) -> List<&2,P195ODSummary>:
  match c:
    case P195ODContext{book,owner,schema,helpers,inputs,summaries}: summaries

@unsafe
def p195oa_virtual(t,env):
  nt_choose(KTerm,String.eq(tg(t),"Var"),u => p195oa_env(ix(t),env),
    u => nt_choose(KTerm,String.eq(tg(t),"ODOwned"),v => p195oa_env(nc_id(64),env),v => kt("OC",nm(t),0,0,p195oa_virtual_fields(ks(t),env))))

@unsafe
def p195od_virtual_inputs(patterns: List<&2,KTerm>, +env: List<&2,KTerm>) -> List<&2,KTerm>:
  match patterns:
    case Nil{}: []
    case Con{p,rest}: Con{p195oa_virtual(p,env),p195od_virtual_inputs(rest,env)}

@unsafe
def p195oa_analyze_ready(+ctx: P195ODContext) -> NO_Analysis:
  +schema = p195oa_schema(ctx)
  +params = no_schema_params(schema)
  +env = p195oa_actuals(params,p195oa_entry_values(params,0))
  +body = nc_source_body(p195oa_book(ctx),lookup(p195oa_book(ctx),p195oa_owner(ctx)),no_schema_fresh(schema))
  p195oa_eval(ctx,body,[],[],[],no_schema_fresh(schema),4096,NO_KApplyArgs{p195od_virtual_inputs(p195od_inputs(ctx),env),NO_KFinish{}})

@unsafe
def p195oa_match_fields(+ctx: P195ODContext, +fn: KTerm, +arg: KTerm, +facts: List<&2,KTerm>, +key: String, +fields: List<&2,KTerm>, +n: U32, +fuel: U32, +k: NO_Cont) -> NO_Analysis:
  +mat = kid(fn,0)
  +yesfacts = Con{kt("OFact","",0,0,[p195oa_origin(arg),kt("OC",nm(mat),0,0,p195oa_origins(fields)),arg]),facts}
  +yes = p195oa_eval(ctx,kid(mat,0),ks(kid(fn,1)),yesfacts,p195oa_unames(ks(kid(fn,2))),n,fuel,NO_KApplyArgs{fields,k})
  nt_choose(NO_Analysis,String.is_empty(p195oa_error(yes)),
    u => p195oa_match_join(key,kid(arg,1),fields,yes,p195oa_eval(ctx,kid(mat,1),ks(kid(fn,1)),facts,p195oa_unames(ks(kid(fn,2))),p195oa_fresh(yes),p195oa_fuel(yes),NO_KApplyOne{arg,k}),u => yes)

@unsafe
def p195od_rebase_facts(+value: KTerm, facts: List<&2,KTerm>, +all: List<&2,KTerm>) -> KTerm:
  match facts:
    case Nil{}: value
    case Con{+fact,rest}:
      nt_choose(KTerm,U32.is_eq(terms_len(ks(fact)),3) && p195oa_equal(value,kid(fact,0),all),u => kid(fact,2),u => p195od_rebase_facts(value,rest,all))

@unsafe
def p195od_rebase(+value: KTerm, +facts: List<&2,KTerm>) -> KTerm:
  nt_choose(KTerm,String.eq(tg(value),"OC"),u => p195od_rebase_facts(value,facts,facts),u => value)

law p195od_flat:
  for +pattern: KTerm
  for +value: KTerm
  for +facts: List<&2,KTerm>
  KTerm

@unsafe
def p195od_flat_fields(patterns: List<&2,KTerm>, values: List<&2,KTerm>, +facts: List<&2,KTerm>) -> KTerm:
  match patterns values:
    case Nil{} Nil{}: kt("ODFlat","",0,0,[])
    case Con{p,ps} Con{v,vs}: p195od_flat_join(p195od_flat(p,v,facts),p195od_flat_fields(ps,vs,facts))
    case _ _: p195od_absent()

@unsafe
def p195od_flat_join(+a: KTerm, +b: KTerm) -> KTerm:
  nt_choose(KTerm,String.eq(tg(a),"ODFlat") && String.eq(tg(b),"ODFlat"),u => kt("ODFlat","",0,0,nt_append(KTerm,ks(a),ks(b))),u => p195od_absent())

@unsafe
def p195od_flat(pattern,value,facts):
  nt_choose(KTerm,String.eq(tg(pattern),"Var"),u => kt("ODFlat","",0,0,[p195od_rebase(value,facts)]),
    u => nt_choose(KTerm,String.eq(tg(pattern),"Ctr") && String.eq(tg(value),"OC") && String.eq(nm(pattern),nm(value)),v => p195od_flat_fields(ks(pattern),ks(value),facts),v => p195od_absent()))

@unsafe
def p195od_owned_result(+ctx: P195ODContext, +value: KTerm, +template: KTerm) -> KTerm:
  +payload = kid(value,0)
  +held = p128br_held(p195oa_origin(payload),no_schema_params(p195oa_schema(ctx)),no_schema_roots(p195oa_schema(ctx)),0)
  nt_choose(KTerm,String.eq(tg(value),"ODOpaqueResult") && String.eq(nm(value),nm(template)) && U32.is_eq(terms_len(ks(value)),2),u => kt("OResult","",0,0,ks(value)),
    u => nt_choose(KTerm,String.eq(tg(value),"OC") && String.eq(nm(value),nm(kid(template,0))) && U32.is_eq(terms_len(ks(value)),0),v => kt("OResult","",0,0,[kt("NWord","0",0,0,[]),kt("NWord","0",0,0,[])]),
      v => nt_choose(KTerm,String.eq(tg(value),"OC") && String.eq(nm(value),nm(kid(template,1))) && U32.is_eq(terms_len(ks(value)),1) && String.eq(tg(payload),"OA") && String.eq(nm(payload),nm(template)) && held,
        w => kt("OResult","",0,0,[kt("NWord","1",0,0,[]),kid(payload,1)]),w => p195od_absent())))

@unsafe
def p195oa_finish_value(ctx,value,template,facts):
  nt_choose(KTerm,String.eq(tg(template),"ODOwned"),u => p195od_owned_result(ctx,value,template),
    u => nt_choose(KTerm,String.eq(tg(template),"Var"),v => nt_choose(KTerm,p195oa_equal(value,p195oa_param_origin(ix(template),no_schema_params(p195oa_schema(ctx)),0),facts),w => kt("OResult","",0,0,[]),w => p195od_absent()),
      v => nt_choose(KTerm,String.eq(tg(template),"Ctr") && String.eq(tg(value),"OC") && String.eq(nm(template),nm(value)),w => p195oa_finish_fields(ctx,ks(value),ks(template),facts),w => p195od_absent())))

@unsafe
def p195oa_finish(+ctx: P195ODContext, +input: NO_Input) -> NO_Analysis:
  +result = p195oa_finish_value(ctx,p195oa_iv(input),no_schema_wrapper(p195oa_schema(ctx)),p195oa_if(input))
  nt_choose(NO_Analysis,String.eq(tg(result),"OResult") && U32.is_eq(terms_len(ks(result)),2),
    u => NO_Analysis{kt("NO_Return","",0,0,ks(result)),p195oa_in(input),p195oa_iu(input),""},
    u => p195oa_fail("owned diagnostic: root identity or owned descendant unproved",p195oa_in(input),p195oa_iu(input)))

@unsafe
def p195oa_recur(ctx,args,facts,n,fuel,k):
  +schema = p195oa_schema(ctx)
  +flat = p195od_flat_fields(p195od_inputs(ctx),args,facts)
  +params = no_schema_params(schema)
  +marker = kt("ODOpaqueResult",no_schema_observation(schema),0,0,[var("",nc_id(n)),var("",nc_id(U32.inc(n)))])
  +env = p195oa_bind(nc_id(64),marker,p195oa_actuals(params,ks(flat)))
  nt_choose(NO_Analysis,String.eq(tg(flat),"ODFlat") && p195oa_loop_valid(ctx,params,ks(flat),0,False{}),
    u => p195oa_recur_done(ctx,ks(flat),marker,p195oa_continue(ctx,k,NO_Input{p195oa_virtual(no_schema_wrapper(schema),env),facts,U32.add(n,2),fuel})),
    u => p195oa_fail("owned diagnostic: product cursor descent/scalar state",n,fuel))

@unsafe
def p195oa_recur_done(+ctx: P195ODContext, +args: List<&2,KTerm>, +marker: KTerm, rest: NO_Analysis) -> NO_Analysis:
  match rest:
    case NO_Analysis{+body,n,fuel,+error}:
      nt_choose(NO_Analysis,String.is_empty(error) && String.eq(tg(body),"NO_Return") && norm_exact_lists(ks(body),ks(marker)),
        u => NO_Analysis{kt("NO_Loop","",0,0,p195oa_loop_words(ctx,no_schema_params(p195oa_schema(ctx)),args)),n,fuel,""},
        u => p195oa_fail(p111_first(error,"owned diagnostic: recursive result continuation"),n,fuel))

@unsafe
def p195od_summary_lookup(+name: String, summaries: List<&2,P195ODSummary>) -> Maybe<&2,P195ODSummary>:
  match summaries:
    case Nil{}: None{}
    case Con{+s,rest}:
      match s:
        case P195ODSummary{owner,schema,inputs}: nt_choose(Maybe<&2,P195ODSummary>,String.eq(name,owner),u => Some{s},u => p195od_summary_lookup(name,rest))

@unsafe
def p195od_arguments(+ctx: P195ODContext, params: List<&2,KTerm>, +roots: List<&2,U32>, args: List<&2,KTerm>, +i: U32) -> Bool:
  match params args:
    case Nil{} Nil{}: True{}
    case Con{+param,rest} Con{+arg,more}:
      String.eq(p195oa_value_type(ctx,arg),nm(param)) &&
        nt_choose(Bool,no_root_index(roots,i),
          u => String.eq(tg(arg),"OA") && p128br_held(p195oa_origin(arg),no_schema_params(p195oa_schema(ctx)),no_schema_roots(p195oa_schema(ctx)),0),
          u => Bool.not(String.eq(tg(p195oa_scalar(ctx,arg)),"Absent"))) &&
        p195od_arguments(ctx,rest,roots,more,U32.inc(i))
    case _ _: False{}

@unsafe
def p195od_words(+ctx: P195ODContext, args: List<&2,KTerm>, +roots: List<&2,U32>, +i: U32) -> List<&2,KTerm>:
  match args:
    case Nil{}: []
    case Con{+arg,rest}: Con{nt_choose(KTerm,no_root_index(roots,i),u => kid(arg,1),u => p195oa_scalar(ctx,arg)),p195od_words(ctx,rest,roots,U32.inc(i))}

@unsafe
def p195od_scalar_call(+ctx: P195ODContext, helper: P128BRHelper, +args: List<&2,KTerm>, +facts: List<&2,KTerm>, +n: U32, +fuel: U32, +k: NO_Cont) -> NO_Analysis:
  match helper:
    case P128BRHelper{owner,+params,+roots,+result,reader,+wrapper,+resultId}:
      +id = nc_id(n)
      nt_choose(NO_Analysis,p195od_arguments(ctx,params,roots,args,0) && nol_scalar(p195oa_book(ctx),kt("ADT",result,0,0,[])) && Bool.not(p131p_parameter(resultId,params)) && p131p_wrapper_ok(wrapper,params,resultId,0),
        u => p195oa_prepend(kt("NO_Let","",id,0,[kt("NO_ReadCall",reader,0,0,p195od_words(ctx,args,roots,0))]),p195oa_continue(ctx,k,NO_Input{p131p_virtual(wrapper,params,args,resultId,p195oa_atom(result,kt("OUnique","",id,0,[]),var("",id))),facts,U32.inc(n),fuel})),
        u => p195oa_fail("owned diagnostic: scalar helper held-origin/type",n,fuel))

@unsafe
def p195od_summary_call(+ctx: P195ODContext, summary: P195ODSummary, +args: List<&2,KTerm>, +facts: List<&2,KTerm>, +n: U32, +fuel: U32, +k: NO_Cont) -> NO_Analysis:
  match summary:
    case P195ODSummary{owner,+schema,inputs}:
      +flat = p195od_flat_fields(inputs,args,facts)
      +params = no_schema_params(schema)
      +marker = kt("ODOpaqueResult",no_schema_observation(schema),0,0,[var("",nc_id(n)),var("",nc_id(U32.inc(n)))])
      +env = p195oa_bind(nc_id(64),marker,p195oa_actuals(params,ks(flat)))
      nt_choose(NO_Analysis,String.eq(tg(flat),"ODFlat") && p195od_arguments(ctx,params,no_schema_roots(schema),ks(flat),0),
        u => p195oa_prepend(kt("NO_Let","",nc_id(n),0,[kt("ODSummaryCall",owner,0,0,p195od_words(ctx,ks(flat),no_schema_roots(schema),0))]),p195oa_continue(ctx,k,NO_Input{p195oa_virtual(no_schema_wrapper(schema),env),facts,U32.add(n,2),fuel})),
        u => p195oa_fail("owned diagnostic: owned summary held-origin/type",n,fuel))

@unsafe
def p195od_reference_scalar(+ctx: P195ODContext, +name: String, +args: List<&2,KTerm>, +facts: List<&2,KTerm>, +stack: List<&2,String>, +n: U32, +fuel: U32, +k: NO_Cont, found: Maybe<&2,P128BRHelper>) -> NO_Analysis:
  match found:
    case Some{helper}: p195od_scalar_call(ctx,helper,args,facts,n,fuel,k)
    case None{}:
      +d = lookup(p195oa_book(ctx),name)
      nt_choose(NO_Analysis,String.eq(dk(d),"Def") && Bool.not(nc_foreign(d) || nc_native_def(d) || nb_contains(stack,name)) && U32.is_lt(nt_count(String,stack),8),
        u => p195oa_eval(ctx,nc_source_body(p195oa_book(ctx),d,n),[],facts,Con{name,stack},n,fuel,NO_KApplyArgs{args,k}),
        u => p195oa_fail("owned diagnostic: helper effect/cycle/depth",n,fuel))

@unsafe
def p195od_reference_helper(+ctx: P195ODContext, +name: String, +args: List<&2,KTerm>, +facts: List<&2,KTerm>, +stack: List<&2,String>, +n: U32, +fuel: U32, +k: NO_Cont, found: Maybe<&2,P195ODSummary>) -> NO_Analysis:
  match found:
    case Some{summary}: p195od_summary_call(ctx,summary,args,facts,n,fuel,k)
    case None{}: p195od_reference_scalar(ctx,name,args,facts,stack,n,fuel,k,p128br_lookup(name,p195od_helpers(ctx)))

@unsafe
def p195oa_reference(+ctx: P195ODContext, +name: String, +args: List<&2,KTerm>, +facts: List<&2,KTerm>, +stack: List<&2,String>, +n: U32, +fuel: U32, +k: NO_Cont) -> NO_Analysis:
  +arity = nd_arity(p195oa_book(ctx),name)
  +d = lookup(p195oa_book(ctx),name)
  nt_choose(NO_Analysis,U32.is_lt(terms_len(args),arity),u => p195oa_continue(ctx,k,NO_Input{kt("OR",name,0,0,Con{kt("OStack","",0,0,p195oa_names(stack)),args}),facts,n,fuel}),u =>
  nt_choose(NO_Analysis,U32.is_eq(terms_len(args),arity),u =>
  nt_choose(NO_Analysis,String.eq(name,p195oa_owner(ctx)),u => p195oa_recur(ctx,args,facts,n,fuel,k),u =>
  nt_choose(NO_Analysis,nt_choose(Bool,nc_native_def(d),v => nd_scalar_known(nc_primitive_name(name)),v => False{}),u => p195oa_primitive(ctx,name,args,facts,n,fuel,k),
    u => p195od_reference_helper(ctx,name,args,facts,stack,n,fuel,k,p195od_summary_lookup(name,p195od_summaries(ctx))))),u => p195oa_fail("owned diagnostic: saturation",n,fuel)))

@unsafe
def p195od_plan(+book: List<&2,KDef>, +owner: String, +helpers: List<&2,P128BRHelper>, +summaries: List<&2,P195ODSummary>, prepared: P195ODSchema) -> NO_Plan:
  match prepared:
    case P195ODSchema{+schema,inputs}:
      nt_choose(NO_Plan,String.is_empty(no_schema_error(schema)),
        u => no_plan_result(owner,schema,p195oa_analyze_ready(P195ODContext{book,owner,schema,helpers,inputs,summaries})),
        u => no_plan_refuse(owner,no_schema_error(schema)))

@unsafe
def p195od_rows(+book: List<&2,KDef>, owners: List<&2,String>, +helpers: List<&2,P128BRHelper>, +summaries: List<&2,P195ODSummary>) -> List<&2,String>:
  match owners:
    case Nil{}: []
    case Con{+owner,rest}:
      +prepared = p195od_schema(book,owner)
      match prepared:
        case P195ODSchema{+schema,+inputs}:
          +plan = p195od_plan(book,owner,helpers,summaries,prepared)
          +error = no_plan_error(plan)
          +ok = String.is_empty(error)
          nt_append(String,["owner=" ++ owner,"schema_error=" ++ no_schema_error(schema),"proof_error=" ++ error,
            "legality=" ++ U32.show(Bool.to_u32(ok)),"flattened_arguments=" ++ U32.show(terms_len(no_schema_params(schema))),
            "retained_roots=" ++ U32.show(nt_count(U32,no_schema_roots(schema))),"layouts=" ++ U32.show(nt_count(NO_Spec,no_schema_specs(schema))),
            "owned_payload=" ++ no_schema_observation(schema),"residual=" ++ term_key(noa_body(no_plan_analysis(plan))),
            "required_escape_guard=RFC-or-trivial;raw-hit-original-fallback","lowering_authorized=0","fallback=original-unconditionally"],
            p195od_rows(book,rest,helpers,nt_choose(List<&2,P195ODSummary>,ok,u => Con{P195ODSummary{owner,schema,inputs},summaries},u => summaries)))

@unsafe
def p195od_diagnose_lowered(+request: NR_Request, +owners: List<&2,String>, lowered: P113ALowering) -> List<&2,String>:
  match request lowered:
    case NR_Request{source,+book,+names,paths,scope,bound} P113ALowered{original,+error}:
      nt_choose(List<&2,String>,String.is_empty(error),u => p195od_rows(book,owners,p128br_summaries(book,no_candidate_names(book,names,nc_bangs_names(book,names)),p128bs_original(original)),[]),u => ["original_lowering_error=" ++ error,"fallback=original-unconditionally"])

@unsafe
def p195od_diagnose(+request: NR_Request, owners: List<&2,String>) -> List<&2,String>:
  p195od_diagnose_lowered(request,owners,p113a_lower_request(request))

@unsafe
def p195od_checked(plan: P86Plan, +owners: List<&2,String>) -> List<&2,String>:
  match plan:
    case P86PlanError{error}: ["source_error=" ++ error,"fallback=original-unconditionally"]
    case P86PlanReady{+request,verdict}:
      +error = p111_runtime_admission(request)
      nt_choose(List<&2,String>,String.is_empty(error),u => p195od_diagnose(request,owners),u => ["admission_error=" ++ error,"fallback=original-unconditionally"])
