# V2: normalize the U64 runtime guard to the verifier's U32 condition.
# Optional scalar-only observer experiment. Existing root-returning eligibility
# is unchanged. Restrict fallback bodies to self-contained direct workers so
# adding a private copy cannot invent dependencies on unavailable ready workers.
@unsafe
def p118s_owned(owner: String) -> String:
  "$p118borrow.owned." ++ owner

@unsafe
def p118s_leaf(body: List<&2,P113DStmt>) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{P113DCall{destinations,target,args},rest}: False{}
    case Con{P113DIf{condition,yes,no},rest}: p118s_leaf(yes) && p118s_leaf(no) && p118s_leaf(rest)
    case Con{head,rest}: p118s_leaf(rest)

@unsafe
def p118s_eligible(+book: List<&2,KDef>, +plan: NO_Plan) -> Bool:
  +schema = no_plan_schema(plan)
  +wrapper = no_schema_wrapper(schema)
  +params = no_plan_params(no_schema_params(schema))
  +roots = no_schema_roots(schema)
  String.is_empty(no_plan_error(plan)) && String.eq(tg(wrapper),"Var") &&
    U32.is_eq(ix(wrapper),no_schema_result(schema)) &&
    U32.is_ge(nt_count(U32,roots),1) && U32.is_le(nt_count(U32,roots),2) &&
    String.eq(dk(lookup(book,p118b_read_name(no_plan_owner(plan)))),"Absent") &&
    String.eq(dk(lookup(book,p118s_owned(no_plan_owner(plan)))),"Absent") &&
    String.is_empty(nc_error(no_emit(noa_body(no_plan_analysis(plan)),params,params,
      no_schema_specs_layouts(no_schema_specs(schema)),0)))

@unsafe
def p118s_roots(params: List<&2,NC_Binding>, +roots: List<&2,U32>, +i: U32) -> List<&2,N111Arg>:
  match params:
    case Nil{}: []
    case Con{NC_Binding{id,word,kind},+rest}:
      nt_choose(List<&2,N111Arg>,no_root_index(roots,i),
        u => Con{p111_word(N111Local{word}),p118s_roots(rest,roots,U32.inc(i))},
        u => p118s_roots(rest,roots,U32.inc(i)))

@unsafe
def p118s_guard_args(roots: List<&2,N111Arg>) -> List<&2,N111Arg>:
  match roots:
    case Con{a,Nil{}}: [p111_state(),a,p111_word(N111Const{0,0}),p111_u32(1)]
    case Con{a,Con{b,Nil{}}}: [p111_state(),a,b,p111_u32(2)]
    case _: []

@unsafe
def p118s_drops(roots: List<&2,N111Arg>, +i: U32) -> List<&2,P113DStmt>:
  match roots:
    case Nil{}: []
    case Con{root,rest}:
      Con{P113DScalar{N111Call{"p118s_drop_" ++ U32.show(i),N111U64{},"p111_rt_sink",[p111_state(),root]}},p118s_drops(rest,U32.inc(i))}

@unsafe
def p118s_functions(+book: List<&2,KDef>, +owner: String, +plan: NO_Plan, fallback: P113DFunction) -> P118BWorkers:
  match fallback:
    case P113DFunction{name,old_params,result,public,body}:
      +schema = no_plan_schema(plan)
      +params = no_plan_params(no_schema_params(schema))
      +roots = p118s_roots(params,no_schema_roots(schema),0)
      +reader = p118b_lower(noa_body(no_plan_analysis(plan)),params,params,no_schema_specs_layouts(no_schema_specs(schema)),0)
      +yes : List<&2,P113DStmt> = Con{P113DCall{["p118s_observation"],p118b_read_name(owner),p111_env_words(params)},
        nt_append(P113DStmt,p118s_drops(roots,0),[P113DResult{[N111Local{"p118s_observation"}]}])}
      +no : List<&2,P113DStmt> = [P113DCall{["p118s_fallback"],p118s_owned(owner),p111_env_words(params)},P113DResult{[N111Local{"p118s_fallback"}]}]
      +adapter : List<&2,P113DStmt> = [P113DScalar{N111Call{"p118s_borrow",N111U64{},"p118_rt_borrow_scalar_safe",p118s_guard_args(roots)}},P113DScalar{N111Bin{"p118s_condition",N111U64{},"ne",N111Local{"p118s_borrow"},N111Const{0,0}}},P113DIf{N111Local{"p118s_condition"},yes,no}]
      P118BWorkers{[
        P113DFunction{p118s_owned(owner),old_params,result,False{},body},
        P113DFunction{p118b_read_name(owner),params,1,False{},p113d_body(reader)},
        P113DFunction{p113d_public(book,owner),params,1,True{},adapter}],p113d_error(reader)}

@unsafe
def p118s_find(+book: List<&2,KDef>, +owner: String, +plan: NO_Plan, functions: List<&2,P113DFunction>) -> P118BWorkers:
  match functions:
    case Nil{}: P118BWorkers{[],""}
    case Con{+head,rest}:
      match head:
        case P113DFunction{+name,+params,+result,+public,+body}:
          nt_choose(P118BWorkers,String.eq(name,p113d_public(book,owner)),
            u => nt_choose(P118BWorkers,public && U32.is_eq(result,1) && p118s_leaf(body) &&
              U32.is_eq(nt_count(NC_Binding,params),nt_count(KTerm,no_schema_params(no_plan_schema(plan)))),
              v => p118s_functions(book,owner,plan,head),v => P118BWorkers{[],""}),
            u => p118s_find(book,owner,plan,rest))

