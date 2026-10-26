# These are new experimental entries. Original source/admission/path/scope and
# all verifier gates are retained. Optional overrides are in a separate module.
@unsafe
def p144o_request(+source: List<&2,KDef>, view: List<&2,KDef>, closure: NR_Closure, bound: Maybe<&2,U32>) -> NR_Request:
  match closure:
    case NR_Closure{+names,facts}:
      NR_Request{source,ns_attach_book(view,facts,0,[]),names,nc_paths_of(source,names),kr_filter(source,names),bound}

@unsafe
def p144o_source_ready(+source: List<&2,KDef>, bound: U32, facts: P144OFacts) -> NR_Request:
  +view = p144o_view(source,facts)
  p144o_request(source,view,nr_walk(view,["main"],[],[]),Some{bound})

@unsafe
def p144o_prepare_annotated(+book: List<&2,KDef>, annotated: List<&2,KDef>) -> NR_Request:
  +merged = nc_context_defs(book,nc_context_index(annotated))
  +bound = norm_max_book(merged)
  +source = book_cached(merged,bound)
  p144o_source_ready(source,bound,p144o_build(source))

@unsafe
def p144o_prepared(+source: List<&2,KDef>, +names: List<&2,String>, constructors: List<&2,N_Constructor>, prepared: P112SPrepared) -> P128RawLowering:
  match prepared:
    case P112SPrepared{+book,+nodes,+error}:
      nt_choose(P128RawLowering,String.is_empty(error),
        u => p144o_lower_bangs(source,book,nodes,names,constructors,nc_bangs_names(book,names)),
        u => P128RawLowering{P113DLowered{P113DProgram{P112StaticProgram{p111_empty(),[]},[]},error},[]})

@unsafe
def p144o_lower_bangs(source: List<&2,KDef>, +book: List<&2,KDef>, +nodes: List<&2,P112SNode>, +names: List<&2,String>, constructors: List<&2,N_Constructor>, +bangs: List<&2,String>) -> P128RawLowering:
  p128raw_plan_finish(p112s_finish(nodes,p140or_finish(source,names,constructors,
    p111_compile_defs(book,names,bangs,0,[]))),
    p113pl_candidates(book,names,bangs,book_cached(nq_signatures(book,names),0)))

@unsafe
def p144o_catalogued(source: List<&2,KDef>, book: List<&2,KDef>, +names: List<&2,String>, +constructors: List<&2,N_Constructor>) -> P128RawLowering:
  p144o_prepared(source,names,constructors,p112s_prepare(book,names,constructors))

@unsafe
def p144o_lower_request(request: NR_Request) -> P128RawLowering:
  match request:
    case NR_Request{+source,+book,+names,paths,scope,+bound}:
      +error = nc_compile_error_known(source,bound)
      nt_choose(P128RawLowering,String.is_empty(error),
        u => p144o_catalogued(source,book,names,nc_add_ctors(nc_default_ctors(),
          p144o_constructors(source,source,p144o_payload(nc_ctor_context(book))))),
        u => P128RawLowering{P113DLowered{P113DProgram{P112StaticProgram{p111_empty(),[]},[]},error},[]})
