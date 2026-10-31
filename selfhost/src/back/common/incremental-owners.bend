

def p140o_absent() -> KTerm:
  KTerm{"Absent","",0,0,[],[],0,0}


@unsafe
def p140o_plain(book: List<&2,KDef>) -> List<&2,KDef>:
  match book:
    case Nil{}: []
    case Con{+d,+rest}:
      nt_choose(List<&2,KDef>,String.eq(dk(d),"BookCache"),u => rest,u => Con{d,rest})


@unsafe
def p140o_header(+d: KDef) -> KDef:
  nt_choose(KDef,p98_tag_eq(dv(d),"Foreign"),u => d,u => declared(d))

# Ordered names, complete types/children, flags and Foreign bodies must match.
# This is deliberately stronger than a public-signature map.

@unsafe
def p140o_headers(left: List<&2,KDef>, right: List<&2,KDef>) -> Bool:
  match left right:
    case Nil{} Nil{}: True{}
    case Con{a,ar} Con{b,br}:
      nt_choose(Bool,f_fresh_prefix_exact_defs([p140o_header(a)],[p140o_header(b)]),
        u => p140o_headers(ar,br),u => False{})
    case _ _: False{}


@unsafe
def p140o_strings(left: List<&2,String>, right: List<&2,String>) -> Bool:
  match left right:
    case Nil{} Nil{}: True{}
    case Con{a,ar} Con{b,br}:
      nt_choose(Bool,String.eq(a,b),u => p140o_strings(ar,br),u => False{})
    case _ _: False{}


@unsafe
def p140o_has(+names: KDef, +name: String) -> Bool:
  String.eq(dk(index_find(names,name,index_hash(name,2166136261),32)),"P140Dirty")


@unsafe
def p140o_mark(+name: String, +dirty: P140ODirty) -> P140ODirty:
  match dirty:
    case P140ODirty{+names,+count}:
      nt_choose(P140ODirty,p140o_has(names,name),u => dirty,
        u => P140ODirty{index_set(names,KDef{name,"P140Dirty",0,0,p140o_absent(),p140o_absent(),[],False{},False{}},index_hash(name,2166136261),32),U32.inc(count)})

# Inspect every term name, not just syntactic Ref nodes. This intentionally
# over-approximates named normalization, ADT and implicit-literal dependencies.

@unsafe
def p140o_terms(todo: List<&2,KTerm>, +acc: List<&2,String>) -> List<&2,String>:
  match todo:
    case Nil{}: acc
    case Con{+term,rest}:
      p140o_terms(nt_append(KTerm,ks(term),rest),
        nt_choose(List<&2,String>,String.is_empty(nm(term)),u => acc,u => Con{nm(term),acc}))


@unsafe
def p140o_refs(defs: List<&2,KDef>, acc: List<&2,String>) -> List<&2,String>:
  match defs:
    case Nil{}: acc
    case Con{+d,rest}:
      p140o_refs(nt_append(KDef,dc(d),rest),p140o_terms([dt(d),dv(d)],acc))


@unsafe
def p140o_edge(+d: KDef) -> P140OEdge:
  P140OEdge{dn(d),p140o_refs([d],["Nat","U32","F32","String","Char","Bool","Word","List"])}


@unsafe
def p140o_edges(defs: List<&2,KDef>) -> List<&2,P140OEdge>:
  match defs:
    case Nil{}: []
    case Con{d,rest}: Con{p140o_edge(d),p140o_edges(rest)}


@unsafe
def p140o_changed(left: List<&2,KDef>, right: List<&2,KDef>, +dirty: P140ODirty) -> P140ODirty:
  match left right:
    case Nil{} Nil{}: dirty
    case Con{+a,ar} Con{+b,br}:
      p140o_changed(ar,br,nt_choose(P140ODirty,f_fresh_prefix_exact_defs([a],[b]),
        u => dirty,u => p140o_mark(dn(a),dirty)))
    case _ _: dirty


@unsafe
def p140o_any(refs: List<&2,String>, +dirty: KDef) -> Bool:
  match refs:
    case Nil{}: False{}
    case Con{name,rest}:
      nt_choose(Bool,p140o_has(dirty,name),u => True{},u => p140o_any(rest,dirty))


