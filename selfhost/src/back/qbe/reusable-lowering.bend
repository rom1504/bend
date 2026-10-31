

def p140l_empty() -> P140LCache:
  P140LCache{[],[],missing(),[],[],[]}

# nol_finish appends this GLOBAL catalogue to each successful schema. An
# unrelated ADT can mention an edited alias, so owner dependencies alone do not
# prove it stable. Construct it once per request and compare every stored field.

@unsafe
def p140l_spec(a: NO_Spec, b: NO_Spec) -> Bool:
  match a b:
    case NO_Spec{NO_Layout{ak,ac,as_,aw},ao,at} NO_Spec{NO_Layout{bk,bc,bs,bw},bo,bt}:
      String.eq(ak,bk) && String.eq(ac,bc) && String.eq(as_,bs) && U32.is_eq(aw,bw) &&
        String.eq(ao,bo) && p140o_strings(at,bt)

# Include exact erased/static fact references directly, instead of assuming
# that the erasure producer cannot introduce names absent from source syntax.

@unsafe
def p140l_edge(+book: List<&2,KDef>, +d: KDef) -> P140OEdge:
  P140OEdge{dn(d),p140o_refs([d,ns_body(book,dn(d))],["Nat","U32","F32","String","Char","Bool","Word","List"])}


@unsafe
def p140l_edges(+book: List<&2,KDef>, defs: List<&2,KDef>) -> List<&2,P140OEdge>:
  match defs:
    case Nil{}: []
    case Con{d,rest}: Con{p140l_edge(book,d),p140l_edges(book,rest)}


@unsafe
def p140l_analyze(+old: List<&2,KDef>, +current: List<&2,KDef>, +edges: List<&2,P140OEdge>, +reverse: KDef) -> P140OAnalysis:
  +a = p140o_plain(old)
  +b = p140o_plain(current)
  nt_choose(P140OAnalysis,Bool.not(List.is_empty(&2,KDef,a)) &&
    U32.is_eq(base_prefix_stamp(old,0),base_prefix_stamp(current,0)) &&
    U32.is_eq(nt_count(KDef,a),nt_count(P140OEdge,edges)) && p140o_headers(a,b),
    u => p140oq_delta(reverse,p140l_delta(old,current,a,b,edges,P140ODirty{missing(),0},[])),
    u => P140OAnalysis{False{},missing(),p140l_edges(current,b),0})

# Equal ordered headers and edge count guarantee the three lists align for a
# privately published cache. Recompute an edge if EITHER actual input changes.

@unsafe
def p140l_delta(+old: List<&2,KDef>, +current: List<&2,KDef>, left: List<&2,KDef>, right: List<&2,KDef>, edges: List<&2,P140OEdge>,
    +dirty: P140ODirty, +acc: List<&2,P140OEdge>) -> P140ODelta:
  match left right edges:
    case Con{+a,ar} Con{+b,br} Con{+edge,er}:
      +same = f_fresh_prefix_exact_defs([a],[b]) &&
        f_fresh_prefix_exact_defs([ns_body(old,dn(a))],[ns_body(current,dn(b))])
      p140l_delta(old,current,ar,br,er,
        nt_choose(P140ODirty,same,u => dirty,u => p140o_mark(dn(a),dirty)),
        Con{nt_choose(P140OEdge,same,u => edge,u => p140l_edge(current,b)),acc})
    case _ _ _: P140ODelta{nt_reverse(P140OEdge,acc,[]),dirty}


@unsafe
def p140l_scan(+book: List<&2,KDef>, +names: List<&2,String>, original: List<&2,P113DFunction>, +previous: P140LCache) -> P140LResult:
  match previous:
    case P140LCache{+old,+edges,+reverse,old_names,old_specs,items}:
      +specs = nol_scalar_specs(book,book)
      +analysis = p140l_analyze(old,book,edges,reverse)
      p140l_context(book,names,specs,original,previous,analysis,p140oq_refresh(edges,reverse,analysis),
        p140o_strings(old_names,names) && p134v_list(~NO_Spec,~p140l_spec,old_specs,specs),items)

@unsafe
def p140l_context(+book: List<&2,KDef>, +names: List<&2,String>, specs: List<&2,NO_Spec>, original: List<&2,P113DFunction>, previous: P140LCache,
    analysis: P140OAnalysis, reverse: KDef, allowed: Bool, items: List<&2,P140LItem>) -> P140LResult:
  match analysis:
    case P140OAnalysis{+ready,dirty,edges,count}:
      p140l_done(book,names,specs,edges,reverse,previous,ready,count,
        p140l_walk(book,names,original,ready && allowed,dirty,items,[],[],[],[],0,0))


