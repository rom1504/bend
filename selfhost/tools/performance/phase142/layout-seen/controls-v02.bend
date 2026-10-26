# Independent traversal/set controls. These inspect constructed input graphs;
# they are not a claim that every fixture passes source type checking.
def p142jt_type() -> KTerm:
  KTerm{"Ref","U32",0,1,[],[],0,0}

def p142jt_ref(name: String) -> KTerm:
  KTerm{"Ann","",0,1,[KTerm{"Ref",name,0,1,[],[],0,0},p142jt_type()],[],0,0}

def p142jt_def(name: String, kind: String, templates: U32, native: Bool, value: KTerm) -> KDef:
  KDef{name,kind,0,templates,p142jt_type(),value,[],native,False{}}

def p142jt_edge(name: String, target: String) -> KDef:
  p142jt_def(name,"Def",0,False{},p142jt_ref(target))

def p142jt_two(a: String, b: String) -> KTerm:
  KTerm{"Ann","",0,1,
    [KTerm{"Let","",0,1,
      [KTerm{"Bind","x",1,1,[p142jt_ref(a)],[],0,0},p142jt_ref(b)],[],0,0},p142jt_type()],[],0,0}

@unsafe
def p142jt_error(+book: List<&2,KDef>, +defs: List<&2,KDef>, +roots: List<&2,String>, +stops: List<&2,String>, +expected: String) -> Bool:
  +old = jl_checked_error(book,defs,roots,stops)
  String.eq(old,expected) && String.eq(p142j_checked_error(book,defs,roots,stops),old)

@unsafe
def p142jt_seen(+defs: List<&2,KDef>, +todo: List<&2,String>, +seen: List<&2,String>, +stops: List<&2,String>, +expected: Bool) -> Bool:
  +context = book_context(defs)
  +cached = book_cached(defs,0)
  +old = jl_visit(context,cached,todo,seen,stops)
  Bool.not(Bool.xor(old,expected)) && Bool.not(Bool.xor(old,
    p142j_visit(context,cached,todo,p142j_members(seen,missing()),stops)))

@unsafe
def p142jt_member(+names: List<&2,String>, +name: String) -> Bool:
  Bool.not(Bool.xor(has_name(names,name),
    p142j_member(p142j_members(names,missing()),name,index_hash(name,2166136261))))

@unsafe
def p142jt_controls() -> List<&2,String>:
  +bad = p142jt_edge("bad","$layout.open-array")
  +self = p142jt_edge("self","self")
  +cycle : List<&2,KDef> = [p142jt_edge("a","b"),p142jt_edge("b","a"),bad]
  +collision : List<&2,KDef> = [p142jt_edge("costarring","missing"),p142jt_edge("liquid","bad"),bad]
  +duplicate_good : List<&2,KDef> = [p142jt_edge("same","missing"),p142jt_edge("same","bad"),bad]
  +duplicate_bad : List<&2,KDef> = [p142jt_edge("same","bad"),p142jt_edge("same","missing"),bad]
  +array : KDef = p142jt_def("Array.new","Def",0,True{},KTerm{"Absent","",0,0,[],[],0,0})
  +names : List<&2,String> = ["","Absent","missing","costarring","liquid","𐀀","商","module.x","x|y","x","x"]
  +open : String = "an open Array element type"
  [p114st_row("layout-index-empty-roots",p142jt_error([],[],[],[],"")),
   p114st_row("layout-index-missing-duplicates",p142jt_error([],[],["missing","missing"],[],"")),
   p114st_row("layout-index-self-cycle",p142jt_error([self],[self],["self"],[],"")),
   p114st_row("layout-index-mutual-cycle",p142jt_error(cycle,cycle,["a"],[],"")),
   p114st_row("layout-index-cycle-then-error",p142jt_error(cycle,cycle,["a","bad"],[],open)),
   p114st_row("layout-index-sentinel-before-stop",p142jt_error([],[],["$layout.open-array"],["$layout.open-array"],open)),
   p114st_row("layout-index-sentinel-before-seen",p142jt_seen([], ["$layout.open-array"],["$layout.open-array"],[],True{})),
   p114st_row("layout-index-stopped-error-owner",p142jt_error([bad],[bad],["bad"],["bad"],"")),
   p114st_row("layout-index-seen-error-owner",p142jt_seen([bad],["bad"],["bad"],[],False{})),
   p114st_row("layout-index-non-def-not-traversed",p142jt_error([],[p142jt_def("other","ADT",0,False{},p142jt_ref("$layout.open-array"))],["other"],[],"")),
   p114st_row("layout-index-template-not-traversed",p142jt_error([],[p142jt_def("generic","Def",1,False{},p142jt_ref("$layout.open-array"))],["generic"],[],"")),
   p114st_row("layout-index-defs-first-match-good",p142jt_error(duplicate_good,duplicate_good,["same"],[],"")),
   p114st_row("layout-index-defs-first-match-bad",p142jt_error(duplicate_bad,duplicate_bad,["same"],[],open)),
   p114st_row("layout-index-real-hash-collision",U32.is_eq(index_hash("costarring",2166136261),index_hash("liquid",2166136261))),
   p114st_row("layout-index-collision-does-not-hide-error",p142jt_error(collision,collision,["costarring","liquid"],[],open)),
   p114st_row("layout-index-collision-seen-name-exact",p142jt_seen(collision,["liquid"],["costarring"],[],True{})),
   p114st_row("layout-index-collision-stop-name-exact",p142jt_error(collision,collision,["liquid"],["costarring"],open)),
   p114st_row("layout-index-shared-tail",p142jt_error(cycle,[p142jt_def("main","Def",0,False{},p142jt_two("a","a")),p142jt_edge("a","missing")],["main"],[],"")),
   p114st_row("layout-index-live-second-branch",p142jt_error([bad],[p142jt_def("main","Def",0,False{},p142jt_two("missing","bad")),bad],["main"],[],open)),
   p114st_row("layout-index-native-array-mark-preserved",p142jt_error([array],[p142jt_edge("main","Array.new")],["main"],[],open)),
   p114st_row("layout-index-qualified-name-not-aliased",p142jt_error([bad],[p142jt_edge("x","missing"),p142jt_edge("module.x","bad"),bad],["x","module.x"],[],open)),
   p114st_row("layout-index-empty-name-membership",p142jt_member(names,"") && p142jt_member([],"")),
   p114st_row("layout-index-absent-name-membership",p142jt_member(names,"Absent") && p142jt_member(names,"unknown")),
   p114st_row("layout-index-collision-membership",p142jt_member(["costarring"],"liquid") && p142jt_member(names,"liquid")),
   p114st_row("layout-index-unicode-membership",p142jt_member(names,"𐀀") && p142jt_member(names,"商") && p142jt_member(names,"")),
   p114st_row("layout-index-qualified-delimiter-membership",p142jt_member(names,"module.x") && p142jt_member(names,"x|y") && p142jt_member(names,"y"))]
