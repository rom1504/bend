# Experimental derived observer profile. No original verifier is overridden.
# A plan retains its checked request; raw worker bodies are never API inputs.
type P118BPlan is Data:
  P118BPlan{+request: NR_Request, +names: List<&2,String>, +error: String}

type P118BValues is Data:
  P118BValues{+body: List<&2,P113DStmt>, +values: List<&2,N111Value>, +next: U32, +error: String}

type P118BWorkers is Data:
  P118BWorkers{+functions: List<&2,P113DFunction>, +error: String}

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
    case Con{+name,rest}:
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
