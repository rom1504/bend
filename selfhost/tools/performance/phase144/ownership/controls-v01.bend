def p144ot_def(name: String, kind: String, owned: Bool, children: List<&2,KDef>) -> KDef:
  KDef{name,kind,0,0,KTerm{"Absent","",0,0,[],[],0,0},KTerm{"Absent","",0,0,[],[],0,0},children,owned,False{}}

def p144ot_ctor(name: String) -> KDef:
  p144ot_def(name,"Ctr",False{},[])

@unsafe
def p144ot_ready(facts: P144OFacts, expected: Bool) -> Bool:
  match facts:
    case P144OFacts{names,valid}: p134v_bool(valid,expected)

@unsafe
def p144ot_indexed(+book: List<&2,KDef>, facts: P144OFacts, +name: String, expected: Bool) -> Bool:
  match facts:
    case P144OFacts{names,valid}:
      p134v_bool(p144o_index_query(book,valid,p144o_index(names,missing()),name),expected)

@unsafe
def p144ot_expected(+book: List<&2,KDef>, +name: String, +expected: Bool, ready: Bool) -> Bool:
  +facts = p144o_build(book)
  p134v_bool(p144o_original(book,name),expected) && p144ot_ready(facts,ready) &&
    p134v_bool(p144o_query(book,facts,name),expected) && p144ot_indexed(book,facts,name,expected)

@unsafe
def p144ot_carry_checked(+source: List<&2,KDef>, +name: String, prepared: P112SPrepared) -> Bool:
  match prepared:
    case P112SPrepared{book,nodes,error}:
      p134v_bool(p144o_owned(book,name),p144o_original(source,name)) &&
        p144ot_ready(p144o_payload(nc_ctor_context(book)),True{})

@unsafe
def p144ot_carry(+raw: List<&2,KDef>, +name: String) -> Bool:
  +source = book_cached(raw,0)
  +view = p144o_view(source,p144o_build(source))
  +again = ns_attach_book(view,[],0,[])
  p134v_bool(p144o_owned(view,name),p144o_original(source,name)) &&
    p134v_bool(p144o_owned(again,name),p144o_original(source,name)) &&
    p144ot_carry_checked(source,name,p112s_attach_book(again,[],0,[],missing(),""))

@unsafe
def p144ot_catalogue(+book: List<&2,KDef>) -> Bool:
  p134v_list(~N_Constructor,~p140v_ctor,p144o_original_constructors(book,book),p144o_constructors(book,book,p144o_build(book)))

@unsafe
def p144ot_bad_metadata(+book: List<&2,KDef>, +name: String, term: KTerm) -> Bool:
  p134v_bool(p144o_owned_term(book,name,term),p144o_original(book,name))

# Query workload helpers. For a complete comparison include p144o_build and,
# for the index version, p144o_index, in the measured acquisition boundary.
@unsafe
def p144ot_original_batch(+book: List<&2,KDef>, names: List<&2,String>) -> List<&2,Bool>:
  match names:
    case Nil{}: []
    case Con{+name,rest}: Con{p144o_original(book,name),p144ot_original_batch(book,rest)}

@unsafe
def p144ot_list_batch(+book: List<&2,KDef>, +facts: P144OFacts, names: List<&2,String>) -> List<&2,Bool>:
  match names:
    case Nil{}: []
    case Con{+name,rest}: Con{p144o_query(book,facts,name),p144ot_list_batch(book,facts,rest)}

@unsafe
def p144ot_index_batch(+book: List<&2,KDef>, +valid: Bool, +tree: KDef, names: List<&2,String>) -> List<&2,Bool>:
  match names:
    case Nil{}: []
    case Con{+name,rest}: Con{p144o_index_query(book,valid,tree,name),p144ot_index_batch(book,valid,tree,rest)}

