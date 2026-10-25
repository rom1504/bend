type P140OFCache is Data:
  P140OFCache{+book: List<&2,KDef>, +edges: List<&2,P140OEdge>, +reverse: KDef, +annotations: List<&2,P140OAEntry>, +erasures: List<&2,P140OEEntry>}

type P140OFResult is Data:
  P140OFResult{+plan: P86Plan, +cache: P140OFCache, +stats: List<&2,U32>}

type P140ORCache is Data:
  P140ORCache{+book: List<&2,KDef>, +edges: List<&2,P140OEdge>, +reverse: KDef, +nodes: List<&2,P112SNode>,
    +names: List<&2,String>, +bangs: List<&2,String>, +signatures: List<&2,KDef>,
    +generic: List<&2,P140OGEntry>, +private: List<&2,P140OPEntry>}

type P140ORResult is Data:
  P140ORResult{+lowering: P128RawLowering, +cache: P140ORCache, +stats: List<&2,U32>}

def p140of_empty() -> P140OFCache:
  P140OFCache{[],[],missing(),[],[]}

def p140or_empty() -> P140ORCache:
  P140ORCache{[],[],missing(),[],[],[],[],[],[]}

# Replace only p86_plan_context's private orchestration in an experimental
# session. Parsing/checking/ownership/entry checks have already succeeded.
@unsafe
def p140of_context(+context: List<&2,KDef>, verdict: String, +previous: P140OFCache) -> P140OFResult:
  match previous:
    case P140OFCache{old,edges,reverse,annotations,erasures}:
      +analysis = p140oq_analyze(old,context,edges,reverse)
      +stops = nc_annotation_stops(context)
      p140of_annotated(context,stops,verdict,analysis,previous,
        p140oa_apply(context,reach_book(context,["main"],stops),stops,analysis,annotations))

@unsafe
def p140of_annotated(+context: List<&2,KDef>, +stops: List<&2,String>, +verdict: String, +analysis: P140OAnalysis,
    +previous: P140OFCache, result: P140OAResult) -> P140OFResult:
  match result:
    case P140OAResult{+definitions,+entries,+hits,+misses}:
      +error = jl_checked_error(context,definitions,["main"],stops)
      nt_choose(P140OFResult,String.is_empty(error),
        u => p140of_merge(context,definitions,verdict,analysis,previous,entries,hits,misses),
        u => P140OFResult{P86PlanError{"compile: " ++ error},previous,[]})

@unsafe
def p140of_merge(+context: List<&2,KDef>, annotated: List<&2,KDef>, verdict: String, +analysis: P140OAnalysis,
    previous: P140OFCache, entries: List<&2,P140OAEntry>, hits: U32, misses: U32) -> P140OFResult:
  match previous:
    case P140OFCache{old,edges,reverse,annotations,erasures}:
      +merged = nc_context_defs(context,nc_context_index(annotated))
      +bound = norm_max_book(merged)
      +source = book_cached(merged,bound)
      p140of_erased(context,source,bound,verdict,analysis,p140oq_refresh(edges,reverse,analysis),entries,hits,misses,p140oe_apply(source,analysis,erasures))

@unsafe
def p140of_erased(context: List<&2,KDef>, +source: List<&2,KDef>, bound: U32, verdict: String, analysis: P140OAnalysis, reverse: KDef,
    annotations: List<&2,P140OAEntry>, ah: U32, am: U32, result: P140OEResult) -> P140OFResult:
  match analysis result:
    case P140OAnalysis{ready,dirty,edges,count} P140OEResult{closure,entries,eh,em}:
      P140OFResult{P86PlanReady{nr_prepared(source,closure,Some{bound}),verdict},
        P140OFCache{context,edges,reverse,annotations,entries},[ah,am,eh,em,count,Bool.to_u32(ready)]}

# Replace only p128raw_lower_request in the private session. The original
# compile eligibility, static preparation, pass closure and final verification
# remain in their original positions. No ready/admission rule is weakened.
@unsafe
def p140or_lower(request: NR_Request, +previous: P140ORCache) -> P140ORResult:
  match request:
    case NR_Request{+source,+book,+names,paths,scope,+bound}:
      +error = nc_compile_error_known(source,bound)
      nt_choose(P140ORResult,String.is_empty(error),
        u => p140or_catalogued(source,book,names,previous,nc_add_ctors(nc_default_ctors(),nc_constructors(source,source))),
        u => p140or_error(previous,error))