@unsafe
def p140o_spread(edges: List<&2,P140OEdge>, +dirty: P140ODirty) -> P140ODirty:
  match edges dirty:
    case Nil{} _: dirty
    case Con{P140OEdge{+name,refs},rest} P140ODirty{+names,count}:
      p140o_spread(rest,nt_choose(P140ODirty,p140o_has(names,name),u => dirty,
        u => nt_choose(P140ODirty,p140o_any(refs,names),v => p140o_mark(name,dirty),v => dirty)))


@unsafe
def p140o_fix(+edges: List<&2,P140OEdge>, +dirty: P140ODirty, +fuel: U32) -> P140ODirty:
  nt_choose(P140ODirty,U32.is_eq(fuel,0),u => dirty,
    u => p140o_fix_step(edges,dirty,p140o_spread(edges,dirty),U32.sub(fuel,1)))


@unsafe
def p140o_fix_step(+edges: List<&2,P140OEdge>, before: P140ODirty, +after: P140ODirty, +fuel: U32) -> P140ODirty:
  match before after:
    case P140ODirty{old,old_count} P140ODirty{names,new_count}:
      nt_choose(P140ODirty,U32.is_eq(old_count,new_count),u => after,u => p140o_fix(edges,after,fuel))


@unsafe
def p140o_refresh(left: List<&2,KDef>, +right: List<&2,KDef>, edges: List<&2,P140OEdge>) -> List<&2,P140OEdge>:
  match left right edges:
    case Nil{} Nil{} Nil{}: []
    case Con{+a,ar} Con{+b,br} Con{+edge,er}:
      Con{nt_choose(P140OEdge,f_fresh_prefix_exact_defs([a],[b]),u => edge,u => p140o_edge(b)),p140o_refresh(ar,br,er)}
    case _ _ _: p140o_edges(right)


@unsafe
def p140o_finish(+edges: List<&2,P140OEdge>, dirty: P140ODirty) -> P140OAnalysis:
  match dirty:
    case P140ODirty{names,count}: P140OAnalysis{True{},names,edges,count}

# The graph is from the old complete successful request. Unchanged owners have
# unchanged outgoing references; propagating through that graph is conservative
# even when changed owners acquire different references in the current request.

@unsafe
def p140o_admitted(+old: List<&2,KDef>, +current: List<&2,KDef>, +edges: List<&2,P140OEdge>) -> P140OAnalysis:
  p140o_delta_finish(edges,U32.inc(nt_count(KDef,current)),
    p140o_delta(old,current,edges,P140ODirty{missing(),0},[]))


@unsafe
def p140o_analyze(+old: List<&2,KDef>, +current: List<&2,KDef>, +edges: List<&2,P140OEdge>) -> P140OAnalysis:
  +a = p140o_plain(old)
  +b = p140o_plain(current)
  nt_choose(P140OAnalysis,Bool.not(List.is_empty(&2,KDef,a)) &&
    U32.is_eq(base_prefix_stamp(old,0),base_prefix_stamp(current,0)) &&
    U32.is_eq(nt_count(KDef,a),nt_count(P140OEdge,edges)) && p140o_headers(a,b),
    u => p140o_guard_adt(b,p140o_admitted(a,b,edges)),u => P140OAnalysis{False{},missing(),p140o_edges(b),0})


@unsafe
def p140o_clean(+analysis: P140OAnalysis, +name: String) -> Bool:
  match analysis:
    case P140OAnalysis{ready,dirty,edges,count}: ready && Bool.not(p140o_has(dirty,name))


@unsafe
def p140o_delta(left: List<&2,KDef>, +right: List<&2,KDef>, edges: List<&2,P140OEdge>,
    +dirty: P140ODirty, +acc: List<&2,P140OEdge>) -> P140ODelta:
  match left right edges:
    case Nil{} Nil{} Nil{}: P140ODelta{nt_reverse(P140OEdge,acc,[]),dirty}
    case Con{+a,ar} Con{+b,br} Con{+edge,er}:
      +same = f_fresh_prefix_exact_defs([a],[b])
      p140o_delta(ar,br,er,
        nt_choose(P140ODirty,same,u => dirty,u => p140o_mark(dn(a),dirty)),
        Con{nt_choose(P140OEdge,same,u => edge,u => p140o_edge(b)),acc})
    case _ _ _:
      P140ODelta{nt_append(P140OEdge,nt_reverse(P140OEdge,acc,[]),p140o_edges(right)),
        p140o_changed(left,right,dirty)}


