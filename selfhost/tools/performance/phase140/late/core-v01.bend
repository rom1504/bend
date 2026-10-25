# Optional internal observer-scan memo. This cache belongs to the ORIGINAL
# NR_Request.book, never p112s_prepare's rewritten book. It is fixed-producer,
# process-private state published only after the complete request succeeds.
# Original closure/retry and final p126bp_complete verification remain intact.
type P140LItem is Data:
  P140LItem{+name: String, +plan: NO_Plan, +mode: U32, +workers: P118BWorkers, +fallback: List<&2,P113DFunction>}

type P140LCache is Data:
  P140LCache{+book: List<&2,KDef>, +edges: List<&2,P140OEdge>, +reverse: KDef, +names: List<&2,String>, +items: List<&2,P140LItem>}

type P140LScan is Data:
  P140LScan{+scan: P128BROpen, +items: List<&2,P140LItem>, +hits: U32, +misses: U32}

type P140LResult is Data:
  P140LResult{+scan: P128BROpen, +cache: P140LCache, +stats: List<&2,U32>}

def p140l_empty() -> P140LCache:
  P140LCache{[],[],missing(),[],[]}

@unsafe
def p140l_names(book: List<&2,KDef>) -> List<&2,String>:
  match book:
    case Nil{}: []
    case Con{d,rest}: Con{dn(d),p140l_names(rest)}

@unsafe
def p140l_scan(+book: List<&2,KDef>, +names: List<&2,String>, original: List<&2,P113DFunction>, +previous: P140LCache) -> P140LResult:
  match previous:
    case P140LCache{+old,+edges,+reverse,old_names,items}:
      +analysis = p140oq_fact_analysis(old,book,p140l_names(p140o_plain(book)),reverse,p140oq_analyze(old,book,edges,reverse))
      p140l_context(book,names,original,previous,analysis,p140oq_refresh(edges,reverse,analysis),p140o_strings(old_names,names),items)

@unsafe
def p140l_context(+book: List<&2,KDef>, +names: List<&2,String>, original: List<&2,P113DFunction>, previous: P140LCache,
    analysis: P140OAnalysis, reverse: KDef, allowed: Bool, items: List<&2,P140LItem>) -> P140LResult:
  match analysis:
    case P140OAnalysis{+ready,dirty,edges,count}:
      p140l_done(book,names,edges,reverse,previous,ready,count,
        p140l_walk(book,names,original,ready && allowed,dirty,items,[],[],[],[],0,0))

@unsafe
def p140l_done(book: List<&2,KDef>, names: List<&2,String>, edges: List<&2,P140OEdge>, reverse: KDef,
    previous: P140LCache, ready: Bool, count: U32, result: P140LScan) -> P140LResult:
  match result:
    case P140LScan{+scan,items,hits,misses}:
      match scan:
        case P128BROpen{functions,helpers,retry,+error}:
          P140LResult{scan,nt_choose(P140LCache,String.is_empty(error),
            u => P140LCache{book,edges,reverse,names,items},u => previous),[hits,misses,count,Bool.to_u32(ready)]}

# Match the FIRST function name, including an ineligible first occurrence.
# This is the exact lookup boundary of p128bs_find, not a signature-only key.
@unsafe
def p140l_fallback(functions: List<&2,P113DFunction>, +name: String) -> List<&2,P113DFunction>:
  match functions:
    case Nil{}: []
    case Con{+head,rest}:
      match head:
        case P113DFunction{found,params,result,public,body}:
          nt_choose(List<&2,P113DFunction>,String.eq(found,name),u => [head],u => p140l_fallback(rest,name))

@unsafe
def p140l_make(+book: List<&2,KDef>, +name: String, +original: List<&2,P113DFunction>) -> P140LItem:
  p140l_plan(book,name,original,no_observer_plan(book,name,True{}))

