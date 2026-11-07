# Expected outputs are complete retained definition records in literal order.
# Host comparison includes every term variant, metadata field and child.
type P177ReachCase is Data:
  P177ReachCase{+name: String, +book: List<&2,KDef>, +roots: List<&2,String>,
    +stops: List<&2,String>, +expected: List<&2,KDef>}

def p177rv_absent() -> KTerm:
  KTerm{"Absent","",0,0,[],[],0,0}

def p177rv_ref(name: String) -> KTerm:
  KTerm{"Ref",name,0,1,[],[],11,12}

def p177rv_def(name: String, kind: String, typ: KTerm, value: KTerm, children: List<&2,KDef>) -> KDef:
  KDef{name,kind,0,0,typ,value,children,False{},False{}}

def p177rv_leaf(name: String) -> KDef:
  p177rv_def(name,"Def",p177rv_absent(),p177rv_absent(),[])

def p177rv_edge(name: String, target: String) -> KDef:
  p177rv_def(name,"Def",p177rv_absent(),p177rv_ref(target),[])

def p177rv_child(name: String) -> KDef:
  p177rv_def(name,"Ctr",p177rv_absent(),p177rv_ref("ignored-child-value"),[])

# This original composition does not call the replaced reach_book entry.
@unsafe
def p177rv_original(+book: List<&2,KDef>, +roots: List<&2,String>, +stops: List<&2,String>) -> List<&2,KDef>:
  kr_filter(book,kr_visit(book,roots,[],stops))