@unsafe
def p140o_delta_finish(+old_edges: List<&2,P140OEdge>, +fuel: U32, result: P140ODelta) -> P140OAnalysis:
  match result:
    case P140ODelta{edges,dirty}: p140o_finish(edges,p140o_fix(old_edges,dirty,fuel))

# A type-alias BODY can change normalized constructor fields while every source
# header stays identical. Global constructor/layout readers are not purely owner
# local: refuse reuse if any affected owner contains a datatype declaration.

@unsafe
def p140o_contains_adt(defs: List<&2,KDef>) -> Bool:
  match defs:
    case Nil{}: False{}
    case Con{+d,rest}:
      nt_choose(Bool,String.eq(dk(d),"ADT"),u => True{},u => p140o_contains_adt(nt_append(KDef,dc(d),rest)))


@unsafe
def p140o_dirty_adt(defs: List<&2,KDef>, +dirty: KDef) -> Bool:
  match defs:
    case Nil{}: False{}
    case Con{+d,rest}:
      nt_choose(Bool,p140o_has(dirty,dn(d)) && p140o_contains_adt([d]),u => True{},u => p140o_dirty_adt(rest,dirty))


@unsafe
def p140o_guard_adt(book: List<&2,KDef>, analysis: P140OAnalysis) -> P140OAnalysis:
  match analysis:
    case P140OAnalysis{ready,+dirty,edges,count}:
      P140OAnalysis{ready && Bool.not(p140o_dirty_adt(p140o_plain(book),dirty)),dirty,edges,count}


@unsafe
def p140oa_done(defs: List<&2,KDef>, entries: List<&2,P140OAEntry>, hits: U32, misses: U32) -> P140OAResult:
  P140OAResult{nt_reverse(KDef,defs,[]),nt_reverse(P140OAEntry,entries,[]),hits,misses}


@unsafe
def p140oa_apply(+book: List<&2,KDef>, selected: List<&2,KDef>, +stops: List<&2,String>, +analysis: P140OAnalysis,
    previous: List<&2,P140OAEntry>) -> P140OAResult:
  p140oa_walk(book_context(book),selected,stops,analysis,previous,[],[],0,0)


@unsafe
def p140oa_walk(+book: List<&2,KDef>, selected: List<&2,KDef>, +stops: List<&2,String>, +analysis: P140OAnalysis,
    previous: List<&2,P140OAEntry>, defs: List<&2,KDef>, entries: List<&2,P140OAEntry>, hits: U32, misses: U32) -> P140OAResult:
  match selected:
    case Nil{}: p140oa_done(defs,entries,hits,misses)
    case Con{+d,rest}:
      p140oa_old(book,d,rest,stops,analysis,previous,defs,entries,hits,misses,has_name(stops,dn(d)))


@unsafe
def p140oa_old(+book: List<&2,KDef>, +d: KDef, +rest: List<&2,KDef>, +stops: List<&2,String>, +analysis: P140OAnalysis,
    previous: List<&2,P140OAEntry>, +defs: List<&2,KDef>, +entries: List<&2,P140OAEntry>, +hits: U32, +misses: U32, +stopped: Bool) -> P140OAResult:
  match previous:
    case Nil{}: p140oa_fresh(book,d,rest,stops,analysis,[],defs,entries,hits,misses,stopped)
    case Con{P140OAEntry{name,was_stopped,product},+tail}:
      nt_choose(P140OAResult,String.eq(dn(d),name) && Bool.not(Bool.xor(stopped,was_stopped)) && p140o_clean(analysis,dn(d)),
        u => p140oa_record(book,rest,stops,analysis,tail,defs,entries,U32.inc(hits),misses,dn(d),stopped,product),
        u => p140oa_fresh(book,d,rest,stops,analysis,tail,defs,entries,hits,misses,stopped))


@unsafe
def p140oa_fresh(+book: List<&2,KDef>, +d: KDef, rest: List<&2,KDef>, stops: List<&2,String>, analysis: P140OAnalysis,
    previous: List<&2,P140OAEntry>, defs: List<&2,KDef>, entries: List<&2,P140OAEntry>, hits: U32, misses: U32, +stopped: Bool) -> P140OAResult:
  p140oa_record(book,rest,stops,analysis,previous,defs,entries,hits,U32.inc(misses),dn(d),stopped,
    nt_choose(KDef,stopped,u => d,u => ka_def(book,d)))