@unsafe
def p144o_controls() -> List<&2,String>:
  +c = p144ot_ctor("C")
  +owned = p144ot_def("Owned","ADT",True{},[c])
  +plain = p144ot_def("Plain","ADT",False{},[c])
  +shadow = p144ot_def("Shadow","ADT",False{},[p144ot_def("C","Def",False{},[]),c])
  +nested = p144ot_def("Nested","ADT",True{},[p144ot_def("wrapper","Def",False{},[c])])
  +cached = p144ot_def("Cached","ADT",True{},book_cached([c],0))
  +collision: List<&2,KDef> = [p144ot_def("First","ADT",False{},[p144ot_ctor("costarring")]),p144ot_def("Second","ADT",True{},[p144ot_ctor("liquid")])]
  +unicode: List<&2,KDef> = [p144ot_def("BMP","ADT",True{},[p144ot_ctor("商"),p144ot_ctor("")]),p144ot_def("Astral","ADT",False{},[p144ot_ctor("𐀀")])]
  +leaf: KDef = KIndexLeaf{0,[c]}
  +node: KDef = KIndexNode{0,1,leaf,leaf}
  +empty = p144ot_ctor("")
  [p114st_row("ownership-empty",p144ot_expected([],"C",False{},True{})),
   p114st_row("ownership-missing",p144ot_expected([owned],"missing",False{},True{})),
   p114st_row("ownership-true",p144ot_expected([owned],"C",True{},True{})),
   p114st_row("ownership-false",p144ot_expected([plain],"C",False{},True{})),
   p114st_row("ownership-false-first",p144ot_expected([plain,owned],"C",False{},True{})),
   p114st_row("ownership-true-first",p144ot_expected([owned,plain],"C",True{},True{})),
   p114st_row("ownership-non-ADT",p144ot_expected([p144ot_def("ignored","Def",True{},[c])],"C",False{},True{})),
   p114st_row("ownership-child-shadow",p144ot_expected([shadow],"C",False{},True{})),
   p114st_row("ownership-later-ADT-after-shadow",p144ot_expected([shadow,owned],"C",True{},True{})),
   p114st_row("ownership-first-child-wins",p144ot_expected([p144ot_def("First","ADT",True{},[c,p144ot_def("C","Def",False{},[])])],"C",True{},True{})),
   p114st_row("ownership-empty-name",p144ot_expected([p144ot_def("Empty","ADT",True{},[empty])],"",True{},True{})),
   p114st_row("ownership-nested-ignored",p144ot_expected([nested],"C",False{},True{})),
   p114st_row("ownership-child-cache-fallback",p144ot_expected([cached],"C",True{},False{})),
   p114st_row("ownership-child-cache-after-visible-fallback",p144ot_expected([p144ot_def("Cached","ADT",True{},[c,index_first(book_cached([],0))])],"C",True{},False{})),
   p114st_row("ownership-full-hash-collision",U32.is_eq(index_hash("costarring",2166136261),index_hash("liquid",2166136261))),
   p114st_row("ownership-collision-false",p144ot_expected(collision,"costarring",False{},True{})),
   p114st_row("ownership-collision-true",p144ot_expected(collision,"liquid",True{},True{})),
   p114st_row("ownership-unicode-BMP",p144ot_expected(unicode,"商",True{},True{})),
   p114st_row("ownership-unicode-boundary",p144ot_expected(unicode,"",True{},True{}) && p144ot_expected(unicode,"𐀀",False{},True{})),
   p114st_row("ownership-index-record-top-ignored",p144ot_expected([leaf,node,owned],"C",True{},True{})),
   p114st_row("ownership-index-leaf-shadows-empty-child",p144ot_expected([p144ot_def("Malformed","ADT",True{},[leaf,empty])],"",False{},True{})),
   p114st_row("ownership-index-node-shadows-empty-child",p144ot_expected([p144ot_def("Malformed","ADT",True{},[node,empty])],"",False{},True{})),
   p114st_row("ownership-local-shadow-set-resets",p144ot_expected([p144ot_def("Malformed","ADT",True{},[leaf,empty]),p144ot_def("Later","ADT",True{},[empty])],"",True{},True{})),
   p114st_row("ownership-carrier-positive-survives",p144ot_carry([owned],"C")),
   p114st_row("ownership-carrier-false-survives",p144ot_carry([plain,owned],"C")),
   p114st_row("ownership-carrier-miss-survives",p144ot_carry([owned],"missing")),
   p114st_row("ownership-raw-view-fallback",p134v_bool(p144o_owned([owned],"C"),True{})),
   p114st_row("ownership-metadata-wrong-version",p144ot_bad_metadata([owned],"C",KTerm{"P144Ownership","",0,2,[],[],0,0})),
   p114st_row("ownership-metadata-wrong-tag",p144ot_bad_metadata([owned],"C",KTerm{"Absent","",0,1,[],[],0,0})),
   p114st_row("ownership-metadata-wrong-origin",p144ot_bad_metadata([owned],"C",KTerm{"P144Ownership","",0,1,[],[],1,0})),
   p114st_row("ownership-metadata-wrong-kind",p144ot_bad_metadata([owned],"C",KLiteral{"U32",0,"",0,0})),
   p114st_row("ownership-catalogue-empty",p144ot_catalogue([])),
   p114st_row("ownership-catalogue-first-false",p144ot_catalogue([plain,owned])),
   p114st_row("ownership-catalogue-shadow",p144ot_catalogue([shadow,owned])),
   p114st_row("ownership-catalogue-collision",p144ot_catalogue(collision))]