@unsafe
def p140l_done(book: List<&2,KDef>, names: List<&2,String>, specs: List<&2,NO_Spec>, edges: List<&2,P140OEdge>, reverse: KDef,
    previous: P140LCache, ready: Bool, count: U32, result: P140LScan) -> P140LResult:
  match result:
    case P140LScan{+scan,items,hits,misses}:
      match scan:
        case P128BROpen{functions,helpers,retry,+error}:
          P140LResult{scan,nt_choose(P140LCache,String.is_empty(error),
            u => P140LCache{book,edges,reverse,names,specs,items},u => previous),[hits,misses,count,Bool.to_u32(ready)]}

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
          u => p134v_list(~P113DFunction,~p134v_function,fallback,p140l_fallback(original,p113d_public(book,name))),u => True{})

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

def p140lc_function(name: String, value: U32) -> P113DFunction:
  P113DFunction{name,[],1,True{},[P113DResult{[N111Const{value,0}]}]}


@unsafe
def p140lc_item(+name: String, mode: U32, fallback: List<&2,P113DFunction>) -> P140LItem:
  P140LItem{name,no_plan_refuse(name,"finite control"),mode,P118BWorkers{[],""},fallback}


@unsafe
def p140lc_dirty(name: String) -> KDef:
  p140lc_dirty_result(p140o_mark(name,P140ODirty{missing(),0}))


def p140lc_dirty_result(dirty: P140ODirty) -> KDef:
  match dirty:
    case P140ODirty{names,count}: names


@unsafe
def p140lc_counts(result: P140LResult, hits: U32, misses: U32) -> Bool:
  match result:
    case P140LResult{scan,cache,stats}: p134v_list(~U32,~U32.is_eq,p140lc_pair(stats),[hits,misses])

def p140lc_pair(stats: List<&2,U32>) -> List<&2,U32>:
  match stats:
    case Con{h,Con{m,rest}}: [h,m]
    case _: []


@unsafe
def p140lc_cache(result: P140LResult) -> P140LCache:
  match result:
    case P140LResult{scan,cache,stats}: cache


@unsafe
def p140lc_book(value: U32) -> List<&2,KDef>:
  book_cached([
    KDef{"main","Control",0,0,atom("Data"),ref("leaf"),[],False{},False{}},
    KDef{"leaf","Control",0,0,atom("Data"),KLiteral{"U32",value,"",0,0},[],False{},False{}},
    KDef{"other","Control",0,0,atom("Data"),atom("Absent"),[],False{},False{}}],40)

# An unrelated nullary constructor result unfolds an editable alias. The
# catalogue changes although the selected main owner's dependency closure does
# not mention Alias/Hidden; source headers remain byte-identical.

@unsafe
def p140lc_global_book(+target: String) -> List<&2,KDef>:
  book_cached([
    KDef{"main","Control",0,0,atom("Data"),atom("Absent"),[],False{},False{}},
    KDef{"Alias","Def",0,0,atom("Data"),kt("ADT",target,0,0,[]),[],False{},False{}},
    KDef{"Hidden","ADT",0,0,atom("Data"),atom("Absent"),
      [KDef{"Hidden0","Ctr",0,0,ref("Alias"),atom("Absent"),[],False{},False{}}],False{},False{}},
    KDef{"Other","ADT",0,0,atom("Data"),atom("Absent"),[],False{},False{}}],40)


@unsafe
def p140lc_hidden_book(value: U32, target: String) -> List<&2,KDef>:
  ns_attach_book(book_cached([
    KDef{"main","Control",0,0,atom("Data"),atom("Absent"),[],False{},False{}},
    KDef{"H","Control",0,0,atom("Data"),KLiteral{"U32",value,"",0,0},[],False{},False{}},
    KDef{"G","Control",0,0,atom("Data"),KLiteral{"U32",9,"",0,0},[],False{},False{}}],40),
    [KDef{"main","NativeErasedBody",0,0,atom("Absent"),ref(target),[],False{},False{}}],0,[])