@unsafe
def p140oa_record(+book: List<&2,KDef>, rest: List<&2,KDef>, stops: List<&2,String>, analysis: P140OAnalysis,
    previous: List<&2,P140OAEntry>, defs: List<&2,KDef>, entries: List<&2,P140OAEntry>, hits: U32, misses: U32,
    name: String, stopped: Bool, +product: KDef) -> P140OAResult:
  p140oa_walk(book,rest,stops,analysis,previous,Con{product,defs},Con{P140OAEntry{name,stopped,product},entries},hits,misses)


@unsafe
def p140oe_apply(+book: List<&2,KDef>, +analysis: P140OAnalysis, previous: List<&2,P140OEEntry>) -> P140OEResult:
  p140oe_walk(book,["main"],[],[],analysis,missing(),previous,[],0,0)


@unsafe
def p140oe_walk(+book: List<&2,KDef>, todo: List<&2,String>, +done: List<&2,String>, +facts: List<&2,KDef>,
    +analysis: P140OAnalysis, +seen: KDef, +previous: List<&2,P140OEEntry>, +entries: List<&2,P140OEEntry>, +hits: U32, +misses: U32) -> P140OEResult:
  match todo:
    case Nil{}: P140OEResult{NR_Closure{done,facts},nt_reverse(P140OEEntry,entries,[]),hits,misses}
    case Con{+name,+rest}:
      nt_choose(P140OEResult,p140o_has(seen,name),
        u => p140oe_walk(book,rest,done,facts,analysis,seen,previous,entries,hits,misses),
        u => p140oe_old(book,name,rest,done,facts,analysis,seen,previous,entries,hits,misses,lookup(book,name)))


@unsafe
def p140oe_old(+book: List<&2,KDef>, +name: String, +todo: List<&2,String>, +done: List<&2,String>, +facts: List<&2,KDef>,
    +analysis: P140OAnalysis, +seen: KDef, previous: List<&2,P140OEEntry>, +entries: List<&2,P140OEEntry>, +hits: U32, +misses: U32, +d: KDef) -> P140OEResult:
  match previous:
    case Nil{}: p140oe_fresh(book,name,todo,done,facts,analysis,seen,[],entries,hits,misses,d)
    case Con{P140OEEntry{old_name,body,arity,refs},+tail}:
      nt_choose(P140OEResult,String.eq(name,old_name) && p140o_clean(analysis,name),
        u => p140oe_record(book,name,todo,done,facts,analysis,seen,tail,entries,U32.inc(hits),misses,d,body,arity,refs),
        u => p140oe_fresh(book,name,todo,done,facts,analysis,seen,tail,entries,hits,misses,d))


@unsafe
def p140oe_regular(+d: KDef) -> Bool:
  String.eq(dk(d),"Def") && Bool.not(nc_native_def(d) || nc_foreign(d))


@unsafe
def p140oe_fresh(+book: List<&2,KDef>, +name: String, todo: List<&2,String>, done: List<&2,String>, facts: List<&2,KDef>,
    analysis: P140OAnalysis, seen: KDef, previous: List<&2,P140OEEntry>, entries: List<&2,P140OEEntry>, hits: U32, misses: U32, +d: KDef) -> P140OEResult:
  +body = nc_definition_plain(book,d,0)
  p140oe_record(book,name,todo,done,facts,analysis,seen,previous,entries,hits,U32.inc(misses),d,
    body,nt_choose(U32,p140oe_regular(d),u => nd_arity_plain(book,name),u => 0),nc_refs(body))


@unsafe
def p140oe_record(+book: List<&2,KDef>, +name: String, todo: List<&2,String>, done: List<&2,String>, +facts: List<&2,KDef>,
    analysis: P140OAnalysis, seen: KDef, previous: List<&2,P140OEEntry>, entries: List<&2,P140OEEntry>, hits: U32, misses: U32,
    +d: KDef, +body: KTerm, +arity: U32, +refs: List<&2,String>) -> P140OEResult:
  +more = nt_choose(List<&2,KDef>,p140oe_regular(d),
    u => Con{KDef{name,"NativeErasedBody",arity,1,p140o_absent(),body,[],False{},False{}},facts},u => facts)
  p140oe_walk(book,nt_append(String,refs,todo),Con{name,done},more,analysis,p140oe_mark(seen,name),previous,
    Con{P140OEEntry{name,body,arity,refs},entries},hits,misses)

# Preserve the original ordered done/fact/queue lists; only membership changes.

