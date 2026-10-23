# Phase128 bounded scalar-result borrowing candidate. Not production selected.
# Reuses checked NO semantics and the exact original leaf fallback. No observer
# grammar, ownership admission, dependency verifier or existing flat-product
# path is relaxed. Runtime requires the reviewed Phase118 scalar-borrow helper.
# Overrides: p118b_project_call, p118e_permitted, p118i_borrow, p118z_runtime.

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
def p118e_permitted(request: NR_Request, original: P113AProgram) -> P111Emission:
  p128bs_prepare(request,original,True{})

@unsafe
def p118i_borrow(request: NR_Request, original: P113AProgram) -> P111Emission:
  p128bs_prepare(request,original,False{})

# The readonly guard never transitions/schedules and must not disable the
# already audited whole-program live-bank transport capability.
@unsafe
def p118z_runtime(+symbol: String) -> Bool:
  Bool.not(List.is_empty(&2,U32,p111v_signature(symbol))) ||
    String.eq(symbol,"p113_rt_array_pair") || String.eq(symbol,"p118_rt_extend") ||
    String.eq(symbol,"p118_rt_finish") || String.eq(symbol,"p118_rt_borrow_fields") ||
    String.eq(symbol,"p126_rt_nat_divmod") || String.eq(symbol,"p118_rt_borrow_scalar_safe")
