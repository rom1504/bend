@unsafe
def p140spc_pair(value: U32) -> KTerm:
  kt("Ctr","Pair",0,0,[kt("NWord",U32.show(value),0,0,[]),kt("NWord","9",0,0,[])])

def p140spc_def(name: String) -> KDef:
  KDef{name,"Def",0,0,atom("Data"),KLiteral{"U32",0,"",0,0},[],False{},False{}}

def p140spc_fact(name: String, body: KTerm) -> KDef:
  KDef{name,"NativeErasedBody",7,11,atom("Absent"),body,[],False{},False{}}

@unsafe
def p140spc_book(a: U32, b: U32, c: KTerm) -> List<&2,KDef>:
  ns_attach_book(book_cached([p140spc_def("a"),p140spc_def("b"),p140spc_def("c")],40),
    [p140spc_fact("a",p140spc_pair(a)),p140spc_fact("b",p140spc_pair(b)),p140spc_fact("c",c)],0,[])

@unsafe
def p140spc_equal(a: P112SPrepared, b: P112SPrepared) -> Bool:
  match a b:
    case P112SPrepared{ab,an,ae} P112SPrepared{bb,bn,be}:
      p140eq_list(ab,bb) && p140or_nodes(an,bn) && String.eq(ae,be)

@unsafe
def p140spc_cache(result: P140SPResult) -> P140SPCache:
  match result:
    case P140SPResult{prepared,cache,stats}: cache

@unsafe
def p140spc_check(+book: List<&2,KDef>, +names: List<&2,String>, +constructors: List<&2,N_Constructor>, previous: P140SPCache, counts: List<&2,U32>) -> Bool:
  p140spc_checked(p112s_prepare(book,names,constructors),p140sp_prepare(book,names,constructors,previous),counts)

@unsafe
def p140spc_checked(fresh: P112SPrepared, candidate: P140SPResult, counts: List<&2,U32>) -> Bool:
  match candidate:
    case P140SPResult{prepared,cache,stats}: p140spc_equal(fresh,prepared) && p134v_list(U32,U32.is_eq,stats,counts)

@unsafe
def p140spc_error(result: P140SPResult) -> Bool:
  match result:
    case P140SPResult{P112SPrepared{book,nodes,error},P140SPCache{constructors,blocked,entries},stats}:
      String.eq(error,"static atom present before fresh preparation") && List.is_empty(&2,P140SPEntry,entries)

@unsafe
def p140spc_inactive() -> List<&2,KDef>:
  ns_attach_book(book_cached([
    KDef{"a","Control",0,0,atom("Data"),KLiteral{"U32",0,"",0,0},[],False{},False{}},
    p140spc_def("b"),p140spc_def("c")],40),
    [p140spc_fact("a",p140spc_pair(1)),p140spc_fact("b",p140spc_pair(2)),p140spc_fact("c",p140spc_pair(3))],0,[])

@unsafe
def p140spc_controls() -> List<&2,String>:
  +names : List<&2,String> = ["a","b","c"]
  +ctors : List<&2,N_Constructor> = [N_Constructor{"Pair",2,True{}},N_Constructor{"Leaf",1,True{}}]
  +book = p140spc_book(1,2,p140spc_pair(3))
  +prior = p140spc_cache(p140sp_prepare(book,names,ctors,p140sp_empty()))
  +last = p140spc_book(1,2,p140spc_pair(4))
  +next = p140spc_cache(p140sp_prepare(last,names,ctors,prior))
  +bad = p140spc_book(1,2,kt("NStatic","Pair",0,0,[]))
  +raw = book_cached([p140spc_def("a"),p140spc_def("b"),p140spc_def("c")],40)
  +inactive = p140spc_inactive()
  +inactive_cache = p140spc_cache(p140sp_prepare(inactive,names,ctors,p140sp_empty()))
  +raw_cache = p140spc_cache(p140sp_prepare(raw,names,ctors,p140sp_empty()))
  [p114st_row("static-prefix-active-to-inactive",p140spc_check(inactive,names,ctors,prior,[0,3,0,2])),
   p114st_row("static-prefix-inactive-to-active",p140spc_check(book,names,ctors,inactive_cache,[0,3,0,3])),
   p114st_row("static-prefix-fact-disappeared",p140spc_check(raw,names,ctors,prior,[0,3,0,3])),
   p114st_row("static-prefix-ctor-arity-refuses",p140spc_check(book,names,[N_Constructor{"Pair",1,True{}},N_Constructor{"Leaf",1,True{}}],prior,[0,3,0,3])),
   p114st_row("static-prefix-cold-exact",p140spc_check(book,names,ctors,p140sp_empty(),[0,3,0,3])),
   p114st_row("static-prefix-noop-exact",p140spc_check(book,names,ctors,prior,[3,0,3,0])),
   p114st_row("static-prefix-last-edit-exact",p140spc_check(last,names,ctors,prior,[2,1,2,1])),
   p114st_row("static-prefix-first-edit-rebuilds-suffix",p140spc_check(p140spc_book(5,2,p140spc_pair(3)),names,ctors,prior,[0,3,0,3])),
   p114st_row("static-prefix-middle-edit-rebuilds-suffix",p140spc_check(p140spc_book(1,5,p140spc_pair(3)),names,ctors,prior,[1,2,1,2])),
   p114st_row("static-prefix-suffix-dedup-exact",p140spc_check(p140spc_book(1,2,p140spc_pair(2)),names,ctors,prior,[2,1,2,1])),
   p114st_row("static-prefix-reverted-edit-exact",p140spc_check(book,names,ctors,next,[2,1,2,1])),
   p114st_row("static-prefix-truncated-names-exact",p140spc_check(book,["a","b"],ctors,prior,[2,0,2,0])),
   p114st_row("static-prefix-reordered-names-exact",p140spc_check(book,["b","a","c"],ctors,prior,[0,3,0,3])),
   p114st_row("static-prefix-inserted-inactive-exact",p140spc_check(book,["missing","a","b","c"],ctors,prior,[0,4,0,3])),
   p114st_row("static-prefix-ctor-order-refuses",p140spc_check(book,names,[N_Constructor{"Leaf",1,True{}},N_Constructor{"Pair",2,True{}}],prior,[0,3,0,3])),
   p114st_row("static-prefix-ctor-hot-refuses",p140spc_check(book,names,[N_Constructor{"Pair",2,False{}},N_Constructor{"Leaf",1,True{}}],prior,[0,3,0,3])),
   p114st_row("static-prefix-no-fact-refuses",p140spc_check(raw,names,ctors,raw_cache,[0,3,0,3])),
   p114st_row("static-prefix-stale-exact",p140spc_check(bad,names,ctors,prior,[2,1,2,1])),
   p114st_row("static-prefix-error-not-published",p140spc_error(p140sp_prepare(bad,names,ctors,p140sp_empty()))),
   p114st_row("static-prefix-noncached-book-error-exact",p140spc_check([],names,ctors,prior,[]))]