@unsafe
def p140oe_mark(seen: KDef, +name: String) -> KDef:
  index_set(seen,KDef{name,"P140Dirty",0,0,p140o_absent(),p140o_absent(),[],False{},False{}},index_hash(name,2166136261),32)


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


@unsafe
def p140oq_record(+name: String, +kind: String, children: List<&2,KDef>) -> KDef:
  KDef{name,kind,0,0,p140o_absent(),p140o_absent(),children,False{},False{}}


@unsafe
def p140oq_user_index(row: KDef) -> KDef:
  match row:
    case KDef{name,kind,arity,templates,typ,value,Con{index,rest},native,unsafe}: index
    case _: missing()

# An owner set deduplicates repeated references. Removal keeps an inactive key;
# only P140Dirty members are traversed. Old relations are not conservatively kept.

@unsafe
def p140oq_set(refs: List<&2,String>, +owner: String, +active: Bool, +index: KDef) -> KDef:
  match refs:
    case Nil{}: index
    case Con{+name,rest}:
      +hash = index_hash(name,2166136261)
      +users = p140oq_user_index(index_find(index,name,hash,32))
      +member = p140oq_record(owner,nt_choose(String,active,u => "P140Dirty",u => "P140QGone"),[])
      p140oq_set(rest,owner,active,index_set(index,
        p140oq_record(name,"P140QUsers",[index_set(users,member,index_hash(owner,2166136261),32)]),hash,32))


@unsafe
def p140oq_refs(refs: List<&2,String>, owner: String, index: KDef) -> KDef:
  p140oq_set(refs,owner,True{},index)


@unsafe
def p140oq_build_go(edges: List<&2,P140OEdge>, index: KDef) -> KDef:
  match edges:
    case Nil{}: index
    case Con{P140OEdge{name,refs},rest}: p140oq_build_go(rest,p140oq_refs(refs,name,index))


@unsafe
def p140oq_build(edges: List<&2,P140OEdge>) -> KDef:
  p140oq_build_go(edges,missing())

# The seed includes dirty names absent from the owner catalogue. Such names can
# still invalidate real owners that reference them; owner-only seeding is wrong.

@unsafe
def p140oq_names(todo: List<&2,KDef>, +acc: List<&2,String>) -> List<&2,String>:
  match todo:
    case Nil{}: acc
    case Con{KIndexLeaf{hash,bucket},rest}: p140oq_names(nt_append(KDef,bucket,rest),acc)
    case Con{KIndexNode{hash,mask,left,right},rest}: p140oq_names(Con{left,Con{right,rest}},acc)
    case Con{KDef{name,kind,arity,templates,typ,value,ctors,native,unsafe},rest}:
      p140oq_names(rest,nt_choose(List<&2,String>,String.eq(kind,"P140Dirty"),u => Con{name,acc},u => acc))


@unsafe
def p140oq_users(users: List<&2,String>, +dirty: P140ODirty, +queue: List<&2,String>) -> P140QPending:
  match users dirty:
    case Nil{} _: P140QPending{dirty,queue}
    case Con{+name,+rest} P140ODirty{names,count}:
      nt_choose(P140QPending,p140o_has(names,name),
        u => p140oq_users(rest,dirty,queue),
        u => p140oq_users(rest,p140o_mark(name,dirty),Con{name,queue}))


@unsafe
def p140oq_walk(+reverse: KDef, queue: List<&2,String>, dirty: P140ODirty) -> P140ODirty:
  match queue:
    case Nil{}: dirty
    case Con{+name,rest}:
      p140oq_pending(reverse,p140oq_users(p140oq_names([p140oq_user_index(index_find(reverse,name,index_hash(name,2166136261),32))],[]),dirty,rest))


@unsafe
def p140oq_pending(reverse: KDef, pending: P140QPending) -> P140ODirty:
  match pending:
    case P140QPending{dirty,queue}: p140oq_walk(reverse,queue,dirty)

# A retained index must belong to this EXACT edge graph and producer. Admission,
# edge removal/update, cache lifetime and acquisition charging are not added here.

@unsafe
def p140oq_with(reverse: KDef, +initial: P140ODirty) -> P140ODirty:
  match initial:
    case P140ODirty{names,count}: p140oq_walk(reverse,p140oq_names([names],[]),initial)


