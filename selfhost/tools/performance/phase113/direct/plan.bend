# Discovery consumes the same prepared checked book as the generic fallback.
# A candidate is not admitted until every non-self callee has already been
# admitted. This excludes native recursion cycles; self-tail edges use Again.
@unsafe
def p113d_candidate(+book: List<&2,KDef>, +name: String) -> P113DCandidate:
  +arity = nd_arity(book,name)
  +params = nk_typed_bindings(nd_entry_params(arity,0),nf_worker_kinds(book,name,arity))
  +owner = p113d_public(book,name)
  +body = nc_compact_definition(book,lookup(book,name),0)
  p113d_candidate_code(owner,params,p113d_lower(book,nd_reapply(body,nd_entry_args(params)),params,owner,P113DReturn{},arity))

@unsafe
def p113d_candidate_code(name: String, params: List<&2,NC_Binding>, code: P113DCode) -> P113DCandidate:
  match code:
    case P113DCode{body,fresh,error,calls}: P113DCandidate{P113DFunction{name,params,1,True{},body},error,calls}

@unsafe
def p113d_candidates(+book: List<&2,KDef>, names: List<&2,String>, +bangs: List<&2,String>) -> List<&2,P113DCandidate>:
  match names:
    case Nil{}: []
    case Con{+name,+rest}:
      +definition = lookup(book,name)
      nt_choose(List<&2,P113DCandidate>,String.eq(dk(definition),"Def") &&
        Bool.not(nc_native_def(definition) || nc_foreign(definition) || nb_contains(bangs,name)) && U32.is_le(nd_arity(book,name),32),
        u => Con{p113d_candidate(book,name),p113d_candidates(book,rest,bangs)},
        u => p113d_candidates(book,rest,bangs))

@unsafe
def p113d_ready(+index: KDef, +name: String) -> Bool:
  String.eq(dk(p111v_get(index,name)),"P113Direct")

@unsafe
def p113d_deps(calls: List<&2,String>, +index: KDef) -> Bool:
  match calls:
    case Nil{}: True{}
    case Con{head,rest}: p113d_ready(index,head) && p113d_deps(rest,index)

type P113DPass is Data:
  P113DPass{+index: KDef, +functions: List<&2,P113DFunction>, +waiting: List<&2,P113DCandidate>, +count: U32}

@unsafe
def p113d_pass(candidates: List<&2,P113DCandidate>, +index: KDef, +functions: List<&2,P113DFunction>, +waiting: List<&2,P113DCandidate>, +count: U32) -> P113DPass:
  match candidates:
    case Nil{}: P113DPass{index,functions,nt_reverse(P113DCandidate,waiting,[]),count}
    case Con{+candidate,rest}: p113d_pass_one(candidate,rest,index,functions,waiting,count)

@unsafe
def p113d_pass_one(+candidate: P113DCandidate, +rest: List<&2,P113DCandidate>, +index: KDef, +functions: List<&2,P113DFunction>, +waiting: List<&2,P113DCandidate>, +count: U32) -> P113DPass:
  match candidate:
    case P113DCandidate{+function,+error,+calls}: p113d_pass_function(candidate,function,error,calls,rest,index,functions,waiting,count)

@unsafe
def p113d_pass_function(+candidate: P113DCandidate, +function: P113DFunction, +error: String, +calls: List<&2,String>, +rest: List<&2,P113DCandidate>, +index: KDef, +functions: List<&2,P113DFunction>, +waiting: List<&2,P113DCandidate>, +count: U32) -> P113DPass:
  match function:
    case P113DFunction{+name,+params,result,public,body}:
      nt_choose(P113DPass,Bool.not(String.is_empty(error)) || p113d_ready(index,name),
        u => p113d_pass(rest,index,functions,waiting,count),u =>
        nt_choose(P113DPass,p113d_deps(calls,index),
          v => p113d_pass(rest,p111v_put(index,name,"P113Direct",nt_count(NC_Binding,params),0),Con{function,functions},waiting,U32.inc(count)),
          v => p113d_pass(rest,index,functions,Con{candidate,waiting},count)))

law p113d_passes:
  for +candidates: List<&2,P113DCandidate>
  for +index: KDef
  for +functions: List<&2,P113DFunction>
  for +fuel: U32
  List<&2,P113DFunction>

@unsafe
def p113d_pass_next(+fuel: U32, pass: P113DPass) -> List<&2,P113DFunction>:
  match pass:
    case P113DPass{index,+functions,waiting,count}:
      nt_choose(List<&2,P113DFunction>,U32.is_eq(count,0),u => nt_reverse(P113DFunction,functions,[]),
        u => p113d_passes(waiting,index,functions,U32.sub(fuel,1)))

@unsafe
def p113d_passes(candidates,index,functions,fuel):
  nt_choose(List<&2,P113DFunction>,U32.is_eq(fuel,0),u => nt_reverse(P113DFunction,functions,[]),
    u => p113d_pass_next(fuel,p113d_pass(candidates,index,functions,[],0)))

@unsafe
def p113d_plan(+book: List<&2,KDef>, +names: List<&2,String>) -> List<&2,P113DFunction>:
  p113d_passes(p113d_candidates(book,names,nc_bangs_names(book,names)),missing(),[],32)

@unsafe
def p113d_finish(original: P112SResult, functions: List<&2,P113DFunction>) -> P113DLowering:
  match original:
    case P112SResult{bundle,error}: P113DLowered{P113DProgram{bundle,functions},error}

@unsafe
def p113d_prepared(+source: List<&2,KDef>, +names: List<&2,String>, prepared: P112SPrepared) -> P113DLowering:
  match prepared:
    case P112SPrepared{+book,+nodes,+error}:
      nt_choose(P113DLowering,String.is_empty(error),
        u => p113d_finish(p112s_finish(nodes,p111_finish(source,names,p111_compile_defs(book,names,nc_bangs_names(book,names),0,[]))),p113d_plan(book,names)),
        u => P113DLowered{P113DProgram{P112StaticProgram{p111_empty(),[]},[]},error})

@unsafe
def p113d_lower_request(request: NR_Request) -> P113DLowering:
  match request:
    case NR_Request{+source,+book,+names,paths,scope,+bound}:
      +error = nc_compile_error_known(source,bound)
      nt_choose(P113DLowering,String.is_empty(error),
        u => p113d_prepared(source,names,p112s_prepare(book,names,nc_add_ctors(nc_default_ctors(),nc_constructors(source,source)))),
        u => P113DLowered{P113DProgram{P112StaticProgram{p111_empty(),[]},[]},error})
