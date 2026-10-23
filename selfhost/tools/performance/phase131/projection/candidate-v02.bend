# Compose a verified product observer with an immediate scalar consumer.
# The existing reader body/loop, entry guards, owning fallback, residual checks
# and independent final verifier are unchanged. Only its result wrapper becomes
# an OC virtual product during NO evaluation; no root is materialized or escaped.
type P128BRHelper is Data:
  P128BRHelper{+owner: String, +params: List<&2,KTerm>, +roots: List<&2,U32>, +result: String, +reader: String, +wrapper: KTerm, +resultId: U32}

@unsafe
def p128br_lookup(+name: String, helpers: List<&2,P128BRHelper>) -> Maybe<&2,P128BRHelper>:
  match helpers:
    case Nil{}: None{}
    case Con{+head,rest}:
      match head:
        case P128BRHelper{owner,params,roots,result,reader,wrapper,resultId}:
          nt_choose(Maybe<&2,P128BRHelper>,String.eq(name,owner),u => Some{head},u => p128br_lookup(name,rest))

@unsafe
def p131p_parameter(+id: U32, params: List<&2,KTerm>) -> Bool:
  match params:
    case Nil{}: False{}
    case Con{p,rest}: U32.is_eq(ix(p),id) || p131p_parameter(id,rest)

@unsafe
def p131p_wrapper_fields(fields: List<&2,KTerm>, +params: List<&2,KTerm>, +result: U32, +depth: U32) -> Bool:
  match fields:
    case Nil{}: True{}
    case Con{head,rest}: p131p_wrapper_ok(head,params,result,depth) && p131p_wrapper_fields(rest,params,result,depth)

@unsafe
def p131p_wrapper_ok(+t: KTerm, +params: List<&2,KTerm>, +result: U32, +depth: U32) -> Bool:
  nt_choose(Bool,String.eq(tg(t),"Var"),u => U32.is_eq(ix(t),result) || p131p_parameter(ix(t),params),u =>
    String.eq(tg(t),"Ctr") && U32.is_lt(depth,2) && p131p_wrapper_fields(ks(t),params,result,U32.inc(depth)))

@unsafe
def p131p_argument(+id: U32, params: List<&2,KTerm>, args: List<&2,KTerm>) -> KTerm:
  match params args:
    case Con{p,rest} Con{arg,more}:
      nt_choose(KTerm,U32.is_eq(ix(p),id),u => arg,u => p131p_argument(id,rest,more))
    case _ _: atom("Absent")

@unsafe
def p131p_virtual_fields(fields: List<&2,KTerm>, +params: List<&2,KTerm>, +args: List<&2,KTerm>, +result: U32, +scalar: KTerm) -> List<&2,KTerm>:
  match fields:
    case Nil{}: []
    case Con{head,rest}: Con{p131p_virtual(head,params,args,result,scalar),p131p_virtual_fields(rest,params,args,result,scalar)}

@unsafe
def p131p_virtual(+t: KTerm, +params: List<&2,KTerm>, +args: List<&2,KTerm>, +result: U32, +scalar: KTerm) -> KTerm:
  nt_choose(KTerm,String.eq(tg(t),"Var"),u =>
    nt_choose(KTerm,U32.is_eq(ix(t),result),v => scalar,v => p131p_argument(ix(t),params,args)),u =>
    nt_choose(KTerm,String.eq(tg(t),"Ctr"),v => kt("OC",nm(t),0,0,p131p_virtual_fields(ks(t),params,args,result,scalar)),v => atom("Absent")))

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
def p131p_reader(+reader: String, +arity: U32, functions: List<&2,P113DFunction>) -> Bool:
  match functions:
    case Nil{}: False{}
    case Con{P113DFunction{name,params,result,public,body},rest}:
      nt_choose(Bool,String.eq(name,reader),u => Bool.not(public) && U32.is_eq(result,1) &&
        U32.is_eq(nt_count(NC_Binding,params),arity),u => p131p_reader(reader,arity,rest))

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
def p128br_helper_names(helpers: List<&2,P128BRHelper>) -> List<&2,String>:
  match helpers:
    case Nil{}: []
    case Con{P128BRHelper{owner,params,roots,result,reader,wrapper,resultId},rest}:
      Con{"helper=" ++ owner ++ ":" ++ result ++ ":" ++ tg(wrapper),p128br_helper_names(rest)}

# Current integrated path: these are the actual workers accumulated for emission,
# not an independently guessed signature set. Keep their old order and retry
# conditions. Product wrappers supply summaries alongside scalar-only readers.
@unsafe
def p128br_scan_ready(+book: List<&2,KDef>, +names: List<&2,String>, +original: List<&2,P113DFunction>, +functions: List<&2,P113DFunction>, +helpers: List<&2,P128BRHelper>, +retry: List<&2,NO_Plan>, +plan: NO_Plan, +scalar: Bool, +workers: P118BWorkers) -> P128BROpen:
  match workers:
    case P118BWorkers{+added,+error}:
      nt_choose(P128BROpen,String.is_empty(error),
        u => p128br_scan(book,names,original,nt_reverse(P113DFunction,added,functions),
          nt_reverse(P128BRHelper,p128br_seed(no_plan_owner(plan),no_plan_schema(plan),workers),helpers),
          nt_choose(List<&2,NO_Plan>,scalar && List.is_empty(&2,P113DFunction,added),v => Con{plan,retry},v => retry)),
        u => P128BROpen{[],[],[],error})
