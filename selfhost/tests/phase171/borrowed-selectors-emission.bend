# Sole treatment entry is p171d_plan(plan,owner). The owner selects which actual
# checked source function to query; it is not a code/certificate input.
# Retain the complete original under a fresh private fallback name and insert
# readers immediately before the replacement wrapper in dependency order.

@unsafe
def p171de_private(function: P113DFunction) -> P113DFunction:
  match function:
    case P113DFunction{name,params,result,public,body}: P113DFunction{name,params,result,False{},body}

@unsafe
def p171de_rename(name: String, function: P113DFunction) -> P113DFunction:
  match function:
    case P113DFunction{old,params,result,public,body}: P113DFunction{name,params,result,False{},body}

@unsafe
def p171de_readers(functions: List<&2,P113DFunction>, +entry: String) -> List<&2,P113DFunction>:
  match functions:
    case Nil{}: []
    case Con{+head,+rest}:
      match head:
        case P113DFunction{name,params,result,public,body}:
          nt_choose(List<&2,P113DFunction>,String.eq(name,entry),
            u => p171de_readers(rest,entry),u => Con{p171de_private(head),p171de_readers(rest,entry)})

@unsafe
def p171de_bundle(+original: P113DFunction, +reader: String, +functions: List<&2,P113DFunction>, +roots: List<&2,U32>) -> List<&2,P113DFunction>:
  match original:
    case P113DFunction{+name,+params,result,public,body}:
      +owned = "$p171desc.owned." ++ name
      Con{p171de_rename(owned,original),nt_append(P113DFunction,
        p171de_readers(functions,"$p171desc.entry." ++ name),
        [p171de_rename(name,p171d_wrapper(owned,params,reader,roots))])}

@unsafe
def p171de_join(head: P113DFunction, workers: P118BWorkers) -> P118BWorkers:
  match workers:
    case P118BWorkers{tail,error}: P118BWorkers{Con{head,tail},error}

@unsafe
def p171de_splice(+target: String, +original: P113DFunction, +replacement: List<&2,P113DFunction>, functions: List<&2,P113DFunction>) -> P118BWorkers:
  match functions:
    case Nil{}: P118BWorkers{[],"descendant: actual private owner disappeared"}
    case Con{+head,+rest}:
      match head:
        case P113DFunction{name,params,result,public,body}:
          nt_choose(P118BWorkers,String.eq(name,target),
            u => nt_choose(P118BWorkers,p134v_function(p171de_private(head),p171de_private(original)),
              v => P118BWorkers{nt_append(P113DFunction,replacement,rest),""},
              v => P118BWorkers{[],"descendant: owning fallback body changed"}),
            u => p171de_join(head,p171de_splice(target,original,replacement,rest)))

@unsafe
def p171de_finish(+request: NR_Request, +static: P112StaticProgram, +adapters: KDef, +stats: List<&2,U32>, workers: P118BWorkers) -> P169Prepared:
  match workers:
    case P118BWorkers{functions,+error}:
      nt_choose(P169Prepared,String.is_empty(error),
        u => p169s_lowered(request,P167Lowered{P113DProgram{static,functions},adapters,"",stats}),
        u => p169s_fail(error))

@unsafe
def p171de_proposed(+request: NR_Request, lowered: P167Lowered, proposal: P171DProposal, shape: P171DShape) -> P169Prepared:
  match lowered proposal shape:
    case P167Lowered{P113DProgram{static,+old},adapters,error,stats} P171DProposal{owner,P113DFunction{+name,params,result,public,body},reader,functions,accepted,declined,+reason} P171DShape{roots,count,valid}:
      +original : P113DFunction = P113DFunction{name,params,result,public,body}
      nt_choose(P169Prepared,String.is_empty(reason) && valid,
        u => p171de_finish(request,static,adapters,stats,p171de_splice(name,original,p171de_bundle(original,reader,functions,roots),old)),
        u => p169s_fail(nt_choose(String,String.is_empty(reason),v => "descendant: source shape changed",v => reason)))

@unsafe
def p171de_lowered(+request: NR_Request, +owner: String, +lowered: P167Lowered) -> P169Prepared:
  match request:
    case NR_Request{source,+book,names,paths,scope,bound}:
      p171de_proposed(request,lowered,p171d_lowered(request,owner,lowered),p171d_shape(book,dt(lookup(book,owner)),0,[],32))

@unsafe
def p171d_prepare(+request: NR_Request, owner: String) -> P169Prepared:
  p171de_lowered(request,owner,p168_request_mode(1,request))

@unsafe
def p171d_plan(plan: P86Plan, +owner: String) -> P169Prepared:
  match plan:
    case P86PlanError{error}: p169s_fail(error)
    case P86PlanReady{+request,meta}:
      +error = p111_runtime_admission(request)
      nt_choose(P169Prepared,String.is_empty(error),u => p171d_prepare(request,owner),u => p169s_fail("compile: " ++ error))