@unsafe
def p140oq_fix(edges: List<&2,P140OEdge>, initial: P140ODirty) -> P140ODirty:
  p140oq_with(p140oq_build(edges),initial)

# The original full admission guard remains exact. Only closure scheduling and
# the duplicated owner comparison are replaced, not dependency semantics.

@unsafe
def p140oq_analyze(+old: List<&2,KDef>, +current: List<&2,KDef>, +edges: List<&2,P140OEdge>, +reverse: KDef) -> P140OAnalysis:
  +a = p140o_plain(old)
  +b = p140o_plain(current)
  nt_choose(P140OAnalysis,Bool.not(List.is_empty(&2,KDef,a)) &&
    U32.is_eq(base_prefix_stamp(old,0),base_prefix_stamp(current,0)) &&
    U32.is_eq(nt_count(KDef,a),nt_count(P140OEdge,edges)) && p140o_headers(a,b),
    u => p140o_guard_adt(b,p140oq_delta(reverse,p140o_delta(a,b,edges,P140ODirty{missing(),0},[]))),
    u => P140OAnalysis{False{},missing(),p140o_edges(b),0})


@unsafe
def p140oq_delta(reverse: KDef, delta: P140ODelta) -> P140OAnalysis:
  match delta:
    case P140ODelta{edges,dirty}: p140o_finish(edges,p140oq_with(reverse,dirty))


@unsafe
def p140oq_refresh(old: List<&2,P140OEdge>, reverse: KDef, analysis: P140OAnalysis) -> KDef:
  match analysis:
    case P140OAnalysis{+ready,dirty,+edges,count}:
      nt_choose(KDef,ready,u => p140oq_update(old,edges,dirty,reverse,edges),u => p140oq_build(edges))

# Admission guarantees equal ordered owner names. Only dirty owners can have a
# changed edge list. Update after closure; closure uses the prior exact graph.

@unsafe
def p140oq_update(old: List<&2,P140OEdge>, current: List<&2,P140OEdge>, +dirty: KDef, +reverse: KDef, +full: List<&2,P140OEdge>) -> KDef:
  match old current:
    case Nil{} Nil{}: reverse
    case Con{P140OEdge{+name,+before},ar} Con{P140OEdge{other,+after},br}:
      p140oq_update(ar,br,dirty,
        nt_choose(KDef,p140o_has(dirty,name),u =>
          nt_choose(KDef,p140o_strings(before,after),v => reverse,
            v => p140oq_set(after,name,True{},p140oq_erase(before,name,full,reverse))),u => reverse),full)
    case _ _: reverse


@unsafe
def p140oq_fact_analysis(+old: List<&2,KDef>, +current: List<&2,KDef>, +names: List<&2,String>, +reverse: KDef, base: P140OAnalysis) -> P140OAnalysis:
  match base:
    case P140OAnalysis{+ready,dirty,+edges,count}:
      nt_choose(P140OAnalysis,ready,
        u => p140o_guard_adt(current,p140o_finish(edges,p140oq_with(reverse,p140or_fact_changes(old,current,names,P140ODirty{dirty,count})))),
        u => P140OAnalysis{False{},dirty,edges,count})

# Duplicate owner rows are legal graph inputs too. Remove a relation only when
# no CURRENT row still supplies it. This scan is paid only for changed ref lists.

@unsafe
def p140oq_referenced(edges: List<&2,P140OEdge>, +owner: String, +reference: String) -> Bool:
  match edges:
    case Nil{}: False{}
    case Con{P140OEdge{name,refs},rest}:
      nt_choose(Bool,String.eq(name,owner) && nb_contains(refs,reference),u => True{},u => p140oq_referenced(rest,owner,reference))


@unsafe
def p140oq_erase(refs: List<&2,String>, +owner: String, +current: List<&2,P140OEdge>, +reverse: KDef) -> KDef:
  match refs:
    case Nil{}: reverse
    case Con{+name,rest}:
      p140oq_erase(rest,owner,current,nt_choose(KDef,p140oq_referenced(current,owner,name),
        u => reverse,u => p140oq_set([name],owner,False{},reverse)))


def p140of_empty() -> P140OFCache:
  P140OFCache{[],[],missing(),[],[]}


def p140or_empty() -> P140ORCache:
  P140ORCache{[],[],missing(),[],[],[],[],[],[],p140sp_empty()}

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
    +previous: P140ORCache, +constructors: List<&2,N_Constructor>) -> P140ORResult:
  match previous:
    case P140ORCache{old,edges,reverse,nodes,old_names,bangs,signatures,generic,private,static}:
      p140or_static(source,names,previous,constructors,p140sp_prepare(book,names,constructors,static))