@unsafe
def p140l_plan(+book: List<&2,KDef>, +name: String, +original: List<&2,P113DFunction>, +plan: NO_Plan) -> P140LItem:
  nt_choose(P140LItem,p118b_eligible(book,plan),
    u => P140LItem{name,plan,1,p118b_functions(book,name,plan),[]},
    u => nt_choose(P140LItem,p128bs_eligible(book,plan),
      v => P140LItem{name,plan,2,p128bs_find(book,name,plan,original),p140l_fallback(original,p113d_public(book,name))},
      v => P140LItem{name,plan,0,P118BWorkers{[],""},[]}))

@unsafe
def p140l_hit(+book: List<&2,KDef>, +name: String, original: List<&2,P113DFunction>, allowed: Bool, dirty: KDef, item: P140LItem) -> Bool:
  match item:
    case P140LItem{old,plan,+mode,workers,fallback}:
      allowed && String.eq(name,old) && Bool.not(p140o_has(dirty,name)) &&
        nt_choose(Bool,U32.is_eq(mode,2),
          u => p134v_list(P113DFunction,p134v_function,fallback,p140l_fallback(original,p113d_public(book,name))),u => True{})

@unsafe
def p140l_walk(+book: List<&2,KDef>, names: List<&2,String>, +original: List<&2,P113DFunction>, +allowed: Bool, +dirty: KDef,
    prior: List<&2,P140LItem>, +items: List<&2,P140LItem>, +functions: List<&2,P113DFunction>, +helpers: List<&2,P128BRHelper>,
    +retry: List<&2,NO_Plan>, +hits: U32, +misses: U32) -> P140LScan:
  match names prior:
    case Nil{} _: P140LScan{P128BROpen{nt_reverse(P113DFunction,functions,[]),nt_reverse(P128BRHelper,helpers,[]),nt_reverse(NO_Plan,retry,[]),""},nt_reverse(P140LItem,items,[]),hits,misses}
    case Con{+name,rest} Nil{}:
      p140l_step(book,rest,original,allowed,dirty,[],items,functions,helpers,retry,hits,U32.inc(misses),p140l_make(book,name,original))
    case Con{+name,+rest} Con{+item,+tail}:
      nt_choose(P140LScan,p140l_hit(book,name,original,allowed,dirty,item),
        u => p140l_step(book,rest,original,allowed,dirty,tail,items,functions,helpers,retry,U32.inc(hits),misses,item),
        u => p140l_step(book,rest,original,allowed,dirty,tail,items,functions,helpers,retry,hits,U32.inc(misses),p140l_make(book,name,original)))

@unsafe
def p140l_step(+book: List<&2,KDef>, +names: List<&2,String>, +original: List<&2,P113DFunction>, +allowed: Bool, +dirty: KDef,
    +prior: List<&2,P140LItem>, +items: List<&2,P140LItem>, +functions: List<&2,P113DFunction>, +helpers: List<&2,P128BRHelper>,
    +retry: List<&2,NO_Plan>, +hits: U32, +misses: U32, +item: P140LItem) -> P140LScan:
  match item:
    case P140LItem{+name,+plan,+mode,+workers,fallback}:
      match workers:
        case P118BWorkers{+added,+error}:
          nt_choose(P140LScan,String.is_empty(error),u =>
            nt_choose(P140LScan,U32.is_eq(mode,0),
              v => p140l_walk(book,names,original,allowed,dirty,prior,Con{item,items},functions,helpers,
                nt_choose(List<&2,NO_Plan>,p128br_retryable(plan),w => Con{plan,retry},w => retry),hits,misses),
              v => p140l_walk(book,names,original,allowed,dirty,prior,Con{item,items},nt_reverse(P113DFunction,added,functions),
                nt_reverse(P128BRHelper,p128br_seed(name,no_plan_schema(plan),workers),helpers),
                nt_choose(List<&2,NO_Plan>,U32.is_eq(mode,2) && List.is_empty(&2,P113DFunction,added),w => Con{plan,retry},w => retry),hits,misses)),
            u => P140LScan{P128BROpen{[],[],[],error},[],hits,misses})
