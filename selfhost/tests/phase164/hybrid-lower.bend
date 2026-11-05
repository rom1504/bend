# Candidate-first lowering. Real factories and every unadmitted owner's full
# generic lowering survive. A skipped worker never creates its continuations.
@unsafe
def p164l_factory(+book: List<&2,KDef>, +body: KTerm, +name: String, +n: U32, +arity: U32) -> P111Code:
  +d = lookup(book,name)
  +typed = jd_live_arity(book,dt(d),jd_arity(book,d))
  +params = nd_entry_params(arity,n)
  nt_choose(P111Code,U32.is_gt(typed,0) && U32.is_eq(typed,arity),
    u => p111_lower(book,nd_eta_body(params,kt("NCall",nd_name(nc_ref_name(book,name)),0,0,nd_entry_args(params))),[],U32.add(n,arity)),
    u => p111_lower(book,body,[],n))

@unsafe
def p164l_adapter(+book: List<&2,KDef>, +name: String, +n: U32, +arity: U32) -> P111Book:
  nt_choose(P111Book,U32.is_eq(arity,0),
    u => P111Book{[p164a_segment(p113d_public(book,name),0)],n,""},
    u => p164l_factory_done(book,name,arity,
      p164l_factory(book,nc_compact_definition(book,lookup(book,name),n),name,U32.add(n,1024),arity)))

@unsafe
def p164l_factory_done(+book: List<&2,KDef>, +name: String, arity: U32, code: P111Code) -> P111Book:
  match code:
    case P111Code{body,segments,fresh,error}:
      P111Book{Con{p111_segment(nc_ref_name(book,name),[],0,0,body),
        nt_append(N111Segment,segments,[p164a_segment(p113d_public(book,name),arity)])},fresh,error}

@unsafe
def p164l_old(+book: List<&2,KDef>, +name: String, +n: U32, +bang: Bool) -> P111Book:
  p164l_old_done(book,name,bang,
    p111_entry(book,nc_compact_definition(book,lookup(book,name),n),name,U32.add(n,1024),bang))

@unsafe
def p164l_old_done(+book: List<&2,KDef>, +name: String, bang: Bool, code: P111Code) -> P111Book:
  match code:
    case P111Code{body,segments,fresh,error}:
      P111Book{p111_mark_segments(Con{p111_segment(nc_ref_name(book,name),[],0,0,body),segments},bang),fresh,error}

@unsafe
def p164l_defs(+book: List<&2,KDef>, names: List<&2,String>, +bangs: List<&2,String>, +ready: KDef,
    +n: U32, +acc: List<&2,N111Segment>, +adapters: KDef, +omitted: U32) -> P164HBook:
  match names:
    case Nil{}: P164HBook{P111Book{nt_reverse(N111Segment,acc,[]),n,""},adapters,omitted}
    case Con{+name,+rest}:
      nt_choose(P164HBook,String.eq(dk(lookup(book,name)),"Absent"),
        u => P164HBook{P111Book{[],n,"native definition not found: " ++ name_key(name)},adapters,omitted},
        u => p164l_selected(book,name,rest,bangs,ready,n,acc,adapters,omitted,
          p164a_allowed(book,name,bangs,ready)))

@unsafe
def p164l_selected(+book: List<&2,KDef>, +name: String, rest: List<&2,String>, +bangs: List<&2,String>, ready: KDef,
    +n: U32, acc: List<&2,N111Segment>, +adapters: KDef, +omitted: U32, +selected: Bool) -> P164HBook:
  p164l_next(book,rest,bangs,ready,acc,
    nt_choose(KDef,selected,u => p164a_put(adapters,name,p113d_public(book,name),nd_arity(book,name)),u => adapters),
    U32.add(omitted,Bool.to_u32(selected)),nt_choose(P111Book,selected,
      u => p164l_adapter(book,name,n,nd_arity(book,name)),u => p164l_old(book,name,n,nb_contains(bangs,name))))

@unsafe
def p164l_next(+book: List<&2,KDef>, +rest: List<&2,String>, +bangs: List<&2,String>, +ready: KDef,
    +acc: List<&2,N111Segment>, +adapters: KDef, +omitted: U32, compiled: P111Book) -> P164HBook:
  match compiled:
    case P111Book{segments,+fresh,+error}:
      nt_choose(P164HBook,String.is_empty(error),
        u => p164l_defs(book,rest,bangs,ready,fresh,nt_reverse(N111Segment,segments,acc),adapters,omitted),
        u => P164HBook{P111Book{[],fresh,error},adapters,omitted})

@unsafe
def p164l_finish(+source: List<&2,KDef>, +names: List<&2,String>, constructors: List<&2,N_Constructor>, nodes: List<&2,P112SNode>,
    functions: List<&2,P113DFunction>, raw: List<&2,P113DCandidate>, result: P164HBook) -> P164HLowering:
  match result:
    case P164HBook{compiled,adapters,omitted}:
      P164HLowering{p113d_finish(p112s_finish(nodes,p140or_finish(source,names,constructors,compiled)),functions),raw,adapters,omitted}

@unsafe
def p164l_functions(+source: List<&2,KDef>, +book: List<&2,KDef>, +names: List<&2,String>, +constructors: List<&2,N_Constructor>,
    nodes: List<&2,P112SNode>, +bangs: List<&2,String>, +raw: List<&2,P113DCandidate>, +functions: List<&2,P113DFunction>) -> P164HLowering:
  p164l_finish(source,names,constructors,nodes,functions,raw,
    p164l_defs(book,names,bangs,p164a_ready(functions,missing()),0,[],missing(),0))

@unsafe
def p164l_candidates(source: List<&2,KDef>, book: List<&2,KDef>, names: List<&2,String>, constructors: List<&2,N_Constructor>,
    nodes: List<&2,P112SNode>, bangs: List<&2,String>, +raw: List<&2,P113DCandidate>) -> P164HLowering:
  p164l_functions(source,book,names,constructors,nodes,bangs,raw,
    p113d_passes(p126sc_candidates(raw),missing(),[],32))

@unsafe
def p164l_prepared(+source: List<&2,KDef>, +names: List<&2,String>, constructors: List<&2,N_Constructor>, prepared: P112SPrepared) -> P164HLowering:
  match prepared:
    case P112SPrepared{+book,nodes,+error}:
      +bangs = nc_bangs_names(book,names)
      nt_choose(P164HLowering,String.is_empty(error),
        u => p164l_candidates(source,book,names,constructors,nodes,bangs,
          p113pl_candidates(book,names,bangs,book_cached(nq_signatures(book,names),0))),
        u => P164HLowering{P113DLowered{P113DProgram{P112StaticProgram{p111_empty(),[]},[]},error},[],missing(),0})

@unsafe
def p164l_catalogued(source: List<&2,KDef>, +book: List<&2,KDef>, +names: List<&2,String>, +constructors: List<&2,N_Constructor>) -> P164HLowering:
  p164l_prepared(source,names,constructors,p112s_prepare(book,names,constructors))

@unsafe
def p164l_request(request: NR_Request) -> P164HLowering:
  match request:
    case NR_Request{+source,+book,+names,paths,scope,bound}:
      +error = nc_compile_error_known(source,bound)
      nt_choose(P164HLowering,String.is_empty(error),
        u => p164l_catalogued(source,book,names,nc_add_ctors(nc_default_ctors(),
          p144o_constructors(source,source,p144o_payload(nc_ctor_context(book))))),
        u => P164HLowering{P113DLowered{P113DProgram{P112StaticProgram{p111_empty(),[]},[]},error},[],missing(),0})
