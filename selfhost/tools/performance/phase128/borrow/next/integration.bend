# Stage1 supplies summaries only for the already checked bounded leaf readers.
# New reader callers are inserted at the original owning function's position;
# prerequisites stay ahead of their copied fallback, and final verification
# starts from an empty ready set. No all-signatures seed is used for admission.

@unsafe
def p128br_seed(+owner: String, +schema: NO_Schema, workers: P118BWorkers) -> List<&2,P128BRHelper>:
  match workers:
    case P118BWorkers{+functions,+error}:
      nt_choose(List<&2,P128BRHelper>,String.is_empty(error) && U32.is_eq(nt_count(P113DFunction,functions),3),
        u => [P128BRHelper{owner,no_schema_params(schema),no_schema_roots(schema),no_schema_observation(schema),p118b_read_name(owner)}],u => [])

@unsafe
def p128br_summaries(+book: List<&2,KDef>, names: List<&2,String>, +original: List<&2,P113DFunction>) -> List<&2,P128BRHelper>:
  match names:
    case Nil{}: []
    case Con{+name,rest}:
      +plan = no_observer_plan(book,name,True{})
      nt_append(P128BRHelper,nt_choose(List<&2,P128BRHelper>,p128bs_eligible(book,plan),
        u => p128br_seed(name,no_plan_schema(plan),p128bs_find(book,name,plan,original)),u => []),
        p128br_summaries(book,rest,original))

@unsafe
def p128br_plan(+book: List<&2,KDef>, +owner: String, +helpers: List<&2,P128BRHelper>) -> NO_Plan:
  +schema = no_schema(book,lookup(book,owner),0)
  nt_choose(NO_Plan,String.is_empty(no_schema_error(schema)),
    u => no_plan_result(owner,schema,noa_analyze_ready(NO_Context{book,owner,schema,helpers})),
    u => NO_Plan{owner,schema,noa_fail(no_schema_error(schema),no_schema_fresh(schema),4096),no_schema_error(schema)})

# no_emit cannot represent NO_ReadCall. Retain its exact residual layout,
# binder, arity and atom checks through an explicit structural call projection,
# then check actual QBE lowering and the full independent direct verifier.
# Old no_observer_plan/p128bs admission remains unchanged for ordinary readers.
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
def p128br_apply(functions: List<&2,P113DFunction>, +patches: List<&2,P128BRPatch>) -> List<&2,P113DFunction>:
  match functions:
    case Nil{}: []
    case Con{+head,rest}:
      match head:
        case P113DFunction{name,params,result,public,body}:
          nt_append(P113DFunction,p128br_replace(head,p128br_replacement(name,patches)),p128br_apply(rest,patches))

@unsafe
def p128br_finish(+request: NR_Request, +original: P113AProgram, +workers: P118BWorkers, patches: P128BRPatches) -> P111Emission:
  match patches:
    case P128BRPatches{+edits,+error}:
      nt_choose(P111Emission,Bool.not(String.is_empty(error)),u => P111Emission{[],"borrowed helper plan: " ++ error},
        u => nt_choose(P111Emission,List.is_empty(&2,P128BRPatch,edits),
          v => p126bp_integrated(request,original,workers),
          v => p128br_compose(request,original,workers,edits)))

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
      +candidates = no_candidate_names(book,names,nc_bangs_names(book,names))
      +functions = p128bs_original(original)
      +helpers = p128br_summaries(book,candidates,functions)
      +prepared = nt_choose(P113AProgram,cold,u => p118e_cold(original,book,source,nh_definitions(book,names,[])),u => original)
      p128br_finish(request,prepared,p128bs_workers(book,candidates,functions,[]),
        nt_choose(P128BRPatches,List.is_empty(&2,P128BRHelper,helpers),u => P128BRPatches{[],""},
          u => p128br_patches(book,candidates,functions,helpers)))

@unsafe
def p118e_permitted(request: NR_Request, original: P113AProgram) -> P111Emission:
  p128br_prepare(request,original,True{})

@unsafe
def p118i_borrow(request: NR_Request, original: P113AProgram) -> P111Emission:
  p128br_prepare(request,original,False{})
