def p144pc_def(name: String, kind: String, version: U32) -> KDef:
  KDef{name,kind,version,0,typ(1),KLiteral{"U32",version,"",0,0},[],False{},False{}}

@unsafe
def p144pc_query(+name: String, +prior: List<&2,KDef>) -> Bool:
  p140eq_def(f_find(name,prior),p144p_find(name,prior,Some{index_build(prior)})) &&
    p140eq_def(f_find(name,prior),p144p_find(name,prior,None{}))

@unsafe
def p144pc_scope(scope: FParseScope, +names: List<&2,String>) -> Bool:
  match scope:
    case FParseScope{+prior,index,ctors,ns,aliases,+view}: p144pc_queries(names,prior,view)

@unsafe
def p144pc_queries(names: List<&2,String>, +prior: List<&2,KDef>, +view: Maybe<&2,KDef>) -> Bool:
  match names:
    case Nil{}: True{}
    case Con{+name,rest}: p140eq_def(f_find(name,prior),p144p_find(name,prior,view)) &&
      p144pc_queries(rest,prior,view)

@unsafe
def p144pc_seed(+prior: List<&2,KDef>, ns: String) -> FParseScope:
  p144p_ready_scope(FParseScope{prior,index_build(List.reverse(&2,KDef,prior)),
    f_ctor_index(prior,missing()),ns,[],None{}})

@unsafe
def p144pc_legacy_index_opposite(+prior: List<&2,KDef>) -> Bool:
  Bool.not(p140eq_def(f_find("same",prior),index_find(index_build(List.reverse(&2,KDef,prior)),
    "same",index_hash("same",2166136261),32))) && p144pc_query("same",prior)

@unsafe
def p144pc_controls() -> List<&2,String>:
  +a = p144pc_def("same","Def",1)
  +b = p144pc_def("same","ADT",2)
  +unit = p144pc_def("Unit","ADT",3)
  +collision = p144pc_def("p143CollisionlrXlHP","Def",4)
  +child = p144pc_def("inside","Ctr",5)
  +parent : KDef = KDef{"Parent","ADT",1,0,typ(1),atom("Absent"),[child],False{},False{}}
  +scope = p144pc_seed([a,b,unit,collision,parent],"")
  [p131u_row(p144pc_query("missing",[]),"prior-empty"),
   p131u_row(p144pc_query("same",[a,b]),"prior-first-duplicate"),
   p131u_row(p144pc_query("same",[b,a]),"prior-reversed-duplicate"),
   p131u_row(p144pc_legacy_index_opposite([a,b]),"existing-reversed-index-is-not-oracle"),
   p131u_row(p144pc_query("missing",[a,b]),"prior-missing-name"),
   p131u_row(p144pc_query("",[a]),"prior-empty-name-miss"),
   p131u_row(p144pc_query("",[p144pc_def("","Odd",7),a]),"prior-empty-name-hit-fallback"),
   p131u_row(p144pc_query("absent",[p144pc_def("absent","Absent",8)]),"prior-real-absent-kind"),
   p131u_row(p144pc_query("missing",[p144pc_def("missing","Missing",9)]),"prior-real-missing-kind"),
   p131u_row(U32.is_eq(index_hash("Unit",2166136261),index_hash("p143CollisionlrXlHP",2166136261)),"prior-actual-hash-collision"),
   p131u_row(p144pc_query("Unit",[collision,unit]),"prior-collision-left"),
   p131u_row(p144pc_query("p143CollisionlrXlHP",[unit,collision]),"prior-collision-right"),
   p131u_row(p144pc_query("inside",[parent]),"prior-does-not-descend-children"),
   p131u_row(p144pc_query("inside",[parent,child]),"prior-flat-child-entry"),
   p131u_row(p144pc_query("λ.猫",[p144pc_def("λ.猫","Def",10)]),"prior-unicode"),
   p131u_row(p144pc_query("$kernel.cache",book_cached([a,b],19)),"prior-book-cache-is-ordinary-row"),
   p131u_row(p144pc_query("same",book_cached([a,b],19)),"prior-past-book-cache-flat"),
   p131u_row(p144pc_query("",[KIndexLeaf{13,[a]},a]),"prior-index-leaf-empty-name"),
   p131u_row(p144pc_query("",[KIndexNode{13,1,a,b},a]),"prior-index-node-empty-name"),
   p131u_row(p144pc_query("same",[KIndexLeaf{13,[b]},a]),"prior-index-value-not-child-search"),
   p131u_row(p144pc_scope(scope,["same","Unit","p143CollisionlrXlHP","Parent","inside","unknown"]),"prior-prepared-scope"),
   p131u_row(p144pc_scope(f_context_declare(b,scope),["same","Unit","Parent","unknown"]),"prior-update-new-header-wins"),
   p131u_row(p144pc_scope(f_context_declare(a,f_context_declare(b,scope)),["same","Unit","Parent"]),"prior-two-updates"),
   p131u_row(p144pc_scope(f_context_declare(a,p144pc_seed([],"Mod")),["same","Mod:same","unknown"]),"prior-qualified-header"),
   p131u_row(p144pc_scope(f_context_declare(a,f_parse_scope_empty()),["same","unknown"]),"prior-unprepared-scope-fallback"),
   p131u_row(p144p_view_same(None{},None{}),"prior-view-none-equality"),
   p131u_row(Bool.not(p144p_view_same(None{},Some{missing()})),"prior-view-readiness-distinct")]
