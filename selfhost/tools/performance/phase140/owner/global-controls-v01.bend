# Data-only countermodel: same exact headers, editable alias body, unchanged
# independent main. This tests conservative refusal, not a checked-source bug.
@unsafe
def p140gc_book(target: String) -> List<&2,KDef>:
  book_cached([
    p140oc_def("main",KLiteral{"U32",0,"",0,0}),
    KDef{"Alias","Def",0,0,atom("Data"),kt("ADT",target,0,0,[]),[],False{},False{}},
    KDef{"Hidden","ADT",0,0,atom("Data"),atom("Absent"),
      [KDef{"Hidden0","Ctr",1,0,kt("All","field",1,1,[ref("Alias"),kt("ADT","Hidden",0,0,[])]),atom("Absent"),[],False{},False{}}],False{},False{}}],40)

@unsafe
def p140gc_preserved(analysis: P140OAnalysis) -> Bool:
  match analysis:
    case P140OAnalysis{ready,+dirty,edges,count}:
      Bool.not(ready) && U32.is_eq(count,2) && p140o_has(dirty,"Alias") && p140o_has(dirty,"Hidden") && Bool.not(p140o_has(dirty,"main"))

@unsafe
def p140gc_controls() -> List<&2,String>:
  +a = p140gc_book("U32")
  +b = p140gc_book("F32")
  +edges = p140o_edges(p140o_plain(a))
  +reverse = p140oq_build(edges)
  +analysis = p140oq_analyze(a,b,edges,reverse)
  [p140oc_row("global-alias-identical-declaration-headers",p140o_headers(p140o_plain(a),p140o_plain(b))),
   p140oc_row("global-alias-dirty-ADT-refuses-core",p140gc_preserved(p140o_analyze(a,b,edges))),
   p140oc_row("global-alias-dirty-ADT-refuses-reverse",p140gc_preserved(analysis)),
   p140oc_row("global-alias-independent-main-misses",Bool.not(p140o_clean(analysis,"main"))),
   p140oc_row("global-alias-fact-refusal-retains-diagnostics",p140gc_preserved(p140oq_fact_analysis(a,b,["main","Alias","Hidden"],reverse,analysis))),
   p140oc_row("global-alias-refusal-refreshes-current-graph",p140qc_equal(
     p140oq_with(p140oq_refresh(edges,reverse,analysis),p140qc_seed(["F32"],P140ODirty{missing(),0})),
     p140o_fix(p140o_edges(p140o_plain(b)),p140qc_seed(["F32"],P140ODirty{missing(),0}),4))),
   p140oc_row("global-numeric-edit-remains-admitted",p140oc_ready(p140oq_analyze(p140oc_book(1,8),p140oc_book(2,8),p140o_edges(p140o_plain(p140oc_book(1,8))),p140oq_build(p140o_edges(p140o_plain(p140oc_book(1,8)))))))]
