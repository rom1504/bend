# Exact original request/context/static/admission orchestration, carrying one additional run product.
# p140or_finish, private candidate preparation and global dependency gates remain original.

@unsafe
def p142or_lower(request: NR_Request, +previous: P140ORCache) -> P142ORResult:
  match request:
    case NR_Request{+source,+book,+names,paths,scope,+bound}:
      +error = nc_compile_error_known(source,bound)
      nt_choose(P142ORResult,String.is_empty(error),
        u => p142or_catalogued(source,book,names,previous,nc_add_ctors(nc_default_ctors(),nc_constructors(source,source))),
        u => p142or_error(previous,error))

@unsafe
def p142or_error(previous: P140ORCache, error: String) -> P142ORResult:
  P142ORResult{P128RawLowering{P113DLowered{P113DProgram{P112StaticProgram{p111_empty(),[]},[]},error},[]},previous,[],[]}

# Both original calls derive this identical ordered catalogue from the same source.
# Retain it across preparation instead of querying ownership/layouts a second time.

@unsafe
def p142or_catalogued(+source: List<&2,KDef>, +book: List<&2,KDef>, +names: List<&2,String>,
    +previous: P140ORCache, +constructors: List<&2,N_Constructor>) -> P142ORResult:
  match previous:
    case P140ORCache{old,edges,reverse,nodes,old_names,bangs,signatures,generic,private,static}:
      p142or_static(source,names,previous,constructors,p140sp_prepare(book,names,constructors,static))

@unsafe
def p142or_static(source: List<&2,KDef>, names: List<&2,String>, previous: P140ORCache,
    constructors: List<&2,N_Constructor>, result: P140SPResult) -> P142ORResult:
  match result:
    case P140SPResult{prepared,cache,stats}: p142or_prepared(source,names,previous,constructors,cache,stats,prepared)

@unsafe
def p142or_prepared(+source: List<&2,KDef>, +names: List<&2,String>, +previous: P140ORCache,
    +constructors: List<&2,N_Constructor>, +static: P140SPCache, +static_stats: List<&2,U32>, prepared: P112SPrepared) -> P142ORResult:
  match prepared:
    case P112SPrepared{+book,+nodes,+error}:
      nt_choose(P142ORResult,String.is_empty(error),
        u => p142or_context(source,book,nodes,names,nc_bangs_names(book,names),book_cached(nq_signatures(book,names),0),previous,constructors,static,static_stats),
        u => p142or_error(previous,error))

@unsafe
def p142or_context(+source: List<&2,KDef>, +book: List<&2,KDef>, +nodes: List<&2,P112SNode>, +names: List<&2,String>,
    +bangs: List<&2,String>, +signatures: List<&2,KDef>, previous: P140ORCache, constructors: List<&2,N_Constructor>, static: P140SPCache, static_stats: List<&2,U32>) -> P142ORResult:
  match previous:
    case P140ORCache{+old,+edges,+reverse,old_nodes,old_names,old_bangs,old_signatures,generic,private,old_static}:
      +analysis = p140oq_fact_analysis(old,book,names,reverse,p140oq_analyze(old,book,edges,reverse))
      +allowed = p140or_global(old_names,names,old_bangs,bangs,old_signatures,signatures,old_nodes,nodes)
      p142or_compiled(source,book,nodes,names,bangs,signatures,analysis,p140oq_refresh(edges,reverse,analysis),allowed,private,constructors,static,static_stats,
        p142og_apply(book,names,bangs,analysis,allowed,generic))

@unsafe
def p142or_compiled(+source: List<&2,KDef>, +book: List<&2,KDef>, +nodes: List<&2,P112SNode>, +names: List<&2,String>,
    +bangs: List<&2,String>, +signatures: List<&2,KDef>, +analysis: P140OAnalysis, reverse: KDef, +allowed: Bool, previous: List<&2,P140OPEntry>, constructors: List<&2,N_Constructor>, static: P140SPCache, static_stats: List<&2,U32>, result: P142OGResult) -> P142ORResult:
  match result:
    case P142OGResult{compiled,entries,runs,gh,gm}:
      p142or_candidates(book,nodes,names,bangs,signatures,analysis,reverse,allowed,entries,gh,gm,static,static_stats,runs,
        p112s_finish(nodes,p140or_finish(source,names,constructors,compiled)),p140op_apply(book,names,bangs,signatures,analysis,allowed,previous))

@unsafe
def p142or_candidates(book: List<&2,KDef>, nodes: List<&2,P112SNode>, names: List<&2,String>, bangs: List<&2,String>, signatures: List<&2,KDef>,
    analysis: P140OAnalysis, reverse: KDef, allowed: Bool, generic: List<&2,P140OGEntry>, gh: U32, gm: U32, static: P140SPCache, static_stats: List<&2,U32>, runs: List<&2,P142WRun>, original: P112SResult, result: P140OPResult) -> P142ORResult:
  match analysis result:
    case P140OAnalysis{ready,dirty,edges,count} P140OPResult{candidates,entries,ph,pm}:
      P142ORResult{p128raw_plan_finish(original,candidates),P140ORCache{book,edges,reverse,nodes,names,bangs,signatures,generic,entries,static},runs,
        nt_append(U32,[gh,gm,ph,pm,count,Bool.to_u32(ready),Bool.to_u32(allowed)],static_stats)}

# Exact p111_finish body, except its catalogue is the already evaluated identical
# expression from p142or_lower. Production p111_finish remains unchanged.
