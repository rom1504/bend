# Test-only legacy oracle: exact nr_walk/nr_visit bodies with just their two
# function names renamed. It stays independent after override-v01 is appended.
@unsafe
def p143nrt_original(+book: List<&2, KDef>, todo: List<&2, String>, +done: List<&2, String>, +facts: List<&2, KDef>) -> NR_Closure:
  match todo:
    case Nil{}: NR_Closure{done, facts}
    case Con{+name, +rest}:
      nt_choose(NR_Closure, nb_contains(done, name), u => p143nrt_original(book, rest, done, facts),
        u => p143nrt_original_visit(book, name, rest, done, facts, lookup(book, name)))

@unsafe
def p143nrt_original_visit(+book: List<&2, KDef>, +name: String, +todo: List<&2, String>, +done: List<&2, String>, +facts: List<&2, KDef>, +d: KDef) -> NR_Closure:
  +body = nc_definition_plain(book, d, 0)
  +more = nt_choose(List<&2, KDef>, p88_string_eq(dk(d), "Def") && Bool.not(nc_native_def(d) || nc_foreign(d)),
    u => Con{KDef{name, "NativeErasedBody", nd_arity_plain(book, name), 1, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, body, Nil{}, False{}, False{}}, facts}, u => facts)
  p143nrt_original(book, nt_append(String, nc_refs(body), todo), Con{name, done}, more)

# The observer retains complete variants, flags, nested children, terms and
# source metadata through the existing independent p140ce_defs observer.
@unsafe
def p143nrt_equal(a: NR_Closure, b: NR_Closure) -> Bool:
  match a b:
    case NR_Closure{an,af} NR_Closure{bn,bf}: p140o_strings(an,bn) && p140ce_defs(af,bf)

@unsafe
def p143nrt_names(result: NR_Closure, expected: List<&2,String>) -> Bool:
  match result:
    case NR_Closure{names,facts}: p140o_strings(names,expected)

@unsafe
def p143nrt_case(+book: List<&2,KDef>, +todo: List<&2,String>, +done: List<&2,String>, +facts: List<&2,KDef>, expected: List<&2,String>) -> Bool:
  +actual = p143nr_begin(book,todo,done,facts)
  p143nrt_equal(actual,p143nrt_original(book,todo,done,facts)) && p143nrt_names(actual,expected)

def p143nrt_type() -> KTerm:
  KTerm{"ADT","U32",0,0,[],[],0,0}

def p143nrt_literal(value: U32) -> KTerm:
  KLiteral{"U32",value,"",0,0}

def p143nrt_ref(name: String) -> KTerm:
  KTerm{"Ref",name,0,1,[],[],0,0}

def p143nrt_def(name: String, value: KTerm) -> KDef:
  KDef{name,"Def",0,0,p143nrt_type(),value,[],False{},False{}}

# Deliberately uncommon constructor tag avoids application-beta or constructor
# erasure policy; this is a finite raw KTerm observer test, not source admission.
def p143nrt_refs(names: List<&2,String>) -> List<&2,KTerm>:
  match names:
    case Nil{}: Nil{}
    case Con{name,rest}: Con{p143nrt_ref(name),p143nrt_refs(rest)}

def p143nrt_many(names: List<&2,String>) -> KTerm:
  KTerm{"FixtureBranch","",0,0,p143nrt_refs(names),[],0,0}

def p143nrt_fact(value: U32) -> KDef:
  KDef{"prior","NativeErasedBody",3,1,
    KLambda{"kept",17,2,[],["removed"],31,37,True{}},
    KLiteral{"U32",value,"retained",41,47},
    [KIndexNode{7,1,KIndexLeaf{3,[]},KIndexLeaf{5,[]}}],True{},True{}}

