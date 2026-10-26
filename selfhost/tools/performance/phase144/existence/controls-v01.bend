@unsafe
def p144cet_ready(facts: P144CEFacts, expected: Bool) -> Bool:
  match facts:
    case P144CEFacts{members,valid}: p134v_bool(valid,expected)

@unsafe
def p144cet_query(+book: List<&2,KDef>, +name: String, +expected: Bool, ready: Bool) -> Bool:
  +facts = p144ce_build(book)
  p134v_bool(constructor_exists(book,name),expected) &&
    p134v_bool(p144ce_query(book,facts,name),expected) && p144cet_ready(facts,ready)

@unsafe
def p144cet_names(+book: List<&2,KDef>, +ctors: List<&2,KDef>, +seen: List<&2,String>, +expected: String) -> Bool:
  p88_string_eq(constructor_names(book,ctors,seen),expected) &&
    p88_string_eq(p144ce_names(book,ctors,seen),expected)

@unsafe
def p144cet_disjoint(+book: List<&2,KDef>, +defs: List<&2,KDef>, +expected: Bool) -> Bool:
  p134v_bool(base_prefix_ctor_disjoint(defs,book),expected) &&
    p134v_bool(p144ce_disjoint(defs,book),expected)

@unsafe
def p144ce_controls() -> List<&2,String>:
  +c = p144ot_ctor("C")
  +u = p144ot_ctor("U")
  +absent = p144ot_def("C","Absent",False{},[])
  +nonctor = p144ot_def("C","Def",False{},[])
  +plain = p144ot_def("Plain","ADT",False{},[c])
  +other = p144ot_def("Other","Def",False{},[c])
  +masked = p144ot_def("Masked","ADT",False{},[absent,c])
  +visible = p144ot_def("Visible","ADT",False{},[c,absent])
  +cached = p144ot_def("Cached","ADT",False{},book_cached([c],0))
  +empty = p144ot_def("Empty","Def",False{},[p144ot_ctor("")])
  +nested = p144ot_def("Nested","ADT",False{},[p144ot_def("Wrapper","Def",False{},[c])])
  +cache = p144ot_def("$kernel.cache","BookCache",True{},[c])
  +leaf: KDef = KIndexLeaf{0,[c]}
  +node: KDef = KIndexNode{0,1,leaf,leaf}
  +collision = p144ot_def("Collision","ADT",False{},[p144ot_ctor("costarring"),p144ot_ctor("liquid")])
  +unicode = p144ot_def("Unicode","ADT",False{},[p144ot_ctor("商"),p144ot_ctor("𐀀")])
  [
    nt_choose(String,p144cet_query([],"C",False{},True{}),u=>"empty:pass",u=>"empty:FAIL"),
    nt_choose(String,p144cet_query([plain],"C",True{},True{}),u=>"unowned:pass",u=>"unowned:FAIL"),
    nt_choose(String,p144cet_query([other],"C",True{},True{}),u=>"nonadt:pass",u=>"nonadt:FAIL"),
    nt_choose(String,p144cet_query([p144ot_def("P","ADT",False{},[nonctor])],"C",True{},True{}),u=>"nonctor:pass",u=>"nonctor:FAIL"),
    nt_choose(String,p144cet_query([masked],"C",False{},True{}),u=>"first-absent:pass",u=>"first-absent:FAIL"),
    nt_choose(String,p144cet_query([visible],"C",True{},True{}),u=>"first-visible:pass",u=>"first-visible:FAIL"),
    nt_choose(String,p144cet_query([masked,plain],"C",True{},True{}),u=>"parent-or:pass",u=>"parent-or:FAIL"),
    nt_choose(String,p144cet_query([cache],"C",False{},True{}),u=>"outer-cache-skip:pass",u=>"outer-cache-skip:FAIL"),
    nt_choose(String,p144cet_query([cached],"C",True{},False{}),u=>"child-cache-fallback:pass",u=>"child-cache-fallback:FAIL"),
    nt_choose(String,p144cet_query([empty],"",True{},True{}),u=>"empty-key:pass",u=>"empty-key:FAIL"),
    nt_choose(String,p144cet_query([nested],"C",False{},True{}),u=>"shallow-only:pass",u=>"shallow-only:FAIL"),
    nt_choose(String,p144cet_query([collision],"costarring",True{},True{}),u=>"collision-left:pass",u=>"collision-left:FAIL"),
    nt_choose(String,p144cet_query([collision],"liquid",True{},True{}),u=>"collision-right:pass",u=>"collision-right:FAIL"),
    nt_choose(String,p144cet_query([collision],"missing",False{},True{}),u=>"collision-miss:pass",u=>"collision-miss:FAIL"),
    nt_choose(String,p144cet_query([unicode],"商",True{},True{}),u=>"unicode-bmp:pass",u=>"unicode-bmp:FAIL"),
    nt_choose(String,p144cet_query([unicode],"𐀀",True{},True{}),u=>"unicode-astral:pass",u=>"unicode-astral:FAIL"),
    nt_choose(String,p144cet_names([plain],[u],[],""),u=>"names-clear:pass",u=>"names-clear:FAIL"),
    nt_choose(String,p144cet_names([plain],[c],[],"duplicate constructor name"),u=>"names-existing:pass",u=>"names-existing:FAIL"),
    nt_choose(String,p144cet_names([],[u,u],[],"duplicate constructor name"),u=>"names-local:pass",u=>"names-local:FAIL"),
    nt_choose(String,p144cet_names([],[u],["U"],"duplicate constructor name"),u=>"names-seen:pass",u=>"names-seen:FAIL"),
    nt_choose(String,p144cet_disjoint([plain],[u],True{}),u=>"disjoint-clear:pass",u=>"disjoint-clear:FAIL"),
    nt_choose(String,p144cet_disjoint([plain],[p144ot_def("X","Def",False{},[c])],False{}),u=>"disjoint-nested:pass",u=>"disjoint-nested:FAIL"),
    nt_choose(String,p144cet_query([leaf],"C",True{},True{}),u=>"index-leaf-parent:pass",u=>"index-leaf-parent:FAIL"),
    nt_choose(String,p144cet_query([node],"",True{},True{}),u=>"index-node-parent:pass",u=>"index-node-parent:FAIL"),
    nt_choose(String,p144cet_query([p144ot_def("P","Absent",False{},[c])],"C",True{},True{}),u=>"absent-parent:pass",u=>"absent-parent:FAIL"),
    nt_choose(String,p144cet_query([p144ot_def("P","Def",False{},[leaf])],"",True{},True{}),u=>"index-child:pass",u=>"index-child:FAIL"),
    nt_choose(String,p144cet_query([p144ot_def("P","ADT",False{},[index_first(book_cached([u],0)),c])],"C",False{},False{}),u=>"child-cache-mask:pass",u=>"child-cache-mask:FAIL")
  ]