@unsafe
def p140lc_controls() -> List<&2,String>:
  +hidden_a = p140lc_hidden_book(1,"H")
  +hidden_b = p140lc_hidden_book(1,"G")
  +hidden_cache = p140lc_cache(p140l_scan(hidden_a,["main"],[],p140l_empty()))
  +hidden_next = p140lc_cache(p140l_scan(hidden_b,["main"],[],hidden_cache))
  +global_a = p140lc_global_book("Hidden")
  +global_b = p140lc_global_book("Other")
  +global_cache = p140lc_cache(p140l_scan(global_a,["main"],[],p140l_empty()))
  +spec : NO_Spec = NO_Spec{NO_Layout{"key","ctor","Boxed",2},"Owner",["A","B"]}
  +empty = missing()
  +name = p113d_public([],"f")
  +a = p140lc_function(name,1)
  +b = p140lc_function(name,2)
  +other = p140lc_function("unrelated",9)
  +none = p140lc_item("f",0,[])
  +scalar = p140lc_item("f",2,[a])
  +absent = p140lc_item("f",2,[])
  +book = p140lc_book(1)
  +names : List<&2,String> = ["main","leaf","other"]
  +cold = p140l_scan(book,names,[],p140l_empty())
  +prior = p140lc_cache(cold)
  [p114st_row("late-hidden-fact-reference-invalidates",p140lc_counts(p140l_scan(p140lc_hidden_book(2,"H"),["main"],[],hidden_cache),0,1)),
   p114st_row("late-hidden-fact-edit-invalidates",p140lc_counts(p140l_scan(hidden_b,["main"],[],hidden_cache),0,1)),
   p114st_row("late-hidden-fact-edge-removal-retained",p140lc_counts(p140l_scan(p140lc_hidden_book(2,"G"),["main"],[],hidden_next),1,0)),
   p114st_row("late-global-alias-changes-catalogue",Bool.not(p134v_list(~NO_Spec,~p140l_spec,nol_scalar_specs(global_a,global_a),nol_scalar_specs(global_b,global_b)))),
   p114st_row("late-global-alias-invalidates-unrelated-owner",p140lc_counts(p140l_scan(global_b,["main"],[],global_cache),0,1)),
   p114st_row("late-spec-identical",p140l_spec(spec,spec)),
   p114st_row("late-spec-key",Bool.not(p140l_spec(spec,NO_Spec{NO_Layout{"other","ctor","Boxed",2},"Owner",["A","B"]}))),
   p114st_row("late-spec-ctor",Bool.not(p140l_spec(spec,NO_Spec{NO_Layout{"key","other","Boxed",2},"Owner",["A","B"]}))),
   p114st_row("late-spec-storage",Bool.not(p140l_spec(spec,NO_Spec{NO_Layout{"key","ctor","Nullary",2},"Owner",["A","B"]}))),
   p114st_row("late-spec-width",Bool.not(p140l_spec(spec,NO_Spec{NO_Layout{"key","ctor","Boxed",1},"Owner",["A","B"]}))),
   p114st_row("late-spec-owner",Bool.not(p140l_spec(spec,NO_Spec{NO_Layout{"key","ctor","Boxed",2},"Other",["A","B"]}))),
   p114st_row("late-spec-type-order",Bool.not(p140l_spec(spec,NO_Spec{NO_Layout{"key","ctor","Boxed",2},"Owner",["B","A"]}))),
   p114st_row("late-spec-type-length",Bool.not(p140l_spec(spec,NO_Spec{NO_Layout{"key","ctor","Boxed",2},"Owner",["A"]}))),
   p114st_row("late-spec-type-name",Bool.not(p140l_spec(spec,NO_Spec{NO_Layout{"key","ctor","Boxed",2},"Owner",["A","C"]}))),
   p114st_row("late-refusal-reuses",p140l_hit([],"f",[],True{},empty,none)),
   p114st_row("late-unready-refuses",Bool.not(p140l_hit([],"f",[],False{},empty,none))),
   p114st_row("late-owner-name-refuses",Bool.not(p140l_hit([],"g",[],True{},empty,none))),
   p114st_row("late-dirty-refuses",Bool.not(p140l_hit([],"f",[],True{},p140lc_dirty("f"),none))),
   p114st_row("late-unrelated-dirty-reuses",p140l_hit([],"f",[],True{},p140lc_dirty("g"),none)),
   p114st_row("late-scalar-exact-fallback",p140l_hit([],"f",[a],True{},empty,scalar)),
   p114st_row("late-scalar-body-change",Bool.not(p140l_hit([],"f",[b],True{},empty,scalar))),
   p114st_row("late-scalar-missing-fallback",Bool.not(p140l_hit([],"f",[],True{},empty,scalar))),
   p114st_row("late-scalar-new-fallback",Bool.not(p140l_hit([],"f",[a],True{},empty,absent))),
   p114st_row("late-scalar-unchanged-absence",p140l_hit([],"f",[other],True{},empty,absent)),
   p114st_row("late-scalar-unrelated-body",p140l_hit([],"f",[other,a],True{},empty,scalar)),
   p114st_row("late-scalar-first-duplicate",p140l_hit([],"f",[a,b],True{},empty,scalar)),
   p114st_row("late-scalar-changed-first-duplicate",Bool.not(p140l_hit([],"f",[b,a],True{},empty,scalar))),
   p114st_row("late-cold-misses",p140lc_counts(cold,0,3)),
   p114st_row("late-same-book-hits",p140lc_counts(p140l_scan(book,names,[],prior),3,0)),
   p114st_row("late-transitive-body-edit",p140lc_counts(p140l_scan(p140lc_book(2),names,[],prior),1,2)),
   p114st_row("late-owner-order-refuses",p140lc_counts(p140l_scan(book,["leaf","main","other"],[],prior),0,3)),
   p114st_row("late-bound-change-refuses",p140lc_counts(p140l_scan(book_cached(p140o_plain(book),41),names,[],prior),0,3))]

