# Derive one additional flat result ABI from the same certified observer plan.
# No runtime helpers, source-name selection, or generic verifier changes.

@unsafe
def p126bp_fields(terms: List<&2,KTerm>) -> Bool:
  match terms:
    case Nil{}: True{}
    case Con{+head,rest}:
      (String.eq(tg(head),"Var") || String.eq(tg(head),"NWord")) && p126bp_fields(rest)

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
def p118b_functions(+book: List<&2,KDef>, +owner: String, +plan: NO_Plan) -> P118BWorkers:
  p126bp_extend(book,owner,plan,p126bp_original_functions(book,owner,plan))

# New flat observer symbols are a necessary precondition for the extra catalogue
# preparation. All other requests retain the original compose path and work.
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
        u => P111Emission{p113a_admitted_chunks(assembled),""},
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
def p118b_emit_verified(+original: P113AProgram, +plan: P118BPlan, +error: String) -> P111Emission:
  nt_choose(P111Emission,String.is_empty(error),u => p126bp_plan(original,plan),
    u => P111Emission{[],"borrowed original: " ++ error})
