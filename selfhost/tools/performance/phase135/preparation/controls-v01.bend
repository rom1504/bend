def p135cot_def(name: String, kind: String, owned: Bool, children: List<&2,KDef>) -> KDef:
  KDef{name,kind,0,0,KTerm{"Absent","",0,0,[],[],0,0},KTerm{"Absent","",0,0,[],[],0,0},children,owned,False{}}

def p135cot_ctor(name: String) -> KDef:
  p135cot_def(name,"Ctr",False{},[])

@unsafe
def p135cot_answer(+book: List<&2,KDef>, +name: String) -> Bool:
  p134v_bool(p135co_query(book,p135co_create(p135co_rows(book,[])),name),p135co_legacy(book,name))

@unsafe
def p135cot_expected(+book: List<&2,KDef>, +name: String, expected: Bool) -> Bool:
  p134v_bool(p135co_legacy(book,name),expected) && p135cot_answer(book,name)

@unsafe
def p135cot_changed(old: List<&2,KDef>, +fresh: List<&2,KDef>, name: String, hit: Bool) -> Bool:
  p135cot_changed_ready(fresh,name,hit,p135co_reuse(fresh,p135co_create(p135co_rows(old,[]))))

@unsafe
def p135cot_changed_ready(+book: List<&2,KDef>, +name: String, expected: Bool, ready: P135COReady) -> Bool:
  match ready:
    case P135COReady{cache,hit}:
      p134v_bool(hit,expected) && p134v_bool(p135co_query(book,cache,name),p135co_legacy(book,name))

@unsafe
def p135cot_context(+book: List<&2,KDef>, name: String) -> Bool:
  p135cot_context_ready(book,name,p135co_prepare_book(ns_attach_book(book_cached(book,0),[],0,[]),p135co_empty()))

@unsafe
def p135cot_context_ready(book: List<&2,KDef>, +name: String, ready: P135COBook) -> Bool:
  match ready:
    case P135COBook{prepared,cache,hit}: p134v_bool(p135co_owned(prepared,name),p135co_legacy(book,name))

@unsafe
def p135cot_repeated(book: List<&2,KDef>) -> Bool:
  p135cot_repeated_ready(p135co_prepare_book(ns_attach_book(book_cached(book,0),[],0,[]),p135co_empty()))

@unsafe
def p135cot_repeated_ready(ready: P135COBook) -> Bool:
  match ready:
    case P135COBook{book,cache,hit}:
      p135cot_repeated_again(p135co_prepare_book(book,cache))

@unsafe
def p135cot_repeated_again(ready: P135COBook) -> Bool:
  match ready:
    case P135COBook{book,cache,hit}:
      hit && U32.is_eq(nt_count(KDef,dc(nc_ctor_context(book))),2)