@unsafe
def p140lc_original(+request: NR_Request, lowering: P128RawLowering) -> P113ALowering:
  match lowering:
    case P128RawLowering{lowered,raw}:
      p113a_finish(p113a_certificate(request),
        p114s_close_lowered(p114s_ranges_lowered(p114s_inline_lowered(p114s_open_lowered(lowered)))))


@unsafe
def p140lc_fresh(request: NR_Request, original: P113AProgram) -> P128BROpen:
  match request:
    case NR_Request{source,+book,+names,paths,scope,bound}:
      p128br_scan(book,no_candidate_names(book,names,nc_bangs_names(book,names)),p128bs_original(original),[],[],[])


@unsafe
def p140lc_cached(request: NR_Request, original: P113AProgram, previous: P140LCache) -> P140LResult:
  match request:
    case NR_Request{source,+book,+names,paths,scope,bound}:
      p140l_scan(book,no_candidate_names(book,names,nc_bangs_names(book,names)),p128bs_original(original),previous)


@unsafe
def p140lc_complete(+request: NR_Request, +raw: List<&2,P113DCandidate>, +original: P113AProgram, +scan: P128BROpen) -> P111Emission:
  +error = p113a_verify(original)
  nt_choose(P111Emission,String.is_empty(error),u => p140lc_permitted(request,raw,original,scan),
    u => P111Emission{[],"array structured IR: " ++ error})


@unsafe
def p140lc_permitted(+request: NR_Request, +raw: List<&2,P113DCandidate>, +original: P113AProgram, +scan: P128BROpen) -> P111Emission:
  match original:
    case P113AProgram{program,P113ACertificate{+scalar,unshared}}:
      nt_choose(P111Emission,scalar || p118i_permission(request),
        u => p140lc_scanned(request,raw,original,scalar,scan),u => P134Planned{P134Admitted{original}})


@unsafe
def p140lc_scanned(request: NR_Request, raw: List<&2,P113DCandidate>, original: P113AProgram, cold: Bool, scan: P128BROpen) -> P111Emission:
  match request:
    case NR_Request{source,book,names,paths,scope,bound}:
      p128raw_br_scanned(raw,original,book,source,names,cold,scan)


@unsafe
def p140le_verified(+request: NR_Request, +raw: List<&2,P113DCandidate>, +original: P113AProgram, +error: String, +previous: P140LCache) -> P140LEmission:
  nt_choose(P140LEmission,String.is_empty(error),u => p140le_prepare(request,raw,original,previous),
    u => P140LEmission{P111Emission{[],"array structured IR: " ++ error},previous,[]})


@unsafe
def p140le_prepare(+request: NR_Request, +raw: List<&2,P113DCandidate>, +original: P113AProgram, +previous: P140LCache) -> P140LEmission:
  match original:
    case P113AProgram{program,P113ACertificate{scalar,unshared}}:
      nt_choose(P140LEmission,scalar,u => p140le_scan(request,raw,original,True{},previous),u =>
        nt_choose(P140LEmission,p118i_permission(request),
          v => p140le_scan(request,raw,original,False{},previous),
          v => P140LEmission{P134Planned{P134Admitted{original}},previous,[]}))