@unsafe
def p143nr_controls() -> List<&2,String>:
  +prior = p143nrt_fact(5)
  +changed = p143nrt_fact(6)
  +a = p143nrt_def("a",p143nrt_literal(1))
  +b = p143nrt_def("b",p143nrt_literal(2))
  +collision : List<&2,KDef> = [p143nrt_def("costarring",p143nrt_literal(1)),p143nrt_def("liquid",p143nrt_literal(2))]
  +foreign : KDef = KDef{"foreign","Def",0,0,p143nrt_type(),KTerm{"Foreign","",0,0,[],[],0,0},[],True{},False{}}
  +absent : KDef = KDef{"absent","Def",0,0,p143nrt_type(),KTerm{"Absent","",0,0,[],[],0,0},[],False{},False{}}
  +native : KDef = KDef{"U32.add","Def",0,0,p143nrt_type(),p143nrt_literal(0),[],True{},False{}}
  +cached = book_cached([p143nrt_def("same",p143nrt_ref("a")),a,b],40)
  [p114st_row("nr-index-empty-preserves-complete-initial-state",
     p143nrt_equal(p143nr_begin([],[],["old","old"],[prior]),NR_Closure{["old","old"],[prior]})),
   p114st_row("nr-index-initial-done-skips-body-and-preserves-duplicates",
     p143nrt_case([p143nrt_def("skip",p143nrt_ref("unvisited"))],["skip","skip"],["skip","skip"],[prior],["skip","skip"])),
   p114st_row("nr-index-new-refs-precede-queue-with-exact-fact-order",
     p143nrt_case([p143nrt_def("main",p143nrt_many(["a","b","a"])),a,b],["main","later"],["old"],[prior],["later","b","a","main","old"])),
   p114st_row("nr-index-self-cycle-terminates-on-first-visit",
     p143nrt_case([p143nrt_def("a",p143nrt_ref("a"))],["a","a"],[],[],["a"])),
   p114st_row("nr-index-mutual-cycle-retains-prepend-order",
     p143nrt_case([p143nrt_def("a",p143nrt_ref("b")),p143nrt_def("b",p143nrt_ref("a"))],["a"],[],[],["b","a"])),
   p114st_row("nr-index-real-hash-collision-distinguishes-names",
     U32.is_eq(index_hash("costarring",2166136261),index_hash("liquid",2166136261)) &&
     p143nrt_case(collision,["costarring","liquid","costarring"],[],[],["liquid","costarring"])),
   p114st_row("nr-index-collision-initial-done-is-not-hash-membership",
     p143nrt_case(collision,["liquid"],["costarring"],[prior],["liquid","costarring"])),
   p114st_row("nr-index-empty-unicode-and-missing-names",
     p143nrt_case([],["","商","𐀀","","missing"],[],[prior],["missing","𐀀","商",""])),
   p114st_row("nr-index-lookup-first-duplicate-remains-authoritative",
     p143nrt_case([p143nrt_def("same",p143nrt_ref("a")),p143nrt_def("same",p143nrt_ref("b")),a,b],["same"],[],[],["a","same"])),
   p114st_row("nr-index-bookcache-preserves-terminal-lookup-policy",
     p143nrt_case(nt_append(KDef,cached,[p143nrt_def("same",p143nrt_ref("b"))]),["same"],[],[],["a","same"])),
   p114st_row("nr-index-native-foreign-absent-preserve-initial-facts",
     p143nrt_case([native,foreign,absent],["U32.add","foreign","absent"],[],[prior],["absent","foreign","U32.add"]) &&
     p143nrt_equal(p143nr_begin([native,foreign,absent],["U32.add","foreign","absent"],[],[prior]),
       NR_Closure{["absent","foreign","U32.add"],[prior]})),
   p114st_row("nr-index-full-observer-detects-payload-and-name-order",
     Bool.not(p143nrt_equal(NR_Closure{["a","b"],[prior]},NR_Closure{["a","b"],[changed]})) &&
     Bool.not(p143nrt_equal(NR_Closure{["a","b"],[prior]},NR_Closure{["b","a"],[prior]})))]
