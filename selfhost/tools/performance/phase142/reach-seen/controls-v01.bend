# Independent exact ordered-list and reached-definition controls. The original
# kr_visit/reach_book remain the oracle; fixtures are constructed graph inputs.
def p142rt_absent() -> KTerm:
  KTerm{"Absent","",0,0,[],[],0,0}

def p142rt_ref(name: String) -> KTerm:
  KTerm{"Ref",name,0,1,[],[],0,0}

def p142rt_def(name: String, kind: String, typ: KTerm, value: KTerm, children: List<&2,KDef>) -> KDef:
  KDef{name,kind,0,0,typ,value,children,False{},False{}}

def p142rt_leaf(name: String) -> KDef:
  p142rt_def(name,"Def",p142rt_absent(),p142rt_absent(),[])

def p142rt_edge(name: String, target: String) -> KDef:
  p142rt_def(name,"Def",p142rt_absent(),p142rt_ref(target),[])

def p142rt_child(name: String) -> KDef:
  p142rt_def(name,"Ctr",p142rt_absent(),p142rt_ref("ignored-child-value"),[])

@unsafe
def p142rt_names(+book: List<&2,KDef>, +todo: List<&2,String>, +seen: List<&2,String>, +stops: List<&2,String>, expected: List<&2,String>) -> Bool:
  +old = kr_visit(book,todo,seen,stops)
  norm_exact_names(old,expected) && norm_exact_names(old,p142r_kr_visit(book,todo,seen,stops))

@unsafe
def p142rt_reached(+book: List<&2,KDef>, +roots: List<&2,String>, +stops: List<&2,String>, expected: List<&2,KDef>) -> Bool:
  +old = reach_book(book,roots,stops)
  p140p_defs(old,expected) && p140p_defs(old,p142r_reach(book,roots,stops))

@unsafe
def p142rt_controls() -> List<&2,String>:
  +leaf = p142rt_leaf("leaf")
  +parent = p142rt_def("P","ADT",p142rt_absent(),p142rt_absent(),[p142rt_child("C"),p142rt_child("D")])
  +other = p142rt_def("Q","ADT",p142rt_absent(),p142rt_absent(),[p142rt_child("C")])
  +deps = p142rt_def("P","ADT",p142rt_ref("T"),p142rt_ref("V"),
    [p142rt_def("C","Ctr",p142rt_ref("U"),p142rt_ref("ignored-child-value"),[])])
  +cycle : List<&2,KDef> = [p142rt_edge("a","b"),p142rt_edge("b","a")]
  +collision : List<&2,KDef> = [p142rt_edge("costarring","left"),p142rt_edge("liquid","right")]
  +shadow = p142rt_leaf("C")
  +false_child = p142rt_def("Odd","ADT",p142rt_absent(),p142rt_absent(),[p142rt_leaf("not-a-Ctr")])
  +qualified = p142rt_def("module.P","ADT",p142rt_absent(),p142rt_absent(),[p142rt_child("module.C")])
  +duplicate_first = p142rt_edge("a","first")
  +duplicate_second = p142rt_edge("a","second")
  [p114st_row("reach-index-empty-keeps-initial-duplicates",p142rt_names([],[],["seed","seed"],[],["seed","seed"])),
   p114st_row("reach-index-missing-name-once",p142rt_names([],["missing","missing"],[],[],["missing"])),
   p114st_row("reach-index-query-and-resolved-duplicate",p142rt_names([leaf],["leaf","leaf"],[],[],["leaf","leaf"])),
   p114st_row("reach-index-initial-seen-list-exact",p142rt_names([leaf],["leaf"],["leaf","z","leaf"],[],["leaf","z","leaf"])),
   p114st_row("reach-index-self-cycle",p142rt_names([p142rt_edge("a","a")],["a"],[],[],["a","a"])),
   p114st_row("reach-index-mutual-cycle",p142rt_names(cycle,["a"],[],[],["b","b","a","a"])),
   p114st_row("reach-index-constructor-resolves-parent",p142rt_names([parent],["C"],[],[],["P","C"])),
   p114st_row("reach-index-repeated-parent-cons-preserved",p142rt_names([parent],["C","D"],[],[],["P","D","P","C"])),
   p114st_row("reach-index-already-seen-parent-not-skipped",p142rt_names([parent],["C"],["P"],[],["P","C","P"])),
   p114st_row("reach-index-direct-parent-then-constructor",p142rt_names([parent],["P","C"],[],[],["P","C","P","P"])),
   p114st_row("reach-index-parent-type-ctor-body-order",p142rt_names([deps],["C"],[],[],["V","U","T","P","C"])),
   p114st_row("reach-index-stop-parent-body-only",p142rt_names([deps],["C"],[],["P"],["U","T","P","C"])),
   p114st_row("reach-index-stop-query-not-parent",p142rt_names([deps],["C"],[],["C"],["V","U","T","P","C"])),
   p114st_row("reach-index-first-parent-selected",p142rt_names([parent,other],["C"],[],[],["P","C"])),
   p114st_row("reach-index-parent-order-observable",p142rt_names([other,parent],["C"],[],[],["Q","C"])),
   p114st_row("reach-index-top-level-shadows-parent",p142rt_names([parent,shadow],["C"],[],[],["C","C"])),
   p114st_row("reach-index-parent-lookup-not-Ctr-filter",p142rt_names([false_child],["not-a-Ctr"],[],[],["Odd","not-a-Ctr"])),
   p114st_row("reach-index-real-hash-collision",U32.is_eq(index_hash("costarring",2166136261),index_hash("liquid",2166136261)) && p142rt_names(collision,["costarring","liquid"],[],[],["right","liquid","liquid","left","costarring","costarring"])),
   p114st_row("reach-index-collision-initial-seen-distinct",p142rt_names(collision,["liquid"],["costarring"],[],["right","liquid","liquid","costarring"])),
   p114st_row("reach-index-qualified-constructor-exact",p142rt_names([qualified],["C","module.C"],[],[],["module.P","module.C","C"])),
   p114st_row("reach-index-empty-and-Absent-names",p142rt_names([],["","Absent",""],[],[],["Absent",""])),
   p114st_row("reach-index-layout-marker-is-ordinary-name",p142rt_names([],["$layout.open-array"],[],[],["$layout.open-array"])),
   p114st_row("reach-index-unicode-names",p142rt_names([],["商","𐀀","商"],[],[],["𐀀","商"])),
   p114st_row("reach-index-cached-book-parent-resolution",p142rt_names(book_cached([parent],0),["C"],[],[],["P","C"])),
   p114st_row("reach-index-duplicate-definitions-first-match",p142rt_names([duplicate_first,duplicate_second],["a"],[],[],["first","a","a"])),
   p114st_row("reach-index-filter-preserves-book-order",p142rt_reached([other,leaf,parent],["C","leaf"],[],[other,leaf])),
   p114st_row("reach-index-filter-retains-duplicate-records",p142rt_reached([duplicate_first,leaf,duplicate_second],["a"],[],[duplicate_first,duplicate_second])),
   p114st_row("reach-index-filter-constructor-keeps-whole-parent",p142rt_reached([leaf,parent],["C"],[],[parent]))]