@unsafe
def p140or_static(source: List<&2,KDef>, names: List<&2,String>, previous: P140ORCache,
    constructors: List<&2,N_Constructor>, result: P140SPResult) -> P140ORResult:
  match result:
    case P140SPResult{prepared,cache,stats}: p140or_prepared(source,names,previous,constructors,cache,stats,prepared)


@unsafe
def p140or_prepared(+source: List<&2,KDef>, +names: List<&2,String>, +previous: P140ORCache,
    +constructors: List<&2,N_Constructor>, +static: P140SPCache, +static_stats: List<&2,U32>, prepared: P112SPrepared) -> P140ORResult:
  match prepared:
    case P112SPrepared{+book,+nodes,+error}:
      nt_choose(P140ORResult,String.is_empty(error),
        u => p140or_context(source,book,nodes,names,nc_bangs_names(book,names),book_cached(nq_signatures(book,names),0),previous,constructors,static,static_stats),
        u => p140or_error(previous,error))


@unsafe
def p140or_context(+source: List<&2,KDef>, +book: List<&2,KDef>, +nodes: List<&2,P112SNode>, +names: List<&2,String>,
    +bangs: List<&2,String>, +signatures: List<&2,KDef>, previous: P140ORCache, constructors: List<&2,N_Constructor>, static: P140SPCache, static_stats: List<&2,U32>) -> P140ORResult:
  match previous:
    case P140ORCache{+old,+edges,+reverse,old_nodes,old_names,old_bangs,old_signatures,generic,private,old_static}:
      +analysis = p140oq_fact_analysis(old,book,names,reverse,p140oq_analyze(old,book,edges,reverse))
      +allowed = p140or_global(old_names,names,old_bangs,bangs,old_signatures,signatures,old_nodes,nodes)
      p140or_compiled(source,book,nodes,names,bangs,signatures,analysis,p140oq_refresh(edges,reverse,analysis),allowed,private,constructors,static,static_stats,
        p140og_apply(book,names,bangs,analysis,allowed,generic))


@unsafe
def p140or_compiled(+source: List<&2,KDef>, +book: List<&2,KDef>, +nodes: List<&2,P112SNode>, +names: List<&2,String>,
    +bangs: List<&2,String>, +signatures: List<&2,KDef>, +analysis: P140OAnalysis, reverse: KDef, +allowed: Bool, previous: List<&2,P140OPEntry>, constructors: List<&2,N_Constructor>, static: P140SPCache, static_stats: List<&2,U32>, result: P140OGResult) -> P140ORResult:
  match result:
    case P140OGResult{compiled,entries,gh,gm}:
      p140or_candidates(book,nodes,names,bangs,signatures,analysis,reverse,allowed,entries,gh,gm,static,static_stats,
        p112s_finish(nodes,p140or_finish(source,names,constructors,compiled)),p140op_apply(book,names,bangs,signatures,analysis,allowed,previous))


@unsafe
def p140or_candidates(book: List<&2,KDef>, nodes: List<&2,P112SNode>, names: List<&2,String>, bangs: List<&2,String>, signatures: List<&2,KDef>,
    analysis: P140OAnalysis, reverse: KDef, allowed: Bool, generic: List<&2,P140OGEntry>, gh: U32, gm: U32, static: P140SPCache, static_stats: List<&2,U32>, original: P112SResult, result: P140OPResult) -> P140ORResult:
  match analysis result:
    case P140OAnalysis{ready,dirty,edges,count} P140OPResult{candidates,entries,ph,pm}:
      P140ORResult{p128raw_plan_finish(original,candidates),P140ORCache{book,edges,reverse,nodes,names,bangs,signatures,generic,entries,static},
        nt_append(U32,[gh,gm,ph,pm,count,Bool.to_u32(ready),Bool.to_u32(allowed)],static_stats)}

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


