# Diagnostic only. Reproduce raw-mode preparation/candidate admission once and
# retain exact original errors/calls. No body optimization, emission or fallback
# policy is changed. Source rows map real names to worker identities explicitly.
# admitted means the ordered candidate pass selected the worker, NOT that the
# independent final-program verifier ran. public is the pre-private raw flag.
type P167WhyRow is Data:
  P167WhyRow{+kind: String, +source: String, +source_kind: String, +owner: String,
    +arity: U32, +result: U32, +public: Bool, +error: String,
    +calls: List<&2,String>, +missing: List<&2,String>, +admitted: Bool}

def p167why_error(message: String) -> List<&2,P167WhyRow>:
  [P167WhyRow{"error","","","",0,0,False{},message,[],[],False{}}]

@unsafe
def p167why_missing(calls: List<&2,String>, +ready: KDef) -> List<&2,String>:
  match calls:
    case Nil{}: []
    case Con{+name,+rest}:
      nt_choose(List<&2,String>,String.eq(dk(p111v_get(ready,name)),"P113Direct"),
        u => p167why_missing(rest,ready),u => Con{name,p167why_missing(rest,ready)})

@unsafe
def p167why_sources(+book: List<&2,KDef>, names: List<&2,String>, +ready: KDef) -> List<&2,P167WhyRow>:
  match names:
    case Nil{}: []
    case Con{+name,rest}:
      +owner = p113d_public(book,name)
      +signature = p111v_get(ready,owner)
      Con{P167WhyRow{"source",name,dk(lookup(book,name)),owner,nd_arity(book,name),dx(signature),
        Bool.not(U32.is_eq(ix(dv(signature)),0)),"",[],[],String.eq(dk(signature),"P113Direct")},
        p167why_sources(book,rest,ready)}

@unsafe
def p167why_raw(raw: List<&2,P113DCandidate>, +ready: KDef) -> List<&2,P167WhyRow>:
  match raw:
    case Nil{}: []
    case Con{P113DCandidate{P113DFunction{+name,params,result,public,body},error,+calls},rest}:
      Con{P167WhyRow{"candidate","","",name,nt_count(NC_Binding,params),result,public,error,
        calls,p167why_missing(calls,ready),String.eq(dk(p111v_get(ready,name)),"P113Direct")},
        p167why_raw(rest,ready)}

@unsafe
def p167why_final(functions: List<&2,P113DFunction>) -> List<&2,P167WhyRow>:
  match functions:
    case Nil{}: []
    case Con{P113DFunction{name,params,result,public,body},rest}:
      Con{P167WhyRow{"admitted","","",name,nt_count(NC_Binding,params),result,public,"",[],[],True{}},
        p167why_final(rest)}

@unsafe
def p167why_rows(+book: List<&2,KDef>, +names: List<&2,String>, +raw: List<&2,P113DCandidate>,
    +functions: List<&2,P113DFunction>) -> List<&2,P167WhyRow>:
  +ready = p113e_signatures(functions,missing())
  nt_append(P167WhyRow,p167why_sources(book,names,ready),
    nt_append(P167WhyRow,p167why_raw(raw,ready),p167why_final(functions)))

@unsafe
def p167why_candidates(+book: List<&2,KDef>, +names: List<&2,String>, +raw: List<&2,P113DCandidate>) -> List<&2,P167WhyRow>:
  p167why_rows(book,names,raw,p113d_passes(p126sc_candidates(raw),missing(),[],32))

@unsafe
def p167why_prepared(+names: List<&2,String>, prepared: P112SPrepared) -> List<&2,P167WhyRow>:
  match prepared:
    case P112SPrepared{+book,nodes,+error}:
      +bangs = nc_bangs_names(book,names)
      nt_choose(List<&2,P167WhyRow>,String.is_empty(error),
        u => p167why_candidates(book,names,
          p113pl_candidates(book,names,bangs,book_cached(nq_signatures(book,names),0))),
        u => p167why_error("candidate diagnostic static preparation: " ++ error))

@unsafe
def p167why_request(request: NR_Request) -> List<&2,P167WhyRow>:
  match request:
    case NR_Request{+source,+book,+names,paths,scope,bound}:
      +error = nc_compile_error_known(source,bound)
      nt_choose(List<&2,P167WhyRow>,String.is_empty(error),
        u => p167why_prepared(names,p112s_prepare(book,names,nc_add_ctors(nc_default_ctors(),
          p144o_constructors(source,source,p144o_payload(nc_ctor_context(book)))))),
        u => p167why_error("candidate diagnostic request: " ++ error))

@unsafe
def p167why_admitted(+request: NR_Request, +error: String) -> List<&2,P167WhyRow>:
  nt_choose(List<&2,P167WhyRow>,String.is_empty(error),u => p167why_request(request),
    u => p167why_error("candidate diagnostic runtime: " ++ error))

@unsafe
def p167why_plan(plan: P86Plan) -> List<&2,P167WhyRow>:
  match plan:
    case P86PlanError{error}: p167why_error(error)
    case P86PlanReady{+request,verdict}: p167why_admitted(request,p111_runtime_admission(request))
