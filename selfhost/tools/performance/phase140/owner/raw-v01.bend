# Same-producer raw owner products. All callers must first compare the actual
# prepared static image, ordered names/bangs and complete NQ signature context.
# Generic fragments additionally require their original incoming fresh counter.
type P140OGEntry is Data:
  P140OGEntry{+name: String, +input: U32, +code: P111Code}

type P140OGResult is Data:
  P140OGResult{+compiled: P111Book, +entries: List<&2,P140OGEntry>, +hits: U32, +misses: U32}

type P140OPEntry is Data:
  P140OPEntry{+name: String, +candidates: List<&2,P113DCandidate>}

type P140OPResult is Data:
  P140OPResult{+candidates: List<&2,P113DCandidate>, +entries: List<&2,P140OPEntry>, +hits: U32, +misses: U32}

@unsafe
def p140or_words(left: List<&2,P112SWord>, right: List<&2,P112SWord>) -> Bool:
  match left right:
    case Nil{} Nil{}: True{}
    case Con{a,ar} Con{b,br}:
      nt_choose(Bool,p140or_word(a,b),u => p140or_words(ar,br),u => False{})
    case _ _: False{}

@unsafe
def p140or_word(left: P112SWord, right: P112SWord) -> Bool:
  match left right:
    case P112SRaw{a} P112SRaw{b}: U32.is_eq(a,b)
    case P112SPacked{a,av} P112SPacked{b,bv}: String.eq(a,b) && U32.is_eq(av,bv)
    case P112SBox{a,av} P112SBox{b,bv}: String.eq(a,b) && U32.is_eq(av,bv)
    case _ _: False{}

@unsafe
def p140or_nodes(left: List<&2,P112SNode>, right: List<&2,P112SNode>) -> Bool:
  match left right:
    case Nil{} Nil{}: True{}
    case Con{P112SNode{offset,name,fields},ar} Con{P112SNode{other,other_name,other_fields},br}:
      nt_choose(Bool,U32.is_eq(offset,other) && String.eq(name,other_name) && p140or_words(fields,other_fields),
        u => p140or_nodes(ar,br),u => False{})
    case _ _: False{}

@unsafe
def p140or_global(+old_names: List<&2,String>, +names: List<&2,String>, +old_bangs: List<&2,String>, +bangs: List<&2,String>,
    +old_signatures: List<&2,KDef>, +signatures: List<&2,KDef>, +old_nodes: List<&2,P112SNode>, +nodes: List<&2,P112SNode>) -> Bool:
  p140o_strings(old_names,names) && p140o_strings(old_bangs,bangs) &&
    f_fresh_prefix_exact_defs(p140o_plain(old_signatures),p140o_plain(signatures)) && p140or_nodes(old_nodes,nodes)

# Generated erased/static facts are inputs too; source KDef equality alone does
# not prove their equality. Propagate their changes through the same old graph.
@unsafe
def p140or_fact_changes(+old: List<&2,KDef>, +current: List<&2,KDef>, names: List<&2,String>, +dirty: P140ODirty) -> P140ODirty:
  match names:
    case Nil{}: dirty
    case Con{+name,rest}:
      p140or_fact_changes(old,current,rest,nt_choose(P140ODirty,
        f_fresh_prefix_exact_defs([ns_body(old,name)],[ns_body(current,name)]),
        u => dirty,u => p140o_mark(name,dirty)))

@unsafe
def p140or_analysis(+old: List<&2,KDef>, +current: List<&2,KDef>, +names: List<&2,String>, +old_edges: List<&2,P140OEdge>, base: P140OAnalysis) -> P140OAnalysis:
  match base:
    case P140OAnalysis{+ready,dirty,+edges,count}:
      nt_choose(P140OAnalysis,ready,
        u => p140o_finish(edges,p140o_fix(old_edges,p140or_fact_changes(old,current,names,P140ODirty{dirty,count}),U32.inc(nt_count(P140OEdge,old_edges)))),
        u => P140OAnalysis{False{},missing(),edges,0})

@unsafe
def p140og_apply(+book: List<&2,KDef>, names: List<&2,String>, +bangs: List<&2,String>, +analysis: P140OAnalysis,
    +allowed: Bool, previous: List<&2,P140OGEntry>) -> P140OGResult:
  p140og_walk(book,names,bangs,analysis,allowed,previous,0,[],[],0,0)

@unsafe
def p140og_walk(+book: List<&2,KDef>, names: List<&2,String>, +bangs: List<&2,String>, +analysis: P140OAnalysis,
    +allowed: Bool, +previous: List<&2,P140OGEntry>, +n: U32, +segments: List<&2,N111Segment>, +entries: List<&2,P140OGEntry>, +hits: U32, +misses: U32) -> P140OGResult:
  match names:
    case Nil{}: P140OGResult{P111Book{nt_reverse(N111Segment,segments,[]),n,""},nt_reverse(P140OGEntry,entries,[]),hits,misses}
    case Con{+name,+rest}:
      +d = lookup(book,name)
      nt_choose(P140OGResult,String.eq(dk(d),"Absent"),
        u => P140OGResult{P111Book{[],n,"native definition not found: " ++ name_key(name)},[],hits,misses},
        u => p140og_old(book,name,rest,bangs,analysis,allowed,previous,n,segments,entries,hits,misses,d))

