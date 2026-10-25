# Exact v03 reference. This stays test-only; original semantic producers and
# the v03 file remain unchanged. Compare every P140OAnalysis field, including
# actual Patricia node shape/hashes and ordered refreshed edge lists.
@unsafe
def p140od_admitted_old(+old: List<&2,KDef>, +current: List<&2,KDef>, +edges: List<&2,P140OEdge>) -> P140OAnalysis:
  p140o_finish(p140o_refresh(old,current,edges),
    p140o_fix(edges,p140o_changed(old,current,P140ODirty{missing(),0}),U32.inc(nt_count(KDef,current))))

@unsafe
def p140od_analyze_old(+old: List<&2,KDef>, +current: List<&2,KDef>, +edges: List<&2,P140OEdge>) -> P140OAnalysis:
  +a = p140o_plain(old)
  +b = p140o_plain(current)
  nt_choose(P140OAnalysis,Bool.not(List.is_empty(&2,KDef,a)) &&
    U32.is_eq(base_prefix_stamp(old,0),base_prefix_stamp(current,0)) &&
    U32.is_eq(nt_count(KDef,a),nt_count(P140OEdge,edges)) && p140o_headers(a,b),
    u => p140od_admitted_old(a,b,edges),u => P140OAnalysis{False{},missing(),p140o_edges(b),0})

@unsafe
def p140od_index(+a: KDef, +b: KDef) -> Bool:
  match a b:
    case KDef{an,ak,aa,ax,at,av,ac,ab,au} KDef{bn,bk,ba,bx,bt,bv,bc,bb,bu}:
      f_fresh_prefix_exact_defs([a],[b])
    case KIndexLeaf{ah,ad} KIndexLeaf{bh,bd}:
      U32.is_eq(ah,bh) && f_fresh_prefix_exact_defs(ad,bd)
    case KIndexNode{ah,am,al,ar} KIndexNode{bh,bm,bl,br}:
      U32.is_eq(ah,bh) && U32.is_eq(am,bm) && p140od_index(al,bl) && p140od_index(ar,br)
    case _ _: False{}

@unsafe
def p140od_edges(left: List<&2,P140OEdge>, right: List<&2,P140OEdge>) -> Bool:
  match left right:
    case Nil{} Nil{}: True{}
    case Con{P140OEdge{an,ar},at} Con{P140OEdge{bn,br},bt}:
      String.eq(an,bn) && p140o_strings(ar,br) && p140od_edges(at,bt)
    case _ _: False{}

@unsafe
def p140od_equal(left: P140OAnalysis, right: P140OAnalysis) -> Bool:
  match left right:
    case P140OAnalysis{ar,ad,ae,ac} P140OAnalysis{br,bd,be,bc}:
      Bool.not(Bool.xor(ar,br)) && U32.is_eq(ac,bc) && p140od_index(ad,bd) && p140od_edges(ae,be)

@unsafe
def p140od_same(+old: List<&2,KDef>, +current: List<&2,KDef>, +edges: List<&2,P140OEdge>) -> Bool:
  p140od_equal(p140od_analyze_old(old,current,edges),p140o_analyze(old,current,edges))

@unsafe
def p140od_case(+old: List<&2,KDef>, current: List<&2,KDef>) -> Bool:
  p140od_same(old,current,p140o_edges(p140o_plain(old)))

@unsafe
def p140od_chain(+a: List<&2,KDef>, +b: List<&2,KDef>, +c: List<&2,KDef>) -> Bool:
  +edges = p140o_edges(p140o_plain(a))
  p140od_chain_step(b,c,p140od_analyze_old(a,b,edges),p140o_analyze(a,b,edges))

@unsafe
def p140od_chain_step(+b: List<&2,KDef>, +c: List<&2,KDef>, before: P140OAnalysis, after: P140OAnalysis) -> Bool:
  match before after:
    case P140OAnalysis{ar,ad,ae,ac} P140OAnalysis{br,bd,be,bc}:
      p140od_equal(p140od_analyze_old(b,c,ae),p140o_analyze(b,c,be))

@unsafe
def p140od_controls() -> List<&2,String>:
  +old = p140oc_book(1,8)
  +foreign_a = book_cached([p140oc_def("foreign",kt("Foreign","c",0,0,[]))],40)
  +foreign_b = book_cached([p140oc_def("foreign",kt("Foreign","other",0,0,[]))],40)
  +header_a = book_cached([p140oc_def("head",ref("leaf"))],40)
  +header_b = book_cached([KDef{"head","Def",1,0,kt("ADT","U32",0,0,[]),ref("leaf"),[],False{},False{}}],40)
  [p140oc_row("delta-exact-noop",p140od_case(old,old)),
   p140oc_row("delta-exact-transitive-leaf",p140od_case(old,p140oc_book(2,8))),
   p140oc_row("delta-exact-independent-leaf",p140od_case(old,p140oc_book(1,9))),
   p140oc_row("delta-exact-multiple-edits",p140od_case(old,p140oc_book(2,9))),
   p140oc_row("delta-exact-cycle",p140od_case(p140oc_cycle(1),p140oc_cycle(2))),
   p140oc_row("delta-exact-new-edge",p140od_case(p140oc_change_edge("unused",1),p140oc_change_edge("leaf",1))),
   p140oc_row("delta-exact-next-revision",p140od_chain(p140oc_change_edge("unused",1),p140oc_change_edge("leaf",1),p140oc_change_edge("leaf",2))),
   p140oc_row("delta-exact-bound-refusal",p140od_case(old,book_cached(p140o_plain(old),41))),
   p140oc_row("delta-exact-header-refusal",p140od_case(header_a,header_b)),
   p140oc_row("delta-exact-foreign-refusal",p140od_case(foreign_a,foreign_b)),
   p140oc_row("delta-exact-insert-refusal",p140od_case(old,book_cached(Con{p140oc_def("new",ref("main")),p140o_plain(old)},40))),
   p140oc_row("delta-exact-missing-graph",p140od_same(old,old,[])),
   p140oc_row("delta-exact-empty-cache",p140od_same([],old,[]))]