@unsafe
def p140le_scan(request: NR_Request, raw: List<&2,P113DCandidate>, +original: P113AProgram, cold: Bool, +previous: P140LCache) -> P140LEmission:
  match request:
    case NR_Request{source,+book,+names,paths,scope,bound}:
      p140le_scanned(raw,original,book,source,names,cold,previous,
        p140l_scan(book,no_candidate_names(book,names,nc_bangs_names(book,names)),p128bs_original(original),previous))


@unsafe
def p140le_scanned(raw: List<&2,P113DCandidate>, original: P113AProgram, book: List<&2,KDef>, source: List<&2,KDef>, names: List<&2,String>,
    cold: Bool, previous: P140LCache, result: P140LResult) -> P140LEmission:
  match result:
    case P140LResult{scan,cache,stats}:
      p140le_publish(previous,cache,stats,p128raw_br_scanned(raw,original,book,source,names,cold,scan))


@unsafe
def p140le_publish(+previous: P140LCache, +cache: P140LCache, stats: List<&2,U32>, +emission: P111Emission) -> P140LEmission:
  match emission:
    case P111Emission{chunks,+error}:
      P140LEmission{emission,nt_choose(P140LCache,String.is_empty(error),u => cache,u => previous),stats}
    case P134Planned{plan}: P140LEmission{emission,cache,stats}

@unsafe
def p140dr_has(+seen: KDef, +name: String) -> Bool:
  String.eq(dk(index_find(seen,name,index_hash(name,2166136261),32)),"P140ReportSeen")


@unsafe
def p140dr_mark(seen: KDef, +name: String) -> KDef:
  index_set(seen,KDef{name,"P140ReportSeen",0,0,KTerm{"Absent","",0,0,[],[],0,0},KTerm{"Absent","",0,0,[],[],0,0},[],False{},False{}},index_hash(name,2166136261),32)


@unsafe
def p140dr_names(book: List<&2,KDef>, +seen: KDef) -> List<&2,String>:
  match book:
    case Nil{}: []
    case Con{+d,+rest}:
      +name = dn(d)
      nt_choose(List<&2,String>,db(d) || p140dr_has(seen,name),
        u => p140dr_names(rest,seen),
        u => Con{name,p140dr_names(rest,p140dr_mark(seen,name))})


@unsafe
def p140dr_report_data(+book: List<&2,KDef>) -> DR_Report:
  +names = dr_cached_names(book_cached(book_final_fast(book,[]),0),p140dr_names(book,missing()),missing())
  DR_Report{dr_verdict(names),names}


@unsafe
def p140dr_controls() -> List<&2,String>:
  +a = p140drc_def("a",False{},False{})
  +b = p140drc_def("b",False{},True{})
  +native_a = p140drc_def("a",True{},False{})
  +left = p140drc_def("costarring",False{},False{})
  +right = p140drc_def("liquid",False{},True{})
  [p131u_row(p140drc_names([],[],[]),"report-empty"),
   p131u_row(p140drc_names([a,b],[],["a","b"]),"report-source-order"),
   p131u_row(p140drc_names([a,b,a,b],[],["a","b"]),"report-duplicates"),
   p131u_row(p140drc_names([native_a,a,b],[],["a","b"]),"report-native-before-user"),
   p131u_row(p140drc_names([a,native_a,a,b],[],["a","b"]),"report-native-after-user"),
   p131u_row(p140drc_names([native_a,native_a],[],[]),"report-all-native"),
   p131u_row(p140drc_names([a,b],["b"],["a"]),"report-existing-seen"),
   p131u_row(p140drc_names([a,b],["a","a","b"],[]),"report-duplicate-seen"),
   p131u_row(U32.is_eq(index_hash("costarring",2166136261),index_hash("liquid",2166136261)) &&
     p140drc_names([left,right,left,right],[],["costarring","liquid"]),"report-real-hash-collision"),
   p131u_row(p140drc_names([p140drc_def("",False{},False{}),a,p140drc_def("",False{},False{})],[],["","a"]),"report-empty-name"),
   p131u_row(p140drc_names([p140drc_def("λ",False{},False{}),p140drc_def("λ",False{},False{})],[],["λ"]),"report-unicode-name"),
   p131u_row(p140drc_report([]),"report-complete-empty"),
   p131u_row(p140drc_report([a,b]),"report-complete-safe-unsafe"),
   p131u_row(p140drc_report([native_a,a,b,a]),"report-complete-native-shadow"),
   p131u_row(p140drc_report([left,right,left]),"report-complete-collision")]