@unsafe
def p140og_old(+book: List<&2,KDef>, +name: String, +rest: List<&2,String>, +bangs: List<&2,String>, +analysis: P140OAnalysis,
    +allowed: Bool, previous: List<&2,P140OGEntry>, +n: U32, +segments: List<&2,N111Segment>, +entries: List<&2,P140OGEntry>, +hits: U32, +misses: U32, +d: KDef) -> P140OGResult:
  match previous:
    case Nil{}: p140og_fresh(book,name,rest,bangs,analysis,allowed,[],n,segments,entries,hits,misses,d)
    case Con{P140OGEntry{old_name,input,code},+tail}:
      nt_choose(P140OGResult,allowed && String.eq(name,old_name) && U32.is_eq(n,input) && p140o_clean(analysis,name),
        u => p140og_record(book,name,rest,bangs,analysis,allowed,tail,n,segments,entries,U32.inc(hits),misses,code),
        u => p140og_fresh(book,name,rest,bangs,analysis,allowed,tail,n,segments,entries,hits,misses,d))

@unsafe
def p140og_fresh(+book: List<&2,KDef>, +name: String, rest: List<&2,String>, +bangs: List<&2,String>, analysis: P140OAnalysis,
    allowed: Bool, previous: List<&2,P140OGEntry>, +n: U32, segments: List<&2,N111Segment>, entries: List<&2,P140OGEntry>, hits: U32, misses: U32, d: KDef) -> P140OGResult:
  p140og_record(book,name,rest,bangs,analysis,allowed,previous,n,segments,entries,hits,U32.inc(misses),
    p111_entry(book,nc_compact_definition(book,d,n),name,U32.add(n,1024),nb_contains(bangs,name)))

@unsafe
def p140og_record(+book: List<&2,KDef>, +name: String, +rest: List<&2,String>, +bangs: List<&2,String>, +analysis: P140OAnalysis,
    +allowed: Bool, +previous: List<&2,P140OGEntry>, +input: U32, +acc: List<&2,N111Segment>, +entries: List<&2,P140OGEntry>, +hits: U32, +misses: U32, +code: P111Code) -> P140OGResult:
  match code:
    case P111Code{+body,+segments,+fresh,+error}:
      nt_choose(P140OGResult,String.eq(error,""),
        u => p140og_walk(book,rest,bangs,analysis,allowed,previous,fresh,
          nt_reverse(N111Segment,p111_mark_segments(Con{p111_segment(nc_ref_name(book,name),[],0,0,body),segments},nb_contains(bangs,name)),acc),
          Con{P140OGEntry{name,input,code},entries},hits,misses),
        u => P140OGResult{P111Book{[],fresh,error},[],hits,misses})

@unsafe
def p140op_apply(+book: List<&2,KDef>, names: List<&2,String>, +bangs: List<&2,String>, +signatures: List<&2,KDef>,
    +analysis: P140OAnalysis, +allowed: Bool, previous: List<&2,P140OPEntry>) -> P140OPResult:
  p140op_walk(book,names,bangs,signatures,analysis,allowed,previous,[],[],0,0)

@unsafe
def p140op_walk(+book: List<&2,KDef>, names: List<&2,String>, +bangs: List<&2,String>, +signatures: List<&2,KDef>,
    +analysis: P140OAnalysis, +allowed: Bool, previous: List<&2,P140OPEntry>, candidates: List<&2,P113DCandidate>, entries: List<&2,P140OPEntry>, hits: U32, misses: U32) -> P140OPResult:
  match names:
    case Nil{}: P140OPResult{nt_reverse(P113DCandidate,candidates,[]),nt_reverse(P140OPEntry,entries,[]),hits,misses}
    case Con{name,rest}: p140op_old(book,name,rest,bangs,signatures,analysis,allowed,previous,candidates,entries,hits,misses)

@unsafe
def p140op_old(+book: List<&2,KDef>, +name: String, +rest: List<&2,String>, +bangs: List<&2,String>, +signatures: List<&2,KDef>,
    +analysis: P140OAnalysis, +allowed: Bool, previous: List<&2,P140OPEntry>, +candidates: List<&2,P113DCandidate>, +entries: List<&2,P140OPEntry>, +hits: U32, +misses: U32) -> P140OPResult:
  match previous:
    case Nil{}: p140op_fresh(book,name,rest,bangs,signatures,analysis,allowed,[],candidates,entries,hits,misses)
    case Con{P140OPEntry{old_name,product},+tail}:
      nt_choose(P140OPResult,allowed && String.eq(name,old_name) && p140o_clean(analysis,name),
        u => p140op_record(book,name,rest,bangs,signatures,analysis,allowed,tail,candidates,entries,U32.inc(hits),misses,product),
        u => p140op_fresh(book,name,rest,bangs,signatures,analysis,allowed,tail,candidates,entries,hits,misses))

@unsafe
def p140op_fresh(+book: List<&2,KDef>, +name: String, rest: List<&2,String>, +bangs: List<&2,String>, +signatures: List<&2,KDef>,
    analysis: P140OAnalysis, allowed: Bool, previous: List<&2,P140OPEntry>, candidates: List<&2,P113DCandidate>, entries: List<&2,P140OPEntry>, hits: U32, misses: U32) -> P140OPResult:
  p140op_record(book,name,rest,bangs,signatures,analysis,allowed,previous,candidates,entries,hits,U32.inc(misses),
    p113pl_candidates(book,[name],bangs,signatures))

@unsafe
def p140op_record(+book: List<&2,KDef>, name: String, rest: List<&2,String>, bangs: List<&2,String>, signatures: List<&2,KDef>,
    analysis: P140OAnalysis, allowed: Bool, previous: List<&2,P140OPEntry>, candidates: List<&2,P113DCandidate>, entries: List<&2,P140OPEntry>, hits: U32, misses: U32,
    +product: List<&2,P113DCandidate>) -> P140OPResult:
  p140op_walk(book,rest,bangs,signatures,analysis,allowed,previous,nt_reverse(P113DCandidate,product,candidates),
    Con{P140OPEntry{name,product},entries},hits,misses)