@unsafe
def p177rv_cases() -> List<&2,P177ReachCase>:
  +a = p177rv_leaf("a")
  +b = p177rv_leaf("b")
  +first = p177rv_edge("a","first")
  +second = p177rv_edge("a","second")
  +first_target = p177rv_leaf("first")
  +second_target = p177rv_leaf("second")
  +parent = p177rv_def("P","ADT",p177rv_absent(),p177rv_absent(),[p177rv_child("C"),p177rv_child("D")])
  +other = p177rv_def("Q","ADT",p177rv_absent(),p177rv_absent(),[p177rv_child("C")])
  +shadow = p177rv_leaf("C")
  +type_dep = p177rv_leaf("T")
  +ctor_dep = p177rv_leaf("U")
  +value_dep = p177rv_leaf("V")
  +ignored = p177rv_leaf("ignored-child-value")
  +deps = p177rv_def("P","ADT",p177rv_ref("T"),p177rv_ref("V"),
    [p177rv_def("C","Ctr",p177rv_ref("U"),p177rv_ref("ignored-child-value"),[])])
  +false_child = p177rv_def("Odd","ADT",p177rv_absent(),p177rv_absent(),[p177rv_leaf("not-a-Ctr")])
  +qualified = p177rv_def("module.P","ADT",p177rv_absent(),p177rv_absent(),[p177rv_child("module.C")])
  +cycle_a = p177rv_edge("cycle.a","cycle.b")
  +cycle_b = p177rv_edge("cycle.b","cycle.a")
  +collision_a = p177rv_edge("costarring","left")
  +collision_b = p177rv_edge("liquid","right")
  +left = p177rv_leaf("left")
  +right = p177rv_leaf("right")
  +empty = p177rv_leaf("")
  +unicode_a = p177rv_leaf("商")
  +unicode_b = p177rv_leaf("𐀀")
  +marker = p177rv_leaf("$layout.open-array")
  +absent_named = p177rv_def("gone","Absent",p177rv_ref("T"),p177rv_ref("V"),[])
  +index_leaf : KDef = KIndexLeaf{17,[]}
  +index_node : KDef = KIndexNode{17,1,missing(),missing()}
  +cache : KDef = KDef{"$kernel.cache","BookCache",7,0,p177rv_absent(),p177rv_absent(),[missing()],True{},False{}}
  +hidden = p177rv_edge("hidden","T")
  +ghost = p177rv_leaf("ghost")
  +ghost_entry = p177rv_edge("ghost","T")
  +ghost_cache : KDef = KDef{"$kernel.cache","BookCache",7,0,p177rv_absent(),p177rv_absent(),
    [index_set(missing(),ghost_entry,index_hash("ghost",2166136261),32)],True{},False{}}
  +duplicate_parent_a = p177rv_def("P","ADT",p177rv_ref("T"),p177rv_absent(),[p177rv_child("C")])
  +duplicate_parent_b = p177rv_def("P","ADT",p177rv_ref("U"),p177rv_absent(),[p177rv_child("D")])
  +metadata : KDef = KDef{"metadata","Def",17,4,
    KLiteral{"U32",4294967295,"type-text",101,103},
    KLambda{"lambda",4294967295,2,[KLiteral{"String",42,"payload",111,117}],["removed"],109,119,True{}},
    [],True{},True{}}
  [P177ReachCase{"empty",[],[],[],[]},
   P177ReachCase{"missing-and-repeated-roots",[],["missing","missing",""],[],[]},
   P177ReachCase{"no-roots",[a,b],[],[],[]},
   P177ReachCase{"ordered-output",[b,a],["a","b"],[],[b,a]},
   P177ReachCase{"duplicate-root",[a,b],["a","a"],[],[a]},
   P177ReachCase{"duplicate-definitions-first-lookup",[first,first_target,second,second_target],["a"],[],[first,first_target,second]},
   P177ReachCase{"self-cycle",[p177rv_edge("self","self")],["self"],[],[p177rv_edge("self","self")]},
   P177ReachCase{"mutual-cycle",[cycle_b,cycle_a],["cycle.a"],[],[cycle_b,cycle_a]},
   P177ReachCase{"constructor-parent",[a,parent],["C"],[],[parent]},
   P177ReachCase{"repeated-parent-expansion",[parent],["C","D"],[],[parent]},
   P177ReachCase{"parent-then-constructor",[parent],["P","C"],[],[parent]},
   P177ReachCase{"first-parent",[parent,other],["C"],[],[parent]},
   P177ReachCase{"reversed-first-parent",[other,parent],["C"],[],[other]},
   P177ReachCase{"top-level-shadows-constructor",[parent,shadow],["C"],[],[shadow]},
   P177ReachCase{"non-Ctr-child-lookup",[false_child],["not-a-Ctr"],[],[false_child]},
   P177ReachCase{"type-ctor-body-dependencies",[value_dep,ignored,deps,ctor_dep,type_dep],["C"],[],[value_dep,deps,ctor_dep,type_dep]},
   P177ReachCase{"stop-parent-only-body",[value_dep,ignored,deps,ctor_dep,type_dep],["C"],["P"],[deps,ctor_dep,type_dep]},
   P177ReachCase{"stop-constructor-does-not-stop-parent",[value_dep,ignored,deps,ctor_dep,type_dep],["C"],["C"],[value_dep,deps,ctor_dep,type_dep]},
   P177ReachCase{"constructor-qualified-exact",[qualified],["C","module.C"],[],[qualified]},
   P177ReachCase{"collision-both",[collision_a,left,collision_b,right],["liquid","costarring"],[],[collision_a,left,collision_b,right]},
   P177ReachCase{"collision-one",[collision_a,left,collision_b,right],["liquid"],[],[collision_b,right]},
   P177ReachCase{"empty-name-index-variants",[empty,index_leaf,index_node],[""],[],[empty,index_leaf,index_node]},
   P177ReachCase{"unicode",[unicode_b,unicode_a],["商","𐀀","商"],[],[unicode_b,unicode_a]},
   P177ReachCase{"layout-marker-is-ordinary",[marker],["$layout.open-array"],[],[marker]},
   P177ReachCase{"Absent-named-record-is-retained-unexpanded",[absent_named,type_dep,value_dep],["gone"],[],[absent_named]},
   P177ReachCase{"cached-book",book_cached([parent,a],0),["C","a"],[],[parent,a]},
   P177ReachCase{"stale-cache-miss-keeps-queried-raw-row",[cache,hidden,type_dep],["hidden"],[],[hidden]},
   P177ReachCase{"stale-cache-hit-follows-index-value",[ghost_cache,ghost,type_dep],["ghost"],[],[ghost,type_dep]},
   P177ReachCase{"stale-cache-parent-fallback",[cache,parent],["C"],[],[parent]},
   P177ReachCase{"cache-record-payload-retained",[cache,a],["$kernel.cache"],[],[cache]},
   P177ReachCase{"duplicate-parent-names-still-expand-distinct-payloads",[duplicate_parent_a,type_dep,duplicate_parent_b,ctor_dep],["C","D"],[],[duplicate_parent_a,type_dep,duplicate_parent_b,ctor_dep]},
   P177ReachCase{"all-record-metadata-retained",[a,metadata],["metadata"],[],[metadata]}]