@unsafe
def p140o_controls() -> List<&2,String>:
  +old = p140oc_book(1,8)
  +same = p140oc_analysis(old,p140oc_book(1,8))
  +leaf = p140oc_analysis(old,p140oc_book(2,8))
  +other = p140oc_analysis(old,p140oc_book(1,9))
  +cycle = p140oc_analysis(p140oc_cycle(1),p140oc_cycle(2))
  +foreign_a = book_cached([p140oc_def("foreign",kt("Foreign","c",0,0,[]))],40)
  +foreign_b = book_cached([p140oc_def("foreign",kt("Foreign","other",0,0,[]))],40)
  +header_a = book_cached([p140oc_def("head",ref("leaf"))],40)
  +header_b = book_cached([KDef{"head","Def",1,0,kt("ADT","U32",0,0,[]),ref("leaf"),[],False{},False{}}],40)
  [p140oc_row("no-op-zero-dirty",p140oc_count(same,0)),
   p140oc_row("unchanged-owner-admitted",p140o_clean(same,"main")),
   p140oc_row("changed-leaf-three-dirty",p140oc_count(leaf,3)),
   p140oc_row("transitive-caller-invalidated",Bool.not(p140o_clean(leaf,"main"))),
   p140oc_row("unrelated-owner-remains-clean",p140o_clean(leaf,"unused")),
   p140oc_row("irrelevant-edit-retains-main",p140oc_count(other,1) && p140o_clean(other,"main")),
   p140oc_row("cycle-propagates-to-fixed-point",p140oc_count(cycle,3) && p140o_clean(cycle,"other")),
   p140oc_row("new-edge-retained-for-next-revision",p140oc_refresh()),
   p140oc_row("different-bound-refused",Bool.not(p140oc_ready(p140oc_analysis(old,book_cached(p140o_plain(old),41))))),
   p140oc_row("changed-header-refused",Bool.not(p140oc_ready(p140oc_analysis(header_a,header_b)))),
   p140oc_row("foreign-body-refused",Bool.not(p140oc_ready(p140oc_analysis(foreign_a,foreign_b)))),
   p140oc_row("inserted-name-refused",Bool.not(p140oc_ready(p140oc_analysis(old,book_cached(Con{p140oc_def("new",ref("main")),p140o_plain(old)},40))))),
   p140oc_row("missing-graph-refused",Bool.not(p140oc_ready(p140o_analyze(old,old,[])))),
   p140oc_row("empty-cache-falls-back",Bool.not(p140oc_ready(p140o_analyze([],old,[])))),
   p140oc_row("static-word-change-refused",Bool.not(p140or_words([P112SRaw{1}],[P112SRaw{2}]))),
   p140oc_row("static-offset-change-refused",Bool.not(p140or_words([P112SBox{"SCon",4}],[P112SBox{"SCon",6}]))),
   p140oc_row("static-kind-change-refused",Bool.not(p140or_words([P112SPacked{"One",4}],[P112SBox{"One",4}]))),
   p140oc_row("same-static-nodes-admitted",p140or_nodes([P112SNode{0,"Pair",[P112SRaw{1},P112SRaw{2}]}],[P112SNode{0,"Pair",[P112SRaw{1},P112SRaw{2}]}]))]


@unsafe
def p140oq_controls() -> List<&2,String>:
  [p140oc_row("reverse-4096-three-node-closures",p140qc_graphs(0)),
   p140oc_row("reverse-duplicate-edges-and-owners",p140qc_case([P140OEdge{"a",["b","b"]},P140OEdge{"a",["c"]},P140OEdge{"b",["a"]}],["c"])),
   p140oc_row("reverse-dirty-unknown-dependency",p140qc_case([P140OEdge{"a",["unknown"]},P140OEdge{"b",["a"]}],["unknown"])),
   p140oc_row("reverse-unrelated-unknown-preserved",p140qc_case([P140OEdge{"a",["b"]}],["elsewhere"])),
   p140oc_row("reverse-empty-string-reference",p140qc_case([P140OEdge{"a",[""]}],[""])),
   p140oc_row("reverse-empty-graph-preserves-seed",p140qc_case([],["a","unknown"])),
   p140oc_row("reverse-real-hash-collision",U32.is_eq(index_hash("costarring",2166136261),index_hash("liquid",2166136261)) &&
     p140qc_case([P140OEdge{"a",["costarring"]},P140OEdge{"b",["liquid"]},P140OEdge{"c",["a"]}],["liquid"])),
   p140oc_row("reverse-collision-does-not-alias",p140qc_no_alias(p140oq_fix([P140OEdge{"a",["costarring"]},P140OEdge{"b",["liquid"]}],p140qc_seed(["liquid"],P140ODirty{missing(),0}))))]