@unsafe
def p118s_workers(+book: List<&2,KDef>, names: List<&2,String>, +original: List<&2,P113DFunction>, +reversed: List<&2,P113DFunction>) -> P118BWorkers:
  match names:
    case Nil{}: P118BWorkers{nt_reverse(P113DFunction,reversed,[]),""}
    case Con{+name,+rest}:
      +plan = no_observer_plan(book,name,True{})
      +here = nt_choose(P118BWorkers,p118b_eligible(book,plan),
        u => p118b_functions(book,name,plan),
        u => nt_choose(P118BWorkers,p118s_eligible(book,plan),
          v => p118s_find(book,name,plan,original),v => P118BWorkers{[],""}))
      p118s_workers_next(book,rest,original,reversed,here)

@unsafe
def p118s_workers_next(book: List<&2,KDef>, names: List<&2,String>, original: List<&2,P113DFunction>, reversed: List<&2,P113DFunction>, here: P118BWorkers) -> P118BWorkers:
  match here:
    case P118BWorkers{functions,+error}:
      nt_choose(P118BWorkers,String.is_empty(error),
        u => p118s_workers(book,names,original,nt_reverse(P113DFunction,functions,reversed)),u => P118BWorkers{[],error})

# Strict structural projection of the new readonly Boolean guard. OR reads both
# Term operands and has the same result width; this is not semantic equivalence.
# State identity and exact arity/count are checked before projection.
@unsafe
def p118s_project_call(+stmt: N111Stmt) -> P113DCode:
  match stmt:
    case N111Call{+name,+typ,+symbol,+args}:
      nt_choose(P113DCode,String.eq(symbol,"p118_rt_borrow_scalar_safe"),
        u => nt_choose(P113DCode,p118b_arg_types(args,[3,2,2,1]) && p111v_state_argument(args) &&
          U32.is_eq(p111v_type(typ),2) && U32.is_ge(p111v_literal(p111v_arg(args,3)),1) && U32.is_le(p111v_literal(p111v_arg(args,3)),2),
          v => P113DCode{[P113DScalar{N111Bin{name,N111U64{},"or",p111v_arg(args,1),p111v_arg(args,2)}}],0,"",[]},
          v => p113d_fail("scalar borrowed guard contract",0)),
        u => P113DCode{[P113DScalar{stmt}],0,"",[]})
    case _: P113DCode{[P113DScalar{stmt}],0,"",[]}

@unsafe
def p118s_project(body: List<&2,P113DStmt>) -> P113DCode:
  match body:
    case Nil{}: P113DCode{[],0,"",[]}
    case Con{P113DScalar{stmt},rest}: p113d_join(p118s_project_call(stmt),p118s_project(rest))
    case Con{P113DIf{condition,yes,no},rest}: p113d_join(p113d_branch(condition,p118s_project(yes),p118s_project(no)),p118s_project(rest))
    case Con{head,rest}: p113d_join(P113DCode{[head],0,"",[]},p118s_project(rest))

@unsafe
def p118s_project_function(function: P113DFunction) -> P118BWorkers:
  match function:
    case P113DFunction{name,params,result,public,body}:
      +projected = p118s_project(body)
      P118BWorkers{[P113DFunction{name,params,result,public,p113d_body(projected)}],p113d_error(projected)}

@unsafe
def p118s_project_functions(functions: List<&2,P113DFunction>) -> P118BWorkers:
  match functions:
    case Nil{}: P118BWorkers{[],""}
    case Con{head,rest}: p118b_workers_join(p118s_project_function(head),p118s_project_functions(rest))

@unsafe
def p118s_verify(program: P111Program, projected: P118BWorkers) -> String:
  match projected:
    case P118BWorkers{functions,+error}:
      nt_choose(String,String.is_empty(error),u => p118b_verify_functions(functions,program),u => error)

@unsafe
def p118s_compose(original: P113AProgram, workers: P118BWorkers) -> P111Emission:
  match original workers:
    case P113AProgram{P113DProgram{P112StaticProgram{+program,nodes},functions},certificate} P118BWorkers{+added,+error}:
      +checked = p111_first(error,p118s_verify(program,p118s_project_functions(added)))
      +merged = nt_append(P113DFunction,added,p118b_without(functions,p113e_signatures(added,missing())))
      nt_choose(P111Emission,String.is_empty(checked),
        u => P111Emission{p113a_admitted_chunks(P113AProgram{P113DProgram{P112StaticProgram{program,nodes},merged},certificate}),""},
        u => P111Emission{[],"scalar borrowed profile: " ++ checked})

@unsafe
def p118s_original(program: P113AProgram) -> List<&2,P113DFunction>:
  match program:
    case P113AProgram{P113DProgram{original,functions},certificate}: functions

@unsafe
def p118s_prepare(request: NR_Request, +original: P113AProgram, +cold: Bool) -> P111Emission:
  match request:
    case NR_Request{+source,+book,+names,paths,scope,bound}:
      +prepared = nt_choose(P113AProgram,cold,
        u => p118e_cold(original,book,source,nh_definitions(book,names,[])),u => original)
      p118s_compose(prepared,p118s_workers(book,no_candidate_names(book,names,nc_bangs_names(book,names)),p118s_original(original),[]))

# Called only after the integrated original request verification. Existing
# scalar and independent observer-permission branches remain the sole callers.
@unsafe
def p118e_permitted(request: NR_Request, original: P113AProgram) -> P111Emission:
  p118s_prepare(request,original,True{})

@unsafe
def p118i_borrow(request: NR_Request, original: P113AProgram) -> P111Emission:
  p118s_prepare(request,original,False{})