@unsafe
def p135co_controls() -> List<&2,String>:
  +c = p135cot_ctor("C")
  +d = p135cot_ctor("D")
  +owned = p135cot_def("Owned","ADT",True{},[c])
  +plain = p135cot_def("Plain","ADT",False{},[c])
  +shadow = p135cot_def("Shadow","ADT",False{},[p135cot_def("C","Def",False{},[]),c])
  +nested = p135cot_def("Nested","ADT",True{},[p135cot_def("wrapper","Def",False{},[c])])
  +cached = p135cot_def("Cached","ADT",True{},book_cached([c],0))
  +collision : List<&2,KDef> = [p135cot_def("First","ADT",False{},[p135cot_ctor("costarring")]),p135cot_def("Second","ADT",True{},[p135cot_ctor("liquid")])]
  +unicode : List<&2,KDef> = [p135cot_def("BMP","ADT",True{},[p135cot_ctor("商"),p135cot_ctor("")]),p135cot_def("Astral","ADT",False{},[p135cot_ctor("𐀀")])]
  +edited : KDef = KDef{"helper","Def",0,0,KTerm{"Absent","",0,0,[],[],0,0},KTerm{"NWord","9",9,0,[],[],0,0},[],False{},False{}}
  +typed : KDef = KDef{"C","Ctr",7,0,KTerm{"Typ","",0,0,[],[],0,0},KTerm{"Absent","",0,0,[],[],0,0},[],False{},False{}}
  +wrong : KDef = KDef{"$native.ctor.ownership","P135CtorOwnership",2,0,KTerm{"Absent","",0,0,[],[],0,0},KTerm{"Absent","",0,0,[],[],0,0},[],True{},False{}}
  [p114st_row("ctor-ownership-empty",p135cot_expected([],"C",False{})),
   p114st_row("ctor-ownership-absent",p135cot_expected([owned],"missing",False{})),
   p114st_row("ctor-ownership-owned",p135cot_expected([owned],"C",True{})),
   p114st_row("ctor-ownership-plain",p135cot_expected([plain],"C",False{})),
   p114st_row("ctor-ownership-non-adt",p135cot_expected([p135cot_def("ignored","Def",True{},[c])],"C",False{})),
   p114st_row("ctor-ownership-false-first",p135cot_expected([plain,owned],"C",False{})),
   p114st_row("ctor-ownership-true-first",p135cot_expected([owned,plain],"C",True{})),
   p114st_row("ctor-ownership-child-shadow",p135cot_expected([shadow],"C",False{})),
   p114st_row("ctor-ownership-next-adt-after-shadow",p135cot_expected([shadow,owned],"C",True{})),
   p114st_row("ctor-ownership-empty-name",p135cot_expected([p135cot_def("Empty","ADT",True{},[p135cot_ctor("")])],"",True{})),
   p114st_row("ctor-ownership-nested-child-ignored",p135cot_expected([nested],"C",False{})),
   p114st_row("ctor-ownership-cached-children-fallback",p135cot_expected([cached],"C",True{})),
   p114st_row("ctor-ownership-real-hash-collision",U32.is_eq(index_hash("costarring",2166136261),index_hash("liquid",2166136261))),
   p114st_row("ctor-ownership-collision-first-false",p135cot_expected(collision,"costarring",False{})),
   p114st_row("ctor-ownership-collision-second-true",p135cot_expected(collision,"liquid",True{})),
   p114st_row("ctor-ownership-unicode-bmp",p135cot_expected(unicode,"商",True{})),
   p114st_row("ctor-ownership-unicode-order-boundary",p135cot_expected(unicode,"",True{}) && p135cot_expected(unicode,"𐀀",False{})),
   p114st_row("ctor-ownership-context-true",p135cot_context([owned],"C")),
   p114st_row("ctor-ownership-context-false",p135cot_context([plain,owned],"C")),
   p114st_row("ctor-ownership-context-missing",p135cot_context([owned],"missing")),
   p114st_row("ctor-ownership-headerless-fallback",p134v_bool(p135co_owned([owned],"C"),True{})),
   p114st_row("ctor-ownership-body-edit-reuses",p135cot_changed([owned,p135cot_def("helper","Def",False{},[])],[owned,edited],"C",True{})),
   p114st_row("ctor-ownership-owner-change-invalidates",p135cot_changed([owned],[plain],"C",False{})),
   p114st_row("ctor-ownership-new-constructor-invalidates",p135cot_changed([owned],[p135cot_def("Owned","ADT",True{},[c,d])],"D",False{})),
   p114st_row("ctor-ownership-adt-order-invalidates",p135cot_changed([owned,plain],[plain,owned],"C",False{})),
   p114st_row("ctor-ownership-field-type-does-not-matter",p135cot_changed([owned],[p135cot_def("Owned","ADT",True{},[typed])],"C",True{})),
   p114st_row("ctor-ownership-child-order-invalidates",p135cot_changed([shadow],[p135cot_def("Shadow","ADT",False{},[c,p135cot_def("C","Def",False{},[])])],"C",False{})),
   p114st_row("ctor-ownership-wrong-metadata-version",String.eq(dk(p135co_payload([missing(),wrong])),"Absent")),
   p114st_row("ctor-ownership-repeat-does-not-grow",p135cot_repeated([owned]))]