@unsafe
def p140or_error(previous: P140ORCache, error: String) -> P140ORResult:
  P140ORResult{P128RawLowering{P113DLowered{P113DProgram{P112StaticProgram{p111_empty(),[]},[]},error},[]},previous,[]}

# Both original calls derive this identical ordered catalogue from the same source.
# Retain it across preparation instead of querying ownership/layouts a second time.
@unsafe
def p140or_catalogued(+source: List<&2,KDef>, +book: List<&2,KDef>, +names: List<&2,String>,
    previous: P140ORCache, +constructors: List<&2,N_Constructor>) -> P140ORResult:
  p140or_prepared(source,names,previous,constructors,p112s_prepare(book,names,constructors))

@unsafe
def p140or_prepared(+source: List<&2,KDef>, +names: List<&2,String>, +previous: P140ORCache,
    +constructors: List<&2,N_Constructor>, prepared: P112SPrepared) -> P140ORResult:
  match prepared:
    case P112SPrepared{+book,+nodes,+error}:
      nt_choose(P140ORResult,String.is_empty(error),
        u => p140or_context(source,book,nodes,names,nc_bangs_names(book,names),book_cached(nq_signatures(book,names),0),previous,constructors),
        u => p140or_error(previous,error))

@unsafe
def p140or_context(+source: List<&2,KDef>, +book: List<&2,KDef>, +nodes: List<&2,P112SNode>, +names: List<&2,String>,
    +bangs: List<&2,String>, +signatures: List<&2,KDef>, previous: P140ORCache, constructors: List<&2,N_Constructor>) -> P140ORResult:
  match previous:
    case P140ORCache{+old,+edges,+reverse,old_nodes,old_names,old_bangs,old_signatures,generic,private}:
      +analysis = p140oq_fact_analysis(old,book,names,reverse,p140oq_analyze(old,book,edges,reverse))
      +allowed = p140or_global(old_names,names,old_bangs,bangs,old_signatures,signatures,old_nodes,nodes)
      p140or_compiled(source,book,nodes,names,bangs,signatures,analysis,p140oq_refresh(edges,reverse,analysis),allowed,private,constructors,
        p140og_apply(book,names,bangs,analysis,allowed,generic))

@unsafe
def p140or_compiled(+source: List<&2,KDef>, +book: List<&2,KDef>, +nodes: List<&2,P112SNode>, +names: List<&2,String>,
    +bangs: List<&2,String>, +signatures: List<&2,KDef>, +analysis: P140OAnalysis, reverse: KDef, +allowed: Bool, previous: List<&2,P140OPEntry>, constructors: List<&2,N_Constructor>, result: P140OGResult) -> P140ORResult:
  match result:
    case P140OGResult{compiled,entries,gh,gm}:
      p140or_candidates(book,nodes,names,bangs,signatures,analysis,reverse,allowed,entries,gh,gm,
        p112s_finish(nodes,p140or_finish(source,names,constructors,compiled)),p140op_apply(book,names,bangs,signatures,analysis,allowed,previous))

@unsafe
def p140or_candidates(book: List<&2,KDef>, nodes: List<&2,P112SNode>, names: List<&2,String>, bangs: List<&2,String>, signatures: List<&2,KDef>,
    analysis: P140OAnalysis, reverse: KDef, allowed: Bool, generic: List<&2,P140OGEntry>, gh: U32, gm: U32, original: P112SResult, result: P140OPResult) -> P140ORResult:
  match analysis result:
    case P140OAnalysis{ready,dirty,edges,count} P140OPResult{candidates,entries,ph,pm}:
      P140ORResult{p128raw_plan_finish(original,candidates),P140ORCache{book,edges,reverse,nodes,names,bangs,signatures,generic,entries},
        [gh,gm,ph,pm,count,Bool.to_u32(ready),Bool.to_u32(allowed)]}

# Exact p111_finish body, except its catalogue is the already evaluated identical
# expression from p140or_lower. Production p111_finish remains unchanged.
@unsafe
def p140or_finish(+source: List<&2,KDef>, +names: List<&2,String>, +ctors: List<&2,N_Constructor>, compiled: P111Book) -> P111Result:
  match compiled:
    case P111Book{+segments,+fresh,+error}:
      +ty = dt(lookup(source,"main"))
      +pure = Bool.not(nc_is_io(source,ty))
      nt_choose(P111Result,String.eq(error,""),
        u => p111_finish_show(segments,ctors,p111_effects(source,names),pure,
          nt_choose(P111Show,pure,u => p111_show(source,ty,ctors),u => P111Show{[0],[],""})),
        u => P111Result{p111_empty(),error})
